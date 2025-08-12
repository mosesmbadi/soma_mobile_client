import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:provider/provider.dart';
import 'package:soma/data/user_repository.dart';
import 'package:soma/data/story_repository.dart';
import 'package:soma/features/story_detail_page/views/story_detail_page.dart';
import 'package:soma/features/author_profile_page/views/author_profile_page.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

// Mock classes for dependencies
class MockUserRepository extends Mock implements UserRepository {}
class MockStoryRepository extends Mock implements StoryRepository {}
class MockSharedPreferences extends Mock implements SharedPreferences {}
class MockHttpClient extends Mock implements http.Client {}

void main() {
  group('StoryDetailPage Author Navigation', () {
    late MockUserRepository mockUserRepository;
    late MockStoryRepository mockStoryRepository;
    late MockSharedPreferences mockSharedPreferences;
    late MockHttpClient mockHttpClient;

    setUp(() {
      mockUserRepository = MockUserRepository();
      mockStoryRepository = MockStoryRepository();
      mockSharedPreferences = MockSharedPreferences();
      mockHttpClient = MockHttpClient();

      // Mock SharedPreferences.getInstance() for AuthorProfilePage's FutureBuilder
      // Note: Mocking static methods directly is not ideal with Mockito.
      // A better approach for SharedPreferences is to provide a mock instance
      // through a Provider or directly to the widget if it's a dependency.
      // For this test, we'll mock the static method as a workaround.
      // Ensure SharedPreferences is imported and available in the test scope.
      when(SharedPreferences.getInstance()).thenAnswer((_) async => mockSharedPreferences);
      when(mockSharedPreferences.getString('jwt_token')).thenReturn('dummy_token');


      // Mock user details for StoryDetailPage's _fetchCurrentUserTokens
      when(mockUserRepository.getCurrentUserDetails()).thenAnswer((_) async => {
            '_id': 'current_user_id',
            'tokens': 10,
          });

      // Mock story unlock status for StoryDetailPage
      when(mockStoryRepository.isStoryUnlocked(any as String, any as String)).thenAnswer((_) async => true);

      // Mock author details for AuthorProfileViewModel
      when(mockUserRepository.getUserById(any as String)).thenAnswer((_) async => {
            '_id': 'author_123',
            'name': 'Test Author',
          });

      // Mock author stories for AuthorProfileViewModel
      when(mockStoryRepository.getStoriesByAuthor(any as String)).thenAnswer((_) async => [
            {'_id': 'story_1', 'title': 'Author Story 1', 'author': {'_id': 'author_123', 'name': 'Test Author'}, 'tags': []},
            {'_id': 'story_2', 'title': 'Author Story 2', 'author': {'_id': 'author_123', 'name': 'Test Author'}, 'tags': []},
          ]);
    });

    Widget createStoryDetailPage({required Map<String, dynamic> story}) {
      return MultiProvider(
        providers: [
          Provider<UserRepository>.value(value: mockUserRepository),
          Provider<StoryRepository>.value(value: mockStoryRepository),
          Provider<SharedPreferences>.value(value: mockSharedPreferences),
          Provider<http.Client>.value(value: mockHttpClient),
        ],
        child: MaterialApp(
          home: StoryDetailPage(story: story),
          onGenerateRoute: (settings) {
            if (settings.name == '/register') {
              return MaterialPageRoute(builder: (_) => const Text('Register Page'));
            }
            return null;
          },
        ),
      );
    }

    testWidgets('tapping author name navigates to AuthorProfilePage', (WidgetTester tester) async {
      final testStory = {
        '_id': 'story_id_1',
        'title': 'Test Story',
        'author': {'_id': 'author_123', 'name': 'Test Author'},
        'content': '[]',
        'is_premium': false,
        'tags': [],
      };

      await tester.pumpWidget(createStoryDetailPage(story: testStory));
      await tester.pumpAndSettle(); // Wait for initial data loading

      // Verify StoryDetailPage is displayed
      expect(find.text('Test Story'), findsOneWidget);
      expect(find.text('By Test Author'), findsOneWidget);

      // Tap on the author name
      await tester.tap(find.text('By Test Author'));
      await tester.pumpAndSettle(); // Wait for navigation

      // Verify AuthorProfilePage is displayed
      expect(find.byType(AuthorProfilePage), findsOneWidget);
      expect(find.text('Test Author'), findsOneWidget); // Author name on profile page
      expect(find.text('Stories by Test Author'), findsOneWidget);
      expect(find.text('Author Story 1'), findsOneWidget);
      expect(find.text('Author Story 2'), findsOneWidget);

      // Verify that getUserById and getStoriesByAuthor were called with the correct authorId
      verify(mockUserRepository.getUserById('author_123')).called(1);
      verify(mockStoryRepository.getStoriesByAuthor('author_123')).called(1);
    });
  });
}