import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:on_audio_query_pluse/on_audio_query.dart';
import 'package:sonofy/core/extensions/color_extensions.dart';
import 'package:sonofy/core/extensions/theme_extensions.dart';
import 'package:sonofy/core/themes/gradient_helpers.dart';
import 'package:sonofy/core/utils/duration_minutes.dart';
import 'package:sonofy/presentation/blocs/settings/settings_cubit.dart';
import 'package:sonofy/presentation/blocs/settings/settings_state.dart';
import 'package:sonofy/presentation/widgets/common/font_awesome/font_awesome_flutter.dart';

class SongCard extends StatefulWidget {
  const SongCard({required this.song, super.key});
  final SongModel song;

  @override
  State<SongCard> createState() => _SongCardState();
}

class _SongCardState extends State<SongCard> {
  bool _isPlaying = false;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SettingsCubit, SettingsState>(
      builder: (context, state) {
        final primaryColor = state.settings.primaryColor;

        return Card(
          margin: const EdgeInsets.symmetric(vertical: 4.0),
          child: InkWell(
            onTap: () => setState(() => _isPlaying = !_isPlaying),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                spacing: 12,
                children: [
                  CircularGradientButton(
                    size: 48,
                    elevation: 1,
                    primaryColor: _isPlaying
                        ? primaryColor
                        : context.musicWhite,
                    onPressed: () => setState(() => _isPlaying = !_isPlaying),
                    child: Icon(
                      _isPlaying
                          ? FontAwesomeIcons.solidPause
                          : FontAwesomeIcons.solidPlay,
                      color: _isPlaying ? context.musicWhite : primaryColor,
                      size: 20,
                    ),
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      spacing: 4,
                      children: [
                        Text(
                          widget.song.title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: context.scaleText(16),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          widget.song.artist ??
                              widget.song.composer ??
                              'Desconocido',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: context.scaleText(12),
                            color: context.musicLightGrey,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    DurationMinutes.format(widget.song.duration ?? 0),
                    style: TextStyle(
                      fontSize: context.scaleText(12),
                      color: context.musicLightGrey,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
