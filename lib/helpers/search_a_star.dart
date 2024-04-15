import 'package:flutter/material.dart';

class AStar {
  final int rows;
  final int columns;
  final Offset start;
  final Offset end;
  final List<Offset> barriers;
  final bool withDiagonal;
  final List<Tile> _doneList = List.empty(growable: true);
  final List<Tile> _waitList = List.empty(growable: true);
  late List<List<Tile>> grid;

  AStar({
    required this.rows,
    required this.columns,
    required this.start,
    required this.end,
    required this.barriers,
    this.withDiagonal = true,
  }) {
    grid = _createGrid(rows, columns, barriers);
  }

  List<Offset> findThePath({ValueChanged<List<Offset>>? doneList}) {
    _doneList.clear();
    _waitList.clear();

    if (barriers.contains(end)) {
      return List.empty(growable: true);
    }

    _addNeighbors(grid);

    Tile startTile = grid[start.dx.toInt()][start.dy.toInt()];
    Tile endTile = grid[end.dx.toInt()][end.dy.toInt()];

    Tile? winner = _getTileWinner(
      startTile,
      endTile,
    );

    List<Offset> path = [end];

    if (winner != null) {
      Tile? tileAux = winner.parent;
      for (int i = 0; i < winner.g - 1; i++) {
        path.add(tileAux!.position);
        tileAux = tileAux.parent;
      }
    }

    path.add(start);
    doneList?.call(_doneList.map((e) => e.position).toList());

    return path.reversed.toList();
  }

  List<List<Tile>> _createGrid(
    int rows,
    int columns,
    List<Offset> barriers,
  ) {
    List<List<Tile>> grid = List.empty(growable: true);

    List.generate(columns, (x) {
      List<Tile> rowList = List.empty(growable: true);

      List.generate(rows, (y) {
        final offset = Offset(x.toDouble(), y.toDouble());

        bool isBarrier =
            barriers.where((element) => element == offset).isNotEmpty;
        rowList.add(
          Tile(
            offset,
            List.empty(growable: true),
            isBarrier: isBarrier,
          ),
        );
      });

      grid.add(rowList);
    });

    return grid;
  }

  void _addNeighbors(List<List<Tile>> grid) {
    for (var _ in grid) {
      for (var element in _) {
        int x = element.position.dx.toInt();
        int y = element.position.dy.toInt();

        if (y > 0) {
          final t = grid[x][y - 1];
          if (!t.isBarrier) {
            element.neighbors.add(t);
          }
        }

        if (y < (grid.first.length - 1)) {
          final t = grid[x][y + 1];
          if (!t.isBarrier) {
            element.neighbors.add(t);
          }
        }

        if (x > 0) {
          final t = grid[x - 1][y];
          if (!t.isBarrier) {
            element.neighbors.add(t);
          }
        }

        if (x < (grid.length - 1)) {
          final t = grid[x + 1][y];
          if (!t.isBarrier) {
            element.neighbors.add(t);
          }
        }

        if (withDiagonal) {
          if (y > 0 && x > 0) {
            final top = grid[x][y - 1];
            final left = grid[x - 1][y];
            final t = grid[x - 1][y - 1];
            if (!t.isBarrier && !left.isBarrier && !top.isBarrier) {
              element.neighbors.add(t);
            }
          }

          if (y > 0 && x < (grid.length - 1)) {
            final top = grid[x][y - 1];
            final right = grid[x + 1][y];
            final t = grid[x + 1][y - 1];
            if (!t.isBarrier && !top.isBarrier && !right.isBarrier) {
              element.neighbors.add(t);
            }
          }

          if (x > 0 && y < (grid.first.length - 1)) {
            final bottom = grid[x][y + 1];
            final left = grid[x - 1][y];
            final t = grid[x - 1][y + 1];
            if (!t.isBarrier && !bottom.isBarrier && !left.isBarrier) {
              element.neighbors.add(t);
            }
          }

          if (x < (grid.length - 1) && y < (grid.first.length - 1)) {
            final bottom = grid[x][y + 1];
            final right = grid[x + 1][y];
            final t = grid[x + 1][y + 1];
            if (!t.isBarrier && !bottom.isBarrier && !right.isBarrier) {
              element.neighbors.add(t);
            }
          }
        }
      }
    }
  }

  Tile? _getTileWinner(Tile current, Tile end) {
    if (current == end) return current;
    _waitList.remove(current);

    for (var element in current.neighbors) {
      _analiseDistance(element, end, parent: current);
    }

    _doneList.add(current);

    _waitList.addAll(
        current.neighbors.where((element) => !_doneList.contains(element)));

    _waitList.sort((a, b) => a.f.compareTo(b.f));

    for (final element in _waitList.toList()) {
      if (!_doneList.contains(element)) {
        final result = _getTileWinner(element, end);
        if (result != null) {
          return result;
        }
      }
    }

    return null;
  }

  void _analiseDistance(Tile current, Tile end, {Tile? parent}) {
    if (current.parent == null) {
      current.parent = parent;
      current.g = (current.parent?.g ?? 0) + 1;

      current.h = _distance(current, end);
    }
  }

  int _distance(Tile tile1, Tile tile2) {
    int distX = (tile1.position.dx.toInt() - tile2.position.dx.toInt()).abs();
    int distY = (tile1.position.dy.toInt() - tile2.position.dy.toInt()).abs();
    return distX + distY;
  }
}

class Tile {
  final Offset position;
  Tile? parent;
  final List<Tile> neighbors;
  final bool isBarrier;
  int g = 0;
  int h = 0;

  int get f => g + h;

  Tile(this.position, this.neighbors, {this.parent, this.isBarrier = false});
}
