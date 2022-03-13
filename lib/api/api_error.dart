class ApiError {
  final String detail;

  ApiError({required this.detail});

  factory ApiError.fromJson(Map<String, dynamic> json) {
    return ApiError(detail: json['text'] ?? '');
  }
}
