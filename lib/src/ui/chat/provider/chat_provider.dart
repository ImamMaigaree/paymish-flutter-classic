import 'dart:collection';

import 'package:collection/collection.dart';
import 'package:flutter/material.dart';

import '../model/res_transaction_details_with_user.dart';

class ChatProvider extends ChangeNotifier {
  List<ResTransactionDetailsItem> _list = [];
  int userId = 0;
  bool isScreenOpen = false;

  Map<String, List<ResTransactionDetailsItem>> get list {
    final dateGroupedList =
        groupBy<ResTransactionDetailsItem, String>(_list, (message) {
      final createdAt = message.createdAt;
      final time = createdAt == null
          ? DateTime.now()
          : DateTime.tryParse(createdAt) ?? DateTime.now();
      return "${time.day}-${time.month}-${time.year} ";
    });
    final groupedList =
        LinkedHashMap.fromEntries(dateGroupedList.entries.toList().reversed);
    return groupedList;
  }

  void setList(List<ResTransactionDetailsItem> chatList) {
    final temp = _list;
    _list = [];
    _list.addAll(chatList);
    _list.addAll(temp);
    notifyListeners();
  }

  void addMessage(ResTransactionDetailsItem message) {
    _list.add(message);
    notifyListeners();
  }

  void clearAllMessages() {
    _list.clear();
    notifyListeners();
  }
}
