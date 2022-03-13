import 'package:flutter/material.dart';

class ApiResponse {
  int? statusCode;
  Map<String, dynamic> body;

  ApiResponse(this.statusCode, this.body);

  bool wasSuccessful() {
    if (statusCode == null) {
      return false;
    } else {
      return statusCode! >= 200 && statusCode! < 300;
    }
  }
}
