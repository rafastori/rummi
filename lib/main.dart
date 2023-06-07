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
  bool player1FirstPlayDone = false;
  bool player2FirstPlayDone = false;
  final List<String> colorNames = ['preto', 'laranja', 'azul', 'vermelho'];
  List<Tile> tiles = [];
  List<Tile> player1Tiles = [];
  List<Tile> player2Tiles = [];
  List<Tile> selectedTiles = [];
  List<List<Tile>> tableTiles = [];
  Tile?
      selectedPlayerTile; // Adicione um campo para rastrear a peça selecionada do rack do jogador
  Tile?
      selectedTableTile; // Adicione um campo para rastrear a peça selecionada da mesa
  List<Tile>? selectedTableSequence;
  bool player1Turn = true;
  List<Tile> selectedSequence = [];

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

// Método buildTable para construir as peças na mesa
  Widget buildTable() {
    return ListView.builder(
      itemCount: tableTiles.length,
      itemBuilder: (context, index) {
        List<Widget> sequenceWidgets = tableTiles[index].map((tile) {
          return GestureDetector(
            onTap: () {
              handleTileTap(tile);
            },
            child: Text(tile.toString()),
          );
        }).toList();
        return Row(
          children: sequenceWidgets,
        );
      },
    );
  }

  // Método handleTileTap para tratar o toque em uma peça
  void handleTileTap(Tile tile, {bool isPlayerTile = false}) {
    if (isPlayerTile) {
      selectedPlayerTile = tile;
    } else {
      if (selectedPlayerTile != null) {
        // Tenta inserir na sequência
        for (List<Tile> sequence in tableTiles) {
          if (sequence.contains(tile)) {
            selectedTableSequence = sequence;
            selectedSequence = sequence; // Atualize a variável selectedSequence
            int index = sequence.indexOf(tile);
            if (isValidPlay2(selectedPlayerTile!, sequence, index)) {
              sequence.insert(index, selectedPlayerTile!);
              (player1Turn ? player1Tiles : player2Tiles)
                  .remove(selectedPlayerTile);
              selectedPlayerTile = null;
            } else {
              print('Jogada inválida em handleTileTap');
            }
            break;
          }
        }
      }
    }
    // Chame setState para atualizar a UI
    setState(() {});
  }

  void play() {
    bool isFirstPlayDone =
        player1Turn ? player1FirstPlayDone : player2FirstPlayDone;

    // Para o primeiro turno do jogador, a jogada é válida se a peça selecionada pode ser inserida na sequência selecionada
    // Para os turnos subsequentes, a jogada é válida se a peça selecionada pode ser inserida em qualquer sequência na mesa
    if (selectedPlayerTile != null && selectedTableSequence != null) {
      if (isFirstPlayDone) {
        if (isValidPlay2(selectedPlayerTile!, selectedTableSequence!,
            selectedTableSequence!.indexOf(selectedPlayerTile!))) {
          updatePlayers();
          swapPlayersTurn();
        } else {
          addTileToCurrentPlayer();
          print('Jogada inválida');
          swapPlayersTurn(); // Adicione a chamada para swapPlayersTurn() aqui
        }
      } else {
        if (isValidPlay()) {
          updatePlayers();
          swapPlayersTurn();
        } else {
          addTileToCurrentPlayer();
          print('Jogada inválida');
          swapPlayersTurn(); // Adicione a chamada para swapPlayersTurn() aqui
        }
      }
    } else {
      addTileToCurrentPlayer();
      print('Jogada inválida');
      swapPlayersTurn(); // Adicione a chamada para swapPlayersTurn() aqui
    }

    // Redefina a peça e a sequência selecionadas após cada turno
    selectedPlayerTile = null;
    selectedTableSequence = null;
  }

  bool canInsertInSequenceAt(Tile tile, List<Tile> sequence, int index) {
    // Verificar se a peça pode ser inserida na posição especificada na sequência

    // Caso seja a primeira posição da sequência
    if (index == 0) {
      // A peça deve ser um número menor que a primeira peça na sequência ou um coringa
      if (!(tile.number == sequence[0].number - 1 || tile.number == 0)) {
        print(
            "Condition 5: First position of sequence, tile number is not one less than the first sequence number or wildcard");
        return false;
      }
    }

    // Caso seja a última posição da sequência
    if (index == sequence.length) {
      // A peça deve ser um número maior que a última peça na sequência ou um coringa
      if (!(tile.number == sequence[sequence.length - 1].number + 1 ||
          tile.number == 0)) {
        print(
            "Condition 6: Last position of sequence, tile number is not one more than the last sequence number or wildcard");
        return false;
      }
    }

    // Caso seja uma posição do meio da sequência
    // A peça deve ser um número entre as peças adjacentes na sequência ou um coringa
    if (!((tile.number == sequence[index - 1].number + 1 &&
            tile.number == sequence[index].number - 1) ||
        tile.number == 0)) {
      print(
          "Condition 7: Middle position of sequence, tile number is not between adjacent sequence numbers or wildcard");
      return false;
    }

    return true;
  }

  bool isValidPlay2(Tile tile, List<Tile> sequence, int index) {
    bool result = canInsertInSequenceAt(tile, sequence, index);

    if (!result) {
      print(
          "Condition 4: Tile can't be inserted at specified sequence position");
    }

    return result;
  }

  bool isValidPlay() {
    print("isValidPlay called");

    if (selectedTiles.length < 3) {
      print("Condition 1: Less than 3 tiles selected");
      return false;
    }

    Color firstColor = selectedTiles.first.color;
    bool sameColor = selectedTiles.every((tile) => tile.color == firstColor);

    if (!sameColor) {
      bool hasWildcard = selectedTiles.any((tile) => tile.number == 0);
      if (!hasWildcard) {
        print(
            "Condition 2: Tiles are not same color and no wildcard is present");
        return false;
      }
    }

    List<int> numbers = selectedTiles.map((tile) => tile.number).toList();
    numbers.sort();

    for (int i = 1; i < numbers.length; i++) {
      if (numbers[i] != numbers[i - 1] + 1) {
        bool hasWildcard = selectedTiles.any((tile) => tile.number == 0);
        if (!hasWildcard) {
          print(
              "Condition 3: Tiles numbers are not in sequence and no wildcard is present");
          return false;
        }
      }
    }

    return true;
  }

  void updatePlayers() {
    bool isFirstPlayDone =
        player1Turn ? player1FirstPlayDone : player2FirstPlayDone;

    if (!isFirstPlayDone) {
      if (player1Turn) {
        player1FirstPlayDone = true;
      } else {
        player2FirstPlayDone = true;
      }
    }

    List<Tile> currentPlayerTiles = player1Turn ? player1Tiles : player2Tiles;
    for (Tile tile in selectedTiles) {
      currentPlayerTiles.remove(tile);
    }

    // Se for a primeira jogada do jogador, adicione as peças selecionadas como uma nova sequência na mesa
    if (!isFirstPlayDone) {
      tableTiles.add(selectedTiles);
    } else {
      // Para jogadas subsequentes, as peças selecionadas serão adicionadas a uma sequência existente na mesa,
      // a validação para isto será feita em isValidPlay2 e canInsertInSequenceAt,
      // por isso não precisamos verificar aqui novamente.
      for (List<Tile> sequence in tableTiles) {
        if (sequence == selectedSequence) {
          sequence.addAll(selectedTiles);
          break;
        }
      }
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
    // Remover todas as sequências da mesa
    tableTiles.clear();

    // Redefinir as variáveis relacionadas às peças selecionadas
    selectedTiles.clear();
    selectedSequence.clear();
    selectedPlayerTile = null;
    selectedTableSequence = null;

    // Redefinir as variáveis relacionadas ao primeiro turno
    player1FirstPlayDone = false;
    player2FirstPlayDone = false;

    // Redistribuir as peças para os jogadores
    distributeTiles();

    // Reiniciar o jogo com o primeiro jogador
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
            // Widget buildTable adicionado aqui para exibir as peças na mesa
            // Widget buildTable agora está envolvido com Expanded
            Expanded(
              child: buildTable(),
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
