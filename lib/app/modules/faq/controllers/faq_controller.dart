import 'package:get/get.dart';

class FaqController extends GetxController {
  // Catégories de FAQ
  final faqCategories = <FaqCategory>[
    FaqCategory(
      title: 'Commandes et livraisons',
      faqs: [
        Faq(
          question: 'Comment passer une commande ?',
          answer: 'Pour passer une commande, parcourez notre catalogue de produits, '
              'ajoutez les articles souhaités à votre panier, puis cliquez sur "Commander". '
              'Remplissez vos informations de livraison et choisissez votre mode de paiement '
              'pour finaliser la commande.',
        ),
        Faq(
          question: 'Comment suivre ma commande ?',
          answer: 'Vous pouvez suivre votre commande en allant dans "Mes commandes" '
              'depuis le menu principal. Cliquez sur la commande que vous souhaitez suivre '
              'pour voir son statut en temps réel et la position du livreur.',
        ),
        Faq(
          question: 'Puis-je annuler ma commande ?',
          answer: 'Oui, vous pouvez annuler votre commande tant qu\'elle n\'est pas '
              'en cours de livraison. Allez dans "Mes commandes", sélectionnez la commande '
              'et cliquez sur "Annuler". Un remboursement sera effectué si le paiement a déjà été traité.',
        ),
        Faq(
          question: 'Quels sont les délais de livraison ?',
          answer: 'Les délais de livraison varient selon votre localisation :\n'
              '• Zone urbaine : 1-2 heures\n'
              '• Zone périurbaine : 2-4 heures\n'
              '• Zone rurale : 24-48 heures',
        ),
      ],
    ),
    FaqCategory(
      title: 'Paiements',
      faqs: [
        Faq(
          question: 'Quels modes de paiement acceptez-vous ?',
          answer: 'Nous acceptons plusieurs modes de paiement :\n'
              '• Paiement mobile (Mobile Money, Orange Money)\n'
              '• Carte bancaire (Visa, Mastercard)\n'
              '• Paiement à la livraison (espèces)\n'
              '• Virement bancaire',
        ),
        Faq(
          question: 'Mes informations de paiement sont-elles sécurisées ?',
          answer: 'Oui, toutes les transactions sont sécurisées par cryptage SSL. '
              'Nous ne stockons pas vos informations de carte bancaire sur nos serveurs. '
              'Tous les paiements sont traités par des passerelles de paiement certifiées PCI-DSS.',
        ),
        Faq(
          question: 'Comment obtenir un remboursement ?',
          answer: 'Pour demander un remboursement, contactez notre service client '
              'avec votre numéro de commande. Les remboursements sont traités sous 5-7 jours '
              'ouvrables et sont crédités sur le mode de paiement original.',
        ),
      ],
    ),
    FaqCategory(
      title: 'Compte et sécurité',
      faqs: [
        Faq(
          question: 'Comment créer un compte ?',
          answer: 'Cliquez sur "S\'inscrire" sur la page d\'accueil, remplissez vos '
              'informations (nom, email, téléphone, mot de passe), puis validez votre compte '
              'via le code envoyé par SMS ou email.',
        ),
        Faq(
          question: 'J\'ai oublié mon mot de passe, que faire ?',
          answer: 'Cliquez sur "Mot de passe oublié" sur la page de connexion, '
              'entrez votre email ou numéro de téléphone, et suivez les instructions '
              'pour réinitialiser votre mot de passe.',
        ),
        Faq(
          question: 'Comment modifier mes informations personnelles ?',
          answer: 'Allez dans "Paramètres" > "Modifier le profil" depuis le menu. '
              'Vous pourrez y modifier votre nom, photo, numéro de téléphone, adresse de livraison, etc.',
        ),
        Faq(
          question: 'Comment supprimer mon compte ?',
          answer: 'Pour supprimer votre compte, allez dans "Paramètres" > "Données et confidentialité" '
              '> "Supprimer mon compte". Cette action est irréversible et toutes vos données seront supprimées.',
        ),
      ],
    ),
    FaqCategory(
      title: 'Retours et remboursements',
      faqs: [
        Faq(
          question: 'Puis-je retourner un produit ?',
          answer: 'Oui, vous avez 7 jours à compter de la réception pour retourner '
              'un produit non utilisé dans son emballage d\'origine. Contactez le service client '
              'pour initier un retour.',
        ),
        Faq(
          question: 'Que faire si je reçois un produit endommagé ?',
          answer: 'Si vous recevez un produit endommagé, refusez la livraison et '
              'contactez immédiatement notre service client avec des photos. '
              'Nous organiserons un remplacement ou un remboursement.',
        ),
        Faq(
          question: 'Combien de temps prend un remboursement ?',
          answer: 'Les remboursements sont traités sous 5-7 jours ouvrables après '
              'réception et validation du retour. Le montant sera crédité sur votre mode '
              'de paiement original.',
        ),
      ],
    ),
  ];

  // Index de l'élément actuellement ouvert (null si aucun)
  final expandedIndex = Rxn<String>();

  /// Basculer l'état d'expansion d'un FAQ
  void toggleExpansion(String id) {
    if (expandedIndex.value == id) {
      expandedIndex.value = null;
    } else {
      expandedIndex.value = id;
    }
  }

  /// Rechercher dans les FAQs
  final searchQuery = ''.obs;
  final filteredCategories = <FaqCategory>[].obs;

  @override
  void onInit() {
    super.onInit();
    filteredCategories.value = faqCategories;

    // Écouter les changements de recherche
    ever(searchQuery, (_) => _filterFaqs());
  }

  void _filterFaqs() {
    if (searchQuery.value.isEmpty) {
      filteredCategories.value = faqCategories;
      return;
    }

    final query = searchQuery.value.toLowerCase();
    final filtered = <FaqCategory>[];

    for (final category in faqCategories) {
      final matchingFaqs = category.faqs.where((faq) =>
          faq.question.toLowerCase().contains(query) ||
          faq.answer.toLowerCase().contains(query)).toList();

      if (matchingFaqs.isNotEmpty) {
        filtered.add(FaqCategory(
          title: category.title,
          faqs: matchingFaqs,
        ));
      }
    }

    filteredCategories.value = filtered;
  }
}

class FaqCategory {
  final String title;
  final List<Faq> faqs;

  FaqCategory({
    required this.title,
    required this.faqs,
  });
}

class Faq {
  final String question;
  final String answer;

  Faq({
    required this.question,
    required this.answer,
  });

  String get id => question.hashCode.toString();
}
