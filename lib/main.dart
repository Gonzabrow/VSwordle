import 'package:flutter/material.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'VSwordle',
      debugShowCheckedModeBanner: false, // これなに？
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: GamePage(), 
    );
  }
}

class GamePage extends StatefulWidget {
  const GamePage({super.key});

  @override
  State<GamePage> createState() => _GamePageState();
}

class _GamePageState extends State<GamePage> {
  List<String> guesses = []; // 今までに入力された単語のリスト
  String currentGuess = '';  // 現在入力中の単語

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            SizedBox(height: 50),
            _buildWordGrid(),
            Spacer(),
            _buildKeyboard(),
          ],
        ),
      )
    );
  }

  Widget _buildWordGrid() {
    final totalRows = 6;
    final wordLength = 5;

    return Column(
      children: List.generate(totalRows, (rowIndex) {
        String letter;
        if (rowIndex < guesses.length) {
          letter = guesses[rowIndex];
        } else if (rowIndex == guesses.length) {
          letter = currentGuess.padRight(wordLength);
        } else {
          letter = ''.padRight(wordLength);
        }

        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: letter.split('').map((char) {
            return Container(
              margin: const EdgeInsets.all(4),
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey),
              ),
              alignment: Alignment.center,
              child: Text(
                char.toUpperCase(),
                style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
            );
          }).toList(),
        );
      }),
    );
  }

  Widget _buildKeyboard() {
    final rows = [
      'QWERTYUIOP',
      'ASDFGHJKL',
      'ZXCVBNM',
    ];

    return Column(
      children: [
        for (int i = 0; i < 2; i++)
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: rows[i].split('').map(_buildKeyButton).toList(),
          ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildSpecialKey('ENTER', _onEnter, flex: 1.5),
            ...rows[2].split('').map(_buildKeyButton),
            _buildSpecialKey('Delete', _onBackspace, icon: true, flex: 1.5),
          ],
        ),
      ],
    );
  }

  Widget _buildKeyButton(String char) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 3, vertical: 4),
      child: SizedBox(
        width: 25,
        height: 48,
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(6),
            ),
            padding: EdgeInsets.zero, // 必要なら padding を削る
          ),
          onPressed: () => _onKeyPress(char),
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              char,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              softWrap: false,
            ),
          ),
        )
      ),
    );
  }

Widget _buildSpecialKey(String label, VoidCallback onPressed,
    {bool icon = false, double flex = 1}) {
  return Padding(
    padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
    child: SizedBox(
      width: 40.0,
      height: 48,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(4),
          ),
          padding: EdgeInsets.symmetric(horizontal: 3),
        ),
        onPressed: onPressed,
        child: FittedBox(
          fit: BoxFit.scaleDown,
          child: icon ? const Icon(Icons.backspace) : Text(
            label, 
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold), 
            softWrap: false
          ),
        ),
      ),
    ),
  );
}

  void _onKeyPress(String char) {
    if (currentGuess.length < 5) {
      setState(() {
        currentGuess += char.toLowerCase();
      });
    }
  }

  void _onEnter() {
    if (currentGuess.length == 5) {
      setState(() {
        guesses.add(currentGuess);
        currentGuess = '';
      });
    }
  }

  void _onBackspace() {
    if (currentGuess.isNotEmpty) {
      setState(() {
        currentGuess = currentGuess.substring(0, currentGuess.length - 1);
      });
    }
  }

}