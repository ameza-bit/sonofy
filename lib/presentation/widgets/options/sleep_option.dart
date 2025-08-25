import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:sonofy/main.dart';
import 'package:sonofy/presentation/blocs/player/player_cubit.dart';
import 'package:sonofy/presentation/blocs/player/player_state.dart';
import 'package:sonofy/presentation/widgets/common/font_awesome/font_awesome_flutter.dart';
import 'package:sonofy/presentation/widgets/common/section_item.dart';
import 'package:sonofy/presentation/widgets/player/sleep_modal.dart';

class SleepOption extends StatelessWidget {
  const SleepOption({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PlayerCubit, PlayerState>(
      builder: (context, state) {
        return SectionItem(
          icon: state.isSleepTimerActive
              ? FontAwesomeIcons.solidAlarmSnooze
              : FontAwesomeIcons.lightAlarmSnooze,
          title: context.tr('options.sleep'),
          onTap: () {
            context.pop();
            SleepModal.show(navigatorKey.currentContext ?? context);
          },
        );
      },
    );
  }
}
