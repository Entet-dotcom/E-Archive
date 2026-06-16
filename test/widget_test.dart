import 'package:flutter_test/flutter_test.dart';

import 'package:e_archive/src/app.dart';

void main() {
  testWidgets('renders login landing page', (WidgetTester tester) async {
    await tester.pumpWidget(const EArchiveApp());
    await tester.pumpAndSettle();

    expect(find.text('Student records,'), findsOneWidget);
    expect(find.text('Administrator'), findsOneWidget);
    expect(find.text('Staff'), findsOneWidget);
  });
}
