import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/utils/app_theme_system.dart';
import '../controllers/home_controller.dart';

class AccueilView extends GetView<HomeController> {
  const AccueilView({super.key});

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        // Carousel de bannières
        SliverToBoxAdapter(
          child: _buildBannerCarousel(context),
        ),

        // Catégories horizontales
        SliverToBoxAdapter(
          child: _buildCategories(context),
        ),

        // Section "Proche de vous"
        SliverToBoxAdapter(
          child: _buildSectionTitle(context, 'Proche de vous', Icons.location_on_rounded),
        ),

        // Liste horizontale de produits proches
        SliverToBoxAdapter(
          child: _buildHorizontalProductList(context, controller.products.take(5).toList()),
        ),

        // Section "Récemment postés"
        SliverToBoxAdapter(
          child: _buildSectionTitle(context, 'Récemment postés', Icons.schedule_rounded),
        ),

        // Grille de produits récents
        SliverPadding(
          padding: EdgeInsets.symmetric(
            horizontal: AppThemeSystem.getHorizontalPadding(context),
          ),
          sliver: SliverGrid(
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: AppThemeSystem.getDeviceType(context) == DeviceType.mobile ? 2 : 3,
              childAspectRatio: 0.75,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
            ),
            delegate: SliverChildBuilderDelegate(
              (context, index) => _buildProductCard(context, index),
              childCount: controller.products.length,
            ),
          ),
        ),

        // Espacement en bas
        SliverToBoxAdapter(
          child: SizedBox(height: AppThemeSystem.getVerticalPadding(context) * 2),
        ),
      ],
    );
  }

  Widget _buildCategories(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(
        bottom: 12,
      ),
      height: 48,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(
          horizontal: AppThemeSystem.getHorizontalPadding(context),
        ),
        itemCount: controller.categories.length,
        itemBuilder: (context, index) {
          final category = controller.categories[index];

          return Obx(() {
            final isSelected = controller.selectedCategory.value == category;

            return GestureDetector(
              onTap: () => controller.selectCategory(category),
              child: AnimatedContainer(
                duration: Duration(milliseconds: 200),
                margin: EdgeInsets.only(right: 12),
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                decoration: BoxDecoration(
                  gradient: isSelected
                      ? LinearGradient(
                          colors: [
                            AppThemeSystem.primaryColor,
                            AppThemeSystem.primaryColor.withValues(alpha: 0.8),
                          ],
                        )
                      : null,
                  color: isSelected
                      ? null
                      : AppThemeSystem.getSurfaceColor(context),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isSelected
                        ? AppThemeSystem.primaryColor
                        : AppThemeSystem.getBorderColor(context),
                    width: isSelected ? 0 : 1,
                  ),
                  boxShadow: isSelected
                      ? [
                          BoxShadow(
                            color: AppThemeSystem.primaryColor.withValues(alpha: 0.3),
                            blurRadius: 8,
                            offset: Offset(0, 4),
                          ),
                        ]
                      : null,
                ),
                child: Row(
                  children: [
                    if (index == 0 && isSelected)
                      Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: Icon(
                          Icons.grid_view_rounded,
                          size: 18,
                          color: Colors.white,
                        ),
                      ),
                    Text(
                      category,
                      style: context.textStyle(
                        FontSizeType.body2,
                        fontWeight: FontWeight.w600,
                        color: isSelected
                            ? Colors.white
                            : AppThemeSystem.getPrimaryTextColor(context),
                      ),
                    ),
                  ],
                ),
              ),
            );
          });
        },
      ),
    );
  }

  Widget _buildBannerCarousel(BuildContext context) {
    final deviceType = AppThemeSystem.getDeviceType(context);

    // Titres et descriptions pour chaque bannière
    final bannerData = [
      {
        'title': 'Bienvenue sur Asso',
        'subtitle': 'Découvrez les meilleures offres près de chez vous',
      },
      {
        'title': 'Livraison Rapide',
        'subtitle': 'Recevez vos commandes en moins de 24h',
      },
      {
        'title': 'Prix Imbattables',
        'subtitle': 'Les meilleurs prix du marché camerounais',
      },
    ];

    return Container(
      margin: EdgeInsets.only(
        top: 16,
        bottom: 12,
      ),
      height: deviceType == DeviceType.mobile ? 220 : 260,
      child: Column(
        children: [
          Expanded(
            child: PageView.builder(
              controller: controller.bannerController,
              itemCount: controller.banners.length,
              onPageChanged: (index) {
                controller.currentBannerIndex.value = index;
              },
              itemBuilder: (context, index) {
                final data = bannerData[index % bannerData.length];

                return Container(
                  margin: EdgeInsets.symmetric(
                    horizontal: AppThemeSystem.getHorizontalPadding(context),
                  ),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: AppThemeSystem.primaryColor.withValues(alpha: 0.15),
                        blurRadius: 16,
                        offset: Offset(0, 8),
                        spreadRadius: -4,
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        // Image de fond
                        Image.asset(
                          controller.banners[index],
                          fit: BoxFit.cover,
                        ),

                        // Gradient overlay pour meilleure lisibilité
                        Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                Colors.black.withValues(alpha: 0.3),
                                Colors.black.withValues(alpha: 0.7),
                              ],
                            ),
                          ),
                        ),

                        // Contenu textuel
                        Positioned(
                          left: AppThemeSystem.getHorizontalPadding(context),
                          right: AppThemeSystem.getHorizontalPadding(context),
                          bottom: AppThemeSystem.getVerticalPadding(context),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              // Titre
                              Text(
                                data['title']!,
                                style: context.textStyle(
                                  deviceType == DeviceType.mobile
                                      ? FontSizeType.h3
                                      : FontSizeType.h2,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),

                              SizedBox(height: 8),

                              // Sous-titre
                              Text(
                                data['subtitle']!,
                                style: context.textStyle(
                                  deviceType == DeviceType.mobile
                                      ? FontSizeType.body2
                                      : FontSizeType.body1,
                                  color: Colors.white.withValues(alpha: 0.95),
                                  height: 1.4,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),

                              SizedBox(height: 16),

                              // Bouton CTA
                              Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: 20,
                                  vertical: 10,
                                ),
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      AppThemeSystem.primaryColor,
                                      AppThemeSystem.tertiaryColor,
                                    ],
                                  ),
                                  borderRadius: BorderRadius.circular(8),
                                  boxShadow: [
                                    BoxShadow(
                                      color: AppThemeSystem.primaryColor.withValues(alpha: 0.4),
                                      blurRadius: 12,
                                      offset: Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: Text(
                                  'Découvrir',
                                  style: context.textStyle(
                                    FontSizeType.button,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          SizedBox(height: 16),
          // Indicateurs améliorés
          Obx(() => Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(
              controller.banners.length,
              (index) => AnimatedContainer(
                duration: Duration(milliseconds: 300),
                margin: EdgeInsets.symmetric(horizontal: 4),
                width: controller.currentBannerIndex.value == index ? 28 : 8,
                height: 8,
                decoration: BoxDecoration(
                  color: controller.currentBannerIndex.value == index
                      ? AppThemeSystem.primaryColor
                      : AppThemeSystem.grey300,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
          )),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title, IconData icon) {
    return Padding(
      padding: EdgeInsets.only(
        left: AppThemeSystem.getHorizontalPadding(context),
        right: AppThemeSystem.getHorizontalPadding(context),
        top: 8,
        bottom: 12,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppThemeSystem.primaryColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  icon,
                  color: AppThemeSystem.primaryColor,
                  size: 20,
                ),
              ),
              SizedBox(width: 12),
              Text(
                title,
                style: context.textStyle(
                  FontSizeType.h4,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          TextButton(
            onPressed: () {},
            child: Row(
              children: [
                Text(
                  'Voir tout',
                  style: context.textStyle(
                    FontSizeType.body2,
                    color: AppThemeSystem.primaryColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(width: 4),
                Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 14,
                  color: AppThemeSystem.primaryColor,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHorizontalProductList(BuildContext context, List<Map<String, dynamic>> products) {
    return Container(
      height: 280,
      margin: EdgeInsets.only(bottom: 8),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(
          horizontal: AppThemeSystem.getHorizontalPadding(context),
        ),
        itemCount: products.length,
        itemBuilder: (context, index) {
          final product = products[index];
          return Container(
            width: 180,
            margin: EdgeInsets.only(right: 16),
            child: GestureDetector(
              onTap: () => controller.onProductTap(index),
              child: Container(
                decoration: BoxDecoration(
                  color: AppThemeSystem.getSurfaceColor(context),
                  borderRadius: context.borderRadius(BorderRadiusType.medium),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.08),
                      blurRadius: 12,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Image du produit
                    Expanded(
                      child: Stack(
                        children: [
                          Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(AppThemeSystem.getBorderRadius(context, BorderRadiusType.medium)),
                                topRight: Radius.circular(AppThemeSystem.getBorderRadius(context, BorderRadiusType.medium)),
                              ),
                              image: DecorationImage(
                                image: AssetImage(product['image']),
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                          // Badge favori
                          Positioned(
                            top: 8,
                            right: 8,
                            child: Container(
                              padding: EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.15),
                                    blurRadius: 6,
                                  ),
                                ],
                              ),
                              child: Icon(
                                Icons.favorite_border_rounded,
                                size: 16,
                                color: AppThemeSystem.grey600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Infos produit
                    Padding(
                      padding: EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Nom
                          Text(
                            product['name'],
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: context.textStyle(
                              FontSizeType.body2,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          SizedBox(height: 8),
                          // Prix
                          Text(
                            '${product['price']} FCFA',
                            style: context.textStyle(
                              FontSizeType.subtitle2,
                              fontWeight: FontWeight.bold,
                              color: AppThemeSystem.primaryColor,
                            ),
                          ),
                          SizedBox(height: 6),
                          // Localisation
                          Row(
                            children: [
                              Icon(
                                Icons.location_on_outlined,
                                size: 14,
                                color: AppThemeSystem.grey600,
                              ),
                              SizedBox(width: 4),
                              Expanded(
                                child: Text(
                                  product['location'],
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: context.textStyle(
                                    FontSizeType.caption,
                                    color: AppThemeSystem.grey600,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildProductCard(BuildContext context, int index) {
    final product = controller.products[index];

    return GestureDetector(
      onTap: () => controller.onProductTap(index),
      child: Container(
        decoration: BoxDecoration(
          color: AppThemeSystem.getSurfaceColor(context),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: AppThemeSystem.getBorderColor(context).withValues(alpha: 0.5),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 12,
              offset: Offset(0, 4),
              spreadRadius: -2,
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image du produit
            Expanded(
              child: Stack(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(16),
                        topRight: Radius.circular(16),
                      ),
                      image: DecorationImage(
                        image: AssetImage(product['image']),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  // Gradient overlay for better readability
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(16),
                        topRight: Radius.circular(16),
                      ),
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.black.withValues(alpha: 0),
                          Colors.black.withValues(alpha: 0.02),
                        ],
                      ),
                    ),
                  ),
                  // Badge favori
                  Positioned(
                    top: 10,
                    right: 10,
                    child: Container(
                      padding: EdgeInsets.all(7),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.95),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.15),
                            blurRadius: 8,
                            spreadRadius: 0,
                          ),
                        ],
                      ),
                      child: Icon(
                        Icons.favorite_border_rounded,
                        size: 18,
                        color: AppThemeSystem.grey700,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Infos produit
            Padding(
              padding: EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Nom
                  Text(
                    product['name'],
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: context.textStyle(
                      FontSizeType.body2,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: 8),
                  // Prix
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppThemeSystem.primaryColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      '${product['price']} FCFA',
                      style: context.textStyle(
                        FontSizeType.body2,
                        fontWeight: FontWeight.bold,
                        color: AppThemeSystem.primaryColor,
                      ),
                    ),
                  ),
                  SizedBox(height: 8),
                  // Localisation
                  Row(
                    children: [
                      Icon(
                        Icons.location_on_rounded,
                        size: 14,
                        color: AppThemeSystem.grey600,
                      ),
                      SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          product['location'],
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: context.textStyle(
                            FontSizeType.caption,
                            color: AppThemeSystem.grey600,
                          ),
                        ),
                      ),
                    ],
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
