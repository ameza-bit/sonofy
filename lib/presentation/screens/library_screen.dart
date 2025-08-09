import 'package:flutter/material.dart';
import 'package:sonofy/presentation/widgets/common/font_awesome/font_awesome_flutter.dart';
import 'package:sonofy/presentation/widgets/library/song_card.dart';

class LibraryScreen extends StatelessWidget {
  static const String routeName = 'library';
  const LibraryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          actions: [
            IconButton(
              icon: const Icon(FontAwesomeIcons.lightMagnifyingGlass),
              onPressed: () {},
            ),
            const Spacer(),
            IconButton(
              icon: const Icon(FontAwesomeIcons.lightGear),
              onPressed: () {},
            ),
          ],
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            child: Container(
              margin: const EdgeInsets.symmetric(
                horizontal: 24.0,
                vertical: 16.0,
              ),
              child: const Column(
                children: [
                  SongCard(),
                  SongCard(),
                  SongCard(),
                  SongCard(),
                  SongCard(),
                  SongCard(),
                  SongCard(),
                  SongCard(),
                  SongCard(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
