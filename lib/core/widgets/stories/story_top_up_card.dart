import 'package:flutter/material.dart';
import 'package:soma/data/user_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:soma/data/offer_repository.dart'; // Import the new repository

class StoryUnlockCard extends StatefulWidget {
  final int neededTokens;

  const StoryUnlockCard({super.key, this.neededTokens = 1});

  @override
  State<StoryUnlockCard> createState() => _StoryUnlockCardState();
}

class _StoryUnlockCardState extends State<StoryUnlockCard> {
  late final UserRepository _userRepository;
  late final SharedPreferences _prefs;
  late final http.Client _httpClient;
  late final OfferRepository _offerRepository; // Add OfferRepository
  List<Map<String, dynamic>> _offers = []; // List to hold fetched offers
  bool _isLoadingOffers = true; // Loading state for offers
  String _offersErrorMessage = ''; // Error message for offers

  @override
  void initState() {
    super.initState();
    _httpClient = http.Client();
    _initializeDependencies();
  }

  Future<void> _initializeDependencies() async {
    _prefs = await SharedPreferences.getInstance();
    _userRepository = UserRepository(prefs: _prefs, client: _httpClient);
    _offerRepository = OfferRepository(client: _httpClient); // Initialize OfferRepository
    await _fetchOffers(); // Fetch offers
    setState(() {}); // Rebuild to use the initialized repository and fetched offers
  }

  Future<void> _fetchOffers() async {
    _isLoadingOffers = true;
    _offersErrorMessage = '';
    try {
      final String? token = _prefs.getString('jwt_token');
      if (token == null) {
        _offersErrorMessage = 'Authentication token not found. Cannot fetch offers.';
        return;
      }
      _offers = await _offerRepository.fetchOffers(token);
    } catch (e) {
      _offersErrorMessage = 'Failed to load offers: $e';
    } finally {
      _isLoadingOffers = false;
      if (mounted) {
        setState(() {});
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, dynamic>>(
      future: _userRepository.getCurrentUserDetails(),
      builder: (context, snapshot) {
        int currentBalance = 0;
        if (snapshot.connectionState == ConnectionState.done &&
            snapshot.hasData) {
          currentBalance = snapshot.data?['tokens'] ?? 0;
        } else if (snapshot.hasError) {
          // Handle error, maybe log it or show a default value
        }

        return ClipRRect(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          child: Container(
            color: Colors.white,
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                // Top notch
                Container(
                  width: 40,
                  height: 5,
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
                // Icon circle
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.purple.shade100,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.monetization_on,
                    color: Colors.white,
                    size: 30,
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Continue Reading',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                const Text(
                  "You've reached your free reading limit. Top up your account to continue enjoying this amazing story.",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 14, color: Colors.black87),
                ),
                const SizedBox(height: 20),
                // Balance info
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildTokenRow('Current Balance', currentBalance),
                      _buildTokenRow('Needed to Continue', widget.neededTokens),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                // Token packages
                if (_isLoadingOffers) ...[
                  const Center(child: CircularProgressIndicator()),
                ] else if (_offersErrorMessage.isNotEmpty) ...[
                  Center(child: Text(_offersErrorMessage, style: const TextStyle(color: Colors.red))),
                ] else if (_offers.isEmpty) ...[
                  const Center(child: Text('No offers available.')),
                ] else ...[
                  Column(
                    children: _offers.map((offer) {
                      final String name = offer['name'] ?? 'Unknown Offer';
                      final double kshAmount = (offer['kshAmount'] as num?)?.toDouble() ?? 0.0;
                      final int tokenAmount = (offer['tokenAmount'] as num?)?.toInt() ?? 0;
                      final bool isActive = offer['isActive'] ?? false; // Assuming 'isActive' field

                      if (!isActive) return const SizedBox.shrink(); // Only show active offers

                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12.0),
                        child: _buildTokenOption(
                          '$tokenAmount Tokens',
                          'Ksh${kshAmount.toStringAsFixed(2)}',
                          highlight: _offers.indexOf(offer) == 0, // Highlight the first offer
                        ),
                      );
                    }).toList(),
                  ),
                ],
                const SizedBox(height: 20),
                // Top Up button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      // TODO: Handle top up
                    },
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      backgroundColor: const Color(0xFF333333),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text(
                      'Top Up Now',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                // Maybe Later button
                Text('Maybe Later', style: TextStyle(fontSize: 16)),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildTokenRow(String label, int value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 14, color: Colors.grey)),
        const SizedBox(height: 4),
        Row(
          children: [
            const Icon(Icons.monetization_on, size: 16, color: Colors.amber),
            const SizedBox(width: 4),
            Text(
              '$value',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildTokenOption(
    String title,
    String price, {
    bool highlight = false,
  }) {
    final Color borderColor = highlight
        ? const Color(0xFF9FE2BF)
        : Colors.grey.shade300;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: borderColor, width: 1.5),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: const Color.fromRGBO(0, 0, 0, 0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              const Icon(Icons.monetization_on, color: Colors.amber),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              if (highlight)
                const Padding(
                  padding: EdgeInsets.only(left: 8),
                  child: Text(
                    'Best Value',
                    style: TextStyle(
                      color: Colors.orange,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
            ],
          ),
          Text(
            price,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}
