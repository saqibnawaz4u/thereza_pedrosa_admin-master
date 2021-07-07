import 'package:flutter/material.dart';
import 'package:thereza_pedrosa_admin/tabs/offers_tabs/events_tab.dart';
import 'package:thereza_pedrosa_admin/tabs/offers_tabs/exhibition_tab.dart';
import 'package:thereza_pedrosa_admin/tabs/offers_tabs/items_tab.dart';

class ExhibitionsEventsItemsScreenMain extends StatefulWidget {
  @override
  _ExhibitionsEventsItemsScreenMainState createState() =>
      _ExhibitionsEventsItemsScreenMainState();
}

class _ExhibitionsEventsItemsScreenMainState
    extends State<ExhibitionsEventsItemsScreenMain> {
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: Text('Select Item'),
          bottom: TabBar(
            tabs: [
              Tab(
                child: Text('Product'),
              ),
              Tab(
                child: Text('Exhibitions'),
              ),
              Tab(
                child: Text('Events'),
              ),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            ItemTab(),
            ExhibitionTab(),
            EventsTab(),
          ],
        ),
      ),
    );
  }
}
