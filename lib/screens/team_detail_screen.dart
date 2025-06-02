import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/football_models.dart';
import '../services/football_api_service.dart';
import '../helpers/database_helper.dart'; // IMPORT DATABASE HELPER

class TeamDetailScreen extends StatefulWidget {
  final int teamId;
  final String teamName;

  const TeamDetailScreen({
    super.key,
    required this.teamId,
    required this.teamName,
  });

  @override
  State<TeamDetailScreen> createState() => _TeamDetailScreenState();
}

class _TeamDetailScreenState extends State<TeamDetailScreen> {
  late Future<TeamDetailResponse> _teamDetailFuture;
  final FootballApiService _apiService = FootballApiService();
  final DatabaseHelper _dbHelper = DatabaseHelper(); // INSTANCE DATABASE HELPER

  String _selectedDisplayCurrency = 'EUR';
  final List<String> _displayCurrencies = ['EUR', 'USD', 'IDR'];
  final Map<String, double> _ratesFromEUR = {
    'EUR': 1.0,
    'USD': 1.11,
    'IDR': 16500.0,
  };

  bool _isFavoriteTeam = false; // State untuk status favorit tim
  TeamDetailResponse? _currentTeamDetail; // Untuk menyimpan detail tim saat ini

  @override
  void initState() {
    super.initState();
    _loadTeamDetailsAndFavoriteStatus();
  }
  
  Future<void> _loadTeamDetailsAndFavoriteStatus() async {
    // Muat detail tim dulu
    setState(() {
      _teamDetailFuture = _apiService.getTeamDetails(widget.teamId);
    });
    // Setelah detail tim dimuat, baru cek status favoritnya
    // atau bisa juga cek status favorit bersamaan jika ID sudah ada
    final teamDetail = await _teamDetailFuture; // Tunggu future selesai
    if (mounted) {
      setState(() {
        _currentTeamDetail = teamDetail; // Simpan detail tim
      });
    }
    await _checkIfFavorite(); // Cek status favorit
  }


  Future<void> _loadTeamDetails() async { // Fungsi ini akan dipanggil oleh RefreshIndicator
    setState(() {
      _teamDetailFuture = _apiService.getTeamDetails(widget.teamId);
    });
    final teamDetail = await _teamDetailFuture;
     if (mounted) {
      setState(() {
        _currentTeamDetail = teamDetail;
      });
    }
    await _checkIfFavorite();
  }


  Future<void> _checkIfFavorite() async {
    final isFav = await _dbHelper.isTeamFavorite(widget.teamId);
    if (mounted) {
      setState(() {
        _isFavoriteTeam = isFav;
      });
    }
  }

  Future<void> _toggleFavoriteTeam() async {
    if (_currentTeamDetail == null) return;

    if (_isFavoriteTeam) {
      await _dbHelper.removeFavoriteTeam(widget.teamId);
    } else {
      // Gunakan _currentTeamDetail yang sudah ada
      await _dbHelper.addFavoriteTeamFromDetail(_currentTeamDetail!);
    }
    await _checkIfFavorite(); // Update status favorit dan UI
  }


  String _formatMarketValue(int? marketValueEUR) {
    // ... (fungsi _formatMarketValue tetap sama)
    if (marketValueEUR == null) return 'N/A';
    double convertedValue = marketValueEUR * _ratesFromEUR[_selectedDisplayCurrency]!;
    
    final formatter = NumberFormat.currency(
      locale: _selectedDisplayCurrency == 'IDR' ? 'id_ID' : (_selectedDisplayCurrency == 'EUR' ? 'de_DE' : 'en_US'),
      symbol: _selectedDisplayCurrency == 'IDR' ? 'Rp ' : (_selectedDisplayCurrency == 'EUR' ? '€' : '\$'),
      decimalDigits: 0,
    );
    return formatter.format(convertedValue);
  }

