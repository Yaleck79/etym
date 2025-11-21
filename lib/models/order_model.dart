import 'package:cloud_firestore/cloud_firestore.dart';

class Order {
  final String id;
  final String productId;
  final String productTitle;
  final String productImage;
  final double productPrice;
  final String buyerId;
  final String buyerName;
  final String sellerId;
  final String sellerName;
  final String sellerPhone;
  final String status; // 'pending', 'paid', 'shipped', 'completed', 'cancelled'
  final DateTime createdAt;
  final String? paymentProofUrl;
  final String chatId;

  Order({
    required this.id,
    required this.productId,
    required this.productTitle,
    required this.productImage,
    required this.productPrice,
    required this.buyerId,
    required this.buyerName,
    required this.sellerId,
    required this.sellerName,
    required this.sellerPhone,
    this.status = 'pending',
    required this.createdAt,
    this.paymentProofUrl,
    required this.chatId,
  });

  factory Order.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return Order(
      id: doc.id,
      productId: data['productId'] ?? '',
      productTitle: data['productTitle'] ?? '',
      productImage: data['productImage'] ?? '',
      productPrice: (data['productPrice'] ?? 0).toDouble(),
      buyerId: data['buyerId'] ?? '',
      buyerName: data['buyerName'] ?? '',
      sellerId: data['sellerId'] ?? '',
      sellerName: data['sellerName'] ?? '',
      sellerPhone: data['sellerPhone'] ?? '',
      status: data['status'] ?? 'pending',
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      paymentProofUrl: data['paymentProofUrl'],
      chatId: data['chatId'] ?? '',
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'productId': productId,
      'productTitle': productTitle,
      'productImage': productImage,
      'productPrice': productPrice,
      'buyerId': buyerId,
      'buyerName': buyerName,
      'sellerId': sellerId,
      'sellerName': sellerName,
      'sellerPhone': sellerPhone,
      'status': status,
      'createdAt': Timestamp.fromDate(createdAt),
      'paymentProofUrl': paymentProofUrl,
      'chatId': chatId,
    };
  }

  String get formattedPrice {
    return '${productPrice.toStringAsFixed(0).replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]} ',
    )} FCFA';
  }

  String get statusText {
    switch (status) {
      case 'pending':
        return 'En attente de paiement';
      case 'paid':
        return 'Payé';
      case 'shipped':
        return 'Expédié';
      case 'completed':
        return 'Terminé';
      case 'cancelled':
        return 'Annulé';
      default:
        return 'Inconnu';
    }
  }
}