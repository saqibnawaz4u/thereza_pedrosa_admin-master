import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:thereza_pedrosa_admin/others/Keys.dart';
import 'package:thereza_pedrosa_admin/others/Utils.dart';
import 'package:thereza_pedrosa_admin/screens/manage_events_screens/event_details_screen.dart';
import 'package:thereza_pedrosa_admin/screens/manage_exhibitions_screens/exhibition_details_screen.dart';
import 'package:thereza_pedrosa_admin/screens/manage_offers_screens/add_edit_offer_screen.dart';
import 'package:thereza_pedrosa_admin/screens/manage_products_screens/product_details_screen.dart';

class OffersListScreen extends StatefulWidget {
  @override
  _OffersListScreenState createState() => _OffersListScreenState();
}

class _OffersListScreenState extends State<OffersListScreen> {
  List<DocumentSnapshot> _offersList = [];
  bool _isLoading = true;
  StreamSubscription _subscription;

  @override
  void initState() {
    _subscription =
        FirebaseFirestore.instance.collection('offers').snapshots().listen((offers) {
      _offersList.clear();
      offers.docs.forEach((offer) {
        _offersList.add(offer);
      });
      setState(() {
        _isLoading = false;
      });
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: Utils.getAppBar(
        context: context,
        title: 'Offers',
        isLeading: false,
        family: 'Playfair',
        leadingObject: null,
      ),
      body: _isLoading
          ? Utils.loadingContainer()
          : _offersList.isEmpty
              ? Utils.errorBody(message: 'No Offer Added')
              : _getBody(),
      floatingActionButton: SizedBox(
        width: Utils.getScreenWidth(context) / 9,
        child: FloatingActionButton(
          onPressed: () {
            Utils.push(context, AddEditOfferScreen(null));
          },
          child: Icon(Icons.add),
        ),
      ),
    );
  }

  Widget _getBody() {
    return ListView(
      padding: EdgeInsets.only(bottom: 80),
      children: _offersList.map((offer) => _rowDesign(offer)).toList(),
    );
  }

  Widget _rowDesign(DocumentSnapshot offer) {
    return Stack(
      children: [
        Container(
          margin: EdgeInsets.only(top: 2),
          height: Utils.getScreenHeight(context) / 4,
          width: Utils.getScreenWidth(context),
          padding: EdgeInsets.all(16),
          decoration: BoxDecoration(
            image: DecorationImage(
              fit: BoxFit.cover,
              image: NetworkImage(
                offer[Keys.OFFER_IMAGE_URL],
              ),
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                offer[Keys.OFFER_TITLE],
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.bold,
                  fontSize: Utils.getScreenHeight(context) / 35,
                  color: Colors.white,
                ),
              ),
              Text(
                offer[Keys.OFFER_TAGLINE],
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: 'Poppins',
                  color: Colors.white,
                ),
              ),
              _getOfferButton(offer),
            ],
          ),
        ),
        Align(
          alignment: Alignment.topRight,
          child: Container(
            margin: EdgeInsets.only(top: 2),
            height: 40,
            width: 40,
            color: Colors.black54,
            alignment: Alignment.center,
            child: IconButton(
              icon: Icon(
                Icons.edit,
                color: Colors.white,
              ),
              onPressed: () {
                Utils.push(context, AddEditOfferScreen(offer));
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _getOfferButton(DocumentSnapshot offer) {
    return Container(
      margin: EdgeInsets.only(
        top: Utils.getScreenHeight(context) / 50,
      ),
      height: Utils.getScreenHeight(context) / 35,
      width: Utils.getScreenWidth(context) / 3,
      child: FlatButton(
        shape: RoundedRectangleBorder(
          side: BorderSide(
            color: Colors.white,
          ),
        ),
        onPressed: () async {
          DocumentSnapshot snpashot;
          Object targetScreen;
          switch (offer[Keys.OFFERED_ITEM_TYPE]) {
            case Keys.EXHIBITION:
              {
                snpashot = await FirebaseFirestore.instance
                    .collection('exhibitions')
                    .doc(offer[Keys.OFFERED_ITEM_ID])
                    .get();
                targetScreen = ExhibitionDetailsScreen(snpashot);
                break;
              }
            case Keys.EVENT:
              {
                snpashot = await FirebaseFirestore.instance
                    .collection('events')
                    .doc(offer[Keys.OFFERED_ITEM_ID])
                    .get();
                targetScreen = EventDetailsScreen(snpashot);
                break;
              }
            case Keys.PRODUCT:
              {
                snpashot = await FirebaseFirestore.instance
                    .collection('products')
                    .doc(offer[Keys.OFFERED_ITEM_ID])
                    .get();
                targetScreen = ProductDetailsScreen(snpashot);
                break;
              }
          }
          Utils.push(context, targetScreen);
        },
        child: Text(
          'Discover More',
          style: TextStyle(
            color: Colors.white,
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
