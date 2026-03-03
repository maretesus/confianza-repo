import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:uuid/uuid.dart';

/// Servicio para manejar medios (videos, imágenes)
class MediaService {
  final ImagePicker _imagePicker = ImagePicker();
  final FirebaseStorage _storage = FirebaseStorage.instance;

  /// Selecciona un video de la galería
  Future<File?> pickVideoFromGallery() async {
    try {
      final XFile? pickedFile = await _imagePicker.pickVideo(
        source: ImageSource.gallery,
      );
      
      if (pickedFile != null) {
        return File(pickedFile.path);
      }
      return null;
    } catch (e) {
      print('Error seleccionando video: $e');
      return null;
    }
  }

  /// Sube un video a Firebase Storage y retorna la URL
  Future<String?> uploadVideo(File videoFile) async {
    try {
      // Generar un ID único para el archivo
      final String fileId = const Uuid().v4();
      final String fileName = 'videos/$fileId.mp4';
      
      // Subir archivo
      final Reference ref = _storage.ref().child(fileName);
      final UploadTask uploadTask = ref.putFile(
        videoFile,
        SettableMetadata(
          contentType: 'video/mp4',
        ),
      );
      
      // Esperar a que se complete la subida
      final TaskSnapshot snapshot = await uploadTask;
      
      // Obtener la URL de descarga
      final String downloadUrl = await snapshot.ref.getDownloadURL();
      
      return downloadUrl;
    } catch (e) {
      print('Error subiendo video: $e');
      return null;
    }
  }

  /// Selecciona un video y lo sube a Firebase Storage
  /// Retorna la URL del video o null si hay error
  Future<File?> selectVideo() async {
    return await pickVideoFromGallery();
  }

  /// Obtiene el tamaño del video en MB
  static double getVideoSizeMB(File videoFile) {
    return videoFile.lengthSync() / (1024 * 1024);
  }

  /// Valida que el video no sea muy grande (máximo 100MB)
  static bool isVideoSizeValid(File videoFile, {double maxSizeMB = 100}) {
    final sizeMB = getVideoSizeMB(videoFile);
    return sizeMB <= maxSizeMB;
  }
}
