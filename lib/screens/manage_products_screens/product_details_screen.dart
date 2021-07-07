import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:expandable/expandable.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:thereza_pedrosa_admin/contracts/ITrailingClicked.dart';
import 'package:thereza_pedrosa_admin/others/Keys.dart';
import 'package:thereza_pedrosa_admin/others/Utils.dart';
import 'package:thereza_pedrosa_admin/screens/manage_products_screens/add_edit_new_product_screen.dart';

class ProductDetailsScreen extends StatefulWidget {
  DocumentSnapshot _snapshot;

  ProductDetailsScreen(this._snapshot);

  @override
  _ProductDetailsScreenState createState() => _ProductDetailsScreenState();
}

class _ProductDetailsScreenState extends State<ProductDetailsScreen>
    implements ITrailingClicked {
  String _artistName = '';
  bool _isFeatured, _isAvailable;

  @override
  void initState() {
    _isFeatured = widget._snapshot[Keys.PRODUCT_IS_FEATURED];
    _isAvailable = widget._snapshot[Keys.PRODUCT_AVAILABLE];
    FirebaseFirestore.instance
        .collection('artists')
        .doc(widget._snapshot[Keys.ARTIST_ID])
        .get()
        .then((artist) {
      setState(() {
        _artistName = artist[Keys.ARTIST_NAME];
      });
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: Utils.getAppBarWithTrailing(
        context: context,
        title: widget._snapshot[Keys.PRODUCT_TITLE],
        isLeading: false,
        leadingObject: null,
        trailingIcon: Icons.edit,
        iTrailingClicked: this,
        family: 'Playfair',
      ),
      body: _getBody(),
    );
  }

  Widget _getBody() {
    return Container(
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _getImageSection(),
            Padding(
              padding: EdgeInsets.only(left: 16, right: 16, top: 16),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      _artistName,
                      style: TextStyle(
                        fontSize: 19,
                      ),
                    ),
                  ),
                  Expanded(
                    child: Text(
                      'Add to Featured',
                      textAlign: TextAlign.end,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: EdgeInsets.only(left: 16, right: 16),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      widget._snapshot[Keys.PRODUCT_CATEGORY],
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Switch(
                    value: _isFeatured,
                    onChanged: (val) {
                      _updateFeaturedStatus(val);
                      setState(() {
                        _isFeatured = val;
                      });
                    },
                  ),
                ],
              ),
            ),
            Padding(
              padding: EdgeInsets.only(left: 16, right: 16),
              child: Text(
                '€${widget._snapshot[Keys.PRODUCT_PRICE]}',
                style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                    fontFamily: 'Poppins'),
              ),
            ),
            Padding(
              padding: EdgeInsets.only(left: 16, right: 16),
              child: Row(
                children: [
                  Text(
                    'Is Available:',
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                        fontFamily: 'Poppins'),
                  ),
                  Switch(
                    value: _isAvailable,
                    onChanged: (val) {
                      _updateAvailability(val);
                      setState(() {
                        _isAvailable = val;
                      });
                    },
                  ),
                ],
              ),
            ),
            _getDescriptionSection(),
            _getDetailsSection(),
          ],
        ),
      ),
    );
  }

  Widget _getDetailsSection() {
    return Padding(
      padding: EdgeInsets.only(left: 16, bottom: 8, right: 16),
      child: ExpandablePanel(
        //headerAlignment: ExpandablePanelHeaderAlignment.center,
        header: Center(
          child: Text(
            'Product Details',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 17,
            ),
          ),
        ),
        collapsed: Text(
          widget._snapshot[Keys.PRODUCT_MATERIAL],
          softWrap: true,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontFamily: 'Poppins',
          ),
        ),
        expanded: Text(
          'Material: ${widget._snapshot[Keys.PRODUCT_MATERIAL]}\nColor: ${widget._snapshot[Keys.PRODUCT_COLOR]}\nDimensions: ${widget._snapshot[Keys.PRODUCT_DIMENSIONS]}',
          softWrap: true,
          style: TextStyle(
            fontFamily: 'Poppins',
          ),
        ),
      ),
    );
  }

  Widget _getDescriptionSection() {
    return Padding(
      padding: EdgeInsets.only(left: 16, bottom: 8, right: 16),
      child: ExpandablePanel(
        //headerAlignment: ExpandablePanelHeaderAlignment.center,
        header: Center(
          child: Text(
            'Description',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 17,
            ),
          ),
        ),
        collapsed: Text(
          widget._snapshot[Keys.PRODUCT_DESCRIPTION],
          softWrap: true,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontFamily: 'Poppins',
          ),
        ),
        expanded: Text(
          widget._snapshot[Keys.PRODUCT_DESCRIPTION],
          softWrap: true,
          style: TextStyle(
            fontFamily: 'Poppins',
          ),
        ),
      ),
    );
  }

  Widget _getImageSection() {
    return Container(
      height: 200,
      child: PageView(
        scrollDirection: Axis.horizontal,
        children: [
          Image.network(
            widget._snapshot[Keys.PRODUCT_IMAGE_URL_1],
            width: Utils.getScreenWidth(context),
            height: 200,
            fit: BoxFit.cover,
          ),
          Image.network(
            widget._snapshot[Keys.PRODUCT_IMAGE_URL_2],
            width: Utils.getScreenWidth(context),
            height: 200,
            fit: BoxFit.cover,
          ),
          Image.network(
            widget._snapshot[Keys.PRODUCT_IMAGE_URL_3],
            width: Utils.getScreenWidth(context),
            height: 200,
            fit: BoxFit.cover,
          ),
        ],
      ),
    );
  }

  void _updateAvailability(bool status) {
    FirebaseFirestore.instance
        .collection('products')
        .doc(widget._snapshot.id)
        .set(
      {
        Keys.PRODUCT_AVAILABLE: status,
      },
      SetOptions(
        merge: true,
      )
    );
  }

  void _updateFeaturedStatus(bool status) {
    FirebaseFirestore.instance
        .collection('products')
        .doc(widget._snapshot.id)
        .set(
      {
        Keys.PRODUCT_IS_FEATURED: status,
      },
      SetOptions(
        merge: true,
      )
    );
  }

  @override
  void onTrailingClicked() {
    Utils.push(context, AddEditNewProductScreen(widget._snapshot));
  }
}
