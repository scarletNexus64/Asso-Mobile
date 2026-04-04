import 'package:get/get.dart';

import '../controllers/home_controller.dart';
import '../../chat/controllers/chat_controller.dart';
import '../../tracking/controllers/tracking_controller.dart';
import '../../profile/controllers/profile_controller.dart';
import '../../wallet/controllers/wallet_controller.dart';
import '../../../data/services/wallet_service.dart';

class HomeBinding extends Bindings {
  @override
  void dependencies() {
    print('');
    print('========================================');
    print('🔧 HOME BINDING: dependencies() CALLED');
    print('========================================');

    // Initialiser les services nécessaires d'abord
    Get.lazyPut<WalletService>(() => WalletService());

    // Créer les controllers des onglets AVANT HomeController
    // Utiliser put() au lieu de lazyPut() pour créer immédiatement
    // car TabBarView a besoin d'eux dès le premier build
    Get.put<ChatController>(
      ChatController(),
      permanent: false,
    );
    print('  └─ ✅ ChatController created');

    Get.put<WalletController>(
      WalletController(),
      permanent: false,
    );
    print('  └─ ✅ WalletController created');

    Get.put<TrackingController>(
      TrackingController(),
      permanent: false,
    );
    print('  └─ ✅ TrackingController created');

    Get.put<ProfileController>(
      ProfileController(),
      permanent: false,
    );
    print('  └─ ✅ ProfileController created');

    // Créer HomeController en dernier
    Get.put<HomeController>(
      HomeController(),
      permanent: false,
    );
    print('  └─ ✅ HomeController created');

    print('✅ HOME BINDING: All dependencies registered');
    print('========================================');
    print('');
  }
}
