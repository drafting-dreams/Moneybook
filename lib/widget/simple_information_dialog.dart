import 'package:flutter/material.dart';
import 'package:money_book/locale/locales.dart';

Future showSimpleDialog(BuildContext context, String title, String content) =>
    showDialog(
        context: context,
        barrierDismissible: true,
        builder: (context) => AlertDialog(
              title: Text(title),
              content: Text(content),
              actions: <Widget>[
                FlatButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: Text(AppLocalizations.of(context).ok))
              ],
            ));
