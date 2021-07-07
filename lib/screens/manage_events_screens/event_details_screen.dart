import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:expandable/expandable.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:share/share.dart';
import 'package:thereza_pedrosa_admin/contracts/ITrailingClicked.dart';
import 'package:thereza_pedrosa_admin/others/Keys.dart';
import 'package:thereza_pedrosa_admin/others/Utils.dart';
import 'package:thereza_pedrosa_admin/screens/manage_events_screens/add_edit_event_screen.dart';

class EventDetailsScreen extends StatefulWidget {
  DocumentSnapshot _snapshot;

  EventDetailsScreen(this._snapshot);

  @override
  _EventDetailsScreenState createState() => _EventDetailsScreenState();
}

class _EventDetailsScreenState extends State<EventDetailsScreen>
    implements ITrailingClicked {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: Utils.getAppBarWithTrailing(
        context: context,
        title: 'Event Details',
        isLeading: false,
        leadingObject: null,
        trailingIcon: Icons.edit,
        family: 'Playfair',
        iTrailingClicked: this,
      ),
      body: _getBody(),
    );
  }

  Widget _getBody() {
    return ListView(
      children: [
        Image.network(
          widget._snapshot[Keys.EVENT_IMAGE_URL],
          width: Utils.getScreenWidth(context),
          height: 250,
          fit: BoxFit.cover,
        ),
        Padding(
          padding: EdgeInsets.only(left: 16, top: 16, bottom: 8, right: 16),
          child: Text(
            'On ${widget._snapshot[Keys.EVENT_DATE]}, at ${widget._snapshot[Keys.EVENT_TIME]} hrs',
            style: TextStyle(
              fontFamily: 'Poppins',
              fontWeight: FontWeight.bold,
              fontSize: 15,
              color: Colors.black54,
            ),
          ),
        ),
        Padding(
          padding: EdgeInsets.only(left: 16, right: 16),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  widget._snapshot[Keys.EVENT_HEADLINE],
                  style: TextStyle(
                    fontSize: 19,
                    color: Colors.black,
                  ),
                ),
              ),
              IconButton(
                icon: Icon(Icons.share),
                onPressed: () {
                  Share.share(
                      '${widget._snapshot[Keys.EVENT_IMAGE_URL]}\n\n*${widget._snapshot[Keys.EVENT_HEADLINE]}*\n${widget._snapshot[Keys.EVENT_DETAILS]}\n*On ${widget._snapshot[Keys.EVENT_DATE]}, at ${widget._snapshot[Keys.EVENT_TIME]}*');
                },
              ),
            ],
          ),
        ),
        _getDetailsSection(),
      ],
    );
  }

  Widget _getDetailsSection() {
    return Padding(
      padding: EdgeInsets.only(left: 16, bottom: 8, right: 16, top: 8),
      child: ExpandablePanel(
        header: Center(
          child: Text(
            'Exhibition Details',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 17,
            ),
          ),
        ),
        collapsed: Text(
          widget._snapshot[Keys.EVENT_DETAILS],
          softWrap: true,
          maxLines: 3,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontFamily: 'Poppins',
          ),
        ),
        expanded: Text(
          widget._snapshot[Keys.EVENT_DETAILS],
          softWrap: true,
          style: TextStyle(
            fontFamily: 'Poppins',
          ),
        ),
      ),
    );
  }

  @override
  void onTrailingClicked() {
    Utils.push(context, AddEditEventScreen(widget._snapshot));
  }
}
