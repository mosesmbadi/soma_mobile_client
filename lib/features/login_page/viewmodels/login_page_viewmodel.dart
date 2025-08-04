import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../../../core/config/environment.dart'; // Corrected import path

const String apiUrl = '${Environment.backendUrl}/api/auth/login'; // Moved to top-level

class LoginPageViewModel extends ChangeNotifier {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  String _errorMessage = '';
  bool _isPasswordVisible = false;

  final GoogleSignIn _googleSignIn = GoogleSignIn();

  TextEditingController get emailController => _emailController;
  TextEditingController get passwordController => _passwordController;
  String get errorMessage => _errorMessage;
  bool get isPasswordVisible => _isPasswordVisible;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void togglePasswordVisibility() {
    _isPasswordVisible = !_isPasswordVisible;
    notifyListeners();
  }

  Future<void> login(BuildContext context) async {
    _errorMessage = ''; // Clear previous errors
    notifyListeners();

    final String email = _emailController.text.trim();
    final String password = _passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      _errorMessage = 'Please enter both email and password.';
      notifyListeners();
      return;
    }

    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(<String, String>{
          'email': email,
          'password': password,
        }),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = jsonDecode(response.body);
        final String token = responseData['token'];
        await SharedPreferences.getInstance().then((prefs) {
          prefs.setString('jwt_token', token);
        });
        

        if (context.mounted) {
          Navigator.pushReplacementNamed(context, '/home');
        }
      } else {
        final Map<String, dynamic> errorData = jsonDecode(response.body);
        _errorMessage =
            errorData['message'] ?? 'Login failed. Please try again.';
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
        
      }
    } catch (error) {
      
      _errorMessage = 'Google Sign-In failed. Please try again.';
      notifyListeners();
    }
  }
}
