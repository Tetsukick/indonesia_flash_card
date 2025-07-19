# AdWidget のビルド時に発生する FlutterError クラッシュの修正要件

## 1. 背景
Crashlyticsで報告されたクラッシュログ (Issue ID: `4353707ea534c87a29e09f97ad522aec`) によると、iOSアプリで `AdWidget` のビルド中に `FlutterError` が発生し、アプリがクラッシュする問題が確認された。
この問題は広告表示に関連する画面で発生し、ユーザー体験を損なうため、修正が必要である。

## 2. 原因分析
スタックトレースを分析した結果、以下の点が明らかになった。

- **エラー:** `Fatal Exception: FlutterError`
- **発生箇所:** `_AdWidgetState.build` メソッド内 (`ad_containers.dart:693`)
- **根本原因:** `AdWidget` をビルドする際に、内部で利用している広告オブジェクト（例: `BannerAd`）がまだ準備できていないか、あるいはすでに破棄（dispose）されている可能性がある。`AdWidget` は有効な広告オブジェクトを要求するため、`null` の広告オブジェクトを渡したり、無効な状態の広告オブジェクトを渡したりすると、ビルド時にエラーが発生する。非同期で広告をロードしている間に画面が遷移したり、ウィジェットが破棄されたりするケースで発生しやすい。

## 3. 要件
このクラッシュ問題を解決するために、以下の対応を行う。

1.  **広告オブジェクトのロード状態の管理:**
    - `AdWidget` を表示する前に、広告オブジェクト（`BannerAd` など）が正常にロード完了していることを確認するフラグ（例: `isAdLoaded`）を管理する。
    - 広告がロード完了するまでは、`AdWidget` の代わりにプレースホルダー（例: `SizedBox` や `Container`）を表示する。

2.  **Stateのライフサイクル管理の徹底:**
    - `StatefulWidget` の `dispose` メソッドで、作成した広告オブジェクトを確実に `dispose` する。
    - `setState` を呼び出す前に `mounted` プロパティをチェックし、ウィジェットがウィジェットツリーに存在しない場合に `setState` が呼ばれるのを防ぐ。

3.  **実装例:**
    ```dart
    class _MyAdScreenState extends State<MyAdScreen> {
      BannerAd? _bannerAd;
      bool _isAdLoaded = false;

      @override
      void initState() {
        super.initState();
        _loadAd();
      }

      void _loadAd() {
        _bannerAd = BannerAd(
          // ... ad properties
          listener: BannerAdListener(
            onAdLoaded: (Ad ad) {
              if (!mounted) return; // mounted チェック
              setState(() {
                _isAdLoaded = true;
              });
            },
            onAdFailedToLoad: (Ad ad, LoadAdError error) {
              ad.dispose();
            },
          ),
        )..load();
      }

      @override
      void dispose() {
        _bannerAd?.dispose();
        super.dispose();
      }

      @override
      Widget build(BuildContext context) {
        return Scaffold(
          // ...
          bottomNavigationBar: _isAdLoaded && _bannerAd != null
              ? SizedBox(
                  width: _bannerAd!.size.width.toDouble(),
                  height: _bannerAd!.size.height.toDouble(),
                  child: AdWidget(ad: _bannerAd!),
                )
              : const SizedBox.shrink(), // or a placeholder
        );
      }
    }
    ```

## 4. 受け入れ基準
- 修正後、iOSアプリで広告表示に関連する画面でクラッシュが発生しないこと。
- 広告が正常にロードされ、表示されること。
- 広告のロードに失敗した場合でも、アプリがクラッシュしないこと。
