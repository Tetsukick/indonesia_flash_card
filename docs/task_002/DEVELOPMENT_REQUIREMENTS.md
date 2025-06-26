### **開発要件定義書：全体の達成度キャッシュ機能**

#### 1. 概要
アプリケーション全体の単語学習達成度（`totalAchievement`）の計算負荷を軽減するため、その値をデータベースにキャッシュし、必要に応じて更新する。

#### 2. 機能要件
- **達成度の計算:**
    - **計算式:** `(ステータスが "remembered" または "perfectRemembered" の全単語数) / (全単語の総数)`
    - **対象ステータス:** `WordStatusType.remembered` (ID: 1) と `WordStatusType.perfectRemembered` (ID: 2) を達成済みとみなす。

- **達成度の保存:**
    - 計算された全体の達成度をデータベースに保存する。
    - `AchievementRate` Entityを再利用し、`id`を`total_achievement`のような固定値とする。

- **データ更新タイミング:**
    - `TangoListController`の`getTotalAchievement()`メソッドが呼ばれた際に、データベースからキャッシュされた値を読み込む。
    - `addQuizResult`が呼ばれ、個別の達成度が更新された際に、全体の達成度も再計算し、データベースを更新する。

#### 3. UI/UX
- UIの変更はなし。既存の`lib/screen/lesson_selector/lesson_selector_screen.dart`の`_userSection()`で表示されている`totalAchievement`が、キャッシュされた値を利用するように変更される。

#### 4. 技術要件・実装方針
- **データベース (Floor):**
    - 既存の`AchievementRate` Entityと`AchievementRateDao`を再利用する。
    - `AchievementRate`の`id`フィールドに`total_achievement`という固定値を設定して、全体の達成度を保存する。

- **状態管理 (Riverpod) & ビジネスロジック:**
    - `TangoListController`の`getTotalAchievement()`メソッドを修正し、データベースから`id = 'total_achievement'`の`AchievementRate`レコードを読み込むようにする。
    - `TangoListController`の`addQuizResult`メソッド内で、個別の達成度更新後に全体の達成度を再計算し、`achievementRateDao.upsertAchievementRate`を使ってデータベースに保存する。
    - `achievementRateProvider`を拡張し、全体の達成度も提供できるようにするか、または新しい`Provider`を定義するかを検討する。今回は既存の`achievementRateProvider`を拡張する方向で進める。
