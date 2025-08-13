import 'package:http/http.dart' as http;
import 'dart:convert';
import '../core/config/environment.dart';

class OfferRepository {
  final http.Client _client;
  final String _offersApiUrl = '${Environment.backendUrl}/api/offers/active';

  OfferRepository({http.Client? client}) : _client = client ?? http.Client();

  Future<List<Map<String, dynamic>>> fetchOffers(String token) async {
    try {
      final response = await _client.get(
        Uri.parse(_offersApiUrl),
        headers: <String, String>{
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json; charset=UTF-8',
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = jsonDecode(response.body);
        if (responseData['success'] == true && responseData['data'] != null) {
          // Assuming 'data' can be a List or a single Map
          if (responseData['data'] is List) {
            return (responseData['data'] as List)
                .cast<Map<String, dynamic>>();
          } else if (responseData['data'] is Map<String, dynamic>) {
            return [responseData['data'] as Map<String, dynamic>]; // Wrap single offer in a list
          }
        }
        return []; // Return empty list if no data or success is false
      } else {
        throw Exception('Failed to load offers: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('An error occurred while fetching offers: $e');
    }
  }
}