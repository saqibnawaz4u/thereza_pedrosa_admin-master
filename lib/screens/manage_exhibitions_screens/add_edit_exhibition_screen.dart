import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:thereza_pedrosa_admin/contracts/IClick.dart';
import 'package:thereza_pedrosa_admin/contracts/IContinueClicked.dart';
import 'package:thereza_pedrosa_admin/contracts/ITextFieldClicked.dart';
import 'package:thereza_pedrosa_admin/contracts/ITrailingClicked.dart';
import 'package:thereza_pedrosa_admin/enums/FieldClickType.dart';
import 'package:thereza_pedrosa_admin/others/Constants.dart';
import 'package:thereza_pedrosa_admin/others/Keys.dart';
import 'package:thereza_pedrosa_admin/others/Utils.dart';
import 'package:thereza_pedrosa_admin/screens/manage_exhibitions_screens/exhibition_details_screen.dart';
import 'package:thereza_pedrosa_admin/screens/others/peoduct_selection_screen.dart';

class AddEditExhibitionScreen extends StatefulWidget {
  DocumentSnapshot _snapshot;

  AddEditExhibitionScreen(this._snapshot);

  @override
  _AddEditExhibitionScreenState createState() =>
      _AddEditExhibitionScreenState();
}

class _AddEditExhibitionScreenState extends State<AddEditExhibitionScreen>
    implements IClick, IContinueClicked, ITrailingClicked, ITextFieldClicked {
  bool _isLoading = false;
  List<DocumentSnapshot> _selectedItems;
  var _headLineController = TextEditingController();
  var _detailsController = TextEditingController();
  String _selectedExhibitionType = 'Solo',
      _exhibitionHeadline,
      _exhibitionDetails,
      _imageUrl,
      _exhibitionDocId,
      _exhibitionDate,
      _endDate;
  PickedFile _pickedFile;
  List<String> _exhibitionTypesList = ['Solo', 'Collective', 'Art Fair'];

  @override
  void initState() {
    if (widget._snapshot != null) {
      _selectedExhibitionType = widget._snapshot[Keys.EXHIBITION_TYPE];
      _headLineController.text = widget._snapshot[Keys.EXHIBITION_HEADLINE];
      _detailsController.text = widget._snapshot[Keys.EXHIBITION_DETAILS];
      _exhibitionDate = widget._snapshot[Keys.EXHIBITION_START_DATE];
      _endDate = widget._snapshot[Keys.EXHIBITION_END_DATE];
      _exhibitionDocId = widget._snapshot.id;
      _imageUrl = widget._snapshot[Keys.EXHIBITION_IMAGE_URL];
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: widget._snapshot != null
          ? Utils.getAppBarWithTrailing(
              context: context,
              title: 'Edit Exhibition',
              isLeading: false,
              trailingIcon: Icons.delete,
              iTrailingClicked: this,
              leadingObject: null,
              family: 'Poppins',
            )
          : Utils.getAppBar(
              context: context,
              title: 'Add Exhibition',
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
          Text(
            'Select Exhibition Type',
            style: TextStyle(
              fontFamily: 'Poppins',
            ),
          ),
          _getTypeDropDown(),
          Utils.getSizedBox(boxHeight: 12, boxWidth: 0),
          Utils.getBorderedTextField(
            controller: _headLineController,
            hint: 'Exhibition headline',
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
            controller: _detailsController,
            hint: 'Exhibition details',
            prefix: null,
            isPassword: false,
            isPhone: false,
            enabled: true,
            maxLines: 5,
            listener: null,
            family: 'Poppins',
            type: null,
          ),
          Utils.getSizedBox(boxHeight: 12, boxWidth: 0),
          Utils.getBorderedText(
            context: context,
            label: _exhibitionDate == null
                ? 'Exhibition start date'
                : _exhibitionDate,
            listener: this,
            family: 'Poppins',
            type: FieldClickType.START_DATE,
          ),
          Utils.getSizedBox(boxHeight: 12, boxWidth: 0),
          Utils.getBorderedText(
            context: context,
            label: _endDate == null ? 'Exhibition end date' : _endDate,
            listener: this,
            family: 'Poppins',
            type: FieldClickType.END_DATE,
          ),
          Utils.getSizedBox(boxHeight: 12, boxWidth: 0),
          Utils.getBorderedText(
            context: context,
            label: _selectedItems == null
                ? 'Select Products'
                : '${_selectedItems[0][Keys.PRODUCT_TITLE]}...',
            listener: this,
            family: 'Poppins',
            type: FieldClickType.PRODUCT_SELECTION,
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

  Widget _getTypeDropDown() {
    return Container(
      margin: EdgeInsets.only(top: 4),
      padding: EdgeInsets.only(left: 12, right: 12),
      height: 45,
      width: Utils.getScreenWidth(context),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.black87),
      ),
      child: DropdownButton<String>(
        isExpanded: true,
        underline: SizedBox(),
        value: _selectedExhibitionType,
        onChanged: (selectedExhibitionType) {
          setState(() {
            _selectedExhibitionType = selectedExhibitionType;
          });
        },
        items: _exhibitionTypesList.map((category) {
          return DropdownMenuItem<String>(
            child: Text(
              category,
              style: TextStyle(
                fontFamily: 'Poppins',
              ),
            ),
            value: category,
          );
        }).toList(),
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
    List<String> items = [];
    _selectedItems.forEach((item) {
      items.add(item.id);
    });
    FirebaseFirestore.instance
        .collection('exhibitions')
        .doc(_exhibitionDocId)
        .set({
      Keys.EXHIBITION_TYPE: _selectedExhibitionType,
      Keys.EXHIBITION_HEADLINE: _exhibitionHeadline,
      Keys.EXHIBITION_DETAILS: _exhibitionDetails,
      Keys.EXHIBITION_START_DATE: _exhibitionDate,
      Keys.EXHIBITION_END_DATE: _endDate,
      Keys.EXHIBITION_ITEMS: items,
      Keys.EXHIBITION_IMAGE_URL: _imageUrl,
    }).then((_) async {
      if (widget._snapshot == null) {
        Navigator.pop(context);
      } else {
        DocumentSnapshot snapshot = await FirebaseFirestore.instance
            .collection('exhibitions')
            .doc(_exhibitionDocId)
            .get();
        Navigator.pop(context);
        Navigator.pop(context);
        Utils.push(context, ExhibitionDetailsScreen(snapshot));
      }
    }).catchError((error) {
      setState(() {
        Utils.showToast(message: error.toString());
        _isLoading = false;
      });
    });
  }

  void _uploadImage() async {
    Reference ref = FirebaseStorage.instance
        .ref()
        .child('exhibition_images/$_exhibitionDocId.jpg');
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

  void _getEventId() {
    _exhibitionDocId =
        FirebaseFirestore.instance.collection('exhibitions').doc().id;
  }

  @override
  void onClick() {
    _exhibitionHeadline = _headLineController.text.trim();
    _exhibitionDetails = _detailsController.text.trim();
    if (_pickedFile == null && _imageUrl == null) {
      Utils.showToast(message: 'Select an image first');
    } else if (_exhibitionHeadline.isEmpty) {
      Utils.showToast(message: 'Headline cannot be empty');
    } else if (_exhibitionDetails.isEmpty) {
      Utils.showToast(message: 'Details cannot be empty');
    } else if (_exhibitionDate == null) {
      Utils.showToast(message: 'Start date cannot be empty');
    } else if (_endDate == null) {
      Utils.showToast(message: 'End date cannot be empty');
    } else if (_selectedItems == null || _selectedItems.isEmpty) {
      Utils.showToast(message: 'Please select exhibition items');
    } else {
      setState(() {
        _isLoading = true;
      });
      if (_exhibitionDocId == null) _getEventId();
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
      message:
          'This exhibition will be permanently deleted.\nAre you sure you want to continue?',
      iDeleteClicked: this,
    );
  }

  @override
  void onContinueClicked() {
    FirebaseFirestore.instance
        .collection('exhibitions')
        .doc(_exhibitionDocId)
        .delete();
    FirebaseStorage.instance
        .ref()
        .child('exhibition_images/$_exhibitionDocId.jpg')
        .delete();
    Navigator.pop(context);
    Navigator.pop(context);
  }

  @override
  void onTextFieldClicked(FieldClickType clickType) async {
    if (clickType == FieldClickType.START_DATE ||
        clickType == FieldClickType.END_DATE) {
      _openDatePicker(clickType);
    } else {
      _selectedItems = await Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => ProductSelectionList()),
      );
      setState(() {});
    }
  }

  Future<void> _openDatePicker(FieldClickType clickType) async {
    DateTime dateTime = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now().subtract(
        Duration(days: 365),
      ),
      lastDate: DateTime.now().add(
        Duration(days: 365),
      ),
    );
    setState(() {
      if (clickType == FieldClickType.START_DATE) {
        _exhibitionDate = '${dateTime.day}/${dateTime.month}/${dateTime.year}';
      } else {
        _endDate = '${dateTime.day}/${dateTime.month}/${dateTime.year}';
      }
    });
  }
}
