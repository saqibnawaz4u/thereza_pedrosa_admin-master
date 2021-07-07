import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:thereza_pedrosa_admin/others/Keys.dart';

import 'Constants.dart';

class FCM {
  static void initAdminNotification({
    @required title,
    @required body,
    @required orderById,
    @required orderDocumentId,
  }) async {
    DocumentSnapshot snapshot =
        await FirebaseFirestore.instance.collection('users').doc(orderById).get();
    if (snapshot[Keys.FCM_TOKEN] != null)
      _sendNotification(
        fcmToken: snapshot[Keys.FCM_TOKEN],
        title: title,
        body: body,
        data: {
          'order_document_id': orderDocumentId,
          'click_action': 'FLUTTER_NOTIFICATION_CLICK',
        },
      );
  }

  static void initGlobalNotification({
    @required title,
    @required body,
  }) async {
    QuerySnapshot querySnapshot =
        await FirebaseFirestore.instance.collection('users').get();
    querySnapshot.docs.forEach((snapshot) {
      print("Here is the key ${snapshot['fcm_token']}");
      if (snapshot[Keys.FCM_TOKEN] != null)
        _sendNotification(
          fcmToken: snapshot[Keys.FCM_TOKEN],
          title: title,
          body: body,
          data: {
            'click_action': 'FLUTTER_NOTIFICATION_CLICK',
          },
        );
    });
  }

  static void _sendNotification({
    @required String fcmToken,
    @required String title,
    @required String body,
    @required Map<String, dynamic> data,
  }) {
    final postUrl = 'https://fcm.googleapis.com/fcm/send';
    http.post(
      ///Uri.http('https://fcm.googleapis.com', "/fcm/send"),,
      Uri.parse(postUrl),
      headers: <String, String>{
        'Content-Type': 'application/json',
        'Authorization': 'key=${Constants.SERVER_TOKEN}',
      },
      body: jsonEncode(
        <String, dynamic>{
          'notification': <String, dynamic>{'body': body, 'title': title},
          'priority': 'high',
          'data': data,
          'to': fcmToken,
        },
      ),
    );
  }
}
