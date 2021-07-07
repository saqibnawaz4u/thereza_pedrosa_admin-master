import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:expandable/expandable.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:share/share.dart';
import 'package:thereza_pedrosa_admin/contracts/ITrailingClicked.dart';
import 'package:thereza_pedrosa_admin/models/ExhibitionItemsModel.dart';
import 'package:thereza_pedrosa_admin/others/Keys.dart';
import 'package:thereza_pedrosa_admin/others/Utils.dart';
import 'package:thereza_pedrosa_admin/screens/manage_exhibitions_screens/add_edit_exhibition_screen.dart';
import 'package:thereza_pedrosa_admin/screens/manage_products_screens/product_details_screen.dart';

class ExhibitionDetailsScreen extends StatefulWidget {
  DocumentSnapshot _snapshot;

  ExhibitionDetailsScreen(this._snapshot);

  @override
  _ExhibitionDetailsScreenState createState() =>
      _ExhibitionDetailsScreenState();
}

class _ExhibitionDetailsScreenState extends State<ExhibitionDetailsScreen>
    implements ITrailingClicked {
  List<ExhibitionItemsModel> _exhibitionItemsList = [];

  @override
  void initState() {
    (widget._snapshot['items'] as List<Object>).forEach((itemId) {
      var model = ExhibitionItemsModel();
      model.itemId = itemId.toString();
      _exhibitionItemsList.add(model);
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: Utils.getAppBarWithTrailing(
        context: context,
        title: 'Exhibition Details',
        isLeading: false,
        leadingObject: null,
        trailingIcon: Icons.edit,
        family: 'Playfair',
        iTrailingClicked: this,
      ),
      body: _getBody(),
    );
  }

  Widget _getBody() {
    return ListView(
      children: [
        Image.network(
          widget._snapshot[Keys.EXHIBITION_IMAGE_URL],
          width: Utils.getScreenWidth(context),
          height: 250,
          fit: BoxFit.cover,
        ),
        Padding(
          padding: EdgeInsets.only(left: 16, top: 16, bottom: 8, right: 16),
          child: Text(
            'From ${widget._snapshot[Keys.EXHIBITION_START_DATE]} to ${widget._snapshot[Keys.EXHIBITION_END_DATE]}',
            style: TextStyle(
              fontFamily: 'Poppins',
              fontWeight: FontWeight.bold,
              fontSize: 15,
              color: Colors.black54,
            ),
          ),
        ),
        Padding(
          padding: EdgeInsets.only(left: 16, right: 16),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  widget._snapshot[Keys.EXHIBITION_HEADLINE],
                  style: TextStyle(
                    fontSize: 19,
                    color: Colors.black,
                  ),
                ),
              ),
              IconButton(
                icon: Icon(Icons.share),
                onPressed: () {
                  Share.share(
                      '${widget._snapshot[Keys
                          .EXHIBITION_IMAGE_URL]}\n\n*${widget._snapshot[Keys
                          .EXHIBITION_HEADLINE]}*\n${widget._snapshot[Keys
                          .EXHIBITION_DETAILS]}\n*On ${widget._snapshot[Keys
                          .EXHIBITION_START_DATE]}}*');
                },
              ),
            ],
          ),
        ),
        _getDetailsSection(),
        _getExhibitionProducts(),
      ],
    );
  }

  Widget _getExhibitionProducts() {
    return Container(
      padding: EdgeInsets.all(16),
      height: 500,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Exhibition Items',
            style: TextStyle(
              fontFamily: 'Playfair',
              fontWeight: FontWeight.bold,
              fontSize: 17,
            ),
          ),
          Expanded(
            child: _getItemsList(),
          ),
        ],
      ),
    );
  }

  Widget _getItemsList() {
    return GridView.count(
      crossAxisCount: 2,
      children: _exhibitionItemsList.map((model) {
        if (model.snapshot == null) {
          _getItemDetails(_exhibitionItemsList.indexOf(model));
        }
        String title = '';
        if (model.snapshot != null) {
          title = model.snapshot[Keys.PRODUCT_TITLE].length > 10
              ? '${model.snapshot[Keys.PRODUCT_TITLE].substring(0, 9)}...'
              : model.snapshot[Keys.PRODUCT_TITLE];
        }
        return GestureDetector(
          onTap: () {
            Utils.push(context, ProductDetailsScreen(model.snapshot));
          },
          child: Container(
            width: Utils.getScreenWidth(context) / 2.75,
            margin: EdgeInsets.all(4),
            child: Card(
              child: Padding(
                padding: EdgeInsets.all(8),
                child: Column(
                  children: [
                    Container(
                      height: Utils.getScreenWidth(context) / 3.5,
                      width: double.infinity,
                      child: Image.network(
                        model.snapshot != null
                            ? model.snapshot[Keys.PRODUCT_IMAGE_URL_1]
                            : '',
                        fit: BoxFit.cover,
                      ),
                    ),
                    Text(
                      title,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                        fontSize: 13,
                      ),
                    ),
                    Text(
                      model.snapshot != null
                          ? '€${model.snapshot[Keys.PRODUCT_PRICE]}'
                          : '',
                      style: TextStyle(
                        color: Colors.black54,
                        fontSize: 12,
                        fontFamily: 'Poppins',
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Future<void> _getItemDetails(int index) async {
    _exhibitionItemsList[index].snapshot = await FirebaseFirestore.instance
        .collection('products')
        .doc(_exhibitionItemsList[index].itemId)
        .get();
    setState(() {});
  }

  Widget _getDetailsSection() {
    return Padding(
      padding: EdgeInsets.only(left: 16, bottom: 8, right: 16, top: 8),
      child: ExpandablePanel(
       // headerAlignment: ExpandablePanelHeaderAlignment.center,
        header: Center(
          child: Text(
            'Exhibition Details',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 17,
            ),
          ),
        ),
        collapsed: Text(
          widget._snapshot[Keys.EXHIBITION_DETAILS],
          softWrap: true,
          maxLines: 3,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontFamily: 'Poppins',
          ),
        ),
        expanded: Text(
          widget._snapshot[Keys.EXHIBITION_DETAILS],
          softWrap: true,
          style: TextStyle(
            fontFamily: 'Poppins',
          ),
        ),
      ),
    );
  }

  @override
  void onTrailingClicked() {
    Utils.push(context, AddEditExhibitionScreen(widget._snapshot));
  }
}
