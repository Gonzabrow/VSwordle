import type { LetterResult, LetterStatus } from './types';
import { wordSet, wordList } from './wordset';

/**
 * Check if a word is valid (exists in the word set)
 */
export function isValidWord(word: string): boolean {
  return wordSet.has(word.toUpperCase());
}

/**
 * Get a random word from the word list
 */
export function getRandomWord(): string {
  const index = Math.floor(Math.random() * wordList.length);
  return wordList[index];
}

/**
 * Check a guess against the answer and return the results
 * Implements standard Wordle rules with correct duplicate letter handling:
 * 1. First pass: Mark exact position matches as HIT (green)
 * 2. Second pass: Mark wrong position matches as BLOW (yellow)
 * 3. Remaining letters: ABSENT (gray)
 */
export function checkGuess(guess: string, answer: string): LetterResult[] {
  const guessUpper = guess.toUpperCase();
  const answerUpper = answer.toUpperCase();

  const guessChars = guessUpper.split('');
  const answerChars = answerUpper.split('');

  // Initialize results with ABSENT status
  const results: LetterResult[] = guessChars.map((letter) => ({
    letter,
    status: 'absent' as LetterStatus,
  }));

  // Count occurrences of each letter in the answer
  const charCounts: Map<string, number> = new Map();
  for (const char of answerChars) {
    charCounts.set(char, (charCounts.get(char) ?? 0) + 1);
  }

  // First pass: Mark HITs (exact matches)
  for (let i = 0; i < guessChars.length; i++) {
    if (guessChars[i] === answerChars[i]) {
      results[i] = { letter: guessChars[i], status: 'hit' };
      charCounts.set(guessChars[i], charCounts.get(guessChars[i])! - 1);
    }
  }

  // Second pass: Mark BLOWs (wrong position but present)
  for (let i = 0; i < guessChars.length; i++) {
    if (results[i].status === 'hit') continue;

    const char = guessChars[i];
    const count = charCounts.get(char);
    if (count !== undefined && count > 0) {
      results[i] = { letter: char, status: 'blow' };
      charCounts.set(char, count - 1);
    }
  }

  return results;
}

/**
 * Check if a guess is a winning guess (all HITs)
 */
export function isWinningGuess(results: LetterResult[]): boolean {
  return results.every((r) => r.status === 'hit');
}

/**
 * Generate a 4-character uppercase room code
 */
export function generateRoomCode(): string {
  const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ';
  let code = '';
  for (let i = 0; i < 4; i++) {
    code += chars.charAt(Math.floor(Math.random() * chars.length));
  }
  return code;
}

/**
 * Maximum number of guesses allowed per player
 */
export const MAX_GUESSES = 6;
