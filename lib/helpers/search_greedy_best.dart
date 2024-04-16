import 'package:flutter/cupertino.dart';

class GreedyBestFirstSearch {
  final int rows;
  final int columns;
  final Offset start;
  final Offset end;
  final List<Offset> barriers;
  final List<Tile> _doneList = [];
  final List<Tile> _waitList = [];

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

  List<Offset> findThePath({ValueChanged<List<Offset>>? doneList}) {
    _doneList.clear();
    _waitList.clear();

    if (barriers.contains(end)) {
      return [];
    }

    //Adiciona vizinhos
    _addNeighbors(grid);

    Tile startTile = grid[start.dx.toInt()][start.dy.toInt()];
    Tile endTile = grid[end.dx.toInt()][end.dy.toInt()];

    Tile? winner = _getTileWinner(startTile, endTile);

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

    return path.reversed.toList();
  }

  List<List<Tile>> _createGrid(int rows, int columns, List<Offset> barriers) {
    return List.generate(columns, (x) {
      return List.generate(rows, (y) {
        final offset = Offset(x.toDouble(), y.toDouble());
        return Tile(
          offset,
          [],
          isBarrier: barriers.contains(offset),
        );
      });
    });
  }

  void _addNeighbors(List<List<Tile>> grid) {
    for (var column in grid) {
      for (var tile in column) {
        final x = grid.indexOf(column);
        final y = column.indexOf(tile);

        if (y > 0) _addNeighbor(tile, grid[x][y - 1]);
        if (y < column.length - 1) _addNeighbor(tile, grid[x][y + 1]);
        if (x > 0) _addNeighbor(tile, grid[x - 1][y]);
        if (x < grid.length - 1) _addNeighbor(tile, grid[x + 1][y]);
      }
    }
  }

  void _addNeighbor(Tile tile, Tile neighbor) {
    if (!neighbor.isBarrier) tile.neighbors.add(neighbor);
  }

  Tile? _getTileWinner(Tile start, Tile end) {
    while (_waitList.isNotEmpty) {
      _waitList.sort((a, b) => a.h.compareTo(b.h));

      final current = _waitList.removeAt(0);

      if (current == end) return current;

      for (var neighbor in current.neighbors) {
        if (neighbor.parent == null) {
          neighbor.parent = current;
          neighbor.h = _distance(neighbor, end);
        }
        if (!_doneList.contains(neighbor)) {
          _waitList.add(neighbor);
        }
      }

      _doneList.add(current);
    }

    return null;
  }

  int _distance(Tile tile1, Tile tile2) {
    return (tile1.position.dx.toInt() - tile2.position.dx.toInt()).abs() +
        (tile1.position.dy.toInt() - tile2.position.dy.toInt()).abs();
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
