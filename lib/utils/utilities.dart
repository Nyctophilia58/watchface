import 'package:bangla_converter/bangla_converter.dart';

String getDayOfWeek(DateTime localTime, bool isEnglish) {
  final List<String> daysEnglish = ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'];
  final List<String> daysBangla = ['রবি', 'সোম', 'মঙ্গল', 'বুধ', 'বৃহঃ', 'শুক্র', 'শনি'];

  int dayIndex = localTime.weekday % 7; // Adjust index (1=Monday in Dart)
  return isEnglish ? daysEnglish[dayIndex] : daysBangla[dayIndex];
}

String getMonth(DateTime localTime, bool isEnglish) {
  final List<String> monthsEnglish = [
    'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
  ];
  final List<String> monthsBangla = [
    'জানু', 'ফেব', 'মার্চ', 'এপ্রি', 'মে', 'জুন', 'জুল', 'আগ', 'সেপ', 'অক্টো', 'নভে', 'ডিসে'
  ];

  int monthIndex = localTime.month - 1; // Month is 1-based in Dart
  return isEnglish ? monthsEnglish[monthIndex] : monthsBangla[monthIndex];
}

String convertText(String text, bool isEnglish) {
  return isEnglish ? BanglaConverter.banToEng(text) : BanglaConverter.engToBan(text);
}
