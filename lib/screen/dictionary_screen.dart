// Dart imports:
import 'dart:io';
import 'dart:math' as math;

// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:material_floating_search_bar_2/material_floating_search_bar_2.dart';

// Project imports:
import 'package:indonesia_flash_card/config/color_config.dart';
import 'package:indonesia_flash_card/config/size_config.dart';
import 'package:indonesia_flash_card/domain/tango_list_service.dart';
import 'package:indonesia_flash_card/gen/assets.gen.dart';
import 'package:indonesia_flash_card/model/category.dart';
import 'package:indonesia_flash_card/model/filter_type.dart';
import 'package:indonesia_flash_card/model/level.dart';
import 'package:indonesia_flash_card/model/sort_type.dart';
import 'package:indonesia_flash_card/model/tango_entity.dart';
import 'package:indonesia_flash_card/model/word_status_type.dart';
import 'package:indonesia_flash_card/screen/dictionary_detail_screen.dart';
import 'package:indonesia_flash_card/utils/admob.dart';
import 'package:indonesia_flash_card/utils/common_text_widget.dart';
import 'package:indonesia_flash_card/utils/logger.dart';
import 'package:indonesia_flash_card/utils/shimmer.dart';
import '../config/config.dart';
import '../model/floor_database/database.dart';
import '../model/floor_entity/word_status.dart';
import '../model/floor_migrations/migration_v1_to_v2_add_bookmark_column_in_word_status_table.dart';
import '../model/floor_migrations/migration_v2_to_v3_add_tango_table.dart';
import '../utils/analytics/analytics_event_entity.dart';
import '../utils/analytics/analytics_parameters.dart';
import '../utils/analytics/firebase_analytics.dart';

class DictionaryScreen extends ConsumerStatefulWidget {
  const DictionaryScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<DictionaryScreen> createState() => _DictionaryScreenState();

  static void navigateTo(BuildContext context) {
    Navigator.push<void>(context, MaterialPageRoute(
      builder: (context) {
        return const DictionaryScreen();
      },
    ),);
  }
}

class _DictionaryScreenState extends ConsumerState<DictionaryScreen> {
  final itemCardHeight = 88.0;
  final GlobalKey<ScaffoldState> _key = GlobalKey();
  SortType _selectedSortType = SortType.indonesian;
  TangoCategory? _selectedCategory;
  LevelGroup? _selectedLevelGroup;
  WordStatusType? _selectedWordStatusType;
  List<TangoEntity> _searchedTango = [];
  AppDatabase? database;
  late BannerAd bannerAd;
  InterstitialAd? _interstitialAd;

  @override
  void initState() {
    FirebaseAnalyticsUtils.analytics.setCurrentScreen(screenName: AnalyticsScreen.dictionary.name);
    initializeDB();
    super.initState();
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
    final tangoList = ref.watch(tangoListControllerProvider);
    return Scaffold(
      key: _key,
      backgroundColor: ColorConfig.bgPinkColor,
      extendBody: true,
      body: Stack(
        children: [
          ListView.builder(
            padding: const EdgeInsets.fromLTRB(0, 64, 0, SizeConfig.bottomBarHeight),
            itemBuilder: (BuildContext context, int index){
              if (index == 0) {
                return Container();
                return SizedBox(
                  height: 50,
                  width: double.infinity,
                  child: AdWidget(ad: bannerAd),
                );
              }
              final tango = tangoList.dictionary.sortAndFilteredTangos[index - 1];
              return tangoListItem(tango);
            },
            itemCount: tangoList.dictionary.sortAndFilteredTangos.length + 1,
          ),
          buildFloatingSearchBar(),
        ],
      ),
      floatingActionButton: sortAndFilterButton(),
      endDrawer: sortAndFilterDrawer(),
    );
  }
  
