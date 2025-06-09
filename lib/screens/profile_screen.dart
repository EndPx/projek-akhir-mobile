import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../models/user_model.dart';
import '../services/auth_service.dart';
import '../screens/login_screen.dart';
import 'package:permission_handler/permission_handler.dart';
import 'gyroscope_screen.dart';
import '../provider/profile_provider.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final TextEditingController _currencyAmountController = TextEditingController();
  String? _fromCurrency = 'USD';
  String? _toCurrency = 'IDR';
  String _convertedAmount = "";
  final List<String> _currencies = ['USD', 'IDR', 'EUR'];

  final Map<String, double> _ratesRelativeToUSD = {
    'USD': 1.0,
    'IDR': 15000.0,
    'EUR': 0.90,
  };

  final TextEditingController _usernameEditController = TextEditingController();

  @override
  void dispose() {
    _currencyAmountController.dispose();
    _usernameEditController.dispose();
    super.dispose();
  }

  void _convertCurrency() {
    if (_currencyAmountController.text.isEmpty ||
        _fromCurrency == null ||
        _toCurrency == null) {
      setState(() => _convertedAmount = "Input tidak valid");
      return;
    }
    final double amount =
        double.tryParse(_currencyAmountController.text.replaceAll(',', '.')) ?? 0.0;
    if (amount <= 0) {
      setState(() => _convertedAmount = "Jumlah tidak valid");
      return;
    }

    double amountInUSD;
    amountInUSD = amount / _ratesRelativeToUSD[_fromCurrency!]!;

    double finalAmount = amountInUSD * _ratesRelativeToUSD[_toCurrency!]!;

    final formatter = NumberFormat.currency(
      locale: _toCurrency == 'IDR'
          ? 'id_ID'
          : (_toCurrency == 'EUR' ? 'de_DE' : 'en_US'),
      symbol:
          _toCurrency == 'IDR' ? 'Rp ' : (_toCurrency == 'EUR' ? '€' : '\$'),
      decimalDigits: _toCurrency == 'IDR' ? 0 : 2,
    );

    setState(() {
      _convertedAmount = formatter.format(finalAmount);
    });
  }

  Widget _buildTimeConverterSection() {
    final now = DateTime.now();
    final idLocaleFormatter = DateFormat('HH:mm:ss (dd MMM yyyy)', 'id_ID');
    final gbLocaleFormatter = DateFormat('HH:mm:ss (dd MMM yyyy)', 'en_GB');

    final String localTime = idLocaleFormatter.format(now);
    final String wibTime =
        idLocaleFormatter.format(now.toUtc().add(const Duration(hours: 7)));
    final String witaTime =
        idLocaleFormatter.format(now.toUtc().add(const Duration(hours: 8)));
    final String witTime =
        idLocaleFormatter.format(now.toUtc().add(const Duration(hours: 9)));
    final String londonTime =
        gbLocaleFormatter.format(now.toUtc().add(const Duration(hours: 1)));

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Waktu Lokal Anda: $localTime',
              style: const TextStyle(fontSize: 15)),
          const SizedBox(height: 4),
          Text('WIB (UTC+7): $wibTime', style: const TextStyle(fontSize: 15)),
          const SizedBox(height: 4),
          Text('WITA (UTC+8): $witaTime', style: const TextStyle(fontSize: 15)),
          const SizedBox(height: 4),
          Text('WIT (UTC+9): $witTime', style: const TextStyle(fontSize: 15)),
          const SizedBox(height: 4),
          Text('London (Sekarang): $londonTime',
              style: const TextStyle(fontSize: 15)),
        ],
      ),
    );
  }

  Future<void> _pickImage(BuildContext context, ImageSource source) async {
    PermissionStatus status;
    if (source == ImageSource.camera) {
      status = await Permission.camera.request();
    } else {
      status = await Permission.photos.request();
    }

    if (status.isGranted) {
      try {
        final ImagePicker picker = ImagePicker();
        final XFile? image = await picker.pickImage(
          source: source,
          maxWidth: 800,
          imageQuality: 70,
        );

        if (image != null && mounted) {
          await Provider.of<ProfileProvider>(context, listen: false)
              .saveProfilePicturePath(image.path);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Foto profil berhasil diperbarui!')),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Gagal mengambil gambar: $e')),
          );
        }
      }
    } else if (status.isDenied || status.isRestricted) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Izin tidak diberikan untuk mengakses gambar.')),
        );
      }
    } else if (status.isPermanentlyDenied) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text(
                  'Izin akses gambar ditolak permanen. Buka pengaturan aplikasi.')),
        );
        await openAppSettings();
      }
    }
  }

  void _showImageSourceActionSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext bc) {
        return SafeArea(
          child: Wrap(
            children: <Widget>[
              ListTile(
                leading: const Icon(Icons.photo_library_outlined),
                title: const Text('Galeri'),
                onTap: () {
                  Navigator.of(context).pop();
                  _pickImage(context, ImageSource.gallery);
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_camera_outlined),
                title: const Text('Kamera'),
                onTap: () {
                  Navigator.of(context).pop();
                  _pickImage(context, ImageSource.camera);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _showEditUsernameDialog(BuildContext context, ProfileProvider provider) {
    _usernameEditController.text = provider.user?.username ?? "";
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Edit Username'),
          content: TextField(
            controller: _usernameEditController,
            decoration:
                const InputDecoration(hintText: "Masukkan username baru"),
            autofocus: true,
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Batal'),
              onPressed: () => Navigator.of(dialogContext).pop(),
            ),
            TextButton(
              child: const Text('Simpan'),
              onPressed: () async {
                if (_usernameEditController.text.trim().isNotEmpty) {
                  await provider.updateUsername(_usernameEditController.text.trim());
                  if (mounted) {
                    Navigator.of(dialogContext).pop();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Username berhasil diperbarui!')),
                    );
                  }
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Username tidak boleh kosong.')),
                  );
                }
              },
            ),
          ],
        );
      },
    );
  }

  void _performLogout(BuildContext context, ProfileProvider provider) async {
    await provider.logout();
    if (mounted) {
      Navigator.of(context, rootNavigator: true).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => const LoginScreen()),
        (Route<dynamic> route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ProfileProvider>(
      builder: (context, provider, _) {
        return Scaffold(
          body: provider.isLoading
              ? const Center(child: CircularProgressIndicator())
              : RefreshIndicator(
                  onRefresh: provider.loadInitialData,
                  child: ListView(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16.0, vertical: 20.0),
                    children: <Widget>[
                      Center(
                        child: Stack(
                          alignment: Alignment.bottomRight,
                          children: [
                            CircleAvatar(
                              radius: 60,
                              backgroundColor: Colors.grey.shade300,
                              backgroundImage: provider.profileImageFile != null &&
                                      provider.profileImageFile!.existsSync()
                                  ? FileImage(provider.profileImageFile!)
                                  : null,
                              child: (provider.profileImageFile == null ||
                                      !provider.profileImageFile!.existsSync())
                                  ? Icon(Icons.person,
                                      size: 60, color: Colors.grey.shade700)
                                  : null,
                            ),
                            MaterialButton(
                              onPressed: () => _showImageSourceActionSheet(context),
                              color: Theme.of(context).primaryColor,
                              textColor: Colors.white,
                              padding: const EdgeInsets.all(10),
                              shape: const CircleBorder(),
                              child: const Icon(Icons.camera_alt, size: 22),
                            )
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      Center(
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Flexible(
                              child: Text(
                                provider.user?.username ?? "Username",
                                style: const TextStyle(
                                    fontSize: 22, fontWeight: FontWeight.bold),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            IconButton(
                              icon: Icon(Icons.edit,
                                  size: 20,
                                  color: Theme.of(context).colorScheme.primary),
                              onPressed: () => _showEditUsernameDialog(context, provider),
                              tooltip: "Edit Username",
                              padding: const EdgeInsets.all(4),
                              constraints: const BoxConstraints(),
                            )
                          ],
                        ),
                      ),
                      Center(
                        child: Text(
                          provider.user?.email ?? "email@example.com",
                          style:
                              TextStyle(fontSize: 16, color: Colors.grey.shade700),
                        ),
                      ),
                      const SizedBox(height: 24),
                      Card(
                        elevation: 2,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                        child: ExpansionTile(
                          leading: Icon(Icons.monetization_on_outlined,
                              color: Theme.of(context).colorScheme.primary),
                          title: Text('Konverter Mata Uang',
                              style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  color: Theme.of(context).colorScheme.primary)),
                          initiallyExpanded: false,
                          childrenPadding:
                              const EdgeInsets.all(16.0).copyWith(top: 0),
                          tilePadding: const EdgeInsets.symmetric(
                              horizontal: 16.0, vertical: 8.0),
                          children: <Widget>[
                            TextField(
                              controller: _currencyAmountController,
                              keyboardType: const TextInputType.numberWithOptions(
                                  decimal: true),
                              decoration: InputDecoration(
                                labelText: 'Jumlah',
                                border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8)),
                                prefixIcon: const Icon(Icons.input),
                              ),
                            ),
                            const SizedBox(height: 12),
                            Row(
                              children: [
                                Expanded(
                                  child: DropdownButtonFormField<String>(
                                    decoration: InputDecoration(
                                        labelText: 'Dari',
                                        border: OutlineInputBorder(
                                            borderRadius:
                                                BorderRadius.circular(8))),
                                    value: _fromCurrency,
                                    items: _currencies.map((String value) {
                                      return DropdownMenuItem<String>(
                                          value: value, child: Text(value));
                                    }).toList(),
                                    onChanged: (String? newValue) {
                                      setState(() => _fromCurrency = newValue);
                                    },
                                  ),
                                ),
                                Padding(
                                  padding:
                                      const EdgeInsets.symmetric(horizontal: 8.0),
                                  child: IconButton(
                                    icon: const Icon(Icons.swap_horiz, size: 28),
                                    onPressed: () {
                                      setState(() {
                                        final temp = _fromCurrency;
                                        _fromCurrency = _toCurrency;
                                        _toCurrency = temp;
                                        if (_currencyAmountController
                                            .text.isNotEmpty) _convertCurrency();
                                      });
                                    },
                                    tooltip: "Tukar Mata Uang",
                                    color: Theme.of(context).colorScheme.primary,
                                  ),
                                ),
                                Expanded(
                                  child: DropdownButtonFormField<String>(
                                    decoration: InputDecoration(
                                        labelText: 'Ke',
                                        border: OutlineInputBorder(
                                            borderRadius:
                                                BorderRadius.circular(8))),
                                    value: _toCurrency,
                                    items: _currencies.map((String value) {
                                      return DropdownMenuItem<String>(
                                          value: value, child: Text(value));
                                    }).toList(),
                                    onChanged: (String? newValue) {
                                      setState(() => _toCurrency = newValue);
                                    },
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            ElevatedButton.icon(
                              icon: const Icon(Icons.currency_exchange),
                              label: const Text('Konversi'),
                              onPressed: _convertCurrency,
                              style: ElevatedButton.styleFrom(
                                  backgroundColor:
                                      Theme.of(context).colorScheme.primary,
                                  foregroundColor:
                                      Theme.of(context).colorScheme.onPrimary,
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 24, vertical: 12),
                                  textStyle: const TextStyle(fontSize: 16)),
                            ),
                            const SizedBox(height: 12),
                            if (_convertedAmount.isNotEmpty)
                              Padding(
                                padding: const EdgeInsets.only(top: 8.0),
                                child: Text(
                                  'Hasil: $_convertedAmount',
                                  style: const TextStyle(
                                      fontSize: 18, fontWeight: FontWeight.bold),
                                ),
                              ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 8),
                      Card(
                        elevation: 2,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                        child: ExpansionTile(
                          leading: Icon(Icons.access_time_outlined,
                              color: Theme.of(context).colorScheme.primary),
                          title: Text('Konverter Waktu Global',
                              style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  color: Theme.of(context).colorScheme.primary)),
                          initiallyExpanded: false,
                          childrenPadding:
                              const EdgeInsets.all(16.0).copyWith(top: 0),
                          tilePadding: const EdgeInsets.symmetric(
                              horizontal: 16.0, vertical: 8.0),
                          children: <Widget>[
                            _buildTimeConverterSection(),
                          ],
                        ),
                      ),
                      const SizedBox(height: 8),
                      Card(
                        elevation: 2,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                        child: ListTile(
                          leading: const Icon(Icons.screen_rotation, color: Colors.blueAccent),
                          title: const Text('Sensor Gyroscope'),
                          subtitle: const Text('Lihat data sensor gyroscope perangkat'),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => const GyroscopeScreen()),
                            );
                          },
                        ),
                      ),
                      const SizedBox(height: 24),
                      Center(
                        child: ElevatedButton.icon(
                          icon: const Icon(Icons.logout),
                          label: const Text('Logout'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Theme.of(context).colorScheme.error,
                            foregroundColor: Theme.of(context).colorScheme.onError,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 32, vertical: 14),
                            textStyle: const TextStyle(fontSize: 16),
                          ),
                          onPressed: () => _performLogout(context, provider),
                        ),
                      ),
                    ],
                  ),
                ),
        );
      },
    );
  }
}