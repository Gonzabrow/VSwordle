import 'package:flutter/material.dart';
import 'package:vs_wordle/const/color.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatefulWidget {
  const MainApp({super.key});

  @override
  State<MainApp> createState() => _MyAppState();
}

class _MyAppState extends State<MainApp> {
  ThemeMode _themeMode = ThemeMode.system;
  Key _appKey = UniqueKey();

  void _toggleThemeMode() {
    setState(() {
      _themeMode = _themeMode == ThemeMode.light
          ? ThemeMode.dark
          : ThemeMode.light;
      _appKey = UniqueKey();
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'VSwordle',
      debugShowCheckedModeBanner: false, // これなに？

      key: _appKey,
      theme: ThemeData.light().copyWith(
        extensions: const [AppColors.light],
        splashFactory: NoSplash.splashFactory,
      ),
      darkTheme: ThemeData.dark().copyWith(
        extensions: const [AppColors.dark],
        splashFactory: NoSplash.splashFactory,
      ),
      themeMode: _themeMode,
      home: GamePage(onToggleTheme: _toggleThemeMode), 
    );
  }
}

class GamePage extends StatefulWidget {
  final VoidCallback onToggleTheme;

  const GamePage({super.key, required this.onToggleTheme});

  @override
  State<GamePage> createState() => _GamePageState();
}

class _GamePageState extends State<GamePage> {
  List<String> guesses = []; // 今までに入力された単語のリスト
  String currentGuess = '';  // 現在入力中の単語

  @override
  Widget build(BuildContext context) {
    final appColors = Theme.of(context).extension<AppColors>()!;

    return Scaffold(
      backgroundColor: appColors.field.Background,
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            PreferredSize(
              preferredSize: Size.fromHeight(1.0), 
              child: AppBar(
                backgroundColor: appColors.field.Background,
                elevation: 0,
                actions: [
                  IconButton(
                    icon: Icon(Icons.brightness_6, color: appColors.field.TextPrimary),
                    onPressed: widget.onToggleTheme,
                  ),
                ],
                shape: Border(
                  bottom: BorderSide(
                    color: appColors.field.BorderPrimary,
                    width: 1.0,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),
            _buildWordGrid(appColors),
            Spacer(),
            _buildKeyboard(appColors),
          ],
        ),
      )
    );
  }

  Widget _buildWordGrid(AppColors appColors) {
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
              margin: const EdgeInsets.all(2),
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                border: Border.all(
                  color: appColors.field.BorderPrimary,
                  width: 2.0,
                ),
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

  Widget _buildKeyboard(AppColors appColors) {
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
            children: rows[i]
              .split('')
              .map((char) => _buildKeyButton(char, appColors))
              .toList(),
          ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildSpecialKey('ENTER', _onEnter, appColors, flex: 1.5),
            ...rows[2]
              .split('')
              .map((char) => _buildKeyButton(char, appColors)),
            _buildSpecialKey('Delete', _onBackspace,appColors, icon: true, flex: 1.5),
          ],
        ),
      ],
    );
  }

  Widget _buildKeyButton(String char, AppColors appColors) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 3, vertical: 4),
      child: SizedBox(
        width: 25,
        height: 48,
        child: Material(
          elevation: 0,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: appColors.field.Keyboard,
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
                style: TextStyle(
                  fontSize: 16, 
                  fontWeight: FontWeight.bold,
                  color: appColors.field.TextPrimary,
                ),
                softWrap: false,
              ),
            ),
          ),
        )
      ),
    );
  }

Widget _buildSpecialKey(String label, VoidCallback onPressed, AppColors appColors,
    {bool icon = false, double flex = 1}) {
  return Padding(
    padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
    child: SizedBox(
      width: 40.0,
      height: 48,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: appColors.field.Keyboard,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(4),
          ),
          padding: EdgeInsets.symmetric(horizontal: 3),
        ),
        onPressed: onPressed,
        child: FittedBox(
          fit: BoxFit.scaleDown,
          child: icon ? Icon(Icons.backspace, color: appColors.field.TextPrimary) : Text(
            label, 
            style: TextStyle(
              fontSize: 16, 
              fontWeight: FontWeight.bold,
              color: appColors.field.TextPrimary,
            ), 
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