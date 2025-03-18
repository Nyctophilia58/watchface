import 'package:timezone/timezone.dart' as tz;

void setTimezone(String timezone, Function(tz.TZDateTime) onUpdateTime) {
  final location = tz.getLocation(timezone);
  final tzDateTime = tz.TZDateTime.now(location);
  onUpdateTime(tzDateTime);
}
