import 'package:flutter/material.dart';
import 'package:thereza_pedrosa_admin/screens/others/products_list.dart';

class FeaturedProductsTab extends StatefulWidget {
  @override
  _FeaturedProductsTabState createState() => _FeaturedProductsTabState();
}

class _FeaturedProductsTabState extends State<FeaturedProductsTab> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ProductsList(null,null, true),
    );
  }
}
