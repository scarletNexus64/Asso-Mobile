import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/utils/app_theme_system.dart';

class AboutController extends GetxController {
  // Informations de l'application
  final appName = 'Asso Market';
  final appVersion = '1.0.0';
  final buildNumber = '1';
  final releaseDate = 'Mars 2026';

  // Réseaux sociaux
  final socialLinks = <SocialLink>[
    SocialLink(
      name: 'Facebook',
      icon: Icons.facebook,
      url: 'https://facebook.com/asso',
      color: const Color(0xFF1877F2),
    ),
    SocialLink(
      name: 'Twitter',
      icon: Icons.close, // Utiliser X icon
      url: 'https://twitter.com/asso',
      color: Colors.black,
    ),
    SocialLink(
      name: 'Instagram',
      icon: Icons.camera_alt,
      url: 'https://instagram.com/asso',
      color: const Color(0xFFE4405F),
    ),
    SocialLink(
      name: 'LinkedIn',
      icon: Icons.work,
      url: 'https://linkedin.com/company/asso',
      color: const Color(0xFF0A66C2),
    ),
  ];

  /// Ouvrir un lien social
  void openSocialLink(String url) {
    Get.snackbar(
      'Ouverture',
      'Redirection vers $url',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: AppThemeSystem.primaryColor,
      colorText: Colors.white,
    );
    // TODO: Ouvrir l'URL avec url_launcher
  }

  /// Afficher les conditions d'utilisation
  void showTermsOfService() {
    Get.dialog(
      AlertDialog(
        title: const Text('Conditions d\'utilisation'),
        content: const SingleChildScrollView(
          child: Text(
            'Conditions d\'utilisation\n\n'
            '1. Acceptation des conditions\n'
            'En utilisant cette application, vous acceptez les présentes conditions.\n\n'
            '2. Utilisation du service\n'
            'Vous vous engagez à utiliser le service de manière légale et appropriée.\n\n'
            '3. Propriété intellectuelle\n'
            'Tous les contenus de l\'application sont protégés par les droits d\'auteur.\n\n'
            '4. Limitation de responsabilité\n'
            'Nous ne pouvons être tenus responsables des dommages indirects.\n\n'
            '5. Modifications\n'
            'Nous nous réservons le droit de modifier ces conditions à tout moment.',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Fermer'),
          ),
        ],
      ),
    );
  }

  /// Afficher la politique de confidentialité
  void showPrivacyPolicy() {
    Get.dialog(
      AlertDialog(
        title: const Text('Politique de confidentialité'),
        content: const SingleChildScrollView(
          child: Text(
            'Politique de confidentialité\n\n'
            '1. Collecte des données\n'
            'Nous collectons uniquement les données nécessaires au fonctionnement du service.\n\n'
            '2. Utilisation des données\n'
            'Vos données sont utilisées pour améliorer votre expérience utilisateur.\n\n'
            '3. Partage des données\n'
            'Nous ne partageons pas vos données avec des tiers sans votre consentement.\n\n'
            '4. Sécurité\n'
            'Nous mettons en œuvre des mesures de sécurité appropriées.\n\n'
            '5. Vos droits\n'
            'Vous avez le droit d\'accéder, modifier ou supprimer vos données.',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Fermer'),
          ),
        ],
      ),
    );
  }

  /// Afficher les licences
  void showLicenses() {
    Get.snackbar(
      'Licences',
      'Affichage des licences des bibliothèques',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: AppThemeSystem.primaryColor,
      colorText: Colors.white,
    );
    // TODO: Afficher la page des licences Flutter
  }

  /// Envoyer un feedback
  void sendFeedback() {
    Get.dialog(
      AlertDialog(
        title: const Text('Envoyer un feedback'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Votre avis nous intéresse !'),
            const SizedBox(height: 16),
            TextField(
              maxLines: 5,
              decoration: const InputDecoration(
                hintText: 'Écrivez votre feedback ici...',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () {
              Get.back();
              Get.snackbar(
                'Merci !',
                'Votre feedback a été envoyé',
                snackPosition: SnackPosition.BOTTOM,
                backgroundColor: Colors.green,
                colorText: Colors.white,
              );
            },
            child: const Text('Envoyer'),
          ),
        ],
      ),
    );
  }
}

class SocialLink {
  final String name;
  final IconData icon;
  final String url;
  final Color color;

  SocialLink({
    required this.name,
    required this.icon,
    required this.url,
    required this.color,
  });
}
