import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:indonesia_flash_card/config/color_config.dart';
import 'package:indonesia_flash_card/config/size_config.dart';
import 'package:indonesia_flash_card/model/question_entity.dart';
import 'package:indonesia_flash_card/repository/question_tweet_repo.dart';
import 'package:indonesia_flash_card/utils/common_border.dart';
import 'package:lottie/lottie.dart';
import 'package:rflutter_alert/rflutter_alert.dart';

import '../../flutter_flow/flutter_flow_icon_button.dart';
import '../../flutter_flow/flutter_flow_theme.dart';
import '../../flutter_flow/flutter_flow_widgets.dart';
import '../../gen/assets.gen.dart';
import '../../utils/shared_preference.dart';
import '../../utils/utils.dart';

class SendQuestionWidget extends StatefulWidget {
  const SendQuestionWidget({Key? key}) : super(key: key);

  static Future<void> navigateTo(BuildContext context) {
    return Navigator.push<void>(context, MaterialPageRoute(
      builder: (context) {
        return SendQuestionWidget();
      },
    ));
  }

  @override
  _SendQuestionWidgetState createState() => _SendQuestionWidgetState();
}

class _SendQuestionWidgetState extends State<SendQuestionWidget> {
  TextEditingController questionTextController = TextEditingController();
  final scaffoldKey = GlobalKey<ScaffoldState>();
  CollectionReference questionsRef =
    FirebaseFirestore.instance.collection('questions');
  FocusNode questionTextFieldFocusNode = FocusNode();
  bool _isSendingQuestion = false;
  bool _isAlreadySentQuestionToday = false;

  @override
  void initState() {
    _confirmAlreadyTestedToday();
    super.initState();
  }

