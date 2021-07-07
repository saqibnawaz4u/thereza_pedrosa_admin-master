import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:thereza_pedrosa_admin/contracts/ITextChangedListener.dart';
import 'package:thereza_pedrosa_admin/others/Keys.dart';
import 'package:thereza_pedrosa_admin/others/Utils.dart';
import 'package:thereza_pedrosa_admin/screens/manage_categories_screens/add_edit_categories_screen.dart';
import 'package:thereza_pedrosa_admin/screens/manage_categories_screens/category_products.dart';

class AllCategoriesScreen extends StatefulWidget {
  @override
  _AllCategoriesScreenState createState() => _AllCategoriesScreenState();
}

class _AllCategoriesScreenState extends State<AllCategoriesScreen>
    implements ITextChangedListener {
  bool _isLoading = true;
  List<DocumentSnapshot> _categoriesList = [];
  List<DocumentSnapshot> _filteredList = [];
  var _searchController = TextEditingController();
  StreamSubscription _subscription;

  @override
  void initState() {
    _subscription = FirebaseFirestore.instance
        .collection('categories')
        .snapshots()
        .listen((querySnapshot) {
      _categoriesList.clear();
      _filteredList.clear();
      querySnapshot.docs.forEach((artist) {
        _categoriesList.add(artist);
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
            Utils.push(context, AddEditCategoriesScreen(null));
          },
          child: Icon(Icons.add),
        ),
      ),
      body: _isLoading
          ? Utils.loadingContainer()
          : _categoriesList.isEmpty
              ? Column(
                  children: [
                    Utils.getHeader(
                      context: context,
                      imageString: 'images/categories_thumbnail.png',
                      title: 'CATEGORIES',
                    ),
                    Expanded(
                      child: Utils.errorBody(message: 'No category found'),
                    ),
                  ],
                )
              : Column(
                  children: [
                    Utils.getHeader(
                      context: context,
                      imageString: 'images/categories_thumbnail.png',
                      title: 'CATEGORIES',
                    ),
                    Padding(
                      padding: EdgeInsets.only(
                        left: 24,
                        right: 24,
                      ),
                      child: Utils.getSearchTextField(
                        controller: _searchController,
                        hint: 'Search Category',
                        textListener: this,
                        suffixListener: null,
                        family: 'Poppins',
                      ),
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
      itemCount:
      (_filteredList.isEmpty ? _categoriesList : _filteredList).length,
      itemBuilder: (context, position) {
        return _rowDesign(position);
      },
    );
  }

  Widget _rowDesign(int position) {
    var artistSnapshot = _filteredList.isEmpty
        ? _categoriesList[position]
        : _filteredList[position];
    return GestureDetector(
      onTap: () {
        Utils.push(
          context,
          CategoryProducts(
            _categoriesList[position],
          ),
        );
      },
      child: Container(
        color: Colors.transparent,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              artistSnapshot[Keys.CATEGORY],
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
  void onTextChanged(String value) {
    _filteredList.clear();
    _categoriesList.forEach((artist) {
      if (artist[Keys.CATEGORY].toLowerCase().contains(value.toLowerCase())) {
        _filteredList.add(artist);
      }
    });
    setState(() {});
  }

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}
