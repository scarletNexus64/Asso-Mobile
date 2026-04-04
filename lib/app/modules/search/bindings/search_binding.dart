import 'package:get/get.dart';

import '../controllers/search_controller.dart' as search_ctrl;

class SearchBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<search_ctrl.SearchController>(
      () => search_ctrl.SearchController(),
    );
  }
}
