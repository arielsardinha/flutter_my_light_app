import 'package:intl/intl.dart';

mixin DateFormatMixin {
  String dateFormatDateTimeInString(DateTime dateTime) {
    return DateFormat('dd-MM-yyyy HH:mm:ss').format(dateTime);
  }
}
