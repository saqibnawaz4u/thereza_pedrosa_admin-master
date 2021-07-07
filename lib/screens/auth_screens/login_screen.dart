import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:thereza_pedrosa_admin/contracts/IClick.dart';
import 'package:thereza_pedrosa_admin/contracts/ITextClicked.dart';
import 'package:thereza_pedrosa_admin/others/Constants.dart';
import 'package:thereza_pedrosa_admin/others/Keys.dart';
import 'package:thereza_pedrosa_admin/others/Utils.dart';
import 'package:thereza_pedrosa_admin/others/header.dart';
import 'package:thereza_pedrosa_admin/screens/others/home_screen.dart';

import 'forgot_password_screen.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    implements ITextClicked, IClick {
  bool _isLoading = false;
  var _emailController = TextEditingController();
  var _passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          _getBody(),
          _isLoading ? Utils.loadingContainer() : Container(),
        ],
      ),
    );
  }

  Widget _getBody() {
    return SingleChildScrollView(
      child: Stack(
        children: [
          Container(
            width: Utils.getScreenWidth(context),
            height: Utils.getScreenHeight(context),
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage('images/splash_background.png'),
                fit: BoxFit.cover,
              ),
            ),
          ),
          Container(
            width: Utils.getScreenWidth(context),
            height: Utils.getScreenHeight(context),
            color: Colors.black38,
            padding: EdgeInsets.all(16),
            child: Column(
              children: [
                Utils.getSizedBox(
                  boxHeight: 80,
                  boxWidth: 0,
                ),
                Header('Admin Panel'),
                Utils.getSizedBox(
                  boxHeight: 64,
                  boxWidth: 0,
                ),
                Utils.getAuthTextField(
                  controller: _emailController,
                  label: 'Admin email',
                  icon: Icon(
                    Icons.email,
                    color: Colors.white,
                  ),
                  isPassword: false,
                  isPhone: false,
                  enabled: true,
                  maxLines: 1,
                ),
                Utils.getSizedBox(
                  boxHeight: 32,
                  boxWidth: 0,
                ),
                Utils.getAuthTextField(
                  controller: _passwordController,
                  label: 'Admin password',
                  icon: Icon(
                    Icons.lock,
                    color: Colors.white,
                  ),
                  isPassword: true,
                  isPhone: false,
                  enabled: true,
                  maxLines: 1,
                ),
                Utils.getSizedBox(
                  boxHeight: 16,
                  boxWidth: 0,
                ),
                Row(
                  children: [
                    Utils.getClickableField(
                      key: Keys.FORGOT_PASSWORD,
                      label: 'Forgot Password?',
                      iTextClicked: this,
                      family: 'Poppins',
                    ),
                  ],
                ),
                Utils.getSizedBox(
                  boxHeight: 32,
                  boxWidth: 0,
                ),
                Utils.getBorderedButton(
                  context,
                  'LOGIN',
                  'Poppins',
                  this,
                  Colors.white,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  void onTextClicked(String key) {
    if (key == Keys.FORGOT_PASSWORD) {
      Utils.pushReplacement(context, ForgotPasswordScreen());
    }
  }

  @override
  void onClick() {
    String email = _emailController.text.trim();
    String password = _passwordController.text.trim();
    if (email.isEmpty) {
      Utils.showToast(message: 'Email cannot be empty');
    } else if (password.isEmpty) {
      Utils.showToast(message: 'Password cannot be empty');
    } else {
      setState(() {
        _isLoading = true;
      });
      FirebaseAuth.instance
          .signInWithEmailAndPassword(email: email, password: password)
          .then((_) {
        _getFirestoreAdminData( email);
      }).catchError((error) {
        setState(() {
          _isLoading = false;
          Utils.showToast(message: error.message);
        });
      });
    }
  }

  void _getFirestoreAdminData( String email) {
    FirebaseFirestore.instance
        .collection('admins')
        .doc(email)
        .get()
        .then((documentSnapshot) {
      if (documentSnapshot.exists)
        Utils.pushReplacement(context, HomeScreen());
      else {
        Utils.showToast(message: 'You are not an admin');
        setState(() {
          FirebaseAuth.instance.signOut();
          _isLoading = false;
        });
      }
    }).catchError((error) {
      setState(() {
        _isLoading = false;
        Utils.showToast(message: error.message);
      });
    });
  }
}
