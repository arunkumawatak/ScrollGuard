import 'package:intl/intl.dart';

class Helpers {
  static String formatMinutes(int minutes) {
    if (minutes < 60) {
      return '$minutes min';
    } else {
      final hours = minutes ~/ 60;
      final remainingMinutes = minutes % 60;
      if (remainingMinutes == 0) {
        return '${hours}h';
      } else {
        return '${hours}h ${remainingMinutes}min';
      }
    }
  }

  static String formatDate(DateTime date) {
    return DateFormat('EEE, dd MMM').format(date);
  }

  static String getAppNameFromPackage(String packageName) {
    return packageName.split('.').last;
  }
}
