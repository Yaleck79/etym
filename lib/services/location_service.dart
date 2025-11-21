import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:permission_handler/permission_handler.dart';

class LocationService {
  // Vérifier si l'utilisateur est au Bénin
  Future<bool> isUserInBenin() async {
    try {
      // Demander la permission de localisation
      PermissionStatus permission = await Permission.location.request();
      
      if (permission.isGranted) {
        // Obtenir la position actuelle
        Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.medium,
        );

        // Convertir les coordonnées en adresse
        List<Placemark> placemarks = await placemarkFromCoordinates(
          position.latitude,
          position.longitude,
        );

        if (placemarks.isNotEmpty) {
          String? country = placemarks[0].country;
          String? countryCode = placemarks[0].isoCountryCode;
          
          // Vérifier si c'est le Bénin
          // Code pays du Bénin : "BJ"
          // Nom : "Benin" ou "Bénin"
          return countryCode == 'BJ' || 
                 country?.toLowerCase().contains('benin') == true ||
                 country?.toLowerCase().contains('bénin') == true;
        }
      }
      
      // Si la permission est refusée, on retourne false
      return false;
    } catch (e) {
      print('Erreur de géolocalisation: $e');
      return false;
    }
  }

  // Obtenir le nom du pays de l'utilisateur
  Future<String> getUserCountry() async {
    try {
      PermissionStatus permission = await Permission.location.request();
      
      if (permission.isGranted) {
        Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.medium,
        );

        List<Placemark> placemarks = await placemarkFromCoordinates(
          position.latitude,
          position.longitude,
        );

        if (placemarks.isNotEmpty) {
          return placemarks[0].country ?? 'Inconnu';
        }
      }
      
      return 'Inconnu';
    } catch (e) {
      return 'Inconnu';
    }
  }
}