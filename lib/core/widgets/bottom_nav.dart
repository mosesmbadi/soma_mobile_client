import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:soma/features/home_page/viewmodels/home_page_viewmodel.dart'; // Reusing the viewmodel for selectedIndex

import 'package:soma/features/my_stories_page/views/my_stories_page.dart';
import 'package:soma/features/add_story_page/views/add_story_page.dart';
import 'package:soma/features/profile_page/views/profile_page.dart';
import 'package:soma/features/home_page/views/home_page.dart'; // Import HomePage

class BottomNavShell extends StatelessWidget {
  const BottomNavShell({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => HomePageViewModel(), // Reusing the viewmodel for navigation state
      child: Consumer<HomePageViewModel>(
        builder: (context, viewModel, child) {
          return Scaffold(
            body: Center(
              child: _buildPage(viewModel.selectedIndex),
            ),
            bottomNavigationBar: BottomNavigationBar(
              items: const <BottomNavigationBarItem>[
                BottomNavigationBarItem(
                  icon: Icon(Icons.home),
                  label: 'Home',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.note),
                  label: 'My Stories',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.add_circle),
                  label: 'Add Story',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.person),
                  label: 'Profile',
                ),
              ],
              currentIndex: viewModel.selectedIndex,
              selectedItemColor: Colors.blueAccent,
              unselectedItemColor: Colors.grey,
              onTap: viewModel.onItemTapped,
              type: BottomNavigationBarType.fixed,
            ),
          );
        },
      ),
    );
  }

  /// Builds the appropriate screen based on selected tab
  Widget _buildPage(int selectedIndex) {
    switch (selectedIndex) {
      case 0:
        return const HomePage(); // Changed to HomePage
      case 1:
        return const MyStoriesPage();
      case 2:
        return const AddStoryPage();
      case 3:
        return const ProfilePage();
      default:
        return const HomePage(); // Changed to HomePage
    }
  }
}
