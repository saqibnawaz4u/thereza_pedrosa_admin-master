import 'package:flutter/material.dart';
import 'package:thereza_pedrosa_admin/custom_widgets/exhibition_list.dart';
import 'package:thereza_pedrosa_admin/others/Constants.dart';

class ArtFairTab extends StatefulWidget {
  @override
  _ArtFairTabState createState() => _ArtFairTabState();
}

class _ArtFairTabState extends State<ArtFairTab> {
  @override
  Widget build(BuildContext context) {
    return ExhibitionList(Constants.ART_FAIR);
  }
}
