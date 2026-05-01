import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:omnom/widgets/list_card_actions.dart';

Widget _wrap(Widget child) => MaterialApp(home: Scaffold(body: child));

void main() {
  setUp(() {
    GoogleFonts.config.allowRuntimeFetching = false;
  });

  testWidgets('swipe-to-delete fires onDelete when confirm dialog accepted',
      (tester) async {
    var deleted = false;
    await tester.pumpWidget(
      _wrap(
        ListView(
          children: [
            ListCardActions(
              itemKey: const ValueKey('item-1'),
              title: 'Mushroom Risotto',
              kind: 'entry',
              onDelete: () => deleted = true,
              child: const SizedBox(
                height: 80,
                child: Center(child: Text('row content')),
              ),
            ),
          ],
        ),
      ),
    );
    await tester.pump();

    // Swipe the row right-to-left to trigger Dismissible.
    await tester.fling(
      find.text('row content'),
      const Offset(-500, 0),
      1000,
    );
    await tester.pumpAndSettle();

    // Confirm dialog appears.
    expect(find.text('Delete this entry?'), findsOneWidget);
    await tester.tap(find.widgetWithText(TextButton, 'Delete'));
    await tester.pumpAndSettle();

    expect(deleted, isTrue);
  });

  testWidgets('Cancel in confirm dialog leaves the row in place',
      (tester) async {
    var deleted = false;
    await tester.pumpWidget(
      _wrap(
        ListView(
          children: [
            ListCardActions(
              itemKey: const ValueKey('item-2'),
              title: 'Shakshuka',
              kind: 'entry',
              onDelete: () => deleted = true,
              child: const SizedBox(
                height: 80,
                child: Center(child: Text('shakshuka row')),
              ),
            ),
          ],
        ),
      ),
    );
    await tester.pump();

    await tester.fling(
      find.text('shakshuka row'),
      const Offset(-500, 0),
      1000,
    );
    await tester.pumpAndSettle();

    expect(find.text('Delete this entry?'), findsOneWidget);
    await tester.tap(find.widgetWithText(TextButton, 'Cancel'));
    await tester.pumpAndSettle();

    expect(deleted, isFalse);
    expect(find.text('shakshuka row'), findsOneWidget);
  });
}
