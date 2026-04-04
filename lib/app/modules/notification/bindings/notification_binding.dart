import 'package:get/get.dart';

import '../controllers/notification_controller.dart';

class NotificationBinding extends Bindings {
  @override
  void dependencies() {
    // NotificationController est déjà initialisé de manière permanente dans main.dart
    // On s'assure juste qu'il est enregistré ici pour la navigation
    // Si non trouvé (cas improbable), on le crée
    if (!Get.isRegistered<NotificationController>()) {
      Get.put<NotificationController>(
        NotificationController(),
        permanent: true,
      );
    }
  }
}
