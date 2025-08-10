import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sonofy/core/extensions/color_extensions.dart';
import 'package:sonofy/presentation/blocs/settings/settings_cubit.dart';
import 'package:sonofy/presentation/blocs/settings/settings_state.dart';
import 'package:sonofy/presentation/widgets/common/font_awesome/font_awesome_flutter.dart';

class PlayerScreen extends StatelessWidget {
  static const String routeName = 'player';
  const PlayerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SettingsCubit, SettingsState>(
      builder: (context, state) {
        final primaryColor = state.settings.primaryColor;

        return Scaffold(
          bottomSheet: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16.0),
            decoration: BoxDecoration(
              color: context.musicWhite,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(100.0),
              ),
            ),
            child: SafeArea(
              top: false,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(FontAwesomeIcons.lightChevronUp, color: primaryColor),
                  Text(
                    context.tr('player.lyrics'),
                    style: TextStyle(color: context.musicMediumGrey),
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
