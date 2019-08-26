import 'package:flutter/material.dart';

class MultiSelectChip extends StatefulWidget {
  final List<String> reportList;
  final List<String> initialList;

  MultiSelectChip(this.reportList, {this.initialList, Key key})
      : super(key: key);

  @override
  MultiSelectChipState createState() => MultiSelectChipState();
}

class MultiSelectChipState extends State<MultiSelectChip> {
  List<String> selectedChoice = [];

  initState() {
    super.initState();
    if (this.widget.initialList != null) {
      setState(() {
        this.selectedChoice = List.from(this.widget.initialList);
      });
    }
  }

  // this function will build and return the choice list
  _buildChoiceList() {
    List<Widget> choices = List();
    widget.reportList.forEach((item) {
      choices.add(Container(
        padding: const EdgeInsets.all(2.0),
        child: ChoiceChip(
          label: Text(item),
          selected: selectedChoice.contains(item),
          onSelected: (selected) {
            setState(() {
              if (selectedChoice.contains(item)) {
                selectedChoice.remove(item);
              } else {
                selectedChoice.add(item);
              }
            });
          },
        ),
      ));
    });
    return choices;
  }

  @override
  Widget build(BuildContext context) {
    return Wrap(
      children: _buildChoiceList(),
    );
  }
}
