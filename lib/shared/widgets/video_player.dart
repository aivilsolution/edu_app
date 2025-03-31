import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'dart:async';

class AppVideoPlayer extends StatefulWidget {
  final String videoUrl;
  final Duration timeout;
  final BoxConstraints? constraints;
  final bool autoPlay;
  final bool showControls;
  final bool looping;
  final VoidCallback? onVideoEnd;
  final Function(String)? onError;

  const AppVideoPlayer({
    super.key,
    required this.videoUrl,
    this.timeout = const Duration(seconds: 15),
    this.constraints,
    this.autoPlay = true,
    this.showControls = true,
    this.looping = false,
    this.onVideoEnd,
    this.onError,
  });

  @override
  State createState() => _AppVideoPlayerState();
}

class _AppVideoPlayerState extends State<AppVideoPlayer> {
  late VideoPlayerController _controller;

  Timer? _bufferingTimer;
  Timer? _timeoutTimer;
  Timer? _controlsTimer;

  bool _isInitializing = true;
  bool _hasError = false;
  bool _isBuffering = false;
  bool _showControls = false;
  bool _showReplayButton = false;
  bool _isSeeking = false;
  bool _isHovering = false;

  double _seekProgress = 0.0;
  Duration _currentPosition = Duration.zero;
  Duration _bufferedPosition = Duration.zero;
  Duration _totalDuration = Duration.zero;

  String _errorMessage = '';

  static const Duration _controlsDisplayDuration = Duration(seconds: 1);
  static const Duration _bufferingTimeoutDuration = Duration(seconds: 20);
  static const Duration _videoEndThreshold = Duration(milliseconds: 300);

  @override
  void initState() {
    super.initState();
    _initializeVideoPlayer();
  }

  @override
  void didUpdateWidget(covariant AppVideoPlayer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.videoUrl != widget.videoUrl) {
      _disposeResources();
      _initializeVideoPlayer();
    }

