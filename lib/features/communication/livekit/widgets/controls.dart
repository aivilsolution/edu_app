import 'dart:async';
import 'dart:convert';

import 'package:collection/collection.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_background/flutter_background.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:livekit_client/livekit_client.dart';

import '../exts.dart';

class ControlsWidget extends StatefulWidget {
  final Room room;
  final LocalParticipant participant;
  final bool videoEnabled;

  const ControlsWidget(
    this.room,
    this.participant, {
    super.key,
    required this.videoEnabled,
  });

  @override
  State<StatefulWidget> createState() => _ControlsWidgetState();
}

class _ControlsWidgetState extends State<ControlsWidget>
    with SingleTickerProviderStateMixin {
  CameraPosition position = CameraPosition.front;

  List<MediaDevice>? _audioInputs;
  List<MediaDevice>? _audioOutputs;
  List<MediaDevice>? _videoInputs;

  StreamSubscription? _subscription;
  late AnimationController _animationController;
  bool _isExpanded = false;

  bool _speakerphoneOn = Hardware.instance.speakerOn ?? false;

  bool get isMuted => participant.isMuted;

  LocalParticipant get participant => widget.participant;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return SafeArea(
      child: Align(
        alignment: Alignment.bottomCenter,
        child: Padding(
          padding: const EdgeInsets.only(bottom: 24, left: 16, right: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Stack(
                alignment: Alignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      vertical: 16,
                      horizontal: 24,
                    ),
                    decoration: BoxDecoration(
                      color: colorScheme.surface.withOpacity(0.95),
                      borderRadius: BorderRadius.circular(36),
                      border: Border.all(
                        color: colorScheme.primary.withOpacity(0.2),
                        width: 1,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.15),
                          blurRadius: 15,
                          offset: const Offset(0, 5),
                          spreadRadius: 1,
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.center,
                      spacing: 16,
                      children: [
                        _buildControlButton(
                          context: context,
                          backgroundColor:
                              participant.isMicrophoneEnabled()
                                  ? colorScheme.primary
                                  : colorScheme.error,
                          onPressed:
                              participant.isMicrophoneEnabled()
                                  ? _disableAudio
                                  : _enableAudio,
                          icon:
                              participant.isMicrophoneEnabled()
                                  ? Icons.mic
                                  : Icons.mic_off,
                          tooltip:
                              participant.isMicrophoneEnabled()
                                  ? 'Mute audio'
                                  : 'Unmute audio',
                        ),

                        if (widget.videoEnabled)
                          _buildControlButton(
                            context: context,
                            backgroundColor:
                                participant.isCameraEnabled()
                                    ? colorScheme.primary
                                    : colorScheme.error,
                            onPressed:
                                participant.isCameraEnabled()
                                    ? _disableVideo
                                    : _enableVideo,
                            icon:
                                participant.isCameraEnabled()
                                    ? Icons.videocam
                                    : Icons.videocam_off,
                            tooltip:
                                participant.isCameraEnabled()
                                    ? 'Disable camera'
                                    : 'Enable camera',
                          ),
                        if (widget.videoEnabled)
                          _buildControlButton(
                            context: context,
                            backgroundColor: colorScheme.secondary,
                            onPressed: _toggleCamera,
                            icon:
                                position == CameraPosition.back
                                    ? Icons.video_camera_back
                                    : Icons.video_camera_front,
                            tooltip: 'Switch camera',
                          ),

                        _buildControlButton(
                          context: context,
                          backgroundColor: colorScheme.error,
                          onPressed: _onTapDisconnect,
                          icon: Icons.call_end,
                          tooltip: 'End call',
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _subscription?.cancel();
    participant.removeListener(_onChange);
    _animationController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    participant.addListener(_onChange);
    _subscription = Hardware.instance.onDeviceChange.stream.listen((
      List<MediaDevice> devices,
    ) {
      _loadDevices(devices);
    });
    Hardware.instance.enumerateDevices().then(_loadDevices);

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
  }

  Widget _buildAdvancedButton({
    required BuildContext context,
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
    required bool isActive,
  }) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Material(
          color: isActive ? colorScheme.primary : colorScheme.surface,
          elevation: 2,
          shadowColor:
              isActive
                  ? colorScheme.primary.withOpacity(0.5)
                  : Colors.black.withOpacity(0.2),
          borderRadius: BorderRadius.circular(14),
          child: InkWell(
            onTap: onPressed,
            borderRadius: BorderRadius.circular(14),
            child: Container(
              padding: const EdgeInsets.all(12),
              child: Icon(
                icon,
                color: isActive ? Colors.white : colorScheme.onSurface,
                size: 22,
              ),
            ),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: theme.textTheme.bodySmall?.copyWith(
            color: colorScheme.onSurface.withOpacity(0.8),
          ),
        ),
      ],
    );
  }

  Widget _buildControlButton({
    required BuildContext context,
    required Color backgroundColor,
    required VoidCallback onPressed,
    required IconData icon,
    required String tooltip,
    double iconSize = 24,
  }) {
    return Material(
      shape: const CircleBorder(),
      color: backgroundColor,
      elevation: 4,
      shadowColor: backgroundColor.withOpacity(0.5),
      child: InkWell(
        onTap: onPressed,
        customBorder: const CircleBorder(),
        child: Tooltip(
          message: tooltip,
          child: Container(
            padding: const EdgeInsets.all(14),
            child: Icon(icon, color: Colors.white, size: iconSize),
          ),
        ),
      ),
    );
  }

  void _disableAudio() async {
    await participant.setMicrophoneEnabled(false);
  }

  void _disableScreenShare() async {
    await participant.setScreenShareEnabled(false);
    if (lkPlatformIs(PlatformType.android)) {
      try {} catch (error) {
        print('error disabling screen share: $error');
      }
    }
  }

  void _disableVideo() async {
    await participant.setCameraEnabled(false);
  }

  Future<void> _enableAudio() async {
    await participant.setMicrophoneEnabled(true);
  }

  void _enableScreenShare() async {
    if (lkPlatformIsDesktop()) {
      try {
        final source = await showDialog<DesktopCapturerSource>(
          context: context,
          builder: (context) => ScreenSelectDialog(),
        );
        if (source == null) {
          print('cancelled screenshare');
          return;
        }
        print('DesktopCapturerSource: ${source.id}');
        var track = await LocalVideoTrack.createScreenShareTrack(
          ScreenShareCaptureOptions(sourceId: source.id, maxFrameRate: 15.0),
        );
        await participant.publishVideoTrack(track);
      } catch (e) {
        print('could not publish video: $e');
      }
      return;
    }
    if (lkPlatformIs(PlatformType.android)) {
      bool hasCapturePermission = await Helper.requestCapturePermission();
      if (!hasCapturePermission) {
        return;
      }

      requestBackgroundPermission([bool isRetry = false]) async {
        try {
          bool hasPermissions = await FlutterBackground.hasPermissions;
          if (!isRetry) {
            const androidConfig = FlutterBackgroundAndroidConfig(
              notificationTitle: 'Screen Sharing',
              notificationText: 'LiveKit Example is sharing the screen.',
              notificationImportance: AndroidNotificationImportance.normal,
              notificationIcon: AndroidResource(
                name: 'livekit_ic_launcher',
                defType: 'mipmap',
              ),
            );
            hasPermissions = await FlutterBackground.initialize(
              androidConfig: androidConfig,
            );
          }
          if (hasPermissions &&
              !FlutterBackground.isBackgroundExecutionEnabled) {
            await FlutterBackground.enableBackgroundExecution();
          }
        } catch (e) {
          if (!isRetry) {
            return await Future<void>.delayed(
              const Duration(seconds: 1),
              () => requestBackgroundPermission(true),
            );
          }
          print('could not publish video: $e');
        }
      }

      await requestBackgroundPermission();
    }

    if (lkPlatformIsWebMobile()) {
      await context.showErrorDialog(
        'Screen share is not supported on mobile web',
      );
      return;
    }
    await participant.setScreenShareEnabled(true, captureScreenAudio: true);
  }

  void _enableVideo() async {
    await participant.setCameraEnabled(true);
  }

  void _loadDevices(List<MediaDevice> devices) async {
    _audioInputs = devices.where((d) => d.kind == 'audioinput').toList();
    _audioOutputs = devices.where((d) => d.kind == 'audiooutput').toList();
    _videoInputs = devices.where((d) => d.kind == 'videoinput').toList();
    setState(() {});
  }

  void _onChange() {
    setState(() {});
  }

  void _onTapDisconnect() async {
    final result = await context.showDisconnectDialog();
    if (result == true) await widget.room.disconnect();
  }

  void _onTapSendData() async {
    final result = await context.showSendDataDialog();
    if (result == true) {
      await widget.participant.publishData(
        utf8.encode('This is a sample data message'),
      );
    }
  }

  void _onTapSimulateScenario() async {
    final result = await context.showSimulateScenarioDialog();
    if (result != null) {
      print('${result}');

      if (SimulateScenarioResult.e2eeKeyRatchet == result) {
        await widget.room.e2eeManager?.ratchetKey();
      }

      if (SimulateScenarioResult.participantMetadata == result) {
        widget.room.localParticipant?.setMetadata(
          'new metadata ${widget.room.localParticipant?.identity}',
        );
      }

      if (SimulateScenarioResult.participantName == result) {
        widget.room.localParticipant?.setName(
          'new name for ${widget.room.localParticipant?.identity}',
        );
      }

      await widget.room.sendSimulateScenario(
        speakerUpdate:
            result == SimulateScenarioResult.speakerUpdate ? 3 : null,
        signalReconnect:
            result == SimulateScenarioResult.signalReconnect ? true : null,
        fullReconnect:
            result == SimulateScenarioResult.fullReconnect ? true : null,
        nodeFailure: result == SimulateScenarioResult.nodeFailure ? true : null,
        migration: result == SimulateScenarioResult.migration ? true : null,
        serverLeave: result == SimulateScenarioResult.serverLeave ? true : null,
        switchCandidate:
            result == SimulateScenarioResult.switchCandidate ? true : null,
      );
    }
  }

  void _onTapUpdateSubscribePermission() async {
    final result = await context.showSubscribePermissionDialog();
    if (result != null) {
      try {
        widget.room.localParticipant?.setTrackSubscriptionPermissions(
          allParticipantsAllowed: result,
        );
      } catch (error) {
        await context.showErrorDialog(error);
      }
    }
  }

  void _selectAudioInput(MediaDevice device) async {
    await widget.room.setAudioInputDevice(device);
    setState(() {});
  }

  void _selectAudioOutput(MediaDevice device) async {
    await widget.room.setAudioOutputDevice(device);
    setState(() {});
  }

  void _selectVideoInput(MediaDevice device) async {
    await widget.room.setVideoInputDevice(device);
    setState(() {});
  }

  void _setSpeakerphoneOn() async {
    _speakerphoneOn = !_speakerphoneOn;
    await widget.room.setSpeakerOn(_speakerphoneOn, forceSpeakerOutput: false);
    setState(() {});
  }

  void _toggleCamera() async {
    final track = participant.videoTrackPublications.firstOrNull?.track;
    if (track == null) return;

    try {
      final newPosition = position.switched();
      await track.setCameraPosition(newPosition);
      setState(() {
        position = newPosition;
      });
    } catch (error) {
      print('could not restart track: $error');
      return;
    }
  }

  void _toggleExpanded() {
    setState(() {
      _isExpanded = !_isExpanded;
      if (_isExpanded) {
        _animationController.forward();
      } else {
        _animationController.reverse();
      }
    });
  }

  void _unpublishAll() async {
    final result = await context.showUnPublishDialog();
    if (result == true) await participant.unpublishAllTracks();
  }
}
