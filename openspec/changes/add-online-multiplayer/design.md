# Design: オンライン対戦アーキテクチャ（サーバー側）

## Context

VSwordleを1v1対戦型Wordleとして実現するため、リアルタイム通信基盤が必要。PartyKitはCloudflare Workers上で動作するWebSocketサーバーを簡単に構築でき、ルームベースの状態管理が標準でサポートされている。

**ステークホルダー**:
- プレイヤー: 友達とオンラインで対戦したい
- 開発者: シンプルで保守しやすい実装

**制約**:
- PartyKitは外部サービス

**スコープ**:
- 今回の実装: PartyKitサーバー（`party/`）のみ
- Flutter側クライアントは別提案で実装

## Goals / Non-Goals

### Goals（今回の実装）
- PartyKitサーバーの構築
- ルーム作成・参加のサーバーロジック
- 推測検証・結果ブロードキャストのゲームロジック
- 切断時の再接続・タイムアウト処理

### Non-Goals（今回のスコープ外）
- Flutter側クライアント実装
- ランダムマッチング
- ユーザー認証・アカウント管理
- 戦績保存
- 観戦機能

## Decisions

### 1. 通信プロトコル: WebSocket over PartyKit

**決定**: PartyKitを使用してWebSocketサーバーを構築

**理由**:
- ルームベースの状態管理が標準機能
- Cloudflare Workersによるグローバル低遅延
- シンプルなAPI（onConnect, onMessage, broadcast）
- 無料枠で十分な規模をカバー

**代替案**:
- Firebase Realtime Database: オーバースペック、コスト高
- Socket.io + 自前サーバー: インフラ管理が必要
- Supabase Realtime: PostgreSQL不要なのに依存

### 2. ルーム管理: サーバー側で正答生成

**決定**: ルーム作成時にサーバーが正答を生成し、両プレイヤーに同じ問題を出題

**理由**:
- チート防止（クライアント側で正答を持たない）
- 公平性の担保

**メッセージフロー**:
```
Client A                    PartyKit Server                    Client B
    |                             |                               |
    |-- create_room ------------->|                               |
    |<-- room_created(code) ------|                               |
    |                             |                               |
    |                             |<-- join_room(code) -----------|
    |<-- player_joined -----------|-- player_joined ------------->|
    |<-- game_start(answer?) -----|-- game_start(answer?) ------->|
    |                             |                               |
    |-- guess(word) ------------->|                               |
    |<-- guess_result ------------|-- opponent_guess ------------>|
    |                             |                               |
    |-- guess(correct!) --------->|                               |
    |<-- game_over(you_win) ------|-- game_over(you_lose) ------->|
```

### 3. 状態同期: イベントベース + 差分送信

**決定**: 各アクションをイベントとしてブロードキャストし、クライアントが状態を再構築

**イベント種別**:
```typescript
type ServerMessage =
  | { type: 'room_created'; roomCode: string }
  | { type: 'player_joined'; playerId: string }
  | { type: 'game_start' }
  | { type: 'guess_result'; playerId: string; word: string; results: LetterResult[] }
  | { type: 'opponent_typing'; currentGuess: string }
  | { type: 'game_over'; winnerId: string }
  | { type: 'player_disconnected'; playerId: string }
  | { type: 'player_reconnected'; playerId: string };

type ClientMessage =
  | { type: 'create_room' }
  | { type: 'join_room'; roomCode: string }
  | { type: 'guess'; word: string }
  | { type: 'typing'; currentGuess: string };
```

### 4. 正答の検証: サーバー側で実施

**決定**: クライアントは推測をサーバーに送信し、サーバーが検証して結果を返す

**理由**:
- チート防止（正答がクライアントに露出しない）
- 両プレイヤーに同時に結果を配信できる

**処理フロー**:
1. クライアントが `guess(word)` を送信
2. サーバーが `wordSet` で有効性チェック
3. サーバーが `checkGuess()` で判定
4. 全クライアントに `guess_result` をブロードキャスト
5. 正解なら `game_over` も送信

### 5. 切断処理: 30秒タイムアウト

**決定**: 切断後30秒間は再接続を許可し、タイムアウトで敗北

**実装**:
- PartyKitの`onClose`で切断を検知
- `setTimeout`で30秒後に敗北処理
- `onConnect`で同じプレイヤーIDなら再接続として復帰
- 再接続時は現在のゲーム状態を全送信

### 6. Flutter側アーキテクチャ（参考情報）

> **Note**: Flutter側の実装は今回のスコープ外。以下は将来の実装時の参考情報。

既存のRiverpod構造を活用し、オンライン専用のProviderを追加する想定:

```dart
// 新規Provider
final roomProvider = StateNotifierProvider<RoomController, RoomState?>(...);
final onlineGameProvider = StateNotifierProvider<OnlineGameController, OnlineGameState>(...);
final connectionProvider = Provider<WebSocketChannel?>(...);

// RoomState
class RoomState {
  final String roomCode;
  final String myPlayerId;
  final String? opponentId;
  final RoomStatus status; // waiting, playing, finished
}

// OnlineGameState extends GameState
class OnlineGameState {
  final GameState myState;
  final GameState opponentState;
  final String? winnerId;
  final ConnectionStatus connectionStatus;
}
```

## Risks / Trade-offs

| リスク | 影響度 | 緩和策 |
|--------|--------|--------|
| PartyKitサービス障害 | 高 | オフラインモードを維持、障害時はオフラインへフォールバック |
| ネットワーク遅延 | 中 | 楽観的UI更新、入力中の文字は即時表示 |
| 同時入力の競合 | 低 | サーバー側でタイムスタンプ管理、順序保証 |
| WordSetの同期 | 中 | サーバーにも同じwordSetを配置、バージョン管理 |

## Migration Plan

1. 既存のオフラインモードは変更なしで維持
2. 新規画面として対戦ロビーを追加
3. `party/`ディレクトリにPartyKitサーバーを配置
4. 段階的リリース: ルーム機能 → ゲーム同期 → 切断処理

**ロールバック**: PartyKitサーバーを停止するだけでオフライン専用に戻る

## Open Questions

- [ ] ルームコードの形式（英数字何文字？）→ 提案: 4文字の英大文字（例: ABCD）
- [ ] タイピング中の文字を相手に見せるか？ → 提案: 見せる（リアルタイム感を重視）
- [ ] ゲーム終了後の再戦機能は必要か？ → 提案: 将来対応（今回スコープ外）
