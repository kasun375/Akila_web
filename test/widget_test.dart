import 'package:flutter_test/flutter_test.dart';
import 'package:akila_maths_lms/main.dart';

void main() {
  testWidgets('LMS App Smoke Test', (WidgetTester tester) async {
    await tester.pumpWidget(const AkilaMathsLmsApp());
    expect(find.text('AKILA JAYAWEERA'), findsWidgets);
  });
}
