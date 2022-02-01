import 'package:flutter/material.dart';
import 'package:indonesia_flash_card/domain/file_service.dart';
import 'package:indonesia_flash_card/model/lecture.dart';
import 'package:indonesia_flash_card/repository/gdrive_repo.dart';
import 'package:indonesia_flash_card/utils/logger.dart';

import 'home/home_page.dart';

class LessonSelectorScreen extends StatefulWidget {
  const LessonSelectorScreen({Key? key}) : super(key: key);

  @override
  State<LessonSelectorScreen> createState() => _LessonSelectorScreenState();

  static void navigateTo(BuildContext context) {
    Navigator.push(context, MaterialPageRoute(
      builder: (context) {
        return const LessonSelectorScreen();
      },
    ));
  }
}

class _LessonSelectorScreenState extends State<LessonSelectorScreen> {
  FilesService fileService = FilesService(GDriveRepo());
  late Future<List<LectureFolder>> getPossibleLectures;

  @override
  void initState() {
    super.initState();
    getPossibleLectures = fileService.getPossibleLectures();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Select your lesson"),
      ),
      body: FutureBuilder<List<LectureFolder>>(
          future: getPossibleLectures,
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              final possibleLectureFolders = snapshot.data;
              logger.d('lecture data: ${snapshot.data}');
              if (possibleLectureFolders == null) {
                return Container(child: Center(child: Text('failed to load data')),);
              }
              return CustomScrollView(
                slivers: [
                  for (var lectureFolder in possibleLectureFolders) ...[
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
              );
            }
            if (snapshot.hasError) return const Text("Something wrong happend");
            return const Center(child: CircularProgressIndicator());
          }),
    );
  }
}
