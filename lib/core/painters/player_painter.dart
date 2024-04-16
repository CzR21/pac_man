import 'dart:math';
import 'package:flutter/material.dart';
import '../models/player_model.dart';

class PlayerPainter extends CustomPainter with ChangeNotifier{

  Player player;
  double animation = 0;

  @override
  void paint(Canvas canvas, Size size) {
    Paint paint = Paint()..style = PaintingStyle.fill;
    Offset center = Offset(size.width / 2, size.height / 2);
    double radius = min(size.width * 0.75 / 2, size.height * 0.75 / 2);

    if (player.die) {
      _drawDie(canvas, paint, radius: radius, center: center);
    } else {
      _drawBirdFace(
        canvas,
        paint,
        center: center,
        radius: radius,
      );
    }
  }

  void _drawBirdFace(Canvas canvas, Paint paint, {required Offset center, required double radius}) {
    canvas.drawCircle(
      center,
      radius,
      paint..color = Colors.yellow,
    );

    canvas.drawCircle(
      const Offset(13, 22),
      radius / 4,
      paint..color = Colors.black,
    );
    canvas.drawCircle(
      const Offset(25, 22),
      radius / 4,
      paint..color = Colors.black,
    );

    Path pathBeak = Path();
    pathBeak.moveTo(center.dx, 6);
    pathBeak.lineTo(center.dx + radius / 2, center.dy - 3 );
    pathBeak.lineTo(center.dx - radius / 2, center.dy - 3);
    pathBeak.close();
    canvas.drawPath(
      pathBeak,
      paint..color = Colors.orange,
    );
  }

  PlayerPainter (this.player, this.animation);

  setBoxes (Player player) => this.player = player;

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;

  void _drawDie(Canvas canvas, Paint paint, {double? radius, Offset? center}) {
    paint.color = const Color.fromARGB(255, 252, 228, 19);
    canvas.drawCircle(center!, radius! * (1 - animation), paint);
  }
}