  Widget tangoListItem(TangoEntity tango) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: SizeConfig.mediumSmallMargin),
      child: InkWell(
        onTap: () async {
          analytics(DictionaryItem.dictionaryItem);
          final rand = math.Random();
          final lottery = rand.nextInt(4);
          if (lottery == 0) {
            await Admob().showInterstitialAd();
          }

          DictionaryDetail.navigateTo(context, tangoEntity: tango);
        },
        child: Card(
          child: SizedBox(
            width: double.infinity,
            height: itemCardHeight,
            child: Stack(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: SizeConfig.smallMargin, horizontal: SizeConfig.mediumSmallMargin),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      wordStatus(tango),
                      const SizedBox(height: SizeConfig.smallestMargin,),
                      TextWidget.titleBlackMediumBold(tango.indonesian ?? ''),
                      const SizedBox(height: 2,),
                      TextWidget.titleGraySmall(tango.japanese ?? ''),
                    ],
                  ),
                ),
                Align(
                  alignment: Alignment.topRight,
                  child: bookmark(tango),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<WordStatus?> getWordStatus(TangoEntity entity) async {
    final wordStatusDao = database?.wordStatusDao;
    final wordStatus = await wordStatusDao?.findWordStatusById(entity.id!);
    return wordStatus;
  }

  Future<WordStatus?> getBookmark(TangoEntity entity) async {
    final wordStatusDao = database?.wordStatusDao;
    final wordStatus = await wordStatusDao?.findWordStatusById(entity.id!);
    return wordStatus;
  }

  Widget bookmark(TangoEntity entity) {
    return FutureBuilder(
        future: getBookmark(entity),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            final status = snapshot.data as WordStatus?;
            final isBookmark = status == null ? false : status.isBookmarked;
            return Visibility(
              visible: isBookmark,
              child: Padding(
                padding: const EdgeInsets.only(right: SizeConfig.mediumSmallMargin),
                child: Assets.png.bookmarkOn64.image(height: 24, width: 24),
              ),
            );
          } else {
            return  const Padding(
              padding: EdgeInsets.only(right: SizeConfig.mediumSmallMargin),
              child: ShimmerWidget.rectangular(width: 24, height: 24,),
            );
          }
        },);
  }

  Widget sortAndFilterButton() {
    return Padding(
      padding: const EdgeInsets.only(bottom: SizeConfig.bottomBarHeight),
      child: FloatingActionButton(
        backgroundColor: ColorConfig.primaryRed900,
        child: Assets.png.sort128.image(width: 32, height: 32),
        onPressed: () {
          analytics(DictionaryItem.showSortFilter);
          _key.currentState!.openEndDrawer();
        },
      ),
    );
  }

  Widget sortAndFilterDrawer() {
    return Drawer(
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _filterHeader(),
            const SizedBox(height: SizeConfig.smallMargin,),
            filterItems(),
            const SizedBox(height: SizeConfig.mediumSmallMargin),
            _sortHeader(),
            const SizedBox(height: SizeConfig.smallMargin),
            sortItems(),
            const SizedBox(height: SizeConfig.bottomBarHeight,),
          ],
        ),
      ),
    );
  }

  Widget _filterHeader() {
    return Padding(
      padding: const EdgeInsets.all(SizeConfig.mediumSmallMargin),
      child: Row(
        children: [
          Assets.png.filter64.image(height: 20, width: 20),
          const SizedBox(width: SizeConfig.mediumSmallMargin),
          TextWidget.titleGraySmallBold('フィルタ'),
        ],
      ),
    );
  }

  Widget _sortHeader() {
    return Padding(
      padding: const EdgeInsets.all(SizeConfig.mediumSmallMargin),
      child: Row(
        children: [
          Assets.png.sort64.image(height: 20, width: 20),
          const SizedBox(width: SizeConfig.mediumSmallMargin),
          TextWidget.titleGraySmallBold('ソート'),
        ],
      ),
    );
  }

  Widget sortItems() {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(vertical: SizeConfig.smallMargin, horizontal: SizeConfig.mediumLargeMargin),
      itemBuilder: (BuildContext context, int index){
        final sortType = SortType.values[index];
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: SizeConfig.mediumSmallMargin),
          child: Card(
            child: InkWell(
              onTap: () async {
                analytics(DictionaryItem.sort, others: sortType.name);
                setState(() => _selectedSortType = sortType);
                await ref.read(tangoListControllerProvider.notifier)
                    .getSortAndFilteredTangoList(
                      category: _selectedCategory,
                      levelGroup: _selectedLevelGroup,
                      wordStatusType: _selectedWordStatusType,
                      sortType: sortType,);
              },
              child: SizedBox(
                width: double.infinity,
                height: 40,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: SizeConfig.smallMargin),
                  child: Row(
                    children: [
                      Visibility(
                          visible: _selectedSortType == sortType,
                          child: Assets.png.checkedGreen128.image(width: 20, height: 20),),
                      const SizedBox(width: SizeConfig.smallestMargin),
                      TextWidget.titleBlackMediumBold(sortType.title),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
      itemCount: SortType.values.length,
    );
  }

  Widget filterItems() {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(vertical: SizeConfig.smallMargin, horizontal: SizeConfig.mediumLargeMargin),
      itemBuilder: (BuildContext context, int index){
        final filterType = FilterType.values[index];
        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.only(left: SizeConfig.smallMargin),
              child: TextWidget.titleGraySmallBold(filterType.title),
            ),
            Padding(
              padding: const EdgeInsets.only(left: SizeConfig.mediumSmallMargin),
              child: filterChildItems(filterType),
            ),
          ],
        );
      },
      itemCount: FilterType.values.length,
    );
  }
  
  Widget filterChildItems(FilterType filterType) {
    switch (filterType) {
      case FilterType.category:
        return filterCategoryItems();
      case FilterType.levelGroup:
        return filterLevelGroupItems();
      case FilterType.wordStatus:
        return filterWordStatusItems();
    }
  } 
  
  Widget filterWordStatusItems() {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(vertical: SizeConfig.smallMargin, horizontal: SizeConfig.mediumLargeMargin),
      itemBuilder: (BuildContext context, int index){
        final wordStatusType = WordStatusType.values[index];
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: SizeConfig.mediumSmallMargin),
          child: Card(
            child: InkWell(
              onTap: () async {
                analytics(DictionaryItem.filter, others: 'wordStatus: ${wordStatusType.name}');
                setState(() => _selectedWordStatusType = wordStatusType);
                await ref.read(tangoListControllerProvider.notifier)
                    .getSortAndFilteredTangoList(
                      category: _selectedCategory,
                      levelGroup: _selectedLevelGroup,
                      wordStatusType: wordStatusType,
                      sortType: _selectedSortType,);
              },
              child: SizedBox(
                width: double.infinity,
                height: 40,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: SizeConfig.smallMargin),
                  child: Row(
                    children: [
                      Visibility(
                          visible: _selectedWordStatusType == wordStatusType,
                          child: Assets.png.checkedGreen128.image(width: 20, height: 20),),
                      const SizedBox(width: SizeConfig.smallestMargin),
                      TextWidget.titleBlackMediumBold(wordStatusType.title),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
      itemCount: WordStatusType.values.length,
    );
  }

  Widget filterCategoryItems() {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(vertical: SizeConfig.smallMargin, horizontal: SizeConfig.mediumLargeMargin),
      itemBuilder: (BuildContext context, int index){
        final tangoCategory = TangoCategory.values[index];
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: SizeConfig.mediumSmallMargin),
          child: Card(
            child: InkWell(
              onTap: () async {
                analytics(DictionaryItem.filter, others: 'tangoCategory: ${tangoCategory.name}');
                setState(() => _selectedCategory = tangoCategory);
                await ref.read(tangoListControllerProvider.notifier)
                    .getSortAndFilteredTangoList(
                      category: tangoCategory,
                      levelGroup: _selectedLevelGroup,
                      wordStatusType: _selectedWordStatusType,
                      sortType: _selectedSortType,);
              },
              child: SizedBox(
                width: double.infinity,
                height: 40,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: SizeConfig.smallMargin),
                  child: Row(
                    children: [
                      Visibility(
                          visible: _selectedCategory == tangoCategory,
                          child: Assets.png.checkedGreen128.image(width: 20, height: 20),),
                      const SizedBox(width: SizeConfig.smallestMargin),
                      TextWidget.titleBlackMediumBold(tangoCategory.title),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
      itemCount: TangoCategory.values.length,
    );
  }

  Widget filterLevelGroupItems() {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(vertical: SizeConfig.smallMargin, horizontal: SizeConfig.mediumLargeMargin),
      itemBuilder: (BuildContext context, int index){
        final levelGroup = LevelGroup.values[index];
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: SizeConfig.mediumSmallMargin),
          child: Card(
            child: InkWell(
              onTap: () async {
                analytics(DictionaryItem.filter, others: 'levelGroup: ${levelGroup.name}');
                setState(() => _selectedLevelGroup = levelGroup);
                await ref.read(tangoListControllerProvider.notifier)
                    .getSortAndFilteredTangoList(
                      category: _selectedCategory,
                      levelGroup: levelGroup,
                      wordStatusType: _selectedWordStatusType,
                      sortType: _selectedSortType,);
              },
              child: SizedBox(
                width: double.infinity,
                height: 40,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: SizeConfig.smallMargin),
                  child: Row(
                    children: [
                      Visibility(
                          visible: _selectedLevelGroup == levelGroup,
                          child: Assets.png.checkedGreen128.image(width: 20, height: 20),),
                      const SizedBox(width: SizeConfig.smallestMargin),
                      TextWidget.titleBlackMediumBold(levelGroup.title),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
      itemCount: LevelGroup.values.length,
    );
  }

  Widget wordStatus(TangoEntity entity) {
    return FutureBuilder(
      future: getWordStatus(entity),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          final status = snapshot.data as WordStatus?;
          final statusType = status == null ? WordStatusType.notLearned : WordStatusTypeExt.intToWordStatusType(status.status);
          return Row(
            children: [
              statusType.icon,
              const SizedBox(width: SizeConfig.smallestMargin),
              TextWidget.titleGraySmallest(statusType.title),
            ],
          );
        } else {
          return const Row(
            children: [
              ShimmerWidget.circular(width: 16, height: 16),
              SizedBox(width: SizeConfig.smallestMargin),
              ShimmerWidget.rectangular(height: 12, width: 80),
            ],
          );
        }
      },);
  }

  Widget buildFloatingSearchBar() {
    final isPortrait =
        MediaQuery.of(context).orientation == Orientation.portrait;

    return FloatingSearchBar(
      scrollPadding: const EdgeInsets.only(top: 16, bottom: SizeConfig.bottomBarHeight),
      transitionDuration: const Duration(milliseconds: 800),
      transitionCurve: Curves.easeInOut,
      physics: const BouncingScrollPhysics(),
      axisAlignment: isPortrait ? 0.0 : -1.0,
      openAxisAlignment: 0,
      width: isPortrait ? 600 : 500,
      debounceDelay: const Duration(milliseconds: 500),
      automaticallyImplyDrawerHamburger: false,
      onQueryChanged: (query) {
        logger.d(query);

        if (query.length >= 2) {
          search(query);
          analytics(DictionaryItem.search, others: query);
        }
      },
      transition: CircularFloatingSearchBarTransition(),
      actions: [
        FloatingSearchBarAction.searchToClear(
          showIfClosed: false,
        ),
      ],
      builder: (context, transition) {
        return ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: _searchedTango.map(tangoListItem).toList(),
          ),
        );
      },
    );
  }

  Future<List<TangoEntity>> search(String search) async {
    final tangoDao = database?.tangoDao;

    final searchTangos =
      await tangoDao?.getTangoListByIndonesian(search.toLowerCase()) ?? [];
    final searchTangosByLikeIndonesian =
        await tangoDao?.getTangoListByLikeIndonesian('%${search.toLowerCase()}%') ?? [];
    searchTangos.addAll(searchTangosByLikeIndonesian);
    final searchTangosByJapanese =
      await tangoDao?.getTangoListByLikeJapanese('%$search%') ?? [];
    searchTangos.addAll(searchTangosByJapanese);

    setState(() => _searchedTango = searchTangos);
    return searchTangos;
  }

  void analytics(DictionaryItem item, {String? others = ''}) {
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

  void initializeBannerAd() {
    final listener = BannerAdListener(
      onAdLoaded: (Ad ad) => logger.d('Ad loaded.$ad'),
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
        request: const AdRequest(),
        listener: listener,
      );
    });

    bannerAd.load();
  }
}
