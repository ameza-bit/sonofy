import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sonofy/providers/player_provider.dart';

class MusicBarProgress extends StatefulWidget {
  const MusicBarProgress({super.key});

  @override
  State<MusicBarProgress> createState() => _MusicBarProgressState();
}

class _MusicBarProgressState extends State<MusicBarProgress> {
  // Propiedades para control durante el arrastre del slider
  double _dragValue = 0.0;
  bool _isDragging = false;

  @override
  Widget build(BuildContext context) {
    PlayerProvider playerWatcher = context.watch<PlayerProvider>();

    // Obtener la posición actual y duración del PlayerProvider
    final position = playerWatcher.position;
    final duration = playerWatcher.duration;

    // Calcular el valor del slider (evitar división por cero)
    final sliderValue = _isDragging ? _dragValue : (duration.inSeconds > 0 ? position.inSeconds / duration.inSeconds : 0.0);

    // Formatear posición y duración como texto
    final positionText = _isDragging ? _formatDuration(Duration(seconds: (sliderValue * duration.inSeconds).round())) : _formatDuration(position);
    final durationText = _formatDuration(duration);

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              positionText, // muestra la duración actual
              style: TextStyle(color: Colors.black54),
            ),
            Text(
              durationText, // muestra la duración total
              style: TextStyle(color: Colors.black54),
            ),
          ],
        ),
        SliderTheme(
          data: SliderTheme.of(context).copyWith(
            activeTrackColor: Colors.deepPurple,
            inactiveTrackColor: Colors.grey[300],
            thumbColor: Colors.deepPurple,
            trackHeight: 4.0,
            thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 8.0),
          ),
          child: Slider(
            value: sliderValue.clamp(0.0, 1.0),
            onChanged: (double value) {
              // Actualiza la UI mientras el usuario arrastra
              setState(() {
                _dragValue = value;
                _isDragging = true;
              });
            },
            onChangeEnd: (double value) {
              // Cuando se suelta el slider, buscar esa posición en la canción
              final newPosition = Duration(
                seconds: (value * duration.inSeconds).round(),
              );
              playerWatcher.seek(newPosition);
              setState(() {
                _isDragging = false;
              });
            },
          ),
        ),
      ],
    );
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return '$minutes:$seconds';
  }
}
