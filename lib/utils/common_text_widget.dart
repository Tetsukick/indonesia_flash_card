// Flutter imports:
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

// Package imports:
import 'package:auto_size_text/auto_size_text.dart';
import 'package:google_fonts/google_fonts.dart';

// Project imports:
import 'package:indonesia_flash_card/config/color_config.dart';
import 'package:indonesia_flash_card/config/size_config.dart';

class TextWidget {

  static TextStyle baseFont = GoogleFonts.notoSans();
  static TextStyle titleFont = GoogleFonts.kaiseiOpti();
  static TextStyle numberFont = GoogleFonts.quicksand();
  static Widget titleRedMedium(String data, {int maxLines = 1}) {
    return AutoSizeText(
      data,
      maxLines: maxLines,
      minFontSize: 11,
      maxFontSize: 16,
      style: baseFont.copyWith(
        fontWeight: FontWeight.bold,
        color: ColorConfig.primaryRed900,
        fontSize: 14,
      ),
    );
  }

  static Widget titleRedLargestBold(String data, {int maxLines = 1}) {
    return AutoSizeText(
      data,
      maxLines: maxLines,
      minFontSize: 24,
      maxFontSize: 32,
      style: baseFont.copyWith(
          fontWeight: FontWeight.bold,
          color: ColorConfig.primaryRed900,
          fontSize: 32,
      ),
    );
  }

  static Widget titleBlackLargeBoldKaisei(String data, {int maxLines = 1}) {
    return AutoSizeText(
      data,
      maxLines: maxLines,
      minFontSize: 16,
      maxFontSize: 28,
      style: titleFont.copyWith(
          fontWeight: FontWeight.bold,
          color: ColorConfig.fontBlack,
          fontSize: 24,
      ),
    );
  }

  static Widget titleBlackLargeBold(String data, {int maxLines = 1}) {
    return AutoSizeText(
      data,
      maxLines: maxLines,
      minFontSize: 16,
      maxFontSize: 28,
      style: baseFont.copyWith(
        fontWeight: FontWeight.bold,
        color: ColorConfig.fontBlack,
        fontSize: 24,
      ),
    );
  }

  static Widget titleNumberBlackLargeBold(String data, {int maxLines = 1}) {
    return AutoSizeText(
      data,
      maxLines: maxLines,
      minFontSize: 16,
      maxFontSize: 28,
      style: numberFont.copyWith(
        fontWeight: FontWeight.bold,
        color: ColorConfig.fontBlack,
        fontSize: 24,
      ),
    );
  }

  static Widget titleBlackLargeBoldSelectable(String data, {int maxLines = 1}) {
    return SelectionArea(
      child: AutoSizeText(
        data,
        maxLines: maxLines,
        minFontSize: 16,
        maxFontSize: 28,
        style: baseFont.copyWith(
          fontWeight: FontWeight.bold,
          color: ColorConfig.fontBlack,
          fontSize: 24,
        ),
      ),
    );
  }

  static Widget titleBlackLargestBold(String data, {int maxLines = 1}) {
    return AutoSizeText(
      data,
      maxLines: maxLines,
      minFontSize: 24,
      maxFontSize: 32,
      style: baseFont.copyWith(
          fontWeight: FontWeight.bold,
          color: ColorConfig.fontBlack,
          fontSize: 32,
      ),
    );
  }

  static Widget titleBlackLargestBoldSelectable(String data, {int maxLines = 1}) {
    return SelectionArea(
      child: AutoSizeText(
        data,
        maxLines: maxLines,
        minFontSize: 24,
        maxFontSize: 32,
        style: baseFont.copyWith(
          fontWeight: FontWeight.bold,
          color: ColorConfig.fontBlack,
          fontSize: 32,
        ),
      ),
    );
  }

  static Widget titleBlackMediumBold(String data, {int maxLines = 1}) {
    return AutoSizeText(
      data,
      maxLines: maxLines,
      minFontSize: 14,
      maxFontSize: 18,
      style: baseFont.copyWith(
          fontWeight: FontWeight.bold,
          color: ColorConfig.fontBlack,
          fontSize: 18,
      ),
    );
  }

  static Widget titleBlackSmallBold(String data, {int maxLines = 1}) {
    return AutoSizeText(
      data,
      maxLines: maxLines,
      minFontSize: 9,
      maxFontSize: 14,
      style: baseFont.copyWith(
          fontWeight: FontWeight.bold,
          color: ColorConfig.fontBlack,
          fontSize: 12,
      ),
    );
  }

  static Widget titleGrayLargeBold(String data, {int maxLines = 1}) {
    return AutoSizeText(
      data,
      maxLines: maxLines,
      minFontSize: 24,
      maxFontSize: 32,
      style: baseFont.copyWith(
          fontWeight: FontWeight.bold,
          color: ColorConfig.fontGrey,
          fontSize: 32,
      ),
    );
  }

