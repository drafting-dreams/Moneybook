import 'package:flutter/material.dart';
import 'package:money_book/locale/locales.dart';

Future<void> paySuccessfulDialog(BuildContext context, String message) async {
  final localizer = AppLocalizations.of(context);
  return showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) => AlertDialog(
            title: Text(localizer.billPaid),
            content: Text(message),
            actions: <Widget>[
              FlatButton(
                child: Text(localizer.ok),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              )
            ],
          ));
}
