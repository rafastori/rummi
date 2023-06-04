import 'package:flutter/material.dart';

class Tile {
  final int number;
  final String colorName;
  final Color color;

  Tile(this.number, this.colorName) : color = getColorFromName(colorName);

  static Color getColorFromName(String colorName) {
    switch (colorName) {
      case 'preto':
        return Colors.black;
      case 'laranja':
        return Colors.orange;
      case 'azul':
        return Colors.blue;
      case 'vermelho':
        return Colors.red;
      default:
        return Colors.black;
    }
  }

  @override
  String toString() {
    return '$number ($colorName)';
  }
}

void main() => runApp(RummikubApp());

class RummikubApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Rummikub',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: RummikubHomePage(),
    );
  }
}

class RummikubHomePage extends StatefulWidget {
  @override
  _RummikubHomePageState createState() => _RummikubHomePageState();
}

class _RummikubHomePageState extends State<RummikubHomePage> {
  final List<String> colorNames = ['preto', 'laranja', 'azul', 'vermelho'];
  List<Tile> tiles = [];
  List<Tile> player1Tiles = [];
  List<Tile> player2Tiles = [];
  List<Tile> selectedTiles = [];
  bool player1Turn = true;

  @override
  void initState() {
    super.initState();
    generateTiles();
    distributeTiles();
  }

  void generateTiles() {
    for (var colorName in colorNames) {
      for (var i = 1; i <= 13; i++) {
        tiles.add(Tile(i, colorName));
      }
    }
    tiles.addAll([
      Tile(0, 'coringa'),
      Tile(0, 'coringa')
    ]); // adicionando as peças coringas
    tiles.shuffle();
  }

  void distributeTiles() {
    player1Tiles = tiles.sublist(0, 14);
    player2Tiles = tiles.sublist(14, 28);
    tiles = tiles.sublist(28);
  }

  void play() {
    if (isValidPlay()) {
      updatePlayers();
      swapPlayersTurn();
    } else {
      print('Jogada inválida');
      addTileToCurrentPlayer();
    }
  }

  bool isValidPlay() {
    if (selectedTiles.length < 3) {
      return false;
    }

    Color firstColor = selectedTiles.first.color;
    bool sameColor = selectedTiles.every((tile) => tile.color == firstColor);

    if (!sameColor) {
      bool hasWildcard = selectedTiles.any((tile) => tile.number == 0);
      if (!hasWildcard) {
        return false;
      }
    }

    List<int> numbers = selectedTiles.map((tile) => tile.number).toList();
    numbers.sort();

    for (int i = 1; i < numbers.length; i++) {
      if (numbers[i] != numbers[i - 1] + 1) {
        bool hasWildcard = selectedTiles.any((tile) => tile.number == 0);
        if (!hasWildcard) {
          return false;
        }
      }
    }

    return true;
  }

  void updatePlayers() {
    List<Tile> currentPlayerTiles = player1Turn ? player1Tiles : player2Tiles;

    for (Tile tile in selectedTiles) {
      currentPlayerTiles.remove(tile);
    }

    setState(() {
      if (player1Turn) {
        player1Tiles = currentPlayerTiles;
      } else {
        player2Tiles = currentPlayerTiles;
      }
    });
  }

  void swapPlayersTurn() {
    setState(() {
      player1Turn = !player1Turn;
    });
  }

  void addTileToCurrentPlayer() {
    if (tiles.isEmpty) {
      print('Não há mais peças disponíveis para adicionar');
      return;
    }

    Tile newTile = tiles.removeLast();

    setState(() {
      if (player1Turn) {
        player1Tiles.add(newTile);
      } else {
        player2Tiles.add(newTile);
      }
    });
  }

  void restartGame() {
    tiles.addAll(player1Tiles);
    tiles.addAll(player2Tiles);
    generateTiles();
    distributeTiles();
    setState(() {
      player1Turn = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Rummikub'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Jogador Atual: ${player1Turn ? 'Jogador 1' : 'Jogador 2'}'),
            ElevatedButton(
              child: Text('Jogar'),
              onPressed: play,
            ),
            SizedBox(height: 16),
            Wrap(
              spacing: 8.0,
              runSpacing: 8.0,
              children: selectedTiles.map((tile) {
                return Container(
                  decoration: BoxDecoration(
                    color: tile.color,
                    border: Border.all(
                      color: Colors.black,
                      width: 2.0,
                    ),
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  width: 50,
                  height: 50,
                  child: Center(
                    child: Text(
                      tile.number.toString(),
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18.0,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
            SizedBox(height: 16),
            ElevatedButton(
              child: Text('Reiniciar Jogo'),
              onPressed: restartGame,
            ),
            SizedBox(height: 16),
            Expanded(
              child: GridView.count(
                crossAxisCount: 4,
                children: List.generate(
                  (player1Turn ? player1Tiles : player2Tiles).length,
                  (index) {
                    Tile tile =
                        (player1Turn ? player1Tiles : player2Tiles)[index];
                    bool selected = selectedTiles.contains(tile);
                    return Container(
                      decoration: BoxDecoration(
                        color: tile.color,
                        border: selected
                            ? Border.all(
                                color: Colors.black,
                                width: 2.0,
                              )
                            : null,
                        borderRadius:
                            selected ? BorderRadius.circular(10.0) : null,
                      ),
                      child: ListTile(
                        title: Text(
                          tile.number.toString(),
                          style: TextStyle(
                            color: Colors.white,
                          ),
                        ),
                        onTap: () {
                          setState(() {
                            if (selected) {
                              selectedTiles.remove(tile);
                            } else {
                              selectedTiles.add(tile);
                            }
                          });
                        },
                      ),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
