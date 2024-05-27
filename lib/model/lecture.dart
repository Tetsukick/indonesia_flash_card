class LectureInformation {

  LectureInformation(this.name, this.id);
  final String name;
  final String id;
}

class LectureFolder {

  LectureFolder(this.name, this.spreadsheets);
  final String name;
  final List<LectureInformation> spreadsheets;
}
