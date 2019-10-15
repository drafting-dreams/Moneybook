import 'package:flutter/material.dart';
import 'package:money_book/api/account.dart';
import 'package:money_book/api/bill.dart';
import 'package:money_book/api/expense_type.dart';
import 'package:money_book/api/transaction.dart';
import 'package:money_book/api/theme.dart';
import 'package:money_book/model/account.dart';
import 'package:money_book/shared_state/account.dart';
import 'package:money_book/shared_state/expense_type_info.dart';
import 'package:money_book/shared_state/transactions.dart';
import 'package:money_book/shared_state/theme.dart';
import 'package:money_book/widget/no_animation_route.dart';
import 'package:money_book/screens/account_screen.dart';
import 'package:money_book/screens/expense_type_setting_screen.dart';
import 'package:money_book/widget/bottom_navigator.dart';
import 'package:money_book/widget/radio_dialog.dart';
import 'package:provider/provider.dart';
import 'package:sqflite_porter/sqflite_porter.dart';
import 'package:money_book/localDB/database_creator.dart';
import 'package:money_book/utils/file_util.dart';
import 'package:money_book/widget/simple_information_dialog.dart'
    as simpleDialog;
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:money_book/model/transaction.dart' as myTransaction;
import 'package:money_book/const/themes.dart';
import 'package:money_book/locale/locales.dart';

Map<String, Widget> items(BuildContext context) {
  return {
    'local': Text(AppLocalizations.of(context).locally),
    'dropbox': Text('Dropbox'),
    'onedrive': Text('OneDrive'),
    'googledrive': Text('GoogleDrive')
  };
}

