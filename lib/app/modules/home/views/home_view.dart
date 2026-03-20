import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/utils/app_theme_system.dart';
import '../../../routes/app_pages.dart';
import '../../search/views/search_view.dart';
import '../../chat/views/chat_view.dart';
import '../../tracking/views/tracking_view.dart';
import '../../profile/views/profile_view.dart';
import '../controllers/home_controller.dart';
import 'accueil_view.dart';

class HomeView extends GetView<HomeController> {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final deviceType = AppThemeSystem.getDeviceType(context);

    return Scaffold(
      key: controller.scaffoldKey,
      backgroundColor: AppThemeSystem.getBackgroundColor(context),
      drawer: _buildDrawer(context),
      body: NestedScrollView(
        controller: controller.nestedScrollController,
        headerSliverBuilder: (context, innerBoxIsScrolled) {
          return [
            SliverAppBar(
              floating: false,
              pinned: true,
              snap: false,
              stretch: false,
              elevation: 0,
              shadowColor: Colors.transparent,
              surfaceTintColor: Colors.transparent,
              automaticallyImplyLeading: false,
              backgroundColor: isDark
                  ? AppThemeSystem.darkCardColor
                  : Colors.white,
              toolbarHeight: deviceType == DeviceType.mobile ? 64 : 72,
              titleSpacing: 0,
              forceElevated: true,
              primary: true,
              flexibleSpace: SafeArea(
                child: Container(
                  height: deviceType == DeviceType.mobile ? 64 : 72,
                  padding: EdgeInsets.symmetric(
                    horizontal: AppThemeSystem.getHorizontalPadding(context),
                  ),
                  child: Row(
                    children: [
                      // Hamburger menu button (left side)
                      IconButton(
                        icon: Icon(
                          Icons.menu_rounded,
                          color: AppThemeSystem.getPrimaryTextColor(context),
                          size: 28,
                        ),
                        onPressed: () {
                          controller.scaffoldKey.currentState?.openDrawer();
                        },
                      ),

                      // User profile section
                      Expanded(
                        child: Row(
                          children: [
                            SizedBox(width: 8),
                            Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    AppThemeSystem.primaryColor,
                                    AppThemeSystem.tertiaryColor,
                                  ],
                                ),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                Icons.person_rounded,
                                color: Colors.white,
                                size: 22,
                              ),
                            ),
                            SizedBox(width: 8),
                            Text(
                              'Kira',
                              style: context.textStyle(
                                FontSizeType.body1,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Action icons (right side)
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Camera icon for image search
                          _buildIconButton(
                            context: context,
                            icon: Icon(
                              Icons.camera_alt_rounded,
                              color: AppThemeSystem.getPrimaryTextColor(context),
                            ),
                            onPressed: () {
                              Get.snackbar(
                                'Recherche par image',
                                'Prenez une photo pour rechercher des produits similaires',
                                snackPosition: SnackPosition.BOTTOM,
                              );
                            },
                          ),

                          SizedBox(width: 4),

                          // Wishlist icon
                          _buildIconButton(
                            context: context,
                            icon: Icon(
                              Icons.favorite_border_rounded,
                              color: AppThemeSystem.getPrimaryTextColor(context),
                            ),
                            onPressed: () {
                              Get.toNamed('/favorites');
                            },
                          ),

                          SizedBox(width: 4),

                          // Notifications icon with badge
                          _buildIconButtonWithBadge(
                            context: context,
                            icon: Icon(
                              Icons.notifications_outlined,
                              color: AppThemeSystem.getPrimaryTextColor(context),
                            ),
                            badgeCount: '3',
                            onPressed: () {
                              Get.toNamed('/notification');
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              bottom: PreferredSize(
                preferredSize: Size.fromHeight(
                  deviceType == DeviceType.mobile ? 72 : 80,
                ),
                child: Container(
                  decoration: BoxDecoration(
                    color: isDark
                        ? AppThemeSystem.darkCardColor
                        : Colors.white,
                    border: Border(
                      bottom: BorderSide(
                        color: isDark
                            ? AppThemeSystem.grey800.withValues(alpha: 0.6)
                            : AppThemeSystem.grey200,
                        width: 1,
                      ),
                    ),
                  ),
                  padding: EdgeInsets.symmetric(
                    horizontal: AppThemeSystem.getHorizontalPadding(context) * 0.5,
                  ),
                  child: TabBar(
                    controller: controller.tabController,
                    onTap: controller.handleTabTap,
                    indicatorColor: AppThemeSystem.primaryColor,
                    indicatorWeight: 3,
                    indicatorSize: TabBarIndicatorSize.tab,
                    indicator: BoxDecoration(
                      border: Border(
                        bottom: BorderSide(
                          color: AppThemeSystem.primaryColor,
                          width: 3,
                        ),
                      ),
                    ),
                    labelColor: AppThemeSystem.primaryColor,
                    unselectedLabelColor: isDark
                        ? AppThemeSystem.grey400
                        : AppThemeSystem.grey600,
                    labelStyle: context.textStyle(FontSizeType.caption).copyWith(
                      fontWeight: FontWeight.w600,
                      fontSize: deviceType == DeviceType.mobile ? 11 : 13,
                    ),
                    unselectedLabelStyle: context.textStyle(FontSizeType.caption).copyWith(
                      fontWeight: FontWeight.normal,
                      fontSize: deviceType == DeviceType.mobile ? 11 : 13,
                    ),
                    tabs: [
                      // Accueil
                      Tab(
                        height: deviceType == DeviceType.mobile ? 64 : 72,
                        child: _AnimatedTabIcon(
                          controller: controller.tabController,
                          index: 0,
                          icon: Icons.home_rounded,
                          label: controller.tabNames[0],
                        ),
                      ),
                      // Recherche
                      Tab(
                        height: deviceType == DeviceType.mobile ? 64 : 72,
                        child: _AnimatedTabIcon(
                          controller: controller.tabController,
                          index: 1,
                          icon: Icons.search_rounded,
                          label: controller.tabNames[1],
                        ),
                      ),
                      // Messages
                      Tab(
                        height: deviceType == DeviceType.mobile ? 64 : 72,
                        child: _AnimatedTabIcon(
                          controller: controller.tabController,
                          index: 2,
                          icon: Icons.chat_bubble_outline_rounded,
                          label: controller.tabNames[2],
                        ),
                      ),
                      // Tracking
                      Tab(
                        height: deviceType == DeviceType.mobile ? 64 : 72,
                        child: _AnimatedTabIcon(
                          controller: controller.tabController,
                          index: 3,
                          icon: Icons.local_shipping_outlined,
                          label: controller.tabNames[3],
                        ),
                      ),
                      // Profile
                      Tab(
                        height: deviceType == DeviceType.mobile ? 64 : 72,
                        child: _AnimatedTabIcon(
                          controller: controller.tabController,
                          index: 4,
                          icon: Icons.person_outline_rounded,
                          label: controller.tabNames[4],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ];
        },
        body: TabBarView(
          controller: controller.tabController,
          children: const [
            AccueilView(),
            SearchView(),
            ChatView(),
            TrackingView(),
            ProfileView(),
          ],
        ),
      ),
    );
  }

  Widget _buildDrawer(BuildContext context) {
    return Drawer(
      backgroundColor: AppThemeSystem.getBackgroundColor(context),
      width: MediaQuery.of(context).size.width * 0.85,
      child: Column(
        children: [
          // Header du drawer avec dégradé
          Container(
            width: double.infinity,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  AppThemeSystem.primaryColor,
                  AppThemeSystem.tertiaryColor,
                ],
              ),
            ),
            child: SafeArea(
              bottom: false,
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: AppThemeSystem.getHorizontalPadding(context),
                  vertical: AppThemeSystem.getVerticalPadding(context) * 1.5,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Avatar avec bordure
                    Container(
                      width: 70,
                      height: 70,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.3),
                          width: 3,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.2),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Icon(
                        Icons.person_rounded,
                        color: AppThemeSystem.primaryColor,
                        size: 36,
                      ),
                    ),

                    SizedBox(height: AppThemeSystem.getElementSpacing(context)),

                    // Username
                    Text(
                      'Kira',
                      style: context.textStyle(
                        FontSizeType.h4,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),

                    SizedBox(height: 6),

                    // Numéro avec flag du pays
                    Row(
                      children: [
                        // Flag Cameroun
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.2),
                            borderRadius: context.borderRadius(BorderRadiusType.small),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                '🇨🇲',
                                style: TextStyle(fontSize: 16),
                              ),
                              const SizedBox(width: 4),
                              Text(
                                '+237',
                                style: context.textStyle(
                                  FontSizeType.caption,
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '658 895 572',
                          style: context.textStyle(
                            FontSizeType.body2,
                            color: Colors.white.withValues(alpha: 0.95),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Menu items avec scroll
          Expanded(
            child: ListView(
              padding: EdgeInsets.symmetric(
                vertical: AppThemeSystem.getVerticalPadding(context) * 0.5,
              ),
              children: [
                // SECTION: MON COMPTE
                _buildSectionHeader(context, 'Mon Compte'),
                _buildDrawerItem(
                  context: context,
                  icon: Icons.favorite_rounded,
                  title: 'Mes préferences',
                  onTap: () {
                    Get.back();
                    Get.toNamed('/favorites');
                  },
                ),
                _buildDrawerItem(
                  context: context,
                  icon: Icons.shopping_bag_rounded,
                  title: 'Mes commandes',
                  onTap: () {
                    Get.back();
                    Get.toNamed('/shipment');
                  },
                ),
                SizedBox(height: AppThemeSystem.getElementSpacing(context)),
                Divider(
                  color: context.borderColor,
                  height: 1,
                  indent: AppThemeSystem.getHorizontalPadding(context),
                  endIndent: AppThemeSystem.getHorizontalPadding(context),
                ),

                // SECTION: MODES
                _buildSectionHeader(context, 'Modes'),
                _buildDrawerItem(
                  context: context,
                  icon: Icons.delivery_dining_rounded,
                  title: 'Mode Livreur',
                  badge: 'Nouveau',
                  onTap: () {
                    Get.back();
                    Get.toNamed('/ship-config');
                  },
                ),
                _buildDrawerItem(
                  context: context,
                  icon: Icons.store_rounded,
                  title: 'Mode Vendeur',
                  onTap: () {
                    Get.back();
                    Get.toNamed(Routes.VENDOR_CONFIG);
                  },
                ),

                SizedBox(height: AppThemeSystem.getElementSpacing(context)),
                Divider(
                  color: context.borderColor,
                  height: 1,
                  indent: AppThemeSystem.getHorizontalPadding(context),
                  endIndent: AppThemeSystem.getHorizontalPadding(context),
                ),

                // SECTION: PARAMÈTRES
                _buildSectionHeader(context, 'Paramètres'),
                _buildDrawerItem(
                  context: context,
                  icon: Icons.settings_rounded,
                  title: 'Paramètres',
                  onTap: () {
                    Get.back();
                    Get.toNamed('/settings');
                  },
                ),
                _buildDrawerItem(
                  context: context,
                  icon: Icons.share_rounded,
                  title: 'Inviter un ami(e)',
                  onTap: () {
                    Get.back();
                    Get.snackbar(
                      'Partager',
                      'Partagez Asso avec vos amis et gagnez des récompenses!',
                      snackPosition: SnackPosition.BOTTOM,
                      duration: const Duration(seconds: 3),
                      backgroundColor: AppThemeSystem.primaryColor,
                      colorText: Colors.white,
                      margin: const EdgeInsets.all(16),
                      borderRadius: 12,
                    );
                  },
                ),

                SizedBox(height: AppThemeSystem.getElementSpacing(context)),
                Divider(
                  color: context.borderColor,
                  height: 1,
                  indent: AppThemeSystem.getHorizontalPadding(context),
                  endIndent: AppThemeSystem.getHorizontalPadding(context),
                ),

                // SECTION: AIDE & SUPPORT
                _buildSectionHeader(context, 'Aide & Support'),
                _buildDrawerItem(
                  context: context,
                  icon: Icons.help_outline_rounded,
                  title: 'Aide & Support',
                  onTap: () {
                    Get.back();
                    Get.snackbar(
                      'Support',
                      'Contactez-nous à support@asso.cm ou appelez le 1234',
                      snackPosition: SnackPosition.BOTTOM,
                      duration: const Duration(seconds: 3),
                      backgroundColor: AppThemeSystem.infoColor,
                      colorText: Colors.white,
                      margin: const EdgeInsets.all(16),
                      borderRadius: 12,
                    );
                  },
                ),
                _buildDrawerItem(
                  context: context,
                  icon: Icons.quiz_rounded,
                  title: 'FAQ',
                  onTap: () {
                    Get.back();
                    Get.snackbar(
                      'FAQ',
                      'Questions fréquemment posées - En cours de développement',
                      snackPosition: SnackPosition.BOTTOM,
                      duration: const Duration(seconds: 2),
                      margin: const EdgeInsets.all(16),
                      borderRadius: 12,
                    );
                  },
                ),
                _buildDrawerItem(
                  context: context,
                  icon: Icons.info_outline_rounded,
                  title: 'À Propos',
                  onTap: () {
                    Get.back();
                    Get.snackbar(
                      'À Propos',
                      'Asso v1.0.0 - Votre marketplace au Cameroun',
                      snackPosition: SnackPosition.BOTTOM,
                      duration: const Duration(seconds: 2),
                      margin: const EdgeInsets.all(16),
                      borderRadius: 12,
                    );
                  },
                ),

                SizedBox(height: AppThemeSystem.getElementSpacing(context)),
              ],
            ),
          ),

          // Footer avec déconnexion
          Container(
            padding: EdgeInsets.all(AppThemeSystem.getHorizontalPadding(context)),
            decoration: BoxDecoration(
              border: Border(
                top: BorderSide(
                  color: context.borderColor,
                  width: 1,
                ),
              ),
            ),
            child: SafeArea(
              top: false,
              child: InkWell(
                onTap: () {
                  Get.back();
                  // Afficher un dialog de confirmation
                  Get.dialog(
                    AlertDialog(
                      title: Text(
                        'Déconnexion',
                        style: context.textStyle(
                          FontSizeType.h5,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      content: Text(
                        'Êtes-vous sûr de vouloir vous déconnecter ?',
                        style: context.textStyle(FontSizeType.body2),
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Get.back(),
                          child: Text(
                            'Annuler',
                            style: context.textStyle(
                              FontSizeType.button,
                              color: context.secondaryTextColor,
                            ),
                          ),
                        ),
                        ElevatedButton(
                          onPressed: () {
                            Get.back();
                            Get.offAllNamed('/login');
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppThemeSystem.errorColor,
                            foregroundColor: Colors.white,
                          ),
                          child: Text(
                            'Déconnexion',
                            style: context.textStyle(
                              FontSizeType.button,
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
                borderRadius: context.borderRadius(BorderRadiusType.medium),
                child: Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: AppThemeSystem.getHorizontalPadding(context) * 0.75,
                    vertical: AppThemeSystem.getVerticalPadding(context) * 0.75,
                  ),
                  decoration: BoxDecoration(
                    color: AppThemeSystem.errorColor.withValues(alpha: 0.1),
                    borderRadius: context.borderRadius(BorderRadiusType.medium),
                    border: Border.all(
                      color: AppThemeSystem.errorColor.withValues(alpha: 0.3),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.logout_rounded,
                        color: AppThemeSystem.errorColor,
                        size: 22,
                      ),
                      const SizedBox(width: 12),
                      Text(
                        'Déconnexion',
                        style: context.textStyle(
                          FontSizeType.body1,
                          color: AppThemeSystem.errorColor,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
        AppThemeSystem.getHorizontalPadding(context),
        AppThemeSystem.getVerticalPadding(context) * 0.75,
        AppThemeSystem.getHorizontalPadding(context),
        AppThemeSystem.getVerticalPadding(context) * 0.25,
      ),
      child: Text(
        title.toUpperCase(),
        style: context.textStyle(
          FontSizeType.caption,
          color: context.secondaryTextColor,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  Widget _buildDrawerItem({
    required BuildContext context,
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    String? badge,
  }) {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: AppThemeSystem.getHorizontalPadding(context) * 0.5,
        vertical: 2,
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: context.borderRadius(BorderRadiusType.small),
        child: Container(
          padding: EdgeInsets.symmetric(
            horizontal: AppThemeSystem.getHorizontalPadding(context) * 0.5,
            vertical: AppThemeSystem.getVerticalPadding(context) * 0.5,
          ),
          child: Row(
            children: [
              // Icône
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppThemeSystem.primaryColor.withValues(alpha: 0.1),
                  borderRadius: context.borderRadius(BorderRadiusType.small),
                ),
                child: Icon(
                  icon,
                  color: AppThemeSystem.primaryColor,
                  size: 20,
                ),
              ),

              SizedBox(width: 12),

              // Titre
              Expanded(
                child: Text(
                  title,
                  style: context.textStyle(
                    FontSizeType.body2,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),

              // Badge (optionnel)
              if (badge != null) ...[
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        AppThemeSystem.primaryColor,
                        AppThemeSystem.tertiaryColor,
                      ],
                    ),
                    borderRadius: context.borderRadius(BorderRadiusType.small),
                  ),
                  child: Text(
                    badge,
                    style: context.textStyle(
                      FontSizeType.overline,
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                SizedBox(width: 8),
              ],

              // Chevron
              Icon(
                Icons.chevron_right_rounded,
                color: context.secondaryTextColor,
                size: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildIconButton({
    required BuildContext context,
    required Widget icon,
    required VoidCallback onPressed,
  }) {
    final deviceType = AppThemeSystem.getDeviceType(context);
    return IconButton(
      icon: icon,
      onPressed: onPressed,
      iconSize: deviceType == DeviceType.mobile ? 24 : 28,
      padding: EdgeInsets.all(deviceType == DeviceType.mobile ? 8 : 10),
      constraints: BoxConstraints(
        minWidth: deviceType == DeviceType.mobile ? 40 : 48,
        minHeight: deviceType == DeviceType.mobile ? 40 : 48,
      ),
    );
  }

  Widget _buildIconButtonWithBadge({
    required BuildContext context,
    required Widget icon,
    required String badgeCount,
    required VoidCallback onPressed,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final deviceType = AppThemeSystem.getDeviceType(context);

    return Stack(
      clipBehavior: Clip.none,
      children: [
        IconButton(
          icon: icon,
          onPressed: onPressed,
          iconSize: deviceType == DeviceType.mobile ? 24 : 28,
          padding: EdgeInsets.all(deviceType == DeviceType.mobile ? 8 : 10),
          constraints: BoxConstraints(
            minWidth: deviceType == DeviceType.mobile ? 40 : 48,
            minHeight: deviceType == DeviceType.mobile ? 40 : 48,
          ),
        ),
        // Badge
        Positioned(
          right: deviceType == DeviceType.mobile ? 6 : 8,
          top: deviceType == DeviceType.mobile ? 6 : 8,
          child: Container(
            padding: EdgeInsets.all(deviceType == DeviceType.mobile ? 3 : 4),
            decoration: BoxDecoration(
              color: AppThemeSystem.errorColor,
              shape: BoxShape.circle,
              border: Border.all(
                color: isDark
                    ? AppThemeSystem.darkCardColor
                    : Colors.white,
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: AppThemeSystem.primaryColor.withValues(alpha: 0.3),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            constraints: BoxConstraints(
              minWidth: deviceType == DeviceType.mobile ? 16 : 18,
              minHeight: deviceType == DeviceType.mobile ? 16 : 18,
            ),
            child: Center(
              child: Text(
                badgeCount,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: deviceType == DeviceType.mobile ? 9 : 10,
                  fontWeight: FontWeight.bold,
                  height: 1.0,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

/// Widget d'icône de tab animé
class _AnimatedTabIcon extends StatefulWidget {
  final TabController controller;
  final int index;
  final IconData icon;
  final String label;

  const _AnimatedTabIcon({
    required this.controller,
    required this.index,
    required this.icon,
    required this.label,
  });

  @override
  State<_AnimatedTabIcon> createState() => _AnimatedTabIconState();
}

class _AnimatedTabIconState extends State<_AnimatedTabIcon> {
  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_onTabChanged);
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onTabChanged);
    super.dispose();
  }

  void _onTabChanged() {
    if (mounted) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isSelected = widget.controller.index == widget.index;
    final deviceType = AppThemeSystem.getDeviceType(context);

    final color = isSelected
        ? AppThemeSystem.primaryColor
        : (isDark ? AppThemeSystem.grey400 : AppThemeSystem.grey600);

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          widget.icon,
          size: deviceType == DeviceType.mobile ? 24 : 28,
          color: color,
        ),
        const SizedBox(height: 4),
        Text(
          widget.label,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(color: color),
        ),
      ],
    );
  }
}
