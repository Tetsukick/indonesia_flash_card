import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/cupertino.dart';
import 'package:indonesia_flash_card/config/color_config.dart';

class TextWidget {
  static Widget titleRedMedium(String data) {
    return AutoSizeText(
      data,
      maxLines: 1,
      minFontSize: 11,
      maxFontSize: 16,
      style: TextStyle(
          fontWeight: FontWeight.bold,
          color: ColorConfig.primaryRed900,
          fontSize: 14
      ),
    );
  }

  static Widget titleBlackLargeBold(String data) {
    return AutoSizeText(
      data,
      maxLines: 1,
      minFontSize: 16,
      maxFontSize: 28,
      style: TextStyle(
          fontWeight: FontWeight.bold,
          color: ColorConfig.fontBlack,
          fontSize: 24
      ),
    );
  }

  static Widget titleGraySmallBold(String data) {
    return AutoSizeText(
      data,
      maxLines: 1,
      minFontSize: 11,
      maxFontSize: 16,
      style: TextStyle(
          fontWeight: FontWeight.bold,
          color: ColorConfig.fontGrey,
          fontSize: 14
      ),
    );
  }

  static Widget titleWhiteLargeBold(String data) {
    return AutoSizeText(
      data,
      maxLines: 1,
      minFontSize: 16,
      maxFontSize: 28,
      style: TextStyle(
          fontWeight: FontWeight.bold,
          color: ColorConfig.fontWhite,
          fontSize: 24
      ),
    );
  }
}