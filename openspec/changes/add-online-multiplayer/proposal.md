# Change: オンライン対戦機能の追加（サーバー側）

## Why

現在のVSwordleはシングルプレイヤー専用で、1v1対戦というコンセプトを実現できていない。PartyKitを使用してリアルタイムオンライン対戦のサーバー基盤を構築する。

## What Changes

- **PartyKitサーバー**: Cloudflare Workers上で動作するWebSocketサーバー
- **ルーム管理**: ルーム作成・参加・退出のサーバーロジック
- **ゲーム状態管理**: 正答生成、推測検証、勝敗判定
- **切断処理**: 30秒の再接続待機、タイムアウト処理

## Scope

**今回の実装範囲（サーバー側のみ）:**
- `party/` (新規) - PartyKitサーバーコード（TypeScript）

**今回のスコープ外（Flutter側）:**
- `lib/` 配下のFlutterコードは変更しない
- spec内のFlutter関連の記述は将来の実装時の参考情報

## Impact

- Affected specs:
  - `multiplayer-room` (新規): ルーム管理機能
  - `game-sync` (新規): ゲーム状態同期機能
- Affected code:
  - `party/` (新規) - PartyKitサーバーコード
- New dependencies:
  - Server: PartyKit (TypeScript)

## Future Considerations

- Flutter側クライアント実装（別提案）
- ランダムマッチング機能
