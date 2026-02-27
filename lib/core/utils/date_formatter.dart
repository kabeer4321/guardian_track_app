import 'package:intl/intl.dart';

class DateFormatter {
  static String formatDate(DateTime date) {
    return DateFormat('dd-MM-yyyy').format(date);
  }

  static String formatTime(DateTime date) {
    return DateFormat('hh:mm:ss a').format(date);
  }
}