import 'package:flutter_test/flutter_test.dart';
import 'package:prompt_mixer/main.dart';

void main() {
  testWidgets('App loads successfully', (WidgetTester tester) async {
    await tester.pumpWidget(const PromptMixerApp());
    await tester.pumpAndSettle();

    // Verify app title is displayed
    expect(find.text('Prompt Mixer'), findsOneWidget);
  });
}
