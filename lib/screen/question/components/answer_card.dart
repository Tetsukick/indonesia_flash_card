import 'package:flutter/material.dart';

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
                    child: Text(
                      answerEntity.createdAt.toString(),
                      textAlign: TextAlign.end,
                      style: FlutterFlowTheme.of(context)
                          .bodyText2
                          .override(
                        fontFamily: 'Lexend Deca',
                        color: const Color(0xFF95A1AC),
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
    );
  }
}
