import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:indonesia_flash_card/config/color_config.dart';
import 'package:indonesia_flash_card/gen/assets.gen.dart';
import 'package:indonesia_flash_card/screen/question/components/answer_card.dart';
import 'package:indonesia_flash_card/screen/question/components/question_title.dart';
import 'package:lottie/lottie.dart';

import '../../flutter_flow/flutter_flow_icon_button.dart';
import '../../flutter_flow/flutter_flow_theme.dart';
import 'package:flutter/material.dart';

import '../../model/question_answer_entity.dart';
import '../../model/question_entity.dart';
import '../../utils/logger.dart';
import '../../utils/utils.dart';
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
  TextEditingController answerTextEditingController = TextEditingController();
  FocusNode answerTextFieldFocusNode = FocusNode();
  bool _isSendingAnswer = false;

  @override
  void initState() {
    initQuestionAnswerList();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: scaffoldKey,
      backgroundColor: ColorConfig.bgPinkColor,
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
        child: Stack(
          children: [
            Stack(
              children: [
                SingleChildScrollView(
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
                                      widget.questionEntity.createdAt.toString() ?? '',
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
                      ),
                      const SizedBox(height: 120)
                    ],
                  ),
                ),
                Align(
                  alignment: AlignmentDirectional(0, 1),
                  child: Container(
                    height: 100,
                    decoration: BoxDecoration(
                      color: Color(0x9AFFFFFF),
                    ),
                    child: Align(
                      alignment: AlignmentDirectional(0, 1),
                      child: Padding(
                        padding: EdgeInsetsDirectional.fromSTEB(0, 0, 0, 8),
                        child: Row(
                          mainAxisSize: MainAxisSize.max,
                          children: [
                            Expanded(
                              child: Padding(
                                padding:
                                EdgeInsetsDirectional.fromSTEB(16, 12, 8, 0),
                                child: TextFormField(
                                  controller: answerTextEditingController,
                                  focusNode: answerTextFieldFocusNode,
                                  decoration: InputDecoration(
                                    labelText: '回答を送信',
                                    labelStyle: FlutterFlowTheme.of(context)
                                        .bodyText2
                                        .override(
                                      fontFamily: 'Outfit',
                                      color: Color(0xFF57636C),
                                      fontSize: 14,
                                      fontWeight: FontWeight.normal,
                                    ),
                                    hintStyle: FlutterFlowTheme.of(context)
                                        .bodyText2
                                        .override(
                                      fontFamily: 'Outfit',
                                      color: Color(0xFF57636C),
                                      fontSize: 14,
                                      fontWeight: FontWeight.normal,
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderSide: BorderSide(
                                        color: Color(0xFFE0E3E7),
                                        width: 2,
                                      ),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderSide: BorderSide(
                                        color: Color(0xFFE0E3E7),
                                        width: 2,
                                      ),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    errorBorder: OutlineInputBorder(
                                      borderSide: BorderSide(
                                        color: Color(0x00000000),
                                        width: 2,
                                      ),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    focusedErrorBorder: OutlineInputBorder(
                                      borderSide: BorderSide(
                                        color: Color(0x00000000),
                                        width: 2,
                                      ),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    filled: true,
                                    fillColor: Color(0xFFF1F4F8),
                                    contentPadding: EdgeInsetsDirectional.fromSTEB(
                                        24, 24, 20, 24),
                                  ),
                                  style: FlutterFlowTheme.of(context)
                                      .bodyText1
                                      .override(
                                    fontFamily: 'Outfit',
                                    color: Color(0xFF1D2429),
                                    fontSize: 14,
                                    fontWeight: FontWeight.normal,
                                  ),
                                  maxLines: 6,
                                ),
                              ),
                            ),
                            Padding(
                              padding: EdgeInsetsDirectional.fromSTEB(0, 12, 12, 0),
                              child: FlutterFlowIconButton(
                                borderColor: Colors.transparent,
                                borderRadius: 30,
                                borderWidth: 1,
                                buttonSize: 50,
                                icon: Icon(
                                  Icons.send,
                                  color: Color(0xFFB71C1C),
                                  size: 30,
                                ),
                                onPressed: () {
                                  answerTextFieldFocusNode.unfocus();
                                  sendAnswer();
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            Visibility(
              visible: _isSendingAnswer,
              child: Container(
                color: Colors.black.withOpacity(0.2),
                child: Center(
                  child: Lottie.asset(
                    Assets.lottie.sendingPaperPlane,
                    height: 300,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void initQuestionAnswerList() {
    questionsRef.doc(widget.questionEntity.id).collection('answers')
        .orderBy('created_at', descending: true).get().then((value) {
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

  void sendAnswer() async {
    if (answerTextEditingController.text.length < 15) {
      Fluttertoast.showToast(
          msg: '回答は15文字以上で入力してください。',
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.CENTER,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.red,
          textColor: Colors.white,
          fontSize: 16.0
      );
      return;
    }
    final answerEntity =
      QuestionAnswerEntity()
        ..answer = answerTextEditingController.text
        ..createdAt = DateTime.now();
    setState(() => _isSendingAnswer = true);
    await questionsRef.doc(widget.questionEntity.id).collection('answers').add(answerEntity.toJson());
    setState(() => _isSendingAnswer = false);
    await Utils.showUploadSuccessDialog(context);
    answerTextEditingController.clear();
    initQuestionAnswerList();
  }
}
