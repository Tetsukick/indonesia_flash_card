import 'package:indonesia_flash_card/model/tango_entity.dart';

class TangoMaster {
  Dictionary dictionary = Dictionary();
  List<TangoEntity> currentLessonData = [];
}

class Dictionary {
  List<TangoEntity> allTangos = [];
  List<TangoEntity> sortAndFilteredTangos = [];
}