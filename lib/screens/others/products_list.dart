import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:thereza_pedrosa_admin/others/Keys.dart';
import 'package:thereza_pedrosa_admin/others/Utils.dart';
import 'package:thereza_pedrosa_admin/screens/manage_products_screens/product_details_screen.dart';

class ProductsList extends StatefulWidget {
  String _artistId, _category;
  bool _isFeatured;

  ProductsList(this._artistId, this._category, this._isFeatured);

  @override
  _ProductsListState createState() => _ProductsListState();
}

class _ProductsListState extends State<ProductsList> {
  List<DocumentSnapshot> _artistWork = [];
  bool _isLoading = true;
  StreamSubscription _subscription;

  @override
  void initState() {
    _subscription = FirebaseFirestore.instance
        .collection('products')
        .where(Keys.ARTIST_ID, isEqualTo: widget._artistId)
        .where(Keys.PRODUCT_CATEGORY, isEqualTo: widget._category)
        .where(Keys.PRODUCT_IS_FEATURED, isEqualTo: widget._isFeatured)
        .snapshots()
        .listen((querySnapshot) {
      _artistWork.clear();
      querySnapshot.docs.forEach((item) {
        _artistWork.add(item);
      });
      setState(() {
        _isLoading = false;
      });
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return _isLoading
        ? Container(
            height: widget._artistId != null ? 300 : double.infinity,
            child: Utils.loadingContainer(),
          )
        : _artistWork.isEmpty
            ? Container(
                height: widget._artistId != null ? 200 : double.infinity,
                child: Utils.errorBody(message: 'No work found'),
              )
            : _getWorkList();
  }

  Widget _getWorkList() {
    return Container(
      height: widget._artistId != null ? 450 : double.infinity,
      child: GridView.builder(
        padding: EdgeInsets.only(left: 16, right: 16, top: 16, bottom: 80),
        gridDelegate:
            SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2),
        itemCount: _artistWork.length,
        itemBuilder: (context, position) => _rowDesign(position),
      ),
    );
  }

  Widget _rowDesign(int position) {
    String title = _artistWork[position][Keys.PRODUCT_TITLE].length > 10
        ? '${_artistWork[position][Keys.PRODUCT_TITLE].substring(0, 9)}...'
        : _artistWork[position][Keys.PRODUCT_TITLE];
    String category = _artistWork[position][Keys.PRODUCT_CATEGORY].length > 10
        ? '${_artistWork[position][Keys.PRODUCT_CATEGORY].substring(0, 9)}...'
        : _artistWork[position][Keys.PRODUCT_CATEGORY];
    return GestureDetector(
      onTap: () {
        Utils.push(context, ProductDetailsScreen(_artistWork[position]));
      },
      child: Container(
        width: Utils.getScreenWidth(context) / 2.75,
        margin: EdgeInsets.all(4),
        child: Card(
          child: Padding(
            padding: EdgeInsets.all(8),
            child: Column(
              children: [
                Container(
                  height: Utils.getScreenWidth(context) / 4.75,
                  width: double.infinity,
                  child: Image.network(
                    _artistWork[position][Keys.PRODUCT_IMAGE_URL_1],
                    fit: BoxFit.cover,
                  ),
                ),
                Text(
                  title,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                Text(
                  category,
                  style: TextStyle(
                    color: Colors.black54,
                    fontSize: 12,
                    fontFamily: 'Poppins',
                  ),
                ),
                Text(
                  '€${_artistWork[position][Keys.PRODUCT_PRICE]}',
                  style: TextStyle(
                    color: Colors.black54,
                    fontSize: 12,
                    fontFamily: 'Poppins',
                  ),
                ),
              ],
            ),
          ),
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
