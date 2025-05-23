// Dart imports:
import 'dart:io';

// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:lottie/lottie.dart';

// Project imports:
import 'package:indonesia_flash_card/config/color_config.dart';
import 'package:indonesia_flash_card/config/size_config.dart';
import 'package:indonesia_flash_card/gen/assets.gen.dart';
import 'package:indonesia_flash_card/model/part_of_speech.dart';
import 'package:indonesia_flash_card/model/tango_entity.dart';
import 'package:indonesia_flash_card/utils/common_text_widget.dart';
import '../config/config.dart';
import '../model/floor_database/database.dart';
import '../model/floor_entity/word_status.dart';
import '../model/floor_migrations/migration_v1_to_v2_add_bookmark_column_in_word_status_table.dart';
import '../model/floor_migrations/migration_v2_to_v3_add_tango_table.dart';
import '../model/word_status_type.dart';
import '../utils/analytics/analytics_event_entity.dart';
import '../utils/analytics/analytics_parameters.dart';
import '../utils/analytics/firebase_analytics.dart';
import '../utils/shared_preference.dart';
import '../utils/shimmer.dart';

class DictionaryDetail extends ConsumerStatefulWidget {

  const DictionaryDetail({Key? key, required this.tangoEntity}) : super(key: key);
  final TangoEntity tangoEntity;

  static void navigateTo(
      BuildContext context,
      {required TangoEntity tangoEntity,}) {
    Navigator.push<void>(context, MaterialPageRoute(
      builder: (context) {
        return DictionaryDetail(tangoEntity: tangoEntity);
      },
    ),);
  }

  @override
  ConsumerState<DictionaryDetail> createState() => _DictionaryDetailState();
}

class _DictionaryDetailState extends ConsumerState<DictionaryDetail> {
  FlutterTts flutterTts = FlutterTts();
  bool _isSoundOn = true;
  final _iconHeight = 20.0;
  final _iconWidth = 20.0;
  AppDatabase? database;

  @override
  void initState() {
    FirebaseAnalyticsUtils.analytics.logScreenView(
        screenName: AnalyticsScreen.dictionaryDetail.name,);
    initializeDB();
    super.initState();
    setTTSandLoadSoundSetting();
  }

  Future<void> setTTSandLoadSoundSetting() async {
    await setTTS();
    await loadSoundSetting();
  }

  Future<void> setTTS() async {
    await flutterTts.setLanguage('id-ID');
    if (Platform.isIOS) {
      await flutterTts.setSharedInstance(true);
      await flutterTts.setIosAudioCategory(IosTextToSpeechAudioCategory.playback,
        [
          IosTextToSpeechAudioCategoryOptions.allowBluetooth,
          IosTextToSpeechAudioCategoryOptions.allowBluetoothA2DP,
          IosTextToSpeechAudioCategoryOptions.mixWithOthers,
        ],
        IosTextToSpeechAudioMode.voicePrompt,
      );
    } else if (Platform.isAndroid) {
      await flutterTts.setSilence(2);
    }
  }

  Future<void> loadSoundSetting() async {
    _isSoundOn = await PreferenceKey.isSoundOn.getBool();
    setState(() {});
    if (_isSoundOn) {
      await flutterTts.speak(widget.tangoEntity.indonesian ?? '');
    }
  }

