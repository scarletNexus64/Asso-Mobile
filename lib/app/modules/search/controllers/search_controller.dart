import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import '../../../data/models/product_model.dart';

class SearchController extends GetxController {
  // ================================
  // SERVICES ET STORAGE
  // ================================
  final _storage = GetStorage();
  final TextEditingController searchTextController = TextEditingController();
  final FocusNode searchFocusNode = FocusNode();

  // ================================
  // DONNÉES DES PRODUITS
  // ================================
  // TODO: Remplacer par un appel API dans le futur
  final RxList<ProductModel> allProducts = <ProductModel>[].obs;
  final RxList<ProductModel> filteredProducts = <ProductModel>[].obs;

  // ================================
  // ÉTAT DE LA RECHERCHE
  // ================================
  final RxString searchQuery = ''.obs;
  final RxBool isSearching = false.obs;
  final RxBool showFilters = false.obs;
  final RxBool isLoading = false.obs;
  final RxBool hasFocus = false.obs;

  // ================================
  // FILTRES
  // ================================
  final RxString selectedCategory = 'Tous'.obs;
  final RxDouble minPrice = 0.0.obs;
  final RxDouble maxPrice = 1000000.0.obs;
  final RxString selectedLocation = 'Toutes les villes'.obs;
  final Rx<ProductCondition?> selectedCondition = Rx<ProductCondition?>(null);

  // ================================
  // TRI
  // ================================
  final Rx<SortOption> selectedSortOption = SortOption.relevance.obs;

  // ================================
  // CATÉGORIES DISPONIBLES
  // ================================
  final List<String> categories = [
    'Tous',
    'Vêtements',
    'Électronique',
    'Accessoires',
    'Maison',
    'Sport',
    'Beauté',
    'Livres',
    'Autres',
  ];

  // ================================
  // VILLES DISPONIBLES
  // ================================
  final List<String> cities = [
    'Toutes les villes',
    'Douala',
    'Yaoundé',
    'Bafoussam',
    'Bamenda',
    'Garoua',
  ];

  // ================================
  // HISTORIQUE DE RECHERCHE
  // ================================
  final RxList<String> searchHistory = <String>[].obs;
  final int maxHistoryItems = 10;

  // ================================
  // SUGGESTIONS
  // ================================
  final RxList<String> suggestions = <String>[].obs;

  // ================================
  // NOMBRE DE FILTRES ACTIFS
  // ================================
  int get activeFiltersCount {
    int count = 0;
    if (selectedCategory.value != 'Tous') count++;
    if (minPrice.value > 0 || maxPrice.value < 1000000) count++;
    if (selectedLocation.value != 'Toutes les villes') count++;
    if (selectedCondition.value != null) count++;
    return count;
  }

  @override
  void onInit() {
    super.onInit();
    _loadSearchHistory();
    _loadMockProducts();
    _setupSearchListener();
    _setupFocusListener();
  }

  @override
  void onClose() {
    searchTextController.dispose();
    searchFocusNode.dispose();
    super.onClose();
  }

  // ================================
  // CHARGEMENT DES DONNÉES
  // ================================

