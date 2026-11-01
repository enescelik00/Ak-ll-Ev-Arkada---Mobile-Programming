import 'package:flutter_test/flutter_test.dart';

import 'package:cotab/main.dart';

void main() {
  testWidgets('Home screen shows the welcome text', (tester) async {
    await tester.pumpWidget(const CoTabApp());
    await tester.pumpAndSettle();

    expect(find.text('Welcome to CoTab!'), findsOneWidget);
    expect(find.text('You are not in any group yet.'), findsOneWidget);
  });
}
