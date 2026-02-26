import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:mobile/app.dart';

void main() {
  testWidgets('renders splash while app initializes', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const ProviderScope(child: BilleteraApp()));

    expect(find.text('billeteraMobile'), findsOneWidget);
  });
}
