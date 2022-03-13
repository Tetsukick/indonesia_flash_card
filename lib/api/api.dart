import 'package:flutter/material.dart';
import 'package:indonesia_flash_card/api/clients/general_client.dart';
import 'package:logger/logger.dart';

class Api {
  final GeneralClient generalClient;

  Api({
    required this.generalClient,
  });

  factory Api.create({
    required String apiKey,
    required String baseUrl,
    required Logger logger,
  }) {
    return Api(
        generalClient: GeneralClient(
            apiKey: apiKey,
            baseUrl: baseUrl,
            logger: logger,
        ),
        // add more clients here
    );
  }
}
