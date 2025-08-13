import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:soma/core/widgets/stories/story_card_grid.dart';

void main() {
  group('StoryCardGrid', () {
    setUpAll(() {
      // Mock the network image loading to prevent actual HTTP requests
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(
        const MethodChannel('flutter/assets'),
        (MethodCall methodCall) async {
          if (methodCall.method == 'loadAsset') {
            // Return a transparent 1x1 pixel image as a placeholder
            return Future.value(Uint8List.fromList([0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A, 0x00, 0x00, 0x00, 0x0D, 0x49, 0x48, 0x44, 0x52, 0x00, 0x00, 0x00, 0x01, 0x00, 0x00, 0x00, 0x01, 0x08, 0x06, 0x00, 0x00, 0x00, 0x1F, 0x15, 0xC4, 0x89, 0x00, 0x00, 0x00, 0x0A, 0x49, 0x44, 0x41, 0x54, 0x78, 0x9C, 0x63, 0x00, 0x01, 0x00, 0x00, 0x05, 0x00, 0x01, 0x0D, 0x0A, 0x2D, 0xB4, 0x00, 0x00, 0x00, 0x00, 0x49, 0x45, 0x4E, 0x44, 0xAE, 0x42, 0x60, 0x82]));
          }
          return null;
        },
      );
    });

    testWidgets('displays story information correctly', (WidgetTester tester) async {
      final Map<String, dynamic> dummyStory = {
        'title': 'Grid Story Title',
        'author': {'name': 'Grid Author'},
        'content': '[{"insert":"This is a grid content snippet."}]',
        'thumbnailUrl': 'https://example.com/grid_thumbnail.jpg',
        'reads': 456,
        'rating': 3.5,
        'tags': [{'name': 'Fantasy'}],
      };

      bool tapped = false;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: StoryCardGrid(
              story: dummyStory,
              onTap: () {
                tapped = true;
              },
            ),
          ),
        ),
      );

      expect(find.text('Grid Story Title'), findsOneWidget);
      expect(find.text('By Grid Author'), findsOneWidget);
      expect(find.textContaining('This is a grid content snippet.'), findsOneWidget);
      expect(find.text('456'), findsOneWidget);
      expect(find.text('3.5'), findsOneWidget);
      expect(find.byType(Chip), findsOneWidget);
      expect(find.text('Fantasy'), findsOneWidget);

      // Find the GestureDetector specifically wrapping the StoryCardGrid
      await tester.tap(find.byWidgetPredicate((widget) =>
          widget is GestureDetector && widget.child is AspectRatio
      ));
      await tester.pumpAndSettle();
      expect(tapped, isTrue);
    });

    testWidgets('displays default values when data is missing', (WidgetTester tester) async {
      final Map<String, dynamic> dummyStory = {
        'content': '[]',
      };

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: StoryCardGrid(
              story: dummyStory,
              onTap: () {},
            ),
          ),
        ),
      );

      expect(find.text('No Title'), findsOneWidget);
      expect(find.text('By Unknown Author'), findsOneWidget);
      expect(find.text('0'), findsOneWidget);
      expect(find.text('4.5'), findsOneWidget);
      expect(find.byType(Chip), findsNothing);
    });
  });
}