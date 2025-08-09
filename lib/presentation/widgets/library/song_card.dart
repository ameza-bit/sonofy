import 'package:flutter/material.dart';
import 'package:sonofy/core/extensions/theme_extensions.dart';
import 'package:sonofy/presentation/widgets/library/reproduction_button.dart';

class SongCard extends StatelessWidget {
  const SongCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          spacing: 12,
          children: [
            const ReproductionButton(),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                spacing: 4,
                children: [
                  Text(
                    'Different world of music',
                    style: TextStyle(
                      fontSize: context.scaleText(16),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    'Manage your library settings and preferences.',
                    style: TextStyle(fontSize: context.scaleText(12)),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
