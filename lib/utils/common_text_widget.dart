import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/cupertino.dart';
import 'package:indonesia_flash_card/config/color_config.dart';
import 'package:indonesia_flash_card/config/size_config.dart';

class TextWidget {
  static Widget titleRedMedium(String data, {int maxLines = 1}) {
    return AutoSizeText(
      data,
      maxLines: maxLines,
      minFontSize: 11,
      maxFontSize: 16,
      style: TextStyle(
          fontWeight: FontWeight.bold,
          color: ColorConfig.primaryRed900,
          fontSize: 14
      ),
    );
  }

  static Widget titleRedLargestBold(String data, {int maxLines = 1}) {
    return AutoSizeText(
      data,
      maxLines: maxLines,
      minFontSize: 24,
      maxFontSize: 32,
      style: TextStyle(
          fontWeight: FontWeight.bold,
          color: ColorConfig.primaryRed900,
          fontSize: 32
      ),
    );
  }

  static Widget titleBlackLargeBold(String data, {int maxLines = 1}) {
    return AutoSizeText(
      data,
      maxLines: maxLines,
      minFontSize: 16,
      maxFontSize: 28,
      style: TextStyle(
          fontWeight: FontWeight.bold,
          color: ColorConfig.fontBlack,
          fontSize: 24
      ),
    );
  }

  static Widget titleBlackLargestBold(String data, {int maxLines = 1}) {
    return AutoSizeText(
      data,
      maxLines: maxLines,
      minFontSize: 24,
      maxFontSize: 32,
      style: TextStyle(
          fontWeight: FontWeight.bold,
          color: ColorConfig.fontBlack,
          fontSize: 32
      ),
    );
  }

  static Widget titleBlackMediumBold(String data, {int maxLines = 1}) {
    return AutoSizeText(
      data,
      maxLines: maxLines,
      minFontSize: 14,
      maxFontSize: 18,
      style: TextStyle(
          fontWeight: FontWeight.bold,
          color: ColorConfig.fontBlack,
          fontSize: 18
      ),
    );
  }

  static Widget titleBlackSmallBold(String data, {int maxLines = 1}) {
    return AutoSizeText(
      data,
      maxLines: maxLines,
      minFontSize: 9,
      maxFontSize: 14,
      style: TextStyle(
          fontWeight: FontWeight.bold,
          color: ColorConfig.fontBlack,
          fontSize: 12
      ),
    );
  }

  static Widget titleGrayLargeBold(String data, {int maxLines = 1}) {
    return AutoSizeText(
      data,
      maxLines: maxLines,
      minFontSize: 16,
      maxFontSize: 24,
      style: TextStyle(
          fontWeight: FontWeight.bold,
          color: ColorConfig.fontGrey,
          fontSize: 24
      ),
    );
  }

  static Widget titleGrayMediumBold(String data, {int maxLines = 1}) {
    return AutoSizeText(
      data,
      maxLines: maxLines,
      minFontSize: 14,
      maxFontSize: 20,
      style: TextStyle(
          fontWeight: FontWeight.bold,
          color: ColorConfig.fontGrey,
          fontSize: 20
      ),
    );
  }

  static Widget titleGrayMedium(String data, {int maxLines = 1}) {
    return AutoSizeText(
      data,
      maxLines: maxLines,
      minFontSize: 14,
      maxFontSize: 20,
      style: TextStyle(
          fontWeight: FontWeight.normal,
          color: ColorConfig.fontGrey,
          fontSize: 20
      ),
    );
  }

  static Widget titleGrayMediumSmallBold(String data, {int maxLines = 1}) {
    return AutoSizeText(
      data,
      maxLines: maxLines,
      minFontSize: 14,
      maxFontSize: 20,
      style: TextStyle(
          fontWeight: FontWeight.bold,
          color: ColorConfig.fontGrey,
          fontSize: 18
      ),
    );
  }

  static Widget titleGraySmallBold(String data, {int maxLines = 1}) {
    return AutoSizeText(
      data,
      maxLines: maxLines,
      minFontSize: 11,
      maxFontSize: 16,
      style: TextStyle(
          fontWeight: FontWeight.bold,
          color: ColorConfig.fontGrey,
          fontSize: 14
      ),
    );
  }

  static Widget titleGraySmallest(String data, {int maxLines = 1}) {
    return AutoSizeText(
      data,
      maxLines: maxLines,
      minFontSize: 9,
      maxFontSize: 12,
      style: TextStyle(
          color: ColorConfig.fontGrey,
          fontSize: 12
      ),
    );
  }

  static Widget titleGraySmall(String data, {int maxLines = 1}) {
    return AutoSizeText(
      data,
      maxLines: maxLines,
      minFontSize: 9,
      maxFontSize: 16,
      style: TextStyle(
          color: ColorConfig.fontGrey,
          fontSize: 14
      ),
    );
  }

  static Widget titleWhiteLargeBold(String data, {int maxLines = 1}) {
    return AutoSizeText(
      data,
      maxLines: maxLines,
      minFontSize: 16,
      maxFontSize: 28,
      style: TextStyle(
          fontWeight: FontWeight.bold,
          color: ColorConfig.fontWhite,
          fontSize: 24
      ),
    );
  }

  static Widget titleWhiteSmallBoldWithBackGround(String data, {int maxLines = 1}) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: ColorConfig.primaryRed900,
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: SizeConfig.smallestMargin, horizontal: SizeConfig.mediumSmallMargin),
        child: AutoSizeText(
          data,
          maxLines: maxLines,
          minFontSize: 12,
          maxFontSize: 16,
          style: TextStyle(
              fontWeight: FontWeight.bold,
              color: ColorConfig.fontWhite,
              fontSize: 14
          ),
        ),
      ),
    );
  }
}