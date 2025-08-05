// Global configurations

class Environment {
  static const String backendUrl = String.fromEnvironment(
    'BACKEND_URL',
    defaultValue: 'http://172.16.57.173:3000', // Default for development
  );
  static const String googleSignInApiUrl = '$backendUrl/api/auth/google'; // Google Sign-In endpoint
}