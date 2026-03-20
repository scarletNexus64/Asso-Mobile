import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:dotted_border/dotted_border.dart';
import '../../../core/utils/app_theme_system.dart';
import '../controllers/add_product_controller.dart';

class AddProductView extends GetView<AddProductController> {
  const AddProductView({super.key});

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
          'Ajouter un produit',
          style: context.h5.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(context.horizontalPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Section Images
            _buildImagesSection(context),

            SizedBox(height: context.sectionSpacing),

            // Nom du produit
            _buildNameSection(context),

            SizedBox(height: context.sectionSpacing),

            // Catégorie (Bottom sheet)
            _buildCategorySelector(context),

            SizedBox(height: context.sectionSpacing),

            // Sous-catégorie (Bottom sheet - apparaît seulement si catégorie sélectionnée)
            _buildSubcategorySelector(context),

            SizedBox(height: context.sectionSpacing),

            // Type d'article
            _buildArticleTypeSection(context),

            SizedBox(height: context.sectionSpacing),

            // Type de prix
            _buildPriceTypeSection(context),

            SizedBox(height: context.sectionSpacing),

            // Description
            _buildDescriptionSection(context),

            SizedBox(height: context.sectionSpacing),

            // Espace de stockage
            _buildStorageSection(context),

            SizedBox(height: context.sectionSpacing * 2),

            // Bouton de soumission
            _buildSubmitButton(context),

            SizedBox(height: context.verticalPadding),
          ],
        ),
      ),
    );
  }

  /// Section Images avec sélection multiple et choix de l'image primaire
  Widget _buildImagesSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              'Images du produit',
              style: context.h5.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: AppThemeSystem.errorColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                'Obligatoire',
                style: context.caption.copyWith(
                  color: AppThemeSystem.errorColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: context.elementSpacing * 0.5),
        Text(
          'Ajoutez plusieurs images et sélectionnez l\'image principale',
          style: context.caption.copyWith(
            color: context.secondaryTextColor,
          ),
        ),
        SizedBox(height: context.elementSpacing),

        Obx(() {
          return SizedBox(
            height: 120,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: [
                // Bouton unique pour upload images
                _buildAddImageButton(
                  context,
                  icon: Icons.add_photo_alternate,
                  label: 'Upload Images',
                  onTap: controller.pickImages,
                ),
                const SizedBox(width: 12),

                // Liste des images
                ...List.generate(controller.productImages.length, (index) {
                  return Padding(
                    padding: const EdgeInsets.only(right: 12),
                    child: _buildImageThumbnail(context, index),
                  );
                }),
              ],
            ),
          );
        }),
      ],
    );
  }

  Widget _buildAddImageButton(
    BuildContext context, {
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 120,
        decoration: BoxDecoration(
          color: context.surfaceColor,
          borderRadius: context.borderRadius(BorderRadiusType.medium),
          border: Border.all(
            color: AppThemeSystem.primaryColor,
            width: 2,
            style: BorderStyle.none,
          ),
        ),
        child: DottedBorder(
          color: AppThemeSystem.primaryColor,
          strokeWidth: 2,
          dashPattern: const [8, 4],
          borderType: BorderType.RRect,
          radius: const Radius.circular(12),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppThemeSystem.primaryColor.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.arrow_upward,
                    color: AppThemeSystem.primaryColor,
                    size: 28,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  label,
                  style: context.caption.copyWith(
                    color: AppThemeSystem.primaryColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildImageThumbnail(BuildContext context, int index) {
    return Obx(() {
      final isPrimary = controller.primaryImageIndex.value == index;

      return Stack(
        children: [
          GestureDetector(
            onTap: () => controller.setPrimaryImage(index),
            child: Container(
              width: 100,
              decoration: BoxDecoration(
                borderRadius: context.borderRadius(BorderRadiusType.medium),
                border: Border.all(
                  color: isPrimary
                      ? AppThemeSystem.successColor
                      : context.borderColor,
                  width: isPrimary ? 3 : 1,
                ),
              ),
              child: ClipRRect(
                borderRadius: context.borderRadius(BorderRadiusType.medium),
                child: Image.file(
                  controller.productImages[index],
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),

          // Badge "Principale"
          if (isPrimary)
            Positioned(
              top: 4,
              left: 4,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: AppThemeSystem.successColor,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  'Principale',
                  style: context.caption.copyWith(
                    color: Colors.white,
                    fontSize: 9,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),

          // Bouton supprimer
          Positioned(
            top: 4,
            right: 4,
            child: GestureDetector(
              onTap: () => controller.removeImage(index),
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: AppThemeSystem.errorColor,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.close,
                  color: Colors.white,
                  size: 16,
                ),
              ),
            ),
          ),
        ],
      );
    });
  }

  /// Section Nom du produit
  Widget _buildNameSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Nom du produit *',
          style: context.subtitle1.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: context.elementSpacing),
        TextField(
          controller: controller.nameController,
          decoration: InputDecoration(
            hintText: 'Ex: iPhone 13 Pro Max',
            filled: true,
            fillColor: context.surfaceColor,
            prefixIcon: const Icon(Icons.inventory_2_outlined),
            border: OutlineInputBorder(
              borderRadius: context.borderRadius(BorderRadiusType.medium),
              borderSide: BorderSide(color: context.borderColor),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: context.borderRadius(BorderRadiusType.medium),
              borderSide: BorderSide(color: context.borderColor),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: context.borderRadius(BorderRadiusType.medium),
              borderSide: const BorderSide(
                color: AppThemeSystem.primaryColor,
                width: 2,
              ),
            ),
          ),
        ),
      ],
    );
  }

  /// Sélecteur de catégorie avec bottom sheet
  Widget _buildCategorySelector(BuildContext context) {
    return Obx(() {
      final category = controller.selectedCategory.value;

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Catégorie *',
            style: context.subtitle1.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: context.elementSpacing),
          GestureDetector(
            onTap: () => _showCategoryBottomSheet(context),
            child: Container(
              padding: EdgeInsets.all(context.horizontalPadding),
              decoration: BoxDecoration(
                color: category != null
                    ? AppThemeSystem.primaryColor.withValues(alpha: 0.1)
                    : context.surfaceColor,
                borderRadius: context.borderRadius(BorderRadiusType.medium),
                border: Border.all(
                  color: category != null
                      ? AppThemeSystem.primaryColor
                      : context.borderColor,
                  width: category != null ? 2 : 1,
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.folder_outlined,
                    color: category != null
                        ? AppThemeSystem.primaryColor
                        : context.secondaryTextColor,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      category ?? 'Sélectionnez une catégorie',
                      style: context.body1.copyWith(
                        color: category != null
                            ? AppThemeSystem.primaryColor
                            : context.secondaryTextColor,
                        fontWeight: category != null
                            ? FontWeight.w600
                            : FontWeight.normal,
                      ),
                    ),
                  ),
                  Icon(
                    Icons.arrow_drop_down,
                    color: category != null
                        ? AppThemeSystem.primaryColor
                        : context.secondaryTextColor,
                  ),
                ],
              ),
            ),
          ),
        ],
      );
    });
  }

  /// Sélecteur de sous-catégorie avec bottom sheet
  Widget _buildSubcategorySelector(BuildContext context) {
    return Obx(() {
      final category = controller.selectedCategory.value;
      final subcategory = controller.selectedSubcategory.value;

      // N'afficher que si une catégorie est sélectionnée
      if (category == null) {
        return const SizedBox.shrink();
      }

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Sous-catégorie *',
            style: context.subtitle1.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: context.elementSpacing),
          GestureDetector(
            onTap: () => _showSubcategoryBottomSheet(context),
            child: Container(
              padding: EdgeInsets.all(context.horizontalPadding),
              decoration: BoxDecoration(
                color: subcategory != null
                    ? AppThemeSystem.primaryColor.withValues(alpha: 0.1)
                    : context.surfaceColor,
                borderRadius: context.borderRadius(BorderRadiusType.medium),
                border: Border.all(
                  color: subcategory != null
                      ? AppThemeSystem.primaryColor
                      : context.borderColor,
                  width: subcategory != null ? 2 : 1,
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.category_outlined,
                    color: subcategory != null
                        ? AppThemeSystem.primaryColor
                        : context.secondaryTextColor,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      subcategory ?? 'Sélectionnez une sous-catégorie',
                      style: context.body1.copyWith(
                        color: subcategory != null
                            ? AppThemeSystem.primaryColor
                            : context.secondaryTextColor,
                        fontWeight: subcategory != null
                            ? FontWeight.w600
                            : FontWeight.normal,
                      ),
                    ),
                  ),
                  Icon(
                    Icons.arrow_drop_down,
                    color: subcategory != null
                        ? AppThemeSystem.primaryColor
                        : context.secondaryTextColor,
                  ),
                ],
              ),
            ),
          ),
        ],
      );
    });
  }

  /// Bottom sheet pour sélectionner la catégorie
  void _showCategoryBottomSheet(BuildContext context) {
    final searchController = TextEditingController();
    final categories = controller.categoriesData.keys.toList();
    final filteredCategories = categories.obs;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          height: MediaQuery.of(context).size.height * 0.7,
          decoration: BoxDecoration(
            color: context.backgroundColor,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              // Header
              Container(
                padding: EdgeInsets.all(context.horizontalPadding),
                decoration: BoxDecoration(
                  color: context.surfaceColor,
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                  border: Border(
                    bottom: BorderSide(color: context.borderColor),
                  ),
                ),
                child: Column(
                  children: [
                    // Handle
                    Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: context.borderColor,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            'Sélectionner une catégorie',
                            style: context.h5.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close),
                          onPressed: () => Navigator.pop(context),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    // Barre de recherche
                    TextField(
                      controller: searchController,
                      decoration: InputDecoration(
                        hintText: 'Rechercher...',
                        prefixIcon: const Icon(Icons.search),
                        filled: true,
                        fillColor: context.backgroundColor,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                      ),
                      onChanged: (value) {
                        if (value.isEmpty) {
                          filteredCategories.value = categories;
                        } else {
                          filteredCategories.value = categories
                              .where((cat) => cat.toLowerCase().contains(value.toLowerCase()))
                              .toList();
                        }
                      },
                    ),
                  ],
                ),
              ),

              // Liste
              Expanded(
                child: Obx(() {
                  return ListView.separated(
                    padding: EdgeInsets.all(context.horizontalPadding),
                    itemCount: filteredCategories.length,
                    separatorBuilder: (context, index) => Divider(
                      height: 1,
                      color: context.borderColor,
                    ),
                    itemBuilder: (context, index) {
                      final category = filteredCategories[index];
                      final isSelected = controller.selectedCategory.value == category;

                      return ListTile(
                        leading: Icon(
                          Icons.folder,
                          color: isSelected
                              ? AppThemeSystem.primaryColor
                              : context.secondaryTextColor,
                        ),
                        title: Text(
                          category,
                          style: context.body1.copyWith(
                            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                            color: isSelected
                                ? AppThemeSystem.primaryColor
                                : context.primaryTextColor,
                          ),
                        ),
                        trailing: isSelected
                            ? Icon(
                                Icons.check_circle,
                                color: AppThemeSystem.successColor,
                              )
                            : null,
                        onTap: () {
                          controller.selectedCategory.value = category;
                          // Réinitialiser la sous-catégorie
                          controller.selectedSubcategory.value = null;
                          Navigator.pop(context);
                        },
                      );
                    },
                  );
                }),
              ),
            ],
          ),
        );
      },
    );
  }

  /// Bottom sheet pour sélectionner la sous-catégorie
  void _showSubcategoryBottomSheet(BuildContext context) {
    final searchController = TextEditingController();
    final category = controller.selectedCategory.value;

    if (category == null) return;

    final subcategories = controller.categoriesData[category] ?? [];
    final filteredSubcategories = subcategories.obs;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          height: MediaQuery.of(context).size.height * 0.7,
          decoration: BoxDecoration(
            color: context.backgroundColor,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              // Header
              Container(
                padding: EdgeInsets.all(context.horizontalPadding),
                decoration: BoxDecoration(
                  color: context.surfaceColor,
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                  border: Border(
                    bottom: BorderSide(color: context.borderColor),
                  ),
                ),
                child: Column(
                  children: [
                    // Handle
                    Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: context.borderColor,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            'Sous-catégories de $category',
                            style: context.h6.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close),
                          onPressed: () => Navigator.pop(context),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    // Barre de recherche
                    TextField(
                      controller: searchController,
                      decoration: InputDecoration(
                        hintText: 'Rechercher...',
                        prefixIcon: const Icon(Icons.search),
                        filled: true,
                        fillColor: context.backgroundColor,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                      ),
                      onChanged: (value) {
                        if (value.isEmpty) {
                          filteredSubcategories.value = subcategories;
                        } else {
                          filteredSubcategories.value = subcategories
                              .where((sub) =>
                                  sub['name']!.toLowerCase().contains(value.toLowerCase()))
                              .toList();
                        }
                      },
                    ),
                  ],
                ),
              ),

              // Liste
              Expanded(
                child: Obx(() {
                  return ListView.separated(
                    padding: EdgeInsets.all(context.horizontalPadding),
                    itemCount: filteredSubcategories.length,
                    separatorBuilder: (context, index) => Divider(
                      height: 1,
                      color: context.borderColor,
                    ),
                    itemBuilder: (context, index) {
                      final subcategory = filteredSubcategories[index];
                      final isSelected =
                          controller.selectedSubcategory.value == subcategory['name'];

                      return ListTile(
                        leading: Icon(
                          Icons.category,
                          color: isSelected
                              ? AppThemeSystem.primaryColor
                              : context.secondaryTextColor,
                        ),
                        title: Text(
                          subcategory['name']!,
                          style: context.body1.copyWith(
                            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                            color: isSelected
                                ? AppThemeSystem.primaryColor
                                : context.primaryTextColor,
                          ),
                        ),
                        trailing: isSelected
                            ? Icon(
                                Icons.check_circle,
                                color: AppThemeSystem.successColor,
                              )
                            : null,
                        onTap: () {
                          controller.selectedSubcategory.value = subcategory['name'];
                          Navigator.pop(context);
                        },
                      );
                    },
                  );
                }),
              ),
            ],
          ),
        );
      },
    );
  }

  /// Section Type d'article
  Widget _buildArticleTypeSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Type d\'article *',
          style: context.subtitle1.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: context.elementSpacing),
        Obx(() => Row(
          children: [
            Expanded(
              child: _buildTypeCard(
                context,
                icon: Icons.shopping_bag_outlined,
                label: 'Article',
                isSelected: controller.articleType.value == 'article',
                onTap: () => controller.articleType.value = 'article',
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildTypeCard(
                context,
                icon: Icons.handyman_outlined,
                label: 'Service',
                isSelected: controller.articleType.value == 'service',
                onTap: () => controller.articleType.value = 'service',
              ),
            ),
          ],
        )),
      ],
    );
  }

  Widget _buildTypeCard(
    BuildContext context, {
    required IconData icon,
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(
          vertical: context.verticalPadding,
        ),
        decoration: BoxDecoration(
          color: isSelected
              ? AppThemeSystem.primaryColor.withValues(alpha: 0.1)
              : context.surfaceColor,
          borderRadius: context.borderRadius(BorderRadiusType.medium),
          border: Border.all(
            color: isSelected
                ? AppThemeSystem.primaryColor
                : context.borderColor,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: isSelected
                  ? AppThemeSystem.primaryColor
                  : context.secondaryTextColor,
              size: 32,
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: context.body1.copyWith(
                color: isSelected
                    ? AppThemeSystem.primaryColor
                    : context.primaryTextColor,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Section Type de prix
  Widget _buildPriceTypeSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Type de prix *',
          style: context.subtitle1.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: context.elementSpacing),

        // Boutons de sélection
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            _buildPriceTypeChip(
              context,
              label: 'Prix fixe',
              value: 'fixed',
              icon: Icons.attach_money,
            ),
            _buildPriceTypeChip(
              context,
              label: 'À découvrir',
              value: 'discover',
              icon: Icons.help_outline,
            ),
            _buildPriceTypeChip(
              context,
              label: 'Visite',
              value: 'visit',
              icon: Icons.visibility_outlined,
            ),
          ],
        ),

        // Champ de prix (si prix fixe)
        Obx(() {
          if (controller.priceType.value != 'fixed') {
            return const SizedBox.shrink();
          }

          return Column(
            children: [
              SizedBox(height: context.elementSpacing),
              TextField(
                controller: controller.priceController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  hintText: 'Entrez le prix',
                  filled: true,
                  fillColor: context.surfaceColor,
                  prefixIcon: const Icon(Icons.payments_outlined),
                  suffixText: 'XAF',
                  border: OutlineInputBorder(
                    borderRadius: context.borderRadius(BorderRadiusType.medium),
                    borderSide: BorderSide(color: context.borderColor),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: context.borderRadius(BorderRadiusType.medium),
                    borderSide: BorderSide(color: context.borderColor),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: context.borderRadius(BorderRadiusType.medium),
                    borderSide: const BorderSide(
                      color: AppThemeSystem.primaryColor,
                      width: 2,
                    ),
                  ),
                ),
              ),
            ],
          );
        }),
      ],
    );
  }

  Widget _buildPriceTypeChip(
    BuildContext context, {
    required String label,
    required String value,
    required IconData icon,
  }) {
    return Obx(() {
      final isSelected = controller.priceType.value == value;

      return FilterChip(
        label: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 18,
              color: isSelected ? Colors.white : context.primaryTextColor,
            ),
            const SizedBox(width: 6),
            Text(label),
          ],
        ),
        selected: isSelected,
        onSelected: (selected) {
          if (selected) {
            controller.priceType.value = value;
          }
        },
        selectedColor: AppThemeSystem.primaryColor,
        checkmarkColor: Colors.white,
        backgroundColor: context.surfaceColor,
        side: BorderSide(
          color: isSelected
              ? AppThemeSystem.primaryColor
              : context.borderColor,
          width: isSelected ? 2 : 1,
        ),
        labelStyle: context.body2.copyWith(
          color: isSelected ? Colors.white : context.primaryTextColor,
          fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      );
    });
  }

  /// Section Description
  Widget _buildDescriptionSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Description *',
          style: context.subtitle1.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: context.elementSpacing),
        TextField(
          controller: controller.descriptionController,
          maxLines: 5,
          decoration: InputDecoration(
            hintText: 'Décrivez votre produit en détail...',
            filled: true,
            fillColor: context.surfaceColor,
            border: OutlineInputBorder(
              borderRadius: context.borderRadius(BorderRadiusType.medium),
              borderSide: BorderSide(color: context.borderColor),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: context.borderRadius(BorderRadiusType.medium),
              borderSide: BorderSide(color: context.borderColor),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: context.borderRadius(BorderRadiusType.medium),
              borderSide: const BorderSide(
                color: AppThemeSystem.primaryColor,
                width: 2,
              ),
            ),
          ),
        ),
      ],
    );
  }

  /// Section Espace de stockage
  Widget _buildStorageSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                'Espace de stockage *',
                style: context.subtitle1.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            TextButton.icon(
              onPressed: controller.addNewStorage,
              icon: const Icon(Icons.add_circle_outline, size: 20),
              label: const Text('Ajouter'),
              style: TextButton.styleFrom(
                foregroundColor: AppThemeSystem.primaryColor,
              ),
            ),
          ],
        ),
        SizedBox(height: context.elementSpacing),

        Obx(() => Column(
          children: controller.storageList.map((storage) {
            final isSelected = controller.selectedStorage.value?['id'] == storage['id'];
            final available = storage['available'] as double;
            final total = storage['total'] as double;
            final percentage = (available / total * 100).toInt();

            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              child: GestureDetector(
                onTap: () => controller.selectedStorage.value = storage,
                child: Container(
                  padding: EdgeInsets.all(context.horizontalPadding),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? AppThemeSystem.primaryColor.withValues(alpha: 0.1)
                        : context.surfaceColor,
                    borderRadius: context.borderRadius(BorderRadiusType.medium),
                    border: Border.all(
                      color: isSelected
                          ? AppThemeSystem.primaryColor
                          : context.borderColor,
                      width: isSelected ? 2 : 1,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.storage,
                            color: isSelected
                                ? AppThemeSystem.primaryColor
                                : context.secondaryTextColor,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              storage['name'],
                              style: context.body1.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          if (isSelected)
                            Icon(
                              Icons.check_circle,
                              color: AppThemeSystem.successColor,
                            ),
                        ],
                      ),
                      const SizedBox(height: 12),

                      // Barre de progression
                      ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(
                          value: available / total,
                          backgroundColor: context.borderColor,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            percentage > 50
                                ? AppThemeSystem.successColor
                                : percentage > 20
                                    ? AppThemeSystem.warningColor
                                    : AppThemeSystem.errorColor,
                          ),
                          minHeight: 6,
                        ),
                      ),
                      const SizedBox(height: 8),

                      Text(
                        '${available.toStringAsFixed(1)} GB disponible sur ${total.toStringAsFixed(0)} GB ($percentage%)',
                        style: context.caption.copyWith(
                          color: context.secondaryTextColor,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }).toList(),
        )),
      ],
    );
  }

  /// Bouton de soumission
  Widget _buildSubmitButton(BuildContext context) {
    return Obx(() {
      final isLoading = controller.isLoading.value;

      return SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: isLoading ? null : controller.submitProduct,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppThemeSystem.primaryColor,
            foregroundColor: Colors.white,
            padding: EdgeInsets.symmetric(
              vertical: context.verticalPadding,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: context.borderRadius(BorderRadiusType.medium),
            ),
          ),
          child: isLoading
              ? const SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                )
              : Text(
                  'Ajouter le produit',
                  style: context.button.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
        ),
      );
    });
  }
}
