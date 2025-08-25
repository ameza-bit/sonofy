import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:sonofy/core/extensions/color_extensions.dart';
import 'package:sonofy/core/extensions/theme_extensions.dart';
import 'package:sonofy/presentation/blocs/equalizer/equalizer_cubit.dart';
import 'package:sonofy/presentation/blocs/equalizer/equalizer_state.dart';
import 'package:sonofy/presentation/blocs/settings/settings_cubit.dart';
import 'package:sonofy/presentation/blocs/settings/settings_state.dart';
import 'package:sonofy/presentation/widgets/common/font_awesome/font_awesome_flutter.dart';
import 'package:sonofy/presentation/widgets/equalizer/equalizer_presets.dart';
import 'package:sonofy/presentation/widgets/equalizer/equalizer_slider.dart';

class EqualizerScreen extends StatelessWidget {
  static const String routeName = 'equalizer';

  const EqualizerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SettingsCubit, SettingsState>(
      builder: (context, settingsState) {
        final primaryColor = settingsState.settings.primaryColor;

        return Scaffold(
          appBar: AppBar(
            title: Text(context.tr('equalizer.title')),
            leading: IconButton(
              icon: const Icon(FontAwesomeIcons.lightChevronLeft),
              onPressed: () => context.pop(),
            ),
          ),
          body: SafeArea(
            child: BlocBuilder<EqualizerCubit, EqualizerState>(
              builder: (context, equalizerState) {
                if (equalizerState.isLoading) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (equalizerState.error != null) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          FontAwesomeIcons.lightTriangleExclamation,
                          size: 48,
                          color: Colors.red,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          context.tr('common.error'),
                          style: TextStyle(
                            fontSize: context.scaleText(18),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          equalizerState.error!,
                          style: TextStyle(
                            fontSize: context.scaleText(14),
                            color: context.musicMediumGrey,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: () {
                            context.read<EqualizerCubit>().refreshSettings();
                          },
                          child: Text(context.tr('common.retry')),
                        ),
                      ],
                    ),
                  );
                }

                return Column(
                  children: [
                    // Switch de activación y descripción
                    Container(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Icon(
                                FontAwesomeIcons.lightSlidersUp,
                                color: equalizerState.isEnabled
                                    ? primaryColor
                                    : context.musicMediumGrey,
                                size: 20,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      context.tr('equalizer.title'),
                                      style: TextStyle(
                                        fontSize: context.scaleText(16),
                                        fontWeight: FontWeight.w600,
                                        color: context.textPrimary,
                                      ),
                                    ),
                                    Text(
                                      equalizerState.isEnabled
                                          ? context.tr(
                                              'equalizer.enabled_description',
                                            )
                                          : context.tr(
                                              'equalizer.disabled_description',
                                            ),
                                      style: TextStyle(
                                        fontSize: context.scaleText(12),
                                        color: context.musicMediumGrey,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              BlocBuilder<EqualizerCubit, EqualizerState>(
                                builder: (context, equalizerState) {
                                  return Switch(
                                    value: equalizerState.isEnabled,
                                    activeColor: primaryColor,
                                    onChanged: (enabled) {
                                      context.read<EqualizerCubit>().setEnabled(
                                        enabled,
                                      );
                                    },
                                  );
                                },
                              ),
                            ],
                          ),
                          if (equalizerState.isCustom) ...[
                            const SizedBox(height: 16),
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: primaryColor.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: primaryColor.withValues(alpha: 0.3),
                                ),
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    FontAwesomeIcons.lightWrench,
                                    color: primaryColor,
                                    size: 16,
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      context.tr('equalizer.custom_mode'),
                                      style: TextStyle(
                                        fontSize: context.scaleText(12),
                                        color: primaryColor,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),

                    // Presets
                    const EqualizerPresets(),

                    const SizedBox(height: 24),

                    // Sliders del ecualizador
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 32),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            for (
                              int i = 0;
                              i < equalizerState.bands.length;
                              i++
                            ) ...[
                              EqualizerSlider(
                                bandIndex: i,
                                bandName: equalizerState.getBandName(i),
                                frequency: equalizerState.getBandFrequency(i),
                                value: equalizerState.getBandGain(i),
                              ),
                              if (i < equalizerState.bands.length - 1)
                                const SizedBox(width: 24),
                            ],
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Botón de acción
                    SafeArea(
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        child: Center(
                          child: OutlinedButton.icon(
                            onPressed: () {
                              context.read<EqualizerCubit>().resetToFlat();
                            },
                            icon: const Icon(FontAwesomeIcons.lightRotateLeft),
                            label: Text(context.tr('equalizer.reset')),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: primaryColor,
                              side: BorderSide(color: primaryColor),
                              padding: const EdgeInsets.symmetric(
                                vertical: 12,
                                horizontal: 32,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        );
      },
    );
  }
}
