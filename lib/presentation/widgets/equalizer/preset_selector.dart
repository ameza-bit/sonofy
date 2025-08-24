import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:sonofy/core/enums/equalizer_preset.dart';

class PresetSelector extends StatelessWidget {
  final EqualizerPreset currentPreset;
  final ValueChanged<EqualizerPreset> onPresetChanged;

  const PresetSelector({
    required this.currentPreset,
    required this.onPresetChanged,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
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
                  Icons.library_music,
                  color: theme.primaryColor,
                ),
                const SizedBox(width: 8),
                Text(
                  context.tr('player.equalizer.presets'),
                  style: theme.textTheme.titleMedium,
                ),
              ],
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8.0,
              runSpacing: 8.0,
              children: EqualizerPreset.values.map((preset) {
                final isSelected = preset == currentPreset;
                return FilterChip(
                  selected: isSelected,
                  label: Text(preset.name),
                  onSelected: (selected) {
                    if (selected) {
                      onPresetChanged(preset);
                    }
                  },
                  selectedColor: theme.primaryColor.withValues(alpha: 0.2),
                  checkmarkColor: theme.primaryColor,
                  side: BorderSide(
                    color: isSelected ? theme.primaryColor : Colors.transparent,
                    width: 2,
                  ),
                );
              }).toList(),
            ),
            if (currentPreset == EqualizerPreset.custom) ...[
              const SizedBox(height: 12),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: theme.primaryColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: theme.primaryColor.withValues(alpha: 0.3),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.tune,
                      size: 16,
                      color: theme.primaryColor,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      context.tr('player.equalizer.custom_mode'),
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.primaryColor,
                        fontWeight: FontWeight.w600,
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
}