import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:thereza_pedrosa_admin/contracts/IContinueClicked.dart';
import 'package:thereza_pedrosa_admin/others/Utils.dart';
import 'package:thereza_pedrosa_admin/screens/auth_screens/login_screen.dart';
import 'package:thereza_pedrosa_admin/screens/others/send_notification_screen.dart';
import 'package:thereza_pedrosa_admin/screens/others/url_link.dart';

class AccountSettingsScreen extends StatefulWidget {
  @override
  _AccountSettingsScreenState createState() => _AccountSettingsScreenState();
}

class _AccountSettingsScreenState extends State<AccountSettingsScreen>
    implements IContinueClicked {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: Utils.getAppBar(
        context: context,
        title: 'Account Settings',
        isLeading: false,
        family: 'Playfair',
        leadingObject: null,
      ),
      body: ListView(
        padding: EdgeInsets.all(16),
        children: [
          _getRow(0, 'Send Notification', Icons.notifications_active),
          _getRow(1, 'Privacy Policy', Icons.security),
          _getRow(2, 'Log Out', Icons.exit_to_app),
        ],
      ),
    );
  }

  Widget _getRow(int index, String label, IconData icon) {
    return ListTile(
      onTap: () {
        switch (index) {
          case 0:
            {
              Utils.push(context, SendNotificationScreen());
              break;
            }

          case 1:
            {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => Privacy(),
                ),
              );
              break;
            }

          case 2:
            {
              Utils.showInfoDialog(
                context: context,
                title: 'Log Out!',
                message: 'Are you sure you want to continue?',
                iDeleteClicked: this,
              );
              break;
            }
        }
      },
      leading: Icon(icon),
      title: Text(
        label,
        style: TextStyle(fontFamily: 'Poppins'),
      ),
    );
  }

  @override
  void onContinueClicked() async {
    String uid = (await FirebaseAuth.instance.currentUser).uid;
    FirebaseFirestore.instance.collection('admin_fcms').doc(uid).delete();
    await FirebaseAuth.instance.signOut();
    Utils.pushReplacement(context, LoginScreen());
  }
}
