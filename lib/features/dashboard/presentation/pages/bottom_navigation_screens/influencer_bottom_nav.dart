import 'package:flutter/material.dart';
import 'package:influcollb_app/features/dashboard/presentation/pages/influencer_dashboard_screen.dart';

import 'messages_screen.dart';
import 'profile_screen.dart';
import 'search_screen.dart';

class InfluencerBottomNav extends StatefulWidget {
  const InfluencerBottomNav({super.key});

  @override
  State<InfluencerBottomNav> createState() => _InfluencerBottomNavState();
}

class _InfluencerBottomNavState extends State<InfluencerBottomNav> {
  int _currentIndex = 0;
  final List<Widget> _screens = const [
    InfluencerDashboardScreen(),
    SearchScreen(),
    MessagesScreen(),
    ProfileScreen(),
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
