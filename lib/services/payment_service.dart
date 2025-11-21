import 'package:cinetpay/cinetpay.dart';
import 'package:flutter/material.dart';

class PaymentService {
  // ⚠️ REMPLACE PAR TES VRAIES CLÉS CINETPAY
  static const String apiKey = '12912847765bc0db748fdd44.40081707';
  static const String siteId = '5865359';
  
  // Payer des coins
  Future<bool> payForCoins({
    required BuildContext context,
    required int coins,
    required int amount,
    required String userId,
  }) async {
    try {
      // Configuration du paiement
      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => CinetPayCheckout(
            title: 'Achat de Coins',
            titleStyle: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
            ),
            titleBackgroundColor: const Color(0xFF9E9F8D),
            configData: <String, dynamic>{
              'apikey': apiKey,
              'site_id': siteId,
              'notify_url': 'https://webhook.site/xxxxx', // ⚠️ Remplace par ton webhook
            },
            paymentData: <String, dynamic>{
              'transaction_id': 'COINS_${DateTime.now().millisecondsSinceEpoch}',
              'amount': amount,
              'currency': 'XOF',
              'channels': 'ALL',
              'description': 'Achat de $coins coins',
              'customer_name': userId,
              'customer_surname': userId,
            },
            waitResponse: (response) {
              // Callback après le paiement
              print('Réponse CinetPay: $response');
              
              if (response['status'] == 'ACCEPTED' || 
                  response['status'] == 'SUCCESSFUL') {
                // Paiement réussi
                Navigator.pop(context, true);
              } else {
                // Paiement échoué
                Navigator.pop(context, false);
              }
            },
            onError: (error) {
              print('Erreur CinetPay: $error');
              Navigator.pop(context, false);
            },
          ),
        ),
      );
      
      return true;
    } catch (e) {
      print('Erreur paiement: $e');
      return false;
    }
  }

  // Payer une commande
  Future<bool> payForOrder({
    required BuildContext context,
    required String orderId,
    required double amount,
    required String buyerName,
    required String productTitle,
  }) async {
    try {
      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => CinetPayCheckout(
            title: 'Paiement de la commande',
            titleStyle: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
            ),
            titleBackgroundColor: const Color(0xFF9E9F8D),
            configData: <String, dynamic>{
              'apikey': apiKey,
              'site_id': siteId,
              'notify_url': 'https://webhook.site/xxxxx', // ⚠️ Remplace par ton webhook
            },
            paymentData: <String, dynamic>{
              'transaction_id': orderId,
              'amount': amount.toInt(),
              'currency': 'XOF',
              'channels': 'ALL',
              'description': 'Achat: $productTitle',
              'customer_name': buyerName,
              'customer_surname': buyerName,
            },
            waitResponse: (response) {
              print('Réponse CinetPay: $response');
              
              if (response['status'] == 'ACCEPTED' || 
                  response['status'] == 'SUCCESSFUL') {
                Navigator.pop(context, true);
              } else {
                Navigator.pop(context, false);
              }
            },
            onError: (error) {
              print('Erreur CinetPay: $error');
              Navigator.pop(context, false);
            },
          ),
        ),
      );
      
      return true;
    } catch (e) {
      print('Erreur paiement: $e');
      return false;
    }
  }
}