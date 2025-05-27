import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

/// Component for displaying videos in an immersive tour
class VideoComponent extends StatefulWidget {
  final String videoUrl;
  final bool autoplay;
  final bool loop;

  const VideoComponent({
    super.key,
    required this.videoUrl,
    this.autoplay = false,
    this.loop = false,
  });

  @override
  State<VideoComponent> createState() => _VideoComponentState();
}

class _VideoComponentState extends State<VideoComponent> {
  late VideoPlayerController _controller;
  bool _isInitialized = false;
  bool _showControls = false;
  bool _isBuffering = false;

  @override
  void initState() {
    super.initState();
    _initVideoPlayer();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _initVideoPlayer() async {
    // Check if video URL is a network URL or an asset
    if (widget.videoUrl.startsWith('http')) {
      _controller = VideoPlayerController.networkUrl(
          Uri.parse(widget.videoUrl)); // Use networkUrl with Uri.parse
    } else {
      _controller = VideoPlayerController.asset(widget.videoUrl);
    }

    // Add error listener
    _controller.addListener(() {
      if (_controller.value.hasError) {
        debugPrint(
            'VideoPlayerController Error: ${_controller.value.errorDescription}');
        if (mounted) {
          setState(() {
            // Potentially update UI to show an error message
          });
        }
      }
      final isBuffering = _controller.value.isBuffering;
      if (_isBuffering != isBuffering) {
        if (mounted) {
          setState(() {
            _isBuffering = isBuffering;
          });
        }
      }
    });

    // Set looping based on props
    _controller.setLooping(widget.loop);

    // Initialize controller
    await _controller.initialize();

    // Set playback status based on autoplay
    if (widget.autoplay) {
      await _controller.play();
    }

    // Update state
    if (mounted) {
      setState(() {
        _isInitialized = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: AspectRatio(
        aspectRatio: _isInitialized ? _controller.value.aspectRatio : 16 / 9,
        child: Stack(
          children: [
            // Video player
            if (_isInitialized)
              VideoPlayer(_controller)
            else
              const Center(
                child: CircularProgressIndicator(color: Colors.white),
              ),

            // Buffering indicator
            if (_isBuffering)
              const Center(
                child: CircularProgressIndicator(color: Colors.white70),
              ),

            // Tap detector for showing/hiding controls
            Positioned.fill(
              child: GestureDetector(
                onTap: () {
                  setState(() {
                    _showControls = !_showControls;
                  });

                  // Auto-hide controls after 3 seconds
                  if (_showControls) {
                    Future.delayed(const Duration(seconds: 3), () {
                      if (mounted) {
                        setState(() {
                          _showControls = false;
                        });
                      }
                    });
                  }
                },
                child: Container(color: Colors.transparent),
              ),
            ),

            // Play/Pause controls
            if (_showControls && _isInitialized)
              Center(
                child: Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: Colors.black54,
                    shape: BoxShape.circle,
                  ),
                  child: IconButton(
                    icon: Icon(
                      _controller.value.isPlaying
                          ? Icons.pause
                          : Icons.play_arrow,
                      color: Colors.white,
                      size: 32,
                    ),
                    onPressed: () {
                      setState(() {
                        _controller.value.isPlaying
                            ? _controller.pause()
                            : _controller.play();
                      });
                    },
                  ),
                ),
              ),

            // Progress bar and time
            if (_showControls && _isInitialized)
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [Colors.transparent, Colors.black54],
                    ),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Video progress bar
                      VideoProgressIndicator(
                        _controller,
                        allowScrubbing: true,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 8),
                        colors: const VideoProgressColors(
                          playedColor: Colors.red,
                          bufferedColor: Colors.white54,
                          backgroundColor: Colors.white24,
                        ),
                      ),

                      // Time display
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              _formatDuration(_controller.value.position),
                              style: const TextStyle(color: Colors.white70),
                            ),
                            Text(
                              _formatDuration(_controller.value.duration),
                              style: const TextStyle(color: Colors.white70),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  // Format duration to minutes:seconds
  String _formatDuration(Duration duration) {
    final minutes = duration.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = duration.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }
}
