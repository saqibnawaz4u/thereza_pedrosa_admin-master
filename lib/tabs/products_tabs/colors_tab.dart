import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:thereza_pedrosa_admin/others/Keys.dart';
import 'package:thereza_pedrosa_admin/others/Utils.dart';
import 'package:thereza_pedrosa_admin/screens/others/add_edit_color_screen.dart';

class ColorsTab extends StatefulWidget {
  @override
  _ColorsTabState createState() => _ColorsTabState();
}

class _ColorsTabState extends State<ColorsTab> {
  bool _isLoading = true;
  List<DocumentSnapshot> _colorsList = [];
  StreamSubscription _subscription;

  @override
  void initState() {
    _subscription = FirebaseFirestore.instance
        .collection('colors')
        .snapshots()
        .listen((querySnapshot) {
      _colorsList.clear();
      querySnapshot.docs.forEach((artist) {
        _colorsList.add(artist);
      });
      setState(() {
        _isLoading = false;
      });
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: SizedBox(
        width: Utils.getScreenWidth(context) / 9,
        child: FloatingActionButton(
          onPressed: () {
            Utils.push(context, AddEditColorScreen(null));
          },
          child: Icon(Icons.add),
        ),
      ),
      body: _isLoading
          ? Utils.loadingContainer()
          : _colorsList.isEmpty
              ? Utils.errorBody(message: 'No color found')
              : Column(
                  children: [
                    Utils.getHeader(
                      context: context,
                      imageString: 'images/artists_thumbnail.png',
                      title: 'COLORS',
                    ),
                    Expanded(
                      child: _getList(),
                    ),
                  ],
                ),
    );
  }

  Widget _getList() {
    return ListView.builder(
      padding: EdgeInsets.only(left: 24, right: 24, top: 16, bottom: 80),
      itemCount: _colorsList.length,
      itemBuilder: (context, position) {
        return _rowDesign(position);
      },
    );
  }

  Widget _rowDesign(int position) {
    var colorSnapshot = _colorsList[position];
    return GestureDetector(
      onTap: () {
        Utils.push(context, AddEditColorScreen(colorSnapshot));
      },
      child: Container(
        color: Colors.transparent,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              colorSnapshot[Keys.COLOR],
              style: TextStyle(
                fontSize: 19,
                color: Colors.black54,
                fontFamily: 'Poppins',
              ),
            ),
            Utils.getDivider(),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}
