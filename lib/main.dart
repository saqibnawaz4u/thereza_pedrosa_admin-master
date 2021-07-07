import 'package:flutter/material.dart';
import 'package:thereza_pedrosa_admin/others/Constants.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:thereza_pedrosa_admin/screens/others/splash_screen.dart';

main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(
    MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        accentColor: Constants.ACCENT_COLOR,
        primaryColor: Constants.PRIMARY_COLOR,
        fontFamily: 'Playfair',
      ),
      home: SplashScreen( ),
    ),
  );
}
