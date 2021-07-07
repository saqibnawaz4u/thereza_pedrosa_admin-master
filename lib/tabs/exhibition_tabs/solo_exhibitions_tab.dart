import 'package:flutter/material.dart';
import 'package:thereza_pedrosa_admin/custom_widgets/exhibition_list.dart';
import 'package:thereza_pedrosa_admin/others/Constants.dart';

class SoloExhibitionTab extends StatefulWidget {
  @override
  _SoloExhibitionTabState createState() => _SoloExhibitionTabState();
}

class _SoloExhibitionTabState extends State<SoloExhibitionTab> {
  @override
  Widget build(BuildContext context) {
    return ExhibitionList(Constants.SOLO);
  }
}
