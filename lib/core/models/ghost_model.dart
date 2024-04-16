import 'dart:math';
import 'package:flutter/material.dart';
import 'package:pac_man/core/enum/direction_enum.dart';
import 'package:pac_man/globals/constants.dart';
import '../../helpers/search_a_star.dart';
import '../../helpers/search_greedy_best.dart';
import 'box_model.dart';
import 'box_pos_model.dart';
import 'row_colums_model.dart';

class Enemy {
  bool start = false;
  bool roaming = false;
  bool die = false;
  bool pause = false;
  BoxPos? position;
  bool playerPowerUp = false;
  List<Offset> targetOffsets = [];
  Offset? targetOffset;
  int? randomDelay;
  bool returnBase = false;

  Enemy({this.position, Offset? offset}) {
    position ??= BoxPos(0, 0);
    if (offset != null) setOffset(offset);
  }

  void setOffset(Offset offset) => position!.setOffset(offset);

  void setStart(bool start) => this.start = start;

  void setRoaming(bool roaming) => this.roaming = roaming;

  bool flagMove() => start;

  void setPause() => pause = true;

  void setPlay() {
    start = true;
    pause = false;
  }

  void setReset({bool dieEvent = false, bool setDefaultPos = true}) {
    pause = false;

    if (!dieEvent) {
      die = false;
      start = false;
      returnBase = false;
      if (setDefaultPos) position!.setOffset(position!.defaultPos!);
    } else {
      die = true;
      start = true;
      returnBase = true;
      randomDelay = null;
    }

    playerPowerUp = false;
    targetOffsets = [];
    targetOffset = null;
  }

  void setReturn(bool returnBase) => this.returnBase = returnBase;

  void gotPowerUp() {
    if (returnBase || die) return;

    playerPowerUp = true;
    targetOffset = null;
    targetOffsets = [];
    randomDelay = 0;
    calculateNextTarget();
  }

  void cancelPowerUp() {
    if (returnBase) return;

    playerPowerUp = false;
    targetOffset = null;
    targetOffsets = [];
    randomDelay = 0;
    calculateNextTarget();
  }

  bool completeArrive(Size size) {
    if (targetOffset == null) return false;

    return (targetOffset! - position!.offset!).distance <
        (size.shortestSide * 0.25);
  }

  void calculateNextTarget() {
    if (targetOffsets.length <= randomDelay! && !returnBase) {
      targetOffsets = [];
      generateRandom();
    }

    if (targetOffsets.isEmpty) return;

    targetOffset = targetOffsets.removeAt(0);

    position!.setDirectionInt(targetOffset! - position!.offset!,
        canRotateRealTime: true);
  }

