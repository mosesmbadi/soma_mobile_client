import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:soma/core/widgets/story_card_grid.dart';

void main() {
  group('StoryCardGrid', () {
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