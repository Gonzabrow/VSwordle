import { describe, it, expect } from 'vitest';
import {
  checkGuess,
  isValidWord,
  isWinningGuess,
  getRandomWord,
  generateRoomCode,
  MAX_GUESSES,
} from '../game';

describe('checkGuess', () => {
  it('should return all HITs for correct guess', () => {
    const results = checkGuess('APPLE', 'APPLE');
    expect(results).toEqual([
      { letter: 'A', status: 'hit' },
      { letter: 'P', status: 'hit' },
      { letter: 'P', status: 'hit' },
      { letter: 'L', status: 'hit' },
      { letter: 'E', status: 'hit' },
    ]);
  });

  it('should return all ABSENTs for completely wrong guess', () => {
    const results = checkGuess('XXXXX', 'APPLE');
    expect(results).toEqual([
      { letter: 'X', status: 'absent' },
      { letter: 'X', status: 'absent' },
      { letter: 'X', status: 'absent' },
      { letter: 'X', status: 'absent' },
      { letter: 'X', status: 'absent' },
    ]);
  });

  it('should return BLOWs for letters in wrong position', () => {
    const results = checkGuess('LEAPT', 'APPLE');
    expect(results[0]).toEqual({ letter: 'L', status: 'blow' }); // L is in APPLE but wrong position
    expect(results[1]).toEqual({ letter: 'E', status: 'blow' }); // E is in APPLE but wrong position
    expect(results[2]).toEqual({ letter: 'A', status: 'blow' }); // A is in APPLE but wrong position
    expect(results[3]).toEqual({ letter: 'P', status: 'blow' }); // P is in APPLE but wrong position
    expect(results[4]).toEqual({ letter: 'T', status: 'absent' }); // T is not in APPLE
  });

  it('should handle duplicate letters correctly - extra letters marked as ABSENT', () => {
    // Answer: APPLE (two Ps at positions 1 and 2)
    // Guess: PIPPY (three Ps at positions 0, 2, 3)
    // P(2) is HIT, P(0) is BLOW (using remaining P count), P(3) is ABSENT (no Ps left)
    const results = checkGuess('PIPPY', 'APPLE');

    expect(results[0].status).toBe('blow'); // P in wrong position (uses 1 of 2 remaining after HIT)
    expect(results[1].status).toBe('absent'); // I not in answer
    expect(results[2].status).toBe('hit'); // P at position 2 matches P at position 2 in APPLE
    expect(results[3].status).toBe('absent'); // Third P - no more Ps available
    expect(results[4].status).toBe('absent'); // Y not in answer
  });

  it('should prioritize HIT over BLOW for duplicate letters', () => {
    // Answer: PAPER (P at 0, A at 1, P at 2, E at 3, R at 4) - two Ps
    // Guess: HAPPY (H at 0, A at 1, P at 2, P at 3, Y at 4)
    // A(1) is HIT, P(2) is HIT, P(3) is BLOW (one P remaining at position 0)
    const results = checkGuess('HAPPY', 'PAPER');
    expect(results[0].status).toBe('absent'); // H not in PAPER
    expect(results[1].status).toBe('hit'); // A at position 1 matches A at position 1
    expect(results[2].status).toBe('hit'); // P at position 2 matches P at position 2
    expect(results[3].status).toBe('blow'); // P uses remaining P at position 0
    expect(results[4].status).toBe('absent'); // Y not in PAPER
  });

  it('should be case-insensitive', () => {
    const results1 = checkGuess('apple', 'APPLE');
    const results2 = checkGuess('APPLE', 'apple');
    expect(results1).toEqual(results2);
    expect(results1.every(r => r.status === 'hit')).toBe(true);
  });
});

describe('isValidWord', () => {
  it('should return true for valid words', () => {
    expect(isValidWord('APPLE')).toBe(true);
    expect(isValidWord('ABOUT')).toBe(true);
    expect(isValidWord('ZEBRA')).toBe(true);
  });

  it('should return false for invalid words', () => {
    expect(isValidWord('XXXXX')).toBe(false);
    expect(isValidWord('ZZZZZ')).toBe(false);
    expect(isValidWord('QWERT')).toBe(false);
  });

  it('should be case-insensitive', () => {
    expect(isValidWord('apple')).toBe(true);
    expect(isValidWord('Apple')).toBe(true);
    expect(isValidWord('APPLE')).toBe(true);
  });
});

describe('isWinningGuess', () => {
  it('should return true when all letters are HITs', () => {
    const results = [
      { letter: 'A', status: 'hit' as const },
      { letter: 'P', status: 'hit' as const },
      { letter: 'P', status: 'hit' as const },
      { letter: 'L', status: 'hit' as const },
      { letter: 'E', status: 'hit' as const },
    ];
    expect(isWinningGuess(results)).toBe(true);
  });

  it('should return false when not all letters are HITs', () => {
    const results = [
      { letter: 'A', status: 'hit' as const },
      { letter: 'P', status: 'blow' as const },
      { letter: 'P', status: 'hit' as const },
      { letter: 'L', status: 'hit' as const },
      { letter: 'E', status: 'hit' as const },
    ];
    expect(isWinningGuess(results)).toBe(false);
  });
});

describe('getRandomWord', () => {
  it('should return a valid 5-letter word', () => {
    const word = getRandomWord();
    expect(word.length).toBe(5);
    expect(isValidWord(word)).toBe(true);
  });

  it('should return different words on multiple calls (probabilistic)', () => {
    const words = new Set<string>();
    for (let i = 0; i < 10; i++) {
      words.add(getRandomWord());
    }
    // With 15000+ words, getting 10 unique words is highly likely
    expect(words.size).toBeGreaterThan(1);
  });
});

describe('generateRoomCode', () => {
  it('should generate a 4-character code', () => {
    const code = generateRoomCode();
    expect(code.length).toBe(4);
  });

  it('should only contain uppercase letters', () => {
    const code = generateRoomCode();
    expect(/^[A-Z]{4}$/.test(code)).toBe(true);
  });

  it('should generate different codes on multiple calls (probabilistic)', () => {
    const codes = new Set<string>();
    for (let i = 0; i < 10; i++) {
      codes.add(generateRoomCode());
    }
    // With 26^4 = 456976 possible codes, getting duplicates is unlikely
    expect(codes.size).toBeGreaterThan(1);
  });
});

describe('MAX_GUESSES', () => {
  it('should be 6', () => {
    expect(MAX_GUESSES).toBe(6);
  });
});
