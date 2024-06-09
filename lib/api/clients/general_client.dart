// Package imports:
import 'package:logger/logger.dart';

// Project imports:
import 'package:indonesia_flash_card/api/api_client.dart';

class GeneralClient extends ApiClient {

  GeneralClient({
    required String apiKey,
    required String baseUrl,
    required Logger logger,
  }) : super(apiKey, baseUrl, logger);

}
