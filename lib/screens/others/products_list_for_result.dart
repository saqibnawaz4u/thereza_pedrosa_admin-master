import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:thereza_pedrosa_admin/contracts/ITextChangedListener.dart';
import 'package:thereza_pedrosa_admin/enums/OfferType.dart';
import 'package:thereza_pedrosa_admin/models/offer_model.dart';
import 'package:thereza_pedrosa_admin/others/Keys.dart';
import 'package:thereza_pedrosa_admin/others/Utils.dart';

class ProductsListForResult extends StatefulWidget {
  @override
  _ProductsListForResultState createState() => _ProductsListForResultState();
}

class _ProductsListForResultState extends State<ProductsListForResult>
    implements ITextChangedListener {
  List<DocumentSnapshot> _productsList = [];
  List<DocumentSnapshot> _filteredList = [];
  bool _isLoading = true;
  StreamSubscription _subscription;
  var _searchController = TextEditingController();

  @override
  void initState() {
    _subscription = FirebaseFirestore.instance
        .collection('products')
        .snapshots()
        .listen((querySnapshot) {
      _productsList.clear();
      querySnapshot.docs.forEach((item) {
        _productsList.add(item);
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
      body: _isLoading
          ? Utils.loadingContainer()
          : _productsList.isEmpty
              ? Utils.errorBody(message: 'No work found')
              : Column(
                  children: [
                    Padding(
                      padding: EdgeInsets.only(left: 16, right: 16, top: 16),
                      child: Utils.getSearchTextField(
                        controller: _searchController,
                        hint: 'Search Product',
                        textListener: this,
                        suffixListener: null,
                        family: 'Poppins',
                      ),
                    ),
                    Expanded(
                      child: _getProductsGrid(),
                    ),
                  ],
                ),
    );
  }

  Widget _getProductsGrid() {
    return GridView.builder(
      padding: EdgeInsets.only(left: 16, right: 16, top: 16, bottom: 80),
      gridDelegate:
          SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2),
      itemCount:
          _filteredList.isEmpty ? _productsList.length : _filteredList.length,
      itemBuilder: (context, position) => _rowDesign(
        _filteredList.isEmpty
            ? _productsList[position]
            : _filteredList[position],
      ),
    );
  }

  Widget _rowDesign(DocumentSnapshot product) {
    String title = product[Keys.PRODUCT_TITLE].length > 10
        ? '${product[Keys.PRODUCT_TITLE].substring(0, 9)}...'
        : product[Keys.PRODUCT_TITLE];
    String category = product[Keys.PRODUCT_CATEGORY].length > 10
        ? '${product[Keys.PRODUCT_CATEGORY].substring(0, 9)}...'
        : product[Keys.PRODUCT_CATEGORY];
    return GestureDetector(
      onTap: () {
        OfferModel offerModel = OfferModel();
        offerModel.offeredItemSnapshpt = product;
        offerModel.offerType = OfferType.PRODUCT;
        Navigator.pop(context, offerModel);
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
                  height: Utils.getScreenWidth(context) / 4.25,
                  width: double.infinity,
                  child: Image.network(
                    product[Keys.PRODUCT_IMAGE_URL_1],
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
                  '\$${product[Keys.PRODUCT_PRICE]}',
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

  @override
  void onTextChanged(String value) {
    _filteredList.clear();
    _productsList.forEach((product) {
      if (product[Keys.PRODUCT_TITLE]
          .toString()
          .toLowerCase()
          .contains(value.toLowerCase())) {
        _filteredList.add(product);
      }
    });
    setState(() {});
  }
}
