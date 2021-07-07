import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:thereza_pedrosa_admin/contracts/IClick.dart';
import 'package:thereza_pedrosa_admin/contracts/IContinueClicked.dart';
import 'package:thereza_pedrosa_admin/contracts/ITrailingClicked.dart';
import 'package:thereza_pedrosa_admin/others/Constants.dart';
import 'package:thereza_pedrosa_admin/others/Keys.dart';
import 'package:thereza_pedrosa_admin/others/Utils.dart';

class AddEditCategoriesScreen extends StatefulWidget {
  DocumentSnapshot _snapshot;

  AddEditCategoriesScreen(this._snapshot);

  @override
  _AddEditCategoriesScreenState createState() =>
      _AddEditCategoriesScreenState();
}

class _AddEditCategoriesScreenState extends State<AddEditCategoriesScreen>
    implements ITrailingClicked, IClick, IContinueClicked {
  bool _isLoading = false;
  var _categoryController = TextEditingController();
  String _docuId, _category;

  @override
  void initState() {
    if (widget._snapshot != null) {
      _categoryController.text = widget._snapshot[Keys.CATEGORY];
      _docuId = widget._snapshot.id;
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
              title: 'Add Category',
              isLeading: false,
              family: 'Poppins',
              leadingObject: null,
            )
          : Utils.getAppBarWithTrailing(
              context: context,
              title: 'Edit Category',
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
              controller: _categoryController,
              hint: 'Enter Category',
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
          'All products under this category will also be deleted along with this category\nAre you sure you want to continue?',
      iDeleteClicked: this,
    );
  }

  @override
  void onClick() {
    _category = _categoryController.text.trim();
    if (_category.isEmpty) {
      Utils.showToast(message: 'Category cannot be empty');
    } else {
      setState(() {
        _isLoading = true;
      });
      if (_docuId == null) _getDocId();
      FirebaseFirestore.instance.collection('categories').doc(_docuId).set({
        Keys.CATEGORY: _category,
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
          Keys.PRODUCT_CATEGORY,
          isEqualTo: widget._snapshot[Keys.CATEGORY],
        )
        .get();
    querySnapshot.docs.forEach((product) {
      FirebaseFirestore.instance
          .collection('products')
          .doc(product.id)
          .set(
        {
          Keys.PRODUCT_CATEGORY: _category,
        },
        SetOptions(
          merge: true,
        )
      );
    });
    Navigator.pop(context);
    Navigator.pop(context);
  }

  void _getDocId() {
    _docuId = FirebaseFirestore.instance.collection('categories').doc().id;
  }

  @override
  void onContinueClicked() async {
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection('products')
        .where(Keys.PRODUCT_CATEGORY,
            isEqualTo: widget._snapshot[Keys.CATEGORY])
        .get();
    FirebaseFirestore.instance
        .collection('categories')
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
    Navigator.pop(context);
  }
}
