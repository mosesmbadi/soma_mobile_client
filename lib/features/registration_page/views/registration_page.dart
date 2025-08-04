import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:soma/features/registration_page/viewmodels/registration_page_viewmodel.dart';

class RegistrationPage extends StatelessWidget {
  const RegistrationPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => RegistrationPageViewModel(),
      child: Consumer<RegistrationPageViewModel>(
        builder: (context, viewModel, child) {
          return Scaffold(
            backgroundColor: const Color.fromARGB(
              255,
              200,
              233,
              255,
            ), //  for the whole page
            body: SafeArea(
              child: Column(
                children: [
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(horizontal: 24.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment
                            .center, // Center for the icon and welcome text
                        children: <Widget>[
                          const SizedBox(height: 40.0,), // Increased space from top
                          // Lightning Bolt Icon
                          Container(
                            width: 60,
                            height: 60,
                            decoration: BoxDecoration(
                              color: const Color.fromARGB(
                                159,
                                94,
                                94,
                                94,
                              ),
                              borderRadius: BorderRadius.circular(
                                20.0,
                              ), // Rounded corners
                            ),
                            child: const Icon(
                              Icons.flash_on, // Lightning bolt icon
                              color: Colors.white,
                              size: 30.0,
                            ),
                          ),
                          const SizedBox(height: 10.0),

                          // Welcome Text
                          const Text(
                            'Create Account 👋',
                            style: TextStyle(
                              fontSize: 28.0, // Slightly smaller font size
                              fontWeight: FontWeight.bold,
                              color: Colors
                                  .black87, // Darker text for better contrast
                            ),
                          ),
                          const SizedBox(height: 6.0),
                          const Text(
                            'Sign up to get started', // Corrected text
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 16.0,
                              color: Colors.grey,
                            ),
                          ),
                          const SizedBox(height: 20.0),
                          // Placeholder for the rest of the content (form, buttons, footer)
                          // This will be filled in subsequent steps
                          const SizedBox(height: 20.0),

                          // Actual Registration Form
                          Container(
                            width: MediaQuery.of(context).size.width,
                            padding: const EdgeInsets.all(
                              16.0,
                            ), // Padding inside the container
                            decoration: const BoxDecoration(
                              color: Color.fromARGB(255, 255, 255, 255),
                              borderRadius: BorderRadius.all(
                                Radius.circular(
                                  24.0,
                                )),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Name Input Field
                                Align(
                                  alignment: Alignment.centerLeft,
                                  child: Text(
                                    'Name',
                                    style: TextStyle(
                                      fontSize: 16.0,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.grey[700],
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 8.0),
                                Container(
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(12.0),
                                    boxShadow: [
                                      BoxShadow(
                                        color: const Color.fromRGBO(
                                          128,
                                          128,
                                          128,
                                          0.1,
                                        ),
                                        spreadRadius: 1,
                                        blurRadius: 5,
                                        offset: const Offset(0, 3),
                                      ),
                                    ],
                                  ),
                                  child: TextField(
                                    controller: viewModel.nameController,
                                    decoration: const InputDecoration(
                                      hintText: 'Enter your name',
                                      hintStyle: TextStyle(color: Colors.grey),
                                      border: InputBorder.none,
                                      contentPadding: EdgeInsets.symmetric(
                                        horizontal: 16.0,
                                        vertical: 14.0,
                                      ),
                                    ),
                                    keyboardType: TextInputType.text,
                                  ),
                                ),
                                const SizedBox(height: 20.0),

                                // Email Label
                                Text(
                                  'Email Address',
                                  style: TextStyle(
                                    fontSize: 16.0,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.grey[700],
                                  ),
                                ),
                                const SizedBox(height: 8.0),

                                // Email Input Field
                                Container(
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(12.0),
                                    boxShadow: [
                                      BoxShadow(
                                        color: const Color.fromRGBO(
                                          128,
                                          128,
                                          128,
                                          0.1,
                                        ),
                                        spreadRadius: 1,
                                        blurRadius: 5,
                                        offset: const Offset(0, 3),
                                      ),
                                    ],
                                  ),
                                  child: TextField(
                                    controller: viewModel.emailController,
                                    decoration: const InputDecoration(
                                      hintText: 'Enter your email',
                                      hintStyle: TextStyle(color: Colors.grey),
                                      border: InputBorder.none,
                                      contentPadding: EdgeInsets.symmetric(
                                        horizontal: 16.0,
                                        vertical: 14.0,
                                      ),
                                    ),
                                    keyboardType: TextInputType.emailAddress,
                                  ),
                                ),
                                const SizedBox(height: 20.0),

                                // Password Input Field
                                Align(
                                  alignment: Alignment.centerLeft,
                                  child: Text(
                                    'Password',
                                    style: TextStyle(
                                      fontSize: 16.0,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.grey[700],
                                    ),
                                  ),
                                ),

                                const SizedBox(height: 8.0),
                                Container(
                                  decoration: BoxDecoration(
                                    color: Colors
                                        .white, // White background for the input field
                                    borderRadius: BorderRadius.circular(12.0),
                                    boxShadow: [
                                      BoxShadow(
                                        color: const Color.fromRGBO(
                                          128,
                                          128,
                                          128,
                                          0.1,
                                        ),
                                        spreadRadius: 1,
                                        blurRadius: 5,
                                        offset: const Offset(0, 3),
                                      ),
                                    ],
                                  ),
                                  child: TextField(
                                    controller: viewModel.passwordController,
                                    decoration: InputDecoration(
                                      hintText: 'Enter your password',
                                      hintStyle: const TextStyle(
                                        color: Colors.grey,
                                      ),
                                      border: InputBorder
                                          .none, // Remove default border
                                      contentPadding:
                                          const EdgeInsets.symmetric(
                                            horizontal: 16.0,
                                            vertical: 14.0,
                                          ), // Adjust padding
                                      suffixIcon: IconButton(
                                        icon: Icon(
                                          viewModel.isPasswordVisible
                                              ? Icons.visibility
                                              : Icons.visibility_off,
                                          color: Colors
                                              .grey, // Grey color for suffix icon
                                        ),
                                        onPressed:
                                            viewModel.togglePasswordVisibility,
                                      ),
                                    ),
                                    obscureText: !viewModel.isPasswordVisible,
                                  ),
                                ),
                                const SizedBox(height: 20.0),

                                // Confirm Password Input Field
                                Align(
                                  alignment: Alignment.centerLeft,
                                  child: Text(
                                    'Confirm Password',
                                    style: TextStyle(
                                      fontSize: 16.0,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.grey[700],
                                    ),
                                  ),
                                ),

                                const SizedBox(height: 8.0),
                                Container(
                                  decoration: BoxDecoration(
                                    color: Colors
                                        .white, // White background for the input field
                                    borderRadius: BorderRadius.circular(12.0),
                                    boxShadow: [
                                      BoxShadow(
                                        color: const Color.fromRGBO(
                                          128,
                                          128,
                                          128,
                                          0.1,
                                        ),
                                        spreadRadius: 1,
                                        blurRadius: 5,
                                        offset: const Offset(0, 3),
                                      ),
                                    ],
                                  ),
                                  child: TextField(
                                    controller: viewModel.confirmPasswordController,
                                    decoration: InputDecoration(
                                      hintText: 'Confirm your password',
                                      hintStyle: const TextStyle(
                                        color: Colors.grey,
                                      ),
                                      border: InputBorder
                                          .none, // Remove default border
                                      contentPadding:
                                          const EdgeInsets.symmetric(
                                            horizontal: 16.0,
                                            vertical: 14.0,
                                          ), // Adjust padding
                                      suffixIcon: IconButton(
                                        icon: Icon(
                                          viewModel.isConfirmPasswordVisible
                                              ? Icons.visibility
                                              : Icons.visibility_off,
                                          color: Colors
                                              .grey, // Grey color for suffix icon
                                        ),
                                        onPressed:
                                            viewModel.toggleConfirmPasswordVisibility,
                                      ),
                                    ),
                                    obscureText: !viewModel.isConfirmPasswordVisible,
                                  ),
                                ),
                                const SizedBox(height: 20.0),

                                if (viewModel.errorMessage.isNotEmpty)
                                  Padding(
                                    padding: const EdgeInsets.only(
                                      bottom: 20.0,
                                    ),
                                    child: Text(
                                      viewModel.errorMessage,
                                      style: const TextStyle(
                                        color: Colors.red,
                                        fontSize: 14.0,
                                      ),
                                    ),
                                  ),

                                // Register Button
                                SizedBox(
                                  width: double.infinity,
                                  height: 50,
                                  child: ElevatedButton(
                                    onPressed: () => viewModel.register(context),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: const Color(0xFF4C00A4), // Purple
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(
                                          12.0,
                                        ),
                                      ),
                                      elevation: 5, // Add a subtle shadow
                                    ),
                                    child: const Text(
                                      'Register',
                                      style: TextStyle(
                                          fontSize: 18, color: Colors.white, fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 20.0),

                                // Or continue with separator
                                Row(
                                  children: [
                                    Expanded(
                                      child: Divider(
                                        color: Colors.grey[300],
                                        thickness: 1,
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 10.0,
                                      ),
                                      child: Text(
                                        'Or continue with',
                                        style: TextStyle(
                                          color: Colors.grey[600],
                                          fontSize: 14,
                                        ),
                                      ),
                                    ),
                                    Expanded(
                                      child: Divider(
                                        color: Colors.grey[300],
                                        thickness: 1,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 20.0),

                                // Continue with Google Button
                                SizedBox(
                                  width: double.infinity,
                                  height: 50,
                                  child: OutlinedButton(
                                    onPressed: () =>
                                        viewModel.handleGoogleSignIn(context),
                                    style: OutlinedButton.styleFrom(
                                      backgroundColor:
                                          Colors.white, // White background
                                      side: BorderSide(
                                        color: Colors.grey[300]!,
                                      ), // Light grey border
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(
                                          12.0,
                                        ),
                                      ),
                                      elevation: 3, // Subtle shadow
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 12.0,
                                      ),
                                    ),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Image.asset(
                                          'assets/images/google_logo.png',
                                          height: 24.0,
                                        ),
                                        const SizedBox(width: 10.0),
                                        const Text(
                                          'Continue with Google',
                                          style: TextStyle(
                                            fontSize: 16,
                                            color: Colors.black87,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 20.0),

                                // Already have an account? Sign In
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      "Already have an account?",
                                      style: TextStyle(
                                        fontSize: 15,
                                        color: Colors.grey[700],
                                      ),
                                    ),
                                    TextButton(
                                      onPressed: () {
                                        Navigator.pushNamed(
                                          context,
                                          '/login',
                                        );
                                      },
                                      child: const Text(
                                        'Sign In',
                                        style: TextStyle(
                                          fontSize: 15,
                                          color: Color(0xFF4C00A4),
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 10.0),

                          const SizedBox(
                            height: 20.0,
                          ), // Space before the bottom card
                        ],
                      ),
                    ),
                  ),
                  // Placeholder for Privacy Policy Footer
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24.0,
                      vertical: 15.0,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(20.0),
                      ), // Rounded top corners
                      boxShadow: [
                        BoxShadow(
                          color: const Color.fromRGBO(128, 128, 128, 0.1),
                          spreadRadius: 1,
                          blurRadius: 10,
                          offset: const Offset(0, -5), // Shadow at the top
                        ),
                      ],
                    ),
                    child: RichText(
                      textAlign: TextAlign.center,
                      text: TextSpan(
                        text: 'By signing up, you agree to our ',
                        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                        children: <TextSpan>[
                          TextSpan(
                            text: 'Terms of Service',
                            style: const TextStyle(
                              color: Color.fromARGB(209, 0, 0, 0),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const TextSpan(text: ' and '),
                          TextSpan(
                            text: 'Privacy Policy',
                            style: const TextStyle(
                              color: Color.fromARGB(209, 0, 0, 0),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
