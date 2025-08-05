import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:soma/features/home_page/viewmodels/home_page_viewmodel.dart';

import 'package:soma/features/my_stories_page/views/my_stories_page.dart';
import 'package:soma/features/add_story_page/views/add_story_page.dart';
import 'package:soma/features/profile_page/views/profile_page.dart';
import 'package:soma/features/home_page/views/home_page.dart';

class BottomNavShell extends StatelessWidget {
  const BottomNavShell({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => HomePageViewModel(),
      child: Consumer<HomePageViewModel>(
        builder: (context, viewModel, child) {
          return Scaffold(
            extendBody: true,
            body: Stack(
              children: [
                _buildPage(viewModel.selectedIndex),

                // Floating Bottom Navigation
                Positioned(
                  bottom: 16,
                  left: 16,
                  right: 16,
                  child: Card(
                    elevation: 8,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                      child: Theme(
                        data: Theme.of(context).copyWith(
                          splashFactory: InkRipple.splashFactory, // Circular ripple
                          splashColor: Colors.blueAccent.withOpacity(0.2),
                          highlightColor: Colors.transparent, // No highlight overlay
                        ),
                        child: BottomNavigationBar(
                          items: const <BottomNavigationBarItem>[
                            BottomNavigationBarItem(
                              icon: Icon(Icons.home),
                              label: '',
                            ),
                            BottomNavigationBarItem(
                              icon: Icon(Icons.note),
                              label: '',
                            ),
                            BottomNavigationBarItem(
                              icon: Icon(Icons.add_circle),
                              label: '',
                            ),
                            BottomNavigationBarItem(
                              icon: Icon(Icons.person),
                              label: '',
                            ),
                          ],
                          currentIndex: viewModel.selectedIndex,
                          selectedItemColor: Colors.blueAccent,
                          unselectedItemColor: Colors.grey,
                          onTap: viewModel.onItemTapped,
                          type: BottomNavigationBarType.fixed,
                          backgroundColor: Colors.transparent,
                          elevation: 0,
                          showSelectedLabels: false,
                          showUnselectedLabels: false,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildPage(int selectedIndex) {
    switch (selectedIndex) {
      case 0:
        return const HomePage();
      case 1:
        return const MyStoriesPage();
      case 2:
        return const AddStoryPage();
      case 3:
        return const ProfilePage();
      default:
        return const HomePage();
    }
  }
}
