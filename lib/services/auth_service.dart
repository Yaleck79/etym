import 'package:firebase_auth/firebase_auth.dart';
import 'coin_service.dart';

class AuthService {
  final CoinService _coinService = CoinService();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Récupérer l'utilisateur actuel
  User? get currentUser => _auth.currentUser;

  // Stream pour écouter les changements d'état de l'utilisateur
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  Future<UserCredential?> signUp({
  required String email,
  required String password,
  required String name,
}) async {
  try {
    UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );
    
    // Mettre à jour le nom de l'utilisateur
    await userCredential.user?.updateDisplayName(name);
    
    // 🎁 CRÉER L'UTILISATEUR DANS FIRESTORE AVEC 100 COINS
    await _coinService.createUserWithCoins(
      userCredential.user!.uid,
      name,
      email.trim(),
    );
    
    return userCredential;
  } on FirebaseAuthException catch (e) {
    throw _handleAuthError(e);
  }
}

  // Connexion avec email et mot de passe
  Future<UserCredential?> signIn({
    required String email,
    required String password,
  }) async {
    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      return userCredential;
    } on FirebaseAuthException catch (e) {
      throw _handleAuthError(e);
    }
  }

  // Déconnexion
  Future<void> signOut() async {
    await _auth.signOut();
  }

  // Gestion des erreurs
  String _handleAuthError(FirebaseAuthException e) {
    switch (e.code) {
      case 'weak-password':
        return 'Le mot de passe est trop faible.';
      case 'email-already-in-use':
        return 'Cet email est déjà utilisé.';
      case 'invalid-email':
        return 'Email invalide.';
      case 'user-not-found':
        return 'Aucun utilisateur trouvé avec cet email.';
      case 'wrong-password':
        return 'Mot de passe incorrect.';
      default:
        return 'Une erreur est survenue. Veuillez réessayer.';
    }
  }
}