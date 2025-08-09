import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:soma/features/home_page/viewmodels/home_page_viewmodel.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:soma/data/user_repository.dart';

import 'package:soma/features/my_stories_page/views/my_stories_page.dart';
import 'package:soma/features/add_story_page/views/add_story_page.dart';
import 'package:soma/features/profile_page/views/profile_page.dart';
import 'package:soma/features/home_page/views/home_page.dart';

class BottomNavShell extends StatefulWidget {
  const BottomNavShell({super.key});

  @override
  State<BottomNavShell> createState() => _BottomNavShellState();
}

class _BottomNavShellState extends State<BottomNavShell> {
  late SharedPreferences _prefs;
  late UserRepository _userRepository;

  @override
  void initState() {
    super.initState();
    _initDependencies();
  }

  Future<void> _initDependencies() async {
    _prefs = await SharedPreferences.getInstance();
    _userRepository = UserRepository(prefs: _prefs);
  }

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
                          onTap: (index) async {
                            if (index == 2) {
                              // Check user role before navigating to AddStoryPage
                              final userDetails = await _userRepository.getCurrentUserDetails();
                              final userRole = userDetails['role'];

                              if (userRole == 'reader') {
                                _showAccessDeniedDialog(context);
                              } else {
                                Navigator.pushNamed(context, '/add_story');
                              }
                            } else {
                              viewModel.onItemTapped(index);
                            }
                          },
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
      case 3:
        return const ProfilePage();
      default:
        return const HomePage();
    }
  }

  void _showAccessDeniedDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Access Denied'),
          content: const Text(
              'Only writers can add stories. Please request writer access.'),
          actions: <Widget>[
            TextButton(
              child: const Text('Request Writer Access'),
              onPressed: () async {
                Navigator.pop(context); // Close dialog
                // Or directly call the request writer access method if available globally
                final success = await _userRepository.requestWriterAccess(
                    _prefs.getString('jwt_token') ?? '');
                final message = success
                    ? 'Request sent successfully!'
                    : 'Failed to send request.';
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(message)),
                );
              },
            ),
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.pop(context); // Close dialog
              },
            ),
          ],
        );
      },
    );
  }
}