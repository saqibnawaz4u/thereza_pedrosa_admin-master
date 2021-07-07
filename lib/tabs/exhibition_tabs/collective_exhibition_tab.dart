import 'package:flutter/material.dart';
import 'package:thereza_pedrosa_admin/custom_widgets/exhibition_list.dart';
import 'package:thereza_pedrosa_admin/others/Constants.dart';

class CollectiveExhibitionTab extends StatefulWidget {
  @override
  _CollectiveExhibitionTabState createState() => _CollectiveExhibitionTabState();
}

class _CollectiveExhibitionTabState extends State<CollectiveExhibitionTab> {
  @override
  Widget build(BuildContext context) {
    return ExhibitionList(Constants.COLLECTIVE);
  }
}
