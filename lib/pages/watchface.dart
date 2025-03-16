import 'dart:async';
import 'dart:convert';
import 'package:bangla_converter/bangla_converter.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import  '../constants/api_key.dart';

class WatchFace extends StatefulWidget {
  const WatchFace({super.key});

  @override
  State<WatchFace> createState() => _WatchFaceState();
}

class _WatchFaceState extends State<WatchFace> {
  late DateTime now;
  late tz.TZDateTime localTime;
  String selectedTimezone = ''; // Initially empty, will hold the selected timezone
  String temperature = '...'; // Placeholder for temperature
  String weatherIcon = '☀️'; // Default icon (sunny)
  String apiKey = key; // Replace with your OpenWeather API key
  bool isEnglish = true; // Flag to toggle between English and Bengali
  bool is24HourFormat = true; // Default to 24-hour format

  @override
  void initState() {
    super.initState();
    tz.initializeTimeZones();
    // Set default timezone to local time
    _setTimezone('Asia/Dhaka');
  }

  // Set the timezone and update the time
  void _setTimezone(String timezone) {
    final location = tz.getLocation(timezone);
    final tzDateTime = tz.TZDateTime.now(location);
    setState(() {
      localTime = tzDateTime;
      selectedTimezone = timezone;
    });

    _fetchTemperature(timezone); // Fetch temperature whenever timezone is changed
  }


  // Fetch temperature from OpenWeather API
  Future<void> _fetchTemperature(String timezone) async {
    try {
      final location = tz.getLocation(timezone);
      final cityName = location.name.split('/')[1]; // Extract city name from timezone
      final url = Uri.parse(
        'http://api.openweathermap.org/data/2.5/weather?q=$cityName&appid=$apiKey&units=metric',
      );

      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final temp = data['main']['temp'];
        final weatherCondition = data['weather'][0]['main']; // Fetch weather condition (e.g., 'Clear', 'Rain', etc.)
        setState(() {
          temperature = '${temp.toStringAsFixed(0)}°C'; // Update temperature
          _setWeatherIcon(weatherCondition); // Update weather icon based on condition
        });
      } else {
        throw Exception('Failed to fetch weather data');
      }
    } catch (e) {
      print('Error fetching temperature: $e');
    }
  }

  // Set the weather icon based on the condition
  void _setWeatherIcon(String weatherCondition) {
    if (weatherCondition == 'Clear') {
      weatherIcon = '☀️'; // Sunny weather
    } else if (weatherCondition == 'Clouds') {
      weatherIcon = '☁️'; // Cloudy weather
    } else if (weatherCondition == 'Rain') {
      weatherIcon = '🌧️'; // Rainy weather
    } else if (weatherCondition == 'Snow') {
      weatherIcon = '❄️'; // Snowy weather
    } else if (weatherCondition == 'Thunderstorm') {
      weatherIcon = '⛈️'; // Thunderstorm weather
    } else if (weatherCondition == 'Drizzle') {
      weatherIcon = '🌦️'; // Drizzle weather
    } else {
      weatherIcon = '☀️'; // Default to sunny if the condition is unknown
    }
  }

  // convert the text from Bangla to English and vice versa
  String _convertText(String text) {
    if (isEnglish) {
      return BanglaConverter.banToEng(text);
    } else {
      return BanglaConverter.engToBan(text);
    }
  }


  @override
  Widget build(BuildContext context) {
    String date = DateFormat('dd').format(localTime);

    // English and Bangla Days
    final List<String> daysEnglish = ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'];
    final List<String> daysBangla = ['রবি', 'সোম', 'মঙ্গল', 'বুধ', 'বৃহস্পতি', 'শুক্র', 'শনি'];

// English and Bangla Months
    final List<String> monthsEnglish = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];

    final List<String> monthsBangla = [
      'জানু', 'ফেব', 'মার্চ', 'এপ্রি', 'মে', 'জুন', 'জুল', 'আগ', 'সেপ', 'অক্টো', 'নভে', 'ডিসে'
    ];


    // Get the day index
    int dayIndex = localTime.weekday % 7; // Adjust index (1=Monday in Dart)
    String dayOfWeek = isEnglish ? daysEnglish[dayIndex] : daysBangla[dayIndex];

    // Get the month index
    int monthIndex = localTime.month - 1; // Month is 1-based in Dart
    String month = isEnglish ? monthsEnglish[monthIndex] : monthsBangla[monthIndex];


    // Convert 24-hour format to 12-hour if needed
    int hour = localTime.hour;

    if (!is24HourFormat) {
      hour = hour % 12;
      hour = hour == 0 ? 12 : hour; // Convert 0 to 12 for 12 AM case
    }

    String formattedHour = hour.toString().padLeft(2, '0');
    String formattedMinute = localTime.minute.toString().padLeft(2, '0');


    // Get the list of all timezones
    final timezones = tz.timeZoneDatabase.locations.keys.toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Watch Face',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 30,
          ),
        ),
        backgroundColor: Colors.blueGrey[300],
        // add a button to convert text from Bangla to English and vice versa
        actions: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 10),
            child: Text(
              isEnglish ? 'English' : 'বাংলা',
              style: const TextStyle(
                fontSize: 20,
                color: Colors.black,
              ),
            ),
          ),
          CupertinoSwitch(
            value: isEnglish,
            onChanged: (value) {
              setState(() {
                isEnglish = value;
              });
            }),
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
                    // Left circle (Weather Info)
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
                            Text(
                              weatherIcon,
                              style: const TextStyle(
                                fontSize: 15,
                                color: Colors.white,
                              ),
                            ),
                            Text(
                              _convertText(temperature),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 15,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    // Middle (Time Display)
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            _convertText(formattedHour),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 70,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            _convertText(formattedMinute),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 70,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Right circle (Day & Date)
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
                            Text(
                              dayOfWeek,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                              ),
                            ),
                            Text(
                            '${_convertText(date)} $month',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                              ),
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
            // Dropdown Button to change timezone
            SizedBox(
              width: 300, // Adjust the width as needed
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
                  items: timezones.map((String timezone) {
                    return DropdownMenuItem<String>(
                      value: timezone,
                      child: Text(timezone),
                    );
                  }).toList(),
                  onChanged: (String? newTimezone) {
                    if (newTimezone != null) {
                      _setTimezone(newTimezone);
                    }
                  },
                  style: const TextStyle(color: Colors.black),
                  dropdownColor: Colors.white,
                  isExpanded: true,  // Makes the button expand to fill the container's width
                  iconSize: 30,
                  iconEnabledColor: Colors.blueGrey[900],
                ),
              ),
            ),
            const SizedBox(height: 20),
            TextButton(
              onPressed: () {
                setState(() {
                  is24HourFormat = !is24HourFormat; // Toggle the format
                });
              },
              style: TextButton.styleFrom(
                foregroundColor: Colors.white, // Text color
                backgroundColor: Colors.blueGrey[300], // Button background color
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8), // Rounded corners
                  side: const BorderSide(color: Colors.blueGrey, width: 2), // Border color & width
                ),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8), // Button padding
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
