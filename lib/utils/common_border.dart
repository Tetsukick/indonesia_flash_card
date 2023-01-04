import 'package:flutter/material.dart';

class CommonBorder {
  final whiteOutlineInputBorder = OutlineInputBorder(
    borderSide: const BorderSide(
      color: Color(0xFFF1F4F8),
      width: 2,
    ),
    borderRadius: BorderRadius.circular(8),
  );

  final transparentBorderSide = const BorderSide(
    color: Colors.transparent,
  );
}
