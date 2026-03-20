import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/utils/app_theme_system.dart';
import '../controllers/onboarding_controller.dart';

class OnboardingView extends GetView<OnboardingController> {
  const OnboardingView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppThemeSystem.getBackgroundColor(context),
      body: SafeArea(
        child: Column(
          children: [
            // Skip button
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: AppThemeSystem.getHorizontalPadding(context),
                vertical: 16,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: controller.skipOnboarding,
                    child: Text(
                      'Passer',
                      style: context.textStyle(
                        FontSizeType.button,
                        color: AppThemeSystem.primaryColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // PageView
            Expanded(
              child: PageView(
                controller: controller.pageController,
                children: [
                  _buildOnboardingPage(
                    context,
                    icon: Icons.shopping_bag_rounded,
                    title: 'Découvrez des Produits Incroyables',
                    description: 'Parcourez des milliers de produits de vendeurs locaux et trouvez exactement ce dont vous avez besoin.',
                  ),
                  _buildOnboardingPage(
                    context,
                    icon: Icons.local_shipping_rounded,
                    title: 'Livraison Rapide et Sécurisée',
                    description: 'Recevez vos commandes rapidement et en toute sécurité à votre porte.',
                  ),
                  _buildOnboardingPage(
                    context,
                    icon: Icons.verified_user_rounded,
                    title: 'Sûr et Fiable',
                    description: 'Achetez en toute confiance. Toutes les transactions sont sécurisées et protégées.',
                  ),
                ],
              ),
            ),

            // Page indicators and button
            Padding(
              padding: EdgeInsets.all(AppThemeSystem.getHorizontalPadding(context)),
              child: Column(
                children: [
                  // Dots indicator
                  Obx(() => Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      controller.totalPages,
                      (index) => _buildDot(context, index),
                    ),
                  )),
                  SizedBox(height: AppThemeSystem.getSectionSpacing(context)),

                  // Next/Get Started button
                  Obx(() => SizedBox(
                    width: double.infinity,
                    height: AppThemeSystem.getButtonHeight(context),
                    child: ElevatedButton(
                      onPressed: controller.nextPage,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppThemeSystem.primaryColor,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: context.borderRadius(BorderRadiusType.medium),
                        ),
                      ),
                      child: Text(
                        controller.currentPage.value == controller.totalPages - 1
                            ? 'Commencer'
                            : 'Suivant',
                        style: context.textStyle(
                          FontSizeType.button,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  )),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOnboardingPage(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String description,
  }) {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: AppThemeSystem.getHorizontalPadding(context),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Icon
          Container(
            width: 140,
            height: 140,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  AppThemeSystem.primaryColor,
                  AppThemeSystem.tertiaryColor,
                ],
              ),
              borderRadius: BorderRadius.circular(40),
              boxShadow: [
                BoxShadow(
                  color: AppThemeSystem.primaryColor.withValues(alpha: 0.3),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Icon(
              icon,
              size: 70,
              color: Colors.white,
            ),
          ),
          SizedBox(height: AppThemeSystem.getSectionSpacing(context)),

          // Title
          Text(
            title,
            textAlign: TextAlign.center,
            style: context.textStyle(
              FontSizeType.h3,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: AppThemeSystem.getElementSpacing(context)),

          // Description
          Text(
            description,
            textAlign: TextAlign.center,
            style: context.textStyle(
              FontSizeType.body1,
              color: context.secondaryTextColor,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDot(BuildContext context, int index) {
    final isActive = controller.currentPage.value == index;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: const EdgeInsets.symmetric(horizontal: 4),
      height: 8,
      width: isActive ? 24 : 8,
      decoration: BoxDecoration(
        color: isActive
          ? AppThemeSystem.primaryColor
          : AppThemeSystem.grey300,
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }
}
