import 'package:flutter/material.dart';
import 'package:thereza_pedrosa_admin/tabs/products_tabs/all_products_tab.dart';
import 'package:thereza_pedrosa_admin/tabs/products_tabs/colors_tab.dart';
import 'package:thereza_pedrosa_admin/tabs/products_tabs/featured_products_tab.dart';

class ProductsScreen extends StatefulWidget {
  @override
  _ProductsScreenState createState() => _ProductsScreenState();
}

class _ProductsScreenState extends State<ProductsScreen> {
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: Text('Manage Products'),
          bottom: TabBar(
            labelStyle: TextStyle(
              fontFamily: 'Poppins',
              fontWeight: FontWeight.bold,
            ),
            tabs: [
              Tab(
                text: 'All',
              ),
              Tab(
                text: 'Featured',
              ),
              Tab(
                text: 'Colors',
              ),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            AllProductsTab(),
            FeaturedProductsTab(),
            ColorsTab(),
          ],
        ),
      ),
    );
  }
}
