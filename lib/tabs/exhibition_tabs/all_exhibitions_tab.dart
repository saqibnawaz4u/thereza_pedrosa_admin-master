import 'package:flutter/material.dart';
import 'package:thereza_pedrosa_admin/custom_widgets/exhibition_list.dart';

class AllExhibitionsTab extends StatefulWidget {
  @override
  _AllExhibitionsTabState createState() => _AllExhibitionsTabState();
}

class _AllExhibitionsTabState extends State<AllExhibitionsTab> {
  @override
  Widget build(BuildContext context) {
    return ExhibitionList(null);
  }
}
