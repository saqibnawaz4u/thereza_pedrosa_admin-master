import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:thereza_pedrosa_admin/contracts/IClick.dart';
import 'package:thereza_pedrosa_admin/contracts/IContinueClicked.dart';
import 'package:thereza_pedrosa_admin/contracts/ISuffixClicked.dart';
import 'package:thereza_pedrosa_admin/contracts/ITextChangedListener.dart';
import 'package:thereza_pedrosa_admin/contracts/ITextClicked.dart';
import 'package:thereza_pedrosa_admin/contracts/ITextFieldClicked.dart';
import 'package:thereza_pedrosa_admin/contracts/ITrailingClicked.dart';
import 'package:url_launcher/url_launcher.dart';

import 'Constants.dart';

class Utils {
  static pushReplacement(BuildContext context, Object targetClass) {
    Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) {
      return targetClass;
    }));
  }

  static push(BuildContext context, Object targetClass) {
    Navigator.push(context, MaterialPageRoute(builder: (context) {
      return targetClass;
    }));
  }

  static showToast({@required String message}) {
    Fluttertoast.showToast(
      msg: message,
      toastLength: Toast.LENGTH_LONG,
      timeInSecForIosWeb: 3,
      gravity: ToastGravity.BOTTOM,
      backgroundColor: Colors.black,
      textColor: Colors.white,
      fontSize: 16.0,
    );
  }

  static loadingContainer() {
    return Container(
      color: Colors.black12,
      child: Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(
            Constants.COLOR_DARK_GREY,
          ),
        ),
      ),
    );
  }

  static errorBody({@required message}) {
    return Container(
      child: Center(
        child: Text(message),
      ),
    );
  }

  static Widget getSearchTextField({
    @required controller,
    @required hint,
    @required textListener,
    @required suffixListener,
    @required family,
  }) {
    return Theme(
      data: ThemeData(
        fontFamily: family,
      ),
      child: TextField(
        onChanged: (val) {
          if (textListener != null)
            (textListener as ITextChangedListener).onTextChanged(val);
        },
        controller: controller,
        decoration: InputDecoration(
          prefixIcon: Icon(
            Icons.search,
            color: Constants.COLOR_DARK_GREY,
          ),
          suffixIcon: suffixListener != null
              ? IconButton(
                  icon: Icon(
                    Icons.filter_list,
                    color: Constants.ACCENT_COLOR,
                  ),
                  onPressed: () {
                    (suffixListener as ISuffixClicked).onSuffixClicked();
                  },
                )
              : null,
          filled: true,
          fillColor: Constants.LIGHT_GREY,
          contentPadding: EdgeInsets.all(12),
          hintText: hint,
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(
              color: Colors.black12,
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(
              color: Colors.black26,
            ),
          ),
        ),
      ),
    );
  }

  static Widget getBorderedTextField({
    @required controller,
    @required hint,
    @required prefix,
    @required isPassword,
    @required isPhone,
    @required enabled,
    @required maxLines,
    @required listener,
    @required family,
    @required type,
  }) {
    return Theme(
      data: ThemeData(
        fontFamily: family,
      ),
      child: TextField(
        cursorColor: Constants.ACCENT_COLOR,
        onTap: () {
          if (listener != null)
            (listener as ITextFieldClicked).onTextFieldClicked(type);
        },
        enabled: enabled,
        maxLines: maxLines,
        controller: controller,
        obscureText: isPassword,
        keyboardType: isPhone ? TextInputType.phone : TextInputType.text,
        decoration: InputDecoration(
          contentPadding: EdgeInsets.all(12),
          labelStyle: TextStyle(
            color: Constants.ACCENT_COLOR,
          ),
          labelText: hint,
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(
              color: Colors.black38,
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(
              color: Colors.black87,
            ),
          ),
          disabledBorder: OutlineInputBorder(
            borderSide: BorderSide(
              color: Colors.black26,
            ),
          ),
          prefix: prefix,
        ),
      ),
    );
  }

  static Widget getBorderedText({
    @required context,
    @required label,
    @required listener,
    @required family,
    @required type,
  }) {
    return GestureDetector(
      onTap: () {
        if (listener != null)
          (listener as ITextFieldClicked).onTextFieldClicked(type);
      },
      child: Container(
        alignment: Alignment.centerLeft,
        height: 45,
        width: Utils.getScreenWidth(context),
        padding: EdgeInsets.all(8),
        decoration: BoxDecoration(
          border: Border.all(
            color: Colors.black54,
          ),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontFamily: family,
            fontSize: 15,
          ),
        ),
      ),
    );
  }

  static Widget getAuthTextField({
    @required controller,
    @required label,
    @required icon,
    @required isPassword,
    @required isPhone,
    @required enabled,
    @required maxLines,
  }) {
    return Theme(
      data: ThemeData(fontFamily: 'Poppins'),
      child: TextField(
        enabled: enabled,
        maxLines: maxLines,
        controller: controller,
        obscureText: isPassword,
        keyboardType: isPhone ? TextInputType.phone : TextInputType.text,
        style: TextStyle(
          color: Colors.white,
        ),
        cursorColor: Colors.white,
        decoration: InputDecoration(
          contentPadding: EdgeInsets.symmetric(vertical: -5),
          labelText: label,
          prefixIcon: icon,
          labelStyle: TextStyle(
            color: Colors.white,
          ),
          enabledBorder: UnderlineInputBorder(
            borderSide: BorderSide(
              color: Colors.white,
            ),
          ),
          focusedBorder: UnderlineInputBorder(
            borderSide: BorderSide(
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }

  static Widget getAppBar({
    @required context,
    @required title,
    @required isLeading,
    @required family,
    @required leadingObject,
  }) {
    return AppBar(
      backgroundColor: Colors.white,
      iconTheme: IconThemeData(
        color: Colors.black,
      ),
      title: Text(
        title,
        style: TextStyle(
          color: Colors.black,
          fontFamily: family,
        ),
      ),
      centerTitle: true,
      leading: isLeading
          ? IconButton(
              icon: Icon(
                Icons.arrow_back,
              ),
              onPressed: () {
                Utils.pushReplacement(context, leadingObject);
              },
            )
          : null,
    );
  }

  static Widget getAppBarWithTrailing({
    @required context,
    @required title,
    @required isLeading,
    @required leadingObject,
    @required trailingIcon,
    @required family,
    @required ITrailingClicked iTrailingClicked,
  }) {
    return AppBar(
      backgroundColor: Colors.white,
      iconTheme: IconThemeData(
        color: Colors.black,
      ),
      title: Text(
        title,
        style: TextStyle(
          color: Colors.black,
          fontFamily: family,
        ),
      ),
      centerTitle: true,
      leading: isLeading
          ? IconButton(
              icon: Icon(
                Icons.arrow_back,
              ),
              onPressed: () {
                Utils.pushReplacement(context, leadingObject);
              },
            )
          : null,
      actions: [
        IconButton(
          icon: Icon(trailingIcon),
          onPressed: () {
            iTrailingClicked.onTrailingClicked();
          },
        ),
      ],
    );
  }

  static double getScreenWidth(BuildContext context) {
    return MediaQuery.of(context).size.width;
  }

  static double getScreenHeight(BuildContext context) {
    return MediaQuery.of(context).size.height;
  }

  static SizedBox getSizedBox({
    @required double boxHeight,
    @required double boxWidth,
  }) {
    return SizedBox(
      height: boxHeight,
      width: boxWidth,
    );
  }

  static Widget getClickableField({
    @required String label,
    @required String key,
    @required String family,
    @required ITextClicked iTextClicked,
  }) {
    return GestureDetector(
      onTap: () {
        iTextClicked.onTextClicked(key);
      },
      child: Text(
        label,
        style: TextStyle(
          fontFamily: family,
          fontWeight: FontWeight.bold,
          color: Colors.white,
          decoration: TextDecoration.underline,
        ),
      ),
    );
  }

  static Widget getDivider() {
    return Divider(
      color: Colors.black54,
    );
  }

  static Widget getOrDivider() {
    return Row(
      children: [
        Expanded(
          child: Divider(
            thickness: 1,
            color: Colors.black54,
          ),
        ),
        Text(
          ' OR  ',
          style: TextStyle(
            fontSize: 17,
          ),
        ),
        Expanded(
          child: Divider(
            thickness: 1,
            color: Colors.black54,
          ),
        ),
      ],
    );
  }

  static Widget getBorderedButton(
    BuildContext context,
    String label,
    String family,
    IClick iClick,
    Color color,
  ) {
    return Container(
      width: getScreenWidth(context),
      child: FlatButton(
        shape: RoundedRectangleBorder(
          side: BorderSide(
            color: color,
          ),
        ),
        onPressed: () {
          iClick.onClick();
        },
        child: Text(
          label,
          style: TextStyle(
            fontFamily: family,
            color: color,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  static Widget getClickAbleTextRow(
      int index, String label, List<String> list) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: Text(
            label,
            style: TextStyle(
              fontSize: 17,
            ),
          ),
        ),
        Expanded(
          child: GestureDetector(
            onTap: () {
              //TODO: take user to more screen
            },
            child: Text(
              'View More',
              textAlign: TextAlign.end,
              style: TextStyle(
                decoration: TextDecoration.underline,
                color: Colors.black54,
              ),
            ),
          ),
        ),
      ],
    );
  }

  static Widget getHeader({
    @required context,
    @required title,
    @required imageString,
  }) {
    return Container(
      margin: EdgeInsets.only(bottom: 16),
      height: getScreenHeight(context) / 4,
      width: getScreenWidth(context),
      decoration: BoxDecoration(
        image: DecorationImage(
          image: AssetImage(imageString),
          fit: BoxFit.cover,
        ),
      ),
      child: Stack(
        children: [
          Container(
            height: getScreenHeight(context) / 4,
            width: getScreenWidth(context),
            color: Colors.black26,
          ),
          Center(
            child: Text(
              title,
              style: TextStyle(
                color: Colors.white,
                fontSize: 19,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Container(
            alignment: AlignmentDirectional.topStart,
            margin: EdgeInsets.only(top: 24),
            child: IconButton(
              icon: Icon(
                Icons.arrow_back,
                color: Colors.white,
              ),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
          ),
        ],
      ),
    );
  }

  static void showInfoDialog({
    @required BuildContext context,
    @required String title,
    @required String message,
    @required IContinueClicked iDeleteClicked,
  }) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          FlatButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: Text('Cancel'),
          ),
          FlatButton(
            onPressed: () {
              Navigator.pop(context);
              iDeleteClicked.onContinueClicked();
            },
            child: Text(
              'Continue',
            ),
          ),
        ],
      ),
    );
  }

  static Future<void> launchURL(String url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }
}
