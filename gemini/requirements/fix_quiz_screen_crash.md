# クイズ画面におけるNull Pointer Exceptionの修正要件

## 1. 背景
Crashlyticsで報告されたクラッシュログ (Issue ID: `266cae90cc8ae49f1c88b74f951ad293`) によると、クイズ画面で特定の操作を行うとアプリがクラッシュする問題が確認された。
この問題はユーザー体験を著しく損なうため、早急な修正が必要である。

## 2. 原因分析
スタックトレースを分析した結果、以下の点が明らかになった。

- **エラー:** `Null check operator used on a null value`
- **発生ファイル:** `lib/screen/quiz_screen.dart`
- **発生箇所:** `_QuizScreenState` の `setPinCodeTextField` メソッド内の `setState` 呼び出し部分。
- **根本原因:** `_answer` メソッドから `getNextCard` を経て `setPinCodeTextField` が呼ばれる非同期処理のフロー中に、`_QuizScreenState` がウィジェットツリーから破棄（unmount）されることがある。その結果、`State` の `context` が `null` となり、`context` プロパティへのアクセス時にNull Pointer Exceptionが発生している。

## 3. 要件
このクラッシュ問題を解決するために、以下の修正を行う。

- **修正対象:** `lib/screen/quiz_screen.dart`
- **修正内容:** `_QuizScreenState` 内で `setState` を呼び出している箇所、特に `setPinCodeTextField` メソッド内に、`setState` を実行する前に `mounted` プロパティをチェックするガード節を設ける。

```dart
// 修正前
void sample() {
  setState(() {
    // context を利用する処理
  });
}

// 修正後
void sample() {
  if (!mounted) return;
  setState(() {
    // context を利用する処理
  });
}
```

## 4. 受け入れ基準
- 修正後、クイズ画面で連続して回答を行ってもクラッシュが発生しないこと。
- クイズの回答直後に画面を遷移したり、アプリを閉じたりしてもクラッシュが発生しないこと。
