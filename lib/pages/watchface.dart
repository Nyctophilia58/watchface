import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import '../constants/api_key.dart';
import '../utils/utilities.dart';
import '../utils/weather_utils.dart';

class WatchFace extends StatefulWidget {
  const WatchFace({super.key});

  @override
  State<WatchFace> createState() => _WatchFaceState();
}

class _WatchFaceState extends State<WatchFace> {
  late DateTime now;
  late tz.TZDateTime localTime;
  late Timer _timer;
  String selectedTimezone = '';
  String temperature = '...';
  IconData weatherIcon = Icons.wb_sunny;
  String apiKey = key;
  bool isEnglish = true;
  bool is24HourFormat = true;


  @override
  void initState() {
    super.initState();
    tz.initializeTimeZones();
    _setTimezone('Asia/Dhaka');
    _timer = Timer.periodic(const Duration(seconds: 1), _updateTime);
  }

  void _setTimezone(String timezone) {
    final location = tz.getLocation(timezone);
    final tzDateTime = tz.TZDateTime.now(location);
    setState(() {
      localTime = tzDateTime;
      selectedTimezone = timezone;
    });

    _fetchTemperature(timezone);
  }

  void _updateTime(Timer timer) {
    setState(() {
      now = DateTime.now();
      localTime = tz.TZDateTime.now(tz.getLocation(selectedTimezone));
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  Future<void> _fetchTemperature(String timezone) async {
    final weatherData = await getWeatherData(timezone, apiKey);
    setState(() {
      temperature = weatherData['temperature'];
      weatherIcon = weatherData['weatherIcon'];
    });
  }

  @override
  Widget build(BuildContext context) {
    String date = DateFormat('dd').format(localTime);
    String dayOfWeek = getDayOfWeek(localTime, isEnglish);
    String month = getMonth(localTime, isEnglish);

    int hour = localTime.hour;
    String amPm = '';
    if (!is24HourFormat) {
      amPm = hour >= 12 ? 'PM' : 'AM';
      hour = hour % 12;
      hour = hour == 0 ? 12 : hour;
    }

    String formattedHour = hour.toString().padLeft(2, '0');
    String formattedMinute = localTime.minute.toString().padLeft(2, '0');

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Watch Face',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 30),
        ),
        backgroundColor: Colors.blueGrey[300],
        actions: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 10),
            child: Text(
              isEnglish ? 'English' : 'বাংলা',
              style: const TextStyle(fontSize: 20, color: Colors.black),
            ),
          ),
          CupertinoSwitch(
            value: isEnglish,
            onChanged: (value) {
              setState(() {
                isEnglish = value;
              });
            },
          ),
          SizedBox(width: 10),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.black,
                border: Border.all(color: Colors.blueGrey, width: 3),
              ),
              child: Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Expanded(
                      child: Container(
                        width: 60,
                        height: 60,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.black,
                          border: Border.all(
                            color: Colors.blueGrey,
                            width: 3,
                          ),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              weatherIcon,
                              size: 15,
                              color: Colors.white,
                            ),
                            Text(
                              convertText(temperature, isEnglish),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 15,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          convertText(formattedHour, isEnglish),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 70,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          convertText(formattedMinute, isEnglish),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 70,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          is24HourFormat ? '' : isEnglish ? amPm : (amPm == 'AM') ? 'পূর্বাহ্ন' : 'অপরাহ্ন',
                          style: const TextStyle(color: Colors.white, fontSize: 12),
                        ),
                      ],
                    ),
                    Expanded(
                      child: Container(
                        width: 60,
                        height: 60,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.black,
                          border: Border.all(
                            color: Colors.blueGrey,
                            width: 3,
                          ),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              dayOfWeek,
                              style: TextStyle(
                                color: (dayOfWeek == 'Fri' || dayOfWeek == 'Sat' || dayOfWeek == 'শুক্র' || dayOfWeek == 'শনি')
                                    ? Colors.red[200]
                                    : Colors.white,
                                fontSize: 16,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                            Text(
                              '${convertText(date, isEnglish)} $month',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 30),
            SizedBox(
              width: 300,
              height: 60,
              child: InputDecorator(
                decoration: InputDecoration(
                  labelText: isEnglish ? 'Select Timezone' : 'টাইমজোন নির্বাচন করুন',
                  labelStyle: TextStyle(color: Colors.blueGrey[900], fontSize: 20),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.blueGrey, width: 2),
                  ),
                ),
                child: DropdownButton<String>(
                  value: selectedTimezone,
                  items: tz.timeZoneDatabase.locations.keys
                      .map((String timezone) {
                    return DropdownMenuItem<String>(
                      value: timezone,
                      child: Text(timezone),
                    );
                  })
                      .toList(),
                  onChanged: (String? newTimezone) {
                    if (newTimezone != null) {
                      _setTimezone(newTimezone);
                    }
                  },
                  style: const TextStyle(color: Colors.black),
                  dropdownColor: Colors.white,
                  isExpanded: true,
                  iconSize: 30,
                  iconEnabledColor: Colors.blueGrey[900],
                ),
              ),
            ),
            const SizedBox(height: 20),
            TextButton(
              onPressed: () {
                setState(() {
                  is24HourFormat = !is24HourFormat;
                });
              },
              style: TextButton.styleFrom(
                foregroundColor: Colors.white,
                backgroundColor: Colors.blueGrey[300],
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                  side: const BorderSide(color: Colors.blueGrey, width: 2),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              ),
              child: Text(
                is24HourFormat
                    ? (isEnglish ? '12 Hour Format' : '১২ ঘণ্টার ফরম্যাট')
                    : (isEnglish ? '24 Hour Format' : '২৪ ঘণ্টার ফরম্যাট'),
                style: const TextStyle(
                  color: Colors.black,
                  fontSize: 18,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
