import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:sonofy/core/constants/app_constants.dart';
import 'package:sonofy/core/extensions/theme_extensions.dart';
import 'package:sonofy/presentation/views/modal_view.dart';

class LyricsModal extends StatelessWidget {
  const LyricsModal({super.key});

  static void show(BuildContext context) {
    modalView(
      context,
      title: context.tr('player.lyrics'),
      maxHeight: 0.85,
      showPlayer: true,
      children: [const LyricsModal()],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Expanded(
            child: ListView(
              children: [
                for (int i = 0; i < 10; i++) ...[
                  ListTile(
                    title: Text(
                      'Lyric $i',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: context.scaleText(16)),
                    ),
                    onTap: () {
                      // Handle lyric tap
                    },
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.bottomSheetHeight),
        ],
      ),
    );
  }
}
