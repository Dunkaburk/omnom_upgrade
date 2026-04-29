import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:omnom/widgets/text_field.dart';

void main() {
  setUp(() {
    GoogleFonts.config.allowRuntimeFetching = false;
  });

  testWidgets('OmnomTextField writes typed input into its controller',
      (tester) async {
    final controller = TextEditingController();
    addTearDown(controller.dispose);

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: OmnomTextField(
            controller: controller,
            placeholder: 'hint',
          ),
        ),
      ),
    );

    await tester.enterText(find.byType(TextField), 'hello');
    expect(controller.text, 'hello');
  });

  testWidgets('OmnomTextField renders prefix and suffix when set',
      (tester) async {
    final controller = TextEditingController();
    addTearDown(controller.dispose);

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: OmnomTextField(
            controller: controller,
            placeholder: 'hint',
            prefix: '£',
            suffix: 'min',
          ),
        ),
      ),
    );

    expect(find.text('£'), findsOneWidget);
    expect(find.text('min'), findsOneWidget);
  });
}
