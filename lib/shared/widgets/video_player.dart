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
  final bool isFullScreen;
  final Duration initialPosition;
  final Function(Duration)? onVideoPositionChanged;
  final Function(bool)? onPlayStateChanged;

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
    this.isFullScreen = false,
    this.initialPosition = Duration.zero,
    this.onVideoPositionChanged,
    this.onPlayStateChanged,
  });

  @override
  State createState() => AppVideoPlayerState();
}

class AppVideoPlayerState extends State<AppVideoPlayer> {
  late VideoPlayerController _controller;

  Timer? _bufferingTimer;
  Timer? _timeoutTimer;
  Timer? _controlsTimer;
  Timer? _positionUpdateTimer;

  bool _isInitializing = true;
  bool _hasError = false;
  bool _isBuffering = false;
  bool _showControls = false;
  bool _showReplayButton = false;
  bool _isSeeking = false;
  bool _isHovering = false;
  bool _wasPlaying = false;
  bool _userInteracting = false;

  double _seekProgress = 0.0;
  Duration _currentPosition = Duration.zero;
  Duration _bufferedPosition = Duration.zero;
  Duration _totalDuration = Duration.zero;

  String _errorMessage = '';

  static const Duration _controlsDisplayDuration = Duration(seconds: 3);
  static const Duration _bufferingTimeoutDuration = Duration(seconds: 10);
  static const Duration _videoEndThreshold = Duration(milliseconds: 300);
  static const Duration _positionUpdateInterval = Duration(milliseconds: 500);

  @override
  void initState() {
    super.initState();
    _wasPlaying = widget.autoPlay;
    _initializeVideoPlayer();
  }

