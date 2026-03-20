import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ChatdetailController extends GetxController {
  final TextEditingController messageController = TextEditingController();
  final ScrollController scrollController = ScrollController();

  late Map<String, dynamic> conversation;
  final RxList<Map<String, dynamic>> messages = <Map<String, dynamic>>[].obs;
  final RxBool isTyping = false.obs;

  @override
  void onInit() {
    super.onInit();
    conversation = Get.arguments ?? {};
    _loadMessages();
  }

  @override
  void onClose() {
    messageController.dispose();
    scrollController.dispose();
    super.onClose();
  }

  void _loadMessages() {
    messages.value = [
      {
        'id': '1',
        'text': 'Bonjour ! Je suis intéressé par votre produit.',
        'isSentByMe': false,
        'timestamp': '10:15',
        'isRead': true,
      },
      {
        'id': '2',
        'text': 'Bonjour ! Oui, le produit est toujours disponible 😊',
        'isSentByMe': true,
        'timestamp': '10:16',
        'isRead': true,
      },
      {
        'id': '3',
        'text': 'Super ! Quel est le prix final avec la livraison ?',
        'isSentByMe': false,
        'timestamp': '10:17',
        'isRead': true,
      },
      {
        'id': '4',
        'text': 'Le prix est de 45 000 FCFA + 2 000 FCFA pour la livraison, soit 47 000 FCFA au total.',
        'isSentByMe': true,
        'timestamp': '10:18',
        'isRead': true,
      },
      {
        'id': '5',
        'text': 'D\'accord, c\'est bon pour moi. Je peux passer commande maintenant ?',
        'isSentByMe': false,
        'timestamp': '10:20',
        'isRead': true,
      },
      {
        'id': '6',
        'text': 'Bien sûr ! Je vais vous envoyer les détails de commande.',
        'isSentByMe': true,
        'timestamp': '10:21',
        'isRead': true,
      },
      {
        'id': '7',
        'text': 'Merci beaucoup ! 👍',
        'isSentByMe': false,
        'timestamp': '10:22',
        'isRead': true,
      },
    ];

    // Auto scroll to bottom
    Future.delayed(Duration(milliseconds: 100), () {
      if (scrollController.hasClients) {
        scrollController.jumpTo(scrollController.position.maxScrollExtent);
      }
    });
  }

  void sendMessage() {
    final text = messageController.text.trim();
    if (text.isEmpty) return;

    final newMessage = {
      'id': DateTime.now().millisecondsSinceEpoch.toString(),
      'text': text,
      'isSentByMe': true,
      'timestamp': _getCurrentTime(),
      'isRead': false,
    };

    messages.add(newMessage);
    messageController.clear();

    // Auto scroll to bottom
    Future.delayed(Duration(milliseconds: 100), () {
      if (scrollController.hasClients) {
        scrollController.animateTo(
          scrollController.position.maxScrollExtent,
          duration: Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });

    // Simuler une réponse
    _simulateResponse();
  }

  void _simulateResponse() {
    Future.delayed(Duration(seconds: 2), () {
      isTyping.value = true;
    });

    Future.delayed(Duration(seconds: 4), () {
      isTyping.value = false;

      final responses = [
        'D\'accord, merci pour votre message !',
        'Parfait, je note ça.',
        'Entendu, à bientôt !',
        'Merci, je reviens vers vous rapidement.',
      ];

      final randomResponse = responses[DateTime.now().second % responses.length];

      messages.add({
        'id': DateTime.now().millisecondsSinceEpoch.toString(),
        'text': randomResponse,
        'isSentByMe': false,
        'timestamp': _getCurrentTime(),
        'isRead': true,
      });

      // Auto scroll
      Future.delayed(Duration(milliseconds: 100), () {
        if (scrollController.hasClients) {
          scrollController.animateTo(
            scrollController.position.maxScrollExtent,
            duration: Duration(milliseconds: 300),
            curve: Curves.easeOut,
          );
        }
      });
    });
  }

  String _getCurrentTime() {
    final now = DateTime.now();
    return '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';
  }
}
