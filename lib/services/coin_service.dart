import 'package:cloud_firestore/cloud_firestore.dart';

class CoinService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Récupérer les coins d'un utilisateur
  Future<int> getUserCoins(String userId) async {
    try {
      DocumentSnapshot doc =
          await _firestore.collection('users').doc(userId).get();
      if (doc.exists) {
        return (doc.data() as Map<String, dynamic>)['coins'] ?? 0;
      }
      return 0;
    } catch (e) {
      print('Erreur récupération coins: $e');
      return 0;
    }
  }

  // Créer un utilisateur avec 100 coins de départ
  Future<void> createUserWithCoins(
      String userId, String name, String email) async {
    try {
      await _firestore.collection('users').doc(userId).set({
        'name': name,
        'email': email,
        'coins': 100, // 🎁 100 coins gratuits
        'createdAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print('Erreur création utilisateur: $e');
    }
  }

  // Ajouter des coins
  Future<bool> addCoins(String userId, int amount) async {
    try {
      await _firestore.collection('users').doc(userId).update({
        'coins': FieldValue.increment(amount),
      });
      return true;
    } catch (e) {
      print('Erreur ajout coins: $e');
      return false;
    }
  }

  // Dépenser des coins (pour envoyer un message)
  Future<bool> spendCoins(String userId, int amount) async {
    try {
      // Vérifier d'abord si l'utilisateur a assez de coins
      int currentCoins = await getUserCoins(userId);

      if (currentCoins < amount) {
        return false; // Pas assez de coins
      }

      // Déduire les coins
      await _firestore.collection('users').doc(userId).update({
        'coins': FieldValue.increment(-amount),
      });

      return true;
    } catch (e) {
      print('Erreur dépense coins: $e');
      return false;
    }
  }

  // Récompenser le vendeur après une vente (5% du prix en coins)
  Future<void> rewardSellerOnSale(String sellerId, double saleAmount) async {
    try {
      // 5% du prix de vente = coins gagnés
      int coinsEarned = (saleAmount * 0.05).round();

      await addCoins(sellerId, coinsEarned);

      print('💰 Vendeur $sellerId a gagné $coinsEarned coins !');
    } catch (e) {
      print('Erreur récompense vendeur: $e');
    }
  }

  // Packages de coins à vendre
  List<Map<String, dynamic>> getCoinPackages() {
    return [
      {'coins': 50, 'price': 500, 'label': '50 Coins'},
      {'coins': 100, 'price': 900, 'label': '100 Coins', 'bonus': '10% bonus'},
      {'coins': 250, 'price': 2000, 'label': '250 Coins', 'bonus': '20% bonus'},
      {'coins': 500, 'price': 3500, 'label': '500 Coins', 'bonus': '30% bonus'},
    ];
  }

  // Stream pour écouter les changements de coins
  Stream<int> coinsStream(String userId) {
    return _firestore.collection('users').doc(userId).snapshots().map((doc) {
      if (doc.exists) {
        return (doc.data() as Map<String, dynamic>)['coins'] ?? 0;
      }
      return 0;
    });
  }
}
