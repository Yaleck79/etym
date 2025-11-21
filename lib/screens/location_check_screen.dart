import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../utils/colors.dart';
import '../services/location_service.dart';
import 'login_screen.dart';

class LocationCheckScreen extends StatefulWidget {
  const LocationCheckScreen({super.key});

  @override
  State<LocationCheckScreen> createState() => _LocationCheckScreenState();
}

class _LocationCheckScreenState extends State<LocationCheckScreen> {
  final LocationService _locationService = LocationService();
  bool _isChecking = true;
  bool _isInBenin = false;
  String _userCountry = '';

  @override
  void initState() {
    super.initState();
    _checkLocation();
  }

  Future<void> _checkLocation() async {
    setState(() => _isChecking = true);

    // Vérifier si l'utilisateur est au Bénin
    bool inBenin = await _locationService.isUserInBenin();
    
    if (!inBenin) {
      // Obtenir le nom du pays pour l'afficher
      String country = await _locationService.getUserCountry();
      setState(() {
        _isInBenin = false;
        _userCountry = country;
        _isChecking = false;
      });
    } else {
      setState(() {
        _isInBenin = true;
        _isChecking = false;
      });
      
      // Naviguer vers la page de connexion
      Future.delayed(const Duration(seconds: 1), () {
        if (mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const LoginScreen()),
          );
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.lightBeige,
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Logo
                Text(
                  'E-TYM',
                  style: GoogleFonts.aoboshiOne(
                    fontSize: 56,
                    color: AppColors.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 48),

                if (_isChecking) ...[
                  // Vérification en cours
                  const CircularProgressIndicator(
                    color: AppColors.primary,
                    strokeWidth: 3,
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Vérification de votre localisation...',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      color: AppColors.secondary,
                    ),
                  ),
                ] else if (_isInBenin) ...[
                  // Utilisateur au Bénin
                  const Icon(
                    Icons.check_circle,
                    color: Colors.green,
                    size: 80,
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Bienvenue !',
                    style: GoogleFonts.poppins(
                      fontSize: 24,
                      fontWeight: FontWeight.w600,
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Vous êtes au Bénin 🇧🇯',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      color: AppColors.secondary,
                    ),
                  ),
                ] else ...[
                  // Utilisateur hors du Bénin
                  const Icon(
                    Icons.location_off,
                    color: AppColors.error,
                    size: 80,
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Service non disponible',
                    style: GoogleFonts.poppins(
                      fontSize: 24,
                      fontWeight: FontWeight.w600,
                      color: AppColors.error,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: AppColors.white,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      children: [
                        Text(
                          'E-TYM est actuellement disponible uniquement au Bénin 🇧🇯',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            color: AppColors.black,
                            height: 1.5,
                          ),
                        ),
                        if (_userCountry.isNotEmpty && _userCountry != 'Inconnu') ...[
                          const SizedBox(height: 16),
                          Text(
                            'Votre localisation : $_userCountry',
                            textAlign: TextAlign.center,
                            style: GoogleFonts.poppins(
                              fontSize: 14,
                              color: AppColors.secondary,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ],
                        const SizedBox(height: 24),
                        Text(
                          'Nous travaillons pour étendre nos services dans d\'autres pays prochainement.',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            color: AppColors.secondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: _checkLocation,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: AppColors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 32,
                        vertical: 16,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      'Réessayer',
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}