import 'package:flutter/cupertino.dart';

class GreedyBestFirstSearch {
  final int rows;
  final int columns;
  final Offset start;
  final Offset end;
  final List<Offset> barriers;
  final List<Tile> _doneList = List.empty(growable: true);
  final List<Tile> _waitList = List.empty(growable: true);

  late List<List<Tile>> grid;

  GreedyBestFirstSearch({
    required this.rows,
    required this.columns,
    required this.start,
    required this.end,
    required this.barriers,
  }) {
    grid = _createGrid(rows, columns, barriers);
  }

  Iterable<Offset> findThePath({ValueChanged<List<Offset>>? doneList}) {
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
      while (tileAux != null) {
        path.add(tileAux.position);
        tileAux = tileAux.parent;
      }
    }

    path.add(start);
    doneList?.call(_doneList.map((e) => e.position).toList());

    return path.reversed;
  }

  List<List<Tile>> _createGrid(int rows, int columns, List<Offset> barriers,) {
    List<List<Tile>> grid = List.empty(growable: true);

    List.generate(columns, (x) {
      List<Tile> rowList = List.empty(growable: true);
      List.generate(rows, (y) {
        final offset = Offset(x.toDouble(), y.toDouble());

        bool isBarrier = barriers.where((element) => element == offset).isNotEmpty;
        rowList.add(Tile(offset, List.empty(growable: true), isBarrier: isBarrier,),);
      });
      grid.add(rowList);
    });

    return grid;
  }

  void _addNeighbors(List<List<Tile>> grid) {
    grid.forEach((_) {
      _.forEach((element) {
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
      });
    });
  }

  Tile? _getTileWinner(Tile current, Tile end) {
    if (current == end) return current;
    _waitList.remove(current);

    current.neighbors.forEach((element) => _analiseDistance(element, end, parent: current));

    _doneList.add(current);

    _waitList.addAll(current.neighbors.where((element) => !_doneList.contains(element)));

    _waitList.sort((a, b) => _distance(a, end).compareTo(_distance(b, end)));

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
  int h = 0;

  Tile(this.position, this.neighbors, {this.parent, this.isBarrier = false});
}
