import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vs_wordle/const/type.dart';
import 'package:vs_wordle/const/wordset/word_set.dart';
import 'package:vs_wordle/game/word_check.dart';
import 'package:vs_wordle/game/word_select.dart';

// Answer word provider
final answerWordProvider = Provider<String>((ref) {
  return getRandomWord();
});

// Theme mode provider
class ThemeModeNotifier extends Notifier<ThemeMode> {
  @override
  ThemeMode build() => ThemeMode.system;

  void toggle() {
    state = state == ThemeMode.light
        ? ThemeMode.dark
        : ThemeMode.light;
  }

  void set(ThemeMode mode) {
    state = mode;
  }
}

final themeModeProvider = NotifierProvider<ThemeModeNotifier, ThemeMode>(() => ThemeModeNotifier());

// 今入力してるやつと今まで入力したやつ -> GameState
class GameController extends StateNotifier<GameState> {
  GameController() : super(GameState());

  void onKeyPress(String letter) {
    if (state.currentGuess.length >= 5) return;
    state = state.copyWith(
      currentGuess: state.currentGuess + letter,
    );
  }

  void onBackspace() {
    if (state.currentGuess.isNotEmpty) {
      state = state.copyWith(
        currentGuess: state.currentGuess.substring(0, state.currentGuess.length - 1),
      );
    }
  }
  
  void onEnter(ref) {
    if (state.currentGuess.length < 5) return;

    final guess = state.currentGuess.toUpperCase();
    if (!wordSet.contains(guess)) {
      // エラーメッセージ出したい
      
      return;
    }
    final answer = ref.read(answerWordProvider);
    final results = checkGuess(guess, answer);

    state = state.copyWith(
      currentGuess: '',
      guesses: [...state.guesses, Guess(guess, results)],
      keyStatuses: _updateKeyStatuses(state.keyStatuses, results),
    );
  }

  Map<String, LetterStatus> _updateKeyStatuses(Map<String, LetterStatus> currentStatus, List<LetterResult> results) {
    final newStatus = Map<String, LetterStatus>.from(currentStatus);
    for (final result in results) {
      final current = newStatus[result.letter];
      if (current == null || _statusPriority(result.status) > _statusPriority(current)) {
        newStatus[result.letter] = result.status;
      }
    }
    return newStatus;
  }

  int _statusPriority(LetterStatus status) {
    switch (status) {
      case LetterStatus.hit:
        return 3;
      case LetterStatus.blow:
        return 2;
      case LetterStatus.absent:
        return 1;
    }
  }
}

final gameProvider = StateNotifierProvider<GameController, GameState>((ref) => GameController());