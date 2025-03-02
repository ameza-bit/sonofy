import 'package:flutter/material.dart';

class CurvedImageView extends StatelessWidget {
  const CurvedImageView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey,
      body: Center(
        child: ClipPath(
          clipper: MyCustomClipper(),
          child: Container(
            width: 200,
            height: 200,
            color: Colors.pink,
          ),
        ),
      ),
    );
  }
}

class MyCustomClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    Path path = Path();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}

// CustomClipper personalizado para la forma curva blanca
class CurvedClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();

    // Empezamos desde la esquina inferior derecha
    path.moveTo(size.width, size.height);

    // Nos movemos hacia la izquierda, en la parte inferior
    path.lineTo(0, size.height);

    // Creamos la curva que sube hacia la derecha
    path.quadraticBezierTo(
      size.width * 0.5, // punto de control x
      size.height * 0.2, // punto de control y
      size.width, // punto final x
      0, // punto final y
    );

    // Cerramos el path
    path.close();

    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}

// Alternativamente, si deseas una curva más precisa, puedes usar este CustomClipper
class AlternativeCurvedClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();

    // Establece el punto de inicio en la esquina inferior derecha
    path.moveTo(size.width, size.height);

    // Línea recta hasta la esquina inferior izquierda
    path.lineTo(0, size.height);

    // Curva que sube hacia la derecha, similar a la de la imagen
    path.cubicTo(
      size.width * 0.2, // control point 1 x
      size.height * 0.8, // control point 1 y
      size.width * 0.7, // control point 2 x
      0, // control point 2 y
      size.width, // end point x
      size.height * 0.3, // end point y
    );

    // Cerramos el path
    path.close();

    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}

// Para implementar la versión alternativa, reemplaza CurvedClipper por AlternativeCurvedClipper
// en el widget ClipPath arriba
