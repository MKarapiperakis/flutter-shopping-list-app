import 'dart:convert';
// import 'package:chat_app/screens/chatPage.dart';
import 'package:chat_app/screens/shoppingCart.dart';
import 'package:chat_app/screens/login.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<StatefulWidget> createState() {
    return _HomeScreenState();
  }
}

class _HomeScreenState extends State<HomeScreen> {
  var _activeScreen = 'login-screen';
  var _username = '';
  var _id;
  var _token;

  @override
  void initState() {
    super.initState();
    getToken();
  }

  void _login(String res) {
    Map<String, dynamic> data = json.decode(res);
    String token = data['token'];
    setState(() {
      _username = data["username"];
      _id = data["userId"];
      _token = token ?? '';
    });
    setToken(token);
    getToken();
  }

  void _logout() {
    deleteToken();
    getToken();
  }

  void setToken(token) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setBool("isLoggedIn", true);
    prefs.setString("token", token);
    prefs.setString("username", _username);
    prefs.setInt("id", _id);
  }

  void deleteToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setBool("isLoggedIn", false);
    prefs.setString("token", '');
    prefs.setString("username", '');
    prefs.setInt("id", 0);
  }

  void getToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var status = prefs.getBool('isLoggedIn') ?? false;
    _token = prefs.getString('token') ?? '';
    _username = prefs.getString('username') ?? '';
    _id = prefs.getInt('id') ?? 0;

    print(
        'user $_username logged in: $status with token: $_token and userId: $_id');
    setState(() {
      status ? _activeScreen = 'shopping-cart' : _activeScreen = 'login-screen';
    });
  }

  @override
  Widget build(BuildContext context) {
    Widget currentWidget = LoginScreen(submit: _login);

    if (_activeScreen == 'shopping-cart') {
      currentWidget = ShoppingCartScreen(
          logout: _logout, username: _username, id: _id, token: _token);
    }

    return currentWidget;
  }
}
