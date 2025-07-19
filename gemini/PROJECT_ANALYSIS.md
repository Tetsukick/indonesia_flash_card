
## プロジェクト概要

- **プロジェクト名:** `indonesia_flash_card`
- **説明:** 日本人向けのインドネシア語単語学習アプリ
- **バージョン:** 3.5.1+99

## アーキテクチャ

Clean Architectureに類似した、関心事の分離を意識したディレクトリ構造になっています。

- **`lib/`**: アプリケーションの主要なソースコードが格納されています。
    - **`api/`**: `Dio` を利用したAPIクライアント。リクエスト/レスポンス処理、エラーハンドリングを担います。
    - **`config/`**: アプリケーション全体の設定（色、サイズ、APIキーヘッダ名など）を管理します。
    - **`domain/`**: `Riverpod` を用いた状態管理と、ビジネスロジック（単語リストの取得・フィルタリング・ソート、クイズの正誤判定など）を担います。`tango_list_service.dart` が中心的な役割を果たしています。
    - **`model/`**: `floor` を利用したデータベースのエンティティ、DAO、およびAPIレスポンスのモデルクラスを定義しています。`TangoEntity` が単語の基本データ構造です。
    - **`repository/`**: データソースとのやり取りを抽象化する層。`googleapis` を利用してGoogle DriveやGoogle Sheetsからデータを取得したり、`cloud_firestore` を利用してデータを永続化したりします。
    - **`screen/`**: アプリケーションの各画面のUIを実装しています。`home_navigation.dart` がメインのナビゲーションを制御しています。
    - **`utils/`**: ロギング、広告（AdMob）、リモート設定（Firebase Remote Config）、セキュアストレージなど、アプリケーション全体で利用される共通機能を提供します。

## 主要なライブラリ

- **状態管理:** `flutter_riverpod`
- **HTTP通信:** `dio`
- **データベース:** `floor`
- **Googleサービス:** `googleapis`, `google_mobile_ads`, `firebase_core` など
- **UI:** `curved_navigation_bar`, `lottie` など
- **その他:** `logger`, `flutter_secure_storage`, `shared_preferences` など

## データフロー

1.  **データ取得:**
    - `SheetRepo` が `googleapis` を介してGoogle Sheetsから単語データを取得します。
    - 取得したデータは `TangoEntity` に変換され、`floor` を使ってローカルのSQLiteデータベースに保存されます。
    - データ更新のタイミングは `firebase_remote_config` で管理されています。
2.  **ビジネスロジック:**
    - `TangoListController` (`Riverpod` の `StateNotifier`) が、ユーザーの操作に応じて単語リストのフィルタリング、ソート、クイズ用のデータ作成などを行います。
    - ユーザーの学習状況（正解・不正解など）は `WordStatus` エンティティとしてデータベースに保存されます。
3.  **UI:**
    - 各画面 (`screen/` 以下) は `TangoListController` から提供されるデータを監視し、UIを更新します。
    - `HomeNavigation` がアプリ全体の画面遷移を管理します。

## 特徴

- **データソースとしてGoogle Sheetsを活用:** 単語データをスプレッドシートで管理しており、柔軟なデータ更新が可能です。
- **Riverpodによる状態管理:** グローバルな状態管理ライブラリとしてRiverpodを採用し、状態の伝播を効率的に行っています。
- **floorによるローカルDB:** オフラインでも利用できるよう、取得した単語データをローカルのSQLiteに保存しています。
- **Firebaseとの連携:** Analytics, Crashlytics, Messaging, Remote Configなど、Firebaseの各種サービスを積極的に利用しています。
