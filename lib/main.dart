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
    }
  }

  bool isValidPlay() {
    if (selectedTiles.length < 3) {
      return false;
    }

    // Implementação simplificada
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
        title: Text('Rummikub3'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Jogador Atual: ${player1Turn ? 'Jogador 1' : 'Jogador 2'}'),
            SizedBox(height: 16),
            Text(
                'Peças do Jogador 1: ${player1Tiles.map((tile) => tile.toString()).join(', ')}'),
            SizedBox(height: 16),
            Text(
                'Peças do Jogador 2: ${player2Tiles.map((tile) => tile.toString()).join(', ')}'),
            SizedBox(height: 16),
            ElevatedButton(
              child: Text('Jogar'),
              onPressed: play,
            ),
            SizedBox(height: 16),
            ElevatedButton(
              child: Text('Reiniciar Jogo'),
              onPressed: restartGame,
            ),
            SizedBox(height: 16),
            Expanded(
              child: GridView.count(
                crossAxisCount: 4, // Define o número de colunas desejado
                children: List.generate(
                  (player1Turn ? player1Tiles : player2Tiles).length,
                  (index) {
                    Tile tile =
                        (player1Turn ? player1Tiles : player2Tiles)[index];
                    bool selected = selectedTiles.contains(tile);
                    return Container(
                      color: tile.color,
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
