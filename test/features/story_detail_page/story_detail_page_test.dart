// test/features/story_detail_page/story_detail_page_test.dart

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:provider/provider.dart';
import 'package:soma/data/story_repository.dart';
import 'package:soma/data/user_repository.dart';
import 'package:soma/features/story_detail_page/viewmodels/story_detail_viewmodel.dart';
import 'package:soma/features/story_detail_page/views/story_detail_page.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:soma/core/widgets/guest_registration_card.dart';
import 'package:soma/core/widgets/story_unlock_card.dart';
import 'package:http/http.dart' as http;

// Mocks
class MockStoryRepository extends Mock implements StoryRepository {}
class MockUserRepository extends Mock implements UserRepository {}
class MockStoryDetailViewModel extends Mock implements StoryDetailViewModel {
  @override
  ScrollController get scrollController => ScrollController();
}
class MockSharedPreferences extends Mock implements SharedPreferences {}
class MockClient extends Mock implements http.Client {}

void main() {
  late MockStoryRepository mockStoryRepository;
  late MockUserRepository mockUserRepository;
  late MockStoryDetailViewModel mockStoryDetailViewModel;
  late MockSharedPreferences mockSharedPreferences;
  late MockClient mockHttpClient;

  setUpAll(() {
    TestWidgetsFlutterBinding.ensureInitialized();
    HttpOverrides.global = null;
  });

  setUp(() {
    mockStoryRepository = MockStoryRepository();
    mockUserRepository = MockUserRepository();
    mockStoryDetailViewModel = MockStoryDetailViewModel();
    mockSharedPreferences = MockSharedPreferences();
    mockHttpClient = MockClient();
    reset(mockStoryRepository);
    reset(mockUserRepository);
    reset(mockStoryDetailViewModel);
    reset(mockSharedPreferences);
    reset(mockHttpClient);
  });

  Widget createStoryDetailPage({
    required Map<String, dynamic> story,
  }) {
    return MultiProvider(
      providers: [
        Provider<StoryRepository>(create: (_) => mockStoryRepository),
        Provider<UserRepository>(create: (_) => mockUserRepository),
        Provider<SharedPreferences>(create: (_) => mockSharedPreferences),
        ChangeNotifierProvider<StoryDetailViewModel>.value(value: mockStoryDetailViewModel),
        Provider<http.Client>(create: (_) => mockHttpClient),
      ],
      child: MaterialApp(
        home: StoryDetailPage(story: story),
      ),
    );
  }

  group('StoryDetailPage', () {
    final Map<String, dynamic> baseStory = {
      '_id': 'story123',
      'title': 'Test Story Title',
      'author': {'_id': 'author123', 'name': 'Test Author'},
      'content': '[{"insert":"This is the story content.\n"}]',
      'thumbnailUrl': 'https://example.com/thumbnail.jpg',
      'slug': 'test-story-title',
      'estimatedTime': 5,
      'is_premium': false,
      'tags': [
        {'name': 'Adventure'},
        {'name': 'Fantasy'}
      ],
    };

    testWidgets('displays basic story information', (WidgetTester tester) async {
      when(mockSharedPreferences.getString('jwt_token')).thenReturn('dummy_token');
      when(mockUserRepository.getCurrentUserDetails()).thenReturn(Future.value({
            '_id': 'user123',
            'tokens': 10,
          }));
      when(mockStoryRepository.isStoryUnlocked(any as String, any as String)).thenReturn(Future.value(false));

      await tester.pumpWidget(createStoryDetailPage(story: baseStory));
      await tester.pumpAndSettle();

      expect(find.text('Test Story Title'), findsOneWidget);
      expect(find.text('By Test Author'), findsOneWidget);
      expect(find.textContaining('This is the story content.'), findsOneWidget);
      expect(find.byType(Image), findsOneWidget);
      expect(find.byType(Chip), findsNWidgets(2));
    });

    testWidgets('displays GuestRegistrationCard for premium story when not logged in', (WidgetTester tester) async {
      final premiumStory = {...baseStory, 'is_premium': true};
      when(mockSharedPreferences.getString('jwt_token')).thenReturn(null);

      await tester.pumpWidget(createStoryDetailPage(story: premiumStory));
      await tester.pumpAndSettle();

      expect(find.byType(GuestRegistrationCard), findsOneWidget);
      expect(find.byType(StoryUnlockCard), findsNothing);
    });

    testWidgets('displays UnlockCard for premium story when logged in with enough tokens', (WidgetTester tester) async {
      final premiumStory = {...baseStory, 'is_premium': true};
      when(mockSharedPreferences.getString('jwt_token')).thenReturn('dummy_token');
      when(mockUserRepository.getCurrentUserDetails()).thenReturn(Future.value({
            '_id': 'user123',
            'tokens': 10,
          }));
      when(mockStoryRepository.isStoryUnlocked(any as String, any as String)).thenReturn(Future.value(false));

      await tester.pumpWidget(createStoryDetailPage(story: premiumStory));
      await tester.pumpAndSettle();

      expect(find.byType(StoryUnlockCard), findsOneWidget);
      expect(find.byType(GuestRegistrationCard), findsNothing);
      expect(find.text('Unlock for 1 token'), findsOneWidget);
    });

    testWidgets('displays TopUpCard for premium story when logged in with no tokens', (WidgetTester tester) async {
      final premiumStory = {...baseStory, 'is_premium': true};
      when(mockSharedPreferences.getString('jwt_token')).thenReturn('dummy_token');
      when(mockUserRepository.getCurrentUserDetails()).thenReturn(Future.value({
            '_id': 'user123',
            'tokens': 0,
          }));
      when(mockStoryRepository.isStoryUnlocked(any as String, any as String)).thenReturn(Future.value(false));

      await tester.pumpWidget(createStoryDetailPage(story: premiumStory));
      await tester.pumpAndSettle();

      expect(find.byType(StoryUnlockCard), findsOneWidget);
      expect(find.byType(GuestRegistrationCard), findsNothing);
      expect(find.text('Top up your tokens'), findsOneWidget);
    });

    testWidgets('does not display any unlock cards when the story is already unlocked', (WidgetTester tester) async {
      final premiumStory = {...baseStory, 'is_premium': true};
      when(mockSharedPreferences.getString('jwt_token')).thenReturn('dummy_token');
      when(mockUserRepository.getCurrentUserDetails()).thenReturn(Future.value({
            '_id': 'user123',
            'tokens': 10,
          }));
      when(mockStoryRepository.isStoryUnlocked(any as String, any as String)).thenReturn(Future.value(true));

      await tester.pumpWidget(createStoryDetailPage(story: premiumStory));
      await tester.pumpAndSettle();

      expect(find.byType(StoryUnlockCard), findsNothing);
      expect(find.byType(GuestRegistrationCard), findsNothing);
    });
  });
}