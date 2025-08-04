import 'package:flutter/material.dart';

import 'package:provider/provider.dart';
import 'package:soma/features/landing_page/viewmodels/landing_page_viewmodel.dart';

class LandingPage extends StatelessWidget {
  const LandingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => LandingPageViewModel(),
      child: Consumer<LandingPageViewModel>(
        builder: (context, viewModel, child) {
          return Scaffold(
            body: Stack(
              children: [
                // Background Image
                Positioned.fill(
                  child: Image.asset(
                    'assets/images/landing_page_hero1.jpg',
                    fit: BoxFit.cover,
                  ),
                ),
                // Overlay
                Positioned.fill(
                  child: Container(
                    color: const Color.fromARGB(51, 0, 0, 0),
                  ),
                ),
                Align(
                  alignment: Alignment.bottomCenter,
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,

                      children: [
                        Image.asset(
                          'assets/images/soma_logo.png',
                          width: 60, // Slightly smaller to make space for text
                          height: 60,
                        ),
                        const SizedBox(height: 20),
                        const Text(
                          "SOMA",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 25,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 10),
                        const Text(
                          "Created for Readers, by readers.",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontFamily: 'PlaywriteQLD',
                            color: Colors.grey,
                            fontSize: 20,
                          ),
                        ),

                        const SizedBox(height: 10),
                        const Text(
                          "Write your world, share your story—earn as your readers turn every page. We make it that simple!",
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.white, fontSize: 16),
                        ),
                        const SizedBox(height: 50),
                        SizedBox(
                          width: double
                              .infinity, // Full width of the parent (with padding)
                          child: ElevatedButton(
                            onPressed: () => viewModel.navigateToLogin(context),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xD1E4FFFF),
                              padding: const EdgeInsets.symmetric(vertical: 15),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            child: const Text(
                              'Get Started',
                              style: TextStyle(
                                fontSize: 18,
                                color: Color.fromARGB(255, 107, 107, 107),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 15),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: () =>
                                viewModel.navigateToGuestStories(context),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF333333),
                              padding: const EdgeInsets.symmetric(vertical: 15),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            child: const Text(
                              'View Guest Stories',
                              style: TextStyle(
                                fontSize: 18,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ],
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
}
