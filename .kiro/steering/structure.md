# Project Structure

## Organization Philosophy

**機能ベース + 共通定義分離** 構成。ゲーム機能は `game/` に集約、共通定義は `const/` に配置。

## Directory Patterns

### 定数・型定義 (`lib/const/`)
**Purpose**: アプリ全体で使用する定数、型、色定義
**Pattern**: 単一責務ファイル

```
const/
  type.dart       # データ型 (LetterStatus, GameState, Guess)
  color.dart      # テーマ色 (ThemeExtension<AppColors>)
  message_bar.dart # トースト通知ユーティリティ
  wordset/
    word_set.dart # 有効単語辞書 (~5,000語)
```

### ゲーム機能 (`lib/game/`)
**Purpose**: ゲーム画面、ロジック、UIコンポーネント
**Pattern**: ページ + widget/ サブディレクトリ

```
game/
  game_page.dart   # メインページ (ConsumerStatefulWidget)
  game_state.dart  # ページ状態クラス
  word_check.dart  # 推測判定ロジック
  word_select.dart # 単語選択ロジック
  widget/
    word_grid.dart # 6x5 文字グリッド
    keyboard.dart  # QWERTYキーボード
    getColor.dart  # ステータス→色変換
```

### 状態管理 (`lib/provider.dart`)
**Purpose**: 全Riverpodプロバイダーを一元定義
**Pattern**: 単一ファイルで集中管理

```dart
// Provider types used:
- Provider<T>              // 読み取り専用（answerWordProvider）
- StateNotifierProvider    // 複雑な状態（gameProvider）
- NotifierProvider         // シンプルな状態（themeModeProvider）
- StateProvider            // フラグ（showFlagProvider）
```

### サーバー (`party/src/`)
**Purpose**: PartyKitマルチプレイヤーサーバー
**Pattern**: 型定義 + ロジック + サーバークラス分離

```
party/src/
  types.ts       # メッセージ型、状態型
  game.ts        # ゲームロジック (checkGuess, isValidWord)
  wordset.ts     # 単語辞書
  index.ts       # PartyKitサーバークラス
  __tests__/     # Vitestテスト
```

## Naming Conventions

- **Dart Files**: snake_case (`word_check.dart`)
- **Dart Classes**: PascalCase (`GameController`, `LetterResult`)
- **TypeScript Files**: snake_case or camelCase (`types.ts`, `index.ts`)
- **Providers**: camelCase + Provider suffix (`gameProvider`, `themeModeProvider`)

## Import Organization

### Dart
```dart
// Package imports first
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports (absolute path: package:vs_wordle/)
import 'package:vs_wordle/const/type.dart';
import 'package:vs_wordle/provider.dart';

// Relative imports for same-feature files
import '../provider.dart';
import 'widget/keyboard.dart';
```

### TypeScript
```typescript
// Type imports first
import type * as Party from 'partykit/server';
import type { ClientMessage, ServerMessage } from './types';

// Regular imports
import { checkGuess, isValidWord } from './game';
```

## Code Organization Principles

1. **状態はProvider経由**: UIコンポーネントは直接状態を持たない、`ref.watch/read` で取得
2. **ロジックは分離**: `word_check.dart`, `game.ts` など純粋関数として実装
3. **型は共有**: クライアント・サーバー間で同じ概念（LetterStatus等）を維持
4. **色はThemeExtension**: `AppColors` でライト/ダークテーマを型安全に定義

---
_created_at: 2024-12-28_
