import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:indonesia_flash_card/config/size_config.dart';
import 'package:indonesia_flash_card/gen/assets.gen.dart';
import 'package:indonesia_flash_card/utils/common_text_widget.dart';

import '../utils/my_inapp_browser.dart';

class MenuScreen extends ConsumerStatefulWidget {
  const MenuScreen({Key? key}) : super(key: key);

  @override
  _MenuScreenState createState() => _MenuScreenState();
}

class _MenuScreenState extends ConsumerState<MenuScreen> {
  final _menuItemBarHeight = 80.0;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(SizeConfig.mediumSmallMargin),
      child: ListView.builder(
        itemCount: MenuItem.values.length,
        itemBuilder: (BuildContext context, int index) {
          final _menuItem = MenuItem.values[index];
          return Card(
            child: InkWell(
              onTap: () => setBrowserPage(_menuItem.url),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: SizeConfig.mediumSmallMargin),
                height: _menuItemBarHeight,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    _menuItem.img,
                    SizedBox(width: SizeConfig.smallMargin),
                    TextWidget.titleBlackMediumBold(_menuItem.title)
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Future<void> setBrowserPage(String url) async {
    MyInAppBrowser browser = new MyInAppBrowser();
    await browser.openUrlRequest(
      urlRequest: URLRequest(url: Uri.parse(url)),
      options: InAppBrowserClassOptions(
        crossPlatform: InAppBrowserOptions(
          toolbarTopBackgroundColor: const Color(0xff2b374d),
        ),
        android: AndroidInAppBrowserOptions(
          // Android用オプション
        ),
        ios: IOSInAppBrowserOptions(
          // iOS用オプション
            toolbarTopTintColor: const Color(0xff2b374d),
            closeButtonCaption: '閉じる',
            closeButtonColor: Colors.white
        ),
      ),
    );
  }
}

enum MenuItem {
  privacyPolicy,
  feedback,
  developerInfo
}

extension MenuItemExt on MenuItem {
  String get title {
    switch (this) {
      case MenuItem.privacyPolicy:
        return 'プライバシーポリシー';
      case MenuItem.feedback:
        return 'フィードバック';
      case MenuItem.developerInfo:
        return '開発者情報';
    }
  }

  String get url {
    switch (this) {
      case MenuItem.privacyPolicy:
        return 'https://qiita.com/tetsukick/items/a3c844940064e15f0dac';
      case MenuItem.feedback:
        return 'https://forms.gle/jMJvWZ5MrJnreB3o8';
      case MenuItem.developerInfo:
        return 'https://linktr.ee/TeppeiKikuchi';
    }
  }

  Widget get img {
    const _height = 24.0;
    const _width = 24.0;
    switch (this) {
      case MenuItem.privacyPolicy:
        return Assets.png.privacypolicy128.image(height: _height, width: _width);
      case MenuItem.feedback:
        return Assets.png.feedback128.image(height: _height, width: _width);
      case MenuItem.developerInfo:
        return Assets.png.developer128.image(height: _height, width: _width);
    }
  }
}
