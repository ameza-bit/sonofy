import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sonofy/core/utils/toast.dart';
import 'package:sonofy/presentation/blocs/settings/settings_cubit.dart';
import 'package:sonofy/presentation/blocs/settings/settings_state.dart';
import 'package:sonofy/presentation/blocs/songs/songs_cubit.dart';
import 'package:sonofy/presentation/widgets/common/font_awesome/font_awesome_flutter.dart';
import 'package:sonofy/presentation/widgets/common/section_card.dart';
import 'package:sonofy/presentation/widgets/common/section_item.dart';

class LocalMusicSection extends StatefulWidget {
  const LocalMusicSection({super.key});

  @override
  State<LocalMusicSection> createState() => _LocalMusicSectionState();
}

class _LocalMusicSectionState extends State<LocalMusicSection> {
  bool _isSelecting = false;

  Future<void> _importMusicFiles() async {
    if (!mounted || _isSelecting) return;

    setState(() => _isSelecting = true);

    try {
      final settingsCubit = context.read<SettingsCubit>();
      final bool success = await settingsCubit.selectAndSetMusicFolder();
      
      if (!mounted) return;
      
      if (success) {
        final mp3Files = await settingsCubit.getMp3FilesFromCurrentFolder();
        if (!mounted) return;
        
        // Actualizar las canciones en SongsCubit
        final songsCubit = context.read<SongsCubit>();
        await songsCubit.refreshLocalSongs();
        
        if (!mounted) return;
        Toast.show(context.tr('settings.music_import_success', namedArgs: {
          'count': mp3Files.length.toString()
        }));
      } else {
        if (!mounted) return;
        Toast.show(context.tr('settings.music_import_no_files'));
      }
    } catch (e) {
      if (!mounted) return;
      Toast.show(context.tr('settings.music_import_error'));
    } finally {
      if (mounted) {
        setState(() => _isSelecting = false);
      }
    }
  }

  String _getImportStatus(String? status) {
    if (status == null || status.isEmpty) {
      return context.tr('settings.music_sync_empty');
    }

    final folderName = status.split('/').last;
    return context.tr('settings.music_folder_selected', namedArgs: {
      'folder': folderName
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SettingsCubit, SettingsState>(
      builder: (context, state) {
        final primaryColor = state.settings.primaryColor;
        final localMusicPath = state.settings.localMusicPath;

        return SectionCard(
          title: context.tr('settings.music_library'),
          children: [
            SectionItem(
              icon: FontAwesomeIcons.lightDownload,
              title: context.tr('settings.import_music_files'),
              subtitle: context.tr('settings.import_music_description'),
              iconColor: primaryColor,
              trailing: _isSelecting
                  ? SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(primaryColor),
                      ),
                    )
                  : null,
              onTap: !_isSelecting ? _importMusicFiles : null,
            ),
            SectionItem(
              icon: FontAwesomeIcons.lightMusic,
              title: context.tr('settings.import_status'),
              subtitle: _getImportStatus(localMusicPath),
              iconColor: primaryColor,
            ),
          ],
        );
      },
    );
  }
}
