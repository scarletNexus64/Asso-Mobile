import 'package:get/get.dart';

import '../controllers/home_controller.dart';
import '../../search/controllers/search_controller.dart' as search;
import '../../chat/controllers/chat_controller.dart';
import '../../tracking/controllers/tracking_controller.dart';
import '../../profile/controllers/profile_controller.dart';

class HomeBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<HomeController>(
      () => HomeController(),
    );

    // Initialiser les controllers des onglets car leurs vues sont utilisées dans HomeView
    Get.lazyPut<search.SearchController>(
      () => search.SearchController(),
    );

    Get.lazyPut<ChatController>(
      () => ChatController(),
    );

    Get.lazyPut<TrackingController>(
      () => TrackingController(),
    );

    Get.lazyPut<ProfileController>(
      () => ProfileController(),
    );
  }
}
