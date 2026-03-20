import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../routes/app_pages.dart';

class PreferencesController extends GetxController {
  // Catégories d'intérêt avec sous-catégories
  final List<CategoryItem> categories = [
    CategoryItem(
      id: 'fashion',
      name: 'Mode & Vêtements',
      svgPath: 'assets/svgs/categories/fashion.svg',
      subcategories: [
        SubcategoryItem(id: 'fashion_men', name: 'Homme'),
        SubcategoryItem(id: 'fashion_women', name: 'Femme'),
        SubcategoryItem(id: 'fashion_kids', name: 'Enfants'),
        SubcategoryItem(id: 'fashion_shoes', name: 'Chaussures'),
        SubcategoryItem(id: 'fashion_accessories', name: 'Accessoires'),
      ],
    ),
    CategoryItem(
      id: 'electronics',
      name: 'Électronique',
      svgPath: 'assets/svgs/categories/electronics.svg',
      subcategories: [
        SubcategoryItem(id: 'electronics_phones', name: 'Téléphones'),
        SubcategoryItem(id: 'electronics_computers', name: 'Ordinateurs'),
        SubcategoryItem(id: 'electronics_tablets', name: 'Tablettes'),
        SubcategoryItem(id: 'electronics_accessories', name: 'Accessoires'),
        SubcategoryItem(id: 'electronics_audio', name: 'Audio & Vidéo'),
      ],
    ),
    CategoryItem(
      id: 'food',
      name: 'Alimentation',
      svgPath: 'assets/svgs/categories/food.svg',
      subcategories: [
        SubcategoryItem(id: 'food_fresh', name: 'Produits frais'),
        SubcategoryItem(id: 'food_grocery', name: 'Épicerie'),
        SubcategoryItem(id: 'food_drinks', name: 'Boissons'),
        SubcategoryItem(id: 'food_snacks', name: 'Snacks'),
        SubcategoryItem(id: 'food_organic', name: 'Bio & Local'),
      ],
    ),
    CategoryItem(
      id: 'beauty',
      name: 'Beauté & Santé',
      svgPath: 'assets/svgs/categories/beauty.svg',
      subcategories: [
        SubcategoryItem(id: 'beauty_skincare', name: 'Soins de la peau'),
        SubcategoryItem(id: 'beauty_makeup', name: 'Maquillage'),
        SubcategoryItem(id: 'beauty_haircare', name: 'Soins capillaires'),
        SubcategoryItem(id: 'beauty_perfume', name: 'Parfums'),
        SubcategoryItem(id: 'beauty_wellness', name: 'Bien-être'),
      ],
    ),
    CategoryItem(
      id: 'sports',
      name: 'Sport & Loisirs',
      svgPath: 'assets/svgs/categories/sports.svg',
      subcategories: [
        SubcategoryItem(id: 'sports_fitness', name: 'Fitness'),
        SubcategoryItem(id: 'sports_outdoor', name: 'Activités outdoor'),
        SubcategoryItem(id: 'sports_team', name: 'Sports d\'équipe'),
        SubcategoryItem(id: 'sports_equipment', name: 'Équipements'),
        SubcategoryItem(id: 'sports_clothing', name: 'Vêtements de sport'),
      ],
    ),
    CategoryItem(
      id: 'home',
      name: 'Maison & Déco',
      svgPath: 'assets/svgs/categories/home.svg',
      subcategories: [
        SubcategoryItem(id: 'home_furniture', name: 'Meubles'),
        SubcategoryItem(id: 'home_decoration', name: 'Décoration'),
        SubcategoryItem(id: 'home_kitchen', name: 'Cuisine'),
        SubcategoryItem(id: 'home_bedding', name: 'Literie'),
        SubcategoryItem(id: 'home_appliances', name: 'Électroménager'),
      ],
    ),
    CategoryItem(
      id: 'books',
      name: 'Livres & Culture',
      svgPath: 'assets/svgs/categories/books.svg',
      subcategories: [
        SubcategoryItem(id: 'books_fiction', name: 'Fiction'),
        SubcategoryItem(id: 'books_nonfiction', name: 'Non-fiction'),
        SubcategoryItem(id: 'books_education', name: 'Éducation'),
        SubcategoryItem(id: 'books_comics', name: 'BD & Comics'),
        SubcategoryItem(id: 'books_magazines', name: 'Magazines'),
      ],
    ),
    CategoryItem(
      id: 'toys',
      name: 'Jouets & Enfants',
      svgPath: 'assets/svgs/categories/toys.svg',
      subcategories: [
        SubcategoryItem(id: 'toys_baby', name: 'Bébé (0-2 ans)'),
        SubcategoryItem(id: 'toys_preschool', name: 'Préscolaire (3-5 ans)'),
        SubcategoryItem(id: 'toys_kids', name: 'Enfants (6-12 ans)'),
        SubcategoryItem(id: 'toys_educational', name: 'Éducatifs'),
        SubcategoryItem(id: 'toys_games', name: 'Jeux de société'),
      ],
    ),
    CategoryItem(
      id: 'automotive',
      name: 'Auto & Moto',
      svgPath: 'assets/svgs/categories/automotive.svg',
      subcategories: [
        SubcategoryItem(id: 'automotive_cars', name: 'Voitures'),
        SubcategoryItem(id: 'automotive_motorcycles', name: 'Motos'),
        SubcategoryItem(id: 'automotive_parts', name: 'Pièces détachées'),
        SubcategoryItem(id: 'automotive_accessories', name: 'Accessoires'),
        SubcategoryItem(id: 'automotive_maintenance', name: 'Entretien'),
      ],
    ),
    CategoryItem(
      id: 'services',
      name: 'Services',
      svgPath: 'assets/svgs/categories/services.svg',
      subcategories: [
        SubcategoryItem(id: 'services_home', name: 'Services à domicile'),
        SubcategoryItem(id: 'services_repair', name: 'Réparation'),
        SubcategoryItem(id: 'services_delivery', name: 'Livraison'),
        SubcategoryItem(id: 'services_cleaning', name: 'Nettoyage'),
        SubcategoryItem(id: 'services_professional', name: 'Services pro'),
      ],
    ),
  ];

