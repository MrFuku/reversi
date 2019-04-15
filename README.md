# ネットでオセロ
[サイトURL](https://fuku-no-othello.herokuapp.com)
[デモ動画](https://youtu.be/E1hvZuW9m7U)

## アプリ概要
- Railsチュートリアルのサンプルを拡張したアプリです。
- オリジナルの全ての機能に加え、AWS上に構築、RSpec導入、コメントやいいねの機能追加、検索機能追加といった変更を加えました。

## 主な機能
- ユーザー機能
  - ユーザー作成
  - ユーザー編集
  - ユーザー削除
- 友達機能
  - 友達申請
  - 申請の取消
  - 申請の受諾
  - 申請の拒否
  - 友達登録の解除
- 対戦ルーム機能
  - 対戦ルーム作成
  - 対戦ルーム削除
  - 参加ユーザー友達限定設定
  - 参加パスワード設定
  - 対戦ルームからのプレイヤー離脱検知
- オセロ機能
  - 基本的オセロ機能
  - 対戦状況のリアルタイム配信
  - ターン切り替え通知
  - 対戦成績記録
- チャット機能
  - メッセージのリアルタイム配信
  - 画面自動スクロール

## 使用した技術
- ユーザー認証
  - device（一部カスタマイズ）
- オンラインユーザー管理
  - Redis
- デプロイ
  - Heroku
- DB
  - MySQL
- RSpec
  - 単体テスト
  - 統合テスト

## バージョン
- Ruby 2.5.0
- Rails 5.2.2
