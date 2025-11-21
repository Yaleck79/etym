import 'package:flutter/foundation.dart';
import '../models/cart_item_model.dart';
import '../models/product_model.dart';

class CartService extends ChangeNotifier {
  final List<CartItem> _items = [];

  List<CartItem> get items => _items;

  int get itemCount => _items.length;

  double get totalPrice {
    return _items.fold(0, (sum, item) => sum + item.totalPrice);
  }

  String get formattedTotalPrice {
    return '${totalPrice.toStringAsFixed(0).replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]} ',
    )} FCFA';
  }

  // Ajouter un produit au panier
  void addToCart(Product product) {
    // Vérifier si le produit existe déjà
    int existingIndex = _items.indexWhere((item) => item.product.id == product.id);

    if (existingIndex >= 0) {
      // Si le produit existe, augmenter la quantité
      _items[existingIndex].quantity++;
    } else {
      // Sinon, ajouter un nouveau produit
      _items.add(CartItem(product: product));
    }

    notifyListeners();
  }

  // Retirer un produit du panier
  void removeFromCart(String productId) {
    _items.removeWhere((item) => item.product.id == productId);
    notifyListeners();
  }

  // Augmenter la quantité
  void increaseQuantity(String productId) {
    int index = _items.indexWhere((item) => item.product.id == productId);
    if (index >= 0) {
      _items[index].quantity++;
      notifyListeners();
    }
  }

  // Diminuer la quantité
  void decreaseQuantity(String productId) {
    int index = _items.indexWhere((item) => item.product.id == productId);
    if (index >= 0) {
      if (_items[index].quantity > 1) {
        _items[index].quantity--;
      } else {
        _items.removeAt(index);
      }
      notifyListeners();
    }
  }

  // Vider le panier
  void clearCart() {
    _items.clear();
    notifyListeners();
  }

  // Vérifier si un produit est dans le panier
  bool isInCart(String productId) {
    return _items.any((item) => item.product.id == productId);
  }
}