import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sonofy/core/enums/equalizer_preset.dart';
import 'package:sonofy/core/extensions/color_extensions.dart';
import 'package:sonofy/core/extensions/theme_extensions.dart';
import 'package:sonofy/presentation/blocs/equalizer/equalizer_cubit.dart';
import 'package:sonofy/presentation/blocs/equalizer/equalizer_state.dart';
import 'package:sonofy/presentation/blocs/settings/settings_cubit.dart';
import 'package:sonofy/presentation/blocs/settings/settings_state.dart';

class EqualizerPresets extends StatelessWidget {
  const EqualizerPresets({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SettingsCubit, SettingsState>(
      builder: (context, settingsState) {
        final primaryColor = settingsState.settings.primaryColor;

        return BlocBuilder<EqualizerCubit, EqualizerState>(
          builder: (context, equalizerState) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  child: Text(
                    'Presets',
                    style: TextStyle(
                      fontSize: context.scaleText(16),
                      fontWeight: FontWeight.w600,
                      color: context.textPrimary,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                SizedBox(
                  height: 50,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount:
                        EqualizerPreset.values.length - 1, // Excluir 'custom'
                    itemBuilder: (context, index) {
                      final preset = EqualizerPreset.values[index];
                      final isSelected = equalizerState.currentPreset == preset;

                      return Padding(
                        padding: const EdgeInsets.only(right: 12),
                        child: _buildPresetChip(
                          context,
                          preset,
                          isSelected,
                          primaryColor,
                        ),
                      );
                    },
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildPresetChip(
    BuildContext context,
    EqualizerPreset preset,
    bool isSelected,
    Color primaryColor,
  ) {
    return Material(
      color: isSelected ? primaryColor : Colors.transparent,
      borderRadius: BorderRadius.circular(25),
      child: InkWell(
        borderRadius: BorderRadius.circular(25),
        onTap: () {
          context.read<EqualizerCubit>().setPreset(preset);
        },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(25),
            border: Border.all(
              color: isSelected
                  ? primaryColor
                  : primaryColor.withValues(alpha: 0.3),
              width: 2,
            ),
          ),
          child: Text(
            preset.displayName,
            style: TextStyle(
              fontSize: context.scaleText(14),
              fontWeight: FontWeight.w500,
              color: isSelected ? Colors.white : context.textPrimary,
            ),
          ),
        ),
      ),
    );
  }
}