    if (oldWidget.looping != widget.looping &&
        _controller.value.isInitialized) {
      _controller.setLooping(widget.looping);
    }
  }

  Future<void> _initializeVideoPlayer() async {
    try {
      _controller = VideoPlayerController.networkUrl(
        Uri.parse(widget.videoUrl),
        videoPlayerOptions: VideoPlayerOptions(mixWithOthers: true),
      );

      _controller.addListener(_videoListener);
      _startTimeoutTimer();
      await _controller.initialize();

      if (!mounted) return;

      _controller.setLooping(widget.looping);

      setState(() {
        _isInitializing = false;
        _totalDuration = _controller.value.duration;
        _showReplayButton = false;
      });

      if (widget.autoPlay) {
        await _controller.play();
        _showControlsTemporarily();
      } else {
        setState(() => _showControls = true);
      }

      _timeoutTimer?.cancel();
    } catch (e) {
      _handleError('Failed to initialize video: $e');
    }
  }

  void _videoListener() {
    if (!mounted) return;

    if (_controller.value.hasError && !_hasError) {
      _handleError(_controller.value.errorDescription ?? 'Unknown video error');
      return;
    }

    final position = _controller.value.position;
    if (position != _currentPosition) {
      setState(() => _currentPosition = position);
    }

    final bufferedPosition = _getBufferedPosition();
    if (bufferedPosition != _bufferedPosition) {
      setState(() => _bufferedPosition = bufferedPosition);
    }

    final isBuffering = _controller.value.isBuffering;
    if (isBuffering != _isBuffering) {
      setState(() => _isBuffering = isBuffering);

      if (isBuffering) {
        _startBufferingTimer();
      } else {
        _bufferingTimer?.cancel();
      }
    }

    if (!_controller.value.isPlaying && _controller.value.isInitialized) {
      final isFinished = _isVideoFinished(position);
      if (isFinished != _showReplayButton) {
        setState(() {
          _showReplayButton = isFinished;
          if (isFinished) {
            widget.onVideoEnd?.call();
          }
        });
      }
    } else if (_controller.value.isPlaying && _showReplayButton) {
      setState(() => _showReplayButton = false);
    }
  }

  bool _isVideoFinished(Duration position) {
    return _controller.value.isInitialized &&
        !_controller.value.isPlaying &&
        position >= _totalDuration - _videoEndThreshold;
  }

  Duration _getBufferedPosition() {
    if (!_controller.value.isInitialized ||
        _controller.value.buffered.isEmpty) {
      return Duration.zero;
    }
    return _controller.value.buffered.last.end;
  }

  void _startTimeoutTimer() {
    _timeoutTimer?.cancel();
    _timeoutTimer = Timer(widget.timeout, () {
      if (_isInitializing && mounted) {
        _handleError('Video loading timed out');
      }
    });
  }

  void _startBufferingTimer() {
    _bufferingTimer?.cancel();
    _bufferingTimer = Timer(_bufferingTimeoutDuration, () {
      if (_isBuffering && mounted) {
        _handleError('Video buffering timed out');
      }
    });
  }

  void _handleError(String message) {
    _disposeTimers();
    if (!mounted) return;

    setState(() {
      _hasError = true;
      _isInitializing = false;
      _isBuffering = false;
      _errorMessage = message;
    });

    widget.onError?.call(message);
  }

  void _togglePlayPause() {
    if (_controller.value.isPlaying) {
      _controller.pause();
      setState(() => _showControls = true);
    } else {
      setState(() => _showReplayButton = false);
      _controller.play();
      _showControlsTemporarily();
    }
  }

  void _replayVideo() {
    setState(() => _showReplayButton = false);
    _controller.seekTo(Duration.zero);
    _controller.play();
    _showControlsTemporarily();
  }

  void _showControlsTemporarily() {
    if (!widget.showControls) return;
    setState(() => _showControls = true);
    _controlsTimer?.cancel();
    _controlsTimer = Timer(_controlsDisplayDuration, () {
      if (mounted && _controller.value.isPlaying && !_isHovering) {
        setState(() => _showControls = false);
      }
    });
  }

  void _handleHoverChanged(bool isHovering) {
    if (!widget.showControls) return;
    setState(() => _isHovering = isHovering);

    if (isHovering) {
      _controlsTimer?.cancel();
      if (!_showControls && _controller.value.isInitialized) {
        setState(() => _showControls = true);
      }
    } else if (_controller.value.isPlaying) {
      _showControlsTemporarily();
    }
  }

  void _handleSeekStart(DragStartDetails details) {
    _controlsTimer?.cancel();
    setState(() => _isSeeking = true);
  }

  void _handleSeekUpdate(DragUpdateDetails details) {
    final RenderBox box = context.findRenderObject() as RenderBox;
    final Offset position = box.globalToLocal(details.globalPosition);
    final double width = box.size.width;
    final double relativePosition = (position.dx / width).clamp(0.0, 1.0);
    setState(() => _seekProgress = relativePosition);
  }

  void _handleSeekEnd(DragEndDetails details) {
    final Duration newPosition = Duration(
      milliseconds: (_seekProgress * _totalDuration.inMilliseconds).round(),
    );
    _controller.seekTo(newPosition);

    if (_showReplayButton) {
      setState(() => _showReplayButton = false);
    }

    setState(() => _isSeeking = false);
    _showControlsTemporarily();
  }

  void _disposeTimers() {
    _timeoutTimer?.cancel();
    _bufferingTimer?.cancel();
    _controlsTimer?.cancel();
  }

  void _disposeResources() {
    _disposeTimers();
    _controller.removeListener(_videoListener);
    _controller.dispose();
  }

  @override
  void dispose() {
    _disposeResources();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final BoxConstraints effectiveConstraints =
            widget.constraints ?? constraints;

        return MouseRegion(
          onEnter: (_) => _handleHoverChanged(true),
          onExit: (_) => _handleHoverChanged(false),
          child: Container(
            constraints: effectiveConstraints,
            color: Colors.black,
            child: _buildContent(),
          ),
        );
      },
    );
  }

  void _handleTap() {
    if (_showReplayButton) {
      _replayVideo();
      return;
    }

    if (!_showControls) {
      _showControlsTemporarily();
    } else if (_controller.value.isPlaying) {
      setState(() => _showControls = false);
    }
  }

  Widget _buildContent() {
    if (_hasError) return _buildErrorView();
    if (_isInitializing) return _buildLoadingView();
    return _buildVideoView();
  }

  Widget _buildErrorView() {
    final theme = Theme.of(context);
    final errorColor = theme.colorScheme.error;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.error_outline, color: errorColor, size: 40),
            const SizedBox(height: 16),
            Text(
              'Failed to load video',
              style: theme.textTheme.bodyLarge?.copyWith(color: errorColor),
            ),
            const SizedBox(height: 8),
            Text(
              _errorMessage,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: errorColor.withValues(alpha: 0.8),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () {
                setState(() {
                  _hasError = false;
                  _isInitializing = true;
                  _showReplayButton = false;
                });
                _initializeVideoPlayer();
              },
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingView() {
    final theme = Theme.of(context);

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          CircularProgressIndicator(color: theme.colorScheme.primary),
          const SizedBox(height: 16),
          Text(
            'Loading video...',
            style: theme.textTheme.bodyLarge?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.8),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVideoView() {
    return Stack(
      alignment: Alignment.center,
      children: [
        GestureDetector(
          onTap: widget.showControls ? _handleTap : null,
          child: Center(
            child: AspectRatio(
              aspectRatio: _controller.value.aspectRatio,
              child: VideoPlayer(_controller),
            ),
          ),
        ),
        if (_isBuffering && !_isSeeking)
          const Center(child: CircularProgressIndicator(color: Colors.white70)),
        if (_showReplayButton) _buildReplayButton(),
        if (_showControls && !_showReplayButton && !_isBuffering)
          _buildPlayPauseButton(),
        if ((widget.showControls && _showControls) ||
            !_controller.value.isPlaying)
          _buildControlsOverlay(),
      ],
    );
  }

  Widget _buildReplayButton() {
    return GestureDetector(
      onTap: _replayVideo,
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.9),
          shape: BoxShape.circle,
        ),
        padding: const EdgeInsets.all(16),
        child: Icon(
          Icons.replay,
          size: 40,
          color: Theme.of(context).colorScheme.onPrimary,
        ),
      ),
    );
  }

  Widget _buildPlayPauseButton() {
    return AnimatedOpacity(
      opacity: _showControls ? 1.0 : 0.0,
      duration: const Duration(milliseconds: 200),
      child: GestureDetector(
        onTap: _togglePlayPause,
        behavior: HitTestBehavior.opaque,
        child: Container(
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.5),
            shape: BoxShape.circle,
          ),
          padding: const EdgeInsets.all(12),
          child: Icon(
            _controller.value.isPlaying ? Icons.pause : Icons.play_arrow,
            size: 40,
            color: Theme.of(context).colorScheme.onPrimary,
          ),
        ),
      ),
    );
  }

  Widget _buildControlsOverlay() {
    return Positioned(
      left: 0,
      right: 0,
      bottom: 0,
      child: AnimatedOpacity(
        opacity: _showControls ? 1.0 : 0.0,
        duration: const Duration(milliseconds: 200),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Colors.transparent, Colors.black.withValues(alpha: 0.7)],
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildProgressBar(),
              const SizedBox(height: 8),
              _buildControlsRow(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProgressBar() {
    return GestureDetector(
      onHorizontalDragStart: _handleSeekStart,
      onHorizontalDragUpdate: _handleSeekUpdate,
      onHorizontalDragEnd: _handleSeekEnd,
      behavior: HitTestBehavior.opaque,
      child: Container(
        height: 20,
        width: double.infinity,
        color: Colors.transparent,
        child: Center(
          child: Container(
            height: 4,
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.white24,
              borderRadius: BorderRadius.circular(2),
            ),
            child: LayoutBuilder(
              builder: (context, constraints) {
                final double maxWidth = constraints.maxWidth;
                final double progressWidth = _getProgressWidth(maxWidth);
                final double bufferedWidth = _getBufferedWidth(maxWidth);

                return Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Container(
                      width: bufferedWidth,
                      decoration: BoxDecoration(
                        color: Colors.white38,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    Container(
                      width: progressWidth,
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.primary,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    if (_isSeeking || _showControls)
                      Positioned(
                        left: progressWidth - 6,
                        top: -4,
                        child: Container(
                          width: 12,
                          height: 12,
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.primary,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.3),
                                blurRadius: 3,
                                offset: const Offset(0, 1),
                              ),
                            ],
                          ),
                        ),
                      ),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  double _getProgressWidth(double maxWidth) {
    if (_totalDuration.inMilliseconds == 0) return 0;

    if (_isSeeking) {
      return _seekProgress * maxWidth;
    } else {
      return _currentPosition.inMilliseconds /
          _totalDuration.inMilliseconds *
          maxWidth;
    }
  }

  double _getBufferedWidth(double maxWidth) {
    if (_totalDuration.inMilliseconds == 0) return 0;
    return _bufferedPosition.inMilliseconds /
        _totalDuration.inMilliseconds *
        maxWidth;
  }

  Widget _buildControlsRow() {
    return Row(
      children: [
        IconButton(
          icon: Icon(
            _controller.value.isPlaying ? Icons.pause : Icons.play_arrow,
            color: Colors.white,
          ),
          onPressed: _togglePlayPause,
          padding: EdgeInsets.zero,
          iconSize: 24,
        ),
        Text(
          '${_formatDuration(_currentPosition)} / ${_formatDuration(_totalDuration)}',
          style: const TextStyle(color: Colors.white, fontSize: 12),
        ),
        const Spacer(),
        IconButton(
          icon: const Icon(Icons.download_rounded, color: Colors.white),
          onPressed: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Download not implemented')),
            );
          },
          padding: EdgeInsets.zero,
          iconSize: 24,
        ),
        IconButton(
          icon: const Icon(Icons.volume_up, color: Colors.white),
          onPressed: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Volume control not implemented')),
            );
          },
          padding: EdgeInsets.zero,
          iconSize: 24,
        ),
        IconButton(
          icon: const Icon(Icons.fullscreen, color: Colors.white),
          onPressed: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Fullscreen not implemented')),
            );
          },
          padding: EdgeInsets.zero,
          iconSize: 24,
        ),
      ],
    );
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
    final String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));
    return "$twoDigitMinutes:$twoDigitSeconds";
  }
}
