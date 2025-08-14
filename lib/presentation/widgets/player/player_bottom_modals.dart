import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sonofy/core/extensions/theme_extensions.dart';
import 'package:sonofy/presentation/blocs/settings/settings_cubit.dart';
import 'package:sonofy/presentation/blocs/settings/settings_state.dart';
import 'package:sonofy/presentation/widgets/common/font_awesome/font_awesome_flutter.dart';
import 'package:sonofy/presentation/widgets/player/lirycs_modal.dart';
import 'package:sonofy/presentation/widgets/player/playlist_modal.dart';

class PlayerBottomModals extends StatelessWidget {
  const PlayerBottomModals({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SettingsCubit, SettingsState>(
      builder: (context, state) {
        final primaryColor = state.settings.primaryColor;

        Widget bottomButton({
          required String label,
          required VoidCallback onTap,
        }) {
          return Expanded(
            child: GestureDetector(
              onTap: onTap,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      FontAwesomeIcons.lightChevronUp,
                      color: primaryColor,
                      size: 12,
                    ),
                    Text(
                      label,
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: context.scaleText(12)),
                    ),
                  ],
                ),
              ),
            ),
          );
        }

        return Hero(
          tag: 'lyrics_container',
          child: SizedBox(
            width: double.infinity,
            child: ClipRRect(
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(100.0),
              ),
              child: Material(
                color: Theme.of(context).cardColor,
                child: SafeArea(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      bottomButton(
                        label: context.tr('player.lyrics'),
                        onTap: () => LyricsModal.show(context),
                      ),
                      bottomButton(
                        label: context.tr('player.playlist'),
                        onTap: () => PlaylistModal.show(context),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
