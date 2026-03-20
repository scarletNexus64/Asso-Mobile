import 'package:get/get.dart';

class ChatController extends GetxController {
  final RxList<Map<String, dynamic>> conversations = <Map<String, dynamic>>[].obs;
  final RxString searchQuery = ''.obs;

  @override
  void onInit() {
    super.onInit();
    _loadConversations();
  }

  void _loadConversations() {
    conversations.value = [
      {
        'id': '1',
        'name': 'Jean Dupont',
        'avatar': 'JD',
        'lastMessage': 'Bonjour, le produit est-il toujours disponible ?',
        'timestamp': '10:30',
        'unreadCount': 2,
        'isOnline': true,
        'productImage': 'assets/images/p1.jpeg',
      },
      {
        'id': '2',
        'name': 'Marie Claire',
        'avatar': 'MC',
        'lastMessage': 'Merci pour la livraison rapide !',
        'timestamp': 'Hier',
        'unreadCount': 0,
        'isOnline': false,
        'productImage': 'assets/images/p2.jpeg',
      },
      {
        'id': '3',
        'name': 'Paul Kamga',
        'avatar': 'PK',
        'lastMessage': 'Je suis intéressé par plusieurs articles',
        'timestamp': '15:45',
        'unreadCount': 5,
        'isOnline': true,
        'productImage': 'assets/images/p3.jpeg',
      },
      {
        'id': '4',
        'name': 'Sophie Ngo',
        'avatar': 'SN',
        'lastMessage': 'Pouvez-vous me faire un prix ?',
        'timestamp': 'Lundi',
        'unreadCount': 0,
        'isOnline': false,
        'productImage': 'assets/images/p4.jpeg',
      },
      {
        'id': '5',
        'name': 'David Mballa',
        'avatar': 'DM',
        'lastMessage': 'OK, je passe demain pour récupérer',
        'timestamp': '09:15',
        'unreadCount': 1,
        'isOnline': true,
        'productImage': 'assets/images/p5.jpeg',
      },
      {
        'id': '6',
        'name': 'Éric Fotso',
        'avatar': 'EF',
        'lastMessage': 'Photo disponible ?',
        'timestamp': 'Dimanche',
        'unreadCount': 0,
        'isOnline': false,
        'productImage': 'assets/images/p6.jpeg',
      },
    ];
  }

  List<Map<String, dynamic>> get filteredConversations {
    if (searchQuery.value.isEmpty) {
      return conversations;
    }
    return conversations
        .where((conv) => conv['name']
            .toString()
            .toLowerCase()
            .contains(searchQuery.value.toLowerCase()))
        .toList();
  }

  void openConversation(Map<String, dynamic> conversation) {
    Get.toNamed('/chatdetail', arguments: conversation);
  }
}
