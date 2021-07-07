import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:thereza_pedrosa_admin/others/Constants.dart';
import 'package:thereza_pedrosa_admin/others/Keys.dart';
import 'package:thereza_pedrosa_admin/others/Utils.dart';

import 'order_details_screen.dart';

class OrdersList extends StatefulWidget {
  List<DocumentSnapshot> _ordersList;

  OrdersList(this._ordersList);

  @override
  _OrdersListState createState() => _OrdersListState();
}

class _OrdersListState extends State<OrdersList> {
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(top: 32),
      child: ListView.builder(
        itemCount: widget._ordersList.length,
        itemBuilder: (context, position) =>
            _rowDesign(widget._ordersList[position]),
      ),
    );
  }

  Widget _rowDesign(DocumentSnapshot snapshot) {
    return Container(
      child: Card(
        child: Padding(
          padding: EdgeInsets.all(8),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                flex: 2,
                child: Image.network(
                  snapshot[Keys.ORDERED_ITEMS][0][Keys.PRODUCT_IMAGE_URL_1],
                  height: 100,
                  fit: BoxFit.cover,
                ),
              ),
              Utils.getSizedBox(boxHeight: 0, boxWidth: 8),
              Expanded(
                flex: 4,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          ' Order Id',
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: Colors.black54,
                          ),
                        ),
                        Text(
                          ' # OR_${snapshot.id.substring(0, 4)}',
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                        Expanded(
                          child: Container(),
                        ),
                        Text(
                          '${(snapshot[Keys.TIMESTAMP] as Timestamp).toDate().day}/${(snapshot[Keys.TIMESTAMP] as Timestamp).toDate().month}/${(snapshot[Keys.TIMESTAMP] as Timestamp).toDate().year}',
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            _getItemsNames(snapshot[Keys.ORDERED_ITEMS]),
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                        ),
                      ],
                    ),
                    Text(
                      ' \$${snapshot[Keys.DELIVERY_PRICE] + snapshot[Keys.TOTAL_PRICE]}',
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        color: Colors.black,
                      ),
                    ),
                    Row(
                      children: [
                        Text(
                          ' ${snapshot[Keys.ORDER_STATUS]}',
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Constants.GREEN,
                          ),
                        ),
                        Expanded(
                          child: Container(),
                        ),
                        Container(
                          height: 25,
                          child: FlatButton(
                            color: Colors.black12,
                            onPressed: () {
                              Utils.push(
                                context,
                                OrderDetailsScreen(
                                  snapshot.id,
                                ),
                              );
                            },
                            child: Text(
                              'View Details',
                              style: TextStyle(
                                fontFamily: 'Poppins',
                                fontWeight: FontWeight.bold,
                                fontSize: 10,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _getItemsNames(List<Object> itemsList) {
    String itemsNamesString = '';
    for (int i = 0; i < itemsList.length; i++) {
      var j = itemsList[i];
      itemsNamesString =
          '$itemsNamesString${itemsNamesString.isNotEmpty ? ',' : ''} ${(j as Map)[Keys.PRODUCT_TITLE]} ';
    }
    return itemsNamesString;
  }
}
