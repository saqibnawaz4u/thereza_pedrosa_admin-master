import 'package:flutter/material.dart';
import 'package:thereza_pedrosa_admin/others/Utils.dart';

class Header extends StatefulWidget {
  String _title;

  Header(this._title);

  @override
  _HeaderState createState() => _HeaderState();
}

class _HeaderState extends State<Header> {
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          Icons.vpn_key,
          color: Colors.white,
          size: 40,
        ),
        Utils.getSizedBox(
          boxHeight: 0,
          boxWidth: 16,
        ),
        Text(
          widget._title,
          style: TextStyle(
            fontSize: 32,
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}