  Future<void> initializeDB() async {
    final _database = await $FloorAppDatabase
        .databaseBuilder(Config.dbName)
        .addMigrations([migration1to2, migration2to3])
        .build();
    setState(() => database = _database);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorConfig.bgPinkColor,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(SizeConfig.smallMargin),
          child: Stack(
            children: [
              Card(
                child: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.all(SizeConfig.mediumSmallMargin),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _topBarSection(),
                        _partOfSpeech(),
                        const SizedBox(height: SizeConfig.smallMargin),
                        _indonesian(),
                        const SizedBox(height: SizeConfig.smallestMargin),
                        _separater(),
                        _japanese(),
                        const SizedBox(height: SizeConfig.smallMargin),
                        _english(),
                        const SizedBox(height: SizeConfig.smallMargin),
                        _exampleHeader(),
                        const SizedBox(height: SizeConfig.smallMargin),
                        _example(),
                        const SizedBox(height: SizeConfig.smallMargin),
                        _exampleJp(),
                        const SizedBox(height: SizeConfig.smallMargin),
                        _descriptionHeader(),
                        const SizedBox(height: SizeConfig.smallMargin),
                        _description(),
                        const SizedBox(height: SizeConfig.smallMargin),
                      ],
                    ),
                  ),
                ),
              ),
              bookmark(widget.tangoEntity),
            ],
          ),
        ),
      ),
    );
  }

  Widget bookmark(TangoEntity entity) {
    final wordStatusDao = database?.wordStatusDao;

    return FutureBuilder(
        future: getBookmark(entity),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            var status = snapshot.data as WordStatus?;
            var isBookmark = status == null ? false : status.isBookmarked;
            if (status == null) {
              status = WordStatus(wordId: entity.id!, status: WordStatusType.notLearned.id);
              wordStatusDao?.insertWordStatus(status);
            }
            return Padding(
              padding: const EdgeInsets.only(left: SizeConfig.mediumSmallMargin),
              child: InkWell(
                onTap: () {
                  analytics(DictionaryDetailItem.bookmark);
                  wordStatusDao?.updateWordStatus(status!..isBookmarked = !isBookmark);
                  setState(() => isBookmark = !isBookmark);
                },
                child: isBookmark ? Assets.png.bookmarkOn64.image(height: 32, width: 32)
                    : Assets.png.bookmarkOff64.image(height: 32, width: 32),
              ),
            );
          } else {
            return  const Padding(
              padding: EdgeInsets.only(left: SizeConfig.mediumSmallMargin),
              child: ShimmerWidget.rectangular(width: 24, height: 24,),
            );
          }
        },);
  }

  Future<WordStatus?> getBookmark(TangoEntity entity) async {
    final wordStatusDao = database?.wordStatusDao;
    final wordStatus = await wordStatusDao?.findWordStatusById(entity.id!);
    return wordStatus;
  }

  Widget _topBarSection() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _soundButton(widget.tangoEntity.indonesian!),
        IconButton(
            onPressed: () {
              analytics(DictionaryDetailItem.close);
              Navigator.pop(context);
            },
            icon: const Icon(Icons.close,
              color: ColorConfig.bgGrey,
              size: SizeConfig.largeSmallMargin,
            ),),
      ],
    );
  }

  Widget _partOfSpeech() {
    return Row(
      children: [
        TextWidget.titleWhiteSmallBoldWithBackGround(PartOfSpeechExt.intToPartOfSpeech(value: widget.tangoEntity.partOfSpeech!).title),
        const SizedBox(width: SizeConfig.mediumSmallMargin),
      ],
    );
  }

  Widget _indonesian() {
    return Row(
      children: [
        Assets.png.indonesia64.image(height: _iconHeight, width: _iconWidth),
        const SizedBox(width: SizeConfig.mediumSmallMargin),
        Flexible(
            child: TextWidget.titleBlackLargestBoldSelectable(
                widget.tangoEntity.indonesian!,
                maxLines: 2,
            ),
        ),
      ],
    );
  }

  Widget _japanese() {
    return Row(
      children: [
        Assets.png.japanFuji64.image(height: _iconHeight, width: _iconWidth),
        const SizedBox(width: SizeConfig.mediumSmallMargin),
        Flexible(
            child: TextWidget.titleGrayLargeBoldSelectable(
                widget.tangoEntity.japanese!,
                maxLines: 2,
            ),
        ),
      ],
    );
  }

  Widget _english() {
    return Row(
      children: [
        Assets.png.english64.image(height: _iconHeight, width: _iconWidth),
        const SizedBox(width: SizeConfig.mediumSmallMargin),
        Flexible(
            child: TextWidget.titleGrayLargeBoldSelectable(
                widget.tangoEntity.english!,
                maxLines: 2,
            ),
        ),
      ],
    );
  }

  Widget _exampleHeader() {
    return Row(
      children: [
        TextWidget.titleRedMedium('例文'),
        const SizedBox(width: SizeConfig.mediumSmallMargin),
        Flexible(child: _separater()),
      ],
    );
  }

  Widget _descriptionHeader() {
    return Visibility(
      visible: widget.tangoEntity.description != null && widget.tangoEntity.description != '',
      child: Row(
        children: [
          TextWidget.titleRedMedium('豆知識'),
          const SizedBox(width: SizeConfig.mediumSmallMargin),
          Flexible(child: _separater()),
        ],
      ),
    );
  }

  Widget _example() {
    return Row(
      children: [
        Assets.png.example64.image(height: _iconHeight, width: _iconWidth),
        const SizedBox(width: SizeConfig.mediumSmallMargin),
        Flexible(
            child: TextWidget.titleBlackLargeBoldSelectable(
                widget.tangoEntity.example!,
                maxLines: 5,
            ),
        ),
      ],
    );
  }

  Widget _exampleJp() {
    return Row(
      children: [
        Assets.png.japan64.image(height: _iconHeight, width: _iconWidth),
        const SizedBox(width: SizeConfig.mediumSmallMargin),
        Flexible(
            child: TextWidget.titleGrayMediumBoldSelectable(
                widget.tangoEntity.exampleJp!,
                maxLines: 5,
            ),
        ),
      ],
    );
  }

  Widget _description() {
    return Visibility(
      visible: widget.tangoEntity.description != null && widget.tangoEntity.description != '',
      child: Row(
        children: [
          Assets.png.infoNotes.image(height: _iconHeight, width: _iconWidth),
          const SizedBox(width: SizeConfig.mediumSmallMargin),
          Flexible(
              child: TextWidget.titleGrayMediumBoldSelectable(
                  widget.tangoEntity.description ?? '',
                  maxLines: 10,
              ),
          ),
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
            analytics(DictionaryDetailItem.sound);
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

  void analytics(DictionaryDetailItem item, {String? others = ''}) {
    final eventDetail = AnalyticsEventAnalyticsEventDetail()
      ..id = item.id
      ..screen = AnalyticsScreen.lectureSelector.name
      ..item = item.shortName
      ..action = AnalyticsActionType.tap.name
      ..others = others;
    FirebaseAnalyticsUtils.eventsTrack(AnalyticsEventEntity()
      ..name = item.name
      ..analyticsEventDetail = eventDetail,);
  }
}
