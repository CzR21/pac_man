import 'package:flutter/material.dart';
import '../enum/direction_enum.dart';
import 'box_model.dart';

class BoxPos{

  late int rowIndex;
  late int columnIndex;
  Offset? offset;
  Offset? defaultPos;

  Direction direction = Direction.Right;
  Direction directionTarget = Direction.Right;

  BoxPos(this.rowIndex, this.columnIndex, {Size? sizePerBox}) {
    calculateOffset(sizePerBox);
  }

  setOffset(Offset offset) => this.offset = offset;

  setOffsetDefault() => defaultPos = offset;

  setDirection(Direction direction) => this.direction = direction;

  getRotation() {
    int rotation = 0;
    switch (direction) {
      case Direction.Right:
        rotation = 2;
        break;
      case Direction.Top:
        rotation = 1;
        break;
      case Direction.Bottom:
        rotation = 3;
        break;
      default:
        rotation = 4;
    }

    return rotation;
  }

  Offset getOffsetBasedRotation(Size size, { bool calculateOnTarget = false, double rate = 0.25}) {
    Offset targetPos = offset!;

    switch (calculateOnTarget ? directionTarget : direction) {
      case Direction.Right:
        targetPos = offset!.translate((size.width * rate).toDouble(), 0);
        break;
      case Direction.Top:
        targetPos = offset!.translate(0, -((size.height * rate).toDouble()));
        break;
      case Direction.Bottom:
        targetPos = offset!.translate(0, (size.height * rate).toDouble());
        break;
      default:
        targetPos = offset!.translate(-((size.width * rate).toDouble()), 0);
    }

    return targetPos;
  }

  void calculateOffset(Size? sizePerBox) {
    sizePerBox ??= Size.zero;
    setOffset(Offset(sizePerBox.width * columnIndex, sizePerBox.height * rowIndex));
  }

  void setDirectionInt(Offset offSet, {bool canRotateRealTime = false}) {
    late Direction x;
    late Direction y;

    x = (offSet.dx > 0) ? Direction.Right : Direction.Left;
    y = (offSet.dy > 0) ? Direction.Bottom : Direction. Top;

    directionTarget = offSet.dx.abs() >= offSet.dy.abs() ? x : y;

    if (canRotateRealTime) direction = directionTarget;
  }

  void setBoxPos(BoxPos boxPos, Size? sizePerBox) {
    rowIndex = boxPos.rowIndex;
    columnIndex = boxPos.columnIndex;
    calculateOffset(sizePerBox);
  }

  void implementDirectionTarget() => setDirection(directionTarget);

  Offset calculateTargetOffset(List<Box>? boxes, { bool calculateOnTarget = false }) => getOffsetBasedRotation(boxes!.first.size, calculateOnTarget: calculateOnTarget, );

  bool gotDirectionTarget() => direction != directionTarget;

  calculateCenters(Size size) {
    Offset boxPosMin = offset!;
    Offset boxPosMax = offset!.translate(size.width, size.height);

    return [
      boxPosMin,
      boxPosMin.translate(size.longestSide, 0),
      boxPosMax,
      boxPosMin.translate(0, size.longestSide),
    ];
  }

  bool positionInCenter(Size sizePerBox, BoxPos playerPos) {
    Offset playerCenter = playerPos.offset!.translate(-sizePerBox.width / 2, -sizePerBox.height / 2);

    Offset selfCenter = offset!.translate(-sizePerBox.width / 2, -sizePerBox.height / 2);

    return (playerCenter - selfCenter).distance < sizePerBox.shortestSide * 0.55;
  }

  bool arriveBase(Size sizePerBox) => (offset! - defaultPos!).distance < 0.1;
}