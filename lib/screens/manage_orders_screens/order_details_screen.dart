import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:thereza_pedrosa_admin/others/Constants.dart';
import 'package:thereza_pedrosa_admin/others/FCM.dart';
import 'package:thereza_pedrosa_admin/others/Keys.dart';
import 'package:thereza_pedrosa_admin/others/Utils.dart';

class OrderDetailsScreen extends StatefulWidget {
  String _orderDocumentId;

  OrderDetailsScreen(this._orderDocumentId);

  @override
  _OrderDetailsScreenState createState() => _OrderDetailsScreenState();
}

class _OrderDetailsScreenState extends State<OrderDetailsScreen> {
  DocumentSnapshot _orderSnapshot;
  bool _isLoading = true;
  StreamSubscription _subscription;
  bool _placed = true, _on_the_way = false;

  @override
  void initState() {
    _subscription = FirebaseFirestore.instance
        .collection('orders')
        .doc(widget._orderDocumentId)
        .snapshots()
        .listen((orderSnapshot) {
      _orderSnapshot = orderSnapshot;
      setState(() {
        if (_orderSnapshot[Keys.ORDER_STATUS] == Constants.PLACED) {
          _placed = true;
          _on_the_way = false;
        } else {
          _placed = false;
          _on_the_way = true;
        }
        _isLoading = false;
      });
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: Utils.getAppBar(
        family: 'Playfair',
        context: context,
        title: 'Order Details',
        isLeading: false,
        leadingObject: null,
      ),
      body: _isLoading ? Utils.loadingContainer() : _getBody(),
    );
  }

  Widget _getBody() {
    return Container(
      padding: EdgeInsets.all(24),
      child: SingleChildScrollView(
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    ' Order Id',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: Colors.black54,
                    ),
                  ),
                ),
                Expanded(
                  child: Text(
                    ' OR_${_orderSnapshot.id.substring(0, 4)}',
                    textAlign: TextAlign.end,
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                ),
              ],
            ),
            Utils.getSizedBox(boxHeight: 12, boxWidth: 0),
            Row(
              children: [
                Expanded(
                  child: Text(
                    _getItemsNames(_orderSnapshot[Keys.ORDERED_ITEMS]),
                    style: TextStyle(
                      fontFamily: 'Playfair',
                      fontSize: 19,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                ),
              ],
            ),
            Utils.getSizedBox(boxHeight: 8, boxWidth: 0),
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Icon(
                  Icons.location_on,
                  size: 20,
                ),
                Expanded(
                  child: Text(
                    _getItemsNames(_orderSnapshot[Keys.ORDERED_ITEMS]),
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      color: Colors.black54,
                    ),
                  ),
                ),
              ],
            ),
            Utils.getSizedBox(boxHeight: 8, boxWidth: 0),
            Container(
              height: Utils.getScreenHeight(context) / 4,
              width: Utils.getScreenWidth(context),
              child: Card(
                elevation: 3,
                child: Padding(
                  padding: EdgeInsets.all(1),
                  child: Image.network(
                    _orderSnapshot[Keys.ORDERED_ITEMS][0]
                        [Keys.PRODUCT_IMAGE_URL_1],
                    height: Utils.getScreenHeight(context) / 4,
                    width: Utils.getScreenWidth(context),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
            Utils.getSizedBox(boxHeight: 8, boxWidth: 0),
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: Text(
                    'Status',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      color: Colors.black54,
                    ),
                  ),
                ),
                Container(
                  height: 25,
                  color: Colors.black12,
                  padding:
                      EdgeInsets.only(left: 16, right: 16, top: 4, bottom: 4),
                  child: Text(
                    _orderSnapshot[Keys.ORDER_STATUS],
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
            Utils.getSizedBox(boxHeight: 8, boxWidth: 0),
            _getInvoiceSection(),
            _getUpdateOrderSection(),
          ],
        ),
      ),
    );
  }

  Widget _getUpdateOrderSection() {
    return _orderSnapshot[Keys.ORDER_STATUS] != Constants.COMPLETED
        ? Container(
            margin: EdgeInsets.only(top: 8),
            child: Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: EdgeInsets.only(top: 16, bottom: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: EdgeInsets.only(left: 16, right: 16),
                      child: Text(
                        'Update Status',
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 19,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                    ),
                    Utils.getDivider(),
                    CheckboxListTile(
                      value: _placed,
                      onChanged: (val) {
                        if (val) {
                          setState(() {
                            _placed = val;
                            _on_the_way = !val;
                          });
                          _updateStatus(Constants.PLACED);
                        }
                      },
                      title: Text(
                        'Placed',
                        style: TextStyle(
                          fontFamily: 'Poppins',
                        ),
                      ),
                    ),
                    Utils.getDivider(),
                    CheckboxListTile(
                      value: _on_the_way,
                      onChanged: (val) {
                        if (val) {
                          setState(() {
                            _placed = !val;
                            _on_the_way = val;
                          });
                          _updateStatus(Constants.ON_THE_WAY);
                        }
                      },
                      title: Text(
                        'Being Delivered',
                        style: TextStyle(
                          fontFamily: 'Poppins',
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          )
        : Container();
  }

  Widget _getInvoiceSection() {
    return Container(
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.only(left: 16, right: 16, top: 16),
              child: Row(
                children: [
                  Text(
                    'INVOICE',
                    style: TextStyle(
                      color: Colors.black,
                      fontFamily: 'Poppins',
                      fontWeight: FontWeight.bold,
                      fontSize: 19,
                    ),
                  ),
                  Expanded(
                    child: Text(
                      '${(_orderSnapshot[Keys.TIMESTAMP] as Timestamp).toDate().day}/${(_orderSnapshot[Keys.TIMESTAMP] as Timestamp).toDate().month}/${(_orderSnapshot[Keys.TIMESTAMP] as Timestamp).toDate().year}',
                      textAlign: TextAlign.end,
                      style: TextStyle(
                        color: Colors.black,
                        fontFamily: 'Poppins',
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Utils.getDivider(),
            Padding(
              padding: EdgeInsets.only(left: 16, right: 16, top: 8),
              child: Row(
                children: [
                  Text(
                    'Total Amount',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                      color: Colors.black54,
                    ),
                  ),
                  Expanded(
                    child: Text(
                      '\$${_orderSnapshot[Keys.TOTAL_PRICE]}',
                      textAlign: TextAlign.end,
                      style: TextStyle(
                        color: Colors.black,
                        fontFamily: 'Poppins',
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Utils.getSizedBox(boxHeight: 4, boxWidth: 0),
            Padding(
              padding: EdgeInsets.only(left: 16, right: 16, bottom: 16),
              child: Row(
                children: [
                  Text(
                    'Delivery Fee',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontWeight: FontWeight.bold,
                      color: Colors.black54,
                      fontSize: 13,
                    ),
                  ),
                  Expanded(
                    child: Text(
                      '\$${_orderSnapshot[Keys.DELIVERY_PRICE]}',
                      textAlign: TextAlign.end,
                      style: TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Poppins',
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Utils.getDivider(),
            Padding(
              padding: EdgeInsets.only(left: 16, right: 16, bottom: 24, top: 8),
              child: Row(
                children: [
                  Text(
                    'Total Paid Amount',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontWeight: FontWeight.bold,
                      color: Colors.black54,
                      fontSize: 13,
                    ),
                  ),
                  Expanded(
                    child: Text(
                      '\$${_orderSnapshot[Keys.DELIVERY_PRICE] + _orderSnapshot[Keys.TOTAL_PRICE]}',
                      textAlign: TextAlign.end,
                      style: TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Poppins',
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _updateStatus(String status) {
    FirebaseFirestore.instance
        .collection('orders')
        .doc(_orderSnapshot.id)
        .set(
      {
        Keys.ORDER_STATUS: status,
      },
      SetOptions(
        merge: true,
      )
    );
    FCM.initAdminNotification(
      title: 'Order Updated',
      body: 'Order status is $status',
      orderById: _orderSnapshot[Keys.ORDER_BY_ID],
      orderDocumentId: _orderSnapshot.id,
    );
  }

  String _getItemsNames(List<Object> itemsList) {
    String itemsNamesString = '';
    for (int i = 0; i < itemsList.length; i++) {
      var j = itemsList[i];
      itemsNamesString =
      '$itemsNamesString${itemsNamesString.isNotEmpty
          ? ','
          : ''} ${(j as Map)[Keys.PRODUCT_TITLE]} ';
    }
    return itemsNamesString;
  }

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}
