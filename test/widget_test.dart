import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:crm_app/main.dart';
import 'package:crm_app/rootdecor_page.dart';

void main() {
  testWidgets("App loads RootDecider screen", (WidgetTester tester) async {
    await tester.pumpWidget(
      ProviderScope(
        child: CrmApp(),
      ),
    );

    // Check if RootDecider is loaded
    expect(find.byType(RootDecider), findsOneWidget);
  });
}