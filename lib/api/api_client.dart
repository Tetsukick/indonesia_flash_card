import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:indonesia_flash_card/api/api_error.dart';
import 'package:indonesia_flash_card/api/response/response_object.dart';
import 'package:indonesia_flash_card/config/config.dart';
import 'package:logger/logger.dart';
import 'api_exception.dart';
import 'api_response.dart';
import 'custom_exception.dart';

// TODO: INJECT THIS
final DIO = Dio();

class ApiClient {
  final String _baseUrl;
  final String apiKey;
  final Logger logger;

  ApiClient(this.apiKey, this._baseUrl, this.logger);

  // Http requests

  // Performs a GET request to the given url, returning a Future with the ApiResponse obtained
  // token should be injected by respective client manually by getting it from `SessionController` instance
  Future<T> get<T>({
    required String endpoint,
    required T Function(Map<String,dynamic>) serializer,
    Map<String, String>? queryParams,
    String? preferredUrl,
    Map<String, dynamic>? headers,
    String? token
  }) async {
    final String url = buildUrl(endpoint: endpoint, queryParams: queryParams, preferredUrl: preferredUrl);
    Map<String, dynamic> requestHeaders = buildHeaders(token: token);
    if (headers != null) {
      requestHeaders.addAll(headers);
    }

    try {
      final response = await DIO.get<dynamic>(url, options: Options(headers: requestHeaders));

      ApiResponse apiResponse = handleResponse(response);

      return serializer(apiResponse.body);
    } on ApiException catch (ex) {
      // If the exception caught is an ApiException, then it isn't actually unexpected. We just throw it again
      logger.d('Unexepected exception obtained with request GET ' +
          endpoint +
          '\nException: ' +
          ex.toString());
      throw ex;
    } on DioError catch (ex) {
      logger.d('Unexepected exception obtained with request GET ' +
          endpoint +
          '\nException: ' +
          ex.toString());

      handleError(ex.response);
      throw ApiException(
          ApiError(detail: ex.error.toString()),
          ex.response?.statusCode ?? -1);
    } catch (ex) {
      logger.d('Unexepected exception obtained with request GET ' +
          endpoint +
          '\nException: ' +
          ex.toString());
      throw CustomException(
          "Something is wrong with your request!", ex, -1);
    }
  }

  // Performs a POST request to the given url with the provided headers and body, returning a Future with the ApiResponse obtained
  // token should be injected by respective client manually by getting it from `SessionController` instance
  Future<ResponseObject> post({
    required String endpoint,
    required ResponseObject Function(Map<String,dynamic>) serializer,
    Map? body,
    Map<String, dynamic>? headers,
    String? token,
    String? preferredUrl
  }) async {
    final String url = buildUrl(endpoint: endpoint, preferredUrl: preferredUrl);
    Map<String, dynamic> requestHeaders = buildHeaders(token: token);
    if (headers != null) {
      requestHeaders.addAll(headers);
    }
    try {
      print(body);

      final Response response = await DIO.post<dynamic>(
          url,
          options: Options(headers: requestHeaders),
          data: body,
      );

      print(response.data.toString());

      ApiResponse apiResponse = handleResponse(response);

      return serializer(apiResponse.body);
    } on ApiException catch (ex) {
      // If the exception caught is an ApiException, then it isn't actually unexpected. We just throw it again
      throw ex;
    } on DioError catch (ex) {
      logger.d('Unexepected exception obtained with request POST ' +
          endpoint +
          '\nException: ' +
          ex.toString());

      handleError(ex.response);
      throw CustomException(
          "Something is wrong with your request", ex, ex.response?.statusCode ?? -1);
    } catch (ex) {
      logger.d('Unexepected exception obtained with request POST ' +
          endpoint +
          '\nException: ' +
          ex.toString());
      throw CustomException(
          "Something is wrong with your request", ex, -1);
    }

  }

  // Process a Response and returns an ApiResponse with the corresponding status code and body.
  // It works for either successful and failing responses, and the status code should be used later to understand whether the response succeeded or not
  // In the case of obtaining an invalid body (i.e. an XML that would fail when parsed as a JSON), it will throw the corresponding exception
  ApiResponse handleResponse(Response response) {
    logger.d('Response for ' +
        response.requestOptions.path +
        '\nStatus code: ' +
        response.statusCode.toString() +
        '\nBody:\n' +
        response.data.toString());


    Map<String, dynamic> body = Map<String, dynamic>();
    if (response.data != null) {
      body = response.data as Map<String, dynamic>;
    }

    final apiResponse = ApiResponse(response.statusCode, body);

    if (apiResponse.wasSuccessful()) {
      return apiResponse;
    } else {
      handleError(response);
      ApiError error = ApiError.fromJson(apiResponse.body);
      throw ApiException(error, apiResponse.statusCode);
    }
  }


  // Creates a Map with the necessary headers for any request sent to our API
  Map<String, dynamic> buildHeaders({
    String? token
  }) {
    Map<String, String> headers = Map();

    headers[Config.apiKeyHeader] = apiKey;
    headers[Config.contentTypeHeader] = "application/json";

    print("token is $token");
    if (token != null) {
      headers[Config.authorizationHeader] = "Bearer $token";
    }

    return headers;
  }

  String buildUrl(
      {required String endpoint, Map<String, String>? queryParams, String? preferredUrl}) {
    var apiUri = preferredUrl != null ? Uri.parse(preferredUrl) : Uri.parse(_baseUrl);
    final apiPath = apiUri.path+"/"+endpoint;
    final uri = Uri(
      scheme: apiUri.scheme,
      host: apiUri.host,
      path: apiPath,
      queryParameters: queryParams
    ).toString();
    return uri;
  }

  void handleError(Response? response) {}

}
