
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:soma/features/profile_page/viewmodels/profile_page_viewmodel.dart';

class ProfileHeader extends StatelessWidget {
  final ProfilePageViewModel viewModel;
  final double backgroundHeight;
  final double profileImageRadius;

  const ProfileHeader({
    super.key,
    required this.viewModel,
    required this.backgroundHeight,
    required this.profileImageRadius,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
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
                  const Center(
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
            icon: const Icon(
              Icons.settings,
              color: Colors.white,
              size: 30,
            ),
            onPressed: () {
              showModalBottomSheet(
                context: context,
                builder: (BuildContext bc) {
                  return SafeArea(
                    child: Wrap(
                      children: <Widget>[
                        ListTile(
                          leading: const Icon(Icons.edit),
                          title: const Text(
                            'Update Profile',
                          ),
                          onTap: () async {
                            Navigator.pop(
                              bc,
                            ); // Close the bottom sheet
                            await Navigator.pushNamed(
                              context,
                              '/profile_update',
                            );
                            Provider.of<ProfilePageViewModel>(context, listen: false)
                                .fetchUserData();
                          },
                        ),
                        ListTile(
                          leading: const Icon(Icons.logout),
                          title: const Text('Logout'),
                          onTap: () {
                            Navigator.pop(
                              bc,
                            ); // Close the bottom sheet
                            Provider.of<ProfilePageViewModel>(context, listen: false)
                                .logout(context);
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
          left: MediaQuery.of(context).size.width / 2 - profileImageRadius,
          child: Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: Colors.white,
                width: 4,
              ),
            ),
            child: CircleAvatar(
              radius: profileImageRadius,
              backgroundImage: (viewModel.userData!['profilePicture'] != null &&
                      viewModel.userData!['profilePicture'] != 'default-profile.png')
                  ? NetworkImage(
                      viewModel.userData!['profilePicture'],
                    )
                  : const NetworkImage(
                          'https://images.pexels.com/photos/2975709/pexels-photo-2975709.jpeg',
                        )
                        as ImageProvider, // Placeholder
              backgroundColor: Colors.grey.shade200,
            ),
          ),
        ),
      ],
    );
  }
}
