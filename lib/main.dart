import 'package:flutter/material.dart';

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
  List<int> tiles = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10];
  List<int> player1Tiles = [];
  List<int> player2Tiles = [];

  @override
  void initState() {
    super.initState();
    // Distribuir as peças para os jogadores
    distributeTiles();
  }

  void distributeTiles() {
    // Embaralhar as peças
    tiles.shuffle();

    // Distribuir 10 peças para cada jogador
    player1Tiles = tiles.sublist(0, 10);
    player2Tiles = tiles.sublist(0, 10);
  }

  void play() {
    // Exemplo de lógica de jogada:

    // Verificar se a jogada é válida
    if (isValidPlay()) {
      // Atualizar os jogadores com a jogada
      updatePlayers();

      // Realizar outras ações relacionadas à jogada, como atualizar o tabuleiro, verificar vencedor, etc.
      // ...

      // Exemplo: Trocar a vez dos jogadores
      swapPlayersTurn();
    } else {
      // A jogada não é válida, exibir mensagem de erro ou tomar ação apropriada
      // ...
    }
  }

  bool isValidPlay() {
    // Obtenha as peças selecionadas pelo jogador
    List<String> selectedTiles =
        []; // Substitua pela lógica de obtenção das peças selecionadas

    // Verifique se a quantidade de peças selecionadas é válida
    if (selectedTiles.length < 3 || selectedTiles.length > 4) {
      return false;
    }

    // Verifique se todas as peças selecionadas são do mesmo número
    String firstTile = selectedTiles[0];
    for (int i = 1; i < selectedTiles.length; i++) {
      if (selectedTiles[i] != firstTile) {
        return false;
      }
    }

    // A jogada é válida se atender a todas as condições
    return true;
  }

  void updatePlayers() {
    // Lógica para atualizar os jogadores após a jogada
    // ...
  }

  void swapPlayersTurn() {
    // Lógica para trocar a vez dos jogadores
    // ...
  }

  void restartGame() {
    // Reiniciar o jogo
    distributeTiles();
    setState(() {});
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
            Text(
                'Player 1: ${player1Tiles.map((tile) => tile.toString()).join(', ')}'),
            SizedBox(height: 16),
            Text(
                'Player 2: ${player2Tiles.map((tile) => tile.toString()).join(', ')}'),
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
          ],
        ),
      ),
    );
  }
}
