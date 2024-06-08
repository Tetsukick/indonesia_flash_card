// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:social_share/social_share.dart';

// Project imports:
import 'package:indonesia_flash_card/model/question_answer_entity.dart';
import 'package:indonesia_flash_card/model/question_entity.dart';
import 'package:indonesia_flash_card/screen/question/components/question_title.dart';
import '../../../utils/logger.dart';
import 'answer_title.dart';

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
  int answerCount = 0;
  
  @override
  void initState() {
    initQuestionAnswerList();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsetsDirectional.fromSTEB(2, 2, 2, 2),
      child: Card(
        clipBehavior: Clip.antiAliasWithSaveLayer,
        color: const Color(0xFFF5F5F5),
        child: Padding(
          padding: const EdgeInsetsDirectional.fromSTEB(8, 8, 8, 8),
          child: Column(
            children: [
              QuestionTitle(question: widget.questionEntity.question, maxLines: 5),
              Visibility(
                visible: questionAnswers.isNotEmpty,
                child: Padding(
                  padding: const EdgeInsetsDirectional.fromSTEB(16, 0, 0, 0),
                  child: AnswerTitle(
                    answer: questionAnswers.isNotEmpty ? questionAnswers.first.answer ?? '' : '',
                    maxLines: 2,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsetsDirectional.fromSTEB(8, 4, 8, 0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Padding(
                            padding: const EdgeInsetsDirectional.fromSTEB(8, 0, 8, 0),
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.mode_comment_outlined,
                                  color: Color(0xFF95A1AC),
                                  size: 24,
                                ),
                                Padding(
                                  padding: const EdgeInsetsDirectional.fromSTEB(
                                      4, 0, 0, 0,),
                                  child: Text(
                                    answerCount.toString(),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          InkWell(
                            onTap: shareSNS,
                            child: const Padding(
                              padding: EdgeInsetsDirectional.fromSTEB(0, 0, 8, 0),
                              child: Icon(
                                Icons.ios_share,
                                color: Color(0xFF95A1AC),
                                size: 24,
                              ),
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
    questionsRef.doc(widget.questionEntity.id).collection('answers').orderBy('created_at', descending: true).limit(1).get().then((value) {
        setState(() {
          questionAnswers = value.docs.map((e) =>
            QuestionAnswerEntity.fromJson(e.data())..id = e.id,
          ).toList();
        });
      },
      onError: (e) {
        logger.d(e);
      },
    );
    questionsRef.doc(widget.questionEntity.id).collection('answers').count().get().then((value) {
      if (value.count != null) {
        setState(() {
          answerCount = value.count!;
        });
      }
    });
  }

  Future<void> shareSNS() async {
    await SocialShare.shareOptions('${widget.questionEntity.question} #インドネシア語についての質問');
  }
}
