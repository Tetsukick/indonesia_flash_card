
class ApiResponse {

  ApiResponse(this.statusCode, this.body);
  int? statusCode;
  Map<String, dynamic> body;

  bool wasSuccessful() {
    if (statusCode == null) {
      return false;
    } else {
      return statusCode! >= 200 && statusCode! < 300;
    }
  }
}
