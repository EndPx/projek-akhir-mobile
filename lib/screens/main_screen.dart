import 'package:flutter/material.dart';
import '../screens/competitions_screen.dart';
import '../screens/favorites_screen.dart';
import '../screens/profile_screen.dart';
import '../screens/feedback_screen.dart';
import '../services/auth_service.dart';
import '../screens/login_screen.dart';
import 'package:provider/provider.dart';
import '../provider/profile_provider.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;
  final AuthService _authService = AuthService();

  static List<Widget> _widgetOptions(BuildContext context) => <Widget>[
  const CompetitionsScreen(),
  const FavoritesScreen(),
    ChangeNotifierProvider(
      create: (_) => ProfileProvider(),
      child: const ProfileScreen(),
    ),
    const FeedbackScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  void _logout(BuildContext context) async {
    await _authService.logout();
    if (mounted) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => const LoginScreen()),
        (Route<dynamic> route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    String title = "Info Sepak Bola";
    if (_selectedIndex == 0) title = "Kompetisi";
    if (_selectedIndex == 1) title = "Favorit";
    if (_selectedIndex == 2) title = "Profil Pengguna";
    if (_selectedIndex == 3) title = "Saran & Kesan";
    
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        actions: [
          if (_selectedIndex == 2)
            IconButton(
              icon: const Icon(Icons.logout),
              onPressed: () => _logout(context),
              tooltip: 'Logout',
            )
        ],
      ),
      body: Center(
        child: _widgetOptions(context).elementAt(_selectedIndex),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.emoji_events_outlined),
            label: 'Kompetisi',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.favorite_border),
            label: 'Favorit',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            label: 'Profil',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.rate_review_outlined),
            label: 'Saran/Kesan',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Theme.of(context).colorScheme.primary,
        unselectedItemColor: Colors.grey,
        showUnselectedLabels: true,
        onTap: _onItemTapped,
        type: BottomNavigationBarType.fixed,
      ),
    );
  }
}