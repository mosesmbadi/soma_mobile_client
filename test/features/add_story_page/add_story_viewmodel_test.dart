import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:soma/features/add_story_page/viewmodels/add_story_viewmodel.dart'; // Corrected import

import 'add_story_viewmodel_test.mocks.dart'; // This file will be generated


// flutter test test/features/add_story_page/add_story_viewmodel_test.dart


@GenerateMocks([http.Client, SharedPreferences]) // Add SharedPreferences back here
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  group('AddStoryViewModel', () {
    late AddStoryViewModel viewModel;
    late MockClient mockHttpClient;
    late MockSharedPreferences mockSharedPreferences; // Declare it

    setUp(() {
      mockHttpClient = MockClient();
      mockSharedPreferences = MockSharedPreferences(); // Initialize mock

      // Stub for _loadSavedStory in the main setUp, for tests that don't re-initialize viewModel
      when(mockSharedPreferences.getString('draft_story_title')).thenReturn(null);
      when(mockSharedPreferences.getString('draft_story_content')).thenReturn(null);

      // Initialize the ViewModel with mocked dependencies
      // The constructor calls _fetchTags and _loadSavedStory, so we need to set up mocks before initializing.
      when(mockSharedPreferences.getString('jwt_token'))
          .thenReturn('test_token');
      when(mockHttpClient.get(
        any,
        headers: anyNamed('headers'),
      )).thenAnswer((_) async => http.Response('[{"id": "1", "name": "Tag1"}, {"id": "2", "name": "Tag2"}]', 200));

      viewModel = AddStoryViewModel(
        httpClient: mockHttpClient,
        sharedPreferences: mockSharedPreferences,
      );
    });

    tearDown(() {
      viewModel.dispose();
    });

    test('fetchTags fetches tags successfully on initialization', () async {
      // Assert that tags are fetched during initialization
      // We need to wait for the async operations in the constructor to complete
      await Future.delayed(Duration.zero); // Allow async operations to complete

      expect(viewModel.availableTags, isNotEmpty);
      expect(viewModel.availableTags.length, 2);
      expect(viewModel.availableTags[0]['name'], 'Tag1');
      expect(viewModel.availableTags[1]['name'], 'Tag2');
      expect(viewModel.isLoading, false);
      expect(viewModel.tagsErrorMessage, '');
    });

    test('fetchTags handles missing authentication token on initialization', () async {
      // Arrange: Re-initialize viewModel with a different mock setup for this test
      mockSharedPreferences = MockSharedPreferences(); // Re-initialize mock for this test
      when(mockSharedPreferences.getString('jwt_token')).thenReturn(null); // Set token to null for this test
      // Stub for _loadSavedStory for this specific test
      when(mockSharedPreferences.getString('draft_story_title')).thenReturn(null);
      when(mockSharedPreferences.getString('draft_story_content')).thenReturn(null);

      viewModel = AddStoryViewModel(
        httpClient: mockHttpClient,
        sharedPreferences: mockSharedPreferences,
      );

      // Act: No explicit call needed, it happens in constructor
      await Future.delayed(Duration.zero); // Allow async operations to complete

      // Assert
      expect(viewModel.availableTags, isEmpty);
      expect(viewModel.isLoading, false);
      expect(viewModel.tagsErrorMessage,
          'Authentication token not found. Cannot fetch tags.');
    });

    test('fetchTags handles API error on initialization', () async {
      // Arrange: Re-initialize viewModel with a different mock setup for this test
      mockSharedPreferences = MockSharedPreferences(); // Re-initialize mock for this test
      when(mockSharedPreferences.getString('jwt_token')).thenReturn('test_token'); // Set token for this test
      when(mockHttpClient.get(
        any,
        headers: anyNamed('headers'),
      )).thenAnswer((_) async => http.Response('{"message": "Failed to fetch"}', 400)); // Ensure valid JSON
      // Stub for _loadSavedStory for this specific test
      when(mockSharedPreferences.getString('draft_story_title')).thenReturn(null);
      when(mockSharedPreferences.getString('draft_story_content')).thenReturn(null);

      viewModel = AddStoryViewModel(
        httpClient: mockHttpClient,
        sharedPreferences: mockSharedPreferences,
      );

      // Act: No explicit call needed, it happens in constructor
      await Future.delayed(Duration.zero); // Allow async operations to complete

      // Assert
      expect(viewModel.availableTags, isEmpty);
      expect(viewModel.isLoading, false);
      expect(viewModel.tagsErrorMessage, 'Failed to fetch');
    });

    test('fetchTags handles network error on initialization', () async {
      // Arrange: Re-initialize viewModel with a different mock setup for this test
      mockSharedPreferences = MockSharedPreferences(); // Re-initialize mock for this test
      when(mockSharedPreferences.getString('jwt_token')).thenReturn('test_token'); // Set token for this test
      when(mockHttpClient.get(
        any,
        headers: anyNamed('headers'),
      )).thenThrow(Exception('Network error'));
      // Stub for _loadSavedStory for this specific test
      when(mockSharedPreferences.getString('draft_story_title')).thenReturn(null);
      when(mockSharedPreferences.getString('draft_story_content')).thenReturn(null);

      viewModel = AddStoryViewModel(
        httpClient: mockHttpClient,
        sharedPreferences: mockSharedPreferences,
      );

      // Act: No explicit call needed, it happens in constructor
      await Future.delayed(Duration.zero); // Allow async operations to complete

      // Assert
      expect(viewModel.availableTags, isEmpty);
      expect(viewModel.isLoading, false);
      expect(viewModel.tagsErrorMessage, contains('Network error'));
    });

    group('toggleTagSelection', () {
      test('adds a tag if not already selected and less than 3 tags', () {
        // Arrange
        viewModel.availableTags.addAll([{'id': '1', 'name': 'Tag1'}, {'id': '2', 'name': 'Tag2'}]);
        expect(viewModel.selectedTagIds, isEmpty);

        // Act
        viewModel.toggleTagSelection('1');

        // Assert
        expect(viewModel.selectedTagIds, contains('1'));
        expect(viewModel.selectedTagIds.length, 1);
        expect(viewModel.tagsErrorMessage, '');
      });

      test('removes a tag if already selected', () {
        // Arrange
        viewModel.availableTags.addAll([{'id': '1', 'name': 'Tag1'}, {'id': '2', 'name': 'Tag2'}]);
        viewModel.toggleTagSelection('1'); // Add it first
        expect(viewModel.selectedTagIds, contains('1'));

        // Act
        viewModel.toggleTagSelection('1');

        // Assert
        expect(viewModel.selectedTagIds, isEmpty);
        expect(viewModel.tagsErrorMessage, '');
      });

      test('does not add a tag if 3 tags are already selected', () {
        // Arrange
        viewModel.availableTags.addAll([{'id': '1', 'name': 'Tag1'}, {'id': '2', 'name': 'Tag2'}, {'id': '3', 'name': 'Tag3'}, {'id': '4', 'name': 'Tag4'}]);
        viewModel.toggleTagSelection('1');
        viewModel.toggleTagSelection('2');
        viewModel.toggleTagSelection('3');
        expect(viewModel.selectedTagIds.length, 3);

        // Act
        viewModel.toggleTagSelection('4');

        // Assert
        expect(viewModel.selectedTagIds, isNot(contains('4')));
        expect(viewModel.selectedTagIds.length, 3);
        expect(viewModel.tagsErrorMessage, 'You can select a maximum of 3 tags.');
      });
    });

    // TODO: Add tests for _loadSavedStory
    // TODO: Add tests for saveStoryLocally
    // TODO: Add tests for publishStory
    // TODO: Add tests for pickImage
  });
}