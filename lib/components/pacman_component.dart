import 'dart:async';
import 'package:flutter/material.dart';
import 'package:pac_man/core/painters/ghost_painter.dart';
import 'package:pac_man/core/painters/player_painter.dart';
import 'package:pac_man/globals/constants.dart';
import '../core/enum/direction_enum.dart';
import '../core/models/box_model.dart';
import '../core/models/box_pos_model.dart';
import '../core/models/ghost_model.dart';
import '../core/models/player_model.dart';
import '../core/models/row_colums_model.dart';
import '../core/painters/bg_painter.dart';
import '../main.dart';

class PacmanComponent extends StatefulWidget {

  Size sizeFull;

  PacmanComponent({super.key, required this.sizeFull,});

  @override
  State<PacmanComponent> createState() => PacmanComponentState();
}

class PacmanComponentState extends State<PacmanComponent> with TickerProviderStateMixin{

  RowColumn boxSize = RowColumn(1, 1);
  GlobalKey key = GlobalKey();

  ValueNotifier<Player> playerNotifier = ValueNotifier<Player>(Player());
  ValueNotifier<List<List<Box>>> boxesNotifier = ValueNotifier<List<List<Box>>>([]);
  ValueNotifier<List<Enemy>> enemiesNotifier = ValueNotifier<List<Enemy>>([
    Enemy(position: BoxPos(6, 13)),
    Enemy(position: BoxPos(6, 14)),
    Enemy(position: BoxPos(6, 15)),
    Enemy(position: BoxPos(6, 16)),
  ]);

  GlobalKey<MyHomePageState> mainkey = GlobalKey<MyHomePageState>();

  BGPainter bgPainter = BGPainter([]);

  Size sizeBoxOuter = Size.zero;
  late Size sizePerBox = Size.zero;
  late Timer timerEnemies;
  late Timer timerPlayer;

  Timer? timerPower;
  Offset? offsetDragStart;
  Direction? direction;
  bool start = false;
  List<List<dynamic>> barriers = [];

  late Animation<double> animation;
  late AnimationController animationController;
  late Size sizeFull;

  @override
  void initState() {
    super.initState();
    setupAnimationPlayer();
    sizeBoxOuter = sizeFull = widget.sizeFull;
    WidgetsBinding.instance.addPostFrameCallback((_) => iniatiateProcess());
  }

