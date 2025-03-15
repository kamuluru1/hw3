import 'dart:async';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Card Matching Game',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const CardMatchingGame(),
    );
  }
}

class MemoryCard {
  final int id;
  bool isFaceUp;
  bool isMatched;

  MemoryCard({
    required this.id,
    this.isFaceUp = false,
    this.isMatched = false,
  });
}

class CardMatchingGame extends StatefulWidget {
  const CardMatchingGame({Key? key}) : super(key: key);

  @override
  State<CardMatchingGame> createState() => _CardMatchingGameState();
}

class _CardMatchingGameState extends State<CardMatchingGame> {
  final int _numberOfPairs = 6;

  late List<MemoryCard> _cards;
  int _score = 0;
  int _timeElapsed = 0;
  Timer? _timer;

  int? _previousFlippedIndex;

  bool _isGameOver = false;

  @override
  void initState() {
    super.initState();
    _startNewGame();
  }

  void _startNewGame() {
    _cards = _generateShuffledCards(_numberOfPairs);
    _score = 0;
    _timeElapsed = 0;
    _isGameOver = false;
    _previousFlippedIndex = null;

    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        _timeElapsed++;
      });
    });
  }

  List<MemoryCard> _generateShuffledCards(int numberOfPairs) {
    List<MemoryCard> cards = [];
    for (int i = 0; i < numberOfPairs; i++) {
      cards.add(MemoryCard(id: i));
      cards.add(MemoryCard(id: i));
    }
    cards.shuffle();
    return cards;
  }

  void _onCardTapped(int index) {
    if (_cards[index].isFaceUp || _cards[index].isMatched || _isGameOver) {
      return;
    }

    setState(() {
      _cards[index].isFaceUp = true;

      if (_previousFlippedIndex == null) {
        _previousFlippedIndex = index;
      } else {
        final int previousIndex = _previousFlippedIndex!;
        if (_cards[previousIndex].id == _cards[index].id) {
          // It's a match
          _cards[previousIndex].isMatched = true;
          _cards[index].isMatched = true;
          _score += 10;
          _previousFlippedIndex = null;

          if (_checkAllMatched()) {
            _onGameOver();
          }
        } else {
          _score -= 2;
          Future.delayed(const Duration(seconds: 1), () {
            setState(() {
              _cards[previousIndex].isFaceUp = false;
              _cards[index].isFaceUp = false;
            });
          });
          _previousFlippedIndex = null;
        }
      }
    });
  }

  bool _checkAllMatched() {
    for (var card in _cards) {
      if (!card.isMatched) return false;
    }
    return true;
  }

  void _onGameOver() {
    setState(() {
      _isGameOver = true;
    });
    _timer?.cancel();
    _showVictoryDialog();
  }

  void _showVictoryDialog() {
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Victory!'),
          content: Text(
            'You matched all pairs in $_timeElapsed seconds\n'
                'Your score: $_score',
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Play Again'),
              onPressed: () {
                Navigator.of(context).pop();
                _startNewGame();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Card Matching Game'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Text('Time: $_timeElapsed s',
                    style: const TextStyle(fontSize: 18)),
                Text('Score: $_score', style: const TextStyle(fontSize: 18)),
              ],
            ),
          ),
          Expanded(
            child: GridView.builder(
              itemCount: _cards.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 4,
                mainAxisSpacing: 8,
                crossAxisSpacing: 8,
              ),
              padding: const EdgeInsets.all(8),
              itemBuilder: (context, index) {
                final card = _cards[index];
                return GestureDetector(
                  onTap: () => _onCardTapped(index),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    decoration: BoxDecoration(
                      color: card.isMatched
                          ? Colors.green
                          : (card.isFaceUp
                          ? Colors.orange
                          : Colors.blueAccent),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Center(
                      child: card.isFaceUp || card.isMatched
                          ? Text(
                        'Card ${card.id}',
                        style: const TextStyle(
                          fontSize: 20,
                          color: Colors.white,
                        ),
                      )
                          : const Text(
                        '?',
                        style: TextStyle(
                          fontSize: 24,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}


