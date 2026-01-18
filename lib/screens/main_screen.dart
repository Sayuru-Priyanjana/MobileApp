import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'home/home_screen.dart';
import 'post/create_post_screen.dart';
import 'search_screen.dart';
import 'discovery_screen.dart'; // Add this import
import 'profile/profile_screen.dart';
import '../providers/user_provider.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    // Current User for Profile Screen
    final user = Provider.of<UserProvider>(context).currentUser;
    // Note: If user is null (shouldn't be here), showing empty profile or redirects handled by splash

    final List<Widget> screens = [
      const HomeScreen(),
      const SearchScreen(),
      CreatePostScreen(
        onPostSuccess: () {
          setState(() {
            _currentIndex = 0;
          });
        },
      ),
      const DiscoveryScreen(), // New Tab
      if (user != null)
        ProfileScreen(userId: user.id, isCurrentUser: true)
      else
        const SizedBox(),
    ];

    return Scaffold(
      body: screens[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        selectedItemColor: Theme.of(context).primaryColor,
        unselectedItemColor: Colors.grey,
        showSelectedLabels: false,
        showUnselectedLabels: false,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.search),
            activeIcon: Icon(Icons.search, weight: 700),
            label: 'Search',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.add_circle_outline, size: 32),
            activeIcon: Icon(Icons.add_circle, size: 32),
            label: 'Create',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.explore_outlined),
            activeIcon: Icon(Icons.explore),
            label: 'Discovery',
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
