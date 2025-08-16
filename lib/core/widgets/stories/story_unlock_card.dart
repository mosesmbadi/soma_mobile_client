import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:soma/core/services/user_repository.dart';
import 'package:soma/core/services/offer_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

enum UnlockCardType { unlock, topUp }

class StoryUnlockCard extends StatefulWidget {
  final int neededTokens;
  final UnlockCardType cardType;
  final Function() onButtonPressed;
  final bool isLoading;

  const StoryUnlockCard({
    super.key,
    required this.neededTokens,
    required this.cardType,
    required this.onButtonPressed,
    this.isLoading = false,
  });

  @override
  _StoryUnlockCardState createState() => _StoryUnlockCardState();
}

class _StoryUnlockCardState extends State<StoryUnlockCard> {
  late final OfferRepository _offerRepository;
  List<Map<String, dynamic>> _offers = [];
  bool _isLoadingOffers = true;
  String? _error;
  
  // State variables for managing selected offer ID and button loading
  String? _selectedOfferId;
  bool _isTopUpLoading = false; 

  @override
  void initState() {
    super.initState();
    _offerRepository = OfferRepository(client: http.Client());
    _fetchOffers();
  }

  Future<void> _fetchOffers() async {
    try {
      final token = await SharedPreferences.getInstance().then(
        (prefs) => prefs.getString('jwt_token'),
      );
      if (token == null) {
        throw Exception('Authentication token not found.');
      }

      final offers = await _offerRepository.fetchActiveOffers(token);
      
      // Added for debugging: print the IDs to check for duplicates.
      // ignore: avoid_print
      print('Fetched offers IDs: ${offers.map((e) => e['_id']).toList()}');
      
      setState(() {
        _offers = offers;
        _isLoadingOffers = false;
        // Reset selected offer on new data load
        _selectedOfferId = null; 
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoadingOffers = false;
      });
    }
  }

  // This function now only handles selecting an offer's ID
  void _handleOfferSelection(String offerId) {
    setState(() {
      if (_selectedOfferId == offerId) {
        // Deselect if already selected
        _selectedOfferId = null;
      } else {
        _selectedOfferId = offerId;
      }
    });
  }

