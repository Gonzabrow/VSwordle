# VSwordle PartyKit Server

オンライン対戦用のWebSocketサーバー（PartyKit / Cloudflare Workers）

## セットアップ

```bash
cd party
pnpm install
```

## ローカルでの動作確認

### 1. サーバー起動

```bash
pnpm dev
```

起動すると以下のように表示されます：

```
🎈 PartyKit v0.0.115
---------------------
[pk:inf] Ready on http://127.0.0.1:1999
```

### 2. 接続テスト

別のターミナルで：

```bash
node test-client.mjs
```

2人のプレイヤーが接続し、推測を送信するテストが実行されます。

### 3. 手動テスト（ブラウザ DevTools）

ブラウザの開発者ツールで直接WebSocket接続をテストできます：

```javascript
// ルームに接続（ルームコードは任意の4文字）
const ws = new WebSocket('ws://127.0.0.1:1999/party/TEST');

ws.onmessage = (e) => console.log('受信:', JSON.parse(e.data));
ws.onopen = () => console.log('接続成功');

// 推測を送信（ゲーム開始後）
ws.send(JSON.stringify({ type: 'guess', word: 'APPLE' }));

// 入力中の文字を送信
ws.send(JSON.stringify({ type: 'typing', currentGuess: 'APP' }));
```

### 4. 2人対戦テスト

2つのブラウザタブ（またはウィンドウ）を開いて：

**タブ1（ルーム作成者）:**
```javascript
const ws1 = new WebSocket('ws://127.0.0.1:1999/party/GAME');
ws1.onmessage = (e) => console.log('P1:', JSON.parse(e.data));
```

**タブ2（参加者）:**
```javascript
const ws2 = new WebSocket('ws://127.0.0.1:1999/party/GAME');
ws2.onmessage = (e) => console.log('P2:', JSON.parse(e.data));
```

両方が接続すると `game_start` メッセージが届き、対戦開始です。

## テスト実行

```bash
# 全テスト実行
pnpm test

# ウォッチモード
pnpm test:watch
```

## メッセージ形式

### クライアント → サーバー

| type | 説明 | 例 |
|------|------|-----|
| `guess` | 推測を送信 | `{ "type": "guess", "word": "APPLE" }` |
| `typing` | 入力中の文字 | `{ "type": "typing", "currentGuess": "APP" }` |
| `leave_room` | ルーム退出 | `{ "type": "leave_room" }` |

### サーバー → クライアント

| type | 説明 |
|------|------|
| `room_created` | ルーム作成成功（roomCode, playerId） |
| `player_joined` | 2人目が参加 |
| `game_start` | ゲーム開始 |
| `guess_result` | 推測結果（word, results） |
| `opponent_typing` | 相手の入力中文字 |
| `game_over` | ゲーム終了（winnerId, answer, result） |
| `player_disconnected` | 相手が切断 |
| `player_reconnected` | 相手が再接続 |
| `state_resync` | 再接続時の状態復元 |
| `error` | エラー（room_full, invalid_word等） |

## 再接続

切断後30秒以内に同じplayerIdで再接続可能：

```javascript
const ws = new WebSocket('ws://127.0.0.1:1999/party/GAME?playerId=player_xxx');
```

## デプロイ

```bash
pnpm deploy
```

※ 初回はCloudflareアカウントへのログインが必要です。
