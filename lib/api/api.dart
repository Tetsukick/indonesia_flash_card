// Package imports:
import 'package:logger/logger.dart';

// Project imports:
import 'package:indonesia_flash_card/api/clients/general_client.dart';

class Api {

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
  final GeneralClient generalClient;
}
