import 'dart:io';

import 'package:carousel_slider/carousel_slider.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:in_app_review/in_app_review.dart';
import 'package:indonesia_flash_card/config/color_config.dart';
import 'package:indonesia_flash_card/config/size_config.dart';
import 'package:indonesia_flash_card/domain/file_service.dart';
import 'package:indonesia_flash_card/domain/tango_list_service.dart';
import 'package:indonesia_flash_card/gen/assets.gen.dart';
import 'package:indonesia_flash_card/model/category.dart';
import 'package:indonesia_flash_card/model/floor_entity/activity.dart';
import 'package:indonesia_flash_card/model/floor_entity/word_status.dart';
import 'package:indonesia_flash_card/model/frequency.dart';
import 'package:indonesia_flash_card/model/lecture.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:indonesia_flash_card/model/level.dart';
import 'package:indonesia_flash_card/model/part_of_speech.dart';
import 'package:indonesia_flash_card/model/word_status_type.dart';
import 'package:indonesia_flash_card/screen/lesson_selector/views/lesson_card.dart';
import 'package:indonesia_flash_card/screen/quiz_screen.dart';
import 'package:indonesia_flash_card/utils/analytics/analytics_event_entity.dart';
import 'package:indonesia_flash_card/utils/analytics/analytics_parameters.dart';
import 'package:indonesia_flash_card/utils/analytics/firebase_analytics.dart';
import 'package:indonesia_flash_card/utils/common_text_widget.dart';
import 'package:indonesia_flash_card/utils/logger.dart';
import 'package:indonesia_flash_card/utils/shared_preference.dart';
import 'package:indonesia_flash_card/utils/shimmer.dart';
import 'package:indonesia_flash_card/utils/utils.dart';
import 'package:lottie/lottie.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

import '../../config/config.dart';
import '../../model/floor_database/database.dart';
import '../../model/floor_migrations/migration_v1_to_v2_add_bookmark_column_in_word_status_table.dart';
import '../flush_card_screen.dart';

class LessonSelectorScreen extends ConsumerStatefulWidget {
  const LessonSelectorScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<LessonSelectorScreen> createState() => _LessonSelectorScreenState();

  static void navigateTo(BuildContext context) {
    Navigator.push<void>(context, MaterialPageRoute(
      builder: (context) {
        return const LessonSelectorScreen();
      },
    ));
  }
}

class _LessonSelectorScreenState extends ConsumerState<LessonSelectorScreen> {
  late Future<List<LectureFolder>> getPossibleLectures;
  int _currentFrequencyIndex = 0;
  final CarouselController _frequencyCarouselController = CarouselController();
  int _currentLevelIndex = 0;
  final CarouselController _levelCarouselController = CarouselController();
  int _currentCategoryIndex = 0;
  final CarouselController _categoryCarouselController = CarouselController();
  int _currentPartOfSpeechIndex = 0;
  final CarouselController _partOfSpeechCarouselController = CarouselController();
  List<WordStatus> wordStatusList = [];
  List<WordStatus> bookmarkList = [];
  List<Activity> activityList = [];
  late AppDatabase database;
  late BannerAd bannerAd;
  final RefreshController _refreshController =
    RefreshController(initialRefresh: false);
  bool _isAlreadyTestedToday = false;

  @override
  void initState() {
    FirebaseAnalyticsUtils.analytics.setCurrentScreen(screenName: AnalyticsScreen.lectureSelector.name);
    initializeDB();
    super.initState();
    initTangoList();
    initFCM();
    initializeBannerAd();
    _confirmAlreadyTestedToday();
  }

  void initializeDB() async {
    final _database = await $FloorAppDatabase
        .databaseBuilder(Config.dbName)
        .addMigrations([migration1to2])
        .build();
    setState(() => database = _database);

    getAllWordStatus();
    getAllActivity();
    getBookmark();
  }

  Future<void> initTangoList() async {
    final lectures = await ref.read(fileControllerProvider.notifier).getPossibleLectures();
    await ref.read(tangoListControllerProvider.notifier).getAllTangoList(folder: lectures.first);
  }

  void initFCM() async {
    FirebaseMessaging messaging = FirebaseMessaging.instance;

    NotificationSettings settings = await messaging.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );

    logger.d('FCM User granted permission: ${settings.authorizationStatus}');

