import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:soma/features/profile_page/viewmodels/profile_page_viewmodel.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:soma/core/services/analytics_repository.dart';

// Import the new widgets
import 'package:soma/features/profile_page/widgets/profile_header.dart';
import 'package:soma/features/profile_page/widgets/profile_info_section.dart';
import 'package:soma/features/profile_page/widgets/profile_action_buttons.dart';
import 'package:soma/features/profile_page/widgets/request_writer_access_button.dart';
import 'package:soma/features/profile_page/widgets/profile_story_list_section.dart';
import 'package:soma/features/profile_page/views/earnings_tab.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage>
    with TickerProviderStateMixin {
  late SharedPreferences _prefs;
  late ProfilePageViewModel _viewModel;
  bool _isInitialized = false;
  TabController? _tabController;

  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  Future<void> _initializeData() async {
    _prefs = await SharedPreferences.getInstance();
    _viewModel = ProfilePageViewModel(prefs: _prefs);
    _viewModel.addListener(_handleViewModelChanges);
    _handleViewModelChanges();
    if (mounted) {
      setState(() {
        _isInitialized = true;
      });
    }
  }

  void _handleViewModelChanges() {
    if (!mounted) return;
    final isWriter = _viewModel.userData?['role'] == 'writer';
    if (isWriter) {
      if (_tabController == null) {
        _tabController = TabController(length: 3, vsync: this);
        _tabController!.addListener(() {
          if (mounted) {
            setState(() {});
          }
        });
        setState(() {});
      }
    } else {
      if (_tabController != null) {
        _tabController?.dispose();
        _tabController = null;
        setState(() {});
      }
    }
  }

  @override
  void dispose() {
    _viewModel.removeListener(_handleViewModelChanges);
    _tabController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_isInitialized) {
      return const Center(child: CircularProgressIndicator());
    }

    return MultiProvider(
      providers: [
        Provider<AnalyticsRepository>(create: (_) => AnalyticsRepository()),
      ],
      child: ChangeNotifierProvider<ProfilePageViewModel>.value(
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
                  ? const Center(
                      child: CircularProgressIndicator(),
                    ) // Show loading indicator if user data is null
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
                          if (_viewModel.userData?['role'] == 'writer' &&
                              _tabController != null) ...[
                            const SizedBox(height: 20),
                            TabBar(
                              controller: _tabController,
                              labelColor: Theme.of(context).colorScheme.primary,
                              unselectedLabelColor: Colors.grey,
                              indicatorColor: Theme.of(
                                context,
                              ).colorScheme.primary,
                              tabs: const [
                                Tab(text: 'Stories'),
                                Tab(text: 'Earnings'),
                                Tab(text: 'Reads'),
                              ],
                            ),
                            const SizedBox(height: 10),
                            [
                              ProfileStoryListSection(),
                              EarningsTab(),
                              const Center(child: Text('Recent Reads Content')),
                            ][_tabController!.index],
                          ] else ...[
                            RequestWriterAccessButton(),
                            const SizedBox(height: 10),
                            ProfileStoryListSection(),
                          ],
                        ],
                      ),
                    ),
            );
          },
        ),
      ),
    );
  }
}
