import 'package:flutter/material.dart';
import 'package:indonesia_flash_card/config/color_config.dart';
import 'package:indonesia_flash_card/config/config.dart';
import 'package:indonesia_flash_card/config/size_config.dart';
import 'package:indonesia_flash_card/domain/file_service.dart';
import 'package:indonesia_flash_card/domain/tango_list_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:indonesia_flash_card/gen/assets.gen.dart';
import 'package:indonesia_flash_card/model/sort_type.dart';
import 'package:indonesia_flash_card/model/tango_entity.dart';
import 'package:indonesia_flash_card/model/word_status_type.dart';
import 'package:indonesia_flash_card/repository/sheat_repo.dart';
import 'package:indonesia_flash_card/utils/common_text_widget.dart';
import 'package:indonesia_flash_card/utils/shimmer.dart';

import '../model/floor_database/database.dart';
import '../model/floor_entity/word_status.dart';

class DictionaryScreen extends ConsumerStatefulWidget {
  const DictionaryScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<DictionaryScreen> createState() => _DictionaryScreenState();

  static void navigateTo(BuildContext context) {
    Navigator.push(context, MaterialPageRoute(
      builder: (context) {
        return const DictionaryScreen();
      },
    ));
  }
}

class _DictionaryScreenState extends ConsumerState<DictionaryScreen> {
  final itemCardHeight = 80.0;
  final GlobalKey<ScaffoldState> _key = GlobalKey();
  SortType _selectedSortType = SortType.indonesian;

  Future<WordStatus?> getWordStatus(TangoEntity entity) async {
    final database = await $FloorAppDatabase.databaseBuilder('app_database.db').build();

    final wordStatusDao = database.wordStatusDao;
    final wordStatus = await wordStatusDao.findWordStatusById(entity.id!);
    return wordStatus;
  }

  @override
  Widget build(BuildContext context) {
    final tangoList = ref.watch(tangoListControllerProvider);
    return Scaffold(
      key: _key,
      backgroundColor: ColorConfig.bgPinkColor,
      extendBody: true,
      body: ListView.builder(
        padding: EdgeInsets.fromLTRB(0, SizeConfig.mediumSmallMargin, 0, SizeConfig.bottomBarHeight),
        itemBuilder: (BuildContext context, int index){
          TangoEntity tango = tangoList.dictionary.sortAndFilteredTangos[index];
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 0, horizontal: SizeConfig.mediumSmallMargin),
            child: Card(
              child: Container(
                width: double.infinity,
                height: itemCardHeight,
                child: Padding(
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
              ),
            ),
          );
        },
        itemCount: tangoList.dictionary.sortAndFilteredTangos.length,
      ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: SizeConfig.bottomBarHeight),
        child: FloatingActionButton(
          backgroundColor: ColorConfig.primaryRed900,
          child: Assets.png.sort128.image(width: 32, height: 32),
          onPressed: () {
            _key.currentState!.openEndDrawer();
          },
        ),
      ),
      endDrawer: Drawer(
        child: ListView.builder(
          padding: EdgeInsets.symmetric(vertical: SizeConfig.smallMargin, horizontal: SizeConfig.mediumLargeMargin),
          itemBuilder: (BuildContext context, int index){
            SortType sortType = SortType.values[index];
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 0, horizontal: SizeConfig.mediumSmallMargin),
              child: Card(
                child: InkWell(
                  onTap: () async {
                   setState(() => _selectedSortType = sortType);
                   final lectures = ref.watch(fileControllerProvider);
                   await ref.read(tangoListControllerProvider.notifier)
                       .getSortAndFilteredTangoList(
                          sheetRepo: SheetRepo(lectures.first.spreadsheets.firstWhere((element) => element.name == Config.dictionarySpreadSheetName).id),
                          sortType: sortType);
                   Navigator.pop(context);
                  },
                  child: Container(
                    width: double.infinity,
                    height: 40,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: SizeConfig.smallMargin),
                      child: Row(
                        children: [
                          Visibility(
                            visible: _selectedSortType == sortType,
                              child: Assets.png.checkedGreen128.image(width: 20, height: 20)),
                          SizedBox(width: SizeConfig.smallestMargin),
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
        ),
      ),
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

    return Row(
      children: [
        WordStatusType.notLearned.icon,
        SizedBox(width: SizeConfig.smallestMargin),
        TextWidget.titleGraySmallest(WordStatusType.notLearned.title),
      ],
    );
  }
}