Map<String, Widget> themeItems(BuildContext context) {
  final localizer = AppLocalizations.of(context);
  return {
    'alien blue': Text(localizer.blue),
    'tree': Text(localizer.green),
    'pony': Text(localizer.pony),
    'noble purple': Text(localizer.purple),
    'chocolate': Text(localizer.chocolate),
    'dark': Text(localizer.dark)
  };
}

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

  Widget renderTile(BuildContext context, String text, IconData icon,
          Function handleTap) =>
      InkWell(
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

  Widget renderHeader(BuildContext context, String title) => Container(
        decoration: BoxDecoration(color: Theme.of(context).dividerColor),
        child: Row(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
              child: Text(title, style: TextStyle(fontSize: 16)),
            )
          ],
        ),
      );

  Future importBackup(
      BuildContext context,
      String contents,
      Transactions transactions,
      ExpenseTypeInfo expenseType,
      AccountState accountState,
      ThemeChanger themeChanger) async {
    final localizer = AppLocalizations.of(context);
    final databasePath = await getDatabasesPath();
    final path = join(databasePath, DatabaseCreator.dbName);
    db.close();
    await deleteDatabase(path);
    db = await openDatabase(path,
        version: 1, onCreate: DatabaseCreator().onCreate);
    List<String> listString = contents.split('^^^');
    dbImportSql(db, listString).then((v) {
      ThemeAPI.getUsing().then((theme) {
        themeChanger.setTheme(theme, getTheme(theme));
      });
      ExpenseTypeAPI.list().then((types) {
        expenseType.clear();
        expenseType.addAll(types);
      });
      AccountAPI.getCurrentAccount().then((Account account) {
        accountState.setCurrentAccount(account);
        final now = DateTime.now();
        final nextMonth = now.month == 12
            ? DateTime(now.year + 1, now.month, 1)
            : DateTime(now.year, now.month + 1, 1);
        TransactionAPI.loadPrevious(account.id, nextMonth).then((ts) {
          transactions.clear();
          transactions.addAll(ts);
        });
      });
      BillAPI.getPreviousUnpaidBills().then((unpaidBills) {
        if (unpaidBills.length > 0) {
          for (var b in unpaidBills) {
            myTransaction.Transaction t = myTransaction.Transaction(
                b.value, b.dueDate, b.accountId,
                type: b.type, name: b.name);
            BillAPI.pay(b.id, t);
            transactions.add(t);
          }
          showDialog(
              context: context,
              barrierDismissible: true,
              builder: (context) => AlertDialog(
                    title: Text(localizer.autoPayNotification),
                    content: Text(localizer.autoPayNotificationMessage),
                    actions: <Widget>[
                      FlatButton(
                        child: Text(localizer.gotIt),
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                      )
                    ],
                  ));
        }
      });
      simpleDialog.showSimpleDialog(
          context, localizer.importSuccess, localizer.importSuccessMessage);
    });
  }

  @override
  Widget build(BuildContext context) {
    var transactions = Provider.of<Transactions>(context);
    var accountState = Provider.of<AccountState>(context);
    var expenseTypeInfo = Provider.of<ExpenseTypeInfo>(context);
    var themeChanger = Provider.of<ThemeChanger>(context);
    final localizer = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(title: Text(AppLocalizations.of(context).settings)),
      bottomNavigationBar: BottomNavigator(
        initialIndex: 3,
      ),
      body: ListView(
        children: <Widget>[
          renderHeader(context, AppLocalizations.of(context).general),
          renderTile(
              context, AppLocalizations.of(context).accounts, Icons.account_box,
              () {
            Navigator.push(
                context,
                NoAnimationMaterialPageRoute(
                    builder: (BuildContext context) => AccountScreen()));
          }),
          renderTile(
              context, AppLocalizations.of(context).expenseType, Icons.category,
              () {
            Navigator.push(
                context,
                NoAnimationMaterialPageRoute(
                    builder: (BuildContext context) =>
                        ExpenseTypeSettingScreen()));
          }),
          renderHeader(context, AppLocalizations.of(context).theme),
          renderTile(
              context, AppLocalizations.of(context).theme, Icons.remove_red_eye,
              () {
            showRadioDialog(context, AppLocalizations.of(context).theme,
                    themeItems(context), themeChanger.themeName)
                .then((theme) {
              themeChanger.setTheme(theme, getTheme(theme));
              ThemeAPI.setTheme(theme);
            });
          }),
          renderHeader(context, AppLocalizations.of(context).backup),
          renderTile(context, AppLocalizations.of(context).backup, Icons.backup,
              () {
            showRadioDialog(context, AppLocalizations.of(context).backup,
                    items(context), '')
                .then((method) async {
              switch (method) {
                case 'local':
                  dbExportSql(db).then((listString) {
                    String str = listString
                        .where((s) => !s.startsWith('CREATE'))
                        .join('^^^');
                    utilizer.writeTo('.moneybookbackup', str).then((f) {
                      simpleDialog.showSimpleDialog(
                          context,
                          localizer.backupSuccess,
                          '${localizer.backupMessage}${f.path}');
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
          renderTile(context, AppLocalizations.of(context).import,
              Icons.cloud_download, () {
            showRadioDialog(context, AppLocalizations.of(context).import,
                    items(context), '')
                .then((method) {
              switch (method) {
                case 'local':
                  showDialog(
                      context: context,
                      barrierDismissible: true,
                      builder: (context) => AlertDialog(
                            title: Text(AppLocalizations.of(context).import),
                            content: Text(localizer.confirmImport),
                            actions: <Widget>[
                              FlatButton(
                                  onPressed: () {
                                    Navigator.of(context).pop(1);
                                  },
                                  child: Text(localizer.yes)),
                              FlatButton(
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                  },
                                  child: Text(localizer.no))
                            ],
                          )).then((answer) {
                    if (answer == 1) {
                      utilizer.readFrom('.moneybookbackup').then((contents) {
                        importBackup(context, contents, transactions,
                            expenseTypeInfo, accountState, themeChanger);
                      }).catchError((error) async {
                        final localPath = await utilizer.localPath;
                        simpleDialog.showSimpleDialog(
                            context,
                            localizer.importFailed,
                            '${localizer.importFailedMessage1}$localPath${localizer.importFailedMessage2}');
                      });
                    }
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
          })
        ],
      ),
    );
  }
}
