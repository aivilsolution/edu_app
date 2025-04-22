import 'dart:async';
import 'package:flutter/material.dart';
import 'package:livekit_client/livekit_client.dart';
import '../exts.dart';

import 'room.dart';

class JoinArgs {
  JoinArgs({
    required this.url,
    required this.token,
    this.e2ee = false,
    this.e2eeKey,
    this.simulcast = true,
    this.adaptiveStream = true,
    this.dynacast = true,
    this.preferredCodec = 'VP8',
    this.enableBackupVideoCodec = true,
  });
  final String url;
  final String token;
  final bool e2ee;
  final String? e2eeKey;
  final bool simulcast;
  final bool adaptiveStream;
  final bool dynacast;
  final String preferredCodec;
  final bool enableBackupVideoCodec;
}

class PreJoinPage extends StatefulWidget {
  final JoinArgs args;
  final bool videoCall;
  const PreJoinPage({required this.args, super.key, required this.videoCall});
  @override
  State<StatefulWidget> createState() => _PreJoinPageState();
}

class _PreJoinPageState extends State<PreJoinPage> {
  List<MediaDevice> _audioInputs = [];
  List<MediaDevice> _videoInputs = [];
  StreamSubscription? _subscription;

  bool _busy = false;
  LocalAudioTrack? _audioTrack;
  LocalVideoTrack? _videoTrack;

  MediaDevice? _selectedVideoDevice;
  MediaDevice? _selectedAudioDevice;
  VideoParameters selectedVideoParameters = VideoParametersPresets.h720_169;
  bool _autoJoinInitiated = false;

  @override
  void initState() {
    super.initState();
    _subscription = Hardware.instance.onDeviceChange.stream.listen(
      _loadDevices,
    );
    Hardware.instance.enumerateDevices().then(_loadDevices);
  }

  @override
  void deactivate() {
    _subscription?.cancel();
    super.deactivate();
  }

  Future<void> _loadDevices(List<MediaDevice> devices) async {
    _audioInputs = devices.where((d) => d.kind == 'audioinput').toList();
    _videoInputs = devices.where((d) => d.kind == 'videoinput').toList();

    if (_audioInputs.isNotEmpty) {
      if (_selectedAudioDevice == null) {
        _selectedAudioDevice = _audioInputs.first;
        await _changeLocalAudioTrack();
      }
    }

    if (_videoInputs.isNotEmpty) {
      if (_selectedVideoDevice == null) {
        _selectedVideoDevice = _videoInputs.first;
        await _changeLocalVideoTrack();
      }
    }

    if (!_autoJoinInitiated && mounted) {
      _autoJoinInitiated = true;
      _join(context);
    }
  }

  Future<void> _changeLocalAudioTrack() async {
    if (_audioTrack != null) {
      await _audioTrack!.stop();
      _audioTrack = null;
    }

    if (_selectedAudioDevice != null) {
      _audioTrack = await LocalAudioTrack.create(
        AudioCaptureOptions(deviceId: _selectedAudioDevice!.deviceId),
      );
      await _audioTrack!.start();
    }
  }

  Future<void> _changeLocalVideoTrack() async {
    if (_videoTrack != null) {
      await _videoTrack!.stop();
      _videoTrack = null;
    }

    if (_selectedVideoDevice != null) {
      _videoTrack = await LocalVideoTrack.createCameraTrack(
        CameraCaptureOptions(
          deviceId: _selectedVideoDevice!.deviceId,
          params: selectedVideoParameters,
        ),
      );
      await _videoTrack!.start();
    }
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }

  Future<void> _join(BuildContext context) async {
    if (_busy) return;
    _busy = true;

    var args = widget.args;

    try {
      final cameraEncoding = const VideoEncoding(
        maxBitrate: 5 * 1000 * 1000,
        maxFramerate: 30,
      );
      final screenEncoding = const VideoEncoding(
        maxBitrate: 3 * 1000 * 1000,
        maxFramerate: 15,
      );

      E2EEOptions? e2eeOptions;
      if (args.e2ee && args.e2eeKey != null) {
        final keyProvider = await BaseKeyProvider.create();
        e2eeOptions = E2EEOptions(keyProvider: keyProvider);
        await keyProvider.setKey(args.e2eeKey!);
      }

      final room = Room(
        roomOptions: RoomOptions(
          adaptiveStream: args.adaptiveStream,
          dynacast: args.dynacast,
          defaultAudioPublishOptions: const AudioPublishOptions(
            name: 'custom_audio_track_name',
          ),
          defaultCameraCaptureOptions: const CameraCaptureOptions(
            maxFrameRate: 30,
            params: VideoParameters(dimensions: VideoDimensions(1280, 720)),
          ),
          defaultScreenShareCaptureOptions: const ScreenShareCaptureOptions(
            useiOSBroadcastExtension: true,
            params: VideoParameters(
              dimensions: VideoDimensionsPresets.h1080_169,
            ),
          ),
          defaultVideoPublishOptions: VideoPublishOptions(
            simulcast: args.simulcast,
            videoCodec: args.preferredCodec,
            backupVideoCodec: BackupVideoCodec(
              enabled: args.enableBackupVideoCodec,
            ),
            videoEncoding: cameraEncoding,
            screenShareEncoding: screenEncoding,
          ),
          e2eeOptions: e2eeOptions,
        ),
      );

      final listener = room.createListener();
      await room.prepareConnection(args.url, args.token);
      await room.connect(
        args.url,
        args.token,
        fastConnectOptions: FastConnectOptions(
          microphone: TrackOption(track: _audioTrack),
          camera: TrackOption(track: _videoTrack),
        ),
      );

      if (!context.mounted) return;

      await Navigator.push<void>(
        context,
        MaterialPageRoute(
          builder: (_) => RoomPage(room, listener, videoCall: widget.videoCall),
        ),
      );
    } catch (error) {
      if (context.mounted) {
        await context.showErrorDialog(error);
      }
    } finally {
      _busy = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            CircularProgressIndicator(),
            SizedBox(height: 20),
            Text('Connecting to call...'),
          ],
        ),
      ),
    );
  }
}
