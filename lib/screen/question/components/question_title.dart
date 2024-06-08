// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:auto_size_text/auto_size_text.dart';

// Project imports:
import '../../../flutter_flow/flutter_flow_theme.dart';
import '../../../gen/assets.gen.dart';

class QuestionTitle extends StatelessWidget {
  const QuestionTitle({Key? key, this.question, this.maxLines}) : super(key: key);
  final String? question;
  final int? maxLines;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsetsDirectional.fromSTEB(0, 0, 2, 0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsetsDirectional.fromSTEB(8, 8, 8, 8),
            child: ClipRRect(
                borderRadius: BorderRadius.circular(0),
                child: Assets.png.askingQuestion128.image(
                    width: 32, height: 32, fit: BoxFit.cover,),
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsetsDirectional.fromSTEB(8, 8, 8, 8),
              child: AutoSizeText(
                question ?? '',
                maxLines: maxLines,
                style: FlutterFlowTheme.of(context).bodyText1,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
