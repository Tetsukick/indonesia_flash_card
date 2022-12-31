import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:indonesia_flash_card/gen/assets.gen.dart';
import 'package:indonesia_flash_card/screen/question/components/answer_card.dart';
import 'package:indonesia_flash_card/screen/question/components/question_title.dart';

import '../../flutter_flow/flutter_flow_icon_button.dart';
import '../../flutter_flow/flutter_flow_theme.dart';
import 'package:flutter/material.dart';

import '../../model/question_answer_entity.dart';
import '../../model/question_entity.dart';
import '../../utils/logger.dart';
import 'components/answer_title.dart';

class QuestionAnswerListWidget extends StatefulWidget {
  const QuestionAnswerListWidget({Key? key, required this.questionEntity}) : super(key: key);
  final QuestionEntity questionEntity;

  static void navigateTo(
      BuildContext context,
      {required QuestionEntity questionEntity}) {
    Navigator.push<void>(context, MaterialPageRoute(
      builder: (context) {
        return QuestionAnswerListWidget(questionEntity: questionEntity);
      },
    ));
  }

  @override
  _QuestionAnswerListWidgetState createState() =>
      _QuestionAnswerListWidgetState();
}

class _QuestionAnswerListWidgetState extends State<QuestionAnswerListWidget> {
  final scaffoldKey = GlobalKey<ScaffoldState>();
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
    return Scaffold(
      key: scaffoldKey,
      backgroundColor: Color(0xFFFFEBEE),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          logger.d('FloatingActionButton pressed ...');
        },
        backgroundColor: Color(0xFFB71C1C),
        elevation: 8,
        child: Assets.png.answerRaiseHand128.image(
          width: 32,
          height: 32,
          fit: BoxFit.cover,
        )
      ),
      appBar: AppBar(
        backgroundColor: Colors.white,
        automaticallyImplyLeading: false,
        leading: FlutterFlowIconButton(
          borderColor: Colors.transparent,
          borderRadius: 30,
          buttonSize: 46,
          icon: Icon(
            Icons.arrow_back_rounded,
            color: Color(0xFF95A1AC),
            size: 24,
          ),
          onPressed: () async {
            Navigator.of(context).pop();
          },
        ),
        title: Text(
          '質問',
          style: FlutterFlowTheme.of(context).subtitle1.override(
            fontFamily: 'Lexend Deca',
            color: Color(0xFF090F13),
            fontSize: 18,
            fontWeight: FontWeight.w500,
          ),
        ),
        actions: [],
        centerTitle: false,
        elevation: 0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.max,
            children: [
              Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      blurRadius: 3,
                      color: Color(0x39000000),
                      offset: Offset(0, 1),
                    )
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    Container(
                      decoration: BoxDecoration(),
                      child: QuestionTitle(
                        question: widget.questionEntity.question,
                        maxLines: 5,
                      ),
                    ),
                    Padding(
                      padding: EdgeInsetsDirectional.fromSTEB(16, 4, 16, 12),
                      child: Row(
                        mainAxisSize: MainAxisSize.max,
                        children: [
                          Expanded(
                            child: Text(
                              widget.questionEntity.cretedAt.toString(),
                              textAlign: TextAlign.end,
                              style: FlutterFlowTheme.of(context)
                                  .bodyText2
                                  .override(
                                fontFamily: 'Lexend Deca',
                                color: Color(0xFF95A1AC),
                                fontSize: 14,
                                fontWeight: FontWeight.normal,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              ListView.builder(
                itemCount: questionAnswers.length,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemBuilder: (BuildContext context, int index) {
                  return AnswerCard(answerEntity: questionAnswers[index]);
                },
              )
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
