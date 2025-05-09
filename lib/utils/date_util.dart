import 'package:intl/intl.dart';

extension DateExtension on DateTime {
  String y() {
    return DateFormat('y').format(this);
  }

  String M() {
    return DateFormat('M').format(this);
  }

  String MMM() {
    return DateFormat('MMM').format(this);
  }

  String MMMCommaY() {
    return DateFormat('MMM, y').format(this);
  }

  String MMMM() {
    return DateFormat('MMMM').format(this);
  }

  String yMM() {
    return DateFormat('y-MM').format(this);
  }

  String dMMMy() {
    return DateFormat('d MMM y').format(this);
  }

  String yMMdd() {
    return DateFormat('y/MM/dd').format(this);
  }

  String yMMddHHmm() {
    return DateFormat('y/MM/dd HH:mm').format(this);
  }

  String dMMMykkss() {
    return DateFormat('d MMM y kk:ss')
        .format(this);
  }

  String get kkmm {
    return DateFormat('kk:mm').format(this);
  }

  String kkss() {
    return DateFormat('kk:ss').format(this);
  }

  String get getAge {
    var endDate = DateTime.now();
    if (isAfter(endDate)) {
      final temp = this;
      endDate = temp;
    }

    var years = endDate.year - year;
    var months = endDate.month - month;

    if (endDate.day < day) {
      months--;
    }

    if (months < 0) {
      years--;
      months += 12;
    }

    final yearsText = years == 1 ? 'year' : 'years';
    final monthsText = months == 1 ? 'month' : 'months';

    if (years > 0 && months > 0) {
      return '$years $yearsText $months $monthsText old';
    } else if (years > 0) {
      return '$years $yearsText old';
    } else {
      return '$months $monthsText old';
    }
  }

  String toMMMdy() {
    return DateFormat('MMM d, y').format(this);
  }

  bool isDateWithinRange(
      {required DateTime startDate, required DateTime endDate}) {
    return (isAfter(startDate) || isAtSameMomentAs(startDate)) &&
        (isBefore(endDate) || isAtSameMomentAs(endDate));
  }
}

extension DateStringExtension on String {
  DateTime toDate() {
    final str = this;
    final arr = str.split('-');
    final dateStr =
        "${arr[0].padLeft(2, "0")}-${arr[1].padLeft(2, "0")}${arr[2].padLeft(2, "0")}";
    return DateTime.parse(dateStr);
  }

  DateTime strMMMCommaYtoDateTime() {
    return DateFormat('MMM, y').parse(this);
  }
}
