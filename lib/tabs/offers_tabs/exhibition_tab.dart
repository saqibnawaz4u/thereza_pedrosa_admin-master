import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:thereza_pedrosa_admin/enums/OfferType.dart';
import 'package:thereza_pedrosa_admin/models/offer_model.dart';
import 'package:thereza_pedrosa_admin/others/Keys.dart';
import 'package:thereza_pedrosa_admin/others/Utils.dart';

class ExhibitionTab extends StatefulWidget {
  @override
  _ExhibitionTabState createState() => _ExhibitionTabState();
}

class _ExhibitionTabState extends State<ExhibitionTab> {
  bool _isLoading = true;
  List<DocumentSnapshot> _exhibitionList = [];
  StreamSubscription _subscription;

  @override
  void initState() {
    _subscription = FirebaseFirestore.instance
        .collection('exhibitions')
        .snapshots()
        .listen((exhibitions) {
      _exhibitionList.clear();
      exhibitions.docs.forEach((exhibition) {
        _exhibitionList.add(exhibition);
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
      body: _isLoading
          ? Utils.loadingContainer()
          : _exhibitionList.isEmpty
              ? Utils.errorBody(message: 'No exhibition found')
              : getBody(),
    );
  }

  Widget getBody() {
    return ListView.builder(
      padding: EdgeInsets.only(bottom: 80),
      itemCount: _exhibitionList.length,
      itemBuilder: (context, position) => _rowDesign(position),
    );
  }

  Widget _rowDesign(int position) {
    DocumentSnapshot exhibition = _exhibitionList[position];
    return GestureDetector(
      onTap: () {
        OfferModel offerModel = OfferModel();
        offerModel.offeredItemSnapshpt = exhibition;
        offerModel.offerType = OfferType.EXHIBITION;
        Navigator.pop(context, offerModel);
      },
      child: Container(
        margin: EdgeInsets.only(top: 8),
        child: Card(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Image.network(
                exhibition[Keys.EXHIBITION_IMAGE_URL],
                width: Utils.getScreenWidth(context),
                height: 200,
                fit: BoxFit.cover,
              ),
              Padding(
                padding: EdgeInsets.only(left: 24, top: 16, bottom: 4),
                child: Text(
                  exhibition[Keys.EXHIBITION_TYPE],
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Poppins',
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.only(left: 24, bottom: 8),
                child: Text(
                  exhibition[Keys.EXHIBITION_HEADLINE],
                  style: TextStyle(
                    fontSize: 17,
                    fontFamily: 'Playfair',
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.only(left: 24, bottom: 8),
                child: Text(
                  'From ${exhibition[Keys.EXHIBITION_START_DATE]} to ${exhibition[Keys.EXHIBITION_START_DATE]}',
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
