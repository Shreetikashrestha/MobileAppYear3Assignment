import 'package:flutter/material.dart';
import '../brand_dashboard_screen.dart';

class BrandBottomNav extends StatefulWidget {
  const BrandBottomNav({super.key});

  @override
  State<BrandBottomNav> createState() => _BrandBottomNavState();
}

class _BrandBottomNavState extends State<BrandBottomNav> {
  int _currentIndex = 0;
  final List<Widget> _screens = const [
    BrandDashboardScreen(),
    // Add other screens for brand navigation as needed
    Center(child: Text('Discover')),
    Center(child: Text('Messages')),
    Center(child: Text('Profile')),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        selectedItemColor: Colors.purple,
        unselectedItemColor: Colors.grey,
        showUnselectedLabels: true,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.search), label: 'Discover'),
          BottomNavigationBarItem(icon: Icon(Icons.message), label: 'Messages'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }
}
