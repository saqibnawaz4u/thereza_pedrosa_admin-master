import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:thereza_pedrosa_admin/enums/OfferType.dart';

class OfferModel {
  OfferType _offerType;
  DocumentSnapshot _offeredItemSnapshpt;

  DocumentSnapshot get offeredItemSnapshpt => _offeredItemSnapshpt;

  set offeredItemSnapshpt(DocumentSnapshot value) {
    _offeredItemSnapshpt = value;
  }

  OfferType get offerType => _offerType;

  set offerType(OfferType value) {
    _offerType = value;
  }
}
