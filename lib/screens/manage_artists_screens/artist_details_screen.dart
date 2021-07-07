import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:expandable/expandable.dart';
import 'package:flutter/material.dart';
import 'package:share/share.dart';
import 'package:thereza_pedrosa_admin/contracts/ITrailingClicked.dart';
import 'package:thereza_pedrosa_admin/others/Keys.dart';
import 'package:thereza_pedrosa_admin/others/Utils.dart';
import 'package:thereza_pedrosa_admin/screens/manage_artists_screens/add_edit_artist_screen.dart';

import '../others/products_list.dart';

class ArtistDetailsScreen extends StatefulWidget {
  DocumentSnapshot _snapshot;

  ArtistDetailsScreen(this._snapshot);

  @override
  _ArtistDetailsScreenState createState() => _ArtistDetailsScreenState();
}

class _ArtistDetailsScreenState extends State<ArtistDetailsScreen>
    implements ITrailingClicked {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: Utils.getAppBarWithTrailing(
        context: context,
        title: 'Artist Profile',
        isLeading: false,
        leadingObject: null,
        trailingIcon: Icons.share,
        iTrailingClicked: this,
        family: 'Playfair',
      ),
      body: _getBody(),
    );
  }

  Widget _getBody() {
    return Container(
      color: Colors.white,
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _getImageSection(),
            Padding(
              padding: EdgeInsets.only(left: 16, right: 16),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      widget._snapshot[Keys.ARTIST_NAME],
                      style: TextStyle(
                        fontSize: 19,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: Icon(
                      Icons.edit,
                      size: 20,
                    ),
                    onPressed: () {
                      Utils.push(
                          context, AddEditArtistScreen(widget._snapshot));
                    },
                  ),
                ],
              ),
            ),
            Padding(
              padding: EdgeInsets.only(left: 16, bottom: 16),
              child: Text(
                widget._snapshot[Keys.ARTIST_ORIGIN],
              ),
            ),
            _getDescriptionSection(),
            Padding(
              padding: EdgeInsets.only(left: 16, top: 16),
              child: Text(
                'Works',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                ),
              ),
            ),
            ProductsList(
              widget._snapshot.id,
              null,
              null,
            ),
          ],
        ),
      ),
    );
  }

  Widget _getDescriptionSection() {
    return Padding(
      padding: EdgeInsets.only(left: 16, bottom: 16, right: 16),
      child: ExpandablePanel(
        header: Center(
          child: Text(
            'Biography',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 17,
            ),
          ),
        ),
        collapsed: Text(
          widget._snapshot[Keys.ARTIST_DESCRIPTION],
          softWrap: true,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontFamily: 'Poppins',
          ),
        ),
        expanded: Text(
          widget._snapshot[Keys.ARTIST_DESCRIPTION],
          softWrap: true,
          style: TextStyle(
            fontFamily: 'Poppins',
          ),
        ),
      ),
    );
  }

  Widget _getImageSection() {
    return Image.network(
      widget._snapshot[Keys.ARTIST_IMAGE_URL],
      width: Utils.getScreenWidth(context),
      height: 200,
      fit: BoxFit.cover,
    );
  }

  @override
  void onTrailingClicked() {
    Share.share(
        '${widget._snapshot[Keys.ARTIST_IMAGE_URL]}\n\n*${widget._snapshot[Keys.ARTIST_NAME]}*\n${widget._snapshot[Keys.ARTIST_DESCRIPTION]}');
  }
}
