// Project imports:
import 'package:indonesia_flash_card/api/api.dart';
import 'package:indonesia_flash_card/api/clients/general_client.dart';
import 'package:indonesia_flash_card/model/translate_response_entity.dart';
import 'package:indonesia_flash_card/utils/logger.dart';

class TranslateRepo {
  Api translateApi = Api(generalClient: GeneralClient(
    apiKey: '',
    baseUrl: 'https://script.google.com/macros/s/AKfycbwwsokn-ihd3ffq0rTu--Qa5p4XtQLgJbL3audTm397ZwFwVQplNPYlEeKrH4AsSIuS',
    logger: logger,
  ),);

  Future<TranslateResponseEntity> translate(String origin, {bool isIndonesianToJapanese = true}) {
    const japaneseCode = 'ja';
    const indonesianCode = 'id';

    return translateApi.generalClient.get<TranslateResponseEntity>(
        endpoint: 'exec',
        queryParams: {
          'text': origin,
          'source': isIndonesianToJapanese ? indonesianCode : japaneseCode,
          'target': isIndonesianToJapanese ? japaneseCode : indonesianCode,
        },
        serializer: (json) {
          final response = TranslateResponseEntity.fromJson(json);
          return response;
        },);
  }
}
