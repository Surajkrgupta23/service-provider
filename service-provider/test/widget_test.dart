import 'package:flutter_test/flutter_test.dart';
import 'package:cp_provider_app/main.dart';

void main() {
  testWidgets('App smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const CooperativeClapApp(isLoggedIn: false));
  });
}
