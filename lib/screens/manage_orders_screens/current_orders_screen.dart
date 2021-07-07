import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:thereza_pedrosa_admin/others/Constants.dart';
import 'package:thereza_pedrosa_admin/others/Keys.dart';
import 'package:thereza_pedrosa_admin/others/Utils.dart';

import 'orders_lsit.dart';

class CurrentOrdersScreen extends StatefulWidget {
  @override
  _CurrentOrdersScreenState createState() => _CurrentOrdersScreenState();
}

class _CurrentOrdersScreenState extends State<CurrentOrdersScreen> {
  List<DocumentSnapshot> _runningOrders = [];
  bool _isLoading = true;
  StreamSubscription _subscription;

  @override
  void initState() {
    _getRunningOrders();
    super.initState();
  }

  void _getRunningOrders() {
    _subscription =
        FirebaseFirestore.instance.collection('orders').snapshots().listen((orders) {
      _runningOrders.clear();
      orders.docs.forEach((order) {
        if (order[Keys.ORDER_STATUS] != Constants.COMPLETED)
          _runningOrders.add(order);
      });
      setState(() {
        _isLoading = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _isLoading
          ? Utils.loadingContainer()
          : _runningOrders.isEmpty
              ? Utils.errorBody(message: 'No running orders')
              : OrdersList(_runningOrders),
    );
  }

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}
