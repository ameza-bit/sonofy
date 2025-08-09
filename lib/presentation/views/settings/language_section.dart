import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:samva/core/enums/language.dart';
import 'package:samva/core/extensions/color_extensions.dart';
import 'package:samva/presentation/blocs/settings/settings_cubit.dart';
import 'package:samva/presentation/blocs/settings/settings_state.dart';
import 'package:samva/presentation/widgets/common/font_awesome/font_awesome_flutter.dart';
import 'package:samva/presentation/widgets/common/section_card.dart';
import 'package:samva/presentation/widgets/common/section_item.dart';

class LanguageSection extends StatelessWidget {
  const LanguageSection({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SettingsCubit, SettingsState>(
      builder: (context, state) {
        final primaryColor = state.settings.primaryColor;

        return SectionCard(
          title: context.tr('settings.language'),
          children: [
            SectionItem(
              icon: FontAwesomeIcons.lightGlobe,
              title: context.tr('settings.app_language'),
              iconColor: primaryColor,
              trailing: DropdownButton<Language>(
                value: state.settings.language,
                icon: const Icon(Icons.arrow_drop_down),
                elevation: 16,
                style: TextStyle(color: context.textPrimary, fontSize: 16),
                underline: Container(height: 2, color: primaryColor),
                onChanged: (Language? value) {
                  if (value != null) {
                    context.read<SettingsCubit>().updateLanguage(value);
                    context.setLocale(Locale(value.code));
                  }
                },
                items:
                    Language.values.map<DropdownMenuItem<Language>>((value) {
                      return DropdownMenuItem<Language>(
                        value: value,
                        child: Text('${value.flag} ${value.name}'),
                      );
                    }).toList(),
              ),
            ),
          ],
        );
      },
    );
  }
}
