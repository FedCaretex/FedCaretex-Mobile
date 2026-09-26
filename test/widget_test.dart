import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:smartwealth_mobile/main.dart';

void main() {
  testWidgets('Smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const ProviderScope(child: SmartWealthApp()));
    expect(find.text('SmartWealth AI'), findsNothing);
  });
}
