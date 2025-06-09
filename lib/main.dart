import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:provider/provider.dart';
import '../services/auth_service.dart';
import '../screens/login_screen.dart';
import '../screens/main_screen.dart';
import '../provider/competitions_provider.dart';
import '../provider/standings_provider.dart';
import '../provider/team_detail_provider.dart';
import '../provider/favorites_provider.dart';
import '../provider/user_provider.dart';
import '../helpers/notification_helper.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await NotificationHelper.init();

  if (await Permission.notification.isDenied) {
    await Permission.notification.request();
  }

  await initializeDateFormatting('id_ID', null);
  await initializeDateFormatting('en_GB', null);

  await NotificationHelper.init(); // Inisialisasi notifikasi

  final AuthService authService = AuthService();
  final bool loggedIn = await authService.isLoggedIn();
  runApp(MyApp(isLoggedIn: loggedIn));
}

class MyApp extends StatelessWidget {
  final bool isLoggedIn;

  const MyApp({
    super.key,
    required this.isLoggedIn,
  });

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => CompetitionsProvider()),
        ChangeNotifierProvider(create: (_) => FavoritesProvider()),
        ChangeNotifierProvider(create: (_) => UserProvider()),
      ],
      child: MaterialApp(
        title: 'Aplikasi Info Sepak Bola & Profil',
        theme: ThemeData(
          primarySwatch: Colors.blue,
          visualDensity: VisualDensity.adaptivePlatformDensity,
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.green),
          useMaterial3: true,
        ),
        home: isLoggedIn ? const MainScreen() : const LoginScreen(),
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}