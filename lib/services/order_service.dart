import 'package:cloud_firestore/cloud_firestore.dart' hide Order;
import '../models/order_model.dart';
import 'coin_service.dart';

class OrderService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final CoinService _coinService = CoinService();

  // Créer une commande
  Future<String> createOrder(Order order) async {
    try {
      DocumentReference docRef =
          await _firestore.collection('orders').add(order.toFirestore());
      return docRef.id;
    } catch (e) {
      throw Exception('Erreur lors de la création de la commande: $e');
    }
  }

  // Récupérer les commandes d'un acheteur
  Stream<List<Order>> getBuyerOrders(String buyerId) {
    return _firestore
        .collection('orders')
        .where('buyerId', isEqualTo: buyerId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) => Order.fromFirestore(doc)).toList();
    });
  }

  // Récupérer les commandes d'un vendeur
  Stream<List<Order>> getSellerOrders(String sellerId) {
    return _firestore
        .collection('orders')
        .where('sellerId', isEqualTo: sellerId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) => Order.fromFirestore(doc)).toList();
    });
  }

  // Mettre à jour le statut d'une commande
  Future<void> updateOrderStatus(String orderId, String status) async {
    try {
      await _firestore.collection('orders').doc(orderId).update({
        'status': status,
      });
    } catch (e) {
      throw Exception('Erreur lors de la mise à jour du statut: $e');
    }
  }

  // Marquer comme payé et récompenser le vendeur
  Future<void> markAsPaid(
      String orderId, String sellerId, double amount) async {
    try {
      // Mettre à jour le statut
      await updateOrderStatus(orderId, 'paid');

      // 💰 Récompenser le vendeur (5% en coins)
      await _coinService.rewardSellerOnSale(sellerId, amount);
    } catch (e) {
      throw Exception('Erreur lors du paiement: $e');
    }
  }

  // Récupérer une commande par son ID
  Future<Order?> getOrderById(String orderId) async {
    try {
      DocumentSnapshot doc =
          await _firestore.collection('orders').doc(orderId).get();
      if (doc.exists) {
        return Order.fromFirestore(doc);
      }
      return null;
    } catch (e) {
      throw Exception('Erreur lors de la récupération de la commande: $e');
    }
  }
}
