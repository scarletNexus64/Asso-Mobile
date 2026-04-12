import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/utils/app_theme_system.dart';

class PaymentLoadingDialog extends StatefulWidget {
  final String message;

  const PaymentLoadingDialog({
    super.key,
    this.message = 'Traitement du paiement en cours...',
  });

  static void show({String? message}) {
    Get.dialog(
      PaymentLoadingDialog(
        message: message ?? 'Traitement du paiement en cours...',
      ),
      barrierDismissible: false,
    );
  }

  static void hide() {
    if (Get.isDialogOpen ?? false) {
      Get.back();
    }
  }

  @override
  State<PaymentLoadingDialog> createState() => _PaymentLoadingDialogState();
}

class _PaymentLoadingDialogState extends State<PaymentLoadingDialog>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 0.9, end: 1.1).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOut,
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          color: context.surfaceColor,
          borderRadius: BorderRadius.circular(24),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Animated loading indicator
            ScaleTransition(
              scale: _pulseAnimation,
              child: Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: AppThemeSystem.primaryColor.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // Rotating outer circle
                    RotationTransition(
                      turns: _controller,
                      child: Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: AppThemeSystem.primaryColor.withValues(alpha: 0.3),
                            width: 3,
                          ),
                          gradient: SweepGradient(
                            colors: [
                              AppThemeSystem.primaryColor.withValues(alpha: 0.1),
                              AppThemeSystem.primaryColor,
                            ],
                            stops: const [0.0, 1.0],
                          ),
                        ),
                      ),
                    ),
                    // Center icon
                    Icon(
                      Icons.credit_card_rounded,
                      color: AppThemeSystem.primaryColor,
                      size: 36,
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Loading dots animation
            _buildLoadingDots(),

            const SizedBox(height: 16),

            // Message
            Text(
              widget.message,
              style: context.body1.copyWith(
                fontWeight: FontWeight.w600,
                color: context.primaryTextColor,
              ),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 8),

            // Subtitle
            Text(
              'Veuillez patienter',
              style: context.body2.copyWith(
                color: context.secondaryTextColor,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingDots() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(3, (index) {
        return TweenAnimationBuilder<double>(
          duration: const Duration(milliseconds: 600),
          tween: Tween(begin: 0.0, end: 1.0),
          onEnd: () {
            setState(() {}); // Trigger rebuild to restart animation
          },
          builder: (context, value, child) {
            final delay = index * 0.2;
            final animValue = (value - delay).clamp(0.0, 1.0);
            final scale = (1.0 + (0.5 * animValue)).clamp(1.0, 1.5);

            return Transform.scale(
              scale: scale,
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 4),
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: AppThemeSystem.primaryColor.withValues(
                    alpha: 0.3 + (0.7 * animValue),
                  ),
                  shape: BoxShape.circle,
                ),
              ),
            );
          },
        );
      }),
    );
  }
}
