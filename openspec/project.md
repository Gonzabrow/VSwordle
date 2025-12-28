# Project Context

## Purpose
1v1対戦型Wordle - A competitive two-player Wordle game built with Flutter. Players compete to guess the 5-letter English word with standard Wordle rules (HIT=green for correct position, BLOW=yellow for wrong position, ABSENT=gray for not in word).

## Tech Stack
- **Framework**: Flutter 3.32.2 (managed via FVM)
- **Language**: Dart (SDK >= 3.0.0 < 4.0.0)
- **State Management**: flutter_riverpod ^2.5.1
- **Linting**: flutter_lints ^5.0.0
- **Platforms**: Android, iOS, Web, Windows, macOS, Linux

## Project Conventions

### Code Style
- Use `flutter_lints` rules defined in `analysis_options.yaml`
- Run `fvm flutter analyze` before committing
- Japanese comments are acceptable

### Architecture Patterns
- **Riverpod providers** in `lib/provider.dart` for all state management
- **StateNotifier** pattern for mutable game state (`GameController`)
- **ConsumerWidget/ConsumerStatefulWidget** for UI components that read state
- **ThemeExtension** for custom color theming (`WordleColors`)
- Keep game logic separate from UI in `lib/game/`

### Testing Strategy
- Use `fvm flutter test` to run tests
- Widget tests in `test/` directory

### Git Workflow
- Main branch: `main`
- Commit messages in Japanese or English
- Web builds output to `docs/` for GitHub Pages deployment

## Domain Context
- **Wordle Rules**: 6 attempts to guess a 5-letter word
- **Letter Status**: HIT (exact match), BLOW (wrong position), ABSENT (not in word)
- **Duplicate Letter Handling**: First pass marks HITs, second pass marks BLOWs with remaining letter count
- **Word Dictionary**: ~5,000 valid 5-letter English words in `lib/const/wordset/word_set.dart`

## Important Constraints
- Word length fixed at 5 letters
- Maximum 6 guesses per game
- Only words in `wordSet` are valid guesses

## External Dependencies
- None (fully offline, no backend services currently)
