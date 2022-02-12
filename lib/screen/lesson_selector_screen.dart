import 'package:flutter/material.dart';
import 'package:indonesia_flash_card/domain/file_service.dart';
import 'package:indonesia_flash_card/model/lecture.dart';
import 'package:indonesia_flash_card/repository/gdrive_repo.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:indonesia_flash_card/utils/logger.dart';

import 'home/home_page.dart';

class LessonSelectorScreen extends ConsumerStatefulWidget {
  const LessonSelectorScreen({Key? key}) : super(key: key);

  @override
  _LessonSelectorScreenState createState() => _LessonSelectorScreenState();

  static void navigateTo(BuildContext context) {
    Navigator.push(context, MaterialPageRoute(
      builder: (context) {
        return const LessonSelectorScreen();
      },
    ));
  }
}

class _LessonSelectorScreenState extends ConsumerState<LessonSelectorScreen> {
  late Future<List<LectureFolder>> getPossibleLectures;

  @override
  void initState() {
    super.initState();
    ref.read(fileControllerProvider.notifier).getPossibleLectures();
  }

  @override
  Widget build(BuildContext context) {
    final lectures = ref.watch(fileControllerProvider);
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          for (var lectureFolder in lectures) ...[
            SliverAppBar(
              title: Text(
                lectureFolder.name,
                textAlign: TextAlign.left,
                style: const TextStyle(color: Colors.black),
              ),
              centerTitle: false,
              backgroundColor: Colors.white,
              forceElevated: true,
              automaticallyImplyLeading: false,
            ),
            SliverList(
              delegate: SliverChildBuilderDelegate((context, index) {
                return ListTile(
                  title: Text(lectureFolder.spreadsheets[index].name),
                  trailing: const Icon(Icons.keyboard_arrow_right),
                  onTap: () {
                    HomePage.navigateTo(
                      context,
                      lectureFolder.spreadsheets[index].id,
                    );
                  },
                );
              }, childCount: lectureFolder.spreadsheets.length),
            )
          ]
        ],
      ),
    );
  }
}