  // Préférences sélectionnées
  final RxSet<String> selectedSubcategories = <String>{}.obs;

  // Catégories expandues
  final RxSet<String> expandedCategories = <String>{}.obs;

  @override
  void onInit() {
    super.onInit();
    _loadPreferences();
  }

  void _loadPreferences() {
    // TODO: Charger depuis le storage local
  }

  void toggleCategory(String categoryId) {
    if (expandedCategories.contains(categoryId)) {
      expandedCategories.remove(categoryId);
    } else {
      expandedCategories.add(categoryId);
    }
  }

  void toggleSubcategory(String subcategoryId) {
    if (selectedSubcategories.contains(subcategoryId)) {
      selectedSubcategories.remove(subcategoryId);
    } else {
      selectedSubcategories.add(subcategoryId);
    }
  }

  bool isCategorySelected(String categoryId) {
    final category = categories.firstWhere((cat) => cat.id == categoryId);
    return category.subcategories.any(
      (sub) => selectedSubcategories.contains(sub.id),
    );
  }

  int getCategorySelectionCount(String categoryId) {
    final category = categories.firstWhere((cat) => cat.id == categoryId);
    return category.subcategories
        .where((sub) => selectedSubcategories.contains(sub.id))
        .length;
  }

  Future<void> saveAndContinue() async {
    // Vérifier qu'au moins une sous-catégorie est sélectionnée
    if (selectedSubcategories.isEmpty) {
      Get.snackbar(
        'Préférences',
        'Veuillez sélectionner au moins une catégorie d\'intérêt',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Get.theme.colorScheme.error,
        colorText: Get.theme.colorScheme.onError,
        margin: const EdgeInsets.all(16),
        borderRadius: 12,
      );
      return;
    }

    // TODO: Sauvegarder les préférences dans le storage local
    // await _savePreferences();

    // Afficher un message de succès
    Get.snackbar(
      'Préférences sauvegardées',
      '${selectedSubcategories.length} catégorie(s) enregistrée(s)',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Get.theme.colorScheme.primary,
      colorText: Colors.white,
      margin: const EdgeInsets.all(16),
      borderRadius: 12,
      duration: const Duration(seconds: 2),
    );

    // Naviguer vers Home
    await Future.delayed(const Duration(milliseconds: 500));
    Get.offAllNamed(Routes.HOME);
  }

  void skipPreferences() {
    Get.offAllNamed(Routes.HOME);
  }
}

class CategoryItem {
  final String id;
  final String name;
  final String svgPath;
  final List<SubcategoryItem> subcategories;

  CategoryItem({
    required this.id,
    required this.name,
    required this.svgPath,
    required this.subcategories,
  });
}

class SubcategoryItem {
  final String id;
  final String name;

  SubcategoryItem({
    required this.id,
    required this.name,
  });
}
