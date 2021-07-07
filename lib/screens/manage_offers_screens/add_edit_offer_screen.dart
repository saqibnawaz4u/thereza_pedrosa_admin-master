import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:thereza_pedrosa_admin/contracts/IClick.dart';
import 'package:thereza_pedrosa_admin/contracts/IContinueClicked.dart';
import 'package:thereza_pedrosa_admin/contracts/ITextFieldClicked.dart';
import 'package:thereza_pedrosa_admin/contracts/ITrailingClicked.dart';
import 'package:thereza_pedrosa_admin/enums/FieldClickType.dart';
import 'package:thereza_pedrosa_admin/enums/OfferType.dart';
import 'package:thereza_pedrosa_admin/models/offer_model.dart';
import 'package:thereza_pedrosa_admin/others/Constants.dart';
import 'package:thereza_pedrosa_admin/others/Keys.dart';
import 'package:thereza_pedrosa_admin/others/Utils.dart';
import 'package:thereza_pedrosa_admin/screens/manage_offers_screens/exhibitions_events_items_screen_main.dart';

class AddEditOfferScreen extends StatefulWidget {
  DocumentSnapshot _snapshot;

  AddEditOfferScreen(this._snapshot);

  @override
  _AddEditOfferScreenState createState() => _AddEditOfferScreenState();
}

