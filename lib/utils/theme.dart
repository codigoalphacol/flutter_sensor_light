import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';


ThemeData light = ThemeData(
  brightness: Brightness.light,
  primarySwatch: Colors.blue,
  accentColor: Colors.pink,
  scaffoldBackgroundColor: Color(0xfff1f1f1),
  textTheme: TextTheme(
    headline: TextStyle(fontSize: 72.0,  fontWeight: FontWeight.bold),
    title: TextStyle(fontSize: 36.0,  fontStyle: FontStyle.italic),
    body1: TextStyle(fontSize: 14.0,  fontFamily: 'Hind', color: Colors.black),
  ),
);

ThemeData dark = ThemeData(
  brightness: Brightness.dark,
  primarySwatch: Colors.blue,
  accentColor: Colors.pink,
  textTheme: TextTheme(
    headline: TextStyle(fontSize: 72.0,  fontWeight: FontWeight.bold),
    title: TextStyle(fontSize: 36.0,  fontStyle: FontStyle.italic),
    body1: TextStyle(fontSize: 14.0,  fontFamily: 'Hind', color: Colors.white),
  ),
);

class ThemeNotifier extends ChangeNotifier {
  final String key = "theme";
  SharedPreferences _prefs;
  bool  _darkTheme;

  bool get darkTheme => _darkTheme;

  ThemeNotifier() {
    _darkTheme = true;
    _loadFromPrefs();
  }

  toogleTheme(){
    _darkTheme = !_darkTheme;
    _saveToPrefs();
    notifyListeners();
  }

  _initPrefs() async {
    if(_prefs == null)
    _prefs = await SharedPreferences.getInstance();
  }

  _loadFromPrefs() async {
    await _initPrefs();
    _darkTheme = _prefs.getBool(key) ?? true;
    notifyListeners();
  }

  _saveToPrefs() async {
    await _initPrefs();
    _prefs.setBool(key, _darkTheme);
  }

}