import 'package:flutter_test/flutter_test.dart';
import 'package:uiu_cgpa_calculator_ai/main.dart';

void main() {
  testWidgets('App smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const UIUCGPACalculatorApp());
    expect(find.byType(UIUCGPACalculatorApp), findsOneWidget);
  });
}
