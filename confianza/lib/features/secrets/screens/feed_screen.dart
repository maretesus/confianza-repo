import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:video_player/video_player.dart';
import '../models/secret.dart';
import '../providers/secrets_providers.dart';

class FeedScreen extends ConsumerStatefulWidget {
  const FeedScreen({super.key});

  @override
  ConsumerState<FeedScreen> createState() => _FeedScreenState();
}

class _FeedScreenState extends ConsumerState<FeedScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final secretsAsync = ref.watch(secretsProvider);

    return Scaffold(
      backgroundColor: Colors.black,
      body: secretsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator(color: Colors.white)),
        error: (error, stack) => Center(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text('Error cargando feed: $error', style: const TextStyle(color: Colors.white)),
          ),
        ),
        data: (secrets) {
          if (secrets.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.sentiment_dissatisfied, color: Colors.white70, size: 56),
                  const SizedBox(height: 12),
                  const Text('No hay videos aún', style: TextStyle(color: Colors.white70)),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => context.push('/record'),
                    child: const Text('Grabar el primero'),
                  ),
                ],
              ),
            );
          }

          return Stack(
            children: [
              PageView.builder(
                controller: _pageController,
                itemCount: secrets.length,
                scrollDirection: Axis.vertical,
                pageSnapping: true,
                physics: const BouncingScrollPhysics(),
                onPageChanged: (index) {
                  setState(() => _currentPage = index);
                },
                itemBuilder: (context, index) {
                  final secret = secrets[index];
                  return _FeedVideoPage(
                    secret: secret,
                    isActive: index == _currentPage,
                  );
                },
              ),
              Positioned(
                top: 40,
                left: 16,
                right: 16,
                child: SafeArea(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Image.asset('assets/images/logo.png', height: 32),
                      FloatingActionButton(
                        mini: true,
                        backgroundColor: Colors.black45,
                        onPressed: () => context.push('/record'),
                        child: const Icon(Icons.videocam, color: Colors.white),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _FeedVideoPage extends StatefulWidget {
  final Secret secret;
  final bool isActive;

  const _FeedVideoPage({
    required this.secret,
    required this.isActive,
  });

  @override
  State<_FeedVideoPage> createState() => _FeedVideoPageState();
}

class _FeedVideoPageState extends State<_FeedVideoPage> {
  VideoPlayerController? _controller;
  bool _isMuted = true;
  bool _isReady = false;

  @override
  void initState() {
    super.initState();
    _initVideo();
  }

  @override
  void didUpdateWidget(covariant _FeedVideoPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.secret.videoUrl != widget.secret.videoUrl) {
      _initVideo();
    } else if (oldWidget.isActive != widget.isActive) {
      _applyPlaybackState();
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  Future<void> _initVideo() async {
    _isReady = false;
    setState(() {});

    _controller?.dispose();
    _controller = VideoPlayerController.networkUrl(Uri.parse(widget.secret.videoUrl));

    try {
      await _controller!.initialize();
      _controller!
        ..setLooping(true)
        ..setVolume(_isMuted ? 0 : 1);

      _isReady = true;
      _applyPlaybackState();
    } catch (_) {
      _isReady = false;
    }

    if (mounted) {
      setState(() {});
    }
  }

  void _applyPlaybackState() {
    if (_controller == null || !_isReady) return;

    if (widget.isActive) {
      if (!_controller!.value.isPlaying) _controller!.play();
    } else {
      if (_controller!.value.isPlaying) _controller!.pause();
    }
  }

  void _togglePlayPause() {
    if (_controller == null || !_isReady) return;
    if (_controller!.value.isPlaying) {
      _controller!.pause();
    } else {
      _controller!.play();
    }
    setState(() {});
  }

  void _toggleMute() {
    if (_controller == null || !_isReady) return;
    _isMuted = !_isMuted;
    _controller!.setVolume(_isMuted ? 0 : 1);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    if (!_isReady || _controller == null || !_controller!.value.isInitialized) {
      return Container(
        color: Colors.black,
        child: const Center(child: CircularProgressIndicator(color: Colors.white)),
      );
    }

    return GestureDetector(
      onTap: _togglePlayPause,
      onDoubleTap: _toggleMute,
      child: Stack(
        fit: StackFit.expand,
        children: [
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 350),
            child: FittedBox(
              key: ValueKey(widget.secret.videoUrl),
              fit: BoxFit.cover,
              child: SizedBox(
                width: _controller!.value.size.width,
                height: _controller!.value.size.height,
                child: VideoPlayer(_controller!),
              ),
            ),
          ),
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Colors.transparent, Colors.black54],
                stops: const [0.6, 1.0],
              ),
            ),
          ),
          Positioned(
            right: 12,
            bottom: 88,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                _buildActionButton(Icons.favorite, widget.secret.likes.toString(), 'Me gusta'),
                const SizedBox(height: 14),
                _buildActionButton(Icons.comment, widget.secret.comments.toString(), 'Comentarios'),
              ],
            ),
          ),
          Positioned(
            left: 16,
            bottom: 64,
            right: 96,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(widget.secret.title, style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                const SizedBox(height: 6),
                if (widget.secret.description != null)
                  Text(widget.secret.description!, style: const TextStyle(color: Colors.white70)),
              ],
            ),
          ),
          if (_controller!.value.isBuffering)
            const Center(child: CircularProgressIndicator(color: Colors.white)),
          Positioned(
            top: 22,
            right: 22,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(color: Colors.black45, borderRadius: BorderRadius.circular(12)),
              child: Text(
                _isMuted ? 'Muted' : 'Sound On',
                style: const TextStyle(color: Colors.white, fontSize: 12),
              ),
            ),
          ),
          Center(
            child: Icon(
              _controller!.value.isPlaying ? Icons.pause_circle : Icons.play_circle_outline,
              color: Colors.white70,
              size: 70,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(IconData iconData, String count, String tooltip) {
    return Column(
      children: [
        IconButton(
          onPressed: () {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$tooltip no implementado aún')));
          },
          icon: Icon(iconData, color: Colors.white, size: 30),
        ),
        Text(count, style: const TextStyle(color: Colors.white, fontSize: 12)),
      ],
    );
  }
}
