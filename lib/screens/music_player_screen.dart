import 'package:flutter/material.dart';
import 'package:sonofy/widgets/general/clipper_container.dart';
import 'package:sonofy/widgets/player/music_bar_progress.dart';
import 'package:sonofy/widgets/player/play_button.dart';
import 'package:sonofy/widgets/player/song_info.dart';

class MusicPlayerScreen extends StatelessWidget {
  static const String routeName = 'music_player';
  const MusicPlayerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(
            height: MediaQuery.of(context).size.height * 0.5,
            decoration: BoxDecoration(
              color: Colors.grey[900],
              image: const DecorationImage(
                image: NetworkImage('https://centenaries.ucd.ie/wp-content/uploads/2017/05/placeholder-400x600.png'),
                fit: BoxFit.cover,
                opacity: 0.8,
              ),
            ),
          ),
          Column(
            children: [
              SafeArea(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back_ios),
                        onPressed: () {},
                      ),
                      const Text(
                        'NOW PLAYING',
                        style: TextStyle(
                          fontWeight: FontWeight.w900,
                          fontSize: 16,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.favorite_border),
                        onPressed: () {},
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: MediaQuery.of(context).size.height * 0.15),
              ClipperContainer(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 48),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const MusicBarProgress(),
                    const SizedBox(height: 12),
                    const SongInfo(),
                    const SizedBox(height: 32),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.skip_previous, size: 40, color: Colors.black),
                          onPressed: () {},
                        ),
                        PlayButton(),
                        IconButton(
                          icon: const Icon(Icons.skip_next, size: 40, color: Colors.black),
                          onPressed: () {},
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
