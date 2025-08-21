import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:on_audio_query_pluse/on_audio_query.dart';
import 'package:sonofy/core/utils/duration_minutes.dart';
import 'package:sonofy/presentation/views/modal_view.dart';
import 'package:sonofy/presentation/widgets/common/font_awesome/font_awesome_flutter.dart';
import 'package:sonofy/presentation/widgets/common/section_card.dart';
import 'package:sonofy/presentation/widgets/common/section_item.dart';

class SongInfoOption extends StatelessWidget {
  const SongInfoOption({
    required this.song,
    super.key,
  });

  final SongModel song;

  @override
  Widget build(BuildContext context) {
    return SectionItem(
      icon: FontAwesomeIcons.lightCircleInfo,
      title: context.tr('options.song_info'),
      onTap: () {
        context.pop();
        _showSongInfo(context);
      },
    );
  }

  void _showSongInfo(BuildContext context) {
    modalView(
      context,
      title: context.tr('options.song_info'),
      children: [
        SectionCard(
          title: context.tr('song.details'),
          children: [
            _InfoItem(
              label: context.tr('song.title'),
              value: song.title,
            ),
            _InfoItem(
              label: context.tr('song.artist'),
              value: song.artist ?? context.tr('common.unknown'),
            ),
            _InfoItem(
              label: context.tr('song.album'),
              value: song.album ?? context.tr('common.unknown'),
            ),
            _InfoItem(
              label: context.tr('song.duration'),
              value: DurationMinutes.format(song.duration ?? 0),
            ),
            if ((song.genre?.isNotEmpty ?? false))
              _InfoItem(
                label: context.tr('song.genre'),
                value: song.genre!,
              ),
            if ((song.composer?.isNotEmpty ?? false))
              _InfoItem(
                label: context.tr('song.composer'),
                value: song.composer!,
              ),
            _InfoItem(
              label: context.tr('song.file_size'),
              value: _formatFileSize(song.size ?? 0),
            ),
          ],
        ),
      ],
    );
  }

  String _formatFileSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }
}

class _InfoItem extends StatelessWidget {
  const _InfoItem({
    required this.label,
    required this.value,
  });

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.w500,
                color: Colors.grey,
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.normal),
            ),
          ),
        ],
      ),
    );
  }
}