  @override
  void didUpdateWidget(covariant AppVideoPlayer oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.videoUrl != widget.videoUrl) {
      _disposeResources();
      _initializeVideoPlayer();
      return;
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

      if (widget.initialPosition != Duration.zero) {
        await _controller.seekTo(widget.initialPosition);
      }

      _controller.setLooping(widget.looping);
      _startPositionUpdateTimer();

      setState(() {
        _isInitializing = false;
        _totalDuration = _controller.value.duration;
        _currentPosition = widget.initialPosition;
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

    final isPlaying = _controller.value.isPlaying;
    if (_wasPlaying != isPlaying) {
      _wasPlaying = isPlaying;
      widget.onPlayStateChanged?.call(isPlaying);
    }

    if (!isPlaying && _controller.value.isInitialized) {
      final isFinished = _isVideoFinished(_controller.value.position);
      if (isFinished != _showReplayButton) {
        setState(() {
          _showReplayButton = isFinished;
          if (isFinished) {
            widget.onVideoEnd?.call();
          }
        });
      }
    } else if (isPlaying && _showReplayButton) {
      setState(() => _showReplayButton = false);
    }
  }

  void _startPositionUpdateTimer() {
    _positionUpdateTimer?.cancel();
    _positionUpdateTimer = Timer.periodic(_positionUpdateInterval, (_) {
      if (!mounted || !_controller.value.isInitialized || _isSeeking) return;

      final newPosition = _controller.value.position;
      if (newPosition != _currentPosition) {
        setState(() => _currentPosition = newPosition);
        widget.onVideoPositionChanged?.call(newPosition);
      }
    });
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
    _userInteracting = true;
    if (_controller.value.isPlaying) {
      _controller.pause();
      setState(() => _showControls = true);
    } else {
      setState(() => _showReplayButton = false);
      _controller.play();
      _showControlsTemporarily();
    }
    _resetUserInteraction();
  }

  void _replayVideo() {
    _userInteracting = true;
    setState(() => _showReplayButton = false);
    _controller.seekTo(Duration.zero);
    _controller.play();
    _showControlsTemporarily();
    _resetUserInteraction();
  }

  void _showControlsTemporarily() {
    if (!widget.showControls) return;

    setState(() => _showControls = true);
    _controlsTimer?.cancel();
    _controlsTimer = Timer(_controlsDisplayDuration, () {
      if (mounted && _controller.value.isPlaying && !_userInteracting) {
        setState(() => _showControls = false);
      }
    });
  }

  void _resetUserInteraction() {
    Future.delayed(const Duration(milliseconds: 500), () {
      _userInteracting = false;
    });
  }

  void _handleHoverChanged(bool isHovering) {
    if (!widget.showControls) return;

    setState(() => _isHovering = isHovering);

    if (isHovering) {
      if (!_showControls && _controller.value.isInitialized) {
        _userInteracting = true;
        setState(() => _showControls = true);
        _resetUserInteraction();
      }

      _controlsTimer?.cancel();
      _controlsTimer = Timer(_controlsDisplayDuration, () {
        if (mounted && _controller.value.isPlaying && !_userInteracting) {
          setState(() => _showControls = false);
        }
      });
    }
  }

  void _handleSeekStart(DragStartDetails details) {
    _userInteracting = true;
    _controlsTimer?.cancel();
    setState(() => _isSeeking = true);
  }

  void _handleSeekUpdate(DragUpdateDetails details) {
    _userInteracting = true;
    final RenderBox box = context.findRenderObject() as RenderBox;
    final Offset position = box.globalToLocal(details.globalPosition);
    final double relativePosition = (position.dx / box.size.width).clamp(
      0.0,
      1.0,
    );
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
    _resetUserInteraction();
  }

  void _handleTap() {
    _userInteracting = true;
    if (_showReplayButton) {
      _replayVideo();
    } else if (!_showControls) {
      _showControlsTemporarily();
    } else {
      _togglePlayPause();
    }
    _resetUserInteraction();
  }

  void _disposeTimers() {
    _timeoutTimer?.cancel();
    _bufferingTimer?.cancel();
    _controlsTimer?.cancel();
    _positionUpdateTimer?.cancel();
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

  Future<void> _toggleFullScreen() async {
    _userInteracting = true;
    if (widget.isFullScreen) {
      final currentPosition = _controller.value.position.inMilliseconds;
      final isPlaying = _controller.value.isPlaying;

      if (isPlaying) {
        await _controller.pause();
      }

      Navigator.of(context).pop(
        VideoReturnData(
          position: currentPosition,
          isPlaying: isPlaying,
          looping: widget.looping,
        ),
      );
    } else {
      final wasPlaying = _controller.value.isPlaying;
      if (wasPlaying) {
        await _controller.pause();
      }

      final currentPosition = _controller.value.position.inMilliseconds;

      try {
        final result = await Navigator.of(context).push<VideoReturnData>(
          MaterialPageRoute(
            builder:
                (context) => VideoScreen(
                  videoUrl: widget.videoUrl,
                  position: currentPosition,
                  isPlaying: wasPlaying,
                  looping: widget.looping,
                ),
          ),
        );

        if (result != null && mounted) {
          await _controller.seekTo(Duration(milliseconds: result.position));

          if (result.isPlaying) {
            await _controller.play();
          } else {
            await _controller.pause();
          }
        }
      } catch (e) {
        debugPrint('Error handling fullscreen navigation: $e');

        if (wasPlaying && mounted) {
          await _controller.play();
        }
      }
    }
    _resetUserInteraction();
  }

  @override
  Widget build(BuildContext context) {
    return widget.isFullScreen
        ? _buildFullScreenLayout()
        : _buildRegularLayout();
  }

  Widget _buildFullScreenLayout() {
    return Scaffold(
      backgroundColor: Colors.black,
      body: MouseRegion(
        onEnter: (_) => _handleHoverChanged(true),
        onExit: (_) => _handleHoverChanged(false),
        onHover: (_) => _handleHoverChanged(true),
        child: SafeArea(
          child: Stack(
            children: [
              _buildContent(),
              if (_showControls)
                Positioned(
                  top: 16,
                  left: 16,
                  child: IconButton(
                    icon: const Icon(
                      Icons.arrow_back,
                      color: Colors.white,
                      size: 28,
                    ),
                    onPressed: _toggleFullScreen,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRegularLayout() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final effectiveConstraints = widget.constraints ?? constraints;

        return MouseRegion(
          onEnter: (_) => _handleHoverChanged(true),
          onExit: (_) => _handleHoverChanged(false),
          onHover: (_) => _handleHoverChanged(true),
          child: Container(
            constraints: effectiveConstraints,
            color: Colors.black,
            child: _buildContent(),
          ),
        );
      },
    );
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
                                color: Colors.black.withOpacity(0.3),
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

    return (_isSeeking
            ? _seekProgress
            : _currentPosition.inMilliseconds / _totalDuration.inMilliseconds) *
        maxWidth;
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
          icon: Icon(
            widget.isFullScreen ? Icons.fullscreen_exit : Icons.fullscreen,
            color: Colors.white,
          ),
          onPressed: _toggleFullScreen,
          padding: EdgeInsets.zero,
          iconSize: 24,
        ),
      ],
    );
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final String minutes = twoDigits(duration.inMinutes.remainder(60));
    final String seconds = twoDigits(duration.inSeconds.remainder(60));
    return "$minutes:$seconds";
  }
}

class VideoReturnData {
  final int position;
  final bool isPlaying;
  final bool looping;

  VideoReturnData({
    required this.position,
    required this.isPlaying,
    required this.looping,
  });

  factory VideoReturnData.fromJson(Map<dynamic, dynamic> json) {
    return VideoReturnData(
      position: json['position'] as int? ?? 0,
      isPlaying: json['isPlaying'] as bool? ?? false,
      looping: json['looping'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {'position': position, 'isPlaying': isPlaying, 'looping': looping};
  }
}

class VideoScreen extends StatelessWidget {
  final String videoUrl;
  final int position;
  final bool isPlaying;
  final bool looping;

  const VideoScreen({
    super.key,
    required this.videoUrl,
    this.position = 0,
    this.isPlaying = true,
    this.looping = false,
  });

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) async {
        if (!didPop) {
          final playerState =
              context.findAncestorStateOfType<AppVideoPlayerState>();
          if (playerState != null) {
            final currentPosition =
                playerState._controller.value.position.inMilliseconds;
            final isPlaying = playerState._controller.value.isPlaying;

            Navigator.of(context).pop(
              VideoReturnData(
                position: currentPosition,
                isPlaying: isPlaying,
                looping: looping,
              ),
            );
          } else {
            Navigator.of(context).pop(
              VideoReturnData(
                position: position,
                isPlaying: isPlaying,
                looping: looping,
              ),
            );
          }
        }
      },
      child: Scaffold(
        backgroundColor: Colors.black,
        body: SafeArea(
          child: AppVideoPlayer(
            videoUrl: videoUrl,
            isFullScreen: true,
            autoPlay: isPlaying,
            looping: looping,
            initialPosition: Duration(milliseconds: position),
          ),
        ),
      ),
    );
  }
}
