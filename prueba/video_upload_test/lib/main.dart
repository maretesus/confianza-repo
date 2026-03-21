import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:uuid/uuid.dart';
import 'dart:io';
import 'dart:typed_data';

// ========================================
// FIREBASE CONFIG - USA TUS CREDENCIALES
// ========================================
class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }
    throw UnsupportedError('Platform not supported');
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: "AIzaSyDpd0lj_9mRFb3hK_fIZ8QSl5NQRy3nM6Q",
    authDomain: "confident-f42af.firebaseapp.com",
    projectId: "confident-f42af",
    storageBucket: "confident-f42af.appspot.com",
    messagingSenderId: "502906815849",
    appId: "1:502906815849:web:5a62f91f8b74c4dd60c913",
  );
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  print('═══════════════════════════════════════');
  print('🚀 INICIANDO APP DE PRUEBA');
  print('═══════════════════════════════════════');
  
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    print('✅ Firebase inicializado correctamente');
  } catch (e) {
    print('❌ ERROR inicializando Firebase: $e');
  }
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Test Video Upload',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: const VideoUploadTestScreen(),
    );
  }
}

class VideoUploadTestScreen extends StatefulWidget {
  const VideoUploadTestScreen({super.key});

  @override
  State<VideoUploadTestScreen> createState() => _VideoUploadTestScreenState();
}

class _VideoUploadTestScreenState extends State<VideoUploadTestScreen> {
  final ImagePicker _picker = ImagePicker();
  
  bool _isUploading = false;
  double _uploadProgress = 0.0;
  String _statusMessage = 'Listo para subir video';
  String? _videoUrl;
  String _logs = '';

  void _addLog(String message) {
    print(message);
    setState(() {
      _logs += '$message\n';
    });
  }

  Future<void> _selectAndUploadVideo() async {
    _addLog('\n═══════════════════════════════════════');
    _addLog('🎬 PASO 1: Seleccionar video');
    _addLog('═══════════════════════════════════════');
    
    try {
      final XFile? pickedFile = await _picker.pickVideo(
        source: ImageSource.gallery,
      );

      if (pickedFile == null) {
        _addLog('❌ No se seleccionó ningún video');
        setState(() {
          _statusMessage = 'No se seleccionó video';
        });
        return;
      }

      _addLog('✅ Video seleccionado: ${pickedFile.name}');
      
      if (kIsWeb) {
        final bytes = await pickedFile.readAsBytes();
        final sizeMB = bytes.length / (1024 * 1024);
        _addLog('📏 Tamaño: ${sizeMB.toStringAsFixed(2)} MB');
        
        if (sizeMB > 50) {
          _addLog('⚠️ Archivo muy grande (max 50MB para web)');
          setState(() {
            _statusMessage = 'Video muy grande (max 50MB)';
          });
          return;
        }
        
        await _uploadVideoWeb(pickedFile, bytes);
      } else {
        final file = File(pickedFile.path);
        final sizeMB = file.lengthSync() / (1024 * 1024);
        _addLog('📏 Tamaño: ${sizeMB.toStringAsFixed(2)} MB');
        
        if (sizeMB > 100) {
          _addLog('⚠️ Archivo muy grande (max 100MB)');
          setState(() {
            _statusMessage = 'Video muy grande (max 100MB)';
          });
          return;
        }
        
        await _uploadVideoMobile(file);
      }

    } catch (e, stackTrace) {
      _addLog('❌ ERROR FATAL: $e');
      _addLog('Stack trace: $stackTrace');
      setState(() {
        _statusMessage = 'Error: $e';
        _isUploading = false;
      });
    }
  }

  Future<void> _uploadVideoWeb(XFile xFile, Uint8List bytes) async {
    _addLog('\n═══════════════════════════════════════');
    _addLog('📤 PASO 2: Subir video (WEB)');
    _addLog('═══════════════════════════════════════');
    
    setState(() {
      _isUploading = true;
      _uploadProgress = 0.0;
      _statusMessage = 'Subiendo video...';
    });

    try {
      final String videoId = const Uuid().v4();
      final String fileName = 'test_videos/$videoId.mp4';
      _addLog('📝 Nombre archivo: $fileName');

      _addLog('🔥 Conectando a Firebase Storage...');
      final Reference ref = FirebaseStorage.instance.ref().child(fileName);
      _addLog('✅ Referencia creada');

      _addLog('📤 Iniciando subida...');
      final UploadTask uploadTask = ref.putData(
        bytes,
        SettableMetadata(contentType: 'video/mp4'),
      );

      uploadTask.snapshotEvents.listen((TaskSnapshot snapshot) {
        final progress = snapshot.bytesTransferred / snapshot.totalBytes;
        setState(() {
          _uploadProgress = progress;
        });
        _addLog(
          '📊 Progreso: ${(progress * 100).toStringAsFixed(1)}% '
          '(${(snapshot.bytesTransferred / 1024 / 1024).toStringAsFixed(2)} MB '
          '/ ${(snapshot.totalBytes / 1024 / 1024).toStringAsFixed(2)} MB)'
        );
      }, onError: (error) {
        _addLog('❌ ERROR en progreso: $error');
      });

      _addLog('⏳ Esperando completar subida...');
      final TaskSnapshot snapshot = await uploadTask;
      _addLog('✅ Subida completada! Estado: ${snapshot.state}');

      _addLog('🔗 Obteniendo URL de descarga...');
      final String downloadUrl = await snapshot.ref.getDownloadURL();
      _addLog('✅ URL obtenida!');
      _addLog('🎉 URL FINAL: $downloadUrl');

      setState(() {
        _videoUrl = downloadUrl;
        _statusMessage = '¡Video subido exitosamente!';
        _isUploading = false;
        _uploadProgress = 1.0;
      });

      _addLog('\n═══════════════════════════════════════');
      _addLog('🎉 ÉXITO TOTAL');
      _addLog('═══════════════════════════════════════');

    } catch (e, stackTrace) {
      _addLog('\n❌❌❌ ERROR EN SUBIDA ❌❌❌');
      _addLog('Error: $e');
      _addLog('Tipo de error: ${e.runtimeType}');
      _addLog('Stack trace completo:');
      _addLog('$stackTrace');
      
      setState(() {
        _statusMessage = 'Error: $e';
        _isUploading = false;
      });
    }
  }

