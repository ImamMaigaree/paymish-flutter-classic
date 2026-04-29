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

  List<SupportChatMessage> get messages => List<SupportChatMessage>.from(_list);

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
    isLoading.value = false;
    notifyListeners();
  }

  void setLoading(bool value) {
    isLoading.value = value;
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

  void replaceMessages(List<SupportChatMessage> chatList) {
    _list = List<SupportChatMessage>.from(chatList);
    isLoading.value = false;
    notifyListeners();
  }

  void mergeNewMessages(List<SupportChatMessage> chatList) {
    final existingIds = _list.map((e) => e.id).whereType<int>().toSet();
    final incoming = chatList.where((message) {
      final id = message.id;
      return id == null || !existingIds.contains(id);
    }).toList();
    if (incoming.isNotEmpty) {
      _list.addAll(incoming);
      notifyListeners();
    }
  }

  void prependOlderMessages(List<SupportChatMessage> chatList) {
    final existingIds = _list.map((e) => e.id).whereType<int>().toSet();
    final incoming = chatList.where((message) {
      final id = message.id;
      return id == null || !existingIds.contains(id);
    }).toList();
    if (incoming.isNotEmpty) {
      _list.insertAll(0, incoming);
      notifyListeners();
    }
  }
}
