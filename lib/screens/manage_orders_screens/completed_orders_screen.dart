import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:thereza_pedrosa_admin/others/Constants.dart';
import 'package:thereza_pedrosa_admin/others/Keys.dart';
import 'package:thereza_pedrosa_admin/others/Utils.dart';

import 'orders_lsit.dart';

class CompletedOrdersScreen extends StatefulWidget {
  @override
  _CompletedOrdersScreenState createState() => _CompletedOrdersScreenState();
}

class _CompletedOrdersScreenState extends State<CompletedOrdersScreen> {
  List<DocumentSnapshot> _completedOrders = [];
  bool _isLoading = true;
  StreamSubscription _subscription;

  @override
  void initState() {
    _getCompletedOrders();
    super.initState();
  }

  void _getCompletedOrders() {
    _subscription = FirebaseFirestore.instance
        .collection('orders')
        .where(Keys.ORDER_STATUS, isEqualTo: Constants.COMPLETED)
        .snapshots()
        .listen((orders) {
      _completedOrders.clear();
      orders.docs.forEach((order) {
        _completedOrders.add(order);
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
          : _completedOrders.isEmpty
              ? Utils.errorBody(message: 'No completed orders')
              : OrdersList(_completedOrders),
    );
  }

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}
