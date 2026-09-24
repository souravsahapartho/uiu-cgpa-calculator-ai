import 'package:flutter_test/flutter_test.dart';
import 'package:uiu_cgpa_calculator_ai/main.dart';
import 'package:uiu_cgpa_calculator_ai/core/providers/user_profile_provider.dart';

void main() {
  testWidgets('App smoke test', (WidgetTester tester) async {
    final provider = UserProfileProvider();
    await tester.pumpWidget(UIUCGPACalculatorApp(profileProvider: provider));
    expect(find.byType(UIUCGPACalculatorApp), findsOneWidget);
  });
}
