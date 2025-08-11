import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:soma/core/widgets/withdraw_bottom_sheet.dart';

void main() {
  group('WithdrawBottomSheet', () {
    testWidgets('shows bottom sheet when called', (WidgetTester tester) async {
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: Builder(
            builder: (BuildContext context) {
              return ElevatedButton(
                onPressed: () {
                  WithdrawBottomSheet.show(
                    context: context,
                    onWithdraw: (amount) {},
                  );
                },
                child: const Text('Show Bottom Sheet'),
              );
            },
          ),
        ),
      ));

      await tester.tap(find.text('Show Bottom Sheet'));
      await tester.pumpAndSettle();

      expect(find.text('How much would you like to withdraw?'), findsOneWidget);
      expect(find.text('Amount in KSh'), findsOneWidget);
      expect(find.text('Confirm Withdrawal'), findsOneWidget);
    });

    testWidgets('updates KSh conversion on amount input', (WidgetTester tester) async {
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: Builder(
            builder: (BuildContext context) {
              return ElevatedButton(
                onPressed: () {
                  WithdrawBottomSheet.show(
                    context: context,
                    onWithdraw: (amount) {},
                  );
                },
                child: const Text('Show Bottom Sheet'),
              );
            },
          ),
        ),
      ));

      await tester.tap(find.text('Show Bottom Sheet'));
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField), '10');
      await tester.pumpAndSettle();

      expect(find.textContaining('Tokens: 10.00 (1Tk = 1Ksh)'), findsOneWidget);
    });

    testWidgets('calls onWithdraw with correct amount and closes sheet on confirm', (WidgetTester tester) async {
      double? withdrawnAmount;

      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: Builder(
            builder: (BuildContext context) {
              return ElevatedButton(
                onPressed: () {
                  WithdrawBottomSheet.show(
                    context: context,
                    onWithdraw: (amount) {
                      withdrawnAmount = amount;
                    },
                  );
                },
                child: const Text('Show Bottom Sheet'),
              );
            },
          ),
        ),
      ));

      await tester.tap(find.text('Show Bottom Sheet'));
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField), '25');
      await tester.pumpAndSettle();

      await tester.tap(find.text('Confirm Withdrawal'));
      await tester.pumpAndSettle();

      expect(withdrawnAmount, 25.0);
      expect(find.text('How much would you like to withdraw?'), findsNothing); // Sheet should be closed
    });

    testWidgets('shows error for invalid amount and does not call onWithdraw', (WidgetTester tester) async {
      double? withdrawnAmount;

      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: Builder(
            builder: (BuildContext context) {
              return ElevatedButton(
                onPressed: () {
                  WithdrawBottomSheet.show(
                    context: context,
                    onWithdraw: (amount) {
                      withdrawnAmount = amount;
                    },
                  );
                },
                child: const Text('Show Bottom Sheet'),
              );
            },
          ),
        ),
      ));

      await tester.tap(find.text('Show Bottom Sheet'));
      await tester.pumpAndSettle();

      // Test with empty input
      await tester.enterText(find.byType(TextField), '');
      await tester.pumpAndSettle();
      await tester.tap(find.text('Confirm Withdrawal'));
      await tester.pumpAndSettle();
      expect(find.text('Please enter a valid amount'), findsOneWidget);
      expect(withdrawnAmount, isNull);

      // Test with zero input
      await tester.enterText(find.byType(TextField), '0');
      await tester.pumpAndSettle();
      await tester.tap(find.text('Confirm Withdrawal'));
      await tester.pumpAndSettle();
      expect(find.text('Please enter a valid amount'), findsOneWidget);
      expect(withdrawnAmount, isNull);

      // Test with negative input
      await tester.enterText(find.byType(TextField), '-5');
      await tester.pumpAndSettle();
      await tester.tap(find.text('Confirm Withdrawal'));
      await tester.pumpAndSettle();
      expect(find.text('Please enter a valid amount'), findsOneWidget);
      expect(withdrawnAmount, isNull);

      // Test with non-numeric input
      await tester.enterText(find.byType(TextField), 'abc');
      await tester.pumpAndSettle();
      await tester.tap(find.text('Confirm Withdrawal'));
      await tester.pumpAndSettle();
      expect(find.text('Please enter a valid amount'), findsOneWidget);
      expect(withdrawnAmount, isNull);
    });
  });
}