import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'dart:async';

/// Mixin to prevent using controllers (PageController, ScrollController, etc.)
/// after they have been disposed.
///
/// This prevents the common error: "A PageController was used after being disposed"
///
/// Usage:
/// ```dart
/// class MyController extends GetxController with SafeControllerMixin {
///   final PageController pageController = PageController();
///
///   @override
///   void onClose() {
///     markAsDisposed(); // Call this BEFORE disposing controllers
///     pageController.dispose();
///     super.onClose();
///   }
///
///   void someMethod() {
///     safeExecute(() {
///       if (pageController.hasClients) {
///         pageController.animateToPage(...);
///       }
///     });
///   }
/// }
/// ```
mixin SafeControllerMixin on GetxController {
  bool _isSafelyDisposed = false;

  /// Check if the controller has been disposed
  bool get isDisposed => _isSafelyDisposed;

  /// Mark controller as disposed. Call this in onClose() BEFORE disposing controllers.
  void markAsDisposed() {
    _isSafelyDisposed = true;
  }

  /// Safely execute a function only if the controller is not disposed
  void safeExecute(VoidCallback callback) {
    if (!_isSafelyDisposed) {
      try {
        callback();
      } catch (e) {
        // Silently catch errors to prevent crashes
        debugPrint('SafeControllerMixin: Error caught during safe execution: $e');
      }
    }
  }

  /// Safely execute an async function only if the controller is not disposed
  Future<void> safeExecuteAsync(Future<void> Function() callback) async {
    if (!_isSafelyDisposed) {
      try {
        await callback();
      } catch (e) {
        // Silently catch errors to prevent crashes
        debugPrint('SafeControllerMixin: Error caught during safe async execution: $e');
      }
    }
  }

  /// Safely execute a delayed function, checking disposal before and after delay
  Future<void> safeDelayed(
    Duration duration,
    VoidCallback callback,
  ) async {
    if (_isSafelyDisposed) return;

    await Future.delayed(duration);

    if (_isSafelyDisposed) return;

    try {
      callback();
    } catch (e) {
      debugPrint('SafeControllerMixin: Error caught during safe delayed execution: $e');
    }
  }

  /// Safely animate a PageController
  Future<void> safeAnimateToPage(
    PageController controller,
    int page, {
    Duration duration = const Duration(milliseconds: 300),
    Curve curve = Curves.easeInOut,
  }) async {
    if (_isSafelyDisposed || !controller.hasClients) return;

    try {
      await controller.animateToPage(
        page,
        duration: duration,
        curve: curve,
      );
    } catch (e) {
      debugPrint('SafeControllerMixin: Error during page animation: $e');
    }
  }

  /// Safely animate a ScrollController
  Future<void> safeAnimateTo(
    ScrollController controller,
    double offset, {
    Duration duration = const Duration(milliseconds: 300),
    Curve curve = Curves.easeOut,
  }) async {
    if (_isSafelyDisposed || !controller.hasClients) return;

    try {
      await controller.animateTo(
        offset,
        duration: duration,
        curve: curve,
      );
    } catch (e) {
      debugPrint('SafeControllerMixin: Error during scroll animation: $e');
    }
  }

  /// Safely jump to a page without animation
  void safeJumpToPage(PageController controller, int page) {
    if (_isSafelyDisposed || !controller.hasClients) return;

    try {
      controller.jumpToPage(page);
    } catch (e) {
      debugPrint('SafeControllerMixin: Error during page jump: $e');
    }
  }

  /// Safely jump to a scroll position without animation
  void safeJumpTo(ScrollController controller, double offset) {
    if (_isSafelyDisposed || !controller.hasClients) return;

    try {
      controller.jumpTo(offset);
    } catch (e) {
      debugPrint('SafeControllerMixin: Error during scroll jump: $e');
    }
  }
}
