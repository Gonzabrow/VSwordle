import 'package:vs_wordle/const/type.dart';

List<LetterResult> checkGuess(String guess, String answer) {
  final result = List<LetterResult>.generate(guess.length, (index) => LetterResult(guess[index], LetterStatus.absent));
  final answerChars = answer.split('');
  final used = List.filled(answerChars.length, false);

  // Hit
  for (int i = 0; i < guess.length; i++) {
    if (guess[i] == answerChars[i]) {
    result[i] = LetterResult(guess[i], LetterStatus.hit);
    used[i] = true;
    }
  }

  // Blow
   for (int i = 0; i < guess.length; i++) {
    if (result[i].status == LetterStatus.hit) continue;

    for (int j = 0; j < answerChars.length; j++) {
      if (!used[j] && guess[i] == answerChars[j]) {
        result[i] = LetterResult(guess[i], LetterStatus.blow);
        used[j] = true;
        break;
      }
    }

    // HIT でも BLOW でもなければ ABSENT
    if (result[i].status == LetterStatus.absent) {
      result[i] = LetterResult(guess[i], LetterStatus.absent);
    }
  }

  return result;
  
}