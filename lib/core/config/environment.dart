// Global configurations

class Environment {
  static const String backendUrl = String.fromEnvironment(
    'BACKEND_URL',
    defaultValue: 'http://192.168.100.46:3000', // Default for development
  );
  static const String googleSignInApiUrl = '$backendUrl/api/auth/google'; // Google Sign-In endpoint
}