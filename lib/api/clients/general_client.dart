import 'package:flutter/material.dart';
import 'package:indonesia_flash_card/api/api_client.dart';
import 'package:logger/logger.dart';

class GeneralClient extends ApiClient {

  GeneralClient({
    required String apiKey,
    required String baseUrl,
    required Logger logger,
  }) : super(apiKey, baseUrl, logger);

}
