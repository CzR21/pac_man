import 'package:flutter/material.dart';
import '../models/box_model.dart';

class BGPainter extends CustomPainter with ChangeNotifier {
  List<Box> boxes = [];

  @override
  void paint(Canvas canvas, Size size) {
    Path pathMain = Path();
    Path pathWalls = Path();
    Path pathWallStrokes = Path();
    Path pathWallStrokesoval = Path();
    Path orangePath = Path();
    Path powerPath = Path();

    for (var element in boxes) {
      if (!element.isWall) {
        if (element.gotOrange) {
          orangePath.addOval(Rect.fromCircle(
              center: element.position!.offset!.translate(
                  element.size.longestSide / 2, element.size.longestSide / 2),
              radius: element.size.shortestSide * 0.25 / 2));
        }

        if (element.powerUp) {
          powerPath.addOval(Rect.fromCircle(
              center: element.position!.offset!.translate(
                  element.size.longestSide / 2, element.size.longestSide / 2),
              radius: element.size.shortestSide * 0.55 / 2));
        }

        pathMain.addPolygon(
            element.position!.calculateCenters(element.size), true);
      } else {
        pathWalls.addPolygon(
            element.position!.calculateCenters(element.size), true);

        pathWallStrokesoval.addOval(Rect.fromCircle(
            center: element.position!.offset!.translate(
                element.size.longestSide / 2, element.size.longestSide / 2),
            radius: element.size.shortestSide * 0.6 / 2));

        pathWallStrokes.addPolygon(
            element.position!.calculateCenters(element.size), true);
      }
    }

    canvas.drawPath(
        pathMain,
        Paint()
          ..color = Colors.black12
          ..style = PaintingStyle.fill
          ..strokeWidth = 2);

    canvas.drawPath(
        orangePath,
        Paint()
          ..color = const Color.fromARGB(255, 208, 255, 0)
          ..style = PaintingStyle.fill
          ..strokeWidth = 2);

    canvas.drawPath(
        powerPath,
        Paint()
          ..color = Colors.orange
          ..style = PaintingStyle.fill
          ..strokeWidth = 1);

    canvas.drawPath(
        pathWalls,
        Paint()
          ..color = const Color.fromARGB(255, 15, 132, 136)
          ..style = PaintingStyle.fill
          ..strokeWidth = 3);

    canvas.drawPath(
        pathWallStrokes,
        Paint()
          ..color = const Color.fromARGB(255, 11, 77, 94)
          ..style = PaintingStyle.stroke
          ..strokeJoin = StrokeJoin.round
          ..strokeCap = StrokeCap.round
          ..strokeWidth = 3);

    canvas.drawPath(
      pathWallStrokesoval,
      Paint()
        ..color = const Color.fromARGB(255, 11, 45, 94)
        ..style = PaintingStyle.fill
        ..strokeJoin = StrokeJoin.round
        ..strokeCap = StrokeCap.round
        ..strokeWidth = 2,
    );
  }

  BGPainter(this.boxes);

  setBoxes(List<Box> boxes) {
    this.boxes = boxes;
    notifyListeners();
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
