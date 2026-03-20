import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/utils/app_theme_system.dart';
import '../controllers/profile_controller.dart';

class ProfileView extends GetView<ProfileController> {
  const ProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: AppThemeSystem.getBackgroundColor(context),
      body: Obx(() {
        if (controller.userProfile.isEmpty) {
          return Center(child: CircularProgressIndicator());
        }

        return SingleChildScrollView(
            child: Column(
              children: [
                // Header avec profil
                _buildProfileHeader(context, isDark),

                SizedBox(height: 24),

                // Statistiques
                _buildStats(context),

                SizedBox(height: 24),

                // Menu principal
                _buildMenuSection(
                  context,
                  'Mon compte',
                  [
                    _MenuItem(
                      icon: Icons.shopping_bag_outlined,
                      title: 'Mes produits',
                      subtitle: 'Gérer mes annonces',
                      onTap: controller.goToMyProducts,
                    ),
                    _MenuItem(
                      icon: Icons.favorite_outline_rounded,
                      title: 'Mes favoris',
                      subtitle: 'Articles sauvegardés',
                      onTap: controller.goToFavorites,
                    ),
                    _MenuItem(
                      icon: Icons.receipt_long_rounded,
                      title: 'Mes commandes',
                      subtitle: 'Historique d\'achats',
                      onTap: controller.goToOrders,
                    ),
                  ],
                ),

                SizedBox(height: 16),

                // Paramètres et préférences
                _buildMenuSection(
                  context,
                  'Paramètres',
                  [
                    _MenuItem(
                      icon: Icons.location_on_outlined,
                      title: 'Adresses',
                      subtitle: 'Gérer mes adresses',
                      onTap: controller.goToAddresses,
                    ),
                    _MenuItem(
                      icon: Icons.payment_rounded,
                      title: 'Paiements',
                      subtitle: 'Moyens de paiement',
                      onTap: controller.goToPaymentMethods,
                    ),
                    _MenuItem(
                      icon: Icons.settings_outlined,
                      title: 'Paramètres',
                      subtitle: 'Préférences de l\'app',
                      onTap: controller.goToSettings,
                    ),
                  ],
                ),

                SizedBox(height: 16),

                // Support
                _buildMenuSection(
                  context,
                  'Support',
                  [
                    _MenuItem(
                      icon: Icons.help_outline_rounded,
                      title: 'Aide & Support',
                      subtitle: 'FAQ et contact',
                      onTap: controller.goToHelp,
                    ),
                    _MenuItem(
                      icon: Icons.info_outline_rounded,
                      title: 'À propos',
                      subtitle: 'Version et infos',
                      onTap: controller.goToAbout,
                    ),
                  ],
                ),

                SizedBox(height: 24),

                // Bouton déconnexion
                _buildLogoutButton(context),

                SizedBox(height: 32),
              ],
            ),
          );
      }),
    );
  }

  Widget _buildProfileHeader(BuildContext context, bool isDark) {
    final profile = controller.userProfile;

    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppThemeSystem.primaryColor,
            AppThemeSystem.tertiaryColor,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Mon Profil',
                style: context.textStyle(
                  FontSizeType.h5,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              IconButton(
                icon: Icon(
                  Icons.edit_rounded,
                  color: Colors.white,
                ),
                onPressed: controller.editProfile,
              ),
            ],
          ),
          SizedBox(height: 20),
          // Avatar
          Stack(
            children: [
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Colors.white,
                    width: 4,
                  ),
                  gradient: LinearGradient(
                    colors: [
                      Colors.white.withValues(alpha: 0.3),
                      Colors.white.withValues(alpha: 0.1),
                    ],
                  ),
                ),
                child: Center(
                  child: Text(
                    profile['avatar'],
                    style: context.textStyle(
                      FontSizeType.h2,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              Positioned(
                right: 0,
                bottom: 0,
                child: Container(
                  padding: EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.green,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Colors.white,
                      width: 2,
                    ),
                  ),
                  child: Icon(
                    Icons.check,
                    size: 16,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 16),
          Text(
            profile['name'],
            style: context.textStyle(
              FontSizeType.h4,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          SizedBox(height: 4),
          Text(
            profile['email'],
            style: context.textStyle(
              FontSizeType.body2,
              color: Colors.white.withValues(alpha: 0.9),
            ),
          ),
          SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.location_on_rounded,
                size: 16,
                color: Colors.white.withValues(alpha: 0.9),
              ),
              SizedBox(width: 4),
              Text(
                profile['location'],
                style: context.textStyle(
                  FontSizeType.caption,
                  color: Colors.white.withValues(alpha: 0.9),
                ),
              ),
            ],
          ),
          SizedBox(height: 8),
          Text(
            profile['memberSince'],
            style: context.textStyle(
              FontSizeType.caption,
              color: Colors.white.withValues(alpha: 0.8),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStats(BuildContext context) {
    final stats = controller.userProfile['stats'];

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          _buildStatCard(
            context,
            Icons.shopping_cart_rounded,
            stats['orders'].toString(),
            'Commandes',
          ),
          SizedBox(width: 12),
          _buildStatCard(
            context,
            Icons.star_rounded,
            stats['reviews'].toString(),
            'Avis',
          ),
          SizedBox(width: 12),
          _buildStatCard(
            context,
            Icons.favorite_rounded,
            stats['favorites'].toString(),
            'Favoris',
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(
    BuildContext context,
    IconData icon,
    String value,
    String label,
  ) {
    return Expanded(
      child: Container(
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppThemeSystem.getSurfaceColor(context),
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: AppThemeSystem.primaryColor,
              size: 28,
            ),
            SizedBox(height: 8),
            Text(
              value,
              style: context.textStyle(
                FontSizeType.h5,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 4),
            Text(
              label,
              style: context.textStyle(
                FontSizeType.caption,
                color: AppThemeSystem.grey600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuSection(
    BuildContext context,
    String title,
    List<_MenuItem> items,
  ) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: AppThemeSystem.getSurfaceColor(context),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.all(16),
            child: Text(
              title,
              style: context.textStyle(
                FontSizeType.body2,
                fontWeight: FontWeight.bold,
                color: AppThemeSystem.grey600,
              ),
            ),
          ),
          ...items.asMap().entries.map((entry) {
            final index = entry.key;
            final item = entry.value;
            final isLast = index == items.length - 1;

            return Column(
              children: [
                Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: item.onTap,
                    borderRadius: BorderRadius.vertical(
                      bottom: isLast ? Radius.circular(12) : Radius.zero,
                    ),
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: AppThemeSystem.primaryColor.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Icon(
                              item.icon,
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
                                  item.title,
                                  style: context.textStyle(
                                    FontSizeType.body1,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                if (item.subtitle != null) ...[
                                  SizedBox(height: 2),
                                  Text(
                                    item.subtitle!,
                                    style: context.textStyle(
                                      FontSizeType.caption,
                                      color: AppThemeSystem.grey600,
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                          Icon(
                            Icons.chevron_right_rounded,
                            color: AppThemeSystem.grey400,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                if (!isLast)
                  Divider(
                    height: 1,
                    indent: 72,
                  ),
              ],
            );
          }).toList(),
        ],
      ),
    );
  }

  Widget _buildLogoutButton(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16),
      child: SizedBox(
        width: double.infinity,
        child: OutlinedButton.icon(
          onPressed: controller.logout,
          icon: Icon(
            Icons.logout_rounded,
            color: AppThemeSystem.errorColor,
          ),
          label: Text(
            'Déconnexion',
            style: context.textStyle(
              FontSizeType.body1,
              fontWeight: FontWeight.w600,
              color: AppThemeSystem.errorColor,
            ),
          ),
          style: OutlinedButton.styleFrom(
            padding: EdgeInsets.symmetric(vertical: 16),
            side: BorderSide(
              color: AppThemeSystem.errorColor,
              width: 1.5,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
      ),
    );
  }
}

class _MenuItem {
  final IconData icon;
  final String title;
  final String? subtitle;
  final VoidCallback onTap;

  _MenuItem({
    required this.icon,
    required this.title,
    this.subtitle,
    required this.onTap,
  });
}
