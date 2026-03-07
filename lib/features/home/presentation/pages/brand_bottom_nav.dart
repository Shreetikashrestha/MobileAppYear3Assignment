import 'package:flutter/material.dart';
import 'package:influcollb_app/features/home/presentation/pages/brand_home_screen.dart';
import 'package:influcollb_app/features/home/presentation/pages/enhanced_brand_dashboard_screen.dart';
import 'package:influcollb_app/features/messages/presentation/pages/conversations_list_screen.dart';
import 'package:influcollb_app/features/profile/presentation/pages/profile_screen.dart';

class BrandBottomNav extends StatefulWidget {
  const BrandBottomNav({super.key});

  @override
  State<BrandBottomNav> createState() => _BrandBottomNavState();
}

class _BrandBottomNavState extends State<BrandBottomNav> {
  int _currentIndex = 0;
  final List<Widget> _screens = const [
    BrandHomeScreen(),
    EnhancedBrandDashboardScreen(),
    ConversationsListScreen(),
    ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        selectedItemColor: const Color(0xFF8F00FF),
        unselectedItemColor: Colors.grey,
        showUnselectedLabels: true,
        type: BottomNavigationBarType.fixed,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.campaign_outlined),
            activeIcon: Icon(Icons.campaign),
            label: 'Campaigns',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.message_outlined),
            activeIcon: Icon(Icons.message),
            label: 'Messages',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            activeIcon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}

