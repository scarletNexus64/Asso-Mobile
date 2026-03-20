import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../../core/utils/app_theme_system.dart';
import '../controllers/store_management_controller.dart';
import '../models/store_models.dart';

class StoreManagementView extends GetView<StoreManagementController> {
  const StoreManagementView({super.key});

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
          'Ma Boutique',
          style: context.h5.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(
              Icons.refresh,
              color: context.primaryTextColor,
            ),
            onPressed: controller.loadData,
          ),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value && controller.storeInfo.value == null) {
          return const Center(child: CircularProgressIndicator());
        }

        return RefreshIndicator(
          onRefresh: controller.loadData,
          child: SingleChildScrollView(
            padding: EdgeInsets.all(context.horizontalPadding),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Carousel de bannières
                _BannerCarousel(),

                SizedBox(height: context.sectionSpacing),

                // Carte de stockage
                _StorageCard(),

                SizedBox(height: context.elementSpacing),

                // Certification
                _CertificationCard(),

                SizedBox(height: context.elementSpacing),

                // Statistiques d'audience
                _AudienceStatsCard(),

                SizedBox(height: context.elementSpacing),

                // Inventaire
                _InventoryCard(),

                SizedBox(height: context.elementSpacing),

                // Édition de la boutique
                _StoreEditorCard(),

                SizedBox(height: context.sectionSpacing),
              ],
            ),
          ),
        );
      }),
    );
  }
}

/// Carousel de bannières promotionnelles
class _BannerCarousel extends GetView<StoreManagementController> {
  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (controller.banners.isEmpty) return const SizedBox.shrink();

      return Column(
        children: [
          SizedBox(
            height: 140,
            child: PageView.builder(
              itemCount: controller.banners.length,
              onPageChanged: (index) {
                controller.currentBannerIndex.value = index;
              },
              itemBuilder: (context, index) {
                final banner = controller.banners[index];
                return _BannerItem(banner: banner);
              },
            ),
          ),
          const SizedBox(height: 12),
          // Indicateurs de page
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(
              controller.banners.length,
              (index) => Obx(() => Container(
                width: controller.currentBannerIndex.value == index ? 24 : 8,
                height: 8,
                margin: const EdgeInsets.symmetric(horizontal: 4),
                decoration: BoxDecoration(
                  color: controller.currentBannerIndex.value == index
                      ? AppThemeSystem.primaryColor
                      : AppThemeSystem.grey300,
                  borderRadius: BorderRadius.circular(4),
                ),
              )),
            ),
          ),
        ],
      );
    });
  }
}

/// Item de bannière
class _BannerItem extends StatelessWidget {
  final PromotionalBanner banner;

  const _BannerItem({required this.banner});

  Color _getColorFromType(BannerType type) {
    final colorCode = type.colorCode;
    return Color(int.parse(colorCode.replaceFirst('#', '0xFF')));
  }

  @override
  Widget build(BuildContext context) {
    final color = _getColorFromType(banner.type);

    return GestureDetector(
      onTap: banner.onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 8),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [color, color.withValues(alpha: 0.7)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: context.borderRadius(BorderRadiusType.medium),
          boxShadow: [
            BoxShadow(
              color: color.withValues(alpha: 0.3),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        padding: EdgeInsets.all(context.horizontalPadding),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    banner.title,
                    style: context.h5.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    banner.description,
                    style: context.body2.copyWith(
                      color: Colors.white.withValues(alpha: 0.9),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: context.borderRadius(BorderRadiusType.small),
                    ),
                    child: Text(
                      banner.actionLabel,
                      style: context.caption.copyWith(
                        color: color,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              color: Colors.white,
              size: 32,
            ),
          ],
        ),
      ),
    );
  }
}

/// Carte de gestion du stockage
class _StorageCard extends GetView<StoreManagementController> {
  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final storage = controller.storageStats.value;
      if (storage == null) return const SizedBox.shrink();

