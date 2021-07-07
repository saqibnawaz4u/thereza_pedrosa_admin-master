import 'package:flutter/material.dart';
import 'package:thereza_pedrosa_admin/others/Utils.dart';
import 'package:thereza_pedrosa_admin/screens/manage_products_screens/add_edit_new_product_screen.dart';
import 'package:thereza_pedrosa_admin/screens/others/products_list.dart';

class AllProductsTab extends StatefulWidget {
  @override
  _AllProductsTabState createState() => _AllProductsTabState();
}

class _AllProductsTabState extends State<AllProductsTab> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: SizedBox(
        width: Utils.getScreenWidth(context) / 9,
        child: FloatingActionButton(
          onPressed: () {
            Utils.push(context, AddEditNewProductScreen(null));
          },
          child: Icon(Icons.add),
        ),
      ),
      body: ProductsList(null, null, null),
    );
  }
}
