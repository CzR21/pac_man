import 'package:flutter/material.dart';
import '../enum/direction_enum.dart';
import '../models/ghost_model.dart';

class GhostPainter extends CustomPainter with ChangeNotifier {
  Enemy enemy;
  int index;

  @override
  void paint(Canvas canvas, Size size) {

    Path path = Path();
    Path pathEyes = Path();
    Path pathMouth = Path();

    pathEyes.addOval(Rect.fromCircle(
        center: getOffsetBasePercent(size, 0.35, 0.4),
        radius: size.width * 0.1));

    pathEyes.addOval(Rect.fromCircle(
        center: getOffsetBasePercent(size, 0.65, 0.4),
        radius: size.width * 0.1));

    Color color = Colors.green;

    if (!enemy.die) {
      path.moveTo(getOffsetBasePercent(size, 0.2, 0.5).dx,
          getOffsetBasePercent(size, 0.2, 0.5).dy);
      path.lineTo(getOffsetBasePercent(size, 0.3, 0.3).dx,
          getOffsetBasePercent(size, 0.3, 0.3).dy);
      path.quadraticBezierTo(
          getOffsetBasePercent(size, 0.5, 0.1).dx,
          getOffsetBasePercent(size, 0.5, 0.1).dy,
          getOffsetBasePercent(size, 0.7, 0.3).dx,
          getOffsetBasePercent(size, 0.7, 0.3).dy);
      path.lineTo(getOffsetBasePercent(size, 0.8, 0.5).dx,
          getOffsetBasePercent(size, 0.8, 0.5).dy);
      path.lineTo(getOffsetBasePercent(size, 0.7, 0.7).dx,
          getOffsetBasePercent(size, 0.7, 0.7).dy);
      path.lineTo(getOffsetBasePercent(size, 0.6, 0.9).dx,
          getOffsetBasePercent(size, 0.6, 0.9).dy);
      path.quadraticBezierTo(
          getOffsetBasePercent(size, 0.5, 0.95).dx,
          getOffsetBasePercent(size, 0.5, 0.95).dy,
          getOffsetBasePercent(size, 0.4, 0.9).dx,
          getOffsetBasePercent(size, 0.4, 0.9).dy);
      path.lineTo(getOffsetBasePercent(size, 0.3, 0.7).dx,
          getOffsetBasePercent(size, 0.3, 0.7).dy);
      path.close();

      pathMouth.moveTo(getOffsetBasePercent(size, 0.4, 0.9).dx,
          getOffsetBasePercent(size, 0.4, 0.9).dy);
      pathMouth.lineTo(getOffsetBasePercent(size, 0.6, 0.9).dx,
          getOffsetBasePercent(size, 0.4, 0.9).dy);
      pathMouth.lineTo(getOffsetBasePercent(size, 0.5, 0.8).dx,
          getOffsetBasePercent(size, 0.5, 0.8).dy);
      pathMouth.close();

      canvas.drawPath(
          path,
          Paint()
            ..color = color
            ..style = PaintingStyle.fill
            ..strokeWidth = 3);
    }

    canvas.drawPath(
        pathEyes,
        Paint()
          ..color = Colors.white
          ..style = PaintingStyle.fill
          ..strokeWidth = 3);

    canvas.drawPath(
        makeEyeLid(canvas, enemy, size),
        Paint()
          ..color = const Color.fromARGB(255, 0, 0, 0)
          ..style = PaintingStyle.fill
          ..strokeWidth = 3);

    canvas.drawPath(
        pathMouth,
        Paint()
          ..color = Colors.pink
          ..style = PaintingStyle.fill
          ..strokeWidth = 3);
  }

  GhostPainter(this.index, this.enemy);

  setBoxes(Enemy enemy) => this.enemy = enemy;

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;

  Offset getOffsetBasePercent(Size size, double d, double e) => Offset(size.width * d, size.height * e);

  Path makeEyeLid(Canvas canvas, Enemy enemy, Size size) {
    Path pathEyeBlacks = Path();

    for (var element in [const Size(0.35, 0.4), const Size(0.65, 0.4)]) {
      pathEyeBlacks.addOval(Rect.fromCircle(
          center: eyeLidDirection(enemy.position!.direction, size, element, 0.08),
          radius: size.width * 0.08));
    }

    return pathEyeBlacks;
  }

  Offset eyeLidDirection(
      Direction direction, Size size, Size sizePos, double distance) {
    Offset offset = Offset.zero;

    switch (direction) {
      case Direction.Right:
        offset = offset.translate(size.shortestSide * distance, 0);
      case Direction.Left:
        offset = offset.translate(-(size.shortestSide * distance), 0);
      case Direction.Bottom:
        offset = offset.translate(0, size.shortestSide * distance);
      default:
        offset = offset.translate(0, -(size.shortestSide * distance));
    }

    return getOffsetBasePercent(size, sizePos.width, sizePos.height).translate(offset.dx, offset.dy);
  }
}
