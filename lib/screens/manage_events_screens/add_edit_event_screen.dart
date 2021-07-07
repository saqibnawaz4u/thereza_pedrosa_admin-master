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
import 'package:thereza_pedrosa_admin/screens/manage_events_screens/event_details_screen.dart';

class AddEditEventScreen extends StatefulWidget {
  DocumentSnapshot _snapshot;

  AddEditEventScreen(this._snapshot);

  @override
  _AddEditEventScreenState createState() => _AddEditEventScreenState();
}

class _AddEditEventScreenState extends State<AddEditEventScreen>
    implements IClick, IContinueClicked, ITrailingClicked, ITextFieldClicked {
  bool _isLoading = false;
  var _typeController = TextEditingController();
  var _headLineController = TextEditingController();
  var _detailsController = TextEditingController();
  DateTime _dateTime;
  TimeOfDay _timeOfDay;
  String _eventType,
      _eventHeadline,
      _eventDetails,
      _imageUrl,
      _eventDocId,
      _eventDate,
      _eventTime;
  PickedFile _pickedFile;

  @override
  void initState() {
    if (widget._snapshot != null) {
      _typeController.text = widget._snapshot[Keys.EVENT_TYPE];
      _headLineController.text = widget._snapshot[Keys.EVENT_HEADLINE];
      _detailsController.text = widget._snapshot[Keys.EVENT_DETAILS];
      _eventDate = widget._snapshot[Keys.EVENT_DATE];
      _eventTime = widget._snapshot[Keys.EVENT_TIME];
      _eventDocId = widget._snapshot.id;
      _imageUrl = widget._snapshot[Keys.EVENT_IMAGE_URL];
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: widget._snapshot != null
          ? Utils.getAppBarWithTrailing(
              context: context,
              title: 'Edit Event',
              isLeading: false,
              trailingIcon: Icons.delete,
              iTrailingClicked: this,
              leadingObject: null,
              family: 'Poppins',
            )
          : Utils.getAppBar(
              context: context,
              title: 'Add Event',
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
            controller: _typeController,
            hint: 'Event type',
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
            controller: _headLineController,
            hint: 'Event headline',
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
            hint: 'Event details',
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
            label: _eventDate == null ? 'Event date' : _eventDate,
            listener: this,
            family: 'Poppins',
            type: FieldClickType.START_DATE,
          ),
          Utils.getSizedBox(boxHeight: 12, boxWidth: 0),
          Utils.getBorderedText(
            context: context,
            label: _eventTime == null ? 'Event time' : _eventTime,
            listener: this,
            family: 'Poppins',
            type: FieldClickType.TIME,
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
    FirebaseFirestore.instance.collection('events').doc(_eventDocId).set({
      Keys.EVENT_TYPE: _eventType,
      Keys.EVENT_HEADLINE: _eventHeadline,
      Keys.EVENT_DETAILS: _eventDetails,
      Keys.EVENT_DATE: _eventDate,
      Keys.EVENT_TIME: _eventTime,
      Keys.EVENT_IMAGE_URL: _imageUrl,
    }).then((_) async {
      if (widget._snapshot == null) {
        Navigator.pop(context);
      } else {
        DocumentSnapshot snapshot = await FirebaseFirestore.instance
            .collection('events')
            .doc(_eventDocId)
            .get();
        Navigator.pop(context);
        Navigator.pop(context);
        Utils.push(context, EventDetailsScreen(snapshot));
      }
    }).catchError((error) {
      setState(() {
        Utils.showToast(message: error.toString());
        _isLoading = false;
      });
    });
  }

  void _uploadImage() async {
    Reference ref =
        FirebaseStorage.instance.ref().child('event_images/$_eventDocId.jpg');
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
    _eventDocId = FirebaseFirestore.instance.collection('events').doc().id;
  }

  @override
  void onClick() {
    _eventType = _typeController.text.trim();
    _eventHeadline = _headLineController.text.trim();
    _eventDetails = _detailsController.text.trim();
    if (_pickedFile == null && _imageUrl == null) {
      Utils.showToast(message: 'Select an image first');
    } else if (_eventType.isEmpty) {
      Utils.showToast(message: 'Event type cannot be empty');
    } else if (_eventHeadline.isEmpty) {
      Utils.showToast(message: 'Headline cannot be empty');
    } else if (_eventDetails.isEmpty) {
      Utils.showToast(message: 'Details cannot be empty');
    } else if (_dateTime == null && _eventDate == null) {
      Utils.showToast(message: 'Date cannot be empty');
    } else if (_timeOfDay == null && _eventTime == null) {
      Utils.showToast(message: 'Time cannot be empty');
    } else {
      setState(() {
        _isLoading = true;
      });
      if (_eventDocId == null) _getEventId();
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
          'This event will be permanently deleted.\nAre you sure you want to continue?',
      iDeleteClicked: this,
    );
  }

  @override
  void onContinueClicked() {
    FirebaseFirestore.instance.collection('events').doc(_eventDocId).delete();
    FirebaseStorage.instance
        .ref()
        .child('event_images/$_eventDocId.jpg')
        .delete();
    Navigator.pop(context);
    Navigator.pop(context);
  }

  @override
  void onTextFieldClicked(FieldClickType clickType) {
    if (clickType == FieldClickType.START_DATE) {
      _openDatePicker();
    } else {
      _openTimePicker();
    }
  }

  Future<void> _openTimePicker() async {
    _timeOfDay =
        await showTimePicker(context: context, initialTime: TimeOfDay.now());
    setState(() {
      _eventTime = '${_timeOfDay.hour}:${_timeOfDay.minute}';
    });
  }

  Future<void> _openDatePicker() async {
    _dateTime = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(
        Duration(days: 365),
      ),
    );
    setState(() {
      _eventDate = '${_dateTime.day}/${_dateTime.month}/${_dateTime.year}';
    });
  }
}
