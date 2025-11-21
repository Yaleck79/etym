import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../utils/colors.dart';
import '../services/auth_service.dart';
import '../services/coin_service.dart';
import '../screens/buy_coins_screen.dart';

class CoinDisplayWidget extends StatelessWidget {
  const CoinDisplayWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final authService = AuthService();
    final coinService = CoinService();
    final user = authService.currentUser;

    if (user == null) return const SizedBox.shrink();

    return StreamBuilder<int>(
      stream: coinService.coinsStream(user.uid),
      builder: (context, snapshot) {
        int coins = snapshot.data ?? 0;

        return GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const BuyCoinsScreen()),
            );
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppColors.white, width: 1.5),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.monetization_on,
                  color: Colors.amber,
                  size: 20,
                ),
                const SizedBox(width: 6),
                Text(
                  '$coins',
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: AppColors.white,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}