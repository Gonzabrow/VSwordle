# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

VSwordle - 1v1対戦型Wordle（Flutter/Dart）

## Development Commands

```bash
# Dependencies
fvm flutter pub get

# Run (debug)
fvm flutter run

# Run (release)
fvm flutter run --release

# Build for web (outputs to docs/ for GitHub Pages)
fvm flutter build web

# Lint
fvm flutter analyze

# Test
fvm flutter test
```

Flutter version is locked at 3.32.2 via FVM (`.fvmrc`).

## Architecture

### State Management (Riverpod)

All state is managed in `lib/provider.dart`:

- `answerWordProvider` - The target word (generated once at app start)
- `gameProvider` - GameController (StateNotifier) managing game state
- `themeModeProvider` - Light/dark theme toggle
- `showFlagProvider` - Debug flag to reveal answer

### Game Logic Flow

1. User types letters → `GameController.onKeyPress()` updates `currentGuess`
2. User presses Enter → `GameController.onEnter()`:
   - Validates word exists in `wordSet`
   - Calls `checkGuess()` from `lib/game/word_check.dart`
   - Updates `keyStatuses` for keyboard coloring
   - Adds `Guess` to history

### Wordle Validation (`lib/game/word_check.dart`)

Implements standard Wordle rules with correct duplicate letter handling:
1. First pass: Mark exact position matches as HIT (green)
2. Second pass: Mark wrong position matches as BLOW (yellow)
3. Remaining letters: ABSENT (gray)

### Key Data Types (`lib/const/type.dart`)

```dart
enum LetterStatus { hit, blow, absent }

class GameState {
  String currentGuess;
  List<Guess> guesses;
  Map<String, LetterStatus> keyStatuses;
}

class Guess {
  String word;
  List<LetterResult> results;
}
```

### UI Structure

```
MainApp → MaterialApp → GamePage
                          ├─ WordGrid (6x5 letter tiles)
                          └─ Keyboard (QWERTY with status colors)
```

### Theme System

Custom `ThemeExtension<WordleColors>` in `lib/const/color.dart` defines HIT/BLOW/ABSENT colors for both light and dark themes.

### Word Dictionary

`lib/const/wordset/word_set.dart` contains ~5,000 valid 5-letter English words.

# 重要
ユーザーへの応答は日本語で行うこと。

# AI-DLC and Spec-Driven Development

Kiro-style Spec Driven Development implementation on AI-DLC (AI Development Life Cycle)

## Project Context

### Paths
- Steering: `.kiro/steering/`
- Specs: `.kiro/specs/`

### Steering vs Specification

**Steering** (`.kiro/steering/`) - Guide AI with project-wide rules and context
**Specs** (`.kiro/specs/`) - Formalize development process for individual features

### Active Specifications
- Check `.kiro/specs/` for active specifications
- Use `/kiro:spec-status [feature-name]` to check progress

## Development Guidelines
- Think in English, generate responses in Japanese. All Markdown content written to project files (e.g., requirements.md, design.md, tasks.md, research.md, validation reports) MUST be written in the target language configured for this specification (see spec.json.language).

## Minimal Workflow
- Phase 0 (optional): `/kiro:steering`, `/kiro:steering-custom`
- Phase 1 (Specification):
  - `/kiro:spec-init "description"`
  - `/kiro:spec-requirements {feature}`
  - `/kiro:validate-gap {feature}` (optional: for existing codebase)
  - `/kiro:spec-design {feature} [-y]`
  - `/kiro:validate-design {feature}` (optional: design review)
  - `/kiro:spec-tasks {feature} [-y]`
- Phase 2 (Implementation): `/kiro:spec-impl {feature} [tasks]`
  - `/kiro:validate-impl {feature}` (optional: after implementation)
- Progress check: `/kiro:spec-status {feature}` (use anytime)

## Development Rules
- 3-phase approval workflow: Requirements → Design → Tasks → Implementation
- Human review required each phase; use `-y` only for intentional fast-track
- Keep steering current and verify alignment with `/kiro:spec-status`
- Follow the user's instructions precisely, and within that scope act autonomously: gather the necessary context and complete the requested work end-to-end in this run, asking questions only when essential information is missing or the instructions are critically ambiguous.

## Steering Configuration
- Load entire `.kiro/steering/` as project memory
- Default files: `product.md`, `tech.md`, `structure.md`
- Custom files are supported (managed via `/kiro:steering-custom`)
