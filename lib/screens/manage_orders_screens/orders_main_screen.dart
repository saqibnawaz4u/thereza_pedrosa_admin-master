import 'package:flutter/material.dart';
import 'package:thereza_pedrosa_admin/others/Constants.dart';
import 'package:thereza_pedrosa_admin/others/Utils.dart';

import 'completed_orders_screen.dart';
import 'current_orders_screen.dart';

class OrdersMainScreen extends StatefulWidget {
  @override
  _OrdersMainScreenState createState() => _OrdersMainScreenState();
}

class _OrdersMainScreenState extends State<OrdersMainScreen> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: Utils.getAppBar(
        family: 'Playfair',
        context: context,
        title: _selectedIndex == 0 ? 'Current Orders' : 'Completed Orders',
        isLeading: false,
        leadingObject: null,
      ),
      body: _getBody(),
    );
  }

  Widget _getBody() {
    return Container(
      padding: EdgeInsets.all(24),
      child: Column(
        children: [
          Row(
            children: [
              _getCustomTab(0, 'Running'),
              Utils.getSizedBox(boxHeight: 0, boxWidth: 8),
              _getCustomTab(1, 'Completed'),
            ],
          ),
          Expanded(
            child: _selectedIndex == 0
                ? CurrentOrdersScreen()
                : CompletedOrdersScreen(),
          ),
        ],
      ),
    );
  }

  Widget _getCustomTab(int index, String label) {
    return GestureDetector(
      onTap: () {
        if (index == 0) {
          _selectedIndex = 0;
        } else {
          _selectedIndex = 1;
        }
        setState(() {});
      },
      child: Container(
        height: 25,
        width: Utils.getScreenWidth(context) / 3.5,
        color: index == _selectedIndex ? Constants.DEEP_BLUE : Colors.black26,
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              color: index == _selectedIndex ? Colors.white : Colors.black,
              fontFamily: 'Poppins',
              fontSize: 12,
            ),
          ),
        ),
      ),
    );
  }
}
