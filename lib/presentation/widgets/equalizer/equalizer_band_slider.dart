import 'package:flutter/material.dart';

class EqualizerBandSlider extends StatelessWidget {
  final double value;
  final String frequency;
  final ValueChanged<double>? onChanged;

  const EqualizerBandSlider({
    required this.value,
    required this.frequency,
    super.key,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isEnabled = onChanged != null;
    
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          value.toStringAsFixed(1),
          style: theme.textTheme.bodySmall?.copyWith(
            fontWeight: FontWeight.w600,
            color: isEnabled ? theme.primaryColor : theme.disabledColor,
            fontSize: 12,
          ),
        ),
        const SizedBox(height: 8),
        SizedBox(
          height: 200,
          child: RotatedBox(
            quarterTurns: 3,
            child: SliderTheme(
              data: SliderTheme.of(context).copyWith(
                trackHeight: 6,
                activeTrackColor: isEnabled ? theme.primaryColor : theme.disabledColor,
                inactiveTrackColor: isEnabled 
                    ? theme.primaryColor.withValues(alpha: 0.3) 
                    : theme.disabledColor.withValues(alpha: 0.3),
                thumbColor: isEnabled ? theme.primaryColor : theme.disabledColor,
                thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 10),
                overlayShape: const RoundSliderOverlayShape(),
                tickMarkShape: SliderTickMarkShape.noTickMark,
              ),
              child: Slider(
                value: value.clamp(-12.0, 12.0),
                min: -12.0,
                max: 12.0,
                divisions: 48,
                onChanged: onChanged,
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          frequency,
          style: theme.textTheme.bodySmall?.copyWith(
            color: isEnabled ? theme.textTheme.bodySmall?.color : theme.disabledColor,
            fontSize: 11,
            fontWeight: FontWeight.w500,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}