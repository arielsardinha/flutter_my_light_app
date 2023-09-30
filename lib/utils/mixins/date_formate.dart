import 'package:intl/intl.dart';

mixin DateFormatMixin {
  String dateFormatDateTimeInStringFullTime(DateTime dateTime) {
    return DateFormat('dd-MM-yyyy - HH:mm:ss').format(dateTime);
  }
}
