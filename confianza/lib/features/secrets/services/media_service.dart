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
      print('Starting video upload: ${videoFile.path}');
      print('File size: ${getVideoSizeMB(videoFile).toStringAsFixed(2)}MB');
      
      // Validar que el archivo existe
      if (!videoFile.existsSync()) {
        print('Video file does not exist: ${videoFile.path}');
        return null;
      }
      
      // Generar un ID único para el archivo
      final String fileId = const Uuid().v4();
      final String fileName = 'videos/$fileId.mp4';
      print('Uploading to Firebase Storage: $fileName');
      
      // Subir archivo
      final Reference ref = _storage.ref().child(fileName);
      final UploadTask uploadTask = ref.putFile(
        videoFile,
        SettableMetadata(
          contentType: 'video/mp4',
        ),
      );
      
      // Escuchar el progreso
      uploadTask.snapshotEvents.listen((TaskSnapshot snapshot) {
        final progress = (snapshot.bytesTransferred / snapshot.totalBytes) * 100;
        print('Upload progress: ${progress.toStringAsFixed(2)}%');
      });
      
      // Esperar a que se complete la subida
      final TaskSnapshot snapshot = await uploadTask;
      print('Upload completed. Snapshot state: ${snapshot.state}');
      
      // Obtener la URL de descarga
      final String downloadUrl = await snapshot.ref.getDownloadURL();
      print('Video uploaded successfully: $downloadUrl');
      
      return downloadUrl;
    } catch (e) {
      print('Error subiendo video: $e');
      print('Stack trace: $e');
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
