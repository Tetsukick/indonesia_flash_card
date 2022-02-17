import 'package:flutter/material.dart';
import 'package:indonesia_flash_card/config/size_config.dart';
import 'package:indonesia_flash_card/domain/file_service.dart';
import 'package:indonesia_flash_card/domain/tango_list_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:indonesia_flash_card/gen/assets.gen.dart';
import 'package:indonesia_flash_card/model/tango_entity.dart';
import 'package:indonesia_flash_card/repository/sheat_repo.dart';
import 'package:indonesia_flash_card/utils/common_text_widget.dart';

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

  @override
  void initState() {
    super.initState();
    _loadTangoList();
  }

  void _loadTangoList() async {
    await ref.read(fileControllerProvider.notifier).getPossibleLectures();
    final lectures = ref.watch(fileControllerProvider);
    ref.read(tangoListControllerProvider.notifier).getAllTangoList(sheetRepo: SheetRepo(lectures.first.spreadsheets.first.id));
  }

  @override
  Widget build(BuildContext context) {
    final tangoList = ref.watch(tangoListControllerProvider);
    return ListView.builder(
      padding: EdgeInsets.fromLTRB(0, SizeConfig.mediumSmallMargin, 0, SizeConfig.bottomBarHeight),
      itemBuilder: (BuildContext context, int index){
        TangoEntity tango = tangoList[index];
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
                    Row(
                      children: [
                        Assets.png.minus128.image(height: 16, width: 16),
                        SizedBox(width: SizeConfig.smallestMargin),
                        TextWidget.titleGraySmallest('未学習'),
                      ],
                    ),
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
      itemCount: tangoList.length,
    );
  }
}
