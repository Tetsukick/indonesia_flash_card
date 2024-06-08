// Project imports:
import 'package:indonesia_flash_card/api/api.dart';
import 'package:indonesia_flash_card/api/clients/general_client.dart';
import 'package:indonesia_flash_card/utils/logger.dart';

class QuestionTweetRepo {
  Api questionTweetApi = Api(generalClient: GeneralClient(
      apiKey: '',
      baseUrl: 'https://script.google.com/macros/s/AKfycbylGcB7-oxaNjKn4Q5NnMMDZH02C_zxQVFkt5Q7W9e3UuXRKjAGCauk0QgMc2075uj7Hg',
      logger: logger,
  ),);

  Future<dynamic> tweet(String contents) {
    return questionTweetApi.generalClient.get<dynamic>(
        endpoint: 'exec',
        queryParams: {
          'text': contents,
        },
        serializer: (json) {
          return json;
        },
      );
  }
}
