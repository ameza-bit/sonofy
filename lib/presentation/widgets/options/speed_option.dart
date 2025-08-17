import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:sonofy/core/utils/toast.dart';
import 'package:sonofy/presentation/blocs/player/player_cubit.dart';
import 'package:sonofy/presentation/views/modal_view.dart';
import 'package:sonofy/presentation/widgets/common/font_awesome/font_awesome_flutter.dart';
import 'package:sonofy/presentation/widgets/common/section_item.dart';

class SpeedOption extends StatelessWidget {
  const SpeedOption({super.key});

  @override
  Widget build(BuildContext context) {
    return SectionItem(
      icon: FontAwesomeIcons.lightGauge,
      title: context.tr('options.player_speed'),
      onTap: () {
        context.pop();
        _showSpeedSelector(context);
      },
    );
  }

  void _showSpeedSelector(BuildContext context) {
    final playerState = context.read<PlayerCubit>().state;
    if (!playerState.hasSelectedSong) {
      Toast.show(context.tr('player.no_song_selected'));
      return;
    }

    modalView(
      context,
      title: context.tr('options.player_speed'),
      maxHeight: 0.5,
      children: [const SpeedSelectorForm()],
    );
  }
}

class SpeedSelectorForm extends StatelessWidget {
  const SpeedSelectorForm({super.key});

  @override
  Widget build(BuildContext context) {
    const speedOptions = [0.5, 0.75, 1.0, 1.25, 1.5, 1.75, 2.0];
    
    return Expanded(
      child: ListView.builder(
        itemCount: speedOptions.length,
        itemBuilder: (context, index) {
          final speed = speedOptions[index];
          final isNormalSpeed = speed == 1.0;
          
          return ListTile(
            title: Text(
              isNormalSpeed 
                ? context.tr('player.speed_normal', namedArgs: {'speed': '${speed}x'})
                : '${speed}x',
              style: TextStyle(
                fontWeight: isNormalSpeed ? FontWeight.bold : FontWeight.normal,
              ),
            ),
            trailing: isNormalSpeed 
                ? const Icon(FontAwesomeIcons.lightCheck)
                : null,
            onTap: () {
              context.pop();
              // Note: This would require audio player integration
              Toast.show(context.tr('player.speed_changed', namedArgs: {'speed': '${speed}x'}));
            },
          );
        },
      ),
    );
  }
}
