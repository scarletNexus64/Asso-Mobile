import 'package:flutter/material.dart';
import 'package:get/get.dart';

class HomeController extends GetxController with GetSingleTickerProviderStateMixin {
  // Scaffold key pour le drawer
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();

  // Tab Controller
  late TabController tabController;
  final RxInt currentTabIndex = 0.obs;

  // Scroll Controller
  final ScrollController nestedScrollController = ScrollController();

  // Tab names
  final List<String> tabNames = [
    'Accueil',
    'Recherche',
    'Messages',
    'Tracking',
    'Profile',
  ];

  // Banner controller pour la page d'accueil
  final PageController bannerController = PageController();
  final RxInt currentBannerIndex = 0.obs;
  final RxString selectedCategory = 'Tous'.obs;

  final List<String> banners = [
    'assets/images/bann1.png',
    'assets/images/bann2.png',
    'assets/images/bann3.png',
  ];

  final List<String> categories = [
    'Tous',
    'Vêtements',
    'Électronique',
    'Accessoires',
  ];

  final List<Map<String, dynamic>> products = [
    {
      'image': 'assets/images/p1.jpeg',
      'name': 'T-shirt Design Artistique',
      'price': '15 000',
      'location': 'Douala, Cameroun',
    },
    {
      'image': 'assets/images/p2.jpeg',
      'name': 'Sneakers Premium',
      'price': '45 000',
      'location': 'Yaoundé, Cameroun',
    },
    {
      'image': 'assets/images/p3.jpeg',
      'name': 'Sac à Main Élégant',
      'price': '25 000',
      'location': 'Douala, Cameroun',
    },
    {
      'image': 'assets/images/p4.jpeg',
      'name': 'Montre Connectée',
      'price': '85 000',
      'location': 'Yaoundé, Cameroun',
    },
    {
      'image': 'assets/images/p5.jpeg',
      'name': 'Casque Audio',
      'price': '35 000',
      'location': 'Douala, Cameroun',
    },
    {
      'image': 'assets/images/p6.jpeg',
      'name': 'Lunettes de Soleil',
      'price': '12 000',
      'location': 'Bafoussam, Cameroun',
    },
    {
      'image': 'assets/images/p7.jpeg',
      'name': 'iPhone 14 Pro',
      'price': '750 000',
      'location': 'Yaoundé, Cameroun',
    },
  ];

  @override
  void onInit() {
    super.onInit();
    tabController = TabController(length: tabNames.length, vsync: this);
    tabController.addListener(() {
      currentTabIndex.value = tabController.index;
    });
    _startBannerAutoScroll();
  }

  @override
  void onClose() {
    tabController.dispose();
    bannerController.dispose();
    nestedScrollController.dispose();
    super.onClose();
  }

  void handleTabTap(int index) {
    currentTabIndex.value = index;
  }

  void _startBannerAutoScroll() {
    Future.delayed(const Duration(seconds: 3), () {
      if (bannerController.hasClients) {
        int nextPage = (currentBannerIndex.value + 1) % banners.length;
        bannerController.animateToPage(
          nextPage,
          duration: const Duration(milliseconds: 400),
          curve: Curves.easeInOut,
        );
        currentBannerIndex.value = nextPage;
        _startBannerAutoScroll();
      }
    });
  }

  void selectCategory(String category) {
    selectedCategory.value = category;
  }

  void onProductTap(int index) {
    final product = {
      ...products[index],
      'description': 'Un produit de qualité exceptionnelle qui répond à tous vos besoins. Fabriqué avec soin et attention aux détails, ce produit offre un excellent rapport qualité-prix.',
      'images': [
        products[index]['image'],
        products[(index + 1) % products.length]['image'],
        products[(index + 2) % products.length]['image'],
      ],
      'seller': {
        'name': 'Boutique ${index + 1}',
        'rating': 4.5,
        'reviews': 120 + (index * 10),
      },
    };

    Get.toNamed('/product', arguments: product);
  }
}
