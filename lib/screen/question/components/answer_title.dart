import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';

import '../../../flutter_flow/flutter_flow_theme.dart';
import '../../../gen/assets.gen.dart';

class AnswerTitle extends StatelessWidget {
  const AnswerTitle({Key? key, this.answer, this.maxLines}) : super(key: key);
  final String? answer;
  final int? maxLines;

  @override
  Widget build(BuildContext context) {
    return Row(
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
              answer ?? '',
              maxLines: maxLines,
              style:
                maxLines != null ? FlutterFlowTheme.of(context).bodyText2.override(
                  fontFamily: 'Poppins',
                  fontStyle: FontStyle.italic,
                )
                : FlutterFlowTheme.of(context).bodyText1,
            ),
          ),
        ),
      ],
    );
  }
}
