import 'package:flutter/material.dart';
import 'package:money_book/widget/no_animation_route.dart';
import 'package:money_book/screens/account_screen.dart';
import 'package:money_book/screens/expense_type_setting_screen.dart';
import 'package:money_book/widget/bottom_navigator.dart';
import 'package:money_book/widget/radio_dialog.dart';
import 'package:sqflite_porter/sqflite_porter.dart';
import 'package:money_book/localDB/database_creator.dart';
import 'package:money_book/utils/file_util.dart';
import 'package:money_book/widget/simple_information_dialog.dart'
    as simpleDialog;

class SettingScreen extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _SettingScreenState();
  }
}

class _SettingScreenState extends State<SettingScreen> {
  FileUtil utilizer;

  initState() {
    super.initState();
    this.utilizer = FileUtil();
  }

  Widget renderTile(String text, IconData icon, Function handleTap) => InkWell(
      onTap: () {
        handleTap();
      },
      child: ListTile(
        title: Row(
          children: <Widget>[
            Container(
                width: 28,
                margin: EdgeInsets.only(right: 20),
                child: Icon(
                  icon,
                  color: Theme.of(context).accentColor,
                )),
            Text(
              text,
            )
          ],
        ),
      ));

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Settings')),
      bottomNavigationBar: BottomNavigator(
        initialIndex: 3,
      ),
      body: ListView(
        children: <Widget>[
          renderTile('Accounts', Icons.account_box, () {
            Navigator.push(
                context,
                NoAnimationMaterialPageRoute(
                    builder: (BuildContext context) => AccountScreen()));
          }),
          renderTile('Expense Type', Icons.category, () {
            Navigator.push(
                context,
                NoAnimationMaterialPageRoute(
                    builder: (BuildContext context) =>
                        ExpenseTypeSettingScreen()));
          }),
          renderTile('Back up', Icons.backup, () {
            final Map<String, Widget> items = {
              'local': Text('Locally'),
              'dropbox': Text('Dropbox'),
              'onedrive': Text('OneDrive'),
              'googledrive': Text('GoogleDrive')
            };
            showRadioDialog(context, 'Backup', items, '').then((method) async {
              switch (method) {
                case 'local':
                  dbExportSql(db).then((listString) {
                    String str = listString.join('^^^');
                    utilizer.writeTo('.moneybookbackup', str).then((f) {
                      simpleDialog.showSimpleDialog(context, 'Backup Success',
                          'Backup file was saved at ${f.path}');
                    });
                  });
                  break;
                case 'dropbox':
                  break;
                case 'onedrive':
                  break;
                case 'googledrive':
                  break;
              }
            });
          }),
        ],
      ),
    );
  }
}
