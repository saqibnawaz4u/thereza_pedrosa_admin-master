import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:thereza_pedrosa_admin/contracts/IClick.dart';
import 'package:thereza_pedrosa_admin/contracts/ITextClicked.dart';
import 'package:thereza_pedrosa_admin/others/Constants.dart';
import 'package:thereza_pedrosa_admin/others/Keys.dart';
import 'package:thereza_pedrosa_admin/others/Utils.dart';
import 'package:thereza_pedrosa_admin/others/header.dart';

import 'login_screen.dart';

class ForgotPasswordScreen extends StatefulWidget {
  @override
  _ForgotPasswordScreenState createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen>
    implements ITextClicked, IClick {
  bool _isLoading = false;
  var _emailController = TextEditingController();

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
                Header('Password Reset'),
                Utils.getSizedBox(
                  boxHeight: 8,
                  boxWidth: 0,
                ),
                Text(
                  'A password reset link will be sent to your email address',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white,
                  ),
                ),
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
                Utils.getBorderedButton(
                  context,
                  'RESET',
                  'Poppins',
                  this,
                  Colors.white,
                ),
                Utils.getSizedBox(
                  boxHeight: 16,
                  boxWidth: 0,
                ),
                Row(
                  children: [
                    Utils.getClickableField(
                      key: Keys.DUMMY,
                      label: 'Go back to Login',
                      iTextClicked: this,
                      family: 'Poppins',
                    ),
                  ],
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
    Utils.pushReplacement(context, LoginScreen());
  }

  @override
  void onClick() {
    String email = _emailController.text.trim();
    if (email.isEmpty) {
      Utils.showToast(message: 'Email cannot be empty');
    } else {
      setState(() {
        _isLoading = true;
      });
      FirebaseAuth.instance.sendPasswordResetEmail(email: email).then((_) {
        setState(() {
          _isLoading = false;
          Utils.showToast(message: 'Link sent');
        });
      }).catchError((error) {
        setState(() {
          _isLoading = false;
          Utils.showToast(message: error.toString());
        });
      });
    }
  }
}