  void computedNewPoint(
    Offset playerOffset,
    List<Box> boxes, {
    required RowColumn boxSize,
    required List<List<dynamic>> barriers,
    required Size size,
    required int index,
  }) {
    targetOffsets = [];
    targetOffset = null;

    if (playerPowerUp) {
      List<Box> boxTargets = boxes
          .where((element) =>
              (element.position!.offset! - playerOffset).distance >
              size.shortestSide * 2)
          .toList();

      if (boxTargets.isNotEmpty) {
        boxTargets.shuffle();
        playerOffset = boxTargets.first.position!.offset!;
      }
    }

    Box? playerBox =
        boxes.firstWhere((element) => element.checkoffsetIn(playerOffset));
    Box? ghostBox =
        boxes.firstWhere((element) => element.checkoffsetIn(position!.offset!));

    Offset ghostPos = Offset(ghostBox.position!.columnIndex.toDouble(),
        ghostBox.position!.rowIndex.toDouble());
    late Offset targetPos;

    const double maxDX = 23.0;
    const double minDX = 1.0;
    const double maxDY = 16.0;
    const double minDY = 1.0;

    if (index == 0) {
      // Blinky
      targetPos = Offset(playerBox.position!.columnIndex.toDouble(),
          playerBox.position!.rowIndex.toDouble());
    } else if (index == 1) {
      // Clyde
      double distance = (Offset(playerBox.position!.columnIndex.toDouble(),
                  playerBox.position!.rowIndex.toDouble()) -
              ghostPos)
          .distance;
      if (distance > 5) {
        targetPos = Offset(playerBox.position!.columnIndex.toDouble(),
            playerBox.position!.rowIndex.toDouble());
      } else {
        targetPos = const Offset(1, 1);
      }
    } else if (index == 2) {
      // Pinky
      double dx = playerBox.position!.columnIndex.toDouble();
      double dy = playerBox.position!.rowIndex.toDouble();

      switch (playerBox.position!.direction) {
        case Direction.Top:
          dy -= 2;
          break;
        case Direction.Bottom:
          dy += 2;
          break;
        case Direction.Right:
          dx += 2;
          break;
        case Direction.Left:
          dx -= 2;
          break;
      }

      dx = dx.clamp(minDX, maxDX);
      dy = dy.clamp(minDY, maxDY);

      targetPos = Offset(dx, dy);
    } else {
      // Inky
      double dx = playerBox.position!.columnIndex.toDouble();
      double dy = playerBox.position!.rowIndex.toDouble();

      switch (playerBox.position!.direction) {
        case Direction.Top:
          dy -= 1;
          break;
        case Direction.Bottom:
          dy += 1;
          break;
        case Direction.Right:
          dx += 1;
          break;
        case Direction.Left:
          dx -= 1;
          break;
      }

      dx = dx.clamp(minDX, maxDX);
      dy = dy.clamp(minDY, maxDY);

      targetPos = Offset(dx, dy);
    }

    late List<Offset> result;

    if(Constant.fase == 1){
      result = GreedyBestFirstSearch(
        rows: boxSize.row,
        columns: boxSize.column,
        start: ghostPos,
        end: targetPos,
        barriers: List<Offset>.from(barriers.expand((element) => element)),
      ).findThePath();
    }else if(Constant.fase == 2){
      switch (index) {
        case 0:
        case 1:
          result = AStar(
            rows: boxSize.row,
            columns: boxSize.column,
            start: ghostPos,
            end: targetPos,
            barriers: List<Offset>.from(barriers.expand((element) => element)),
            withDiagonal: false,
          ).findThePath();
          break;
        case 2:
        case 3:
          result = GreedyBestFirstSearch(
            rows: boxSize.row,
            columns: boxSize.column,
            start: ghostPos,
            end: targetPos,
            barriers: List<Offset>.from(barriers.expand((element) => element)),
          ).findThePath();
          break;
        default:
         throw "ERRO NO INDEX";
      }
    }else{
      result = AStar(
        rows: boxSize.row,
        columns: boxSize.column,
        start: ghostPos,
        end: targetPos,
        barriers: List<Offset>.from(barriers.expand((element) => element)),
        withDiagonal: false,
      ).findThePath();
    }

    targetOffsets =
        result.map((e) => e.scale(size.width, size.height)).toList();
    targetOffsets.add(targetPos);

    if (!die) {
      generateRandom();
    } else {
      randomDelay = targetOffsets.length - 1;
    }

    calculateNextTarget();
  }

  void move(Size size) {
    if (targetOffset != null && !pause) {
      position!.setOffset(position!.getOffsetBasedRotation(size));
    }
  }

  void generateRandom() => randomDelay =
      targetOffsets.length < 2 ? 0 : Random().nextInt(targetOffsets.length);

  void setDie() => die = true;

  void setStop() {}

  getColor(int index) {
    if (playerPowerUp) {
      return const Color.fromARGB(255, 2, 70, 126);
    } else {
      switch (index) {
        case 0:
          return Colors.red;
        case 1:
          return Colors.blue;
        case 2:
          return Colors.orange;
        default:
          return Colors.pink;
      }
    }
  }
}
