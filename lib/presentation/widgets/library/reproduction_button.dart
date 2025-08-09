import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sonofy/core/extensions/color_extensions.dart';
import 'package:sonofy/core/themes/gradient_helpers.dart';
import 'package:sonofy/presentation/blocs/settings/settings_cubit.dart';
import 'package:sonofy/presentation/blocs/settings/settings_state.dart';
import 'package:sonofy/presentation/widgets/common/font_awesome/font_awesome_flutter.dart';

class ReproductionButton extends StatefulWidget {
  const ReproductionButton({super.key});

  @override
  State<ReproductionButton> createState() => _ReproductionButtonState();
}

class _ReproductionButtonState extends State<ReproductionButton> {
  bool _isPlaying = false;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SettingsCubit, SettingsState>(
      builder: (context, state) {
        final primaryColor = state.settings.primaryColor;

        return CircularGradientButton(
          size: 48,
          elevation: 1,
          primaryColor: _isPlaying ? primaryColor : context.musicWhite,
          onPressed: () {
            setState(() {
              _isPlaying = !_isPlaying;
            });
          },
          child: Icon(
            _isPlaying
                ? FontAwesomeIcons.solidPause
                : FontAwesomeIcons.solidPlay,
            color: _isPlaying ? context.musicWhite : primaryColor,
            size: 24,
          ),
        );
      },
    );
  }
}
