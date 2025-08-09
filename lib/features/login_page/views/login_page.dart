import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:soma/features/login_page/viewmodels/login_page_viewmodel.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => LoginPageViewModel(),
      child: Consumer<LoginPageViewModel>(
        builder: (context, viewModel, child) {
          return Scaffold(
            backgroundColor: const Color.fromARGB(255, 232, 246, 255), //  for the whole page
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

                          // Welcome Back Text
                          const Text(
                            'Welcome Back 👋',
                            style: TextStyle(
                              fontSize: 28.0, // Slightly smaller font size
                              fontWeight: FontWeight.bold,
                              color: Colors
                                  .black87, // Darker text for better contrast
                            ),
                          ),
                          const SizedBox(height: 6.0),
                          const Text(
                            'Sign in to continue to your account', // Corrected text
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 16.0,
                              color: Colors.grey,
                            ),
                          ),
                          const SizedBox(height: 20.0),

                          // Actual Login Form
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
                              // borderRadius: BorderRadius.only(
                              //   topLeft: Radius.circular(24),
                              //   topRight: Radius.circular(24),
                              // ),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
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

                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Row(
                                      children: [
                                        SizedBox(
                                          width: 24,
                                          height: 24,
                                          child: Checkbox(
                                            value: viewModel.rememberMe,
                                            onChanged: (bool? value) {
                                              viewModel.toggleRememberMe(value);
                                            },
                                            activeColor: const Color(
                                              0xD1E4FFFF,
                                            ),
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(4.0),
                                            ),
                                          ),
                                        ),
                                        const Text(
                                          'Remember me',
                                          style: TextStyle(
                                            fontSize: 14.0,
                                            color: Colors.black87,
                                          ),
                                        ),
                                      ],
                                    ),
                                    TextButton(
                                      onPressed: () {
                                        // TODO: Implement
                                        // Handle forgot password
                                      },
                                      child: const Text(
                                        'Forgot Password?',
                                        style: TextStyle(
                                          fontSize: 14.0,
                                          color: Color.fromARGB(
                                            209,
                                            58,
                                            58,
                                            58,
                                          ),
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),

                                const SizedBox(height: 10.0),

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

                                // Sign In Button
                                SizedBox(
                                  width: double.infinity,
                                  height: 50,
                                  child: ElevatedButton(
                                    onPressed: () => viewModel.login(context),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: const Color(0xD1E4FFFF),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(
                                          12.0,
                                        ),
                                      ),
                                    ),
                                    child: const Text(
                                      'Sign In',
                                      style: TextStyle(
                                        fontSize: 18,
                                        color: Color.fromARGB(255, 39, 39, 39),
                                        fontWeight: FontWeight.bold,
                                      ),
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
                                      // The image does not show internal padding that pushes text far from icon
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
                                          ), // Adjusted font weight
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 20.0),

                                // Don't have an account? Sign Up
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      "Don't have an account?",
                                      style: TextStyle(
                                        fontSize: 15,
                                        color: Colors.grey[700],
                                      ),
                                    ),
                                    TextButton(
                                      onPressed: () {
                                        Navigator.pushNamed(
                                          context,
                                          '/register',
                                        );
                                      },
                                      child: const Text(
                                        'Sign Up',
                                        style: TextStyle(
                                          fontSize: 15,
                                          color: Color.fromARGB(51, 27, 27, 27),
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
                  // Privacy Policy Footer - This part should always be at the bottom
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
                        text: 'By signing in, you agree to our ',
                        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                        children: <TextSpan>[
                          TextSpan(
                            text: 'Terms of Service',
                            style: const TextStyle(
                              color: Color.fromARGB(209, 0, 0, 0),
                              fontWeight: FontWeight.bold,
                            ),
                            // Recognizer for tap if you want to make it clickable
                            // recognizer: TapGestureRecognizer()..onTap = () {
                            //   // Handle tap on Terms of Service
                            // },
                          ),
                          const TextSpan(text: ' and '),
                          TextSpan(
                            text: 'Privacy Policy',
                            style: const TextStyle(
                              color: Color.fromARGB(209, 0, 0, 0),
                              fontWeight: FontWeight.bold,
                            ),
                            // recognizer: TapGestureRecognizer()..onTap = () {
                            //   // Handle tap on Privacy Policy
                            // },
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
