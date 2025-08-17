import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:sonofy/core/constants/app_constants.dart';
import 'package:sonofy/core/extensions/theme_extensions.dart';
import 'package:sonofy/presentation/blocs/songs/songs_cubit.dart';
import 'package:sonofy/presentation/blocs/songs/songs_state.dart';
import 'package:sonofy/presentation/screens/player_screen.dart';
import 'package:sonofy/presentation/widgets/common/font_awesome/font_awesome_flutter.dart';
import 'package:sonofy/presentation/widgets/library/bottom_player.dart';
import 'package:sonofy/presentation/widgets/library/song_card.dart';

class PlaylistScreen extends StatelessWidget {
  static const String routeName = 'playlist';
  const PlaylistScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          context.tr('library.title'),
          style: TextStyle(
            fontSize: context.scaleText(24),
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SafeArea(
        child: BlocBuilder<SongsCubit, SongsState>(
          builder: (context, state) {
            if (state.isLoading) {
              return const Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Expanded(child: Center(child: CircularProgressIndicator())),
                  SizedBox(height: AppSpacing.bottomSheetHeight),
                ],
              );
            } else if (state.songs.isEmpty) {
              return Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Expanded(
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        spacing: 16.0,
                        children: [
                          Icon(
                            FontAwesomeIcons.lightMusic,
                            size: 64,
                            color: Theme.of(context).iconTheme.color,
                          ),
                          Text(
                            context.tr('playlist.empty'),
                            style: TextStyle(fontSize: context.scaleText(18)),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.bottomSheetHeight),
                ],
              );
            }

            return ListView.builder(
              itemCount: state.songs.length + 1,
              itemBuilder: (context, index) {
                if (index == state.songs.length) {
                  // Espacio final
                  return const SizedBox(height: AppSpacing.bottomSheetHeight);
                } else {
                  // Canción
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24.0),
                    child: SongCard(
                      playlist: state.songs,
                      song: state.songs[index],
                      onTap: () => context.pushNamed(PlayerScreen.routeName),
                    ),
                  );
                }
              },
            );
          },
        ),
      ),
      resizeToAvoidBottomInset: false,
      bottomSheet: Stack(
        children: [
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(height: 80, color: Theme.of(context).cardColor),
          ),
          BottomPlayer(onTap: () => context.pushNamed(PlayerScreen.routeName)),
        ],
      ),
    );
  }
}
