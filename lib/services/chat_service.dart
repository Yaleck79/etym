import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/message_model.dart';
import 'coin_service.dart';

class ChatService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final CoinService _coinService = CoinService();

  // Envoyer un message (coûte 1 coin)
  Future<bool> sendMessage({
    required String chatId,
    required String senderId,
    required String senderName,
    required String text,
    String? imageUrl,
  }) async {
    try {
      // 💰 VÉRIFIER ET DÉPENSER 1 COIN
      bool hasCoins = await _coinService.spendCoins(senderId, 1);
      
      if (!hasCoins) {
        throw Exception('Vous n\'avez pas assez de coins pour envoyer un message');
      }

      // Créer le message
      final message = Message(
        id: '',
        chatId: chatId,
        senderId: senderId,
        senderName: senderName,
        text: text,
        timestamp: DateTime.now(),
        imageUrl: imageUrl,
      );

      // Ajouter à Firestore
      await _firestore.collection('messages').add(message.toFirestore());

      return true;
    } catch (e) {
      print('Erreur envoi message: $e');
      rethrow;
    }
  }

  // Récupérer les messages d'un chat
  Stream<List<Message>> getMessages(String chatId) {
    return _firestore
        .collection('messages')
        .where('chatId', isEqualTo: chatId)
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) => Message.fromFirestore(doc)).toList();
    });
  }

  // Créer ou récupérer un chat entre acheteur et vendeur
  Future<String> getOrCreateChat(String buyerId, String sellerId, String productId) async {
    String chatId = '${productId}_${buyerId}_$sellerId';
    
    // Vérifier si le chat existe
    DocumentSnapshot chatDoc = await _firestore.collection('chats').doc(chatId).get();
    
    if (!chatDoc.exists) {
      // Créer le chat
      await _firestore.collection('chats').doc(chatId).set({
        'chatId': chatId,
        'buyerId': buyerId,
        'sellerId': sellerId,
        'productId': productId,
        'createdAt': FieldValue.serverTimestamp(),
        'lastMessage': '',
        'lastMessageTime': FieldValue.serverTimestamp(),
      });
    }
    
    return chatId;
  }
}