  // This function handles the button press and sends the request
  void _handleTopUpButtonPressed() async {
    // Find the full offer object from the ID
    final selectedOffer = _offers.firstWhere(
      (offer) => offer['_id'] == _selectedOfferId,
      orElse: () => {},
    );

    if (selectedOffer.isEmpty) {
      // Button should be disabled, but as a safeguard
      return;
    }
    
    setState(() {
      _isTopUpLoading = true;
    });

    try {
      final token = await SharedPreferences.getInstance().then(
        (prefs) => prefs.getString('jwt_token'),
      );
      if (token == null) {
        throw Exception('Authentication token not found.');
      }

      final payload = {
        'offerId': selectedOffer['_id'],
        'amount': selectedOffer['kshAmount'],
      };

      await _offerRepository.topUpAccount(token, payload);
      // Success message or refresh balance here
    } catch (e) {
      // Handle error (e.g., show a snackbar or dialog)
    } finally {
      setState(() {
        _isTopUpLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final UserRepository userRepository = Provider.of<UserRepository>(context);

    return FutureBuilder<Map<String, dynamic>>(
      future: userRepository.getCurrentUserDetails(),
      builder: (context, snapshot) {
        int currentBalance = 0;
        if (snapshot.connectionState == ConnectionState.done && snapshot.hasData) {
          currentBalance = (snapshot.data?['tokens'] as num?)?.toInt() ?? 0;
        } else if (snapshot.hasError) {
          // ignore: avoid_print
          print('Error fetching current user details: ${snapshot.error}');
        }

        if (widget.cardType == UnlockCardType.unlock) {
          if (currentBalance >= widget.neededTokens) {
            // Render StoryUnlockCard (enough tokens)
            return _buildUnlockCard(
              title: 'Unlock Story',
              description: "Unlock this premium story to continue reading.",
              buttonText: 'Unlock Now',
              icon: Icons.lock_open,
              currentBalance: currentBalance,
              neededTokens: widget.neededTokens,
              isTopUp: false,
            );
          } else {
            // Render Top-Up card (same UI as Unlock card) + dynamic offers
            return _buildUnlockCard(
              title: 'Top Up Account',
              description:
                  "You've reached your free reading limit. Top up your account to continue enjoying this amazing story.",
              buttonText: 'Top Up Now',
              icon: Icons.account_balance_wallet,
              currentBalance: currentBalance,
              neededTokens: widget.neededTokens,
              isTopUp: true,
              offers: _offers,
              isOffersLoading: _isLoadingOffers,
              offersError: _error,
            );
          }
        } else {
          // For UnlockCardType.topUp → same UI as Unlock card, with offers
          return _buildUnlockCard(
            title: 'Top Up Account',
            description:
                "Purchase tokens to unlock premium stories and enjoy uninterrupted reading.",
            buttonText: 'Top Up Now',
            icon: Icons.account_balance_wallet,
            currentBalance: currentBalance,
            neededTokens: widget.neededTokens,
            isTopUp: true,
            offers: _offers,
            isOffersLoading: _isLoadingOffers,
            offersError: _error,
          );
        }
      },
    );
  }

  Widget _buildUnlockCard({
    required String title,
    required String description,
    required String buttonText,
    required IconData icon,
    required int currentBalance,
    required int neededTokens,
    bool isTopUp = false,
    List<Map<String, dynamic>>? offers,
    bool isOffersLoading = false,
    String? offersError,
  }) {
    return ClipRRect(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      child: Container(
        color: Colors.white,
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Container(
              width: 40,
              height: 5,
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(3),
              ),
            ),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.purple.shade100,
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: Colors.white, size: 30),
            ),
            const SizedBox(height: 16),
            Text(
              title,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              description,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 14, color: Colors.black87),
            ),
            const SizedBox(height: 20),
            // Balance row is now ALWAYS visible to keep UI consistent
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: _buildTokenRow('Current Balance', currentBalance),
                  ),
                  Expanded(
                    child: _buildTokenRow('Needed to Unlock', neededTokens),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Top-up extras: show offers within the SAME card UI
            if (isTopUp) ...[
              if (offersError != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Text(
                    offersError,
                    style: const TextStyle(color: Colors.red),
                  ),
                )
              else if (isOffersLoading)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 12),
                  child: SizedBox(
                    height: 36,
                    child: Center(child: CircularProgressIndicator()),
                  ),
                )
              else if ((offers ?? []).isNotEmpty) ...[
                ...offers!.map((offer) => Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: _buildTokenOption(
                        // Pass the offer ID to the selection handler
                        offer['_id'].toString(), 
                        '${offer['tokenAmount']} Tokens',
                        'Ksh${offer['kshAmount']}',
                        highlight: (offer['name']?.toString().toLowerCase() ?? '')
                            .contains('best'),
                        // Check if the current offer's ID matches the selected ID
                        isSelected: _selectedOfferId == offer['_id'].toString(), 
                      ),
                    )).toList(),
                const SizedBox(height: 8),
              ]
              else ...[
                const Text(
                  'No offers available right now. Please try again later.',
                  style: TextStyle(color: Colors.grey),
                ),
                const SizedBox(height: 12),
              ],
            ],

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                // The onPressed now depends on which card type is shown
                onPressed: isTopUp
                    ? (_selectedOfferId != null ? _handleTopUpButtonPressed : null)
                    : (widget.isLoading ? null : widget.onButtonPressed),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  backgroundColor: const Color(0xFF333333),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: (isTopUp ? _isTopUpLoading : widget.isLoading)
                    ? const CircularProgressIndicator(color: Colors.white)
                    : Text(
                        buttonText,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
            ),
            const SizedBox(height: 12),
            if (!isTopUp && !widget.isLoading)
              const Text('Maybe Later', style: TextStyle(fontSize: 16)),
          ],
        ),
      ),
    );
  }

  static Widget _buildTokenRow(String label, int value) {
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
    String offerId,
    String title,
    String price, {
    bool highlight = false,
    required bool isSelected, // Parameter to check if selected
  }) {
    // Change border color based on selection
    final Color borderColor = isSelected
        ? const Color(0xFF333333) // Dark border for selected
        : highlight
            ? const Color(0xFF9FE2BF)
            : Colors.grey.shade300;

    return GestureDetector(
      onTap: () => _handleOfferSelection(offerId), // Now calls handler with the ID
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: borderColor, width: 1.5),
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: isSelected
                  ? const Color.fromRGBO(0, 0, 0, 0.1) // Stronger shadow for selected
                  : const Color.fromRGBO(0, 0, 0, 0.05),
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
            Row(
              children: [
                Text(
                  price,
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                if (isSelected)
                  const Padding(
                    padding: EdgeInsets.only(left: 8),
                    child: Icon(
                      Icons.check_circle,
                      color: Color(0xFF333333),
                      size: 20,
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}