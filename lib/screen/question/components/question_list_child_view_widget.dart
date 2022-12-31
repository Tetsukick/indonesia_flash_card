import 'package:auto_size_text/auto_size_text.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:indonesia_flash_card/gen/assets.gen.dart';
import 'package:indonesia_flash_card/model/question_answer_entity.dart';
import 'package:indonesia_flash_card/model/question_entity.dart';

import '../../../utils/logger.dart';

class QuestionListChildViewWidget extends StatefulWidget {
  const QuestionListChildViewWidget({Key? key, required this.questionEntity}) : super(key: key);
  final QuestionEntity questionEntity;

  @override
  State<QuestionListChildViewWidget> createState() => _QuestionListChildViewWidgetState();
}

class _QuestionListChildViewWidgetState extends State<QuestionListChildViewWidget> {
  List<QuestionAnswerEntity> questionAnswers = [];
  CollectionReference questionsRef = 
    FirebaseFirestore.instance.collection('questions');
  
  @override
  void initState() {
    initQuestionAnswerList();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsetsDirectional.fromSTEB(2, 2, 2, 2),
      child: Card(
        clipBehavior: Clip.antiAliasWithSaveLayer,
        color: Color(0xFFF5F5F5),
        child: Padding(
          padding: EdgeInsetsDirectional.fromSTEB(8, 8, 8, 8),
          child: Column(
            mainAxisSize: MainAxisSize.max,
            children: [
              Padding(
                padding: EdgeInsetsDirectional.fromSTEB(0, 0, 2, 0),
                child: Row(
                  mainAxisSize: MainAxisSize.max,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: EdgeInsetsDirectional.fromSTEB(8, 8, 8, 8),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(0),
                        child: Assets.png.askingQuestion128.image(
                            width: 32, height: 32, fit: BoxFit.cover)
                      ),
                    ),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsetsDirectional.fromSTEB(8, 8, 8, 8),
                        child: AutoSizeText(
                          widget.questionEntity.question ?? '',
                          maxLines: 5,
                          // style: FlutterFlowTheme.of(context).bodyText1,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Visibility(
                visible: questionAnswers.isNotEmpty,
                child: Padding(
                  padding: EdgeInsetsDirectional.fromSTEB(16, 0, 0, 0),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: EdgeInsetsDirectional.fromSTEB(8, 8, 8, 8),
                        child: Assets.png.hijabTeacher128.image(
                            width: 24, height: 24, fit: BoxFit.cover)
                      ),
                      Expanded(
                        child: Padding(
                          padding: EdgeInsetsDirectional.fromSTEB(8, 8, 8, 8),
                          child: AutoSizeText(
                            questionAnswers.isNotEmpty ? questionAnswers.first.answer ?? '' : '',
                            maxLines: 2,
                            // style:
                            // FlutterFlowTheme.of(context).bodyText2.override(
                            //   fontFamily: 'Poppins',
                            //   fontStyle: FontStyle.italic,
                            // ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsetsDirectional.fromSTEB(8, 4, 8, 0),
                child: Row(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Row(
                        mainAxisSize: MainAxisSize.max,
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Visibility(
                            visible: questionAnswers.isNotEmpty,
                            child: Padding(
                              padding: EdgeInsetsDirectional.fromSTEB(8, 0, 8, 0),
                              child: Row(
                                mainAxisSize: MainAxisSize.max,
                                children: [
                                  Icon(
                                    Icons.mode_comment_outlined,
                                    color: Color(0xFF95A1AC),
                                    size: 24,
                                  ),
                                  Padding(
                                    padding: EdgeInsetsDirectional.fromSTEB(
                                        4, 0, 0, 0),
                                    child: Text(
                                      questionAnswers.length.toString(),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          Padding(
                            padding: EdgeInsetsDirectional.fromSTEB(0, 0, 8, 0),
                            child: Icon(
                              Icons.ios_share,
                              color: Color(0xFF95A1AC),
                              size: 24,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void initQuestionAnswerList() {
    questionsRef.doc(widget.questionEntity.id).collection('answers').get().then((value) {
        setState(() {
          questionAnswers = value.docs.map((e) =>
            QuestionAnswerEntity.fromJson(e.data() as Map<String, dynamic>)..id = e.id
          ).toList();
        });
      },
      onError: (e) {
        logger.d(e);
      }
    );
  }
}
