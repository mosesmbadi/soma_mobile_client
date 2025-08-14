import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:soma/core/config/environment.dart';

class OfferRepository {
  final http.Client client;

  OfferRepository({required this.client});

  Future<List<Map<String, dynamic>>> fetchActiveOffers(String token) async {
    final response = await client.get(
      Uri.parse('${Environment.backendUrl}/api/offers/active'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data['success'] == true) {
        return List<Map<String, dynamic>>.from(data['data']);
      } else {
        throw Exception('Failed to fetch offers.');
      }
    } else {
      throw Exception('Failed to fetch offers.');
    }
  }
}
