import 'package:flutter/material.dart';

class MusicBarProgress extends StatefulWidget {
  const MusicBarProgress({super.key});

  @override
  State<MusicBarProgress> createState() => _MusicBarProgressState();
}

class _MusicBarProgressState extends State<MusicBarProgress> {
  double _currentSliderValue = 0.3; // Reproducción al 30% (1:24 de 2:46)

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: const [
            Text(
              '1:24',
              style: TextStyle(color: Colors.black54),
            ),
            Text(
              '2:46',
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
            value: _currentSliderValue,
            onChanged: (double value) {
              setState(() {
                _currentSliderValue = value;
              });
            },
          ),
        ),
      ],
    );
  }
}
