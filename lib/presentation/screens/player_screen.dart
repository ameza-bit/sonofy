import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sonofy/core/extensions/color_extensions.dart';
import 'package:sonofy/core/extensions/theme_extensions.dart';
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
          appBar: AppBar(
            title: Text(
              context.tr('player.now_playing'),
              style: TextStyle(
                color: context.musicWhite,
                fontSize: context.scaleText(20),
                fontWeight: FontWeight.bold,
              ),
            ),
            centerTitle: true,
            backgroundColor: primaryColor,
            elevation: 0,
            leading: IconButton(
              icon: Icon(
                FontAwesomeIcons.solidArrowLeft,
                color: context.musicWhite,
                size: 20,
              ),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ),

          bottomNavigationBar: SizedBox(
            width: double.infinity,
            child: ClipRRect(
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(100.0),
              ),
              child: Material(
                color: context.musicWhite,
                child: SafeArea(
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
                          context.tr('player.lyrics'),
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: context.musicMediumGrey,
                            fontSize: context.scaleText(12),
                          ),
                        ),
                      ],
                    ),
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
