import 'package:asso/app/core/utils/app_feedback.dart';
import 'package:asso/app/data/providers/api_validation_exception.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';

void main() {
  tearDown(Get.reset);

  testWidgets(
    'duplicate failures share one notification and can be retried after dismissal',
    (tester) async {
      await tester.pumpWidget(const GetMaterialApp(home: Scaffold()));
      final first = AppFeedback.show('Erreur', 'Échec de la réservation');
      final duplicate = AppFeedback.show('Erreur', 'Échec de la réservation');
      expect(identical(first, duplicate), isTrue);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));
      expect(find.text('Échec de la réservation'), findsOneWidget);
      first.close();
      await tester.pumpAndSettle();
      final retry = AppFeedback.show('Erreur', 'Échec de la réservation');
      expect(identical(first, retry), isFalse);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));
      expect(find.text('Échec de la réservation'), findsOneWidget);
      retry.close();
      await tester.pumpAndSettle();
    },
  );

  test('errorMessage keeps app messages and hides technical errors', () {
    expect(AppFeedback.errorMessage(Exception('Paiement refusé')), 'Paiement refusé');
    expect(
      AppFeedback.errorMessage(ApiValidationException('Code invalide', {})),
      'Code invalide',
    );
    expect(
      AppFeedback.errorMessage(const FormatException('Unexpected <html>')),
      'common.generic_error_retry'.tr,
    );
    expect(
      AppFeedback.errorMessage(TypeError()),
      'common.generic_error_retry'.tr,
    );
    expect(AppFeedback.errorMessage(Exception('')), 'common.generic_error_retry'.tr);
  });
}
