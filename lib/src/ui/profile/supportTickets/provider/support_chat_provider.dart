import 'dart:collection';

import 'package:collection/collection.dart';
import 'package:flutter/material.dart';

import '../../../../apis/dic_params.dart';
import '../model/res_support_ticket_old_messages.dart';

class SupportChatProvider extends ChangeNotifier {
  List<SupportChatMessage> _list = <SupportChatMessage>[];
  bool _isTicketClosed = false;
  int ticketId = 0;
  bool isScreenOpen = false;
  ValueNotifier<bool> isLoading = ValueNotifier<bool>(false);

  Map<String, List<SupportChatMessage>> get list {
    final dateGroupedList =
        groupBy<SupportChatMessage, String>(_list, (message) {
      final time =
          DateTime.tryParse(message.createdAt ?? '') ?? DateTime.now();
      return "${time.day}-${time.month}-${time.year} ";
    });
    final groupedList =
        LinkedHashMap.fromEntries(dateGroupedList.entries.toList().reversed);
    return groupedList;
  }

  void setList(List<SupportChatMessage> chatList) {
    final temp = _list;
    _list = <SupportChatMessage>[];
    _list.addAll(chatList);
    _list.addAll(temp);
    isLoading = ValueNotifier<bool>(false);
    notifyListeners();
  }

  void setIsTicketClosed(String ticketStatus) {
    if (ticketStatus == DicParams.close) {
      _isTicketClosed = true;
    } else {
      _isTicketClosed = false;
    }
    notifyListeners();
  }

  bool get isTicketClosed {
    return _isTicketClosed;
  }

  void addMessage(SupportChatMessage message) {
    _list.add(message);
    notifyListeners();
  }

  void clearAllMessages() {
    _list.clear();
    notifyListeners();
  }
}