    final fcmToken = await messaging.getToken();
    logger.d('FCM token: $fcmToken');
  }

  @override
  Widget build(BuildContext context) {
    final tangoMaster = ref.watch(tangoListControllerProvider);
    return Stack(
      children: [
        SmartRefresher(
          enablePullDown: true,
          controller: _refreshController,
          header: WaterDropMaterialHeader(
            backgroundColor: Theme.of(context).primaryColor,
          ),
          onRefresh: _onRefresh,
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(
                  SizeConfig.mediumMargin,
                  SizeConfig.mediumMargin,
                  SizeConfig.mediumMargin,
                  SizeConfig.bottomBarHeight),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  _userSection(),
                  _todayTangTest(),
                  _bookMarkLecture(),
                  _notRememberTangoLecture(),
                  _sectionTitle('頻出度別'),
                  _carouselFrequencyLectures(),
                  _adWidget(),
                  _sectionTitle('レベル別'),
                  _carouselLevelLectures(),
                  _sectionTitle('カテゴリー別'),
                  _carouselCategoryLectures(),
                  _sectionTitle('品詞別'),
                  _carouselPartOfSpeechLectures(),
                ],
              ),
            ),
          ),
        ),
        Visibility(
          visible: tangoMaster.dictionary.allTangos.isEmpty,
          child: Container(
            color: Colors.black.withOpacity(0.2),
            child: Center(
              child: Lottie.asset(
                Assets.lottie.splashScreen,
                height: 300,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _adWidget() {
    return Container(
      height: 50,
      width: double.infinity,
      child: AdWidget(ad: bannerAd),
    );
  }

  Widget _userSection() {
    final tangoMaster = ref.watch(tangoListControllerProvider);
    return Card(
        child: Container(
            height: 120,
            width: double.infinity,
            child: Column(
              children: [
                Container(
                  height: 90,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _userSectionItem(
                          title: '総単語数',
                          data: tangoMaster.dictionary.allTangos.length,
                          unitTitle: '単語'
                      ),
                      _separater(),
                      _userSectionItemTangoStatus(title: '覚えた単語数'),
                      _separater(),
                      _userSectionItem(
                          title: '累計学習日数',
                          data: activityList.map((e) => e.date).toList().toSet().toList().length,
                          unitTitle: '日'
                      ),
                    ],
                  ),
                ),
                LinearPercentIndicator(
                  width: MediaQuery.of(context).size.width - 40,
                  animation: true,
                  lineHeight: 20.0,
                  animationDuration: 2500,
                  percent: tangoMaster.totalAchievement,
                  center: Text('${(tangoMaster.totalAchievement*100).toStringAsFixed(2)} %'),
                  linearStrokeCap: LinearStrokeCap.roundAll,
                  progressColor: ColorConfig.green,
                ),
              ],
            )
        )
    );
  }

  Widget _todayTangTest() {
    return Visibility(
      visible: !_isAlreadyTestedToday,
      child: Card(
          child: InkWell(
            onTap: () async {
              if (await _confirmAlreadyTestedToday()) {
                Utils.showSimpleAlert(context,
                    title: 'インドネシア語単語力検定は1日1回となっております。',
                    content: 'また明日お待ちしております。');
              } else {
                analytics(LectureSelectorItem.todayTest);
                ref.read(tangoListControllerProvider.notifier).setTestData();
                QuizScreen.navigateTo(context);
              }
            },
            child: Container(
                height: 40,
                width: double.infinity,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: SizeConfig.mediumSmallMargin),
                          child: Assets.png.test128.image(height: 20, width: 20),
                        ),
                        TextWidget.titleGraySmallBold('今日のインドネシア単語力検定'),
                      ],
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: SizeConfig.mediumSmallMargin),
                      child: Icon(Icons.arrow_forward_ios_sharp, size: 20),
                    )
                  ],
                )
            ),
          )
      ),
    );
  }

  Future<bool> _confirmAlreadyTestedToday() async {
    bool _tmpIsAlradyTestedToday = false;
    final lastTestDate = await PreferenceKey.lastTestDate.getString();
    if (lastTestDate == null) {
      _tmpIsAlradyTestedToday = false;
    } else {
      _tmpIsAlradyTestedToday =
          lastTestDate == Utils.dateTimeToString(DateTime.now());
    }
    setState(() => _isAlreadyTestedToday = _tmpIsAlradyTestedToday);
    return _tmpIsAlradyTestedToday;
  }

  Widget _bookMarkLecture() {
    return Visibility(
      visible: bookmarkList.isNotEmpty,
      child: Card(
          child: InkWell(
            onTap: () {
              analytics(LectureSelectorItem.bookmarkLesson);
              ref.read(tangoListControllerProvider.notifier).setBookmarkLessonsData();
              FlashCardScreen.navigateTo(context);
            },
            child: Container(
                height: 40,
                width: double.infinity,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: SizeConfig.mediumSmallMargin),
                          child: Assets.png.bookmarkOn64.image(height: 20, width: 20),
                        ),
                        TextWidget.titleGraySmallBold('ブックマークの復習 ${bookmarkList.length}語'),
                      ],
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: SizeConfig.mediumSmallMargin),
                      child: Icon(Icons.arrow_forward_ios_sharp, size: 20),
                    )
                  ],
                )
            ),
          )
      ),
    );
  }

  Widget _notRememberTangoLecture() {
    return Visibility(
      visible: wordStatusList.where((element)
        => element.status == WordStatusType.notRemembered.id).isNotEmpty,
      child: Card(
          child: InkWell(
            onTap: () {
              ref.read(tangoListControllerProvider.notifier).setNotRememberedTangoLessonsData();
              FlashCardScreen.navigateTo(context);
            },
            child: Container(
                height: 40,
                width: double.infinity,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: SizeConfig.mediumSmallMargin),
                          child: Assets.png.cancelRed128.image(height: 20, width: 20),
                        ),
                        TextWidget.titleGraySmallBold('未暗記・誤答の復習 ${wordStatusList.where((element) => element.status == WordStatusType.notRemembered.id).length}語'),
                      ],
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: SizeConfig.mediumSmallMargin),
                      child: Icon(Icons.arrow_forward_ios_sharp, size: 20),
                    )
                  ],
                )
            ),
          )
      ),
    );
  }

  Widget _userSectionItem({required String title, required int data, required String unitTitle}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Padding(
          padding: const EdgeInsets.all(SizeConfig.smallMargin),
          child: TextWidget.titleRedMedium(title),
        ),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(SizeConfig.smallMargin, 0, SizeConfig.smallMargin, SizeConfig.smallMargin,),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                TextWidget.titleBlackLargeBold(data.toString()),
                TextWidget.titleGraySmallBold(unitTitle),
              ],
            ),
          ),
        )
      ],
    );
  }

  Widget _userSectionItemTangoStatus({required String title}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Padding(
          padding: const EdgeInsets.all(SizeConfig.smallMargin),
          child: TextWidget.titleRedMedium(title),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            wordStatus(WordStatusType.perfectRemembered),
            SizedBox(width: SizeConfig.smallestMargin),
            TextWidget.titleBlackMediumBold(
                wordStatusList.where((element)
                  => element.status == WordStatusType.perfectRemembered.id)
                    .length.toString()),
          ],
        ),
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            wordStatus(WordStatusType.remembered),
            SizedBox(width: SizeConfig.smallestMargin),
            TextWidget.titleBlackMediumBold(
                wordStatusList.where((element)
                => element.status == WordStatusType.remembered.id)
                    .length.toString()),
          ],
        ),
      ],
    );
  }

  Widget wordStatus(WordStatusType statusType) {
    return Row(
      children: [
        statusType.icon,
        SizedBox(width: SizeConfig.smallestMargin),
        TextWidget.titleGraySmallest(statusType.title),
      ],
    );
  }

  Widget _separater() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: SizeConfig.mediumMargin),
      child: Container(
        height: double.infinity,
        width: 1,
        color: ColorConfig.bgGreySeparater,
      ),
    );
  }

  Widget _sectionTitle(String title) {
    return Padding(
      padding: EdgeInsets.fromLTRB(0, SizeConfig.mediumMargin, SizeConfig.mediumSmallMargin, SizeConfig.smallMargin),
      child: TextWidget.titleBlackLargeBold(title),
    );
  }

  Widget _carouselFrequencyLectures() {
    return _carouselLectures(
      items: _frequencyWidgets(),
      controller: _frequencyCarouselController,
      index: _currentFrequencyIndex,
    );
  }

  Widget _carouselLevelLectures() {
    return _carouselLectures(
      items: _levelWidgets(),
      controller: _levelCarouselController,
      index: _currentLevelIndex,
    );
  }

  Widget _carouselCategoryLectures() {
    return _carouselLectures(
      items: _categoryWidgets(),
      controller: _categoryCarouselController,
      index: _currentCategoryIndex,
      autoPlay: true,
    );
  }

  Widget _carouselPartOfSpeechLectures() {
    return _carouselLectures(
      items: _partOfSpeechWidgets(),
      controller: _partOfSpeechCarouselController,
      index: _currentPartOfSpeechIndex,
    );
  }

  Widget _carouselLectures({
    required List<Widget> items,
    required CarouselController controller,
    required int index,
    bool autoPlay = false,
    bool visibleIndicator = false,
    bool enlargeCenterPage = false}) {
    return Column(
      children: [
        CarouselSlider(
          items: items,
          carouselController: controller,
          options: CarouselOptions(
              autoPlay: autoPlay,
              enlargeCenterPage: enlargeCenterPage,
              viewportFraction: 0.3,
              aspectRatio: 2.0,
              onPageChanged: (_index, reason) {
                setState(() => index = _index);
              }
          ),
        ),
        Visibility(
          visible: visibleIndicator,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: _categoryWidgets().asMap().entries.map((entry) {
              return GestureDetector(
                onTap: () => controller.animateToPage(entry.key),
                child: Container(
                  width: 8.0,
                  height: 8.0,
                  margin: EdgeInsets.symmetric(vertical: 8.0, horizontal: 4.0),
                  decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: (ColorConfig.primaryRed900)
                          .withOpacity(index == entry.key ? 0.9 : 0.2)),
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  List<Widget> _frequencyWidgets() {
    List<Widget> _frequency = [];
    FrequencyGroup.values.forEach((element) {
      _frequency.add(LessonCard(frequencyGroup: element));
    });
    return _frequency;
  }

  List<Widget> _levelWidgets() {
    List<Widget> _levels = [];
    LevelGroup.values.forEach((element) {
      _levels.add(LessonCard(levelGroup: element));
    });
    return _levels;
  }

  List<Widget> _categoryWidgets() {
    List<Widget> _categories = [];
    TangoCategory.values.forEach((element) {
      _categories.add(LessonCard(category: element));
    });
    return _categories;
  }

  List<Widget> _partOfSpeechWidgets() {
    List<Widget> _partOfSpeechs = [];
    PartOfSpeechEnum.values.forEach((element) {
      _partOfSpeechs.add(LessonCard(partOfSpeech: element));
    });
    return _partOfSpeechs;
  }

  Future<void> getAllWordStatus() async {
    final wordStatusDao = database.wordStatusDao;
    final wordStatus = await wordStatusDao.findAllWordStatus();
    setState(() => wordStatusList = wordStatus);
  }

  Future<void> getAllActivity() async {
    final activityDao = database.activityDao;
    final _activityList = await activityDao.findAllActivity();
    setState(() => activityList = _activityList);

    _requestAppReview();
  }

  Future<void> _requestAppReview() async {
    if (activityList.map((e) => e.date).toList().toSet().toList().length >= 10) {
      final inAppReview = InAppReview.instance;

      if (await inAppReview.isAvailable()) {
        await inAppReview.requestReview();
      }
    }
  }

  Future<void> getBookmark() async {
    final wordStatusDao = database.wordStatusDao;
    final wordStatus = await wordStatusDao.findBookmarkWordStatus();
    setState(() => bookmarkList = wordStatus);
  }

  void analytics(LectureSelectorItem item, {String? others = ''}) {
    final eventDetail = AnalyticsEventAnalyticsEventDetail()
      ..id = item.id.toString()
      ..screen = AnalyticsScreen.lectureSelector.name
      ..item = item.shortName
      ..action = AnalyticsActionType.tap.name
      ..others = others;
    FirebaseAnalyticsUtils.eventsTrack(AnalyticsEventEntity()
      ..name = item.name
      ..analyticsEventDetail = eventDetail);
  }

  void initializeBannerAd() {
    final BannerAdListener listener = BannerAdListener(
      onAdLoaded: (Ad ad) => logger.d('Ad loaded.${ad}'),
      onAdFailedToLoad: (Ad ad, LoadAdError error) {
        ad.dispose();
        logger.d('Ad failed to load: $error');
      },
      onAdOpened: (Ad ad) => logger.d('Ad opened.'),
      onAdClosed: (Ad ad) => logger.d('Ad closed.'),
      onAdImpression: (Ad ad) => logger.d('Ad impression.'),
    );

    setState(() {
      bannerAd = BannerAd(
        adUnitId: Platform.isIOS ? Config.adUnitIdIosBanner : Config.adUnitIdAndroidBanner,
        size: AdSize.banner,
        request: AdRequest(),
        listener: listener,
      );
    });

    bannerAd.load();
  }

  void _onRefresh() async{
    initializeDB();
    await initTangoList();
    _refreshController.refreshCompleted();
  }
}
