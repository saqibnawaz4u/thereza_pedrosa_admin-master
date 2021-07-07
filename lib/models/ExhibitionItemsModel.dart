import 'package:cloud_firestore/cloud_firestore.dart';

class ExhibitionItemsModel {
  String _itemId;
  DocumentSnapshot _snapshot;

  String get itemId => _itemId;

  set itemId(String value) {
    _itemId = value;
  }

  DocumentSnapshot get snapshot => _snapshot;

  set snapshot(DocumentSnapshot value) {
    _snapshot = value;
  }
}
