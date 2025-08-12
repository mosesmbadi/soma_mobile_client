import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:soma/features/profile_page/viewmodels/profile_page_viewmodel.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Import the new widgets
import 'package:soma/features/profile_page/widgets/profile_header.dart';
import 'package:soma/features/profile_page/widgets/profile_info_section.dart';
import 'package:soma/features/profile_page/widgets/profile_action_buttons.dart';
import 'package:soma/features/profile_page/widgets/request_writer_access_button.dart';
import 'package:soma/features/profile_page/widgets/profile_story_list_section.dart';

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
                ? const Center(child: CircularProgressIndicator()) // Show loading indicator if user data is null
                : SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: <Widget>[
                        ProfileHeader(
                          viewModel: viewModel,
                          backgroundHeight: backgroundHeight,
                          profileImageRadius: profileImageRadius,
                        ),
                        const SizedBox(height: profileImageRadius + 10),
                        ProfileInfoSection(viewModel: viewModel),
                        const SizedBox(height: 10),
                        ProfileActionButtons(viewModel: viewModel),
                        RequestWriterAccessButton(),
                        const SizedBox(height: 10),
                        ProfileStoryListSection(),
                      ],
                    ),
                  ),
          );
        },
      ),
    );
  }
}