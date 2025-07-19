import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vs_wordle/const/color.dart';
import 'package:vs_wordle/provider.dart';
import 'package:vs_wordle/const/type.dart';
import 'getColor.dart';

class Keyboard extends ConsumerWidget{
  const Keyboard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appColors = Theme.of(context).extension<AppColors>()!;
    final gameState = ref.watch(gameProvider);
    final gameController = ref.watch(gameProvider.notifier);

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
              .map((char) => _buildKeyButton(char, appColors, gameState, gameController))
              .toList(),
          ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildSpecialKey('ENTER', () => gameController.onEnter(ref), appColors, flex: 1.5),
            ...rows[2]
              .split('')
              .map((char) => _buildKeyButton(char, appColors, gameState, gameController)),
            _buildSpecialKey('Delete', gameController.onBackspace, appColors, icon: true, flex: 1.5),
          ],
        ),
      ],
    );
  }
}

Widget _buildKeyButton(String char, AppColors appColors, GameState gameState, GameController gameController) {
  final status = gameState.keyStatuses[char];
  final backgroundColor = status != null 
    ? getColorForStatus(status, appColors) 
    : appColors.field.Keyboard;
  final textColor = status != null 
    ? appColors.field.TextSecondary 
    : appColors.field.TextPrimary;
  
  return Padding(
    padding: const EdgeInsets.symmetric(horizontal: 3, vertical: 4),
    child: SizedBox(
      width: 25,
      height: 48,
      child: Material(
        elevation: 0,
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: backgroundColor,
            elevation: 0, 
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(6),
            ),
            padding: EdgeInsets.zero, // 必要なら padding を削る
          ),
          onPressed: () => gameController.onKeyPress(char),
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              char,
              style: TextStyle(
                fontSize: 16, 
                fontWeight: FontWeight.bold,
                color: textColor,
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