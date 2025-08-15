import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:soma/core/services/analytics_repository.dart';

class EarningsTab extends StatefulWidget {
  @override
  _EarningsTabState createState() => _EarningsTabState();
}

class _EarningsTabState extends State<EarningsTab> {
  late AnalyticsRepository _analyticsRepository;
  Map<String, dynamic>? _analyticsData;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _analyticsRepository = Provider.of<AnalyticsRepository>(
      context,
      listen: false,
    );
    _fetchAnalyticsData();
  }

  Future<void> _fetchAnalyticsData() async {
    try {
      final data = await _analyticsRepository.fetchUserAnalytics();
      setState(() {
        _analyticsData = data;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return Center(child: Text('Error: $_error'));
    }

    if (_analyticsData == null) {
      return const Center(child: Text('No data available'));
    }

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildEarningsChart(),
          const SizedBox(height: 16),
          _buildTopPerformingStories(),
          const SizedBox(height: 16),
          _buildMostReadStories(),
          const SizedBox(height: 16),
          _buildMostUpvotedStories(),
        ],
      ),
    );
  }

  Widget _buildEarningsChart() {
    final earningsData = _analyticsData?['earningsPerMonth'] ?? [];

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Earnings Per Month',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            ...earningsData.map<Widget>(
              (data) => Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(data['month']),
                  Text('Earnings: ${data['earnings']}'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTopPerformingStories() {
    final topStories = _analyticsData?['topPerformingStories'] ?? [];

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Top Performing Stories',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            ...topStories.map<Widget>(
              (story) => ListTile(
                title: Text(story['title']),
                subtitle: Text('Earnings: ${story['earnings']}'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMostReadStories() {
    final mostReadStories = _analyticsData?['mostReadStories'] ?? [];

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Most Read Stories',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            ...mostReadStories.map<Widget>(
              (story) => ListTile(
                title: Text(story['title']),
                subtitle: Text('Reads: ${story['reads']}'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMostUpvotedStories() {
    final mostUpvotedStories = _analyticsData?['mostUpvotedStories'] ?? [];

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Most Upvoted Stories',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            ...mostUpvotedStories.map<Widget>(
              (story) => ListTile(
                title: Text(story['title']),
                subtitle: Text('Upvotes: ${story['upvotes']}'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
