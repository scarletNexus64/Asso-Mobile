import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';

import 'package:asso/app/modules/home/bindings/home_binding.dart';
import 'package:asso/app/modules/home/views/home_view.dart';

void main() {
  testWidgets('Home view smoke test', (WidgetTester tester) async {
    // Setup binding
    HomeBinding().dependencies();

    // Build our app and trigger a frame.
    await tester.pumpWidget(
      const GetMaterialApp(
        home: HomeView(),
      ),
    );

    // Verify that home view is rendered
    expect(find.text('HomeView is working'), findsOneWidget);
  });
}
