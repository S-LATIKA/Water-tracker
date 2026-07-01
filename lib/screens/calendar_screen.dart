import 'package:flutter/material.dart';
import 'dart:ui';
import 'package:table_calendar/table_calendar.dart';

class CalendarScreen extends StatefulWidget {
  final Map<String, int> history;

  CalendarScreen({required this.history});

  @override
  _CalendarScreenState createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  DateTime selectedDay = DateTime.now();

  int getBestIntake() {
    if (widget.history.isEmpty) return 0;
    return widget.history.values.reduce((a, b) => a > b ? a : b);
  }

  @override
  Widget build(BuildContext context) {
    String selectedKey = selectedDay.toString().substring(0, 10);
    int intake = widget.history[selectedKey] ?? 0;
    int best = getBestIntake();

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text(
          "📅 History Calendar",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: Colors.white),
      ),

      // 🌌 MODERN BACKGROUND
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFF0F2027),
              Color(0xFF203A43),
              Color(0xFF2C5364),
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),

        child: Stack(
          children: [

            // ✨ Glow Effects
            Positioned(
              top: 100,
              left: 50,
              child: _glowCircle(120),
            ),
            Positioned(
              bottom: 150,
              right: 40,
              child: _glowCircle(80),
            ),

            // 🌫 Main Content
            Container(
              color: Colors.black.withOpacity(0.2),

              child: Column(
                children: [

                  SizedBox(height: 100),

                  // 💎 GLASS CALENDAR
                  Padding(
                    padding: EdgeInsets.all(16),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: BackdropFilter(
                        filter:
                        ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                        child: Container(
                          padding: EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                                color: Colors.white.withOpacity(0.2)),
                          ),

                          child: TableCalendar(
                            focusedDay: selectedDay,
                            firstDay: DateTime(2020),
                            lastDay: DateTime(2100),

                            selectedDayPredicate: (day) =>
                                isSameDay(day, selectedDay),

                            onDaySelected: (selected, focused) {
                              setState(() {
                                selectedDay = selected;
                              });
                            },

                            calendarStyle: CalendarStyle(
                              defaultTextStyle: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                              weekendTextStyle: TextStyle(
                                color: Colors.lightBlueAccent,
                              ),

                              selectedDecoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [Colors.blue, Colors.cyan],
                                ),
                                shape: BoxShape.circle,
                              ),

                              todayDecoration: BoxDecoration(
                                color: Colors.orange,
                                shape: BoxShape.circle,
                              ),

                              markerDecoration: BoxDecoration(
                                color: Colors.yellow,
                                shape: BoxShape.circle,
                              ),
                            ),

                            calendarBuilders: CalendarBuilders(
                              defaultBuilder:
                                  (context, day, focusedDay) {
                                String key =
                                day.toString().substring(0, 10);
                                int value =
                                    widget.history[key] ?? 0;

                                if (value == best && best != 0) {
                                  return Container(
                                    alignment: Alignment.center,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      gradient: LinearGradient(
                                        colors: [
                                          Colors.green,
                                          Colors.lightGreenAccent
                                        ],
                                      ),
                                    ),
                                    child: Text(
                                      '${day.day}',
                                      style: TextStyle(
                                        color: Colors.black,
                                        fontWeight:
                                        FontWeight.bold,
                                      ),
                                    ),
                                  );
                                }

                                return null;
                              },
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),

                  SizedBox(height: 20),

                  // 💧 SELECTED DAY INFO
                  ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: BackdropFilter(
                      filter:
                      ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                      child: Container(
                        margin:
                        EdgeInsets.symmetric(horizontal: 20),
                        padding: EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Column(
                          children: [

                            Text(
                              "Selected Day 💧",
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 18),
                            ),

                            SizedBox(height: 10),

                            Text(
                              selectedKey,
                              style: TextStyle(
                                  color: Colors.white70),
                            ),

                            SizedBox(height: 10),

                            Text(
                              "$intake ml",
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold),
                            ),

                            SizedBox(height: 10),

                            if (intake == best && intake != 0)
                              Text(
                                "🏆 Best Day!",
                                style: TextStyle(
                                    color: Colors.yellow,
                                    fontWeight:
                                    FontWeight.bold),
                              )
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ✨ Glow Circle Widget
Widget _glowCircle(double size) {
  return Container(
    width: size,
    height: size,
    decoration: BoxDecoration(
      shape: BoxShape.circle,
      color: Colors.blueAccent.withOpacity(0.2),
      boxShadow: [
        BoxShadow(
          color: Colors.blueAccent.withOpacity(0.6),
          blurRadius: 50,
          spreadRadius: 10,
        )
      ],
    ),
  );
}