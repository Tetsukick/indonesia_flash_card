import 'package:flutter/cupertino.dart';

class AlwaysDisabledFocusNode extends FocusNode {
  @override
  bool get hasFocus => false;
}