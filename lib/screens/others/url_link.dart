import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:thereza_pedrosa_admin/others/Utils.dart';

class Privacy extends StatefulWidget {
  String urlText;

  @override
  _PrivacyState createState() => _PrivacyState();
}

class _PrivacyState extends State<Privacy> {
  TextEditingController controller = TextEditingController();
  DocumentSnapshot mRef;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    fetchData();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.blueGrey,
        body: SingleChildScrollView(
          child: Column(
            children: [
              Padding(
                padding: EdgeInsets.symmetric(
                  vertical: 100.0,
                ),
                child: Center(
                  child: Text(
                    'Privacy Policy',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 30.0,
                        fontFamily: 'Poppins',
                        fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(
                  vertical: 50.0,
                  horizontal: 20.0,
                ),
                child: Center(
                  child: TextField(
                    controller: controller,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(
                          10.0,
                        ),
                        borderSide: BorderSide(color: Colors.black),
                      ),
                    ),
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: 20.0,
                ),
                child: RaisedButton(
                  onPressed: ()
                  {
                    updateLink();
                  },
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  child: Text('Save Changes', style: TextStyle(color: Colors.black),),
                )
              ),
            ],
          ),
        ),
      ),
    );
  }

  void dispose() {
    controller.dispose();
    super.dispose();
  }

  void fetchData() async {
    mRef = await FirebaseFirestore.instance
        .collection('privacy')
        .doc('privacy_policy_link')
        .get();
    setState(() {
      controller.text = mRef['link'];
    });
  }

  void updateLink() async {
   await FirebaseFirestore.instance
        .collection('privacy')
        .doc('privacy_policy_link')
        .set(
      {'link': controller.text},
      SetOptions(merge: true),
    );
  }
}
