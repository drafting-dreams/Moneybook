import 'package:flutter/material.dart';

Future<void> paySuccessfulDialog(BuildContext context, String message) async {
  return showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) => AlertDialog(
            title: Text('Bill paid'),
            content: Text(message),
            actions: <Widget>[
              FlatButton(
                child: Text('OK'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              )
            ],
          ));
}
