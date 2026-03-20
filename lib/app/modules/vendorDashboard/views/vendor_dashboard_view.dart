import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../../core/utils/app_theme_system.dart';
import '../controllers/vendor_dashboard_controller.dart';
import '../../addProduct/views/add_product_view.dart';
import '../../addProduct/bindings/add_product_binding.dart';
import '../../orderManagement/views/order_management_view.dart';
import '../../orderManagement/bindings/order_management_binding.dart';
import '../../storeManagement/views/store_management_view.dart';
import '../../storeManagement/bindings/store_management_binding.dart';
import '../../wallet/views/wallet_view.dart';
import '../../wallet/bindings/wallet_binding.dart';

class VendorDashboardView extends GetView<VendorDashboardController> {
  const VendorDashboardView({super.key});

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
          'Dashboard Vendeur',
          style: context.h5.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(
              Icons.settings,
              color: context.primaryTextColor,
            ),
            onPressed: () {
              // TODO: Ouvrir les paramètres vendeur
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(context.horizontalPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header avec logo de la boutique
            _buildShopHeader(context),

            SizedBox(height: context.sectionSpacing),

            // Statistiques
            _buildStatsSection(context),

            SizedBox(height: context.sectionSpacing),

            // Actions rapides
            _buildQuickActions(context),
          ],
        ),
      ),
    );
  }

  /// Header avec logo de la boutique
  Widget _buildShopHeader(BuildContext context) {
    return Container(
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
          // Logo de la boutique
          Stack(
            children: [
              Container(
                width: 70,
                height: 70,
                decoration: BoxDecoration(
                  color: AppThemeSystem.primaryColor.withValues(alpha: 0.1),
                  borderRadius: context.borderRadius(BorderRadiusType.medium),
                  border: Border.all(
                    color: AppThemeSystem.primaryColor.withValues(alpha: 0.3),
                    width: 2,
                  ),
                ),
                child: Obx(() {
                  if (controller.shopLogo.value != null) {
                    return ClipRRect(
                      borderRadius: context.borderRadius(BorderRadiusType.medium),
                      child: Image.file(
                        controller.shopLogo.value!,
                        fit: BoxFit.cover,
                      ),
                    );
                  }
                  return Icon(
                    Icons.store,
                    color: AppThemeSystem.primaryColor,
                    size: 36,
                  );
                }),
              ),
              // Badge "Non vérifié"
              Positioned(
                top: -2,
                right: -2,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppThemeSystem.warningColor,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Icon(
                    Icons.warning_amber_rounded,
                    color: Colors.white,
                    size: 14,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(width: 16),
          // Informations boutique
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Obx(() => Text(
                  controller.shopName.value,
                  style: context.h5.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                )),
                SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: AppThemeSystem.warningColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: AppThemeSystem.warningColor,
                      width: 1,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.pending_outlined,
                        size: 12,
                        color: AppThemeSystem.warningColor,
                      ),
                      SizedBox(width: 4),
                      Text(
                        'Non vérifié',
                        style: context.caption.copyWith(
                          color: AppThemeSystem.warningColor,
                          fontWeight: FontWeight.w600,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Section statistiques
  Widget _buildStatsSection(BuildContext context) {
    final formatter = NumberFormat('#,###', 'fr_FR');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Statistiques',
          style: context.h4.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: context.elementSpacing),
        Row(
          children: [
            Expanded(
              child: Obx(() => _buildStatCard(
                context,
                icon: Icons.shopping_bag_outlined,
                title: 'Commandes',
                value: '${controller.totalOrders.value}',
              )),
            ),
            SizedBox(width: 12),
            Expanded(
              child: Obx(() => _buildStatCard(
                context,
                icon: Icons.trending_up,
                title: 'Ventes',
                value: '${formatter.format(controller.totalSales.value)} XAF',
                isCompact: true,
                onTap: () {
                  Get.to(
                    () => const WalletView(),
                    binding: WalletBinding(),
                  );
                },
              )),
            ),
          ],
        ),
        SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: Obx(() => _buildStatCard(
                context,
                icon: Icons.inventory_2_outlined,
                title: 'Produits',
                value: '${controller.totalProducts.value}',
              )),
            ),
            SizedBox(width: 12),
            Expanded(
              child: Obx(() => _buildStatCard(
                context,
                icon: Icons.star_outline,
                title: 'Note',
                value: '${controller.rating.value.toStringAsFixed(1)} ⭐',
              )),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStatCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String value,
    bool isCompact = false,
    VoidCallback? onTap,
  }) {
    final cardContent = Container(
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
          Icon(
            icon,
            color: AppThemeSystem.primaryColor,
            size: 24,
          ),
          SizedBox(height: 12),
          Text(
            value,
            style: (isCompact ? context.h5 : context.h3).copyWith(
              fontWeight: FontWeight.bold,
              color: context.primaryTextColor,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          SizedBox(height: 4),
          Text(
            title,
            style: context.caption.copyWith(
              color: context.secondaryTextColor,
            ),
          ),
        ],
      ),
    );

    if (onTap != null) {
      return InkWell(
        onTap: onTap,
        borderRadius: context.borderRadius(BorderRadiusType.medium),
        child: cardContent,
      );
    }

    return cardContent;
  }

  /// Actions rapides
  Widget _buildQuickActions(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Actions rapides',
          style: context.h4.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: context.elementSpacing),
        _buildActionButton(
          context,
          icon: Icons.add_box_outlined,
          title: 'Ajouter un produit',
          subtitle: 'Créez un nouveau produit',
          onTap: () {
            Get.to(
              () => const AddProductView(),
              binding: AddProductBinding(),
            );
          },
        ),
        SizedBox(height: 12),
        _buildActionButton(
          context,
          icon: Icons.list_alt,
          title: 'Gérer les commandes',
          subtitle: 'Consultez vos commandes',
          onTap: () {
            Get.to(
              () => const OrderManagementView(),
              binding: OrderManagementBinding(),
            );
          },
        ),
        SizedBox(height: 12),
        _buildActionButton(
          context,
          icon: Icons.store,
          title: 'Ma boutique',
          subtitle: 'Personnalisez votre boutique',
          onTap: () {
            Get.to(
              () => const StoreManagementView(),
              binding: StoreManagementBinding(),
            );
          },
        ),
      ],
    );
  }

  Widget _buildActionButton(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: context.borderRadius(BorderRadiusType.medium),
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
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppThemeSystem.primaryColor.withValues(alpha: 0.1),
                borderRadius: context.borderRadius(BorderRadiusType.small),
              ),
              child: Icon(
                icon,
                color: AppThemeSystem.primaryColor,
                size: 24,
              ),
            ),
            SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: context.body1.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: context.caption.copyWith(
                      color: context.secondaryTextColor,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right,
              color: context.secondaryTextColor,
            ),
          ],
        ),
      ),
    );
  }
}
