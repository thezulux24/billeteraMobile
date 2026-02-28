import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/shared/widgets/wallet_style_header.dart';

void main() {
  testWidgets('renders leading, two actions and default padding', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: WalletStyleHeader(
            leading: const Text('Header Leading'),
            actions: [
              WalletHeaderActionButton(
                icon: Icons.search_rounded,
                semanticLabel: 'Search',
                onPressed: () {},
              ),
              WalletHeaderActionButton(
                icon: Icons.notifications_none_rounded,
                semanticLabel: 'Notifications',
                onPressed: () {},
              ),
            ],
          ),
        ),
      ),
    );

    expect(find.text('Header Leading'), findsOneWidget);
    expect(find.byType(WalletHeaderActionButton), findsNWidgets(2));

    final paddingFinder = find.descendant(
      of: find.byType(WalletStyleHeader),
      matching: find.byType(Padding),
    );
    final headerPadding = tester.widget<Padding>(paddingFinder.first);

    expect(
      headerPadding.padding,
      const EdgeInsets.only(top: 60, left: 24, right: 24, bottom: 16),
    );
  });
}
