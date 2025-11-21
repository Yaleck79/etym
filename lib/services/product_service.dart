import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/product_model.dart';

class ProductService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _collectionName = 'products';

  // Récupérer tous les produits disponibles
  Stream<List<Product>> getAllProducts() {
    return _firestore
        .collection(_collectionName)
        .where('status', isEqualTo: 'disponible')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) => Product.fromFirestore(doc)).toList();
    });
  }

  // Récupérer les produits par catégorie
  Stream<List<Product>> getProductsByCategory(String category) {
    return _firestore
        .collection(_collectionName)
        .where('category', isEqualTo: category)
        .where('status', isEqualTo: 'disponible')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) => Product.fromFirestore(doc)).toList();
    });
  }

  // Récupérer les produits d'un vendeur
  Stream<List<Product>> getSellerProducts(String sellerId) {
    return _firestore
        .collection(_collectionName)
        .where('sellerId', isEqualTo: sellerId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) => Product.fromFirestore(doc)).toList();
    });
  }

  // Récupérer un produit par son ID
  Future<Product?> getProductById(String productId) async {
    try {
      DocumentSnapshot doc = await _firestore.collection(_collectionName).doc(productId).get();
      if (doc.exists) {
        return Product.fromFirestore(doc);
      }
      return null;
    } catch (e) {
      throw Exception('Erreur lors de la récupération du produit: $e');
    }
  }

  // Ajouter un produit
  Future<String> addProduct(Product product) async {
    try {
      DocumentReference docRef = await _firestore
          .collection(_collectionName)
          .add(product.toFirestore());
      return docRef.id;
    } catch (e) {
      throw Exception('Erreur lors de l\'ajout du produit: $e');
    }
  }

  // Mettre à jour un produit
  Future<void> updateProduct(String productId, Map<String, dynamic> updates) async {
    try {
      await _firestore.collection(_collectionName).doc(productId).update(updates);
    } catch (e) {
      throw Exception('Erreur lors de la mise à jour du produit: $e');
    }
  }

  // Supprimer un produit
  Future<void> deleteProduct(String productId) async {
    try {
      await _firestore.collection(_collectionName).doc(productId).delete();
    } catch (e) {
      throw Exception('Erreur lors de la suppression du produit: $e');
    }
  }

  // Rechercher des produits
  Stream<List<Product>> searchProducts(String query) {
    return _firestore
        .collection(_collectionName)
        .where('status', isEqualTo: 'disponible')
        .snapshots()
        .map((snapshot) {
      final products = snapshot.docs
          .map((doc) => Product.fromFirestore(doc))
          .where((product) =>
              product.title.toLowerCase().contains(query.toLowerCase()) ||
              product.description.toLowerCase().contains(query.toLowerCase()))
          .toList();
      return products;
    });
  }
}