import 'package:flutter/material.dart';
import 'package:thereza_pedrosa_admin/others/Utils.dart';
import 'package:thereza_pedrosa_admin/screens/manage_exhibitions_screens/add_edit_exhibition_screen.dart';
import 'package:thereza_pedrosa_admin/tabs/exhibition_tabs/all_exhibitions_tab.dart';
import 'package:thereza_pedrosa_admin/tabs/exhibition_tabs/art_fair_tab.dart';
import 'package:thereza_pedrosa_admin/tabs/exhibition_tabs/collective_exhibition_tab.dart';
import 'package:thereza_pedrosa_admin/tabs/exhibition_tabs/solo_exhibitions_tab.dart';

class ExhibitionScreen extends StatefulWidget {
  @override
  _ExhibitionScreenState createState() => _ExhibitionScreenState();
}

class _ExhibitionScreenState extends State<ExhibitionScreen> {
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 4,
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            'Exhibitions',
          ),
          bottom: TabBar(
            labelStyle: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 13,
              fontWeight: FontWeight.bold,
            ),
            tabs: [
              Tab(
                text: 'All',
              ),
              Tab(
                text: 'Solo',
              ),
              Tab(
                text: 'Collective',
              ),
              Tab(
                text: 'Art Fair',
              ),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            AllExhibitionsTab(),
            SoloExhibitionTab(),
            CollectiveExhibitionTab(),
            ArtFairTab(),
          ],
        ),
        floatingActionButton: SizedBox(
          width: Utils.getScreenWidth(context) / 9,
          child: FloatingActionButton(
            onPressed: () {
              Utils.push(context, AddEditExhibitionScreen(null));
            },
            child: Icon(Icons.add),
          ),
        ),
      ),
    );
  }
}