class _AddEditOfferScreenState extends State<AddEditOfferScreen>
    implements IClick, ITrailingClicked, IContinueClicked, ITextFieldClicked {
  var _titleController = TextEditingController();
  var _taglineController = TextEditingController();
  String _imageUrl, _title, _tagline, _offerDocId, _itemType;
  OfferType _offerType;
  String _selectedProductId, _selectedProductTitle;
  bool _isLoading = false;
  PickedFile _pickedFile;

  @override
  void initState() {
    if (widget._snapshot != null) {
      _titleController.text = widget._snapshot[Keys.OFFER_TITLE];
      _taglineController.text = widget._snapshot[Keys.OFFER_TAGLINE].toString();
      _offerDocId = widget._snapshot.id;
      _imageUrl = widget._snapshot[Keys.OFFER_IMAGE_URL];
      _getProduct();
    }
    super.initState();
  }

  Future<void> _getProduct() async {
    DocumentSnapshot product = await FirebaseFirestore.instance
        .collection('products')
        .doc(widget._snapshot[Keys.OFFERED_ITEM_ID])
        .get();
    setState(() {
      _selectedProductId = product.id;
      _selectedProductTitle = product[Keys.PRODUCT_TITLE];
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: widget._snapshot != null
          ? Utils.getAppBarWithTrailing(
              context: context,
              title: 'Edit Offer',
              isLeading: false,
              trailingIcon: Icons.delete,
              iTrailingClicked: this,
              leadingObject: null,
              family: 'Poppins',
            )
          : Utils.getAppBar(
              context: context,
              title: 'Add Offer',
              isLeading: false,
              leadingObject: null,
              family: 'Poppins',
            ),
      body: _getBody(),
    );
  }

  Widget _getBody() {
    return Stack(
      children: [
        Container(
          child: Column(
            children: [
              _getImageSection(),
              _getFormSection(),
            ],
          ),
        ),
        _isLoading ? Utils.loadingContainer() : Container(),
      ],
    );
  }

  Widget _getFormSection() {
    return Expanded(
      child: ListView(
        padding: EdgeInsets.only(
          left: 24,
          right: 24,
          top: 24,
          bottom: 60,
        ),
        children: [
          Utils.getBorderedTextField(
            type: null,
            controller: _titleController,
            hint: 'Offer title',
            prefix: null,
            isPassword: false,
            isPhone: false,
            enabled: true,
            maxLines: 1,
            listener: null,
            family: 'Poppins',
          ),
          Utils.getSizedBox(boxHeight: 12, boxWidth: 0),
          Utils.getBorderedTextField(
            type: null,
            controller: _taglineController,
            hint: 'Offer tagline',
            prefix: null,
            isPassword: false,
            isPhone: false,
            enabled: true,
            maxLines: 1,
            listener: null,
            family: 'Poppins',
          ),
          Utils.getSizedBox(boxHeight: 12, boxWidth: 0),
          Utils.getBorderedText(
            context: context,
            label: _selectedProductId == null
                ? 'Select Offer Item'
                : _selectedProductTitle,
            type: FieldClickType.PRODUCT_SELECTION,
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
    );
  }

  Widget _getImageSection() {
    return GestureDetector(
      onTap: () async {
        var file = await ImagePicker().getImage(
          source: ImageSource.gallery,
          imageQuality: 20,
        );
        if (file != null) {
          setState(() {
            _pickedFile = file;
          });
        }
      },
      child: _pickedFile != null
          ? Image.file(
              File(_pickedFile.path),
              width: Utils.getScreenWidth(context),
              height: 200,
              fit: BoxFit.cover,
            )
          : _imageUrl != null
              ? Image.network(
                  _imageUrl,
                  width: Utils.getScreenWidth(context),
                  height: 200,
                  fit: BoxFit.cover,
                )
              : Image.asset(
                  'images/img_camera.png',
                  width: Utils.getScreenWidth(context),
                  height: 200,
                  fit: BoxFit.cover,
                ),
    );
  }

  void _saveToFirestore() {
    FirebaseFirestore.instance.collection('offers').doc(_offerDocId).set({
      Keys.OFFER_TITLE: _title,
      Keys.OFFER_TAGLINE: _tagline,
      Keys.OFFER_IMAGE_URL: _imageUrl,
      Keys.OFFERED_ITEM_ID: _selectedProductId,
      Keys.OFFERED_ITEM_TYPE: _itemType,
    }).then((_) async {
      Navigator.pop(context);
    }).catchError((error) {
      setState(() {
        Utils.showToast(message: error.toString());
        _isLoading = false;
      });
    });
  }

  void _uploadImage() async{
    Reference ref =
        FirebaseStorage.instance.ref().child('offer_images/$_offerDocId.jpg');
    UploadTask task = ref.putFile(File(_pickedFile.path));
    task.whenComplete(() => null).then((_) async {
      _imageUrl = await _.ref.getDownloadURL();
      _saveToFirestore();
    }).catchError((error) {
      setState(() {
        Utils.showToast(message: error.toString());
        _isLoading = false;
      });
    });
  }

  void _getOfferId() {
    _offerDocId = FirebaseFirestore.instance.collection('offers').doc().id;
  }

  @override
  void onClick() {
    _title = _titleController.text.trim();
    _tagline = _taglineController.text.trim();
    if (_pickedFile == null && _imageUrl == null) {
      Utils.showToast(message: 'Select an image first');
    } else if (_title.isEmpty) {
      Utils.showToast(message: 'Title cannot be empty');
    } else if (_tagline.isEmpty) {
      Utils.showToast(message: 'Tagline cannot be empty');
    } else if (_selectedProductId == null) {
      Utils.showToast(message: 'Select a product first');
    } else {
      setState(() {
        _isLoading = true;
      });
      if (_offerDocId == null) _getOfferId();
      if (_pickedFile != null)
        _uploadImage();
      else
        _saveToFirestore();
    }
  }

  @override
  void onTrailingClicked() {
    Utils.showInfoDialog(
      context: context,
      title: 'Warning!',
      message: 'This offer will be permanently deleted.\nAre you sure?',
      iDeleteClicked: this,
    );
  }

  @override
  void onContinueClicked() {
    FirebaseFirestore.instance.collection('offers').doc(_offerDocId).delete();
    FirebaseStorage.instance
        .ref()
        .child('offer_images/$_offerDocId.jpg')
        .delete();
    Navigator.pop(context);
  }

  @override
  void onTextFieldClicked(FieldClickType clickType) async {
    OfferModel selectedItem = await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => ExhibitionsEventsItemsScreenMain(),
      ),
    );
    setState(() {
      if (selectedItem != null) {
        _selectedProductId = selectedItem.offeredItemSnapshpt.id;
        _offerType = selectedItem.offerType;
        switch (selectedItem.offerType) {
          case OfferType.PRODUCT:
            _selectedProductTitle =
                selectedItem.offeredItemSnapshpt[Keys.PRODUCT_TITLE];
            _itemType = Keys.PRODUCT;
            break;
          case OfferType.EXHIBITION:
            _selectedProductTitle =
                selectedItem.offeredItemSnapshpt[Keys.EXHIBITION_HEADLINE];
            _itemType = Keys.EXHIBITION;
            break;
          case OfferType.EVENT:
            _selectedProductTitle =
                selectedItem.offeredItemSnapshpt[Keys.EVENT_HEADLINE];
            _itemType = Keys.EVENT;
            break;
        }
      }
    });
  }
}
