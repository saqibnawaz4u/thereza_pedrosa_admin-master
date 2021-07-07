import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:thereza_pedrosa_admin/enums/OfferType.dart';
import 'package:thereza_pedrosa_admin/models/offer_model.dart';
import 'package:thereza_pedrosa_admin/others/Keys.dart';
import 'package:thereza_pedrosa_admin/others/Utils.dart';
import 'package:thereza_pedrosa_admin/screens/manage_events_screens/add_edit_event_screen.dart';

class EventsTab extends StatefulWidget {
  @override
  _EventsTabState createState() => _EventsTabState();
}

class _EventsTabState extends State<EventsTab> {
  bool _isLoafing = true;
  StreamSubscription _subscription;
  List<DocumentSnapshot> _eventsList = [];

  @override
  void initState() {
    _subscription =
        FirebaseFirestore.instance.collection('events').snapshots().listen((events) {
      _eventsList.clear();
      events.docs.forEach((event) {
        _eventsList.add(event);
      });
      setState(() {
        _isLoafing = false;
      });
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: SizedBox(
        width: Utils.getScreenWidth(context) / 9,
        child: FloatingActionButton(
          onPressed: () {
            Utils.push(context, AddEditEventScreen(null));
          },
          child: Icon(Icons.add),
        ),
      ),
      body: _isLoafing
          ? Utils.loadingContainer()
          : _eventsList.isEmpty
              ? Utils.errorBody(message: 'No event added')
              : _getBody(),
    );
  }

  Widget _getBody() {
    return ListView.builder(
      padding: EdgeInsets.only(bottom: 80),
      itemCount: _eventsList.length,
      itemBuilder: (context, position) => _rowDesign(position),
    );
  }

  Widget _rowDesign(int position) {
    DocumentSnapshot event = _eventsList[position];
    return GestureDetector(
      onTap: () {
        OfferModel offerModel = OfferModel();
        offerModel.offeredItemSnapshpt = event;
        offerModel.offerType = OfferType.EVENT;
        Navigator.pop(context, offerModel);
      },
      child: Container(
        margin: EdgeInsets.only(top: 8),
        child: Card(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Image.network(
                event[Keys.EVENT_IMAGE_URL],
                width: Utils.getScreenWidth(context),
                height: 200,
                fit: BoxFit.cover,
              ),
              Padding(
                padding: EdgeInsets.only(left: 24, top: 16, bottom: 4),
                child: Text(
                  event[Keys.EVENT_TYPE],
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Poppins',
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.only(left: 24, bottom: 8),
                child: Text(
                  event[Keys.EVENT_HEADLINE],
                  style: TextStyle(
                    fontSize: 17,
                    fontFamily: 'Playfair',
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.only(left: 24, bottom: 8),
                child: Text(
                  'On ${event[Keys.EVENT_DATE]}, at ${event[Keys.EVENT_TIME]} hrs',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}
