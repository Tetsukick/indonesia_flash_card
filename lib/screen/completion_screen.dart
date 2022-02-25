import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:indonesia_flash_card/config/color_config.dart';
import 'package:indonesia_flash_card/domain/tango_list_service.dart';
import 'package:indonesia_flash_card/screen/flush_card_screen.dart';
import 'package:indonesia_flash_card/utils/common_text_widget.dart';
import 'package:lottie/lottie.dart';

import '../config/config.dart';
import '../config/size_config.dart';
import '../gen/assets.gen.dart';
import '../model/floor_database/database.dart';
import '../model/floor_entity/word_status.dart';
import '../model/floor_migrations/migration_v1_to_v2_add_bookmark_column_in_word_status_table.dart';
import '../model/tango_entity.dart';
import '../model/word_status_type.dart';
import '../utils/shimmer.dart';
import 'dictionary_detail_screen.dart';

class CompletionScreen extends ConsumerStatefulWidget {
  const CompletionScreen({Key? key}) : super(key: key);

  static navigateTo(context) {
    Navigator.pushReplacement(context, MaterialPageRoute(
      builder: (context) {
        return CompletionScreen();
      },
    ));
  }

  @override
  _CompletionScreenState createState() => _CompletionScreenState();
}

class _CompletionScreenState extends ConsumerState<CompletionScreen> {
  final itemCardHeight = 80.0;
  late AppDatabase database;

  @override
  void initState() {
    initializeDB();
    super.initState();
  }

  void initializeDB() async {
    final _database = await $FloorAppDatabase
        .databaseBuilder(Config.dbName)
        .addMigrations([migration1to2])
        .build();;
    setState(() => database = _database);
  }

  @override
  Widget build(BuildContext context) {
    final tangoList = ref.watch(tangoListControllerProvider);
    return Scaffold(
      backgroundColor: ColorConfig.bgPinkColor,
      body: Container(
        padding: EdgeInsets.all(SizeConfig.mediumSmallMargin),
        height: double.infinity,
        width: double.infinity,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Assets.gif.birBintangKanpai.image(height: 150),
            const SizedBox(height: SizeConfig.mediumSmallMargin),
            TextWidget.titleGraySmallBold('おつかれさまでした!'),
            const SizedBox(height: SizeConfig.smallMargin),
            Flexible(
              child: ListView.builder(
                padding: EdgeInsets.symmetric(vertical: SizeConfig.smallMargin),
                itemBuilder: (BuildContext context, int index){
                  TangoEntity tango = tangoList.lesson.tangos[index];
                  return tangoListItem(tango);
                },
                itemCount: tangoList.lesson.tangos.length,
              ),
            ),
            SizedBox(height: SizeConfig.smallMargin),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _button(
                    onPressed: () {
                      ref.read(tangoListControllerProvider.notifier).resetLessonsData();
                      FlashCardScreen.navigateReplacementTo(context);
                    },
                    img: Assets.png.continue128,
                    title: '同設定で継続'
                ),
                const SizedBox(width: SizeConfig.smallMargin),
                _button(
                    onPressed: () {
                      Navigator.of(context).popUntil((route) => route.isFirst);
                    },
                    img: Assets.png.home128,
                    title: 'トップに戻る'
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget tangoListItem(TangoEntity tango) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 0, horizontal: SizeConfig.mediumSmallMargin),
      child: InkWell(
        onTap: () {
          DictionaryDetail.navigateTo(context, tangoEntity: tango);
        },
        child: Card(
          child: Container(
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
                      SizedBox(height: SizeConfig.smallestMargin,),
                      TextWidget.titleBlackMediumBold(tango.indonesian ?? ''),
                      SizedBox(height: 2,),
                      TextWidget.titleGraySmall(tango.japanese ?? ''),
                    ],
                  ),
                ),
                Align(
                  alignment: Alignment.topRight,
                  child: bookmark(tango),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<WordStatus?> getWordStatus(TangoEntity entity) async {
    final wordStatusDao = database.wordStatusDao;
    final wordStatus = await wordStatusDao.findWordStatusById(entity.id!);
    return wordStatus;
  }

  Future<WordStatus?> getBookmark(TangoEntity entity) async {
    final wordStatusDao = database.wordStatusDao;
    final wordStatus = await wordStatusDao.findWordStatusById(entity.id!);
    return wordStatus;
  }

  Widget _button({required VoidCallback? onPressed, required AssetGenImage img, required String title}) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        primary: Colors.white,
        onPrimary: ColorConfig.primaryRed900,
        shape: const StadiumBorder(),
      ),
      child: SizedBox(
        height: 50,
        width: 112,
        child: Row(
          children: [
            img.image(height: 20, width: 20),
            const SizedBox(width: SizeConfig.smallMargin),
            TextWidget.titleRedMedium(title)
          ],
        ),
      ),
    );
  }

  Widget bookmark(TangoEntity entity) {
    return FutureBuilder(
        future: getBookmark(entity),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            WordStatus? status = snapshot.data as WordStatus?;
            bool isBookmark = status == null ? false : status.isBookmarked;
            return Visibility(
              visible: isBookmark,
              child: Padding(
                padding: const EdgeInsets.only(right: SizeConfig.mediumSmallMargin),
                child: Assets.png.bookmarkOn64.image(height: 24, width: 24),
              ),
            );
          } else {
            return  Padding(
              padding: const EdgeInsets.only(right: SizeConfig.mediumSmallMargin),
              child: ShimmerWidget.rectangular(width: 24, height: 24,),
            );
          }
        });
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
                SizedBox(width: SizeConfig.smallestMargin),
                TextWidget.titleGraySmallest(statusType.title),
              ],
            );
          } else {
            return Row(
              children: [
                ShimmerWidget.circular(width: 16, height: 16),
                SizedBox(width: SizeConfig.smallestMargin),
                ShimmerWidget.rectangular(height: 12, width: 80),
              ],
            );
          }
        });
  }
}
