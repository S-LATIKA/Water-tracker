import 'dart:ui';
import 'dart:math';
import 'package:flutter/material.dart';

import '../services/storage_service.dart';
import '../services/notification_service.dart';
import 'calendar_screen.dart';
import 'analytics_screen.dart';
import '../widgets/water_wave.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int intake = 0;
  int goal = 2000;
  Map<String, int> history = {};

  final goalController = TextEditingController();

  @override
  void initState() {
    super.initState();
    loadData();
  }

  void loadData() async {
    var data = await StorageService.loadData();
    setState(() {
      intake = data['intake'] ?? 0;
      goal = data['goal'] ?? 2000;
      history = Map<String, int>.from(data['history'] ?? {});
    });
  }

  void saveData() {
    StorageService.saveData(intake, goal, history);
  }

  void addWater(int amount) {
    String today = DateTime.now().toString().substring(0, 10);

    setState(() {
      intake += amount;
      history[today] = intake;
    });

    saveData();

    // 🎉 Goal celebration
    if (intake >= goal) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("🎉 Great Job! Goal Completed!"),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  void resetDaily() {
    String today = DateTime.now().toString().substring(0, 10);

    history[today] = intake;

    setState(() {
      intake = 0;
    });

    saveData();
  }

  // 🌙 AUTO DAY/NIGHT MODE
  List<Color> getBackgroundGradient() {
    int hour = DateTime.now().hour;

    if (hour >= 6 && hour < 18) {
      return [Color(0xFF56CCF2), Color(0xFF2F80ED)];
    } else {
      return [Color(0xFF0F2027), Color(0xFF203A43)];
    }
  }

  @override
  Widget build(BuildContext context) {
    double progress = intake / goal;

    return Scaffold(
      extendBodyBehindAppBar: true,

      appBar: AppBar(
        title: Text(
          "💧 Water Tracker",
          style: TextStyle(
            color: Colors.white, // ⭐ CHANGE COLOR HERE
            fontWeight: FontWeight.bold,
            fontSize: 22,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),

      body: Stack(
        children: [

          // 🌊 BACKGROUND IMAGE
          Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage("assets/images/water_bg.png"),
                fit: BoxFit.cover,
              ),
            ),
          ),

          // 🌈 DAY/NIGHT OVERLAY
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: getBackgroundGradient(),
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),

          // 💧 FLOATING BUBBLES
          ...List.generate(20, (index) => _bubble()),

          // 📱 MAIN CONTENT
          SingleChildScrollView(
            padding: EdgeInsets.fromLTRB(16, 100, 16, 16),
            child: Column(
              children: [

                Image.asset(
                  'assets/images/water.png',
                  height: MediaQuery.of(context).size.height * 0.25,
                ),

                SizedBox(height: 20),

                // 💎 GLASS CARD + 🌊 WAVE
                ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                    child: Container(
                      padding: EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                            color: Colors.white.withOpacity(0.2)),
                      ),
                      child: Column(
                        children: [

                          Text(
                            "Daily Goal: $goal ml",
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 18),
                          ),

                          SizedBox(height: 10),

                          Stack(
                            alignment: Alignment.center,
                            children: [
                              Container(
                                height: 180,
                                child: WaterWave(progress: progress),
                              ),
                              Text(
                                "$intake ml",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 26,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                SizedBox(height: 25),

                // 💧 BUTTONS
                Row(
                  mainAxisAlignment:
                  MainAxisAlignment.spaceEvenly,
                  children: [
                    _modernButton("+250 ml",
                            () => addWater(250)),
                    _modernButton("+500 ml",
                            () => addWater(500)),
                  ],
                ),

                SizedBox(height: 20),

                _fullButton("Reset Day", Icons.refresh,
                    resetDaily),

                SizedBox(height: 15),

                // 🎯 GOAL INPUT
                TextField(
                  controller: goalController,
                  keyboardType: TextInputType.number,
                  style: TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    labelText: "Set Goal (ml)",
                    labelStyle: TextStyle(color: Colors.white),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.white),
                    ),
                  ),
                ),

                SizedBox(height: 10),

                _fullButton("Update Goal", Icons.flag, () {
                  setState(() {
                    goal = int.parse(goalController.text);
                  });
                  saveData();
                }),

                SizedBox(height: 15),

                _fullButton("Test Reminder",
                    Icons.notifications, () {
                      NotificationService.showNotification();
                    }),

                SizedBox(height: 15),

                _fullButton("Start Hourly Reminder",
                    Icons.alarm, () {
                      NotificationService.scheduleHourlyReminder();
                    }),

                SizedBox(height: 15),

                _fullButton("View Calendar",
                    Icons.calendar_month, () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) =>
                              CalendarScreen(history: history),
                        ),
                      );
                    }),

                SizedBox(height: 15),

                _fullButton("View Analytics",
                    Icons.pie_chart, () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) =>
                              AnalyticsScreen(history: history),
                        ),
                      );
                    }),

                SizedBox(height: 25),

                // 📊 HISTORY
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text("History 📅",
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold)),
                ),

                SizedBox(height: 10),

                ...history.entries.map((e) => Container(
                  margin: EdgeInsets.symmetric(vertical: 5),
                  padding: EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    mainAxisAlignment:
                    MainAxisAlignment.spaceBetween,
                    children: [
                      Text(e.key,
                          style: TextStyle(color: Colors.white)),
                      Text("${e.value} ml",
                          style: TextStyle(color: Colors.white)),
                    ],
                  ),
                ))
              ],
            ),
          ),
        ],
      ),
    );
  }

  // 💧 FLOATING BUBBLE
  Widget _bubble() {
    final random = Random();
    return Positioned(
      left: random.nextDouble() * 300,
      bottom: random.nextDouble() * 600,
      child: Container(
        width: random.nextDouble() * 12 + 5,
        height: random.nextDouble() * 12 + 5,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.white.withOpacity(0.2),
        ),
      ),
    );
  }

  // 🔘 BUTTONS
  Widget _modernButton(String text, VoidCallback onPressed) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        padding:
        EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
      ),
      child: Text(text),
    );
  }

  Widget _fullButton(
      String text, IconData icon, VoidCallback onPressed) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: onPressed,
        icon: Icon(icon),
        label: Text(text),
      ),
    );
  }
}