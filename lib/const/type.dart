
enum LetterStatus { hit, blow, absent }

class LetterResult {
  final String letter;
  final LetterStatus status;

  LetterResult(this.letter, this.status);
}

class Guess {
  final String word;
  final List<LetterResult> results;

  Guess(this.word, this.results);
}

class GameState {
  final String currentGuess;
  final List<Guess> guesses;
  final Map<String, LetterStatus> keyStatuses;

  GameState({
    this.currentGuess = '',
    this.guesses = const [],
    this.keyStatuses = const {},
  });

  GameState copyWith({
    String? currentGuess,
    List<Guess>? guesses,
    Map<String, LetterStatus>? keyStatuses,
  }) {
    return GameState(
      currentGuess: currentGuess ?? this.currentGuess,
      guesses: guesses ?? this.guesses,
      keyStatuses: keyStatuses ?? this.keyStatuses,
    );
  }
}