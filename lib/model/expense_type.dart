import 'package:flutter/material.dart';
import 'package:money_book/localDB/database_creator.dart';
import 'package:money_book/const/icons.dart';

class ExpenseType {
  String name;
  IconData icon;
  Color color;

  ExpenseType(String name, String icon, String color) {
    final iconDatas = [];
    final colors = [];
    
    icons.forEach((_, v) {
      colors.add(v['color']);
      iconDatas.addAll(v['icons']);
    });

    for(int i=0; i<iconDatas.length; i++) {
      if (icon == iconDatas[i].toString()) {
        this.icon = iconDatas[i];
        break;
      }
    }
    for(int i=0; i<colors.length; i++) {
      if (color == colors[i].toString()) {
        this.color = colors[i];
      }
    }
    this.name = name;
  }

  ExpenseType.fromJson(Map<String, dynamic> json) {
    final name = json[DatabaseCreator.expenseTypeName];
    final icon = json[DatabaseCreator.expenseTypeIcon];
    final color = json[DatabaseCreator.expenseTypeColor];
    final iconDatas = [];
    final colors = [];

    icons.forEach((_, v) {
      colors.add(v['color']);
      iconDatas.addAll(v['icons']);
    });

    for(int i=0; i<iconDatas.length; i++) {
      if (icon == iconDatas[i].toString()) {
        this.icon = iconDatas[i];
        break;
      }
    }
    for(int i=0; i<colors.length; i++) {
      if (color == colors[i].toString()) {
        this.color = colors[i];
      }
    }
    this.name = name;
  }
}