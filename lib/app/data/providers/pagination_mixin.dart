import 'package:get/get.dart';

/// Mixin for controllers that need pagination support
mixin PaginationMixin on GetxController {
  final RxBool isLoading = false.obs;
  final RxBool isLoadingMore = false.obs;
  final RxBool hasMore = true.obs;
  final RxInt currentPage = 1.obs;
  final int perPage = 20;

  /// Reset pagination state
  void resetPagination() {
    currentPage.value = 1;
    hasMore.value = true;
    isLoading.value = false;
    isLoadingMore.value = false;
  }

  /// Update pagination state from API response
  void updatePaginationState(Map<String, dynamic>? pagination) {
    if (pagination != null) {
      hasMore.value = pagination['has_more'] ?? false;
      currentPage.value = pagination['current_page'] ?? currentPage.value;
    }
  }

  /// Check if can load more
  bool get canLoadMore => !isLoadingMore.value && hasMore.value;

  /// Increment page
  void nextPage() {
    currentPage.value++;
  }
}
