import 'package:flutter/material.dart';

import '../../contracts/IClick.dart';
import '../../others/Constants.dart';
import '../../others/FCM.dart';
import '../../others/Utils.dart';

class SendNotificationScreen extends StatefulWidget {
  @override
  _SendNotificationScreenState createState() => _SendNotificationScreenState();
}

class _SendNotificationScreenState extends State<SendNotificationScreen>
    implements IClick {
  var _titleController = TextEditingController();
  var _bodyController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: Utils.getAppBar(
        context: context,
        title: 'Send Notification',
        isLeading: false,
        family: 'Playfair',
        leadingObject: null,
      ),
      body: _getBody(),
    );
  }

  Widget _getBody() {
    return Container(
      padding: EdgeInsets.all(16),
      child: SingleChildScrollView(
        child: Column(
          children: [
            TextField(
              controller: _titleController,
              decoration: InputDecoration(
                  labelText: 'Enter Title', hintText: 'Title Here...'),
            ),
            SizedBox(
              height: 16,
            ),
            TextField(
              controller: _bodyController,
              decoration: InputDecoration(
                  labelText: 'Enter body', hintText: 'Body Here...'),
            ),
            SizedBox(
              height: 32,
            ),
            Utils.getBorderedButton(
              context,
              'SEND',
              'Playfair',
              this,
              Constants.ACCENT_COLOR,
            ),
          ],
        ),
      ),
    );
  }

  @override
  void onClick() {
    String title = _titleController.text.trim();
    String body = _bodyController.text.trim();
    if (title.isEmpty) {
      Utils.showToast(message: 'Title cannot be empty');
    } else if (body.isEmpty) {
      Utils.showToast(message: 'Body cannot be empty');
    } else {
      FCM.initGlobalNotification(title: title, body: body);
      Navigator.pop(context);
      Utils.showToast(message: 'Notification sent');
    }
  }
}
