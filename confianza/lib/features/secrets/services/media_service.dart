import 'dart:io';
import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:uuid/uuid.dart';

/// Servicio para manejar medios (videos, imágenes)
class MediaService {
  final ImagePicker _imagePicker = ImagePicker();
  final FirebaseStorage _storage = FirebaseStorage.instance;
  
  XFile? _lastPickedFile; // Guardar el XFile para web
  String? _lastVideoId; // Guardar el ID del último video subido
  
  // Configuración de subida
  static const int MAX_RETRIES = 3;
  static const Duration UPLOAD_TIMEOUT = Duration(minutes: 2);
  static const double WEB_MAX_SIZE_MB = 20;
  static const double MOBILE_MAX_SIZE_MB = 100;

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

  /// Obtiene el tamaño real del último archivo seleccionado (útil en web)
  Future<double?> getLastPickedFileSizeMB() async {
    if (_lastPickedFile == null) return null;
    return await getXFileSizeMB(_lastPickedFile!);
  }

  /// Obtiene el ID del último video subido
  String? getLastVideoId() {
    return _lastVideoId;
  }

  /// Sube un video a Firebase Storage y retorna la URL
  /// Incluye reintentos automáticos si falla
  Future<String?> uploadVideo(File videoFile) async {
    try {
      print('=== Starting video upload ===');
      print('Video file path: ${videoFile.path}');
      
      // Detectar si es web
      if (kIsWeb && _lastPickedFile != null) {
        print('Platform: Web');
        return await _uploadVideoWebWithRetry(_lastPickedFile!);
      }
      
      // Mobile/Desktop: trabajar con File
      print('Platform: Mobile/Desktop');
      print('File size: ${getVideoSizeMB(videoFile).toStringAsFixed(2)}MB');
      
      // Validar que el archivo existe
      if (!videoFile.existsSync()) {
        print('❌ Video file does not exist: ${videoFile.path}');
        return null;
      }
      
      return await _uploadVideoMobileWithRetry(videoFile);
    } catch (e) {
      print('❌ Fatal error in uploadVideo: $e');
      return null;
    }
  }
  
