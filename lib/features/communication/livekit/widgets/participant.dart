import 'package:collection/collection.dart';
import 'package:edu_app/core/theme/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:livekit_client/livekit_client.dart';

import 'no_video.dart';
import 'participant_info.dart';

abstract class ParticipantWidget extends StatefulWidget {
  
  static ParticipantWidget widgetFor(
    ParticipantTrack participantTrack, {
    bool showStatsLayer = false,
    bool videoCall = true,
  }) {
    if (participantTrack.participant is LocalParticipant) {
      return LocalParticipantWidget(
        participantTrack.participant as LocalParticipant,
        participantTrack.type,
        showStatsLayer,
        videoCall: videoCall,
      );
    } else if (participantTrack.participant is RemoteParticipant) {
      return RemoteParticipantWidget(
        participantTrack.participant as RemoteParticipant,
        participantTrack.type,
        showStatsLayer,
        videoCall: videoCall,
      );
    }
    throw UnimplementedError('Unknown participant type');
  }

  
  abstract final Participant participant;
  abstract final ParticipantTrackType type;
  abstract final bool showStatsLayer;
  final VideoQuality quality;
  final bool videoCall;

  const ParticipantWidget({
    this.quality = VideoQuality.MEDIUM,
    this.videoCall = true,
    super.key,
  });
}

class LocalParticipantWidget extends ParticipantWidget {
  @override
  final LocalParticipant participant;
  @override
  final ParticipantTrackType type;
  @override
  final bool showStatsLayer;

  const LocalParticipantWidget(
    this.participant,
    this.type,
    this.showStatsLayer, {
    super.key,
    super.videoCall = true,
  });

  @override
  State<StatefulWidget> createState() => _LocalParticipantWidgetState();
}

class RemoteParticipantWidget extends ParticipantWidget {
  @override
  final RemoteParticipant participant;
  @override
  final ParticipantTrackType type;
  @override
  final bool showStatsLayer;

  const RemoteParticipantWidget(
    this.participant,
    this.type,
    this.showStatsLayer, {
    super.key,
    super.videoCall = true,
  });

  @override
  State<StatefulWidget> createState() => _RemoteParticipantWidgetState();
}

abstract class _ParticipantWidgetState<T extends ParticipantWidget>
    extends State<T> {
  bool _visible = true;
  VideoTrack? get activeVideoTrack;
  AudioTrack? get activeAudioTrack;
  TrackPublication? get videoPublication;
  TrackPublication? get audioPublication;
  bool get isScreenShare => widget.type == ParticipantTrackType.kScreenShare;
  EventsListener<ParticipantEvent>? _listener;

  @override
  void initState() {
    super.initState();
    _listener = widget.participant.createListener();
    _listener?.on<TranscriptionEvent>((e) {
      for (var seg in e.segments) {
        print('Transcription: ${seg.text} ${seg.isFinal}');
      }
    });

    widget.participant.addListener(_onParticipantChanged);
    _onParticipantChanged();
  }

  @override
  void dispose() {
    widget.participant.removeListener(_onParticipantChanged);
    _listener?.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant T oldWidget) {
    oldWidget.participant.removeListener(_onParticipantChanged);
    widget.participant.addListener(_onParticipantChanged);
    _onParticipantChanged();
    super.didUpdateWidget(oldWidget);
  }

  
  
  void _onParticipantChanged() => setState(() {});

  
  List<Widget> extraWidgets(bool isScreenShare) => [];

  @override
  Widget build(BuildContext ctx) => Container(
    foregroundDecoration: BoxDecoration(
      border:
          widget.participant.isSpeaking && !isScreenShare
              ? Border.all(width: 5, color: AppTheme.seedColor)
              : null,
    ),
    decoration: BoxDecoration(color: Theme.of(ctx).cardColor),
    child: Stack(
      children: [
        
        InkWell(
          onTap: () => setState(() => _visible = !_visible),
          child:
              _shouldShowVideo()
                  ? VideoTrackRenderer(
                    renderMode: VideoRenderMode.auto,
                    activeVideoTrack!,
                    fit: RTCVideoViewObjectFit.RTCVideoViewObjectFitContain,
                  )
                  : const NoVideoWidget(),
        ),
        
        Align(
          alignment: Alignment.bottomCenter,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: [
              ...extraWidgets(isScreenShare),
              ParticipantInfoWidget(
                title:
                    widget.participant.name.isNotEmpty
                        ? '${widget.participant.name} (${widget.participant.identity})'
                        : widget.participant.identity,
                audioAvailable:
                    audioPublication?.muted == false &&
                    audioPublication?.subscribed == true,
                connectionQuality: widget.participant.connectionQuality,
                isScreenShare: isScreenShare,
                enabledE2EE: widget.participant.isEncrypted,
              ),
            ],
          ),
        ),
      ],
    ),
  );

  
  bool _shouldShowVideo() {
    
    if (isScreenShare) {
      return activeVideoTrack != null && !activeVideoTrack!.muted;
    }

    
    return widget.videoCall &&
        activeVideoTrack != null &&
        !activeVideoTrack!.muted;
  }
}

class _LocalParticipantWidgetState
    extends _ParticipantWidgetState<LocalParticipantWidget> {
  @override
  LocalTrackPublication<LocalVideoTrack>? get videoPublication =>
      widget.participant.videoTrackPublications
          .where((element) => element.source == widget.type.lkVideoSourceType)
          .firstOrNull;

  @override
  LocalTrackPublication<LocalAudioTrack>? get audioPublication =>
      widget.participant.audioTrackPublications
          .where((element) => element.source == widget.type.lkAudioSourceType)
          .firstOrNull;

  @override
  VideoTrack? get activeVideoTrack => videoPublication?.track;

  @override
  AudioTrack? get activeAudioTrack => audioPublication?.track;
}

class _RemoteParticipantWidgetState
    extends _ParticipantWidgetState<RemoteParticipantWidget> {
  @override
  RemoteTrackPublication<RemoteVideoTrack>? get videoPublication =>
      widget.participant.videoTrackPublications
          .where((element) => element.source == widget.type.lkVideoSourceType)
          .firstOrNull;

  @override
  RemoteTrackPublication<RemoteAudioTrack>? get audioPublication =>
      widget.participant.audioTrackPublications
          .where((element) => element.source == widget.type.lkAudioSourceType)
          .firstOrNull;

  @override
  VideoTrack? get activeVideoTrack => videoPublication?.track;

  @override
  AudioTrack? get activeAudioTrack => audioPublication?.track;

  @override
  List<Widget> extraWidgets(bool isScreenShare) => [];
}
