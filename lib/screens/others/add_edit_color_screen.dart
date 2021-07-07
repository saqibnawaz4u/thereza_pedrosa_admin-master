import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:thereza_pedrosa_admin/contracts/IClick.dart';
import 'package:thereza_pedrosa_admin/contracts/IContinueClicked.dart';
import 'package:thereza_pedrosa_admin/contracts/ITrailingClicked.dart';
import 'package:thereza_pedrosa_admin/others/Constants.dart';
import 'package:thereza_pedrosa_admin/others/Keys.dart';
import 'package:thereza_pedrosa_admin/others/Utils.dart';

class AddEditColorScreen extends StatefulWidget {
  DocumentSnapshot _snapshot;

  AddEditColorScreen(this._snapshot);

  @override
  _AddEditColorScreenState createState() => _AddEditColorScreenState();
}

class _AddEditColorScreenState extends State<AddEditColorScreen>
    implements ITrailingClicked, IClick, IContinueClicked {
  bool _isLoading = false;
  var _colorController = TextEditingController();
  String _docId, _color;

  @override
  void initState() {
    if (widget._snapshot != null) {
      _colorController.text = widget._snapshot[Keys.COLOR];
      _docId = widget._snapshot.id;
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: widget._snapshot == null
          ? Utils.getAppBar(
              context: context,
              title: 'Add Color',
              isLeading: false,
              family: 'Poppins',
              leadingObject: null,
            )
          : Utils.getAppBarWithTrailing(
              context: context,
              title: 'Edit Color',
              isLeading: false,
              leadingObject: null,
              trailingIcon: Icons.delete,
              family: 'Poppins',
              iTrailingClicked: this,
            ),
      body: Stack(
        children: [
          _getForm(),
          _isLoading ? Utils.loadingContainer() : Container(),
        ],
      ),
    );
  }

  Widget _getForm() {
    return Container(
      padding: EdgeInsets.all(24),
      child: SingleChildScrollView(
        child: Column(
          children: [
            Utils.getBorderedTextField(
              type: null,
              controller: _colorController,
              hint: 'Enter color name',
              prefix: null,
              isPassword: false,
              isPhone: false,
              enabled: true,
              maxLines: 1,
              listener: this,
              family: 'Poppins',
            ),
            Utils.getSizedBox(boxHeight: 32, boxWidth: 0),
            Utils.getBorderedButton(
              context,
              widget._snapshot == null ? 'Add' : 'Save Changes',
              'Poppins',
              this,
              Constants.ACCENT_COLOR,
            ),
          ],
        ),
      ),
    );
  }

  @override
  void onTrailingClicked() {
    Utils.showInfoDialog(
      context: context,
      title: 'Warning!',
      message:
          'All products under this color will also be deleted along with this category\nAre you sure you want to continue?',
      iDeleteClicked: this,
    );
  }

  @override
  void onClick() {
    _color = _colorController.text.trim();
    if (_color.isEmpty) {
      Utils.showToast(message: 'Color cannot be empty');
    } else {
      setState(() {
        _isLoading = true;
      });
      if (_docId == null) _getDocId();
      FirebaseFirestore.instance.collection('colors').doc(_docId).set({
        Keys.COLOR: _color,
      }).then((_) async {
        if (widget._snapshot == null) {
          Navigator.pop(context);
        } else {
          _makeChangesToProducts();
        }
      }).catchError((error) {
        setState(() {
          _isLoading = false;
          Utils.showToast(message: error.toString());
        });
      });
    }
  }

  void _makeChangesToProducts() async {
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection('products')
        .where(
          Keys.PRODUCT_COLOR,
          isEqualTo: widget._snapshot[Keys.COLOR],
        )
        .get();
    querySnapshot.docs.forEach((product) {
      FirebaseFirestore.instance
          .collection('products')
          .doc(product.id)
          .set(
        {
          Keys.PRODUCT_COLOR: _color,
        },
        SetOptions(
          merge: true,
        )
      );
    });
    Navigator.pop(context);
  }

  void _getDocId() {
    _docId = FirebaseFirestore.instance.collection('colors').doc().id;
  }

  @override
  void onContinueClicked() async {
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection('products')
        .where(
          Keys.PRODUCT_COLOR,
          isEqualTo: widget._snapshot[Keys.COLOR],
        )
        .get();
    FirebaseFirestore.instance
        .collection('colors')
        .doc(widget._snapshot.id)
        .delete();
    querySnapshot.docs.forEach((product) {
      FirebaseFirestore.instance
          .collection('products')
          .doc(product.id)
          .delete();
      FirebaseStorage.instance
          .ref()
          .child('product_images/${product.id}0.jpg')
          .delete();
      FirebaseStorage.instance
          .ref()
          .child('product_images/${product.id}1.jpg')
          .delete();
      FirebaseStorage.instance
          .ref()
          .child('product_images/${product.id}2.jpg')
          .delete();
    });
    Navigator.pop(context);
  }
}
