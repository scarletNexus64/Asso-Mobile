import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import '../../../core/utils/app_theme_system.dart';

class VendorDashboardShimmer extends StatelessWidget {
  const VendorDashboardShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: const NeverScrollableScrollPhysics(),
      padding: EdgeInsets.only(
        left: context.horizontalPadding,
        right: context.horizontalPadding,
        top: context.horizontalPadding,
        bottom: MediaQuery.of(context).viewPadding.bottom > 0
            ? MediaQuery.of(context).viewPadding.bottom + context.horizontalPadding
            : context.horizontalPadding * 1.5,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Shop Header Shimmer
          _buildShopHeaderShimmer(context),

          SizedBox(height: context.sectionSpacing),

          // Statistics Section Shimmer
          _buildStatsSectionShimmer(context),

          SizedBox(height: context.sectionSpacing),

          // Package Section Shimmer
          _buildPackageSectionShimmer(context),

          SizedBox(height: context.sectionSpacing),

          // Quick Actions Shimmer
          _buildQuickActionsShimmer(context),
        ],
      ),
    );
  }

  /// Shop Header Shimmer
  Widget _buildShopHeaderShimmer(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: context.isDarkMode ? Colors.grey[800]! : Colors.grey[300]!,
      highlightColor: context.isDarkMode ? Colors.grey[700]! : Colors.grey[100]!,
      child: Container(
        padding: EdgeInsets.all(context.horizontalPadding),
        decoration: BoxDecoration(
          color: context.surfaceColor,
          borderRadius: context.borderRadius(BorderRadiusType.medium),
          border: Border.all(
            color: context.borderColor,
            width: 1,
          ),
        ),
        child: Row(
          children: [
            // Logo placeholder
            Container(
              width: context.deviceType == DeviceType.mobile ? 70 : 90,
              height: context.deviceType == DeviceType.mobile ? 70 : 90,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: context.borderRadius(BorderRadiusType.medium),
              ),
            ),
            SizedBox(width: 16),
            // Text placeholders
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: double.infinity,
                    height: 20,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  SizedBox(height: 8),
                  Container(
                    width: 100,
                    height: 14,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Statistics Section Shimmer
  Widget _buildStatsSectionShimmer(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Title
        Shimmer.fromColors(
          baseColor: context.isDarkMode ? Colors.grey[800]! : Colors.grey[300]!,
          highlightColor: context.isDarkMode ? Colors.grey[700]! : Colors.grey[100]!,
          child: Container(
            width: 150,
            height: 24,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
        ),
        SizedBox(height: context.elementSpacing),

        // Stats cards row 1
        Row(
          children: [
            Expanded(child: _buildStatCardShimmer(context)),
            SizedBox(width: AppThemeSystem.getAdaptiveSpacing(context, baseSpacing: 12)),
            Expanded(child: _buildStatCardShimmer(context)),
          ],
        ),
        SizedBox(height: AppThemeSystem.getAdaptiveSpacing(context, baseSpacing: 12)),

        // Stats cards row 2
        Row(
          children: [
            Expanded(child: _buildStatCardShimmer(context)),
            SizedBox(width: AppThemeSystem.getAdaptiveSpacing(context, baseSpacing: 12)),
            Expanded(child: _buildStatCardShimmer(context)),
          ],
        ),
      ],
    );
  }

  /// Single Stat Card Shimmer
  Widget _buildStatCardShimmer(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: context.isDarkMode ? Colors.grey[800]! : Colors.grey[300]!,
      highlightColor: context.isDarkMode ? Colors.grey[700]! : Colors.grey[100]!,
      child: Container(
        padding: EdgeInsets.all(context.horizontalPadding * 0.75),
        decoration: BoxDecoration(
          color: context.surfaceColor,
          borderRadius: context.borderRadius(BorderRadiusType.medium),
          border: Border.all(
            color: context.borderColor,
            width: 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Icon placeholder
            Container(
              width: context.deviceType == DeviceType.mobile ? 24 : 32,
              height: context.deviceType == DeviceType.mobile ? 24 : 32,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            SizedBox(height: AppThemeSystem.getAdaptiveSpacing(context, baseSpacing: 12)),

            // Value placeholder
            Container(
              width: 80,
              height: 28,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            SizedBox(height: 4),

            // Title placeholder
            Container(
              width: 60,
              height: 12,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Package Section Shimmer
  Widget _buildPackageSectionShimmer(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Title
        Shimmer.fromColors(
          baseColor: context.isDarkMode ? Colors.grey[800]! : Colors.grey[300]!,
          highlightColor: context.isDarkMode ? Colors.grey[700]! : Colors.grey[100]!,
          child: Container(
            width: 120,
            height: 24,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
        ),
        SizedBox(height: context.elementSpacing),

        // Package card
        Shimmer.fromColors(
          baseColor: context.isDarkMode ? Colors.grey[800]! : Colors.grey[300]!,
          highlightColor: context.isDarkMode ? Colors.grey[700]! : Colors.grey[100]!,
          child: Container(
            padding: EdgeInsets.all(context.horizontalPadding),
            decoration: BoxDecoration(
              color: context.surfaceColor,
              borderRadius: context.borderRadius(BorderRadiusType.large),
              border: Border.all(
                color: context.borderColor,
                width: 2,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header row
                Row(
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: double.infinity,
                            height: 20,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                          SizedBox(height: 4),
                          Container(
                            width: 80,
                            height: 14,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      width: 60,
                      height: 24,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: context.elementSpacing),

                // Divider
                Container(
                  height: 1,
                  color: Colors.white,
                ),
                SizedBox(height: context.elementSpacing),

                // Progress bar section
                Container(
                  width: 150,
                  height: 14,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                SizedBox(height: 8),
                Container(
                  width: double.infinity,
                  height: 14,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      width: 100,
                      height: 14,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    Container(
                      width: 60,
                      height: 14,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: context.elementSpacing),

                // Button placeholder
                Container(
                  width: double.infinity,
                  height: 48,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: context.borderRadius(BorderRadiusType.medium),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  /// Quick Actions Shimmer
  Widget _buildQuickActionsShimmer(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Title
        Shimmer.fromColors(
          baseColor: context.isDarkMode ? Colors.grey[800]! : Colors.grey[300]!,
          highlightColor: context.isDarkMode ? Colors.grey[700]! : Colors.grey[100]!,
          child: Container(
            width: 150,
            height: 24,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
        ),
        SizedBox(height: context.elementSpacing),

        // Action buttons
        _buildActionButtonShimmer(context),
        SizedBox(height: AppThemeSystem.getAdaptiveSpacing(context, baseSpacing: 12)),
        _buildActionButtonShimmer(context),
        SizedBox(height: AppThemeSystem.getAdaptiveSpacing(context, baseSpacing: 12)),
        _buildActionButtonShimmer(context),
      ],
    );
  }

  /// Single Action Button Shimmer
  Widget _buildActionButtonShimmer(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: context.isDarkMode ? Colors.grey[800]! : Colors.grey[300]!,
      highlightColor: context.isDarkMode ? Colors.grey[700]! : Colors.grey[100]!,
      child: Container(
        padding: EdgeInsets.all(context.horizontalPadding),
        decoration: BoxDecoration(
          color: context.surfaceColor,
          borderRadius: context.borderRadius(BorderRadiusType.medium),
          border: Border.all(
            color: context.borderColor,
            width: 1,
          ),
        ),
        child: Row(
          children: [
            // Icon placeholder
            Container(
              width: context.deviceType == DeviceType.mobile ? 48 : 64,
              height: context.deviceType == DeviceType.mobile ? 48 : 64,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: context.borderRadius(BorderRadiusType.small),
              ),
            ),
            SizedBox(width: context.elementSpacing),

            // Text placeholders
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: double.infinity,
                    height: 16,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  SizedBox(height: 4),
                  Container(
                    width: 150,
                    height: 12,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ],
              ),
            ),

            // Chevron placeholder
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
