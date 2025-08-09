import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:samva/presentation/blocs/settings/settings_cubit.dart';
import 'package:samva/presentation/blocs/settings/settings_state.dart';
import 'package:samva/presentation/widgets/common/font_awesome/font_awesome_flutter.dart';
import 'package:samva/presentation/widgets/common/section_card.dart';
import 'package:samva/presentation/widgets/common/section_item.dart';

class SecuritySection extends StatelessWidget {
  const SecuritySection({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SettingsCubit, SettingsState>(
      builder: (context, state) {
        final primaryColor = state.settings.primaryColor;

        return SectionCard(
          title: context.tr('settings.security'),
          children: [
            SectionItem(
              icon: FontAwesomeIcons.lightFingerprint,
              title: context.tr('settings.biometric_auth'),
              subtitle: context.tr('settings.biometric_auth_desc'),
              iconColor: primaryColor,
              trailing: Switch(
                value: state.settings.biometricEnabled,
                activeColor: primaryColor,
                onChanged: context.read<SettingsCubit>().updateBiometricEnabled,
              ),
            ),
          ],
        );
      },
    );
  }
}
