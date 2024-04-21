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

  //Aqui é a função principal
  List<Offset> findThePath({ValueChanged<List<Offset>>? doneList}) {
    _doneList.clear(); // Lista Fechada
    _waitList.clear(); //Lista Aberta

    //Tratamento caso as barreias contenham o final
    if (barriers.contains(end)) {
      return List.empty(growable: true);
    }

    //Aqui chama a função que adiciona os vizinhos ao GRID
    _addNeighbors(grid);

    //Adicionado o início, posição em que se contra
    Tile startTile = grid[start.dx.toInt()][start.dy.toInt()];

    //Adicionado posição final objetivo
    Tile endTile = grid[end.dx.toInt()][end.dy.toInt()];

    //Verificação do vencedor
    Tile? winner = _getTileWinner(
      startTile,
      endTile,
    );

    //Caminho
    List<Offset> path = [end];

    //Caso o vencedor seja diferente de null
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

  //Aqui Gera o grid
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

        //Caso seja barreira
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

  //Função que adiciona os vizinhos no nó atual
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
    //  Current -> Representa o nó atual
    //  End     -> Representa o nó de destino

    //Se o nó atual é o mesmo que o nó final, retorna o atual
    if (current == end) return current;

    //Remove da lista aberta o nó atual
    _waitList.remove(current);

    //Para cada elemento vizinhos do nó atual
    for (var element in current.neighbors) {
      //Analisa a distancia
      _analiseDistance(element, end, parent: current);
    }

    //Aqui é Adicionado nó atual na lista fechada
    _doneList.add(current);

    //Aqui Adiciona na lista aberta todos os vizinhos do nó atual que não se encontram na lista fechada
    _waitList.addAll(
        current.neighbors.where((element) => !_doneList.contains(element)));

    //Aqui reordena os elementos da lista aberta de acordo com o custo
    _waitList.sort((a, b) => a.f.compareTo(b.f));

    //Aqui percorre todos os elementos da lista aberta
    for (final element in _waitList.toList()) {
      //Verifica se o mesmo elemento não está na lista fechada

      if (!_doneList.contains(element)) {
        //Chama novamente a chamada de forma recursiva, passando o elemento atual e o final
        final result = _getTileWinner(element, end);

        //Caso tenha econtrado, retorna o resultado
        if (result != null) {
          return result;
        }
      }
    }

    //Retorna null caso não tenha encontrado
    return null;
  }

  //Função que analisa a distancia
  void _analiseDistance(Tile current, Tile end, {Tile? parent}) {
    if (current.parent == null) {
      current.parent = parent;

      //O valor atual de g ou 0 + 1
      current.g = (current.parent?.g ?? 0) + 1;

      //Valor do custo restante
      current.h = _distance(current, end);
    }
  }

  //Calculo do Valor absoluto da distancia entre os dois elementos, tile1 e tile2
  int _distance(Tile tile1, Tile tile2) {
    int distX = (tile1.position.dx.toInt() - tile2.position.dx.toInt()).abs();
    int distY = (tile1.position.dy.toInt() - tile2.position.dy.toInt()).abs();
    return distX + distY;
  }
}

//Classe do elemento Tile
class Tile {
  final Offset position;
  Tile? parent;
  final List<Tile> neighbors;
  final bool isBarrier;

  // g -> Valor acumulado do custo até o momento
  // h -> Valor do custo restante
  int g = 0;
  int h = 0;

  //Função de caminho mais curto f(n) = g(n) + h(n)
  int get f => g + h;

  Tile(this.position, this.neighbors, {this.parent, this.isBarrier = false});
}
