import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:sonofy/providers/player_provider.dart';
import 'package:sonofy/screens/music_player_screen.dart';
import 'package:sonofy/widgets/general/clipper_container.dart';
import 'package:sonofy/widgets/player/play_button.dart';
import 'package:sonofy/widgets/player/song_info.dart';

class BottomSheetPlayer extends StatelessWidget {
  const BottomSheetPlayer({super.key});

  @override
  Widget build(BuildContext context) {
    PlayerProvider playerWatcher = context.watch<PlayerProvider>();

    // Obtener la posición actual y duración del PlayerProvider
    final position = playerWatcher.position;
    final duration = playerWatcher.duration;

    // Calcular el valor del slider (evitar división por cero)
    final sliderValue = (duration.inSeconds > 0 ? position.inSeconds / duration.inSeconds : 0.0);

    DecorationImage? songCover;
    if (playerWatcher.currentSong != null) {
      songCover = DecorationImage(
        image: NetworkImage(playerWatcher.currentSong?.songCover ?? 'https://centenaries.ucd.ie/wp-content/uploads/2017/05/placeholder-400x600.png'),
        fit: BoxFit.cover,
      );
    }

    Widget container = ClipperContainer(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
      child: SafeArea(
        child: Row(
          spacing: 16,
          children: [
            // Contenedor con borde de progreso
            Container(
              padding: const EdgeInsets.all(2), // Reducido para dar espacio al borde de progreso
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(50),
                gradient: LinearGradient(
                  colors: [Colors.deepPurple, Colors.purple],
                ),
              ),
              child: CustomPaint(
                foregroundPainter: ProgressBorderPainter(
                  progress: sliderValue,
                  progressColor: Colors.deepPurple,
                  backgroundColor: Colors.transparent,
                  strokeWidth: 2.0,
                ),
                child: Hero(
                  tag: "song-image-cover",
                  child: Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(50),
                      image: songCover,
                    ),
                  ),
                ),
              ),
            ),
            Expanded(child: SongInfo(isBottomSheet: true)),
            if (playerWatcher.currentSong != null) PlayButton(size: 60),
          ],
        ),
      ),
    );

    if (playerWatcher.currentSong != null) {
      container = InkWell(
        onTap: () {
          if (playerWatcher.currentSong != null) {
            context.goNamed(MusicPlayerScreen.routeName);
          }
        },
        child: container,
      );
    }

    return container;
  }
}

// Clase personalizada para dibujar el borde de progreso
class ProgressBorderPainter extends CustomPainter {
  final double progress;
  final Color progressColor;
  final Color backgroundColor;
  final double strokeWidth;

  ProgressBorderPainter({
    required this.progress,
    required this.progressColor,
    required this.backgroundColor,
    required this.strokeWidth,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - strokeWidth) / 2;

    // Dibujar arco completo (360 grados) con el color de fondo si es necesario
    if (backgroundColor != Colors.transparent) {
      final backgroundPaint = Paint()
        ..color = backgroundColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth;

      canvas.drawCircle(center, radius, backgroundPaint);
    }

    // Dibujar arco de progreso
    final progressPaint = Paint()
      ..color = progressColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    // Arco de progreso (desde la parte superior, en sentido horario)
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -1.5708, // -90 grados en radianes (inicio desde arriba)
      2 * 3.1416 * progress, // Convertir el progreso a radianes (360 grados = 2π)
      false,
      progressPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true; // Repintar siempre que cambie el progreso
  }
}
