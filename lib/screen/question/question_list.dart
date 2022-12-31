import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'components/question_list_child_view_widget.dart';

class QuestionListScreen extends StatefulWidget {
  const QuestionListScreen({Key? key}) : super(key: key);

  @override
  _QuestionListScreenState createState() => _QuestionListScreenState();
}

class _QuestionListScreenState extends State<QuestionListScreen> {
  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: scaffoldKey,
      backgroundColor: Color(0xFFFFEBEE),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          print('FloatingActionButton pressed ...');
        },
        backgroundColor: Color(0xFFB71C1C),
        elevation: 8,
        child: Image.network(
          'https://cdn-icons-png.flaticon.com/512/6238/6238434.png',
          width: 32,
          height: 32,
          fit: BoxFit.cover,
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.max,
          children: [
            // Container(
            //   width: MediaQuery.of(context).size.width,
            //   decoration: BoxDecoration(
            //     color: Color(0xFFFFEBEE),
            //     boxShadow: [
            //       BoxShadow(
            //         blurRadius: 3,
            //         color: Color(0x3A000000),
            //         offset: Offset(0, 1),
            //       )
            //     ],
            //   ),
            //   child: Container(
            //     decoration: BoxDecoration(),
            //     child: Align(
            //       alignment: AlignmentDirectional(0, 0),
            //       child: SearchHeaderWidget(),
            //     ),
            //   ),
            // ),
            Padding(
              padding: EdgeInsetsDirectional.fromSTEB(0, 0, 0, 32),
              child: Column(
                mainAxisSize: MainAxisSize.max,
                children: [
                  QuestionListChildViewWidget(),
                  QuestionListChildViewWidget(),
                  QuestionListChildViewWidget(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
