import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:thereza_pedrosa_admin/contracts/ITrailingClicked.dart';
import 'package:thereza_pedrosa_admin/others/Keys.dart';
import 'package:thereza_pedrosa_admin/others/Utils.dart';
import 'package:thereza_pedrosa_admin/screens/manage_categories_screens/add_edit_categories_screen.dart';
import 'package:thereza_pedrosa_admin/screens/others/products_list.dart';

class CategoryProducts extends StatefulWidget {
  DocumentSnapshot _snapshot;

  CategoryProducts(this._snapshot);

  @override
  _CategoryProductsState createState() => _CategoryProductsState();
}

class _CategoryProductsState extends State<CategoryProducts>
    implements ITrailingClicked {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: Utils.getAppBarWithTrailing(
        context: context,
        title: widget._snapshot[Keys.CATEGORY],
        isLeading: false,
        family: null,
        leadingObject: null,
        trailingIcon: Icons.edit,
        iTrailingClicked: this,
      ),
      body: ProductsList(null, widget._snapshot[Keys.CATEGORY], null),
    );
  }

  @override
  void onTrailingClicked() {
    Utils.push(context, AddEditCategoriesScreen(widget._snapshot));
  }
}
