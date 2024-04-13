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

    pathEyes.addOval(Rect.fromCircle(
        center: getOffsetBasePercent(size, 0.35, 0.4),
        radius: size.width * 0.15));

    pathEyes.addOval(Rect.fromCircle(
        center: getOffsetBasePercent(size, 0.65, 0.4),
        radius: size.width * 0.15));

    Color color = enemy.getColor(index);

    if (!enemy.die) {
      path.addPolygon([
        getOffsetBasePercent(size, 0.2, 0.2),
        getOffsetBasePercent(size, 0.35, 0.15),
        getOffsetBasePercent(size, 0.5, 0.1),
        getOffsetBasePercent(size, 0.65, 0.15),
        getOffsetBasePercent(size, 0.8, 0.2),
        getOffsetBasePercent(size, 0.8, 0.8),
        getOffsetBasePercent(size, 0.7, 0.7),
        getOffsetBasePercent(size, 0.6, 0.8),
        getOffsetBasePercent(size, 0.5, 0.7),
        getOffsetBasePercent(size, 0.4, 0.8),
        getOffsetBasePercent(size, 0.3, 0.7),
        getOffsetBasePercent(size, 0.2, 0.8),
      ], true);

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