  Future<void> _uploadVideoMobile(File file) async {
    _addLog('\n═══════════════════════════════════════');
    _addLog('📤 PASO 2: Subir video (MOBILE)');
    _addLog('═══════════════════════════════════════');
    
    setState(() {
      _isUploading = true;
      _uploadProgress = 0.0;
      _statusMessage = 'Subiendo video...';
    });

    try {
      final String videoId = const Uuid().v4();
      final String fileName = 'test_videos/$videoId.mp4';
      _addLog('📝 Nombre archivo: $fileName');

      _addLog('🔥 Conectando a Firebase Storage...');
      final Reference ref = FirebaseStorage.instance.ref().child(fileName);
      _addLog('✅ Referencia creada');

      _addLog('📤 Iniciando subida...');
      final UploadTask uploadTask = ref.putFile(
        file,
        SettableMetadata(contentType: 'video/mp4'),
      );

      uploadTask.snapshotEvents.listen((TaskSnapshot snapshot) {
        final progress = snapshot.bytesTransferred / snapshot.totalBytes;
        setState(() {
          _uploadProgress = progress;
        });
        _addLog(
          '📊 Progreso: ${(progress * 100).toStringAsFixed(1)}% '
          '(${(snapshot.bytesTransferred / 1024 / 1024).toStringAsFixed(2)} MB '
          '/ ${(snapshot.totalBytes / 1024 / 1024).toStringAsFixed(2)} MB)'
        );
      }, onError: (error) {
        _addLog('❌ ERROR en progreso: $error');
      });

      _addLog('⏳ Esperando completar subida...');
      final TaskSnapshot snapshot = await uploadTask;
      _addLog('✅ Subida completada! Estado: ${snapshot.state}');

      _addLog('🔗 Obteniendo URL de descarga...');
      final String downloadUrl = await snapshot.ref.getDownloadURL();
      _addLog('✅ URL obtenida!');
      _addLog('🎉 URL FINAL: $downloadUrl');

      setState(() {
        _videoUrl = downloadUrl;
        _statusMessage = '¡Video subido exitosamente!';
        _isUploading = false;
        _uploadProgress = 1.0;
      });

      _addLog('\n═══════════════════════════════════════');
      _addLog('🎉 ÉXITO TOTAL');
      _addLog('═══════════════════════════════════════');

    } catch (e, stackTrace) {
      _addLog('\n❌❌❌ ERROR EN SUBIDA ❌❌❌');
      _addLog('Error: $e');
      _addLog('Tipo de error: ${e.runtimeType}');
      _addLog('Stack trace completo:');
      _addLog('$stackTrace');
      
      setState(() {
        _statusMessage = 'Error: $e';
        _isUploading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Test Subida de Video'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Card(
              color: _videoUrl != null 
                ? Colors.green.shade50 
                : Colors.blue.shade50,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    Icon(
                      _videoUrl != null ? Icons.check_circle : Icons.cloud_upload,
                      size: 48,
                      color: _videoUrl != null ? Colors.green : Colors.blue,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _statusMessage,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 16),

            ElevatedButton.icon(
              onPressed: _isUploading ? null : _selectAndUploadVideo,
              icon: _isUploading 
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.video_library),
              label: Text(_isUploading ? 'Subiendo...' : 'Seleccionar y Subir Video'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.all(16),
              ),
            ),

            if (_isUploading) ...[
              const SizedBox(height: 16),
              LinearProgressIndicator(value: _uploadProgress),
              const SizedBox(height: 8),
              Text(
                '${(_uploadProgress * 100).toStringAsFixed(1)}%',
                textAlign: TextAlign.center,
              ),
            ],

            if (_videoUrl != null) ...[
              const SizedBox(height: 16),
              const Text(
                'URL del video:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              SelectableText(
                _videoUrl!,
                style: const TextStyle(fontSize: 12),
              ),
            ],

            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 8),

            const Text(
              'LOGS DE DEBUGGING:',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.grey.shade900,
                  borderRadius: BorderRadius.circular(8),
                ),
                padding: const EdgeInsets.all(12),
                child: SingleChildScrollView(
                  child: SelectableText(
                    _logs.isEmpty ? 'Esperando acción...' : _logs,
                    style: const TextStyle(
                      fontFamily: 'monospace',
                      fontSize: 12,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
