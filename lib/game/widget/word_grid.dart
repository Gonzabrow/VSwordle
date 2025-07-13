import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vs_wordle/const/color.dart';
import 'package:vs_wordle/provider.dart';
import 'package:vs_wordle/const/type.dart';
import 'getColor.dart';

class WordGrid extends ConsumerWidget {
  const WordGrid({super.key});

  final totalRows = 6;
  final wordLength = 5;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appColors = Theme.of(context).extension<AppColors>()!;
    final gameState = ref.watch(gameProvider);

    return Column(
      children: List.generate(totalRows, (rowIndex) {
        String letter;
        List<LetterResult>? result;

        if (rowIndex < gameState.guesses.length) {
          final guess = gameState.guesses[rowIndex];
          letter = guess.word;
          result = guess.results;
        } else if (rowIndex == gameState.guesses.length) {
          letter = gameState.currentGuess.padRight(wordLength);
        } else {
          letter = ''.padRight(wordLength);
        }

        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(wordLength, (i) {
            final char = letter[i];
            final isFilled = char.trim().isNotEmpty;
            final backgroundColor = (result != null) 
              ? getColorForStatus(result[i].status, appColors) 
              : null;
            final borderColor = (result != null)
              ? backgroundColor!
              : isFilled 
                ? appColors.field.BorderSecondary 
                : appColors.field.BorderPrimary;
            final textColor = (result != null)
              ? appColors.field.TextSecondary
              : appColors.field.TextPrimary;
            
            return Container(
              margin: const EdgeInsets.all(2),
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: backgroundColor,
                border: Border.all(
                  color: borderColor, 
                  width: 2.0,
                ),
              ),
              alignment: Alignment.center,
              child: Text(
                char.toUpperCase(),
                style: TextStyle(
                  fontSize: 24, 
                  color: textColor,
                  fontWeight: FontWeight.bold
                ),
              ),
            );
          }).toList(),
        );
      }),
    );
  }
}