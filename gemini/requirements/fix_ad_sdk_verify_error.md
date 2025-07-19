# Google Mobile Ads SDKに起因するクラッシュの修正要件

## 1. 背景
Crashlyticsで報告されたクラッシュログ (Issue ID: `5d8f04ff626b8aa6163069f8563c6b40`) によると、Androidアプリで `java.lang.VerifyError` が原因でアプリがクラッシュする問題が確認された。
この問題は特定の状況でアプリを起動できなくするため、ユーザー体験を著しく損ない、早急な修正が必要である。

## 2. 原因分析
スタックトレースを分析した結果、以下の点が明らかになった。

- **エラー:** `Fatal Exception: java.lang.VerifyError: Rejecting class com.google.android.gms.internal.ads.EN that attempts to sub-type erroneous class com.google.android.gms.internal.ads.jO`
- **発生ライブラリ:** `com.google.android.gms:play-services-ads@@24.1.0`
- **根本原因:** `play-services-ads` ライブラリのバージョン `24.1.0` 内部で `VerifyError` が発生している。これは、ライブラリ自体の不具合、または他の依存関係との競合、あるいはビルド時のコード圧縮・難読化（ProGuard/R8）によって必要なクラスが削除されてしまった可能性が考えられる。

## 3. 要件
このクラッシュ問題を解決するために、以下の対応を行う。

1.  **`google_mobile_ads` パッケージのアップデート:**
    - `pubspec.yaml` ファイルを開き、`google_mobile_ads` パッケージを最新の安定バージョンに更新する。これにより、問題が修正されたバージョンの `play-services-ads` が利用されることが期待される。

2.  **AndroidのProGuard設定の確認と追加:**
    - `android/app/build.gradle` ファイルを編集し、`buildTypes.release.proguardRules` にGoogle Mobile Ads SDKが必要とする設定が正しく含まれていることを確認する。不足している場合は、公式ドキュメントに従って以下のルールを追加する。
    ```groovy
    -keep public class com.google.android.gms.ads.** {
       public *;
    }

    -keep public class com.google.ads.** {
       public *;
    }
    ```

3.  **クリーンビルドの実行:**
    - 依存関係を更新し、設定を変更した後は、必ずプロジェクトのクリーンアップを行ってから再度ビルドを実行する。
    ```shell
    fvm flutter clean
    fvm flutter pub get
    ```

## 4. 受け入れ基準
- 修正後、Androidアプリで `java.lang.VerifyError` によるクラッシュが発生しないこと。
- アプリ内の広告が正常に表示されること。