      return Container(
        padding: EdgeInsets.all(context.horizontalPadding),
        decoration: BoxDecoration(
          color: context.surfaceColor,
          borderRadius: context.borderRadius(BorderRadiusType.medium),
          border: Border.all(color: context.borderColor),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.storage,
                  color: AppThemeSystem.primaryColor,
                  size: 24,
                ),
                const SizedBox(width: 12),
                Text(
                  'Espace de stockage',
                  style: context.h6.copyWith(fontWeight: FontWeight.bold),
                ),
              ],
            ),
            SizedBox(height: context.elementSpacing),
            // Barre de progression
            ClipRRect(
              borderRadius: context.borderRadius(BorderRadiusType.small),
              child: LinearProgressIndicator(
                value: storage.usagePercentage / 100,
                minHeight: 12,
                backgroundColor: AppThemeSystem.grey200,
                valueColor: AlwaysStoppedAnimation<Color>(
                  storage.isAlmostFull
                      ? AppThemeSystem.errorColor
                      : AppThemeSystem.primaryColor,
                ),
              ),
            ),
            SizedBox(height: context.elementSpacing),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${storage.usedSpaceGB.toStringAsFixed(1)} GB / ${storage.totalSpaceGB.toStringAsFixed(1)} GB',
                  style: context.body2.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  '${storage.usagePercentage.toStringAsFixed(1)}%',
                  style: context.body2.copyWith(
                    color: storage.isAlmostFull
                        ? AppThemeSystem.errorColor
                        : AppThemeSystem.successColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            SizedBox(height: context.elementSpacing),
            Row(
              children: [
                Expanded(
                  child: _InfoChip(
                    icon: Icons.inventory_2_outlined,
                    label: '${storage.totalProducts} produits',
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _InfoChip(
                    icon: Icons.image_outlined,
                    label: '${storage.totalImages} images',
                  ),
                ),
              ],
            ),
            if (storage.isAlmostFull) ...[
              SizedBox(height: context.elementSpacing),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppThemeSystem.warningColor.withValues(alpha: 0.1),
                  borderRadius: context.borderRadius(BorderRadiusType.small),
                  border: Border.all(color: AppThemeSystem.warningColor),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.warning_amber_rounded,
                      color: AppThemeSystem.warningColor,
                      size: 20,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Votre espace de stockage est presque plein',
                        style: context.caption.copyWith(
                          color: AppThemeSystem.warningColor,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
            SizedBox(height: context.elementSpacing),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: controller.upgradeStorage,
                icon: const Icon(Icons.upgrade),
                label: const Text('Augmenter l\'espace'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppThemeSystem.primaryColor,
                ),
              ),
            ),
          ],
        ),
      );
    });
  }
}

/// Puce d'information
class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String label;

  const _InfoChip({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: AppThemeSystem.grey100,
        borderRadius: context.borderRadius(BorderRadiusType.small),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: context.secondaryTextColor),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              label,
              style: context.caption,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}

/// Carte de certification
class _CertificationCard extends GetView<StoreManagementController> {
  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final cert = controller.certification.value;
      if (cert == null) return const SizedBox.shrink();

      return Container(
        padding: EdgeInsets.all(context.horizontalPadding),
        decoration: BoxDecoration(
          color: context.surfaceColor,
          borderRadius: context.borderRadius(BorderRadiusType.medium),
          border: Border.all(color: context.borderColor),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  cert.isCertified ? Icons.verified : Icons.verified_outlined,
                  color: cert.isCertified
                      ? AppThemeSystem.successColor
                      : AppThemeSystem.grey400,
                  size: 24,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Certification',
                    style: context.h6.copyWith(fontWeight: FontWeight.bold),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: cert.isCertified
                        ? AppThemeSystem.successColor.withValues(alpha: 0.1)
                        : AppThemeSystem.grey200,
                    borderRadius: context.borderRadius(BorderRadiusType.small),
                    border: Border.all(
                      color: cert.isCertified
                          ? AppThemeSystem.successColor
                          : AppThemeSystem.grey400,
                    ),
                  ),
                  child: Text(
                    cert.status.label,
                    style: context.caption.copyWith(
                      color: cert.isCertified
                          ? AppThemeSystem.successColor
                          : context.secondaryTextColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: context.elementSpacing),
            if (cert.isCertified && cert.expiryDate != null) ...[
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: cert.isExpiringSoon
                      ? AppThemeSystem.warningColor.withValues(alpha: 0.1)
                      : AppThemeSystem.successColor.withValues(alpha: 0.1),
                  borderRadius: context.borderRadius(BorderRadiusType.small),
                ),
                child: Row(
                  children: [
                    Icon(
                      cert.isExpiringSoon
                          ? Icons.warning_amber_rounded
                          : Icons.check_circle,
                      color: cert.isExpiringSoon
                          ? AppThemeSystem.warningColor
                          : AppThemeSystem.successColor,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        cert.isExpiringSoon
                            ? 'Expire dans ${cert.daysUntilExpiry} jours'
                            : 'Valide jusqu\'au ${DateFormat('dd/MM/yyyy').format(cert.expiryDate!)}',
                        style: context.body2,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: context.elementSpacing),
            ] else ...[
              Text(
                'Obtenez la certification pour gagner la confiance de vos clients et augmenter vos ventes.',
                style: context.body2.copyWith(
                  color: context.secondaryTextColor,
                ),
              ),
              SizedBox(height: context.elementSpacing),
            ],
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: controller.requestCertification,
                icon: Icon(
                  cert.isCertified ? Icons.refresh : Icons.verified,
                ),
                label: Text(
                  cert.isCertified
                      ? 'Renouveler la certification'
                      : 'Demander la certification',
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: cert.isCertified
                      ? AppThemeSystem.successColor
                      : AppThemeSystem.primaryColor,
                ),
              ),
            ),
          ],
        ),
      );
    });
  }
}