  /// Charge les produits (mock data pour l'instant)
  void _loadMockProducts() {
    // TODO: Remplacer par un appel API réel
    allProducts.value = [
      ProductModel(
        id: '1',
        name: 'T-shirt Design Artistique',
        description:
            'Magnifique t-shirt avec design unique fait à la main. Matière 100% coton de qualité premium.',
        price: 15000,
        category: 'Vêtements',
        location: 'Douala, Cameroun',
        locationCity: 'Douala',
        locationCountry: 'Cameroun',
        images: ['assets/images/p1.jpeg'],
        condition: ProductCondition.nouveau,
        createdAt: DateTime.now().subtract(const Duration(days: 2)),
        seller: SellerModel(
          id: 's1',
          name: 'Boutique Fashion',
          rating: 4.5,
          reviewsCount: 120,
        ),
        tags: ['vêtements', 'fashion', 't-shirt', 'design'],
      ),
      ProductModel(
        id: '2',
        name: 'Sneakers Sport Premium',
        description:
            'Chaussures de sport haute qualité, confortables et durables. Parfaites pour le running.',
        price: 35000,
        category: 'Accessoires',
        location: 'Yaoundé, Cameroun',
        locationCity: 'Yaoundé',
        locationCountry: 'Cameroun',
        images: ['assets/images/p2.jpeg'],
        condition: ProductCondition.nouveau,
        createdAt: DateTime.now().subtract(const Duration(days: 5)),
        seller: SellerModel(
          id: 's2',
          name: 'Sports Plus',
          rating: 4.8,
          reviewsCount: 250,
        ),
        tags: ['chaussures', 'sport', 'sneakers'],
      ),
      ProductModel(
        id: '3',
        name: 'Montre Élégante',
        description:
            'Montre classique pour homme, boîtier en acier inoxydable, bracelet cuir véritable.',
        price: 45000,
        category: 'Accessoires',
        location: 'Douala, Cameroun',
        locationCity: 'Douala',
        locationCountry: 'Cameroun',
        images: ['assets/images/p3.jpeg'],
        condition: ProductCondition.commeNeuf,
        createdAt: DateTime.now().subtract(const Duration(days: 1)),
        seller: SellerModel(
          id: 's3',
          name: 'Time Boutique',
          rating: 4.7,
          reviewsCount: 180,
        ),
        tags: ['montre', 'accessoire', 'homme'],
      ),
      ProductModel(
        id: '4',
        name: 'Casque Audio Bluetooth',
        description:
            'Casque sans fil avec réduction de bruit active, autonomie 30h, son haute qualité.',
        price: 28000,
        category: 'Électronique',
        location: 'Bafoussam, Cameroun',
        locationCity: 'Bafoussam',
        locationCountry: 'Cameroun',
        images: ['assets/images/p4.jpeg'],
        condition: ProductCondition.nouveau,
        createdAt: DateTime.now().subtract(const Duration(hours: 12)),
        seller: SellerModel(
          id: 's4',
          name: 'Tech Store',
          rating: 4.9,
          reviewsCount: 320,
        ),
        tags: ['électronique', 'audio', 'casque', 'bluetooth'],
      ),
      ProductModel(
        id: '5',
        name: 'Sac à Main Cuir',
        description:
            'Sac à main en cuir véritable, élégant et spacieux. Plusieurs compartiments.',
        price: 32000,
        category: 'Accessoires',
        location: 'Douala, Cameroun',
        locationCity: 'Douala',
        locationCountry: 'Cameroun',
        images: ['assets/images/p5.jpeg'],
        condition: ProductCondition.tresBonEtat,
        createdAt: DateTime.now().subtract(const Duration(days: 3)),
        seller: SellerModel(
          id: 's5',
          name: 'Luxury Bags',
          rating: 4.6,
          reviewsCount: 95,
        ),
        tags: ['sac', 'accessoire', 'cuir', 'femme'],
      ),
      ProductModel(
        id: '6',
        name: 'Lunettes de Soleil Tendance',
        description:
            'Lunettes de soleil UV400, monture métallique, style aviateur moderne.',
        price: 12000,
        category: 'Accessoires',
        location: 'Yaoundé, Cameroun',
        locationCity: 'Yaoundé',
        locationCountry: 'Cameroun',
        images: ['assets/images/p6.jpeg'],
        condition: ProductCondition.nouveau,
        createdAt: DateTime.now().subtract(const Duration(days: 4)),
        seller: SellerModel(
          id: 's6',
          name: 'Vision Style',
          rating: 4.4,
          reviewsCount: 78,
        ),
        tags: ['lunettes', 'accessoire', 'soleil'],
      ),
      ProductModel(
        id: '7',
        name: 'Jean Slim Fit',
        description:
            'Jean de qualité premium, coupe slim, tissu élastique confortable.',
        price: 18000,
        category: 'Vêtements',
        location: 'Douala, Cameroun',
        locationCity: 'Douala',
        locationCountry: 'Cameroun',
        images: ['assets/images/p7.jpeg'],
        condition: ProductCondition.nouveau,
        createdAt: DateTime.now().subtract(const Duration(days: 6)),
        seller: SellerModel(
          id: 's7',
          name: 'Denim Shop',
          rating: 4.5,
          reviewsCount: 145,
        ),
        tags: ['vêtements', 'jean', 'pantalon'],
      ),
    ];

    filteredProducts.value = allProducts;
  }

