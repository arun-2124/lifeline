import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_app/main.dart';

void main() {
  testWidgets('App renders splash screen initially', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(
      const ProviderScope(
        child: LifelineApp(),
      ),
    );

    // Verify that the Lifeline title is displayed on splash screen
    expect(find.text('Lifeline'), findsOneWidget);
  });
}
