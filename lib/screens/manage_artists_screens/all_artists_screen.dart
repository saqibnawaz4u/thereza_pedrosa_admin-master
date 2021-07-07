import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:thereza_pedrosa_admin/contracts/ITextChangedListener.dart';
import 'package:thereza_pedrosa_admin/others/Keys.dart';
import 'package:thereza_pedrosa_admin/others/Utils.dart';
import 'package:thereza_pedrosa_admin/screens/manage_artists_screens/add_edit_artist_screen.dart';
import 'package:thereza_pedrosa_admin/screens/manage_artists_screens/artist_details_screen.dart';

class AllArtistsScreen extends StatefulWidget {
  @override
  _AllArtistsScreenState createState() => _AllArtistsScreenState();
}

class _AllArtistsScreenState extends State<AllArtistsScreen>
    implements ITextChangedListener {
  bool _isLoading = true;
  List<DocumentSnapshot> _artistsList = [];
  List<DocumentSnapshot> _filteredList = [];
  var _searchController = TextEditingController();
  StreamSubscription _subscription;

  @override
  void initState() {
    _subscription = FirebaseFirestore.instance
        .collection('artists')
        .snapshots()
        .listen((querySnapshot) {
      _artistsList.clear();
      _filteredList.clear();
      querySnapshot.docs.forEach((artist) {
        _artistsList.add(artist);
      });
      _artistsList
          .sort((a, b) => a[Keys.ARTIST_NAME].compareTo(b[Keys.ARTIST_NAME]));
      setState(() {
        _isLoading = false;
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
            Utils.push(context, AddEditArtistScreen(null));
          },
          child: Icon(Icons.add),
        ),
      ),
      body: _isLoading
          ? Utils.loadingContainer()
          : _artistsList.isEmpty
              ? Column(
                  children: [
                    Utils.getHeader(
                      context: context,
                      imageString: 'images/artists_thumbnail.png',
                      title: 'ARTISTS',
                    ),
                    Expanded(
                      child: Utils.errorBody(message: 'No artist found'),
                    ),
                  ],
                )
              : Column(
                  children: [
                    Utils.getHeader(
                      context: context,
                      imageString: 'images/artists_thumbnail.png',
                      title: 'ARTISTS',
                    ),
                    Padding(
                      padding: EdgeInsets.only(
                        left: 24,
                        right: 24,
                      ),
                      child: Utils.getSearchTextField(
                        controller: _searchController,
                        hint: 'Search Artist',
                        textListener: this,
                        suffixListener: null,
                        family: 'Poppins',
                      ),
                    ),
                    Expanded(
                      child: _getList(),
                    ),
                  ],
                ),
    );
  }

  Widget _getList() {
    return ListView.builder(
      padding: EdgeInsets.only(left: 24, right: 24, top: 16, bottom: 80),
      itemCount: (_filteredList.isEmpty ? _artistsList : _filteredList).length,
      itemBuilder: (context, position) {
        return _rowDesign(position);
      },
    );
  }

  Widget _rowDesign(int position) {
    var artistSnapshot = _filteredList.isEmpty
        ? _artistsList[position]
        : _filteredList[position];
    return GestureDetector(
      onTap: () {
        Utils.push(context, ArtistDetailsScreen(artistSnapshot));
      },
      child: Container(
        color: Colors.transparent,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              artistSnapshot[Keys.ARTIST_NAME],
              style: TextStyle(
                fontSize: 19,
                color: Colors.black54,
                fontFamily: 'Poppins',
              ),
            ),
            Utils.getDivider(),
          ],
        ),
      ),
    );
  }

  @override
  void onTextChanged(String value) {
    _filteredList.clear();
    _artistsList.forEach((artist) {
      if (artist[Keys.ARTIST_NAME]
          .toLowerCase()
          .contains(value.toLowerCase())) {
        _filteredList.add(artist);
      }
    });
    setState(() {});
  }

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}
