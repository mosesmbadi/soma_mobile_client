import 'dart:convert';
import 'package:http/http.dart' as http;

class OfferService {
  final String baseUrl;
  final String authToken;

  OfferService({required this.baseUrl, required this.authToken});

  Future<Map<String, dynamic>> fetchActiveOffer() async {
    final url = Uri.parse('$baseUrl/api/offers/active');

    try {
      final response = await http.get(
        url,
        headers: {
          'Authorization': 'Bearer $authToken',
          'User-Agent': 'soma-app',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true && data['data'] != null) {
          return data['data'];
        } else {
          throw Exception('No active offers found.');
        }
      } else {
        throw Exception('Failed to fetch offers.');
      }
    } catch (e) {
      throw Exception('Error fetching offers: $e');
    }
  }
}
