import 'package:audio_metadata_reader/audio_metadata_reader.dart';
import 'package:flutter/material.dart';
import 'package:on_audio_query_pluse/on_audio_query.dart';

class PlaylistCoverGrid extends StatelessWidget {
  const PlaylistCoverGrid(
    this.songs, {
    required this.width,
    required this.height,
    this.radius = 0.0,
    super.key,
  });

  final List<SongModel> songs;
  final double width;
  final double height;
  final double radius;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(radius),
        border: Border.all(width: 0),
        image: songs.isEmpty
            ? const DecorationImage(
                image: AssetImage('assets/images/placeholder.png'),
                fit: BoxFit.cover,
              )
            : null,
      ),
      child: songs.length <= 1
          ? _buildSingleCover()
          : ClipRRect(
              borderRadius: BorderRadius.circular(radius),
              child: Wrap(
                children: songs
                    .take(4)
                    .map(
                      (song) => PlaylistCoverGrid(
                        [song],
                        width:
                            (songs.length > 1 &&
                                (songs.indexOf(song) != 2 || songs.length > 3))
                            ? width / 2
                            : width,
                        height: songs.length > 2 ? height / 2 : height,
                      ),
                    )
                    .toList(),
              ),
            ),
    );
  }

  Widget? _buildSingleCover() {
    if (songs.isEmpty) return null;

    ImageProvider emptyImage = const AssetImage(
      'assets/images/placeholder.png',
    );

    final currentSongInfo = songs.first.getMap;
    if (currentSongInfo.containsKey('artwork') &&
        currentSongInfo['artwork'] is Picture) {
      final Picture artworkData = currentSongInfo['artwork'];
      emptyImage = MemoryImage(artworkData.bytes);
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(radius),
      child: QueryArtworkWidget(
        id: songs.first.id,
        type: ArtworkType.AUDIO,
        artworkBorder: BorderRadius.zero,
        nullArtworkWidget: DecoratedBox(
          decoration: BoxDecoration(
            image: DecorationImage(image: emptyImage, fit: BoxFit.cover),
          ),
        ),
      ),
    );
  }
}
