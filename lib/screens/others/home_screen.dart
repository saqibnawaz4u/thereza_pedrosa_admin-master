import 'dart:async';
import 'dart:io' as Platform;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:thereza_pedrosa_admin/others/Keys.dart';
import 'package:thereza_pedrosa_admin/others/Utils.dart';
import 'package:thereza_pedrosa_admin/screens/manage_artists_screens/all_artists_screen.dart';
import 'package:thereza_pedrosa_admin/screens/manage_categories_screens/all_categories_screen.dart';
import 'package:thereza_pedrosa_admin/screens/manage_events_screens/all_events_screen.dart';
import 'package:thereza_pedrosa_admin/screens/manage_exhibitions_screens/exhibition_screen.dart';
import 'package:thereza_pedrosa_admin/screens/manage_offers_screens/offers_list_screen.dart';
import 'package:thereza_pedrosa_admin/screens/manage_orders_screens/order_details_screen.dart';
import 'package:thereza_pedrosa_admin/screens/manage_orders_screens/orders_main_screen.dart';
import 'package:thereza_pedrosa_admin/screens/manage_products_screens/products_screen.dart';
import 'package:thereza_pedrosa_admin/screens/others/account_settings_screen.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
   FirebaseMessaging _firebaseMessaging;
  StreamSubscription _fcmSubscription;

  @override
  void initState() {
    _initFcm();
    super.initState();
  }

  Future<void> _initFcm() async {
    if (Platform.Platform.isIOS) {
      await _firebaseMessaging.requestPermission(
        alert: true,
        sound: true,
        badge: true,
        announcement: true,
      );

      FirebaseMessaging.onMessage.listen( (RemoteMessage message) {
        Utils.push(
            context, OrderDetailsScreen( message.data['order_document_id'] ) );
      } );
      FirebaseMessaging.onMessageOpenedApp.listen( (RemoteMessage message) {
        Utils.push(
            context, OrderDetailsScreen( message.data['order_document_id'] ) );
      } );

      _fcmSubscription = _firebaseMessaging.onTokenRefresh.listen( (token) {
        _saveTokenToFirestore( token.toString( ) );
      } );
    }
  }
  Future<void> _saveTokenToFirestore(token) async {
    String _uid = (await FirebaseAuth.instance.currentUser).uid;
    FirebaseFirestore.instance.collection('admin_fcms').doc(_uid).set(
      {
        Keys.FCM_TOKEN: token,
      },
      SetOptions(
        merge: true,
      )
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: Utils.getAppBar(
        context: context,
        title: 'Admin Dashboard',
        isLeading: false,
        leadingObject: null,
        family: 'Playfair',
      ),
      body: _getBody(),
    );
  }

  Widget _getBody() {
    return GridView.count(
      padding: EdgeInsets.all(16),
      crossAxisCount: 2,
      children: [
        _rowDesign(
          0,
          'Manage\nOrders',
          'images/manage_orders.svg',
        ),
        _rowDesign(
          1,
          'Manage\nProducts',
          'images/manage_products.svg',
        ),
        _rowDesign(
          2,
          'Manage\nCategories',
          'images/manage_categories.svg',
        ),
        _rowDesign(
          3,
          'Manage\nExhibitions',
          'images/manage_exhibitions.svg',
        ),
        _rowDesign(
          4,
          'Manage\nEvents',
          'images/manage_events.svg',
        ),
        _rowDesign(
          5,
          'Manage\nOffers',
          'images/manage_offers.svg',
        ),
        _rowDesign(
          6,
          'Manage\nArtists',
          'images/manage_artists.svg',
        ),
        _rowDesign(
          7,
          'Account\nSettings',
          'images/account_settings.svg',
        ),
      ],
    );
  }

  Widget _rowDesign(int index, String label, String icon) {
    return GestureDetector(
      onTap: () {
        switch (index) {
          case 0:
            {
              Utils.push(context, OrdersMainScreen());
              break;
            }
          case 1:
            {
              Utils.push(context, ProductsScreen());
              break;
            }
          case 2:
            {
              Utils.push(context, AllCategoriesScreen());
              break;
            }
          case 3:
            {
              Utils.push(context, ExhibitionScreen());
              break;
            }
          case 4:
            {
              Utils.push(context, AllEventsScreen());
              break;
            }
          case 5:
            {
              Utils.push(context, OffersListScreen());
              break;
            }
          case 6:
            {
              Utils.push(context, AllArtistsScreen());
              break;
            }
          case 7:
            {
              Utils.push(context, AccountSettingsScreen());
              break;
            }
        }
      },
      child: Card(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SvgPicture.asset(
                icon,
                width: Utils.getScreenWidth(context) / 10,
              ),
              Utils.getSizedBox(boxHeight: 16, boxWidth: 0),
              Text(
                label,
                style: TextStyle(
                  fontFamily: 'Playfair',
                  fontSize: Utils.getScreenWidth(context) / 22,
                  color: Colors.black,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
