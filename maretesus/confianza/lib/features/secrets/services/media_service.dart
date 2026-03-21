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

  XFile? _lastPickedFile; // guardamos el XFile en web

  // configuración de subida
  static const int MAX_RETRIES = 3;
  static const Duration UPLOAD_TIMEOUT = Duration(minutes: 2);
  static const double WEB_MAX_SIZE_MB = 20;
  static const double MOBILE_MAX_SIZE_MB = 100;

  /// abre el selector y devuelve el File (o null)
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
        return null;
      }

      if (kIsWeb) {
        // web no puede devolver File, así que guardamos el XFile para upload
        _lastPickedFile = pickedFile;
        return null; // el caller deberá usar getLastPickedFileSizeMB
      }

      // mobile/desktop
      final file = File(pickedFile.path);
      print('Created File object: ${file.path}');
      print('File exists: ${file.existsSync()}');
      return file;
    } catch (e, st) {
      print('Error seleccionando video: $e');
      print(st);
      return null;
    }
  }

  Future<double?> getLastPickedFileSizeMB() async {
    if (_lastPickedFile == null) return null;
    return await getXFileSizeMB(_lastPickedFile!);
  }

  Future<String?> uploadVideo(File videoFile) async {
    try {
      print('=== Starting video upload ===');
      print('Video file path: ${videoFile.path}');

      if (kIsWeb) {
        if (_lastPickedFile == null) {
          print('Web upload failed: no XFile guardado');
          return null;
        }
        return await _uploadVideoWebWithRetry(_lastPickedFile!);
      }

      print('Platform: Mobile/Desktop');
      final sizeMB = getVideoSizeMB(videoFile);
      print('File size: ${sizeMB.toStringAsFixed(2)}MB');

      if (sizeMB > MOBILE_MAX_SIZE_MB) {
        print('❌ Video too large: ${sizeMB.toStringAsFixed(2)}MB');
        return null;
      }

      if (!videoFile.existsSync()) {
        print('❌ Video file does not exist: ${videoFile.path}');
        return null;
      }

      return await _uploadVideoMobileWithRetry(videoFile);
    } catch (e, st) {
      print('❌ Fatal error in uploadVideo: $e');
      print(st);
      return null;
    }
  }

  Future<String?> _uploadVideoMobileWithRetry(File videoFile) async {
    for (int attempt = 1; attempt <= MAX_RETRIES; attempt++) {
      try {
        final String fileId = const Uuid().v4();
        final Reference ref = _storage.ref().child('videos/$fileId.mp4');
        final UploadTask task = ref.putFile(
          videoFile,
          SettableMetadata(contentType: 'video/mp4'),
        );
        final TaskSnapshot snap = await task.timeout(UPLOAD_TIMEOUT);
        return await snap.ref.getDownloadURL();
      } on TimeoutException {
        print('timeout en intento $attempt');
        if (attempt == MAX_RETRIES) rethrow;
      } catch (e) {
        print('upload attempt $attempt failed: $e');
        if (attempt == MAX_RETRIES) rethrow;
      }
      await Future.delayed(const Duration(seconds: 1));
    }
    return null;
  }

  Future<String?> _uploadVideoWebWithRetry(XFile xFile) async {
    for (int attempt = 1; attempt <= MAX_RETRIES; attempt++) {
      try {
        return await _uploadVideoWeb(xFile);
      } catch (e) {
        print('web upload attempt $attempt failed: $e');
        if (attempt == MAX_RETRIES) rethrow;
        await Future.delayed(const Duration(seconds: 1));
      }
    }
    return null;
  }

  Future<String?> _uploadVideoWeb(XFile xFile) async {
    try {
      print('Starting web video upload for: ${xFile.name}');
      final bytes = await xFile.readAsBytes();
      final fileSizeMB = bytes.length / (1024 * 1024);
      print('File size: ${fileSizeMB.toStringAsFixed(2)}MB');
      if (fileSizeMB > WEB_MAX_SIZE_MB) {
        print('❌ Web video too large');
        return null;
      }
      final String fileId = const Uuid().v4();
      final String fileName = 'videos/$fileId.mp4';
      print('Uploading to Firebase Storage: $fileName');
      final Reference ref = _storage.ref().child(fileName);
      final UploadTask uploadTask = ref.putData(
        bytes,
        SettableMetadata(contentType: 'video/mp4'),
      );
      final TaskSnapshot snap = await uploadTask.timeout(UPLOAD_TIMEOUT);
      final downloadUrl = await snap.ref.getDownloadURL();
      print('Web upload finished, url = $downloadUrl');
      return downloadUrl;
    } catch (e, st) {
      print('Error en _uploadVideoWeb: $e');
      print(st);
      rethrow;
    }
  }

  static double getVideoSizeMB(File videoFile) {
    if (kIsWeb) return 0.0;
    return videoFile.lengthSync() / (1024 * 1024);
  }

  static Future<double> getXFileSizeMB(XFile xFile) async {
    final bytes = await xFile.readAsBytes();
    return bytes.length / (1024 * 1024);
  }

  static Future<bool> isVideoSizeValidAsync(XFile? xFile) async {
    if (xFile == null) return true;
    final sizeMB = await getXFileSizeMB(xFile);
    final maxSize = kIsWeb ? WEB_MAX_SIZE_MB : MOBILE_MAX_SIZE_MB;
    return sizeMB <= maxSize;
  }
}