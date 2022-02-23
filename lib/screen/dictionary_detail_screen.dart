import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:indonesia_flash_card/config/color_config.dart';
import 'package:indonesia_flash_card/config/size_config.dart';
import 'package:indonesia_flash_card/gen/assets.gen.dart';
import 'package:indonesia_flash_card/model/part_of_speech.dart';
import 'package:indonesia_flash_card/model/tango_entity.dart';
import 'package:indonesia_flash_card/utils/common_text_widget.dart';
import 'package:lottie/lottie.dart';

import '../utils/shared_preference.dart';

class DictionaryDetail extends ConsumerStatefulWidget {
  final TangoEntity tangoEntity;
  static navigateTo(context, {required TangoEntity tangoEntity}) {
    Navigator.push(context, MaterialPageRoute(
      builder: (context) {
        return DictionaryDetail(tangoEntity: tangoEntity);
      },
    ));
  }

  const DictionaryDetail({Key? key, required this.tangoEntity}) : super(key: key);

  @override
  ConsumerState<DictionaryDetail> createState() => _DictionaryDetailState();
}

class _DictionaryDetailState extends ConsumerState<DictionaryDetail> {
  FlutterTts flutterTts = FlutterTts();
  bool _isSoundOn = true;
  final _iconHeight = 20.0;
  final _iconWidth = 20.0;

  @override
  void initState() {
    setTTS();
    loadSoundSetting();
    super.initState();
  }

  void setTTS() {
    flutterTts.setLanguage('id-ID');
  }

  void loadSoundSetting() async {
    _isSoundOn = await PreferenceKey.isSoundOn.getBool();
    setState(() {});
    if (_isSoundOn) {
      flutterTts.speak(this.widget.tangoEntity.indonesian ?? '');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorConfig.bgPinkColor,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(SizeConfig.smallMargin),
          child: Card(
            child: Padding(
              padding: const EdgeInsets.all(SizeConfig.mediumSmallMargin),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _topBarSection(),
                  _partOfSpeech(),
                  SizedBox(height: SizeConfig.smallMargin),
                  _indonesian(),
                  SizedBox(height: SizeConfig.smallestMargin),
                  _separater(),
                  _japanese(),
                  SizedBox(height: SizeConfig.smallMargin),
                  _english(),
                  SizedBox(heiTetsukick29ght: SizeConfig.smallMargin),
                  _exampleHeader(),
                  SizedBox(height: SizeConfig.smallMargin),
                  _example(),
                  SizedBox(height: SizeConfig.smallMargin),
                  _exampleJp(),
                  SizedBox(height: SizeConfig.smallMargin),
                  _descriptionHeader(),
                  SizedBox(height: SizeConfig.smallMargin),
                  _description()
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _topBarSection() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _soundButton(this.widget.tangoEntity.indonesian!),
        IconButton(
            onPressed: () => Navigator.pop(context),
            icon: Icon(Icons.close,
              color: ColorConfig.bgGrey,
              size: SizeConfig.largeSmallMargin,
            ))
      ],
    );
  }

  Widget _partOfSpeech() {
    return Row(
      children: [
        TextWidget.titleWhiteSmallBoldWithBackGround(PartOfSpeechExt.intToPartOfSpeech(value: this.widget.tangoEntity.partOfSpeech!).title),
        SizedBox(width: SizeConfig.mediumSmallMargin),
      ],
    );
  }

  Widget _indonesian() {
    return Row(
      children: [
        Assets.png.indonesia64.image(height: _iconHeight, width: _iconWidth),
        SizedBox(width: SizeConfig.mediumSmallMargin),
        Flexible(child: TextWidget.titleBlackLargestBold(this.widget.tangoEntity.indonesian!, maxLines: 2)),
      ],
    );
  }

  Widget _japanese() {
    return Row(
      children: [
        Assets.png.japanFuji64.image(height: _iconHeight, width: _iconWidth),
        SizedBox(width: SizeConfig.mediumSmallMargin),
        Flexible(child: TextWidget.titleGrayLargeBold(this.widget.tangoEntity.japanese!, maxLines: 2)),
      ],
    );
  }

  Widget _english() {
    return Row(
      children: [
        Assets.png.english64.image(height: _iconHeight, width: _iconWidth),
        SizedBox(width: SizeConfig.mediumSmallMargin),
        Flexible(child: TextWidget.titleGrayLargeBold(this.widget.tangoEntity.english!, maxLines: 2)),
      ],
    );
  }

  Widget _exampleHeader() {
    return Row(
      children: [
        TextWidget.titleRedMedium('例文', maxLines: 1),
        SizedBox(width: SizeConfig.mediumSmallMargin),
        Flexible(child: _separater())
      ],
    );
  }

  Widget _descriptionHeader() {
    return Row(
      children: [
        TextWidget.titleRedMedium('豆知識', maxLines: 1),
        SizedBox(width: SizeConfig.mediumSmallMargin),
        Flexible(child: _separater())
      ],
    );
  }

  Widget _example() {
    return Row(
      children: [
        Assets.png.example64.image(height: _iconHeight, width: _iconWidth),
        SizedBox(width: SizeConfig.mediumSmallMargin),
        Flexible(child: TextWidget.titleBlackLargeBold(this.widget.tangoEntity.example!, maxLines: 5)),
      ],
    );
  }

  Widget _exampleJp() {
    return Row(
      children: [
        Assets.png.japan64.image(height: _iconHeight, width: _iconWidth),
        SizedBox(width: SizeConfig.mediumSmallMargin),
        Flexible(child: TextWidget.titleGrayMediumBold(this.widget.tangoEntity.exampleJp!, maxLines: 5)),
      ],
    );
  }

  Widget _description() {
    return Visibility(
      visible: this.widget.tangoEntity.description != null && this.widget.tangoEntity.description != '',
      child: Row(
        children: [
          Assets.png.infoNotes.image(height: _iconHeight, width: _iconWidth),
          SizedBox(width: SizeConfig.mediumSmallMargin),
          Flexible(child: TextWidget.titleGrayMediumBold(this.widget.tangoEntity.description ?? '', maxLines: 10)),
        ],
      ),
    );
  }

  Widget _separater() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: SizeConfig.mediumMargin),
      child: Container(
        height: 1,
        width: double.infinity,
        color: ColorConfig.bgGreySeparater,
      ),
    );
  }

  Widget _soundButton(String data) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        GestureDetector(
          onTap: () {
            flutterTts.speak(data);
          },
          child: Padding(
            padding: const EdgeInsets.all(SizeConfig.mediumSmallMargin),
            child: Lottie.asset(
              Assets.lottie.speaker,
              height: 50,
            ),
          ),
        ),
      ],
    );
  }
}
