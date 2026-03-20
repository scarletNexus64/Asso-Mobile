import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:get/get.dart';
import '../../../core/utils/app_theme_system.dart';
import '../../../routes/app_pages.dart';

class SplashView extends StatefulWidget {
  const SplashView({super.key});

  @override
  State<SplashView> createState() => _SplashViewState();
}

class _SplashViewState extends State<SplashView> {
  @override
  void initState() {
    super.initState();
    // Navigation après 3 secondes
    Timer(const Duration(seconds: 3), () {
      if (mounted) {
        Get.offAllNamed(Routes.ONBOARDING);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppThemeSystem.getBackgroundColor(context),
      body: SizedBox(
        width: double.infinity,
        height: double.infinity,
        child: Stack(
          children: [
            // Cercles décoratifs en arrière-plan
            Positioned(
              top: -100,
              right: -100,
              child: TweenAnimationBuilder(
                duration: const Duration(milliseconds: 1500),
                tween: Tween<double>(begin: 0, end: 1),
                builder: (context, double value, child) {
                  return Opacity(
                    opacity: (value * 0.1).clamp(0.0, 1.0),
                    child: Container(
                      width: 300,
                      height: 300,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppThemeSystem.primaryColor,
                      ),
                    ),
                  );
                },
              ),
            ),
            Positioned(
              bottom: -150,
              left: -150,
              child: TweenAnimationBuilder(
                duration: const Duration(milliseconds: 1500),
                tween: Tween<double>(begin: 0, end: 1),
                builder: (context, double value, child) {
                  return Opacity(
                    opacity: (value * 0.08).clamp(0.0, 1.0),
                    child: Container(
                      width: 400,
                      height: 400,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppThemeSystem.tertiaryColor,
                      ),
                    ),
                  );
                },
              ),
            ),

            // Contenu principal
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Logo animé dans un cercle
                  TweenAnimationBuilder(
                    duration: const Duration(milliseconds: 1200),
                    tween: Tween<double>(begin: 0, end: 1),
                    curve: Curves.elasticOut,
                    builder: (context, double value, child) {
                      return Transform.scale(
                        scale: value,
                        child: Opacity(
                          opacity: value.clamp(0.0, 1.0),
                          child: Container(
                            width: 200,
                            height: 200,
                            padding: const EdgeInsets.all(30),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: AppThemeSystem.primaryColor.withValues(alpha: 0.3),
                                  blurRadius: 40,
                                  offset: const Offset(0, 20),
                                ),
                              ],
                            ),
                            child: ClipOval(
                              child: Image.asset(
                                'assets/images/logo.png',
                                fit: BoxFit.contain,
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),

                  const SizedBox(height: 50),

                  // Nom de l'app avec animation
                  TweenAnimationBuilder(
                    duration: const Duration(milliseconds: 1500),
                    tween: Tween<double>(begin: 0, end: 1),
                    curve: Curves.easeOut,
                    builder: (context, double value, child) {
                      return Opacity(
                        opacity: value.clamp(0.0, 1.0),
                        child: Transform.translate(
                          offset: Offset(0, 30 * (1 - value)),
                          child: Column(
                            children: [
                              Text(
                                'ASSO',
                                style: TextStyle(
                                  fontSize: AppThemeSystem.getFontSize(context, FontSizeType.h1),
                                  fontWeight: FontWeight.bold,
                                  color: AppThemeSystem.getPrimaryTextColor(context),
                                  letterSpacing: 6,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Container(
                                width: 60,
                                height: 4,
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      AppThemeSystem.primaryColor,
                                      AppThemeSystem.tertiaryColor,
                                    ],
                                  ),
                                  borderRadius: BorderRadius.circular(2),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),

                  const SizedBox(height: 16),

                  // Tagline
                  TweenAnimationBuilder(
                    duration: const Duration(milliseconds: 2000),
                    tween: Tween<double>(begin: 0, end: 1),
                    curve: Curves.easeOut,
                    builder: (context, double value, child) {
                      return Opacity(
                        opacity: value.clamp(0.0, 1.0),
                        child: Text(
                          'Votre Marketplace de Confiance',
                          style: TextStyle(
                            fontSize: AppThemeSystem.getFontSize(context, FontSizeType.subtitle1),
                            color: AppThemeSystem.getSecondaryTextColor(context),
                            letterSpacing: 0.5,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      );
                    },
                  ),

                  const SizedBox(height: 80),

                  // Loading indicator moderne avec flutter_spinkit
                  TweenAnimationBuilder(
                    duration: const Duration(milliseconds: 2200),
                    tween: Tween<double>(begin: 0, end: 1),
                    builder: (context, double value, child) {
                      return Opacity(
                        opacity: value.clamp(0.0, 1.0),
                        child: SpinKitThreeBounce(
                          color: AppThemeSystem.primaryColor,
                          size: 40.0,
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
