# Tasks: オンライン対戦機能（サーバー側）

## 1. PartyKitプロジェクト初期化

- [x] 1.1 `party/`ディレクトリにPartyKitプロジェクトを初期化
- [x] 1.2 TypeScript設定（tsconfig.json）
- [x] 1.3 partykit.json設定ファイル作成

## 2. 型定義・メッセージプロトコル

- [x] 2.1 サーバー/クライアント間メッセージ型定義（ServerMessage, ClientMessage）
- [x] 2.2 ゲーム状態型定義（RoomState, PlayerState, GameState）
- [x] 2.3 LetterStatus, LetterResult等のWordle関連型

## 3. WordSet移植

- [x] 3.1 Dart版wordSetをTypeScript形式に変換
- [x] 3.2 単語検証ユーティリティ関数

## 4. Wordleロジック移植

- [x] 4.1 checkGuess関数（HIT/BLOW/ABSENT判定）をTypeScriptで実装
- [x] 4.2 ランダム単語選択関数

## 5. ルーム管理実装

- [x] 5.1 ルームコード生成（4文字英大文字）
- [x] 5.2 onConnect: ルーム作成/参加処理
- [x] 5.3 ルーム状態管理（waiting, playing, finished）
- [x] 5.4 プレイヤー管理（最大2人）

## 6. ゲームロジック実装

- [x] 6.1 ゲーム開始処理（正答生成、両プレイヤーに通知）
- [x] 6.2 onMessage: 推測受信・検証・結果ブロードキャスト
- [x] 6.3 onMessage: タイピング中文字の転送
- [x] 6.4 勝敗判定（先に正解、両者失敗、一方のみ失敗）
- [x] 6.5 ゲーム終了処理（正答公開）

## 7. 切断/再接続処理

- [x] 7.1 onClose: 切断検知、タイムアウト開始
- [x] 7.2 再接続判定（同一プレイヤーID）
- [x] 7.3 30秒タイムアウト後の敗北処理
- [x] 7.4 再接続時のゲーム状態再送信

## 8. テスト

- [x] 8.1 checkGuess関数のユニットテスト
- [x] 8.2 ルーム管理のユニットテスト
- [x] 8.3 ローカル環境での2クライアント接続テスト

## 9. デプロイ

- [ ] 9.1 Cloudflareアカウント設定
- [ ] 9.2 PartyKitデプロイ（`npx partykit deploy`）
- [ ] 9.3 本番環境URLの動作確認

## Notes

- Flutter側の実装は別提案で行う
- specに記載のクライアント側要件は、サーバーAPIの設計指針として参照
