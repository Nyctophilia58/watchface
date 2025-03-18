import 'package:bangla_converter/bangla_converter.dart';

String convertText(String text, bool isEnglish) {
  if (isEnglish) {
    return BanglaConverter.banToEng(text);
  } else {
    return BanglaConverter.engToBan(text);
  }
}