  // ================================
  // RECHERCHE
  // ================================

  /// Configure l'écoute des changements de texte
  void _setupSearchListener() {
    searchTextController.addListener(() {
      searchQuery.value = searchTextController.text;
      _updateSuggestions();
    });
  }

  /// Configure l'écoute des changements de focus
  void _setupFocusListener() {
    searchFocusNode.addListener(() {
      hasFocus.value = searchFocusNode.hasFocus;
    });
  }

  /// Effectue la recherche
  void performSearch(String query) {
    searchQuery.value = query;
    searchTextController.text = query;
    isSearching.value = true;

    // Ajouter à l'historique
    if (query.isNotEmpty) {
      _addToSearchHistory(query);
    }

    // Appliquer tous les filtres
    _applyFilters();

    // Masquer le focus du champ de recherche
    searchFocusNode.unfocus();
  }

  /// Met à jour les suggestions basées sur la requête
  void _updateSuggestions() {
    if (searchQuery.value.isEmpty) {
      suggestions.clear();
      return;
    }

    final query = searchQuery.value.toLowerCase();
    final matchingProducts = allProducts
        .where((product) => product.name.toLowerCase().contains(query))
        .take(5)
        .map((p) => p.name)
        .toList();

    suggestions.value = matchingProducts;
  }

  /// Efface la recherche
  void clearSearch() {
    searchQuery.value = '';
    searchTextController.clear();
    isSearching.value = false;
    suggestions.clear();
    _applyFilters();
  }

  // ================================
  // FILTRES
  // ================================

  /// Applique tous les filtres actifs
  void _applyFilters() {
    isLoading.value = true;

    var results = List<ProductModel>.from(allProducts);

    // Filtre par recherche
    if (searchQuery.value.isNotEmpty) {
      results = results
          .where((product) => product.matchesSearchQuery(searchQuery.value))
          .toList();
    }

    // Filtre par catégorie
    if (selectedCategory.value != 'Tous') {
      results = results
          .where((product) => product.category == selectedCategory.value)
          .toList();
    }

    // Filtre par prix
    results = results
        .where((product) =>
            product.price >= minPrice.value && product.price <= maxPrice.value)
        .toList();

    // Filtre par localisation
    if (selectedLocation.value != 'Toutes les villes') {
      results = results
          .where(
              (product) => product.locationCity == selectedLocation.value)
          .toList();
    }

    // Filtre par condition
    if (selectedCondition.value != null) {
      results = results
          .where((product) => product.condition == selectedCondition.value)
          .toList();
    }

    // Tri
    _sortResults(results);

    filteredProducts.value = results;
    isLoading.value = false;
  }

  /// Trie les résultats selon l'option sélectionnée
  void _sortResults(List<ProductModel> results) {
    switch (selectedSortOption.value) {
      case SortOption.relevance:
        // Tri par pertinence (déjà fait par le filtre de recherche)
        break;
      case SortOption.priceAsc:
        results.sort((a, b) => a.price.compareTo(b.price));
        break;
      case SortOption.priceDesc:
        results.sort((a, b) => b.price.compareTo(a.price));
        break;
      case SortOption.dateDesc:
        results.sort((a, b) => b.createdAt.compareTo(a.createdAt));
        break;
      case SortOption.dateAsc:
        results.sort((a, b) => a.createdAt.compareTo(b.createdAt));
        break;
    }
  }