  /// Intenta subir el video varias veces en caso de fallo (Mobile/Desktop)
  Future<String?> _uploadVideoMobileWithRetry(File videoFile) async {
    for (int attempt = 1; attempt <= MAX_RETRIES; attempt++) {
      try {
        print('📤 Upload attempt $attempt/$MAX_RETRIES');
        
        // Generar un ID único para el archivo
        final String fileId = const Uuid().v4();
        _lastVideoId = fileId; // Guardar el ID para acceso posterior
        final String fileName = 'videos/$fileId.mp4';
        print('Uploading to Firebase Storage: $fileName');
        print('   Video ID: $fileId');
        
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
          print('  Progress: ${progress.toStringAsFixed(1)}% (${(snapshot.bytesTransferred / 1024 / 1024).toStringAsFixed(2)}MB / ${(snapshot.totalBytes / 1024 / 1024).toStringAsFixed(2)}MB)');
        });
        
        // Esperar a que se complete con timeout
        print('⏱️ Waiting for upload to complete (timeout: ${UPLOAD_TIMEOUT.inSeconds}s)...');
        final TaskSnapshot snapshot = await uploadTask.timeout(
          UPLOAD_TIMEOUT,
          onTimeout: () {
            print('⏰ Upload timeout - cancelling...');
            uploadTask.cancel();
            throw TimeoutException('Upload timed out after ${UPLOAD_TIMEOUT.inSeconds}s', UPLOAD_TIMEOUT);
          },
        );
        
        print('✅ Upload completed. Snapshot state: ${snapshot.state}');
        
        // Obtener la URL de descarga
        final String downloadUrl = await snapshot.ref.getDownloadURL();
        print('✅ Video uploaded successfully!');
        print('   URL: $downloadUrl');
        return downloadUrl;
        
      } on TimeoutException {
        print('⏰ Attempt $attempt failed: timeout');
        if (attempt < MAX_RETRIES) {
          print('🔄 Retrying in 3 seconds...');
          await Future.delayed(Duration(seconds: 3));
        }
      } catch (e) {
        print('⚠️ Attempt $attempt failed: $e');
        if (attempt < MAX_RETRIES) {
          print('🔄 Retrying in 3 seconds...');
          await Future.delayed(Duration(seconds: 3));
        }
      }
    }
    return null;
  }
  
  /// Intenta subir el video varias veces en caso de fallo (Web)
  Future<String?> _uploadVideoWebWithRetry(XFile xFile) async {
    for (int attempt = 1; attempt <= MAX_RETRIES; attempt++) {
      try {
        print('📤 Web upload attempt $attempt/$MAX_RETRIES');
        return await _uploadVideoWeb(xFile);
      } catch (e) {
        print('⚠️ Attempt $attempt failed: $e');
        if (attempt < MAX_RETRIES) {
          print('🔄 Retrying in 3 seconds...');
          await Future.delayed(Duration(seconds: 3));
        }
      }
    }
    return null;
  }
  
  /// Sube un video desde web (XFile)
  Future<String?> _uploadVideoWeb(XFile xFile) async {
    try {
      print('Starting web video upload for: ${xFile.name}');
      
      // Obtener los bytes del archivo
      final bytes = await xFile.readAsBytes();
      final fileSizeMB = bytes.length / (1024 * 1024);
      print('File size: ${fileSizeMB.toStringAsFixed(2)}MB');
      
      // Validar tamaño máximo (20MB para web por estabilidad)
      if (fileSizeMB > WEB_MAX_SIZE_MB) {
        print('❌ File too large for web: ${fileSizeMB.toStringAsFixed(2)}MB (max ${WEB_MAX_SIZE_MB}MB)');
        throw Exception('Video too large for web (max ${WEB_MAX_SIZE_MB}MB)');
      }
      
      // Generar un ID único para el archivo
      final String fileId = const Uuid().v4();
      _lastVideoId = fileId; // Guardar el ID para acceso posterior
      final String fileName = 'videos/$fileId.mp4';
      print('Uploading to Firebase Storage: $fileName');
      print('   Video ID: $fileId');
      
      // Subir archivo
      final Reference ref = _storage.ref().child(fileName);
      final UploadTask uploadTask = ref.putData(
        bytes,
        SettableMetadata(
          contentType: 'video/mp4',
        ),
      );
      
      // Escuchar el progreso
      final progressSub = uploadTask.snapshotEvents.listen((TaskSnapshot snapshot) {
        final progress = (snapshot.bytesTransferred / snapshot.totalBytes) * 100;
        print('  Progress: ${progress.toStringAsFixed(1)}% (${(snapshot.bytesTransferred / 1024 / 1024).toStringAsFixed(2)}MB / ${(snapshot.totalBytes / 1024 / 1024).toStringAsFixed(2)}MB)');
      });
      
      // Esperar a que se complete la subida con timeout
      print('⏱️ Waiting for upload to complete (timeout: ${UPLOAD_TIMEOUT.inSeconds}s)...');
      final TaskSnapshot snapshot = await uploadTask.timeout(
        UPLOAD_TIMEOUT,
        onTimeout: () {
          print('⏰ Upload timeout - cancelling...');
          uploadTask.cancel();
          throw TimeoutException('Upload timed out', UPLOAD_TIMEOUT);
        },
      );
      
      progressSub.cancel();
      
      print('✅ Upload completed. Snapshot state: ${snapshot.state}');
      
      // Obtener la URL de descarga
      final String downloadUrl = await snapshot.ref.getDownloadURL();
      print('✅ Web video uploaded successfully!');
      print('   URL: $downloadUrl');
      
      // Limpiar
      _lastPickedFile = null;
      
      return downloadUrl;
    } catch (e) {
      print('❌ Error subiendo video en web: $e');
      rethrow;
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

  /// Obtiene el tamaño real del XFile en web (en MB)
  static Future<double> getXFileSizeMB(XFile xFile) async {
    final bytes = await xFile.readAsBytes();
    return bytes.length / (1024 * 1024);
  }

  /// Valida que el video no sea muy grande
  static Future<bool> isVideoSizeValidAsync(XFile? xFile) async {
    if (xFile == null) return true;
    
    final sizeMB = await getXFileSizeMB(xFile);
    final maxSize = kIsWeb ? WEB_MAX_SIZE_MB : MOBILE_MAX_SIZE_MB;
    return sizeMB <= maxSize;
  }
}
