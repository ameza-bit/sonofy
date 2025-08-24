import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sonofy/core/enums/equalizer_preset.dart';
import 'package:sonofy/presentation/blocs/equalizer/equalizer_cubit.dart';
import 'package:sonofy/presentation/blocs/equalizer/equalizer_state.dart';
import 'package:sonofy/presentation/blocs/player/player_cubit.dart';
import 'package:sonofy/presentation/widgets/equalizer/equalizer_band_slider.dart';
import 'package:sonofy/presentation/widgets/equalizer/preset_selector.dart';

class EqualizerModal extends StatefulWidget {
  const EqualizerModal({super.key});

  @override
  State<EqualizerModal> createState() => _EqualizerModalState();
}

class _EqualizerModalState extends State<EqualizerModal> {
  @override
  void initState() {
    super.initState();
    final equalizerCubit = context.read<EqualizerCubit>();
    final playerCubit = context.read<PlayerCubit>();
    
    // Configurar sincronización con el reproductor
    equalizerCubit.setPlayerSync(playerCubit.syncEqualizer);
    
    // Cargar configuración guardada del ecualizador
    equalizerCubit.loadEqualizerSettings().then((_) {
      // Sincronizar configuración inicial con el reproductor
      final state = equalizerCubit.state;
      if (state.equalizer.isEnabled) {
        playerCubit.syncEqualizer(
          state.equalizer.isEnabled,
          state.equalizer.currentValues,
          state.equalizer.preamp,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return BlocListener<EqualizerCubit, EqualizerState>(
      listener: (context, state) {
        if (state.errorMessage != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(context.tr(state.errorMessage!)),
              backgroundColor: Colors.red,
              action: SnackBarAction(
                label: context.tr('common.close'),
                textColor: Colors.white,
                onPressed: () {
                  context.read<EqualizerCubit>().clearError();
                },
              ),
            ),
          );
        }
      },
      child: Container(
        height: MediaQuery.of(context).size.height * 0.8,
        decoration: BoxDecoration(
          color: theme.scaffoldBackgroundColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: BlocBuilder<EqualizerCubit, EqualizerState>(
          builder: (context, state) {
            if (state.isLoading) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }

            return Column(
              children: [
                _buildHeader(context),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        _buildEnableSwitch(context, state),
                        const SizedBox(height: 20),
                        _buildPresetSelector(context, state),
                        const SizedBox(height: 20),
                        _buildPreamp(context, state),
                        const SizedBox(height: 20),
                        _buildEqualizer(context, state),
                        const SizedBox(height: 20),
                        _buildResetButton(context),
                      ],
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    final theme = Theme.of(context);
    
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: theme.primaryColor.withValues(alpha: 0.1),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Row(
        children: [
          Icon(
            Icons.equalizer,
            color: theme.primaryColor,
            size: 28,
          ),
          const SizedBox(width: 12),
          Text(
            context.tr('player.equalizer.title'),
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: theme.primaryColor,
            ),
          ),
          const Spacer(),
          IconButton(
            onPressed: () => Navigator.of(context).pop(),
            icon: const Icon(Icons.close),
          ),
        ],
      ),
    );
  }

  Widget _buildEnableSwitch(BuildContext context, EqualizerState state) {
    final theme = Theme.of(context);
    
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Icon(
              Icons.power_settings_new,
              color: theme.primaryColor,
            ),
            const SizedBox(width: 12),
            Text(
              context.tr('player.equalizer.enabled'),
              style: theme.textTheme.titleMedium,
            ),
            const Spacer(),
            Switch(
              value: state.equalizer.isEnabled,
              onChanged: (value) {
                HapticFeedback.selectionClick();
                context.read<EqualizerCubit>().setEqualizerEnabled(value);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPresetSelector(BuildContext context, EqualizerState state) {
    if (!state.equalizer.isEnabled) return const SizedBox.shrink();
    
    return PresetSelector(
      currentPreset: state.equalizer.currentPreset,
      onPresetChanged: (preset) {
        context.read<EqualizerCubit>().setPreset(preset);
      },
    );
  }

  Widget _buildPreamp(BuildContext context, EqualizerState state) {
    if (!state.equalizer.isEnabled) return const SizedBox.shrink();
    
    final theme = Theme.of(context);
    
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.volume_up,
                  color: theme.primaryColor,
                ),
                const SizedBox(width: 8),
                Text(
                  context.tr('player.equalizer.preamp'),
                  style: theme.textTheme.titleMedium,
                ),
                const Spacer(),
                Text(
                  '${state.equalizer.preamp.toStringAsFixed(1)} dB',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.primaryColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            SliderTheme(
              data: SliderTheme.of(context).copyWith(
                trackHeight: 4,
                thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 8),
              ),
              child: Slider(
                value: state.equalizer.preamp,
                min: -12.0,
                max: 12.0,
                divisions: 48,
                onChanged: (value) {
                  HapticFeedback.selectionClick();
                  context.read<EqualizerCubit>().setPreamp(value);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEqualizer(BuildContext context, EqualizerState state) {
    if (!state.equalizer.isEnabled) return const SizedBox.shrink();
    
    final theme = Theme.of(context);
    final values = state.equalizer.currentValues;
    
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.graphic_eq,
                  color: theme.primaryColor,
                ),
                const SizedBox(width: 8),
                Text(
                  context.tr('player.equalizer.frequency_bands'),
                  style: theme.textTheme.titleMedium,
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: List.generate(10, (index) {
                return Expanded(
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: index == 0 || index == 9 ? 0 : 4,
                    ),
                    child: EqualizerBandSlider(
                      value: values[index],
                      frequency: EqualizerPreset.frequencyLabels[index],
                      onChanged: state.equalizer.currentPreset == EqualizerPreset.custom
                          ? (value) {
                              context.read<EqualizerCubit>().updateBandValue(index, value);
                            }
                          : null,
                    ),
                  ),
                );
              }),
            ),
            if (state.equalizer.currentPreset != EqualizerPreset.custom) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: theme.primaryColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.info_outline,
                      size: 16,
                      color: theme.primaryColor,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        context.tr('player.equalizer.custom_mode_info'),
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.primaryColor,
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
    );
  }

  Widget _buildResetButton(BuildContext context) {
    final theme = Theme.of(context);
    
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: () {
          _showResetDialog(context);
        },
        icon: const Icon(Icons.restore),
        label: Text(context.tr('player.equalizer.reset_to_default')),
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.all(16),
          side: BorderSide(color: theme.primaryColor),
        ),
      ),
    );
  }

  void _showResetDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(context.tr('player.equalizer.reset_dialog_title')),
        content: Text(context.tr('player.equalizer.reset_dialog_message')),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: Text(context.tr('common.cancel')),
          ),
          FilledButton(
            onPressed: () {
              Navigator.of(dialogContext).pop();
              context.read<EqualizerCubit>().resetToDefault();
            },
            child: Text(context.tr('player.equalizer.reset_button')),
          ),
        ],
      ),
    );
  }
}