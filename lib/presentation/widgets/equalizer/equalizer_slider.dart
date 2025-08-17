import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sonofy/core/extensions/color_extensions.dart';
import 'package:sonofy/core/extensions/theme_extensions.dart';
import 'package:sonofy/presentation/blocs/equalizer/equalizer_cubit.dart';
import 'package:sonofy/presentation/blocs/settings/settings_cubit.dart';
import 'package:sonofy/presentation/blocs/settings/settings_state.dart';

class EqualizerSlider extends StatefulWidget {
  final int bandIndex;
  final String bandName;
  final String frequency;
  final double value;
  final double minValue;
  final double maxValue;
  final ValueChanged<double>? onChanged;

  const EqualizerSlider({
    required this.bandIndex,
    required this.bandName,
    required this.frequency,
    required this.value,
    this.minValue = -12.0,
    this.maxValue = 12.0,
    this.onChanged,
    super.key,
  });

  @override
  State<EqualizerSlider> createState() => _EqualizerSliderState();
}

class _EqualizerSliderState extends State<EqualizerSlider> {
  bool _isDragging = false;
  double _dragValue = 0.0;

  @override
  void initState() {
    super.initState();
    _dragValue = widget.value;
  }

  @override
  void didUpdateWidget(EqualizerSlider oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!_isDragging && widget.value != oldWidget.value) {
      _dragValue = widget.value;
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SettingsCubit, SettingsState>(
      builder: (context, settingsState) {
        final primaryColor = settingsState.settings.primaryColor;

        return Expanded(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Valor actual
              Container(
                height: 32,
                alignment: Alignment.center,
                child: Text(
                  '${(_isDragging ? _dragValue : widget.value).toStringAsFixed(1)}dB',
                  style: TextStyle(
                    fontSize: context.scaleText(12),
                    fontWeight: FontWeight.w600,
                    color: primaryColor,
                  ),
                ),
              ),

              const SizedBox(height: 8),

              // Slider vertical
              Expanded(
                child: RotatedBox(
                  quarterTurns: 3,
                  child: SliderTheme(
                    data: SliderTheme.of(context).copyWith(
                      trackHeight: 6.0,
                      thumbColor: primaryColor,
                      activeTrackColor: primaryColor,
                      inactiveTrackColor: primaryColor.withValues(alpha: 0.3),
                      thumbShape: RoundSliderThumbShape(
                        enabledThumbRadius: _isDragging ? 12.0 : 10.0,
                      ),
                      overlayShape: RoundSliderOverlayShape(
                        overlayRadius: _isDragging ? 24.0 : 20.0,
                      ),
                      tickMarkShape: SliderTickMarkShape.noTickMark,
                      valueIndicatorShape:
                          const RectangularSliderValueIndicatorShape(),
                      valueIndicatorColor: primaryColor,
                      showValueIndicator: ShowValueIndicator.never,
                    ),
                    child: Slider(
                      value: _isDragging ? _dragValue : widget.value,
                      min: widget.minValue,
                      max: widget.maxValue,
                      divisions: 48, // 0.5dB increments
                      onChanged: (value) {
                        setState(() {
                          _isDragging = true;
                          _dragValue = value;
                        });
                      },
                      onChangeStart: (value) {
                        setState(() {
                          _isDragging = true;
                          _dragValue = value;
                        });
                      },
                      onChangeEnd: (value) {
                        setState(() {
                          _isDragging = false;
                        });

                        // Actualizar el estado del ecualizador
                        context.read<EqualizerCubit>().setBandGain(
                          widget.bandIndex,
                          value,
                        );

                        // Llamar callback si existe
                        widget.onChanged?.call(value);
                      },
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 8),

              // Nombre de la banda
              Text(
                widget.bandName,
                style: TextStyle(
                  fontSize: context.scaleText(14),
                  fontWeight: FontWeight.w500,
                  color: context.textPrimary,
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 4),

              // Frecuencia
              Text(
                widget.frequency,
                style: TextStyle(
                  fontSize: context.scaleText(10),
                  color: context.musicMediumGrey,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        );
      },
    );
  }
}