/// Carte des statistiques d'audience
class _AudienceStatsCard extends GetView<StoreManagementController> {
  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final stats = controller.audienceStats.value;
      if (stats == null) return const SizedBox.shrink();

      return Container(
        padding: EdgeInsets.all(context.horizontalPadding),
        decoration: BoxDecoration(
          color: context.surfaceColor,
          borderRadius: context.borderRadius(BorderRadiusType.medium),
          border: Border.all(color: context.borderColor),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.trending_up,
                  color: AppThemeSystem.primaryColor,
                  size: 24,
                ),
                const SizedBox(width: 12),
                Text(
                  'Mes audiences',
                  style: context.h6.copyWith(fontWeight: FontWeight.bold),
                ),
              ],
            ),
            SizedBox(height: context.elementSpacing),
            // Statistiques générales
            Row(
              children: [
                Expanded(
                  child: _StatBox(
                    icon: Icons.visibility_outlined,
                    label: 'Vues',
                    value: NumberFormat('#,###').format(stats.totalViews),
                    color: AppThemeSystem.infoColor,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _StatBox(
                    icon: Icons.touch_app_outlined,
                    label: 'Clics',
                    value: NumberFormat('#,###').format(stats.totalClicks),
                    color: AppThemeSystem.primaryColor,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: _StatBox(
                    icon: Icons.shopping_cart_outlined,
                    label: 'Commandes',
                    value: stats.totalOrders.toString(),
                    color: AppThemeSystem.successColor,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _StatBox(
                    icon: Icons.percent,
                    label: 'Conversion',
                    value: '${stats.conversionRate.toStringAsFixed(1)}%',
                    color: AppThemeSystem.warningColor,
                  ),
                ),
              ],
            ),
            SizedBox(height: context.elementSpacing),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: controller.boostProducts,
                icon: const Icon(Icons.rocket_launch),
                label: const Text('Booster mes produits'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppThemeSystem.primaryColor,
                ),
              ),
            ),
          ],
        ),
      );
    });
  }
}

/// Boîte de statistique
class _StatBox extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _StatBox({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: context.borderRadius(BorderRadiusType.small),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(height: 8),
          Text(
            value,
            style: context.h5.copyWith(
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: context.caption.copyWith(
              color: context.secondaryTextColor,
            ),
          ),
        ],
      ),
    );
  }
}

/// Carte d'inventaire
class _InventoryCard extends GetView<StoreManagementController> {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(context.horizontalPadding),
      decoration: BoxDecoration(
        color: context.surfaceColor,
        borderRadius: context.borderRadius(BorderRadiusType.medium),
        border: Border.all(color: context.borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.inventory,
                color: AppThemeSystem.primaryColor,
                size: 24,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Inventaire',
                  style: context.h6.copyWith(fontWeight: FontWeight.bold),
                ),
              ),
              IconButton(
                onPressed: controller.addInventoryEntry,
                icon: const Icon(Icons.add_circle),
                color: AppThemeSystem.primaryColor,
              ),
            ],
          ),
          SizedBox(height: context.elementSpacing),
          // Filtres
          Obx(() => Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _FilterChip(
                label: 'Tous',
                isSelected: controller.selectedInventoryFilter.value == null,
                onTap: () => controller.selectedInventoryFilter.value = null,
              ),
              _FilterChip(
                label: 'Entrées',
                isSelected: controller.selectedInventoryFilter.value ==
                    InventoryType.entry,
                onTap: () => controller.selectedInventoryFilter.value =
                    InventoryType.entry,
              ),
              _FilterChip(
                label: 'Sorties',
                isSelected: controller.selectedInventoryFilter.value ==
                    InventoryType.exit,
                onTap: () => controller.selectedInventoryFilter.value =
                    InventoryType.exit,
              ),
            ],
          )),
          SizedBox(height: context.elementSpacing),
          // Liste des entrées
          Obx(() {
            final entries = controller.filteredInventory;
            if (entries.isEmpty) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Text(
                    'Aucune entrée d\'inventaire',
                    style: context.body2.copyWith(
                      color: context.secondaryTextColor,
                    ),
                  ),
                ),
              );
            }

            return Column(
              children: entries.take(3).map((entry) {
                return _InventoryItem(entry: entry);
              }).toList(),
            );
          }),
        ],
      ),
    );
  }
}