  static Widget titleGrayLargestBold(String data, {int maxLines = 1}) {
    return AutoSizeText(
      data,
      maxLines: maxLines,
      minFontSize: 16,
      maxFontSize: 24,
      style: baseFont.copyWith(
        fontWeight: FontWeight.bold,
        color: ColorConfig.fontGrey,
        fontSize: 24,
      ),
    );
  }

  static Widget titleGrayLargeBoldSelectable(String data, {int maxLines = 1}) {
    return SelectionArea(
      child: AutoSizeText(
        data,
        maxLines: maxLines,
        minFontSize: 16,
        maxFontSize: 24,
        style: baseFont.copyWith(
          fontWeight: FontWeight.bold,
          color: ColorConfig.fontGrey,
          fontSize: 24,
        ),
      ),
    );
  }

  static Widget titleGrayMediumBold(String data, {int maxLines = 1}) {
    return AutoSizeText(
      data,
      maxLines: maxLines,
      minFontSize: 14,
      maxFontSize: 20,
      style: baseFont.copyWith(
          fontWeight: FontWeight.bold,
          color: ColorConfig.fontGrey,
          fontSize: 20,
      ),
    );
  }

  static Widget titleGrayMediumBoldSelectable(String data, {int maxLines = 1}) {
    return SelectionArea(
      child: AutoSizeText(
        data,
        maxLines: maxLines,
        minFontSize: 14,
        maxFontSize: 20,
        style: baseFont.copyWith(
          fontWeight: FontWeight.bold,
          color: ColorConfig.fontGrey,
          fontSize: 20,
        ),
      ),
    );
  }

  static Widget titleGrayMedium(String data, {int maxLines = 1}) {
    return AutoSizeText(
      data,
      maxLines: maxLines,
      minFontSize: 14,
      maxFontSize: 20,
      style: baseFont.copyWith(
          fontWeight: FontWeight.normal,
          color: ColorConfig.fontGrey,
          fontSize: 20,
      ),
    );
  }

  static Widget titleGrayMediumSmallBold(String data, {int maxLines = 1}) {
    return AutoSizeText(
      data,
      maxLines: maxLines,
      minFontSize: 14,
      maxFontSize: 20,
      style: baseFont.copyWith(
          fontWeight: FontWeight.bold,
          color: ColorConfig.fontGrey,
          fontSize: 18,
      ),
    );
  }

  static Widget titleGraySmallBold(String data, {int maxLines = 1}) {
    return AutoSizeText(
      data,
      maxLines: maxLines,
      minFontSize: 11,
      maxFontSize: 16,
      style: baseFont.copyWith(
          fontWeight: FontWeight.bold,
          color: ColorConfig.fontGrey,
          fontSize: 14,
      ),
    );
  }

  static Widget titleGraySmallest(String data, {int maxLines = 1, TextAlign? textAlign}) {
    return AutoSizeText(
      data,
      maxLines: maxLines,
      minFontSize: 9,
      maxFontSize: 12,
      textAlign: textAlign,
      style: baseFont.copyWith(
          color: ColorConfig.fontGrey,
          fontSize: 12,
      ),
    );
  }

  static Widget titleNumberGraySmallest(String data, {int maxLines = 1, TextAlign? textAlign}) {
    return AutoSizeText(
      data,
      maxLines: maxLines,
      minFontSize: 9,
      maxFontSize: 12,
      textAlign: textAlign,
      style: numberFont.copyWith(
        color: ColorConfig.fontGrey,
        fontSize: 12,
      ),
    );
  }

  static Widget titleGraySmall(String data, {int maxLines = 1}) {
    return AutoSizeText(
      data,
      maxLines: maxLines,
      minFontSize: 9,
      maxFontSize: 16,
      style: baseFont.copyWith(
          color: ColorConfig.fontGrey,
          fontSize: 14,
      ),
    );
  }

  static Widget titleNumberGraySmall(String data, {int maxLines = 1}) {
    return AutoSizeText(
      data,
      maxLines: maxLines,
      minFontSize: 9,
      maxFontSize: 16,
      style: numberFont.copyWith(
        color: ColorConfig.fontGrey,
        fontSize: 14,
      ),
    );
  }

  static Widget titleWhiteLargeBold(String data, {int maxLines = 1}) {
    return AutoSizeText(
      data,
      maxLines: maxLines,
      minFontSize: 16,
      maxFontSize: 28,
      style: titleFont.copyWith(
          fontWeight: FontWeight.bold,
          color: ColorConfig.fontWhite,
          fontSize: 24,
      ),
    );
  }

  static Widget titleWhiteSmallBoldWithBackGround(String data, {int maxLines = 1}) {
    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: ColorConfig.primaryRed900,
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: SizeConfig.smallestMargin, horizontal: SizeConfig.mediumSmallMargin),
        child: AutoSizeText(
          data,
          maxLines: maxLines,
          maxFontSize: 16,
          style: baseFont.copyWith(
              fontWeight: FontWeight.bold,
              color: ColorConfig.fontWhite,
              fontSize: 14,
          ),
        ),
      ),
    );
  }
}
