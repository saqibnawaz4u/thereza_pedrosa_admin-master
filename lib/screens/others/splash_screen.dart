import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:thereza_pedrosa_admin/others/Utils.dart';
import 'package:thereza_pedrosa_admin/screens/auth_screens/login_screen.dart';

import 'home_screen.dart';

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  StreamSubscription _subscription;

  @override
  void initState() {
    _subscription = _counter().listen((count) async {
      if (count == 3) {
        if (await FirebaseAuth.instance.currentUser == null)
          Utils.pushReplacement(context, LoginScreen());
        else
          Utils.pushReplacement(context, HomeScreen());
      }
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: Utils.getScreenWidth(context),
        height: Utils.getScreenHeight(context),
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage('images/splash_background.png'),
            fit: BoxFit.cover,
          ),
        ),
        child: Column(
          children: [
            Image.asset(
              'images/logo.png',
              width: 300,
              height: 250,
            ),
          ],
        ),
      ),
    );
  }

  Stream<int> _counter() async* {
    int count = 0;
    while (true) {
      yield count;
      await Future.delayed(
        Duration(seconds: 1),
      );
      count++;
    }
  }

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}