  Widget _buildInfoRow(String label, String? value, {IconData? icon, bool isLink = false}) {
    // ... (fungsi _buildInfoRow tetap sama)
     if (value == null || value.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (icon != null) Icon(icon, size: 18, color: Theme.of(context).colorScheme.primary),
          if (icon != null) const SizedBox(width: 8),
          Text('$label: ', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontSize: 14,
                color: isLink ? Colors.blue : null,
                decoration: isLink ? TextDecoration.underline : null,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTeamCrestImage(String? crestUrl, {double size = 80}) {
    // ... (fungsi _buildTeamCrestImage tetap sama)
    if (crestUrl == null || crestUrl.isEmpty) {
      return Icon(Icons.shield_outlined, size: size, color: Colors.grey);
    }
    return Image.network(crestUrl, height: size, width: size, fit: BoxFit.contain,
      errorBuilder: (c,e,s) => Icon(Icons.shield_outlined, size: size, color: Colors.grey),
    );
  }
  
  Widget _buildLastUpdatedSection(String? utcTimestamp) {
    // ... (fungsi _buildLastUpdatedSection tetap sama)
    if (utcTimestamp == null) return const SizedBox.shrink();
    try {
      final DateTime utcDateTime = DateTime.parse(utcTimestamp); 
      final DateFormat idFormatter = DateFormat('dd MMM yy, HH:mm', 'id_ID');
      final DateFormat gbFormatter = DateFormat('dd MMM yy, HH:mm', 'en_GB');

      final String wibTime = idFormatter.format(utcDateTime.add(const Duration(hours: 7)));
      final String witaTime = idFormatter.format(utcDateTime.add(const Duration(hours: 8)));
      final String witTime = idFormatter.format(utcDateTime.add(const Duration(hours: 9)));
      final String londonTimeAsUTC = gbFormatter.format(utcDateTime);

      return Card(
        elevation: 1,
        margin: const EdgeInsets.only(top: 16.0, bottom: 8.0),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Pembaruan Terakhir (Server)', style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold)),
              const Divider(height: 12, thickness: 0.5),
              Text('UTC: ${DateFormat('dd MMM yy, HH:mm \'Z\'').format(utcDateTime)}', style: const TextStyle(fontSize: 12)),
              Text('WIB: $wibTime', style: const TextStyle(fontSize: 12)),
              Text('WITA: $witaTime', style: const TextStyle(fontSize: 12)),
              Text('WIT: $witTime', style: const TextStyle(fontSize: 12)),
              Text('London (UTC): $londonTimeAsUTC', style: const TextStyle(fontSize: 12)),
            ],
          ),
        ),
      );
    } catch (e) {
      return Text('Gagal format tanggal: $utcTimestamp', style: const TextStyle(color: Colors.red, fontSize: 12));
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.teamName),
        actions: [
          // Tombol Favorit di AppBar
          if (_currentTeamDetail != null) // Hanya tampilkan jika detail tim sudah dimuat
            IconButton(
              icon: Icon(
                _isFavoriteTeam ? Icons.star_rounded : Icons.star_border_rounded,
                color: _isFavoriteTeam ? Colors.amber.shade600 : null, // Warna null akan mengambil warna default ikon AppBar
                size: 28,
              ),
              onPressed: _toggleFavoriteTeam,
              tooltip: _isFavoriteTeam ? 'Hapus dari Favorit' : 'Tambah ke Favorit',
            ),
        ],
      ),
      body: FutureBuilder<TeamDetailResponse>(
        future: _teamDetailFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center( /* Error View */ );
          } else if (snapshot.hasData) {
            final team = snapshot.data!;
            // _currentTeamDetail = team; // Sudah di-set di _loadTeamDetailsAndFavoriteStatus atau _loadTeamDetails
            
            return RefreshIndicator(
              onRefresh: _loadTeamDetails,
              child: ListView(
                padding: const EdgeInsets.all(16.0),
                children: [
                  Center(
                    child: Column(
                      children: [
                        _buildTeamCrestImage(team.crest),
                        const SizedBox(height: 12),
                        Text(team.name, style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold), textAlign: TextAlign.center),
                        if (team.shortName != null && team.shortName != team.name)
                          Text(team.shortName!, style: Theme.of(context).textTheme.titleMedium?.copyWith(color: Colors.grey.shade700)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  Card(
                    elevation: 2,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Informasi Tim', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w600)),
                          const Divider(height: 20, thickness: 0.5),
                          _buildInfoRow('Didirikan', team.founded?.toString(), icon: Icons.cake_outlined),
                          _buildInfoRow('Venue', team.venue, icon: Icons.stadium_outlined),
                          _buildInfoRow('Alamat', team.address, icon: Icons.location_on_outlined),
                          _buildInfoRow('Website', team.website, icon: Icons.public_outlined, isLink: true),
                          _buildInfoRow('Warna Klub', team.clubColors, icon: Icons.color_lens_outlined),
                          if (team.marketValue != null)
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 4.0),
                              child: Row(
                                children: [
                                  Icon(Icons.show_chart_outlined, size: 18, color: Colors.green.shade700),
                                  const SizedBox(width: 8),
                                  const Text('Total Nilai Pasar: ', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                                  Expanded(child: Text(_formatMarketValue(team.marketValue), style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500))),
                                ],
                              ),
                            ),
                           if(team.runningCompetitions.isNotEmpty) ...[
                            const SizedBox(height: 10),
                            Text('Kompetisi Aktif:', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                            const SizedBox(height: 4),
                            Wrap(
                              spacing: 8.0,
                              runSpacing: 0.0,
                              children: team.runningCompetitions.map((comp) => Chip(
                                avatar: comp.emblem != null ? Padding(
                                  padding: const EdgeInsets.all(2.0),
                                  child: _buildTeamCrestImage(comp.emblem, size: 16)) : null,
                                label: Text(comp.name, style: const TextStyle(fontSize: 11)),
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                                visualDensity: VisualDensity.compact,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                                side: BorderSide(color: Theme.of(context).dividerColor),
                                backgroundColor: Theme.of(context).colorScheme.surface,
                              )).toList(),
                            ),
                           ]
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  if (team.coach != null && team.coach!.name != null)
                  Card(
                    elevation: 2,
                     shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                           Text('Pelatih', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w600)),
                           const Divider(height: 20, thickness: 0.5),
                          _buildInfoRow('Nama', team.coach!.name, icon: Icons.person_pin_outlined),
                          _buildInfoRow('Kewarganegaraan', team.coach!.nationality, icon: Icons.flag_outlined),
                          _buildInfoRow('Tgl. Lahir', team.coach!.dateOfBirth, icon: Icons.calendar_today_outlined),
                           if (team.coach!.contract?.start != null || team.coach!.contract?.until != null)
                            _buildInfoRow('Kontrak', '${team.coach!.contract?.start ?? '?'} - ${team.coach!.contract?.until ?? '?'}', icon: Icons.article_outlined),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  Text('Skuad Tim', style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  if (team.squad.any((p) => p.marketValue != null))
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Text('Harga dlm: ', style: Theme.of(context).textTheme.bodySmall),
                        DropdownButton<String>(
                          value: _selectedDisplayCurrency,
                          items: _displayCurrencies.map((String value) {
                            return DropdownMenuItem<String>(value: value, child: Text(value, style: Theme.of(context).textTheme.bodySmall));
                          }).toList(),
                          onChanged: (String? newValue) {
                            if (newValue != null) {
                              setState(() {
                                _selectedDisplayCurrency = newValue;
                              });
                            }
                          },
                          underline: const SizedBox.shrink(),
                        ),
                      ],
                    )
                  else if (team.squad.isNotEmpty)
                    const SizedBox(height: 4),
                  
                  if (team.squad.isEmpty)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 16.0),
                      child: Text('Data skuad tidak tersedia.', textAlign: TextAlign.center),
                    )
                  else
                    ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: team.squad.length,
                      itemBuilder: (context, index) {
                        final player = team.squad[index];
                        return Card(
                          elevation: 1,
                          margin: const EdgeInsets.symmetric(vertical: 4.0),
                           shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Row(
                              children: [
                                CircleAvatar(
                                  radius: 20,
                                  backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                                  child: Text(
                                    player.shirtNumber?.toString() ?? (player.position != null && player.position!.isNotEmpty ? player.position![0].toUpperCase() : '?'), 
                                    style: TextStyle(color: Theme.of(context).colorScheme.onPrimaryContainer, fontSize: player.shirtNumber != null ? 14: 10, fontWeight: FontWeight.bold)
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(player.name, style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 14.5)),
                                      Text('${player.position ?? 'N/A'} - ${player.nationality ?? 'N/A'}', style: TextStyle(fontSize: 12.5, color: Colors.grey.shade700)),
                                      if (player.dateOfBirth != null)
                                        Text('Lahir: ${player.dateOfBirth}', style: const TextStyle(fontSize: 11, color: Colors.grey)),
                                    ],
                                  ),
                                ),
                                if (player.marketValue != null)
                                  Padding(
                                    padding: const EdgeInsets.only(left: 8.0),
                                    child: Text(_formatMarketValue(player.marketValue), style: TextStyle(fontSize: 12, color: Colors.green.shade800, fontStyle: FontStyle.italic, fontWeight: FontWeight.w500)),
                                  )
                                else if (team.squad.any((p) => p.marketValue != null))
                                   Padding(
                                    padding: const EdgeInsets.only(left: 8.0),
                                    child: Text('N/A', style: TextStyle(fontSize: 12, color: Colors.grey.shade600, fontStyle: FontStyle.italic)),
                                  ),
                              ],
                            ),
                          ),
                        );
                      },
                      separatorBuilder: (context, index) => const SizedBox(height: 2),
                    ),
                  
                  _buildLastUpdatedSection(team.lastUpdated),

                ],
              ),
            );
          } else {
            return const Center(child: Text('Tidak ada detail tim ditemukan.'));
          }
        },
      ),
    );
  }
}