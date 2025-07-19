import 'package:vs_wordle/const/wordset/word_set.dart';
import 'dart:math';

final _random = Random();

String getRandomWord() {
  return wordSet.elementAt(_random.nextInt(wordSet.length)).toUpperCase();
}