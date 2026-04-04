import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../../core/utils/app_theme_system.dart';
import '../controllers/package_subscription_controller.dart';

class PackageSubscriptionView extends GetView<PackageSubscriptionController> {
  const PackageSubscriptionView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.backgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios,
            color: context.primaryTextColor,
          ),
          onPressed: () => Get.back(),
        ),
        title: Text(
          'Choisir un package de stockage',
          style: context.h5.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: Obx(() {
        if (controller.isLoading.value && controller.packages.isEmpty) {
          return const Center(
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(
                AppThemeSystem.primaryColor,
              ),
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: controller.refreshPackages,
          color: AppThemeSystem.primaryColor,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: EdgeInsets.all(context.horizontalPadding),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Current Package Section (if exists)
                if (controller.hasPackage.value) ...[
                  _buildCurrentPackageSection(context),
                  SizedBox(height: context.sectionSpacing),
                ],

                // Available Packages Title
                Text(
                  controller.hasPackage.value
                      ? 'Packages disponibles'
                      : 'Choisissez votre package',
                  style: context.h5.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: context.elementSpacing),

                // Packages Grid
                if (controller.packages.isEmpty)
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.all(32.0),
                      child: Text(
                        'Aucun package disponible',
                        style: context.body1.copyWith(
                          color: context.secondaryTextColor,
                        ),
                      ),
                    ),
                  )
                else
                  _buildPackagesGrid(context),
              ],
            ),
          ),
        );
      }),
    );
  }

  /// Build current package section
  Widget _buildCurrentPackageSection(BuildContext context) {
    final vendorPackage = controller.currentVendorPackage.value;
    if (vendorPackage == null) return const SizedBox.shrink();

    final storageTotalMb = (vendorPackage['storage_total_mb'] ?? 0).toDouble();
    final storageUsedMb = (vendorPackage['storage_used_mb'] ?? 0).toDouble();
    final storageRemainingMb = (vendorPackage['storage_remaining_mb'] ?? 0).toDouble();
    final storagePercentageUsed = (vendorPackage['storage_percentage_used'] ?? 0).toDouble();
    final daysRemaining = vendorPackage['days_remaining'] ?? 0;
    final packageData = vendorPackage['package'];

    return Container(
      padding: EdgeInsets.all(context.horizontalPadding),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppThemeSystem.primaryColor.withValues(alpha: 0.1),
            AppThemeSystem.successColor.withValues(alpha: 0.1),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: context.borderRadius(BorderRadiusType.medium),
        border: Border.all(
          color: AppThemeSystem.successColor,
          width: 2,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with badge
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      packageData?['name'] ?? 'Package Actuel',
                      style: context.h6.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      packageData?['formatted_price'] ?? '',
                      style: context.subtitle1.copyWith(
                        color: AppThemeSystem.primaryColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: AppThemeSystem.successColor,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  'Actif',
                  style: context.caption.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: context.elementSpacing),

          // Storage Progress Bar
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: storagePercentageUsed / 100,
              backgroundColor: context.borderColor,
              valueColor: AlwaysStoppedAnimation<Color>(
                storagePercentageUsed > 80
                    ? AppThemeSystem.errorColor
                    : storagePercentageUsed > 50
                        ? AppThemeSystem.warningColor
                        : AppThemeSystem.successColor,
              ),
              minHeight: 12,
            ),
          ),
          SizedBox(height: 12),

          // Storage Info
          Text(
            '${storageUsedMb.toStringAsFixed(1)} MB utilisés sur ${storageTotalMb.toStringAsFixed(0)} MB (${storagePercentageUsed.toStringAsFixed(1)}%)',
            style: context.body2.copyWith(
              color: context.secondaryTextColor,
            ),
          ),
          SizedBox(height: 4),
          Text(
            'Espace restant : ${storageRemainingMb.toStringAsFixed(1)} MB',
            style: context.caption.copyWith(
              color: AppThemeSystem.successColor,
              fontWeight: FontWeight.w600,
            ),
          ),

          // Expiration warning
          if (daysRemaining <= 7)
            Container(
              margin: const EdgeInsets.only(top: 12),
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppThemeSystem.warningColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: AppThemeSystem.warningColor,
                  width: 1,
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.access_time,
                    size: 16,
                    color: AppThemeSystem.warningColor,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Expire dans $daysRemaining jour${daysRemaining > 1 ? "s" : ""}',
                      style: context.caption.copyWith(
                        color: AppThemeSystem.warningColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  /// Build packages grid
  Widget _buildPackagesGrid(BuildContext context) {
    final crossAxisCount = context.deviceType == DeviceType.mobile ? 1 : 2;
    final spacing = context.elementSpacing;

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        crossAxisSpacing: spacing,
        mainAxisSpacing: spacing,
        childAspectRatio: context.deviceType == DeviceType.mobile ? 1.2 : 0.9,
      ),
      itemCount: controller.packages.length,
      itemBuilder: (context, index) {
        final package = controller.packages[index];
        return _buildPackageCard(context, package);
      },
    );
  }

  /// Build a single package card
  Widget _buildPackageCard(BuildContext context, Map<String, dynamic> package) {
    final isPopular = package['is_popular'] ?? false;
    final benefits = package['benefits'] as List?;

    return GestureDetector(
      onTap: () => _showSubscriptionDialog(context, package),
      child: Container(
        decoration: BoxDecoration(
          color: context.surfaceColor,
          borderRadius: context.borderRadius(BorderRadiusType.medium),
          border: Border.all(
            color: isPopular
                ? AppThemeSystem.primaryColor
                : context.borderColor,
            width: isPopular ? 2 : 1,
          ),
          boxShadow: isPopular
              ? [
                  BoxShadow(
                    color: AppThemeSystem.primaryColor.withValues(alpha: 0.2),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ]
              : null,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with popular badge
            if (isPopular)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 8),
                decoration: BoxDecoration(
                  color: AppThemeSystem.primaryColor,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(context.deviceType == DeviceType.mobile ? 12 : 16),
                    topRight: Radius.circular(context.deviceType == DeviceType.mobile ? 12 : 16),
                  ),
                ),
                child: Text(
                  'POPULAIRE',
                  textAlign: TextAlign.center,
                  style: context.caption.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.2,
                  ),
                ),
              ),

            // Content
            Expanded(
              child: Padding(
                padding: EdgeInsets.all(context.horizontalPadding),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Package name
                    Text(
                      package['name'] ?? '',
                      style: context.h6.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: context.elementSpacing / 2),

                    // Price
                    Text(
                      package['formatted_price'] ?? '',
                      style: context.h5.copyWith(
                        color: AppThemeSystem.primaryColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: context.elementSpacing / 2),

                    // Storage and duration
                    Row(
                      children: [
                        Icon(
                          Icons.storage,
                          size: 16,
                          color: context.secondaryTextColor,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          package['formatted_storage_size'] ?? '',
                          style: context.body2.copyWith(
                            color: context.secondaryTextColor,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(
                          Icons.access_time,
                          size: 16,
                          color: context.secondaryTextColor,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          package['formatted_duration'] ?? '',
                          style: context.body2.copyWith(
                            color: context.secondaryTextColor,
                          ),
                        ),
                      ],
                    ),

                    // Benefits
                    if (benefits != null && benefits.isNotEmpty) ...[
                      SizedBox(height: context.elementSpacing),
                      Expanded(
                        child: ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: benefits.length > 3 ? 3 : benefits.length,
                          itemBuilder: (context, index) {
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 4),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Icon(
                                    Icons.check_circle,
                                    size: 16,
                                    color: AppThemeSystem.successColor,
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      benefits[index].toString(),
                                      style: context.caption.copyWith(
                                        color: context.secondaryTextColor,
                                      ),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ),
                    ],

                    const Spacer(),

                    // Choose button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () => _showSubscriptionDialog(context, package),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: isPopular
                              ? AppThemeSystem.primaryColor
                              : context.surfaceColor,
                          foregroundColor: isPopular
                              ? Colors.white
                              : AppThemeSystem.primaryColor,
                          side: BorderSide(
                            color: AppThemeSystem.primaryColor,
                            width: isPopular ? 0 : 1,
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: Text(
                          'Choisir',
                          style: context.button.copyWith(
                            color: isPopular ? Colors.white : AppThemeSystem.primaryColor,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Show subscription confirmation dialog
  void _showSubscriptionDialog(BuildContext context, Map<String, dynamic> package) {
    controller.selectPackage(package);

    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: Container(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Title
              Text(
                'Confirmer l\'abonnement',
                style: context.h6.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),

              // Package summary
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppThemeSystem.primaryColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      package['name'] ?? '',
                      style: context.subtitle1.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    _buildInfoRow(
                      context,
                      Icons.attach_money,
                      'Prix',
                      package['formatted_price'] ?? '',
                    ),
                    const SizedBox(height: 4),
                    _buildInfoRow(
                      context,
                      Icons.storage,
                      'Stockage',
                      package['formatted_storage_size'] ?? '',
                    ),
                    const SizedBox(height: 4),
                    _buildInfoRow(
                      context,
                      Icons.access_time,
                      'Durée',
                      package['formatted_duration'] ?? '',
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Buttons
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Get.back(),
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: context.borderColor),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      child: Text(
                        'Annuler',
                        style: context.button.copyWith(
                          color: context.primaryTextColor,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Obx(() {
                      return ElevatedButton(
                        onPressed: controller.isLoading.value
                            ? null
                            : () {
                                Get.back(); // Close dialog
                                controller.subscribe();
                              },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppThemeSystem.primaryColor,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                        child: controller.isLoading.value
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    Colors.white,
                                  ),
                                ),
                              )
                            : Text(
                                'Confirmer',
                                style: context.button.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                      );
                    }),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Build info row helper
  Widget _buildInfoRow(BuildContext context, IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 16, color: context.secondaryTextColor),
        const SizedBox(width: 8),
        Text(
          '$label: ',
          style: context.caption.copyWith(
            color: context.secondaryTextColor,
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: context.caption.copyWith(
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.right,
          ),
        ),
      ],
    );
  }
}