  /// Change la catégorie
  void selectCategory(String category) {
    selectedCategory.value = category;
    _applyFilters();
  }

  /// Change la plage de prix
  void setPriceRange(double min, double max) {
    minPrice.value = min;
    maxPrice.value = max;
    _applyFilters();
  }

  /// Change la localisation
  void selectLocation(String location) {
    selectedLocation.value = location;
    _applyFilters();
  }

  /// Change la condition
  void selectCondition(ProductCondition? condition) {
    selectedCondition.value = condition;
    _applyFilters();
  }

  /// Change l'option de tri
  void selectSortOption(SortOption option) {
    selectedSortOption.value = option;
    _applyFilters();
  }

  /// Réinitialise tous les filtres
  void resetFilters() {
    selectedCategory.value = 'Tous';
    minPrice.value = 0.0;
    maxPrice.value = 1000000.0;
    selectedLocation.value = 'Toutes les villes';
    selectedCondition.value = null;
    selectedSortOption.value = SortOption.relevance;
    _applyFilters();
  }

  /// Toggle affichage des filtres
  void toggleFilters() {
    showFilters.value = !showFilters.value;
  }

  // ================================
  // HISTORIQUE
  // ================================

  /// Charge l'historique de recherche
  void _loadSearchHistory() {
    final history = _storage.read<List>('search_history');
    if (history != null) {
      searchHistory.value = history.cast<String>();
    }
  }

  /// Ajoute une recherche à l'historique
  void _addToSearchHistory(String query) {
    // Retirer si déjà présent
    searchHistory.remove(query);

    // Ajouter en première position
    searchHistory.insert(0, query);

    // Limiter la taille
    if (searchHistory.length > maxHistoryItems) {
      searchHistory.removeRange(maxHistoryItems, searchHistory.length);
    }

    // Sauvegarder
    _storage.write('search_history', searchHistory);
  }

  /// Supprime un élément de l'historique
  void removeFromHistory(String query) {
    searchHistory.remove(query);
    _storage.write('search_history', searchHistory);
  }

  /// Efface tout l'historique
  void clearHistory() {
    searchHistory.clear();
    _storage.remove('search_history');
  }

  // ================================
  // ACTIONS SUR LES PRODUITS
  // ================================

  /// Navigue vers les détails du produit
  void goToProductDetails(ProductModel product) {
    Get.toNamed('/product', arguments: product.toMap());
  }

  /// Toggle favori
  void toggleFavorite(ProductModel product) {
    final index = allProducts.indexWhere((p) => p.id == product.id);
    if (index != -1) {
      allProducts[index] =
          product.copyWith(isFavorite: !product.isFavorite);
      _applyFilters();
    }
  }
}

// ================================
// ENUMS
// ================================

enum SortOption {
  relevance,
  priceAsc,
  priceDesc,
  dateDesc,
  dateAsc,
}

extension SortOptionExtension on SortOption {
  String get label {
    switch (this) {
      case SortOption.relevance:
        return 'Pertinence';
      case SortOption.priceAsc:
        return 'Prix croissant';
      case SortOption.priceDesc:
        return 'Prix décroissant';
      case SortOption.dateDesc:
        return 'Plus récents';
      case SortOption.dateAsc:
        return 'Plus anciens';
    }
  }

  IconData get icon {
    switch (this) {
      case SortOption.relevance:
        return Icons.star_outline;
      case SortOption.priceAsc:
        return Icons.arrow_upward;
      case SortOption.priceDesc:
        return Icons.arrow_downward;
      case SortOption.dateDesc:
        return Icons.access_time;
      case SortOption.dateAsc:
        return Icons.history;
    }
  }
}
