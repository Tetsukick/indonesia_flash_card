import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:indonesia_flash_card/config/color_config.dart';
import 'package:indonesia_flash_card/gen/assets.gen.dart';
import 'package:indonesia_flash_card/model/question_entity.dart';
import 'package:indonesia_flash_card/screen/question/add_question_screen.dart';
import 'package:indonesia_flash_card/screen/question/answer_list_screen.dart';
import 'package:indonesia_flash_card/utils/logger.dart';

import '../../config/config.dart';
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
  InterstitialAd? _interstitialAd;

  @override
  void initState() {
    initQuestionList();
    super.initState();
    loadInterstitialAd();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: scaffoldKey,
      backgroundColor: ColorConfig.bgPinkColor,
      extendBody: true,
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: SizeConfig.bottomBarHeight),
        child: FloatingActionButton(
          onPressed: () async {
            await showInterstitialAd();
            await SendQuestionWidget.navigateTo(context);
            initQuestionList();
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
      body: Padding(
        padding: EdgeInsetsDirectional.fromSTEB(0, 0, 0, 32),
        child: ListView.builder(
          itemCount: questionList.length,
          itemBuilder: (BuildContext context, int index) {
            final questionEntity = questionList[index];
            return InkWell(
              onTap: () {
                QuestionAnswerListWidget.navigateTo(context, questionEntity: questionEntity);
              },
              child: QuestionListChildViewWidget(questionEntity: questionEntity),
            );
          },
        ),
      ),
    );
  }

  void initQuestionList() {
    questionsRef.orderBy('created_at', descending: true).get().then((value) {
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

  Future<void> loadInterstitialAd() async {
    await InterstitialAd.load(
        adUnitId: Platform.isIOS ?
        Config.adUnitIdIosInterstitial : Config.adUnitIdAndroidInterstitial,
        request: AdRequest(),
        adLoadCallback: InterstitialAdLoadCallback(
          onAdLoaded: (InterstitialAd ad) {
            _interstitialAd = ad;
            logger.d('Ad loaded.${ad}');
          },
          onAdFailedToLoad: (LoadAdError error) {
            logger.d('Ad failed to load: $error');
          },
        ));
  }

  Future<void> showInterstitialAd() async {
    if (_interstitialAd != null) {
      await _interstitialAd?.show();
    }
  }
}
