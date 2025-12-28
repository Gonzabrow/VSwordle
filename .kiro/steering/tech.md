# Technology Stack

## Architecture

クライアント-サーバー型リアルタイムアプリケーション。Flutter製クライアントとPartyKit製サーバーがWebSocketで通信。

## Core Technologies

### Client (Flutter)
- **Language**: Dart
- **Framework**: Flutter 3.32.2 (FVM管理)
- **State Management**: Riverpod (flutter_riverpod)
- **Target**: Web (GitHub Pages)

### Server (PartyKit)
- **Language**: TypeScript
- **Runtime**: PartyKit (Cloudflare Workers ベース)
- **Protocol**: WebSocket

## Key Libraries

### Client
- `flutter_riverpod` - 状態管理（Provider/StateNotifier/Notifier パターン）
- `another_flushbar` - トースト通知

### Server
- `partykit` - リアルタイムマルチプレイヤーサーバー
- `vitest` - テストフレームワーク

## Development Standards

### Type Safety
- Dart: null safety有効（`>=3.0.0`）
- TypeScript: strict mode

### Code Quality
- Flutter: `flutter_lints` (flutter analyze)
- TypeScript: 型定義を `types.ts` で一元管理

### Testing
- Client: `flutter test`
- Server: `vitest` (単体テスト)

## Development Environment

### Required Tools
- FVM (Flutter Version Management)
- Node.js + pnpm (PartyKit server)

### Common Commands
```bash
# Client
fvm flutter pub get      # 依存解決
fvm flutter run          # 開発実行
fvm flutter build web    # Webビルド (-> docs/)
fvm flutter analyze      # Lint
fvm flutter test         # テスト

# Server
cd party && pnpm dev     # 開発サーバー
cd party && pnpm test    # テスト
cd party && pnpm deploy  # デプロイ
```

## Key Technical Decisions

| Decision | Rationale |
|----------|-----------|
| Riverpod | Provider + StateNotifierで予測可能な状態管理 |
| PartyKit | エッジ実行のWebSocketサーバー、スケーラブル |
| FVM | Flutter バージョン固定（チーム開発の安定性） |
| GitHub Pages | 無料ホスティング、docs/ ディレクトリ出力 |
| ThemeExtension | ライト/ダークテーマの色定義を型安全に管理 |

---
_created_at: 2024-12-28_
