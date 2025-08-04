import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:google_sign_in/google_sign_in.dart';
import '../../../core/config/environment.dart';

class RegistrationPageViewModel extends ChangeNotifier {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  String _errorMessage = '';
  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;

  final GoogleSignIn _googleSignIn = GoogleSignIn();

  TextEditingController get nameController => _nameController;
  TextEditingController get emailController => _emailController;
  TextEditingController get passwordController => _passwordController;
  TextEditingController get confirmPasswordController =>
      _confirmPasswordController;
  String get errorMessage => _errorMessage;
  bool get isPasswordVisible => _isPasswordVisible;
  bool get isConfirmPasswordVisible => _isConfirmPasswordVisible;

  void togglePasswordVisibility() {
    _isPasswordVisible = !_isPasswordVisible;
    notifyListeners();
  }

  void toggleConfirmPasswordVisibility() {
    _isConfirmPasswordVisible = !_isConfirmPasswordVisible;
    notifyListeners();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> register(BuildContext context) async {
    _errorMessage = ''; // Clear previous errors
    notifyListeners();

    final String name = _nameController.text.trim();
    final String email = _emailController.text.trim();
    final String password = _passwordController.text.trim();
    final String confirmPassword = _confirmPasswordController.text.trim();

    if (name.isEmpty || email.isEmpty || password.isEmpty || confirmPassword.isEmpty) {
      _errorMessage = 'Please fill in all fields.';
      notifyListeners();
      return;
    }

    if (password != confirmPassword) {
      _errorMessage = 'Passwords do not match.';
      notifyListeners();
      return;
    }

    const String apiUrl = '${Environment.backendUrl}/api/auth/register';

    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(<String, String>{
          'name': name,
          'email': email,
          'password': password,
          'role': 'reader',
        }),
      );

      if (response.statusCode == 201) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Registration successful! Please log in.'),
            ),
          );
          Navigator.pop(context);
        }
      } else {
        final Map<String, dynamic> errorData = jsonDecode(response.body);
        _errorMessage =
            errorData['message'] ?? 'Registration failed. Please try again.';
      }
    } catch (e) {
      _errorMessage = 'An error occurred: $e';
    } finally {
      notifyListeners();
    }
  }

  Future<void> handleGoogleSignIn(BuildContext context) async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser != null) {
        // TODO: Send googleUser.idToken to your backend for verification and authentication
        // Your backend should then return its own JWT token.
        // For now, just navigate to home page as a placeholder
        if (context.mounted) {
          Navigator.pushReplacementNamed(context, '/home');
        }
      } else {
        // User cancelled the sign-in
      }
    } catch (error) {
      _errorMessage = 'Google Sign-In failed. Please try again.';
      notifyListeners();
    }
  }
}
