import 'package:flutter/material.dart';
import 'package:pac_man/core/enum/direction_enum.dart';

import 'box_model.dart';
import 'box_pos_model.dart';

class Player{

  BoxPos? position;
  Offset? targetOffset;
  List<Box>? boxes;
  late Size sizePerBox;
  bool start = false;
  bool die = false;
  bool powerUp = false;
  double animate = 0;

  Player({this.position}) {
    position ??= BoxPos (0, 0);
  }

  void setOffset(Offset offset) {
    position!.setOffset(offset);
    targetOffset = offset;
  }

  void setAnimate(double animate) => this.animate = animate;

  void setBoxes(List<Box> boxes) => this.boxes = boxes;

  void move(List<Box> boxess) {
    bool gotDirectionTarget = position!.gotDirectionTarget();
    bool canMoveTarget = canMove(targetCheck: true);

    if (canMoveTarget && gotDirectionTarget) {
      position!.direction = position!.directionTarget;
    }

    if (canMove()) position!.setOffset(position!.calculateTargetOffset(boxess));
  }

  bool canMove({bool targetCheck = false}) {
    Offset targetOffsetTemp = position!.calculateTargetOffset(boxes, calculateOnTarget: targetCheck);

    return boxes!.where((element) => element.checkPlayerInBox(targetOffsetTemp,targetCheck ? position!.directionTarget : position!.direction, test: targetCheck),).isNotEmpty;
  }

  void setSize(Size sizePerBox) => this.sizePerBox = sizePerBox;

  bool flagMove() => start && !die;

  void setPlay() => start = true;

  void setReset() {
    die = false;
    start = false;
    position!.direction = Direction.Right;
    position!.directionTarget = Direction.Right;
    position!.setOffset(position!.defaultPos!);
  }

  void gotPowerUp() => powerUp = true;

  void cancelPowerUp() => powerUp;
}