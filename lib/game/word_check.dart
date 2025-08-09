import 'package:vs_wordle/const/type.dart';

List<LetterResult> checkGuess(String guess, String answer) {
  final result = List<LetterResult>.generate(guess.length, (index) => LetterResult(guess[index], LetterStatus.absent));
  final guessChars = guess.split('');
  final answerChars = answer.split('');

  // 各文字の出現数をカウント
  final Map<String, int> charCounts = {};
  for (final char in answerChars) {
    charCounts[char] = (charCounts[char] ?? 0) + 1;
  }

  // HIT
  for (int i = 0; i < guess.length; i++) {
    if (guessChars[i] == answerChars[i]) {
      result[i] = LetterResult(guessChars[i], LetterStatus.hit);
      charCounts[guessChars[i]] = charCounts[guessChars[i]]! - 1;
    }
  }

  // BLOW
  for (int i = 0; i < guess.length; i++) {
    if (result[i].status == LetterStatus.hit) continue;

    final char = guessChars[i];
    if (charCounts.containsKey(char) && charCounts[char]! > 0) {
      result[i] = LetterResult(char, LetterStatus.blow);
      charCounts[char] = charCounts[char]! - 1;
    }
  }

  return result;
  
}