import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sonofy/core/extensions/color_extensions.dart';
import 'package:sonofy/core/themes/music_colors.dart';
import 'package:sonofy/presentation/blocs/settings/settings_cubit.dart';
import 'package:sonofy/presentation/blocs/settings/settings_state.dart';
import 'package:sonofy/presentation/views/settings/color_picker_dialog.dart';
import 'package:sonofy/presentation/widgets/common/font_awesome/font_awesome_flutter.dart';
import 'package:sonofy/presentation/widgets/common/section_card.dart';
import 'package:sonofy/presentation/widgets/common/section_item.dart';

class AppearanceSection extends StatefulWidget {
  const AppearanceSection({super.key});

  @override
  State<AppearanceSection> createState() => _AppearanceSectionState();
}

class _AppearanceSectionState extends State<AppearanceSection> {
  late double _currentFontSize;

  void _showColorPicker(
    BuildContext context,
    Color selectedColor,
    List<Color> availableColors,
  ) {
    showDialog(
      context: context,
      builder: (context) => ColorPickerDialog(
        colors: availableColors,
        selectedColor: selectedColor,
        onColorSelected: context.read<SettingsCubit>().updatePrimaryColor,
      ),
    );
  }

  String _getFontSizeLabel(BuildContext context, double fontSize) {
    if (fontSize <= 0.8) return context.tr('settings.font_size_small');
    if (fontSize <= 0.9) return context.tr('settings.font_size_medium_small');
    if (fontSize <= 1.1) return context.tr('settings.font_size_medium');
    if (fontSize <= 1.2) return context.tr('settings.font_size_medium_large');
    return context.tr('settings.font_size_large');
  }

  @override
  void initState() {
    super.initState();
    // Initialize the slider to the saved font size
    _currentFontSize = context.read<SettingsCubit>().state.settings.fontSize;
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SettingsCubit, SettingsState>(
      builder: (context, state) {
        final primaryColor = state.settings.primaryColor;

        // Usar la paleta de colores predefinida de MusicColors
        const availableColors = MusicColors.availableColors;

        return SectionCard(
          title: context.tr('settings.appearance'),
          children: [
            SectionItem(
              icon: FontAwesomeIcons.lightMoonStars,
              title: context.tr('settings.dark_mode'),
              iconColor: primaryColor,
              trailing: DropdownButton<ThemeMode>(
                value: state.settings.themeMode,
                icon: const Icon(Icons.arrow_drop_down),
                elevation: 16,
                style: TextStyle(color: context.textPrimary, fontSize: 16),
                underline: Container(height: 2, color: primaryColor),
                onChanged: (ThemeMode? value) {
                  if (value != null) {
                    context.read<SettingsCubit>().updateIsDarkMode(value);
                  }
                },
                items: ThemeMode.values.map<DropdownMenuItem<ThemeMode>>((
                  value,
                ) {
                  return DropdownMenuItem<ThemeMode>(
                    value: value,
                    child: Text(context.tr('app.theme.${value.name}')),
                  );
                }).toList(),
              ),
            ),
            SectionItem(
              icon: FontAwesomeIcons.lightPalette,
              title: context.tr('settings.primary_color'),
              iconColor: primaryColor,
              trailing: GestureDetector(
                onTap: () =>
                    _showColorPicker(context, primaryColor, availableColors),
                child: Container(
                  width: 30,
                  height: 30,
                  decoration: BoxDecoration(
                    color: primaryColor,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                ),
              ),
            ),
            SectionItem(
              icon: FontAwesomeIcons.lightTextSize,
              title: context.tr('settings.font_size'),
              iconColor: primaryColor,
              trailing: SizedBox(
                width: 150,
                child: Slider(
                  value: _currentFontSize,
                  min: 0.8,
                  max: 1.2,
                  divisions: 4,
                  label: _getFontSizeLabel(context, _currentFontSize),
                  activeColor: primaryColor,
                  onChanged: (value) =>
                      setState(() => _currentFontSize = value),
                  onChangeEnd: context.read<SettingsCubit>().updateFontSize,
                ),
              ),
            ),
            SectionItem(
              icon: FontAwesomeIcons.lightTextSize,
              title: context.tr('settings.hide_controls'),
              iconColor: primaryColor,
              trailing: Switch(
                value: state.settings.hideControls,
                activeColor: primaryColor,
                onChanged: context.read<SettingsCubit>().updateHideControls,
              ),
            ),
          ],
        );
      },
    );
  }
}
