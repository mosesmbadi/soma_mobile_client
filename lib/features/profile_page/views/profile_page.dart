import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:soma/features/profile_page/viewmodels/profile_page_viewmodel.dart';
import 'package:soma/features/profile_page/views/profile_update_page.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  late SharedPreferences _prefs;
  late ProfilePageViewModel _viewModel;
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  Future<void> _initializeData() async {
    _prefs = await SharedPreferences.getInstance();
    _viewModel = ProfilePageViewModel(prefs: _prefs);
    setState(() {
      _isInitialized = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (!_isInitialized) {
      return const Center(child: CircularProgressIndicator());
    }

    return ChangeNotifierProvider<ProfilePageViewModel>.value(
      value: _viewModel,
      child: Consumer<ProfilePageViewModel>(
        builder: (context, viewModel, child) {
          const double backgroundHeight = 250;
          const double profileImageRadius = 60;

          return Scaffold(
            body: viewModel.errorMessage.isNotEmpty
                ? Center(
                    child: Text(
                      viewModel.errorMessage,
                      style: const TextStyle(color: Colors.red),
                    ),
                  )
                : viewModel.userData == null
                ? const Center(child: CircularProgressIndicator())
                : SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: <Widget>[
                        // Header Section
                        Stack(
                          clipBehavior: Clip.none,
                          children: [
                            // Background Image
                            Container(
                              height: backgroundHeight,
                              decoration: const BoxDecoration(
                                color: Color(0xD1E4FFFF),
                                borderRadius: BorderRadius.vertical(
                                  bottom: Radius.circular(10),
                                ),
                              ),
                              child: ClipRRect(
                                borderRadius: const BorderRadius.vertical(
                                  bottom: Radius.circular(10),
                                ),
                                child: Image.asset(
                                  'assets/images/default_thumbnail.jpg',
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) =>
                                      Center(
                                        child: Icon(
                                          Icons.image_not_supported,
                                          color: Colors.white,
                                          size: 50,
                                        ),
                                      ),
                                ),
                              ),
                            ),
                            // Gear Icon for Profile Update
                            Positioned(
                              top: 10,
                              right: 10,
                              child: IconButton(
                                icon: const Icon(Icons.settings, color: Colors.white, size: 30),
                                onPressed: () {
                                  showModalBottomSheet(
                                    context: context,
                                    builder: (BuildContext bc) {
                                      return SafeArea(
                                        child: Wrap(
                                          children: <Widget>[
                                            ListTile(
                                              leading: const Icon(Icons.edit),
                                              title: const Text('Update Profile'),
                                              onTap: () async {
                                                Navigator.pop(bc); // Close the bottom sheet
                                                await Navigator.pushNamed(context, '/profile_update');
                                                Provider.of<ProfilePageViewModel>(context, listen: false).fetchUserData();
                                              },
                                            ),
                                            ListTile(
                                              leading: const Icon(Icons.logout),
                                              title: const Text('Logout'),
                                              onTap: () {
                                                Navigator.pop(bc); // Close the bottom sheet
                                                Provider.of<ProfilePageViewModel>(context, listen: false).logout(context);
                                              },
                                            ),
                                          ],
                                        ),
                                      );
                                    },
                                  );
                                },
                              ),
                            ),
                            // Profile Picture (centered at bottom of background)
                            Positioned(
                              top: backgroundHeight - profileImageRadius,
                              left:
                                  MediaQuery.of(context).size.width / 2 -
                                  profileImageRadius,
                              child: Container(
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: Colors.white,
                                    width: 4,
                                  ),
                                ),
                                child: InkWell(
                                  onTap: () {
                                    viewModel.pickAndUploadProfilePhoto();
                                  },
                                  child: CircleAvatar(
                                    radius: profileImageRadius,
                                    backgroundImage: (viewModel.userData!['profilePhotoUrl'] != null && viewModel.userData!['profilePhotoUrl'] != 'default-profile.png')
                                        ? NetworkImage(viewModel.userData!['profilePhotoUrl']!)
                                        : const AssetImage('assets/images/default_thumbnail.jpg') as ImageProvider, // Placeholder
                                    backgroundColor: Colors.grey.shade200,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: profileImageRadius + 10),
                        // User Name
                        Text(
                          viewModel.userData!['name'] ?? 'George Mukabi',
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        // User Stats
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Row(
                              children: [
                                const Icon(
                                  Icons.arrow_upward,
                                  size: 16,
                                  color: Colors.green,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  '${viewModel.userData!['monthly_upvote'] ?? 0}',
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(width: 8),
                              ],
                            ),
                            Row(
                              children: [
                                const Icon(
                                  Icons.remove_red_eye_outlined,
                                  size: 16,
                                  color: Colors.grey,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  '${viewModel.userData!['total_monthly_reads'] ?? 0}',
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(width: 8),
                              ],
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 5,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.grey[200],
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Row(
                                children: [
                                  const Icon(
                                    Icons.wallet,
                                    size: 18,
                                    color: Colors.black54,
                                  ),
                                  const SizedBox(width: 5),
                                  Text(
                                    '${viewModel.userData!['tokens'] ?? 0} Tokens',
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        // Action Buttons
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 50.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              _buildCustomActionButton(
                                icon: Icons.wallet,
                                label: 'Top up',
                                onPressed: () =>
                                    viewModel.showTopUpDialog(context),
                                backgroundColor: const Color(0xFF333333),
                                iconColor: const Color.fromARGB(209, 255, 255, 255),
                              ),
                              _buildCustomActionButton(
                                icon: Icons.upload,
                                label: 'Top up', // This label seems incorrect, should it be 'Upload Story'?
                                onPressed: () =>
                                    viewModel.showTopUpDialog(context), // This onPressed seems incorrect
                                backgroundColor: const Color(0xFFD1E4FF),
                                iconColor: const Color(0xD1333333),
                              ),
                              _buildCustomActionButton(
                                icon: Icons.payment,
                                label: 'Withdraw',
                                onPressed: () =>
                                    viewModel.showWithdrawDialog(context),
                                backgroundColor: const Color(0xFFCFFDBC),
                                iconColor: const Color(0xD1333333),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 10),
                        // Recent Reads / My Stories / Trending Stories Section
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                viewModel.userData!['role'] == 'reader'
                                    ? (viewModel.recentReads.isNotEmpty ? 'Recent Reads' : 'Trending Stories')
                                    : (viewModel.myStories.isNotEmpty ? 'My Stories' : 'Trending Stories'),
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              TextButton(
                                onPressed: () {
                                  // Handle view all based on what's displayed
                                  if (viewModel.userData!['role'] == 'reader') {
                                    if (viewModel.recentReads.isNotEmpty) {
                                      // Navigate to Recent Reads page
                                    } else {
                                      // Navigate to Trending Stories page
                                    }
                                  } else {
                                    if (viewModel.myStories.isNotEmpty) {
                                      // Navigate to My Stories page
                                    } else {
                                      // Navigate to Trending Stories page
                                    }
                                  }
                                },
                                child: const Text(
                                  'View All',
                                  style: TextStyle(
                                    color: Color(0xD1E4FFFF),
                                    fontSize: 16,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 10),
                        Builder(
                          builder: (context) {
                            if (viewModel.userData!['role'] == 'reader') {
                              return (viewModel.recentReads.isNotEmpty)
                                  ? Column(
                                      children: viewModel.recentReads.map((story) {
                                        if (story is Map<String, dynamic>) {
                                          return _buildRecentReadItem(
                                            title: story['title'] ?? 'No Title',
                                            author: (story['author'] is Map<String, dynamic>)
                                                ? story['author']['name'] ?? 'Unknown Author'
                                                : (story['author'] is String)
                                                    ? story['author']
                                                    : 'Unknown Author',
                                            date: story['createdAt'] != null
                                                ? DateFormat('MMM d, yyyy').format(DateTime.parse(story['createdAt']))
                                                : '',
                                          );
                                        } else {
                                          return const SizedBox.shrink(); // Or a placeholder widget
                                        }
                                      }).toList().cast<Widget>(),
                                    )
                                  : (viewModel.trendingStories.isNotEmpty)
                                      ? Column(
                                          children: viewModel.trendingStories.map((story) {
                                            if (story is Map<String, dynamic>) {
                                              return _buildRecentReadItem(
                                                title: story['title'] ?? 'No Title',
                                                author: (story['author'] is Map<String, dynamic>)
                                                ? story['author']['name'] ?? 'Unknown Author'
                                                : (story['author'] is String)
                                                    ? story['author']
                                                    : 'Unknown Author',
                                                date: story['createdAt'] != null
                                                    ? DateFormat('MMM d, yyyy').format(DateTime.parse(story['createdAt']))
                                                    : '',
                                              );
                                            } else {
                                              return const SizedBox.shrink(); // Or a placeholder widget
                                            }
                                          }).toList().cast<Widget>(),
                                        )
                                      : const SizedBox.shrink();
                            } else if (viewModel.userData!['role'] == 'writer') {
                              return (viewModel.myStories.isNotEmpty)
                                  ? Column(
                                      children: viewModel.myStories.map((story) {
                                        if (story is Map<String, dynamic>) {
                                          return _buildRecentReadItem(
                                            title: story['title'] ?? 'No Title',
                                            author: (story['author'] is Map<String, dynamic>)
                                                ? story['author']['name'] ?? 'Unknown Author'
                                                : (story['author'] is String)
                                                    ? story['author']
                                                    : 'Unknown Author',
                                            date: story['createdAt'] != null
                                                ? DateFormat('MMM d, yyyy').format(DateTime.parse(story['createdAt']))
                                                : '',
                                          );
                                        } else {
                                          return const SizedBox.shrink(); // Or a placeholder widget
                                        }
                                      }).toList().cast<Widget>(),
                                    )
                                  : (viewModel.trendingStories.isNotEmpty)
                                      ? Column(
                                          children: viewModel.trendingStories.map((story) {
                                            if (story is Map<String, dynamic>) {
                                              return _buildRecentReadItem(
                                                title: story['title'] ?? 'No Title',
                                                author: (story['author'] is Map<String, dynamic>)
                                                ? story['author']['name'] ?? 'Unknown Author'
                                                : (story['author'] is String)
                                                    ? story['author']
                                                    : 'Unknown Author',
                                                date: story['createdAt'] != null
                                                    ? DateFormat('MMM d, yyyy').format(DateTime.parse(story['createdAt']))
                                                    : '',
                                              );
                                            } else {
                                              return const SizedBox.shrink(); // Or a placeholder widget
                                            }
                                          }).toList().cast<Widget>(),
                                        )
                                      : const SizedBox.shrink();
                            } else {
                              return const SizedBox.shrink(); // Handle other roles or no stories
                            }
                          },
                        ),
                      ],
                    ),
                  ),
          );
        },
      ),
    );
  }

  Widget _buildCustomActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
    required Color backgroundColor,
    required Color iconColor,
  }) {
    return Column(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: backgroundColor,
            shape: BoxShape.circle,
          ),
          child: IconButton(
            icon: Icon(icon, size: 20, color: iconColor),
            onPressed: onPressed,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(fontSize: 14, color: Colors.black87),
        ),
      ],
    );
  }

  Widget _buildRecentReadItem({
    required String title,
    required String author,
    required String date,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // container for Recent Reads
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              image: const DecorationImage(
                image: NetworkImage(
                  'https://images.pexels.com/photos/986857/pexels-photo-986857.jpeg',
                ),
                fit: BoxFit.cover,
              ),
            ),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Title: $title',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  'By: $author',
                  style: const TextStyle(fontSize: 14, color: Colors.grey),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                date,
                style: const TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ],
          ),
        ],
      ),
    );
  }
}