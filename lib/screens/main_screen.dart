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
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          border: Border(
            top: BorderSide(
              color: Theme.of(context).dividerColor.withOpacity(0.1),
              width: 1,
            ),
          ),
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) {
            setState(() {
              _currentIndex = index;
            });
          },
          backgroundColor: Colors.transparent, // Use Container color
          elevation: 0,
          selectedItemColor: Theme.of(context).primaryColor,
          unselectedItemColor: Colors.grey.withOpacity(0.6),
          showSelectedLabels: false,
          showUnselectedLabels: false,
          type: BottomNavigationBarType.fixed,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home_outlined, size: 28),
              activeIcon: Icon(Icons.home, size: 28),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.search, size: 28),
              activeIcon: Icon(Icons.search, weight: 700, size: 28),
              label: 'Search',
            ),
            BottomNavigationBarItem(
              icon: Icon(
                Icons.add_circle_outline,
                size: 36,
              ), // Prominent Create
              activeIcon: Icon(Icons.add_circle, size: 36),
              label: 'Create',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.explore_outlined, size: 28),
              activeIcon: Icon(Icons.explore, size: 28),
              label: 'Discovery',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person_outline, size: 28),
              activeIcon: Icon(Icons.person, size: 28),
              label: 'Profile',
            ),
          ],
        ),
      ),
    );
  }
}
