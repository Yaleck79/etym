import 'dart:io';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';

class ImageService {
  final ImagePicker _picker = ImagePicker();
  final String _imgbbApiKey = 'edbee570845e94d6b84f850032a0a17a';

  Future<File?> takePhoto() async {
    try {
      PermissionStatus permission = await Permission.camera.request();
      if (permission.isGranted) {
        final XFile? photo = await _picker.pickImage(
          source: ImageSource.camera,
          maxWidth: 1920,
          maxHeight: 1080,
          imageQuality: 85,
        );
        if (photo != null) {
          return File(photo.path);
        }
      }
      return null;
    } catch (e) {
      print('Erreur caméra: $e');
      return null;
    }
  }

  Future<File?> pickImage() async {
    try {
      PermissionStatus permission = await Permission.photos.request();
      if (permission.isGranted || permission.isLimited) {
        final XFile? image = await _picker.pickImage(
          source: ImageSource.gallery,
          maxWidth: 1920,
          maxHeight: 1080,
          imageQuality: 85,
        );
        if (image != null) {
          return File(image.path);
        }
      }
      return null;
    } catch (e) {
      print('Erreur galerie: $e');
      return null;
    }
  }

  Future<List<File>> pickMultipleImages() async {
    try {
      PermissionStatus permission = await Permission.photos.request();
      if (permission.isGranted || permission.isLimited) {
        final List<XFile> images = await _picker.pickMultiImage(
          maxWidth: 1920,
          maxHeight: 1080,
          imageQuality: 85,
        );
        if (images.isNotEmpty) {
          return images.map((xFile) => File(xFile.path)).toList();
        }
      }
      return [];
    } catch (e) {
      print('Erreur: $e');
      return [];
    }
  }

  Future<String?> uploadImage(File imageFile, String folder) async {
    try {
      List<int> imageBytes = await imageFile.readAsBytes();
      String base64Image = base64Encode(imageBytes);

      var request = http.MultipartRequest(
        'POST',
        Uri.parse('https://api.imgbb.com/1/upload'),
      );

      request.fields['key'] = _imgbbApiKey;
      request.fields['image'] = base64Image;

      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        var jsonResponse = json.decode(response.body);
        return jsonResponse['data']['url'];
      }
      return null;
    } catch (e) {
      print('Erreur upload: $e');
      return null;
    }
  }

  Future<List<String>> uploadMultipleImages(
      List<File> imageFiles, String folder) async {
    List<String> urls = [];
    for (int i = 0; i < imageFiles.length; i++) {
      String? url = await uploadImage(imageFiles[i], folder);
      if (url != null) {
        urls.add(url);
      }
    }
    return urls;
  }
}
