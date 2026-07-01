import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class StorageService {
  static Future<void> saveData(
      int intake, int goal, Map<String, int> history) async {
    final prefs = await SharedPreferences.getInstance();

    prefs.setInt('intake', intake);
    prefs.setInt('goal', goal);
    prefs.setString('history', jsonEncode(history));
  }
  static Future<Map<String, dynamic>> loadData() async {
    final prefs = await SharedPreferences.getInstance();

    String historyString = prefs.getString('history') ?? "{}";

    return {
      'intake': prefs.getInt('intake') ?? 0,
      'goal': prefs.getInt('goal') ?? 2000,
      'history': Map<String, int>.from(jsonDecode(historyString)),
    };
  }
}