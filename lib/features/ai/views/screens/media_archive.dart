import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:edu_app/features/ai/views/widgets/media_deck_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '/features/ai/cubit/media_cubit.dart';
import '/features/ai/cubit/media_state.dart';
import '/features/ai/data/models/media.dart';
import '/features/ai/data/models/media_deck_data.dart';

class MediaArchiveScreen extends StatelessWidget {
  const MediaArchiveScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Media Archive')),
      body: BlocBuilder<MediaCubit, MediaState>(
        builder: (context, state) {
          if (state is MediaLoadingState) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is MediaGeneratingState) {
            return _buildGeneratingState(state);
          } else if (state is MediaLoadedState) {
            if (state.isEmpty) {
              return _buildEmptyState();
            }
            return _buildMediaList(context, state.allMedia);
          } else if (state is MediaErrorState) {
            return _buildErrorState(state, context);
          } else {
            return _buildInitialState(context);
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => BlocProvider.of<MediaCubit>(context).refreshMedia(),
        tooltip: 'Refresh Media',
        child: const Icon(Icons.refresh),
      ),
    );
  }

  Widget _buildGeneratingState(MediaGeneratingState state) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(value: state.progress),
          const SizedBox(height: 16),
          Text('Generating media for: ${state.prompt}'),
          Text('Progress: ${(state.progress ?? 0.0) * 100 ~/ 1}%'),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return const Center(child: Text('No media items yet.'));
  }

  Widget _buildErrorState(MediaErrorState state, BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 48, color: Colors.red),
          const SizedBox(height: 16),
          Text('Error: ${state.message}'),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed:
                () => BlocProvider.of<MediaCubit>(context).refreshMedia(),
            child: const Text('Try Again'),
          ),
        ],
      ),
    );
  }

  Widget _buildInitialState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text('Waiting for media...'),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed:
                () => BlocProvider.of<MediaCubit>(context).refreshMedia(),
            child: const Text('Load Media'),
          ),
        ],
      ),
    );
  }

  Widget _buildMediaList(BuildContext context, List<Media> mediaItems) {
    return ListView.builder(
      itemCount: mediaItems.length,
      itemBuilder: (context, index) {
        final media = mediaItems[index];
        return MediaCard(media: media);
      },
    );
  }
}

class MediaCard extends StatelessWidget {
  const MediaCard({super.key, required this.media});

  final Media media;

  String _cleanJsonString(String jsonString) {
    if (jsonString.startsWith('```json')) {
      jsonString = jsonString.substring(7);
    } else if (jsonString.startsWith('```')) {
      jsonString = jsonString.substring(3);
    }
    if (jsonString.endsWith('```')) {
      jsonString = jsonString.substring(0, jsonString.length - 3);
    }
    return jsonString.trim();
  }

  static dynamic _decodeJsonInBackground(String jsonString) {
    return jsonDecode(jsonString);
  }

  Future<String> _getMediaTitleFuture(Media media) async {
    String mediaTitle = 'Media Preview';
    try {
      final mediaContent = media.content;
      if (mediaContent != null && mediaContent.isNotEmpty) {
        final cleanedJsonString = _cleanJsonString(mediaContent);
        final jsonData = await compute(
          _decodeJsonInBackground,
          cleanedJsonString,
        );
        final mediaDeck = MediaDeckData.fromJson(jsonData);
        if (mediaDeck.deckTitle?.isNotEmpty == true) {
          mediaTitle = mediaDeck.deckTitle!;
        } else if (mediaDeck.slides.isNotEmpty) {
          mediaTitle = mediaDeck.slides.first.title;
        }
      }
    } catch (e) {
      mediaTitle = 'Error Loading Title';
    }
    return mediaTitle;
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      elevation: 2,
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ),
        title: FutureBuilder<String>(
          future: _getMediaTitleFuture(media),
          builder: (BuildContext context, AsyncSnapshot<String> snapshot) {
            TextStyle titleStyle = const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            );

            if (snapshot.connectionState == ConnectionState.waiting) {
              return Text(
                'Loading Title...',
                style: titleStyle.copyWith(
                  fontStyle: FontStyle.italic,
                  color: Colors.grey,
                ),
              );
            } else if (snapshot.hasError) {
              return Text(
                'Error Loading Title',
                style: titleStyle.copyWith(color: Colors.red),
              );
            } else {
              return Text(snapshot.data ?? 'Media Preview', style: titleStyle);
            }
          },
        ),
        trailing: IconButton(
          icon: const Icon(Icons.delete),
          onPressed:
              () => BlocProvider.of<MediaCubit>(context).deleteMedia(media),
        ),
        onTap: () => _navigateToMediaDeckView(context, media),
      ),
    );
  }

  void _navigateToMediaDeckView(BuildContext context, Media media) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => MediaDeckView(media: media)),
    );
  }
}
