class ApiError {

  ApiError({required this.detail});

  factory ApiError.fromJson(Map<String, dynamic> json) {
    return ApiError(detail: json['text'] as String ?? '');
  }
  final String detail;
}
