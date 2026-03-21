import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:video_player/video_player.dart';

import '../models/secret.dart';
import '../providers/secrets_providers.dart';
import '../services/media_service.dart';

class RecordScreen extends ConsumerStatefulWidget {
  const RecordScreen({super.key});

  @override
  ConsumerState<RecordScreen> createState() => _RecordScreenState();
}

class _RecordScreenState extends ConsumerState<RecordScreen> {
  final MediaService _mediaService = MediaService();
  List<CameraDescription> _cameras = [];
  CameraController? _cameraController;
  bool _isInitializing = true;
  bool _isRecording = false;
  XFile? _recordedVideo;
  VideoPlayerController? _previewController;
  bool _isUploading = false;
  DateTime? _recordingStartTime;

  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _setupCamera();
  }

  @override
  void dispose() {
    _cameraController?.dispose();
    _previewController?.dispose();
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _setupCamera() async {
    try {
      _cameras = await availableCameras();
      if (_cameras.isNotEmpty) {
        _cameraController = CameraController(
          _cameras.first,
          ResolutionPreset.high,
          enableAudio: true,
        );
        await _cameraController!.initialize();
      }
    } catch (e) {
      // Ignorar, se mostrará mensaje de error luego
    } finally {
      if (mounted) {
        setState(() {
          _isInitializing = false;
        });
      }
    }
  }

  Future<void> _toggleRecord() async {
    if (_cameraController == null || !_cameraController!.value.isInitialized) return;

    if (_isRecording) {
      final XFile file = await _cameraController!.stopVideoRecording();
      setState(() {
        _isRecording = false;
        _recordingStartTime = null;
        _recordedVideo = file;
      });
      await _preparePreview(file);
    } else {
      await _cameraController!.startVideoRecording();
      setState(() {
        _isRecording = true;
        _recordingStartTime = DateTime.now();
      });
    }
  }

  Future<void> _preparePreview(XFile file) async {
    _previewController?.dispose();
    _previewController = VideoPlayerController.file(File(file.path));
    await _previewController!.initialize();
    _previewController!.setLooping(true);
    await _previewController!.play();
    setState(() {});
  }

  Future<void> _handlePublish() async {
    if (_recordedVideo == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Graba un video primero')));
      return;
    }

    if (_isUploading) return;

    setState(() => _isUploading = true);

    try {
      final uploadedUrl = await _mediaService.uploadVideo(File(_recordedVideo!.path));
      if (uploadedUrl == null || uploadedUrl.isEmpty) {
        throw Exception('Error subiendo video');
      }

      final newSecret = Secret(
        id: '',
        userId: null,
        videoUrl: uploadedUrl,
        title: _titleController.text.isEmpty ? 'Video grabado' : _titleController.text,
        description: _descriptionController.text.isEmpty ? null : _descriptionController.text,
        category: 'WEIRD',
        likes: 0,
        comments: 0,
        createdAt: DateTime.now(),
        isAnonymous: true,
      );

      final newSecretId = await ref.read(createSecretProvider(newSecret).future);
      if (!mounted) return;
      if (newSecretId != null) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Video publicado')));
        Navigator.of(context).pop();
      } else {
        throw Exception('No se creó el secreto');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    } finally {
      if (mounted) {
        setState(() => _isUploading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Grabar video'),
        centerTitle: true,
      ),
      body: _isInitializing
          ? const Center(child: CircularProgressIndicator())
          : _cameraController == null || !_cameraController!.value.isInitialized
              ? const Center(child: Text('No se encuentran cámaras disponibles'))
              : Column(
                  children: [
                    AspectRatio(
                      aspectRatio: _cameraController!.value.aspectRatio,
                      child: CameraPreview(_cameraController!),
                    ),
                    const SizedBox(height: 12),
                    // Indicador de tiempo de grabación
                    if (_isRecording && _recordingStartTime != null)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: Colors.red.withOpacity(0.9),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.fiber_manual_record, color: Colors.white, size: 16),
                            const SizedBox(width: 8),
                            StreamBuilder(
                              stream: Stream.periodic(const Duration(seconds: 1)),
                              builder: (context, snapshot) {
                                final duration = DateTime.now().difference(_recordingStartTime!);
                                final minutes = duration.inMinutes.toString().padLeft(2, '0');
                                final seconds = (duration.inSeconds % 60).toString().padLeft(2, '0');
                                return Text(
                                  '$minutes:$seconds',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                    const SizedBox(height: 12),
                    // Botón grande de grabación
                    Center(
                      child: GestureDetector(
                        onTap: _toggleRecord,
                        child: Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: _isRecording ? Colors.red : Colors.white,
                            border: Border.all(
                              color: _isRecording ? Colors.red : Colors.grey,
                              width: 4,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.3),
                                blurRadius: 8,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Icon(
                            _isRecording ? Icons.stop : Icons.fiber_manual_record,
                            color: _isRecording ? Colors.white : Colors.red,
                            size: 40,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Center(
                      child: Text(
                        _isRecording ? 'Tocá para detener' : 'Tocá para grabar',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    if (_recordedVideo != null)
                      Center(
                        child: ElevatedButton.icon(
                          onPressed: () => _preparePreview(_recordedVideo!),
                          icon: const Icon(Icons.play_arrow),
                          label: const Text('Ver preview'),
                        ),
                      ),
                    if (_previewController != null && _previewController!.value.isInitialized)
                      SizedBox(
                        height: 180,
                        child: VideoPlayer(_previewController!),
                      ),
                    const SizedBox(height: 12),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: TextField(
                        controller: _titleController,
                        decoration: const InputDecoration(labelText: 'Título (opcional)'),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: TextField(
                        controller: _descriptionController,
                        decoration: const InputDecoration(labelText: 'Descripción (opcional)'),
                      ),
                    ),
                    const SizedBox(height: 12),
                    ElevatedButton(
                      onPressed: _isUploading ? null : _handlePublish,
                      child: _isUploading ? const CircularProgressIndicator() : const Text('Publicar video'),
                    ),
                  ],
                ),
    );
  }
}
