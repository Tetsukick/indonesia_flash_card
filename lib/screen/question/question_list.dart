import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:indonesia_flash_card/gen/assets.gen.dart';
import 'package:indonesia_flash_card/model/question_entity.dart';
import 'package:indonesia_flash_card/utils/logger.dart';

import '../../config/size_config.dart';
import 'components/question_list_child_view_widget.dart';

class QuestionListScreen extends StatefulWidget {
  const QuestionListScreen({Key? key}) : super(key: key);

  @override
  _QuestionListScreenState createState() => _QuestionListScreenState();
}

class _QuestionListScreenState extends State<QuestionListScreen> {
  final scaffoldKey = GlobalKey<ScaffoldState>();
  CollectionReference questionsRef =
    FirebaseFirestore.instance.collection('questions');
  List<QuestionEntity> questionList = [];

  @override
  void initState() {
    initQuestionList();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: scaffoldKey,
      backgroundColor: Color(0xFFFFEBEE),
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: SizeConfig.bottomBarHeight),
        child: FloatingActionButton(
          onPressed: () {
            print('FloatingActionButton pressed ...');
          },
          backgroundColor: Color(0xFFB71C1C),
          elevation: 8,
          child: Assets.png.addQuestion128.image(
            width: 32,
            height: 32,
            fit: BoxFit.cover,
          )
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsetsDirectional.fromSTEB(0, 0, 0, 32),
          child: ListView.builder(
            itemCount: questionList.length,
            itemBuilder: (BuildContext context, int index) {
              final questionEntity = questionList[index];
              return QuestionListChildViewWidget(questionEntity: questionEntity);
            },
          ),
        ),
      ),
    );
  }

  void initQuestionList() {
    questionsRef.get().then((value) {
        logger.d(value.docs.first);
        setState(() {
          questionList = value.docs.map((e) =>
            QuestionEntity.fromJson(e.data() as Map<String, dynamic>)..id = e.id
          ).toList();
        });
      },
      onError: (e) {
        logger.d(e);
      }
    );
  }
}