  @override
  void dispose() {
    questionTextController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: scaffoldKey,
      backgroundColor: ColorConfig.bgPinkColor,
      appBar: AppBar(
        backgroundColor: ColorConfig.bgPinkColor,
        automaticallyImplyLeading: false,
        title: Padding(
          padding: const EdgeInsets.only(left: 8),
          child: Text(
            '質問を新規作成',
            style: FlutterFlowTheme.of(context).title2.override(
              fontFamily: 'Lexend Deca',
              color: Color(0xFF090F13),
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        actions: [
          Padding(
            padding: EdgeInsetsDirectional.fromSTEB(0, 0, 12, 0),
            child: FlutterFlowIconButton(
              borderColor: Colors.transparent,
              borderRadius: 30,
              buttonSize: 48,
              icon: Icon(
                Icons.close_rounded,
                color: Color(0xFF95A1AC),
                size: 30,
              ),
              onPressed: () async {
                Navigator.of(context).pop();
              },
            ),
          ),
        ],
        centerTitle: false,
        elevation: 0,
      ),
      body: SafeArea(
        child: GestureDetector(
          onTap: () => questionTextFieldFocusNode.unfocus(),
          child: Stack(
            children: [
              Stack(
                children: [
                  Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Padding(
                            padding: const EdgeInsetsDirectional.fromSTEB(0, 0, 0, 12),
                            child: SizedBox(
                              width: MediaQuery.of(context).size.width * 0.94,
                              child: Column(
                                children: [
                                  Padding(
                                    padding: const EdgeInsetsDirectional.fromSTEB(0, 12, 0, 0),
                                    child: Row(
                                      children: [
                                        Expanded(
                                          child: TextFormField(
                                            controller: questionTextController,
                                            focusNode: questionTextFieldFocusNode,
                                            decoration: InputDecoration(
                                              hintText:
                                              '質問を入力 ※20字以上\n(質問例: \n頻度を表す単語(sering, selalu, kadang-kadang)のそれぞれの違いがいまいちよく分かっていません。どのように使い分けたら良いでしょうか？)',
                                              hintStyle: FlutterFlowTheme.of(context)
                                                  .bodyText2
                                                  .override(
                                                fontFamily: 'Lexend Deca',
                                                color: Color(0xFF95A1AC),
                                                fontSize: 14,
                                                fontWeight: FontWeight.normal,
                                              ),
                                              enabledBorder: CommonBorder().whiteOutlineInputBorder,
                                              focusedBorder: CommonBorder().whiteOutlineInputBorder,
                                              errorBorder: CommonBorder().whiteOutlineInputBorder,
                                              focusedErrorBorder: CommonBorder().whiteOutlineInputBorder,
                                              filled: true,
                                              fillColor: Colors.white,
                                              contentPadding:
                                              const EdgeInsetsDirectional.fromSTEB(
                                                  20, 32, 20, 12),
                                            ),
                                            style: FlutterFlowTheme.of(context)
                                                .bodyText1
                                                .override(
                                              fontFamily: 'Lexend Deca',
                                              color: const Color(0xFF090F13),
                                              fontSize: 14,
                                              fontWeight: FontWeight.normal,
                                            ),
                                            maxLines: 10,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                      Padding(
                        padding: const EdgeInsetsDirectional.fromSTEB(0, 16, 0, 0),
                        child: FFButtonWidget(
                          onPressed: () {
                            questionTextFieldFocusNode.unfocus();
                            showConfirmToPostQuestionDialog();
                          },
                          text: '質問を投稿',
                          options: FFButtonOptions(
                            width: 270,
                            height: 50,
                            color: ColorConfig.primaryRed900,
                            textStyle: FlutterFlowTheme.of(context).subtitle2.override(
                              fontFamily: 'Lexend Deca',
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                            elevation: 3,
                            borderSide: CommonBorder().transparentBorderSide,
                          ),
                        ),
                      ),
                    ],
                  ),
                  Visibility(
                    visible: _isAlreadySentQuestionToday,
                    child: Container(
                      color: Colors.black.withOpacity(0.6),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Lottie.asset(
                            Assets.lottie.thankYou,
                            height: 300,
                          ),
                          Padding(
                            padding: const EdgeInsets.all(SizeConfig.mediumLargeMargin),
                            child: Text(
                              'ありがとうございます。\n\n現在は一日に可能な質問は一回までとなっております。\n明日、再度お試しください。ご利用いただきありがとうございます。',
                              style: FlutterFlowTheme.of(context).subtitle2.override(
                                fontFamily: 'Lexend Deca',
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          FFButtonWidget(
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                            text: '戻る',
                            options: FFButtonOptions(
                              width: 270,
                              height: 50,
                              color: ColorConfig.primaryRed900,
                              textStyle: FlutterFlowTheme.of(context).subtitle2.override(
                                fontFamily: 'Lexend Deca',
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                              ),
                              elevation: 3,
                              borderSide: CommonBorder().transparentBorderSide,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              Visibility(
                visible: _isSendingQuestion,
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
      ),
    );
  }

  Future<void> showConfirmToPostQuestionDialog() async {
    await Alert(
      context: context,
      type: AlertType.warning,
      title: 'この内容で質問を投稿しますか?',
      desc: '質問を投稿後に削除・編集することはできません。質問は一日に一度までしか投稿できません。',
      buttons: [
        DialogButton(
          onPressed: () => Navigator.pop(context),
          color: ColorConfig.red,
          child: const Text(
            'キャンセル',
            style: TextStyle(color: Colors.white, fontSize: 18),
          ),
        ),
        DialogButton(
          onPressed: sendQuestion,
          gradient: const LinearGradient(colors: [
            ColorConfig.green,
            Color.fromRGBO(52, 138, 199, 1),
          ]),
          child: const Text(
            '投稿',
            style: TextStyle(color: Colors.white, fontSize: 18),
          ),
        )
      ],
    ).show();
  }

  Future<void> sendQuestion() async {
    if (questionTextController.text.length < 25) {
      await Fluttertoast.showToast(
          msg: '質問は20文字以上で入力してください。',
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.CENTER,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.red,
          textColor: Colors.white,
          fontSize: 16.0
      );
      return;
    }
    final questionEntity =
      QuestionEntity()
        ..question = questionTextController.text
        ..createdAt = DateTime.now();
    setState(() => _isSendingQuestion = true);
    await questionsRef.add(questionEntity.toJson());
    await QuestionTweetRepo().tweet(questionTextController.text);
    setState(() => _isSendingQuestion = false);
    await PreferenceKey.lastQuestionPostDate.setString(Utils.dateTimeToString(DateTime.now()));
    await Utils.showUploadSuccessDialog(context);
    questionTextController.clear();
    Navigator.of(context).pop();
  }

  Future<bool> _confirmAlreadyTestedToday() async {
    bool _tmpIsAlradySentQuestionToday = false;
    final lastTestDate = await PreferenceKey.lastQuestionPostDate.getString();
    if (lastTestDate == null) {
      _tmpIsAlradySentQuestionToday = false;
    } else {
      _tmpIsAlradySentQuestionToday =
          lastTestDate == Utils.dateTimeToString(DateTime.now());
    }
    setState(() => _isAlreadySentQuestionToday = _tmpIsAlradySentQuestionToday);
    return _tmpIsAlradySentQuestionToday;
  }
}
