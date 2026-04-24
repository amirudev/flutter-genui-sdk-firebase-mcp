import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_genui_sdk_firebase_mcp/main.dart';

void main() {
  testWidgets('App loads smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const AirbnbShoppingApp());

    // Verify that the Explore tab is present.
    expect(find.text('Explore'), findsOneWidget);
  });
}
