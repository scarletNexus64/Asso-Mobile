import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/utils/app_theme_system.dart';

class HelpController extends GetxController {
  // État de chargement
  final isLoading = false.obs;

  // Sujets d'aide
  final supportTopics = <SupportTopic>[
    SupportTopic(
      icon: Icons.shopping_cart_outlined,
      title: 'Commandes',
      description: 'Aide sur vos commandes et livraisons',
      items: [
        'Comment passer une commande ?',
        'Suivre ma commande',
        'Annuler une commande',
        'Retourner un produit',
      ],
    ),
    SupportTopic(
      icon: Icons.payment_outlined,
      title: 'Paiements',
      description: 'Informations sur les paiements',
      items: [
        'Méthodes de paiement acceptées',
        'Sécurité des paiements',
        'Problèmes de paiement',
        'Remboursements',
      ],
    ),
    SupportTopic(
      icon: Icons.person_outline,
      title: 'Compte',
      description: 'Gérer votre compte',
      items: [
        'Créer un compte',
        'Modifier mes informations',
        'Mot de passe oublié',
        'Supprimer mon compte',
      ],
    ),
    SupportTopic(
      icon: Icons.local_shipping_outlined,
      title: 'Livraison',
      description: 'Questions sur la livraison',
      items: [
        'Zones de livraison',
        'Frais de livraison',
        'Délais de livraison',
        'Problèmes de livraison',
      ],
    ),
  ];

  /// Contacter par email
  Future<void> contactByEmail() async {
    Get.snackbar(
      'Email',
      'Ouverture du client email...',
      snackPosition: SnackPosition.BOTTOM,
      icon: const Icon(Icons.email, color: Colors.white),
      backgroundColor: AppThemeSystem.primaryColor,
      colorText: Colors.white,
    );
    // TODO: Ouvrir le client email avec mailto:support@example.com
  }

  /// Contacter par téléphone
  Future<void> contactByPhone() async {
    Get.snackbar(
      'Téléphone',
      'Appel vers le support...',
      snackPosition: SnackPosition.BOTTOM,
      icon: const Icon(Icons.phone, color: Colors.white),
      backgroundColor: Colors.green,
      colorText: Colors.white,
    );
    // TODO: Ouvrir le dialer avec tel:+237670000000
  }

  /// Contacter par WhatsApp
  Future<void> contactByWhatsApp() async {
    Get.snackbar(
      'WhatsApp',
      'Ouverture de WhatsApp...',
      snackPosition: SnackPosition.BOTTOM,
      icon: const Icon(Icons.chat, color: Colors.white),
      backgroundColor: const Color(0xFF25D366),
      colorText: Colors.white,
    );
    // TODO: Ouvrir WhatsApp avec le numéro de support
  }

  /// Ouvrir un sujet d'aide
  void openTopic(SupportTopic topic) {
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppThemeSystem.primaryColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    topic.icon,
                    color: AppThemeSystem.primaryColor,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        topic.title,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        topic.description,
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            ...topic.items.map((item) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Row(
                    children: [
                      Icon(
                        Icons.help_outline,
                        color: AppThemeSystem.primaryColor,
                        size: 20,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          item,
                          style: const TextStyle(fontSize: 15),
                        ),
                      ),
                    ],
                  ),
                )),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Get.back();
                  contactByEmail();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppThemeSystem.primaryColor,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: const Text('Contacter le support'),
              ),
            ),
          ],
        ),
      ),
      isScrollControlled: true,
    );
  }
}

class SupportTopic {
  final IconData icon;
  final String title;
  final String description;
  final List<String> items;

  SupportTopic({
    required this.icon,
    required this.title,
    required this.description,
    required this.items,
  });
}