  @override
  void dispose() {
    animation.removeListener(() {});
    animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.center,
      child: Container(
        constraints: BoxConstraints.tight(boxSize.calculateMaxSizeGame(sizeBoxOuter)),
        child: Stack(
          clipBehavior: Clip.antiAlias,
          fit: StackFit.loose,
          alignment: Alignment.center,
          children: [
            backgroundWidget(),
            ...foregroundWidget(),
          ],
        ),
      ),
    );
  }

  setupAnimationPlayer({
    int durationPlaySecond = 200,
    double start = 0,
    double end = 1,
    bool reverse = true
  }) {
    if (!reverse) {
      animationController.stop();
      animationController.reset();
    }
    animationController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: durationPlaySecond),
      lowerBound: 0,
      upperBound: 1
    );

    animation = Tween<double>(begin: start, end: end).animate(animationController);

    if (reverse) {
      animationController.repeat(reverse: true);
    } else {
      animationController.forward();
    }
  }

  updateDragDown(Offset offset, {bool start = false}) {
    if (start) {
      offsetDragStart = offset;
    } else {
      playerNotifier.value.position!.setDirectionInt((offset - offsetDragStart!));
      playerNotifier.notifyListeners();
    }
  }

  backgroundWidget() {
    return LayoutBuilder(
      builder: (context, constraint) {
        return Container(
          alignment: Alignment.center,
          color: Colors.black,
          child: CustomPaint(
            painter: bgPainter,
            willChange: true,
            child: ValueListenableBuilder(
              valueListenable: boxesNotifier,
              builder: (context, List<List<Box>> boxes, child) {
                bgPainter.setBoxes (boxes.expand((element) => element).toList());
                return Container();
              },
            ),
          ),
        );
      }
    );
  }

  foregroundWidget(){
    return [
      ValueListenableBuilder(
        valueListenable: enemiesNotifier,
        builder: (context, List<Enemy> enemies, child) => Stack(
          children: [
            ...enemies.asMap().entries.map((e) => AnimatedPositioned(
                duration: Duration(milliseconds: e.value.start || e.value.roaming ? 300 : 1),
                left: e.value.position?.offset?.dx,
                top: e.value.position?.offset?.dy,
                child: CustomPaint(
                  foregroundPainter: GhostPainter(e.key, e.value),
                  child: Container(
                    constraints: BoxConstraints.tight(sizePerBox),
                    padding: EdgeInsets.all(sizePerBox.longestSide * 0.1),
                    // child: Container(
                    //   margin: const EdgeInsets.all(4.5),
                    //   color: e.value.getColor(e.key),
                    // ),
                  ),
                ),
              ),
            ),
            child!,
          ],
        ),
        child: ValueListenableBuilder(
          valueListenable: playerNotifier,
          builder: (context, Player player, child){
            return AnimatedPositioned(
              duration: const Duration(milliseconds: 100),
              left: player.position!.offset!.dx,
              top: player.position!.offset!.dy,
              child: RotatedBox(
                quarterTurns: player.position?.getRotation(),
                child: AnimatedBuilder(
                  animation: animation,
                  builder: (context, child) => CustomPaint(
                    foregroundPainter: PlayerPainter(player, animation.value),
                    child: child,
                  ),
                  child: Container(
                    constraints: BoxConstraints.tight(sizePerBox),
                    // child: Container(
                    //   margin: const EdgeInsets.all(4.5),
                    //   color: Colors.yellow,
                    // ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    ];
  }

  iniatiateProcess() async {
    generateList();
    setTimerProcess();
  }

  generateList() {
    List<List<int>> routes = Constant.grids;

    boxSize = RowColumn(routes.length, routes[0].length);

    // List<RowColumn> localRowCol = [
    //   RowColumn(5, 14),
    //   RowColumn(6, 13),
    //   RowColumn(6, 14),
    //   RowColumn(6, 15),
    //   RowColumn(6, 16),
    // ];

    barriers = [];

    setState(() => sizePerBox = Size.square(boxSize.calculateMaxSize(sizeBoxOuter)));

    playerNotifier.value.setSize(sizePerBox);

    BoxPos? playerPos;

    boxesNotifier.value = List.generate(boxSize.row, (index) {
      List<int> routerInner = routes.asMap().entries.firstWhere((element) => element.key == index).value;

      bool noRouteOuter = routerInner.where((element) => element > 0).isEmpty;

      return List.generate(boxSize.column, (columnIndex) {
        bool gotWall = false;
        bool gotOrange = false;
        bool gotPowerUp = false;

        if (!noRouteOuter) {
          late int boxValue;

          try{
            boxValue = routerInner.asMap().entries.firstWhere((element) => element.key == columnIndex).value;
          }catch (ex){
            print('aquiiiiiiii');
            boxValue = -1;
          }

          switch (boxValue) {
            case 0:
              gotWall = true;
              break;
            case 1:
              gotOrange = true;
              break;
            case 2:
              gotPowerUp = true;
              break;
            case 3:
              playerPos = BoxPos(index, columnIndex);
              break;
            default:
              if (boxValue >= 0) {
                enemiesNotifier.value[boxValue - 4].position!.setBoxPos(BoxPos(index, columnIndex), sizePerBox);
              }
            }
          } else {
            gotWall = true;
          }

          return Box(
            sizePerBox,
            uniqueIndex: index * boxSize.column + columnIndex,
            position: BoxPos(index, columnIndex, sizePerBox: sizePerBox),
            isWall: gotWall,
            gotOrange: gotOrange,
            powerUp: gotPowerUp,
          );
        },
      );
    });

    boxesNotifier.notifyListeners();
    playerNotifier.value.position!.setBoxPos(playerPos!,sizePerBox,);
    playerNotifier.value.position!.setOffsetDefault();

    playerNotifier.value.setBoxes (boxesNotifier.value.expand((element) => element).where((element) => !element.isWall).toList());

    for (var element in enemiesNotifier.value) {
      element.position!.calculateOffset(sizePerBox);
      element.position!.setOffsetDefault();
    }

    updateNotifier(enemyNotify: true, playerNotify: true);

    barriers = boxesNotifier.value.map((e) => e.where((element) => element.isWall).map((e) => Offset(e. position!.columnIndex.toDouble(),e.position!.rowIndex.toDouble())).toList()).toList();
  }

  void setTimerProcess() {
    List<Box> boxess = boxesNotifier.value.expand((element) => element).where((element) => !element.isWall).toList();

    timerPlayer = Timer.periodic(const Duration(milliseconds: 50), (timerEnemies) {
      if (boxesNotifier.value.isNotEmpty && playerNotifier.value.flagMove()) {
        if (playerNotifier.value.position?.offset != Offset.zero) {
          if ((playerNotifier.value.powerUp && timerEnemies.tick % 1 != 0) ||(!playerNotifier.value.powerUp && timerEnemies.tick % 2 != 0)) {
            return;
          }

          playerNotifier.value.move(boxess);

          updateNotifier(playerNotify: true);

          boxesNotifier.value.expand((element) => element).where((element) => element.checkoffsetInRange(
              playerNotifier.value.position!.offset!.translate(sizePerBox.shortestSide / 2, sizePerBox.shortestSide / 2),
            )).where((element) => element.gotOrange || element.powerUp).forEach((element) async {
            if (element.powerUp) playerGotPower();

            element.setEatOnPath();
            mainkey.currentState?.udpateScore(1);
            }
          );

          boxesNotifier.notifyListeners();
        }
      }
    });

    timerEnemies = Timer.periodic(const Duration(milliseconds: 50), (timerEnemies) {
      if (boxesNotifier.value.isNotEmpty) {
        List<Box> boxess = boxesNotifier.value.expand((element) => element).where((element) => !element.isWall).toList();

        enemiesNotifier.value = enemiesNotifier.value.asMap().entries.map((mapkey) {
          Enemy e = mapkey.value;

          if (e.position?.offset != Offset.zero && e.flagMove()) {

            bool hitPlayer = !e.playerPowerUp && !e.die && e.position!.positionInCenter(sizePerBox, playerNotifier.value.position!);

            if (hitPlayer && !playerNotifier.value.die) {
              playerNotifier.value.die = true;
              mapkey.value.setPause();
              updateNotifier(playerNotify: true);

              enemiesNotifier.value.forEach((element) => element.setPause());
              updateNotifier(enemyNotify: true);

              setupAnimationPlayer(durationPlaySecond: 500, end: 1, start: 0, reverse: false);
              return e;
            }

            bool eatByPlayer = e.playerPowerUp && e.position!.positionInCenter(sizePerBox, playerNotifier.value.position!);

            if (eatByPlayer && !playerNotifier.value.die){
              e.setReset(dieEvent: true);
              return e;
            } else if (e.returnBase && e.position!.arriveBase(sizePerBox)){
              e.setReset(setDefaultPos: false);
              Future.delayed(const Duration (seconds: 3)).then((value) => e.setPlay());
              return e;
            }

            if (!e.die && ((e.playerPowerUp && timerEnemies.tick % 3 != 0) || (!e.playerPowerUp && timerEnemies.tick % 2 != 0))){
              return e;
            }

            if (e.targetOffsets.isEmpty) {
              e.computedNewPoint(
                e.die ? e.position!.defaultPos! : playerNotifier.value.position!.offset!,
                boxess,
                barriers: barriers,
                boxSize: boxSize,
                size: sizePerBox,
                index: mapkey.key
              );
            } else if (e.completeArrive(sizePerBox)) {
              e.targetOffset = null;
              e.calculateNextTarget();
            } else {
              e.move(sizePerBox);
            }
          }

          return e;
        }).toList();

        updateNotifier(enemyNotify: true);
      }
    }); // Timer.periodic
  }

  startGame() {
    playerNotifier.value.setPlay();

    for (var element in enemiesNotifier.value) {
      element.setPlay();
      updateNotifier(enemyNotify: true, playerNotify: true);
    }
  }

  resetGame() {
    setupAnimationPlayer();
    playerNotifier.value.setReset();

    for (var element in enemiesNotifier.value) {
      element.setReset();
      updateNotifier(enemyNotify: true, playerNotify: true);
      generateList();
      setState(() {});
    }
  }


  void playerGotPower() {
    if (timerPower != null && timerPower!.isActive) {
      timerPower!.cancel();
      playerNotifier.value.gotPowerUp();

      for (var element in enemiesNotifier.value) {
        element.gotPowerUp();
      }

      updateNotifier(enemyNotify: true, playerNotify: true);
      timerPower = Timer(const Duration(seconds: 6), cancelPowerUp);
    }
  }

  void cancelPowerUp() {
    playerNotifier.value.cancelPowerUp();

    for (var element in enemiesNotifier.value) {
      element.cancelPowerUp();
    }

    updateNotifier (enemyNotify: true, playerNotify: true);
  }

  updateNotifier({bool playerNotify = false, bool enemyNotify = false}) {
    if (playerNotify) playerNotifier.notifyListeners();
    if (enemyNotify) enemiesNotifier.notifyListeners();
  }
}
