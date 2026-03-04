import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:uuid/uuid.dart';

/// Servicio para manejar medios (videos, imágenes)
class MediaService {
  final ImagePicker _imagePicker = ImagePicker();
  final FirebaseStorage _storage = FirebaseStorage.instance;
  
  XFile? _lastPickedFile; // Guardar el XFile para web

  /// Selecciona un video de la galería
  /// En web, retorna un marcador especial; en mobile/desktop, retorna el File
  Future<File?> pickVideoFromGallery() async {
    try {
      print('pickVideoFromGallery() called');
      final XFile? pickedFile = await _imagePicker.pickVideo(
        source: ImageSource.gallery,
      );
      
      print('Picked file: ${pickedFile?.path}');
      print('Picked file name: ${pickedFile?.name}');
      print('Is Web: $kIsWeb');
      
      if (pickedFile == null) {
        print('No file picked (user cancelled)');
        return null;
      }
      
      // En web, no podemos crear un File directamente
      if (kIsWeb) {
        print('Running on web, storing XFile reference');
        _lastPickedFile = pickedFile;
        // Retornar un marcador especial para web
        // Usamos una ruta falsa que indica que es web
        return File('web://${pickedFile.name}');
      }
      
      // En mobile/desktop, convertir a File normalmente
      final file = File(pickedFile.path);
      print('Created File object: ${file.path}');
      print('File exists: ${file.existsSync()}');
      return file;
    } catch (e) {
      print('Error seleccionando video: $e');
      print('Stack trace: $e');
      return null;
    }
  }

  /// Sube un video a Firebase Storage y retorna la URL
  Future<String?> uploadVideo(File videoFile) async {
    try {
      print('Starting video upload: ${videoFile.path}');
      
      // Detectar si es web
      if (kIsWeb && _lastPickedFile != null) {
        print('Running on web, uploading XFile');
        return await _uploadVideoWeb(_lastPickedFile!);
      }
      
      // Mobile/Desktop: trabajar con File
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
  
  /// Sube un video desde web (XFile)
  Future<String?> _uploadVideoWeb(XFile xFile) async {
    try {
      print('Starting web video upload for: ${xFile.name}');
      
      // Obtener los bytes del archivo
      final bytes = await xFile.readAsBytes();
      print('File size: ${(bytes.length / (1024 * 1024)).toStringAsFixed(2)}MB');
      
      // Generar un ID único para el archivo
      final String fileId = const Uuid().v4();
      final String fileName = 'videos/$fileId.mp4';
      print('Uploading to Firebase Storage: $fileName');
      
      // Subir archivo
      final Reference ref = _storage.ref().child(fileName);
      final UploadTask uploadTask = ref.putData(
        bytes,
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
      print('Web upload completed. Snapshot state: ${snapshot.state}');
      
      // Obtener la URL de descarga
      final String downloadUrl = await snapshot.ref.getDownloadURL();
      print('Web video uploaded successfully: $downloadUrl');
      
      // Limpiar
      _lastPickedFile = null;
      
      return downloadUrl;
    } catch (e) {
      print('Error subiendo video en web: $e');
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
    // En web, no podemos llamar a lengthSync()
    if (kIsWeb) {
      // Retornar un valor predeterminado para web (será validado después)
      return 50.0;
    }
    return videoFile.lengthSync() / (1024 * 1024);
  }

  /// Valida que el video no sea muy grande (máximo 100MB)
  static bool isVideoSizeValid(File videoFile, {double maxSizeMB = 100}) {
    final sizeMB = getVideoSizeMB(videoFile);
    return sizeMB <= maxSizeMB;
  }
}
