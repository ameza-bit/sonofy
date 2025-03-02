import 'package:flutter/material.dart';

class MusicPlayerScreen extends StatefulWidget {
  const MusicPlayerScreen({super.key});

  @override
  State<MusicPlayerScreen> createState() => _MusicPlayerScreenState();
}

// CustomClipper para crear el efecto ondulado
class WaveClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    var path = Path();

    // Comenzar desde la esquina superior izquierda
    path.lineTo(0, 40);

    // Crear el efecto ondulado
    var firstControlPoint = Offset(size.width / 4, 0);
    var firstEndPoint = Offset(size.width / 2, 20);
    path.quadraticBezierTo(firstControlPoint.dx, firstControlPoint.dy, firstEndPoint.dx, firstEndPoint.dy);

    var secondControlPoint = Offset(size.width * 3 / 4, 40);
    var secondEndPoint = Offset(size.width, 0);
    path.quadraticBezierTo(secondControlPoint.dx, secondControlPoint.dy, secondEndPoint.dx, secondEndPoint.dy);

    // Completar el path hacia las esquinas inferior derecha e izquierda
    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);
    path.close();

    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}

class _MusicPlayerScreenState extends State<MusicPlayerScreen> {
  double _currentSliderValue = 0.3; // Reproducción al 30% (1:24 de 2:46)

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
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
              SizedBox(height: MediaQuery.of(context).size.height * 0.4),
              Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: const BorderRadius.only(
                    topRight: Radius.circular(80),
                  ),
                ),
                padding: const EdgeInsets.all(20),
                child: Center(
                  child: const Text(
                    'Title',
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              Expanded(
                child: Container(
                  width: double.infinity,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ],
      ),
    );

    // ignore: dead_code
    return Scaffold(
      body: Column(
        children: [
          // Sección superior con imagen y controles
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.grey[900],
                image: const DecorationImage(
                  image: NetworkImage('https://centenaries.ucd.ie/wp-content/uploads/2017/05/placeholder-400x600.png'),
                  fit: BoxFit.cover,
                  opacity: 0.8,
                ),
              ),
              child: Column(
                children: [
                  // Barra superior
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
                              fontWeight: FontWeight.bold,
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
                ],
              ),
            ),
          ),

          // Sección inferior con controles de reproducción
          Container(
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(30),
                topRight: Radius.circular(30),
              ),
            ),
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 40),
            child: Column(
              children: [
                // Tiempo y barra de progreso
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

                // Título de la canción y artistas
                const SizedBox(height: 10),
                const Text(
                  'Different World (feat. COR...',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Alan Walker, K-391 & Sofia Carson',
                  style: TextStyle(
                    color: Colors.black54,
                    fontSize: 16,
                  ),
                ),

                // Botones de control
                const SizedBox(height: 30),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.skip_previous, size: 40, color: Colors.black),
                      onPressed: () {},
                    ),
                    Container(
                      width: 80,
                      height: 80,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: LinearGradient(
                          colors: [Colors.deepPurple, Colors.purple],
                        ),
                      ),
                      child: IconButton(
                        icon: const Icon(Icons.play_arrow, size: 40, color: Colors.white),
                        onPressed: () {},
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.skip_next, size: 40, color: Colors.black),
                      onPressed: () {},
                    ),
                  ],
                ),

                // Botón de lyrics
                const SizedBox(height: 20),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(30),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.2),
                        spreadRadius: 1,
                        blurRadius: 5,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: const Center(
                    child: Text(
                      'LYRICS',
                      style: TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
