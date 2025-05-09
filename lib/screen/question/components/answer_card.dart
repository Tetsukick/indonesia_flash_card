// Flutter imports:
import 'package:flutter/material.dart';
import 'package:indonesia_flash_card/config/color_config.dart';
import 'package:indonesia_flash_card/utils/common_text_widget.dart';
import 'package:indonesia_flash_card/utils/date_util.dart';

// Project imports:
import '../../../flutter_flow/flutter_flow_theme.dart';
import '../../../model/question_answer_entity.dart';
import 'answer_title.dart';

class AnswerCard extends StatelessWidget {
  const AnswerCard({Key? key, required this.answerEntity}) : super(key: key);
  final QuestionAnswerEntity answerEntity;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsetsDirectional.fromSTEB(16, 12, 16, 0),
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: const [
            BoxShadow(
              blurRadius: 4,
              color: Color(0x33000000),
              offset: Offset(0, 2),
            ),
          ],
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          children: [
            AnswerTitle(answer: answerEntity.answer),
            Padding(
              padding:
              const EdgeInsetsDirectional.fromSTEB(16, 4, 16, 12),
              child: Row(
                children: [
                  Expanded(
                    child: TextWidget.titleNumberGraySmallest(
                      answerEntity.createdAt?.yMMddHHmm() ?? '',
                      textAlign: TextAlign.end,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
