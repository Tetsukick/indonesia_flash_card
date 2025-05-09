// Flutter imports:
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

// Package imports:
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:indonesia_flash_card/utils/my_inapp_browser.dart';

// Project imports:
import '../../../flutter_flow/flutter_flow_theme.dart';
import '../../../gen/assets.gen.dart';

class AnswerTitle extends StatelessWidget {
  const AnswerTitle({Key? key, this.answer, this.maxLines}) : super(key: key);
  final String? answer;
  final int? maxLines;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
            padding: const EdgeInsetsDirectional.fromSTEB(8, 8, 8, 8),
            child: Assets.png.hijabTeacher128.image(
                width: 24, height: 24, fit: BoxFit.cover,),
        ),
        Expanded(
          child: Padding(
            padding: const EdgeInsetsDirectional.fromSTEB(8, 8, 8, 8),
            child: MarkdownBody(
              data: answer ?? '',
              onTapLink: (text, href, title) {
                setBrowserPage(text);
              },
            ),
          ),
        ),
      ],
    );
  }

  Future<void> setBrowserPage(String url) async {
    final browser = MyInAppBrowser();
    await browser.openUrlRequest(
      urlRequest: URLRequest(url: WebUri.uri(Uri.parse(url))),
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
          closeButtonColor: Colors.white,
        ),
      ),
    );
  }
}
