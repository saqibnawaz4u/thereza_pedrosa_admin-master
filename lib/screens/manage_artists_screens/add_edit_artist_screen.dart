import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:thereza_pedrosa_admin/contracts/IClick.dart';
import 'package:thereza_pedrosa_admin/contracts/IContinueClicked.dart';
import 'package:thereza_pedrosa_admin/contracts/ITrailingClicked.dart';
import 'package:thereza_pedrosa_admin/others/Constants.dart';
import 'package:thereza_pedrosa_admin/others/Keys.dart';
import 'package:thereza_pedrosa_admin/others/Utils.dart';
import 'package:thereza_pedrosa_admin/screens/manage_artists_screens/artist_details_screen.dart';

class AddEditArtistScreen extends StatefulWidget {
  DocumentSnapshot _snapshot;

  AddEditArtistScreen(this._snapshot);

  @override
  _AddEditArtistScreenState createState() => _AddEditArtistScreenState();
}

class _AddEditArtistScreenState extends State<AddEditArtistScreen>
    implements IClick, ITrailingClicked, IContinueClicked {
  var _nameController = TextEditingController();
  var _originController = TextEditingController();
  var _descriptionController = TextEditingController();
  String _imageUrl,
      _artistName,
      _artistOrigin,
      _artistDescription,
      _artistDocId;
  bool _isLoading = false;
  PickedFile _pickedFile;

  @override
  void initState() {
    if (widget._snapshot != null) {
      _nameController.text = widget._snapshot[Keys.ARTIST_NAME];
      _originController.text = widget._snapshot[Keys.ARTIST_ORIGIN];
      _descriptionController.text = widget._snapshot[Keys.ARTIST_DESCRIPTION];
      _imageUrl = widget._snapshot[Keys.ARTIST_IMAGE_URL];
      _artistDocId = widget._snapshot.id;
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: widget._snapshot != null
          ? Utils.getAppBarWithTrailing(
              context: context,
              title: 'Edit Artist',
              isLeading: false,
              trailingIcon: Icons.delete,
              iTrailingClicked: this,
              leadingObject: null,
              family: 'Poppins',
            )
          : Utils.getAppBar(
              context: context,
              title: 'Add Artist',
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
            controller: _nameController,
            hint: 'Artist name',
            prefix: null,
            isPassword: false,
            isPhone: false,
            enabled: true,
            maxLines: 1,
            listener: null,
            family: 'Poppins',
            type: null,
          ),
          Utils.getSizedBox(boxHeight: 12, boxWidth: 0),
          Utils.getBorderedTextField(
            type: null,
            controller: _originController,
            hint: 'Artist origin',
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
            controller: _descriptionController,
            hint: 'Artist description',
            prefix: null,
            isPassword: false,
            isPhone: false,
            enabled: true,
            maxLines: 5,
            listener: null,
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

  @override
  void onClick() {
    _artistName = _nameController.text.trim();
    _artistOrigin = _originController.text.trim();
    _artistDescription = _descriptionController.text.trim();
    if (_pickedFile == null && widget._snapshot == null) {
      Utils.showToast(message: 'Select an image first');
    } else if (_artistName.isEmpty) {
      Utils.showToast(message: 'Artist name cannot be empty');
    } else if (_artistOrigin.isEmpty) {
      Utils.showToast(message: 'Artist origin cannot be empty');
    } else if (_artistDescription.isEmpty) {
      Utils.showToast(message: 'Artist description cannot be empty');
    } else {
      setState(() {
        _isLoading = true;
      });
      if (_artistDocId == null) _getArtistId();
      if (_pickedFile != null)
        _uploadImage();
      else
        _saveToFirestore();
    }
  }

  void _saveToFirestore() {
    FirebaseFirestore.instance.collection('artists').doc(_artistDocId).set({
      Keys.ARTIST_NAME: _artistName,
      Keys.ARTIST_ORIGIN: _artistOrigin,
      Keys.ARTIST_DESCRIPTION: _artistDescription,
      Keys.ARTIST_IMAGE_URL: _imageUrl,
    }).then((_) async {
      if (widget._snapshot == null) {
        Navigator.pop(context);
      } else {
        DocumentSnapshot snapshot = await FirebaseFirestore.instance
            .collection('artists')
            .doc(_artistDocId)
            .get();
        Navigator.pop(context);
        Navigator.pop(context);
        Utils.push(context, ArtistDetailsScreen(snapshot));
      }
    }).catchError((error) {
      setState(() {
        Utils.showToast(message: error.toString());
        _isLoading = false;
      });
    });
  }

  void _uploadImage()async {
   Reference ref =
        FirebaseStorage.instance.ref().child('artist_images/$_artistDocId.jpg');
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

  void _getArtistId() {
    _artistDocId =
        FirebaseFirestore.instance.collection('artists').doc().id;
  }

  @override
  void onTrailingClicked() {
    Utils.showInfoDialog(
      context: context,
      title: 'Warning!',
      message: 'This artist, with its all work, will be permanently deleted',
      iDeleteClicked: this,
    );
  }

  @override
  void onContinueClicked() async {
    setState(() {
      _isLoading = true;
    });
    QuerySnapshot artistWork = await FirebaseFirestore.instance
        .collection('products')
        .where(Keys.ARTIST_ID, isEqualTo: widget._snapshot.id)
        .get();
    artistWork.docs.forEach((product) {
      FirebaseFirestore.instance
          .collection('products')
          .doc(product.id)
          .delete();
      FirebaseStorage.instance
          .ref()
          .child('product_images/${product.id}.jpg')
          .delete();
    });
    FirebaseFirestore.instance
        .collection('artists')
        .doc(widget._snapshot.id)
        .delete();
    FirebaseStorage.instance
        .ref()
        .child('artist_images/${widget._snapshot.id}.jpg')
        .delete();
    Navigator.pop(context);
    Navigator.pop(context);
  }
}
