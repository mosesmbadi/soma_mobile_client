import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:soma/core/widgets/nav_warning_card.dart';
import 'package:soma/core/widgets/show_toast.dart';
import 'package:soma/data/user_repository.dart';
import 'package:soma/core/exceptions/auth_exception.dart';
import 'package:soma/features/home_page/viewmodels/home_page_viewmodel.dart';

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

                Positioned(
                  bottom: 16,
                  left: 16,
                  right: 16,
                  child: NavWarningCard(
                    selectedIndex: viewModel.selectedIndex,
                    onItemTapped: (index) async {
                      if (index == 2) {
                        try {
                          final userDetails = await _userRepository.getCurrentUserDetails();
                          final userRole = userDetails['role'];

                          if (userRole == 'reader') {
                            _showAccessDeniedDialog(context);
                          } else {
                            Navigator.pushNamed(context, '/add_story');
                          }
                        } on AuthException catch (e) {
                          print('AuthException: $e');
                          await _prefs.remove('jwt_token');
                          Navigator.pushReplacementNamed(context, '/login');
                        } catch (e) {
                          print('An error occurred: $e');
                        }
                      } else {
                        viewModel.onItemTapped(index);
                      }
                    },
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
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Row(
            children: [
              Text('❗ ', style: TextStyle(fontSize: 20)),
              Text(
                'Access Denied',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          content: const Text(
            'Only writers can add stories.\nPlease request writer access.',
            style: TextStyle(fontSize: 16),
          ),
          actionsPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          actions: <Widget>[
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF333333),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
              onPressed: () async {
                Navigator.pop(context);
                final result = await _userRepository.requestWriterAccess(
                    _prefs.getString('jwt_token') ?? '');
                final bool success = result['success'] as bool;
                final String message = result['message'] as String;
                if (success) {
                  showToast(context, message, type: ToastType.success);
                } else {
                  showToast(context, message, type: ToastType.error);
                }
              },
              child: const Text(
                'Request Writer Access',
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
            ),
            TextButton(
              child: const Text(
                'Cancel',
                style: TextStyle(fontWeight: FontWeight.w500),
              ),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
          ],
        );
      },
    );
  }
}
