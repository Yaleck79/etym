import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String uid;
  final String name;
  final String email;
  final String? phone;
  final int coins;  // 💰 Coins de l'utilisateur
  final DateTime createdAt;

  UserModel({
    required this.uid,
    required this.name,
    required this.email,
    this.phone,
    this.coins = 100,  // 100 coins gratuits au départ
    required this.createdAt,
  });

  // Convertir depuis Firestore
  factory UserModel.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return UserModel(
      uid: doc.id,
      name: data['name'] ?? '',
      email: data['email'] ?? '',
      phone: data['phone'],
      coins: data['coins'] ?? 100,
      createdAt: (data['createdAt'] as Timestamp).toDate(),
    );
  }

  // Convertir vers Firestore
  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'email': email,
      'phone': phone,
      'coins': coins,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  // Créer une copie avec modifications
  UserModel copyWith({
    String? uid,
    String? name,
    String? email,
    String? phone,
    int? coins,
    DateTime? createdAt,
  }) {
    return UserModel(
      uid: uid ?? this.uid,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      coins: coins ?? this.coins,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}