/// Filtre chip
class _FilterChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _FilterChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? AppThemeSystem.primaryColor
              : AppThemeSystem.grey100,
          borderRadius: context.borderRadius(BorderRadiusType.small),
          border: Border.all(
            color: isSelected
                ? AppThemeSystem.primaryColor
                : AppThemeSystem.grey300,
          ),
        ),
        child: Text(
          label,
          style: context.caption.copyWith(
            color: isSelected ? Colors.white : context.secondaryTextColor,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}

/// Item d'inventaire
class _InventoryItem extends GetView<StoreManagementController> {
  final InventoryEntry entry;

  const _InventoryItem({required this.entry});

  @override
  Widget build(BuildContext context) {
    final isEntry = entry.type == InventoryType.entry;

    return InkWell(
      onTap: () => controller.viewInventoryDetails(entry),
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: context.backgroundColor,
          borderRadius: context.borderRadius(BorderRadiusType.small),
          border: Border.all(color: context.borderColor),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: isEntry
                    ? AppThemeSystem.successColor.withValues(alpha: 0.1)
                    : AppThemeSystem.errorColor.withValues(alpha: 0.1),
                borderRadius: context.borderRadius(BorderRadiusType.small),
              ),
              child: Icon(
                isEntry ? Icons.add : Icons.remove,
                color: isEntry
                    ? AppThemeSystem.successColor
                    : AppThemeSystem.errorColor,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    entry.productName,
                    style: context.body2.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    DateFormat('dd/MM/yyyy').format(entry.date),
                    style: context.caption.copyWith(
                      color: context.secondaryTextColor,
                    ),
                  ),
                ],
              ),
            ),
            Text(
              '${isEntry ? '+' : '-'}${entry.quantity}',
              style: context.body1.copyWith(
                color: isEntry
                    ? AppThemeSystem.successColor
                    : AppThemeSystem.errorColor,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Carte d'édition de la boutique
class _StoreEditorCard extends GetView<StoreManagementController> {
  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final store = controller.storeInfo.value;
      if (store == null) return const SizedBox.shrink();

      return Container(
        padding: EdgeInsets.all(context.horizontalPadding),
        decoration: BoxDecoration(
          color: context.surfaceColor,
          borderRadius: context.borderRadius(BorderRadiusType.medium),
          border: Border.all(color: context.borderColor),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.edit,
                  color: AppThemeSystem.primaryColor,
                  size: 24,
                ),
                const SizedBox(width: 12),
                Text(
                  'Informations de la boutique',
                  style: context.h6.copyWith(fontWeight: FontWeight.bold),
                ),
              ],
            ),
            SizedBox(height: context.elementSpacing),
            // Logo
            Center(
              child: GestureDetector(
                onTap: controller.pickLogo,
                child: Stack(
                  children: [
                    Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        color: AppThemeSystem.grey200,
                        borderRadius:
                            context.borderRadius(BorderRadiusType.medium),
                        border: Border.all(
                          color: AppThemeSystem.primaryColor,
                          width: 2,
                        ),
                      ),
                      child: controller.selectedLogo.value != null
                          ? ClipRRect(
                              borderRadius:
                                  context.borderRadius(BorderRadiusType.medium),
                              child: Image.file(
                                controller.selectedLogo.value!,
                                fit: BoxFit.cover,
                              ),
                            )
                          : Icon(
                              Icons.store,
                              size: 50,
                              color: AppThemeSystem.primaryColor,
                            ),
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: AppThemeSystem.primaryColor,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.camera_alt,
                          color: Colors.white,
                          size: 16,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: context.elementSpacing),
            // Informations
            _InfoRow(
              icon: Icons.store,
              label: 'Nom',
              value: store.name,
            ),
            _InfoRow(
              icon: Icons.location_on,
              label: 'Ville',
              value: store.city,
            ),
            _InfoRow(
              icon: Icons.home,
              label: 'Adresse',
              value: store.address,
            ),
            _InfoRow(
              icon: Icons.phone,
              label: 'Téléphone',
              value: store.phone,
            ),
            SizedBox(height: context.elementSpacing),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  // TODO: Ouvrir un formulaire d'édition
                  Get.snackbar(
                    'Édition',
                    'Formulaire d\'édition en cours de développement',
                    snackPosition: SnackPosition.BOTTOM,
                  );
                },
                icon: const Icon(Icons.edit),
                label: const Text('Modifier les informations'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppThemeSystem.primaryColor,
                ),
              ),
            ),
          ],
        ),
      );
    });
  }
}

/// Ligne d'information
class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, size: 20, color: context.secondaryTextColor),
          const SizedBox(width: 12),
          Text(
            '$label:',
            style: context.body2.copyWith(
              color: context.secondaryTextColor,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              value,
              style: context.body2.copyWith(
                fontWeight: FontWeight.w600,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
