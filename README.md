# BINTANGO
Flash card application of Indonesian language for Japanese  
日本語話者向けインドネシア語単語学習アプリ  

![tango_ver1 0 0](https://user-images.githubusercontent.com/47769514/156931533-41fe312c-a344-47db-9e7e-2569fe937947.png)
![dictionary_ver1 0 0](https://user-images.githubusercontent.com/47769514/156931525-415779c9-e3f5-406a-bec0-591f3fc6326b.png)
![top_ver1 0 0](https://user-images.githubusercontent.com/47769514/156931537-ebce6387-c55f-4dbb-bab4-b0ab1c0a7c4e.png)


## ストア情報
iOS: https://apps.apple.com/app/id1607987786  
Android: https://play.google.com/store/apps/details?id=com.tetsukick.indonesia.flash.card  

## 開発環境情報

```
[✓] Flutter (Channel stable, 2.10.2, on macOS 11.6.2 20G314 darwin-x64, locale en-US)
    • Flutter version 2.10.2 at /Users/teppei.kikuchi/fvm/versions/2.10.2
    • Upstream repository https://github.com/flutter/flutter.git
    • Framework revision 097d3313d8 (9 days ago), 2022-02-18 19:33:08 -0600
    • Engine revision a83ed0e5e3
    • Dart version 2.16.1
    • DevTools version 2.9.2

[!] Android toolchain - develop for Android devices (Android SDK version 32.1.0-rc1)
    • Android SDK at /Users/teppei.kikuchi/Library/Android/sdk
    ✗ cmdline-tools component is missing
      Run `path/to/sdkmanager --install "cmdline-tools;latest"`
      See https://developer.android.com/studio/command-line for more details.
    ✗ Android license status unknown.
      Run `flutter doctor --android-licenses` to accept the SDK licenses.
      See https://flutter.dev/docs/get-started/install/macos#android-setup for more details.

[✓] Xcode - develop for iOS and macOS (Xcode 13.2.1)
    • Xcode at /Applications/Xcode.app/Contents/Developer
    • CocoaPods version 1.11.2

[✓] Chrome - develop for the web
    • Chrome at /Applications/Google Chrome.app/Contents/MacOS/Google Chrome

[✓] Android Studio (version 2020.3)
    • Android Studio at /Applications/Android Studio.app/Contents
    • Flutter plugin can be installed from:
      🔨 https://plugins.jetbrains.com/plugin/9212-flutter
    • Dart plugin can be installed from:
      🔨 https://plugins.jetbrains.com/plugin/6351-dart
    • Java version OpenJDK Runtime Environment (build 11.0.10+0-b96-7281165)

[✓] VS Code (version 1.64.2)
    • VS Code at /Applications/Visual Studio Code.app/Contents
    • Flutter extension can be installed from:
      🔨 https://marketplace.visualstudio.com/items?itemName=Dart-Code.flutter

[✓] Connected device (2 available)
    • vivo 1820 (mobile) • HUFIWC4TM7MF9LKN • android-arm64  • Android 8.1.0 (API 27)
    • Chrome (web)       • chrome           • web-javascript • Google Chrome 98.0.4758.109

[✓] HTTP Host Availability
    • All required HTTP hosts are available
```

## 導入ツール
- FlutterBeanFactory
- FlutterGen

## 必要ファイル
/lib/config/credentials.dart にGoogleAPI用のServiceアカウントが必要です。  

例)

```
const credentials = {
  "type": "service_account",
  "project_id": "",
  "private_key_id": "",
  "private_key": "",
  "client_email": "",
  "client_id": "",
  "auth_uri": "",
  "token_uri": "",
  "auth_provider_x509_cert_url": "",
  "client_x509_cert_url": ""
};
```

また、Firebaseの設定ファイルを以下に格納してください。  

- Android
  android/app/google-services.json  
- ios
  ios/Runner/GoogleService-Info.plist  
