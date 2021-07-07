import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:thereza_pedrosa_admin/contracts/IClick.dart';
import 'package:thereza_pedrosa_admin/contracts/IContinueClicked.dart';
import 'package:thereza_pedrosa_admin/contracts/ITrailingClicked.dart';
import 'package:thereza_pedrosa_admin/others/Constants.dart';
import 'package:thereza_pedrosa_admin/others/Keys.dart';
import 'package:thereza_pedrosa_admin/others/Utils.dart';
import 'package:thereza_pedrosa_admin/screens/manage_products_screens/product_details_screen.dart';

class AddEditNewProductScreen extends StatefulWidget {
  DocumentSnapshot _snapshot;

  AddEditNewProductScreen(this._snapshot);

  @override
  _AddEditNewProductScreenState createState() =>
      _AddEditNewProductScreenState();
}

class _AddEditNewProductScreenState extends State<AddEditNewProductScreen>
    implements IClick, ITrailingClicked, IContinueClicked {
  var _titleController = TextEditingController();
  var _priceController = TextEditingController();
  var _descriptionController = TextEditingController();
  var _materialController = TextEditingController();
  var _dimensionsController = TextEditingController();
  String _imageUrl1,
      _imageUrl2,
      _imageUrl3,
      _productTitle,
      _productDescription,
      _productMaterial,
      _productDimensions,
      _productDocId,
      _productPrice;
  DocumentSnapshot _selectedArtist;
  String _selectedColor;
  String _selectedCategory;
  List<DocumentSnapshot> _artists = [];
  List<String> _colors = [];
  List<String> _categories = [];
  bool _isLoading = false;
  PickedFile _pickedFile1, _pickedFile2, _pickedFile3;

  @override
  void initState() {
    if (widget._snapshot != null) {
      _titleController.text = widget._snapshot[Keys.PRODUCT_TITLE];
      _priceController.text = widget._snapshot[Keys.PRODUCT_PRICE].toString();
      _descriptionController.text = widget._snapshot[Keys.PRODUCT_DESCRIPTION];
      _materialController.text = widget._snapshot[Keys.PRODUCT_MATERIAL];
      _dimensionsController.text = widget._snapshot[Keys.PRODUCT_DIMENSIONS];
      _productDocId = widget._snapshot.id;
      _imageUrl1 = widget._snapshot[Keys.PRODUCT_IMAGE_URL_1];
      _imageUrl2 = widget._snapshot[Keys.PRODUCT_IMAGE_URL_2];
      _imageUrl3 = widget._snapshot[Keys.PRODUCT_IMAGE_URL_3];
      _selectedCategory = widget._snapshot[Keys.PRODUCT_CATEGORY];
      _selectedColor = widget._snapshot[Keys.PRODUCT_COLOR];
    }
    FirebaseFirestore.instance.collection('artists')
      ..get().then((querySnapshot) {
        querySnapshot.docs.forEach((artist) {
          _artists.add(artist);
        });
        if (widget._snapshot == null && _artists.isNotEmpty) {
          _selectedArtist = _artists[0];
        } else {
          _artists.forEach((listArtist) {
            if (listArtist.id == widget._snapshot[Keys.ARTIST_ID])
              _selectedArtist = listArtist;
          });
        }
        setState(() {});
      });
    FirebaseFirestore.instance.collection('categories')
      ..get().then((querySnapshot) {
        querySnapshot.docs.forEach((category) {
          _categories.add(category[Keys.CATEGORY]);
        });
        if (widget._snapshot == null && _categories.isNotEmpty) {
          _selectedCategory = _categories[0];
        }
        setState(() {});
      });
    FirebaseFirestore.instance.collection('colors')
      ..get().then((querySnapshot) {
        querySnapshot.docs.forEach((color) {
          _colors.add(color[Keys.COLOR]);
        });
        if (widget._snapshot == null && _colors.isNotEmpty) {
          _selectedColor = _colors[0];
        }
        setState(() {});
      });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: widget._snapshot != null
          ? Utils.getAppBarWithTrailing(
              context: context,
              title: 'Edit Product',
              isLeading: false,
              trailingIcon: Icons.delete,
              iTrailingClicked: this,
              leadingObject: null,
              family: 'Poppins',
            )
          : Utils.getAppBar(
              context: context,
              title: 'Add New Product',
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
              Utils.getSizedBox(boxHeight: 8, boxWidth: 0),
              _getImagesSection(),
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
              hint: 'Product title',
              prefix: null,
              isPassword: false,
              isPhone: false,
              enabled: true,
              maxLines: 1,
              listener: null,
              family: 'Poppins'),
          Utils.getSizedBox(boxHeight: 12, boxWidth: 0),
          Utils.getBorderedTextField(
              type: null,
              controller: _priceController,
              hint: 'Product price',
              prefix: null,
              isPassword: false,
              isPhone: true,
              enabled: true,
              maxLines: 1,
              listener: null,
              family: 'Poppins'),
          Utils.getSizedBox(boxHeight: 12, boxWidth: 0),
          Text(
            'Select Category',
            style: TextStyle(
              fontFamily: 'Poppins',
            ),
          ),
          _getCategoriesDropDown(),
          Utils.getSizedBox(boxHeight: 12, boxWidth: 0),
          Text(
            'Select Color',
            style: TextStyle(
              fontFamily: 'Poppins',
            ),
          ),
          _getColorsDropDown(),
          Utils.getSizedBox(boxHeight: 12, boxWidth: 0),
          Text(
            'Select Artist',
            style: TextStyle(
              fontFamily: 'Poppins',
            ),
          ),
          _getArtistsDropDown(),
          Utils.getSizedBox(boxHeight: 12, boxWidth: 0),
          Utils.getBorderedTextField(
            type: null,
            controller: _descriptionController,
            hint: 'Product description',
            prefix: null,
            isPassword: false,
            isPhone: false,
            enabled: true,
            maxLines: 5,
            listener: null,
            family: 'Poppins',
          ),
          Utils.getSizedBox(boxHeight: 12, boxWidth: 0),
          Text('Product Details'),
          Utils.getSizedBox(boxHeight: 4, boxWidth: 0),
          Utils.getBorderedTextField(
            type: null,
            controller: _materialController,
            hint: 'Material',
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
            controller: _dimensionsController,
            hint: 'Dimensions',
            prefix: null,
            isPassword: false,
            isPhone: false,
            enabled: true,
            maxLines: 1,
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

  Widget _getCategoriesDropDown() {
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
        value: _selectedCategory,
        onChanged: (selectedCategory) {
          setState(() {
            _selectedCategory = selectedCategory;
          });
        },
        items: _categories.map((category) {
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

  Widget _getColorsDropDown() {
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
        value: _selectedColor,
        onChanged: (color) {
          setState(() {
            _selectedColor = color;
          });
        },
        items: _colors.map((color) {
          return DropdownMenuItem<String>(
            child: Text(
              color,
              style: TextStyle(
                fontFamily: 'Poppins',
              ),
            ),
            value: color,
          );
        }).toList(),
      ),
    );
  }

  Widget _getArtistsDropDown() {
    return Container(
      margin: EdgeInsets.only(top: 4),
      padding: EdgeInsets.only(left: 12, right: 12),
      height: 45,
      width: Utils.getScreenWidth(context),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.black87),
      ),
      child: DropdownButton<DocumentSnapshot>(
        isExpanded: true,
        underline: SizedBox(),
        value: _selectedArtist,
        onChanged: (selectedArtist) {
          setState(() {
            _selectedArtist = selectedArtist;
          });
        },
        items: _artists.map((artist) {
          return DropdownMenuItem<DocumentSnapshot>(
            child: Text(
              artist[Keys.ARTIST_NAME],
              style: TextStyle(
                fontFamily: 'Poppins',
              ),
            ),
            value: artist,
          );
        }).toList(),
      ),
    );
  }

  Widget _getImagesSection() {
    return Row(
      children: [
        Expanded(
          child: GestureDetector(
            onTap: () async {
              var file = await ImagePicker().getImage(
                source: ImageSource.gallery,
                imageQuality: 20,
              );
              if (file != null) {
                setState(() {
                  _pickedFile1 = file;
                });
              }
            },
            child: _pickedFile1 != null
                ? Image.file(
                    File(_pickedFile1.path),
                    height: 100,
                    fit: BoxFit.cover,
                  )
                : _imageUrl1 != null
                    ? Image.network(
                        _imageUrl1,
                        height: 100,
                        fit: BoxFit.cover,
                      )
                    : Image.asset(
                        'images/img_camera.png',
                        height: 100,
                        fit: BoxFit.cover,
                      ),
          ),
        ),
        Utils.getSizedBox(boxHeight: 0, boxWidth: 4),
        Expanded(
          child: GestureDetector(
            onTap: () async {
              var file = await ImagePicker().getImage(
                source: ImageSource.gallery,
                imageQuality: 20,
              );
              if (file != null) {
                setState(() {
                  _pickedFile2 = file;
                });
              }
            },
            child: _pickedFile2 != null
                ? Image.file(
                    File(_pickedFile2.path),
                    height: 100,
                    fit: BoxFit.cover,
                  )
                : _imageUrl2 != null
                    ? Image.network(
                        _imageUrl2,
                        height: 100,
                        fit: BoxFit.cover,
                      )
                    : Image.asset(
                        'images/img_camera.png',
                        height: 100,
                        fit: BoxFit.cover,
                      ),
          ),
        ),
        Utils.getSizedBox(boxHeight: 0, boxWidth: 4),
        Expanded(
          child: GestureDetector(
            onTap: () async {
              var file = await ImagePicker().getImage(
                source: ImageSource.gallery,
                imageQuality: 20,
              );
              if (file != null) {
                setState(() {
                  _pickedFile3 = file;
                });
              }
            },
            child: _pickedFile3 != null
                ? Image.file(
                    File(_pickedFile3.path),
                    height: 100,
                    fit: BoxFit.cover,
                  )
                : _imageUrl3 != null
                    ? Image.network(
                        _imageUrl3,
                        height: 100,
                        fit: BoxFit.cover,
                      )
                    : Image.asset(
                        'images/img_camera.png',
                        height: 100,
                        fit: BoxFit.cover,
                      ),
          ),
        ),
      ],
    );
  }

  void _saveToFirestore() {
    FirebaseFirestore.instance.collection('products').doc(_productDocId).set({
      Keys.PRODUCT_TITLE: _productTitle,
      Keys.PRODUCT_PRICE: _productPrice.contains('.')
          ? double.parse(_productPrice)
          : int.parse(_productPrice),
      Keys.PRODUCT_AVAILABLE: widget._snapshot == null
          ? true
          : widget._snapshot[Keys.PRODUCT_AVAILABLE],
      Keys.PRODUCT_DESCRIPTION: _productDescription,
      Keys.PRODUCT_MATERIAL: _productMaterial,
      Keys.PRODUCT_COLOR: _selectedColor,
      Keys.PRODUCT_CATEGORY: _selectedCategory,
      Keys.TIMESTAMP: widget._snapshot == null
          ? Timestamp.now()
          : widget._snapshot[Keys.TIMESTAMP],
      Keys.ARTIST_ID: _selectedArtist.id,
      Keys.PRODUCT_DIMENSIONS: _productDimensions,
      Keys.PRODUCT_IS_FEATURED: widget._snapshot == null
          ? false
          : widget._snapshot[Keys.PRODUCT_IS_FEATURED],
      Keys.PRODUCT_IMAGE_URL_1: _imageUrl1,
      Keys.PRODUCT_IMAGE_URL_2: _imageUrl2,
      Keys.PRODUCT_IMAGE_URL_3: _imageUrl3,
    }).then((_) async {
      if (widget._snapshot == null) {
        Navigator.pop(context);
      } else {
        DocumentSnapshot snapshot = await FirebaseFirestore.instance
            .collection('products')
            .doc(_productDocId)
            .get();
        Navigator.pop(context);
        Navigator.pop(context);
        Utils.push(context, ProductDetailsScreen(snapshot));
      }
    }).catchError((error) {
      setState(() {
        Utils.showToast(message: error.toString());
        _isLoading = false;
      });
    });
  }

  Future<void> _uploadImage(int index, String path) async {
    Reference ref = FirebaseStorage.instance
        .ref()
        .child('product_images/$_productDocId$index.jpg');
    UploadTask task = ref.putFile(File(path));
    try {
      var result = await task.whenComplete(() => null);
      if (index == 0) {
        _imageUrl1 = await result.ref.getDownloadURL();
      } else if (index == 1) {
        _imageUrl2 = await result.ref.getDownloadURL();
      } else {
        _imageUrl3 = await result.ref.getDownloadURL();
      }
    } catch (exc) {
      Utils.showToast(message: exc.toString());
    }
  }

  void _getProductId() {
    _productDocId =
        FirebaseFirestore.instance.collection('products').doc().id;
  }

  @override
  void onClick() async {
    _productTitle = _titleController.text.trim();
    _productPrice = _priceController.text.trim();
    _productDescription = _descriptionController.text.trim();
    _productMaterial = _materialController.text.trim();
    _productDimensions = _dimensionsController.text.trim();
    if ((_pickedFile1 == null && _imageUrl1 == null) ||
        (_pickedFile2 == null && _imageUrl2 == null) ||
        (_pickedFile3 == null && _imageUrl3 == null)) {
      Utils.showToast(message: 'Select images first');
    } else if (_productTitle.isEmpty) {
      Utils.showToast(message: 'Title cannot be empty');
    } else if (_productPrice.isEmpty) {
      Utils.showToast(message: 'Price cannot be empty');
    } else if (_productDescription.isEmpty) {
      Utils.showToast(message: 'Description cannot be empty');
    } else if (_productMaterial.isEmpty) {
      Utils.showToast(message: 'Material cannot be empty');
    } else if (_productDimensions.isEmpty) {
      Utils.showToast(message: 'Dimensions cannot be empty');
    } else {
      setState(() {
        _isLoading = true;
      });
      if (_productDocId == null) _getProductId();
      if (_pickedFile1 != null) {
        await _uploadImage(0, _pickedFile1.path);
      }
      if (_pickedFile2 != null) {
        await _uploadImage(1, _pickedFile2.path);
      }
      if (_pickedFile3 != null) {
        await _uploadImage(2, _pickedFile3.path);
      }
      if (_imageUrl1 != null && _imageUrl2 != null && _imageUrl3 != null) {
        _saveToFirestore();
      } else {
        setState(() {
          Utils.showToast(message: 'There was an error uploading your images');
          _isLoading = false;
        });
      }
    }
  }

  @override
  void onTrailingClicked() {
    Utils.showInfoDialog(
      context: context,
      title: 'Warning!',
      message: 'This product will be permanently deleted.\nAre you sure?',
      iDeleteClicked: this,
    );
  }

  @override
  void onContinueClicked() {
    FirebaseFirestore.instance.collection('products').doc(_productDocId).delete();
    FirebaseStorage.instance
        .ref()
        .child('product_images/$_productDocId.jpg')
        .delete();
    Navigator.pop(context);
    Navigator.pop(context);
  }
}
