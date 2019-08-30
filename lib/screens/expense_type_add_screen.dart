import 'package:flutter/material.dart';
import 'package:money_book/api/expense_type.dart';

const icons = {
  'Housing': {
    'color': Colors.indigoAccent,
    'icons': [
      Icons.business,
      Icons.home,
      Icons.whatshot,
      Icons.power,
      Icons.offline_bolt,
      Icons.opacity,
      Icons.invert_colors,
      Icons.lightbulb_outline,
      Icons.format_paint,
      Icons.build,
      Icons.settings,
      Icons.local_hotel,
      Icons.event_seat,
      Icons.weekend
    ]
  },
  'Commuting': {
    'color': Colors.orangeAccent,
    'icons': [
      Icons.airplanemode_active,
      Icons.airport_shuttle,
      Icons.directions_bus,
      Icons.motorcycle,
      Icons.directions_bike,
      Icons.directions_boat,
      Icons.directions_car,
      Icons.local_taxi,
      Icons.local_shipping,
      Icons.directions_subway,
      Icons.local_gas_station,
      Icons.local_parking,
      Icons.directions_run
    ]
  },
  'Food': {
    'color': Colors.redAccent,
    'icons': [
      Icons.fastfood,
      Icons.free_breakfast,
      Icons.local_bar,
      Icons.local_drink,
      Icons.local_dining,
      Icons.restaurant,
      Icons.room_service,
      Icons.cake,
      Icons.local_pizza
    ]
  },
  'Shopping': {
    'color': Colors.deepPurpleAccent,
    'icons': [
      Icons.shopping_cart,
      Icons.shopping_basket,
      Icons.local_mall,
      Icons.redeem,
      Icons.credit_card,
      Icons.kitchen,
      Icons.store
    ]
  },
  'Digital': {
    'color': Colors.teal,
    'icons': [
      Icons.laptop_chromebook,
      Icons.desktop_mac,
      Icons.devices,
      Icons.phone_android,
      Icons.headset,
      Icons.camera_alt
    ]
  },
  'Individual': {
    'color': Colors.brown,
    'icons': [Icons.work, Icons.call, Icons.mail_outline, Icons.smoking_rooms]
  },
  'Education': {
    'color': Colors.cyan,
    'icons': [
      Icons.account_balance,
      Icons.location_city,
      Icons.import_contacts,
      Icons.school,
      Icons.color_lens,
      Icons.edit
    ]
  },
  'Entertainment': {
    'color': Colors.amber,
    'icons': [
      Icons.videogame_asset,
      Icons.album,
      Icons.audiotrack,
      Icons.videocam,
      Icons.local_movies
    ]
  },
  'Travel': {
    'color': Colors.cyanAccent,
    'icons': [
      Icons.landscape,
      Icons.beach_access,
      Icons.crop_original,
      Icons.flight_takeoff,
      Icons.public,
      Icons.room,
      Icons.explore
    ]
  },
  'Exercising': {
    'color': Colors.lightGreenAccent,
    'icons': [Icons.fitness_center, Icons.pool]
  },
  'Family': {
    'color': Colors.pinkAccent,
    'icons': [
      Icons.child_friendly,
      Icons.child_care,
      Icons.wc,
      Icons.pregnant_woman
    ]
  },
  'Medical': {
    'color': Colors.red,
    'icons': [Icons.local_hospital]
  },
  'Others': {
    'color': Colors.yellow,
    'icons': [Icons.attach_money, Icons.monetization_on, Icons.style]
  }
};

class ExpenseTypeAddScreen extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _ExpenseTypeAddScreen();
  }
}

class _ExpenseTypeAddScreen extends State<ExpenseTypeAddScreen> {
  List<String> types = [];

  void initState() {
    super.initState();
    loadData();
  }

  void loadData() {
    ExpenseTypeAPI.list().then((data) {
      setState(() {
        types = data;
      });
    });
  }

  List<Widget> _build() {
    final List<Widget> re = [];
    icons.forEach((k, v) {
      re.add(_buildBlock(k, v));
    });
    return re;
  }

  Widget _buildBlock(String title, Map iconInfo) {
    Color color = iconInfo['color'];
    List<IconData> icons = iconInfo['icons'];
    List<List<IconData>> groupByFour = [];

    for (int i = 0; i < icons.length; i += 4) {
      groupByFour
          .add(icons.sublist(i, i + 4 > icons.length ? icons.length : i + 4));
    }

    return Container(
        child: Column(children: [
      Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              title,
              style: TextStyle(fontSize: 18),
            )
          ],
        ),
      ),
      ...groupByFour.map((datas) => _buildIconRow(datas, color)).toList()
    ]));
  }

  Widget _buildIconRow(List<IconData> datas, Color color) {
    List<Widget> icons = datas
        .map((data) => Opacity(opacity:1, child:RawMaterialButton(
              onPressed: () {},
              constraints: BoxConstraints(minWidth: 45, minHeight: 45),
              shape: CircleBorder(),
              child: Icon(
                data,
                color: Colors.white,
              ),
              fillColor: color,
            )))
        .toList();
    int len = icons.length;
    if (icons.length < 4) {
      for (int i = 0; i < 4 - len; i++) {
        icons.add(Opacity(
            opacity: 0,
            child: RawMaterialButton(
              onPressed: () {},
              constraints: BoxConstraints(minWidth: 45, minHeight: 45),
              shape: CircleBorder(),
              child: Container(),
              fillColor: color,
            )));
      }
    }
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 7),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: icons,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: Text('Add Expense Type')),
        body: ListView(
          children: <Widget>[
            Column(
              children: _build(),
            )
          ],
        ));
  }
}
