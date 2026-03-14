import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import 'package:socket_io_client/socket_io_client.dart' as io;

import '../ui/chat/model/res_ticket_status.dart';
import '../ui/chat/model/res_transaction_details_with_user.dart';
import '../ui/chat/provider/chat_provider.dart';
import '../ui/profile/supportTickets/model/res_support_ticket_old_messages.dart';
import '../ui/profile/supportTickets/provider/support_chat_provider.dart';
import '../utils/app_config.dart';
import '../utils/preference_key.dart';
import '../utils/preference_utils.dart';
import 'socket_constants.dart';

io.Socket? _socketInstance;
BuildContext? buildContext;

void initSocketManager(BuildContext context) {
  buildContext = context;
  _socketInstance = io.io(
    "$socketUrl?authorization=${getString(PreferenceKey.token)}",
    <String, dynamic>{
      'transports': ['websocket', "polling"],
    },
  );
  _socketInstance?.connect();
  socketGlobalListeners();
}

void reInitializeAndConnectSocket() {
  disconnectSocket();
  if (buildContext != null) {
    initSocketManager(buildContext!);
  }
}

void disconnectSocket() {
  _socketInstance?.clearListeners();
  _socketInstance?.disconnect();
}

void socketGlobalListeners() {
  _socketInstance?.on(eventConnect, onConnect);
  _socketInstance?.on(eventDisconnect, onDisconnect);
  _socketInstance?.on(onSocketError, onConnectError);
  _socketInstance?.on(eventConnectTimeout, onConnectError);
  _socketInstance?.on(emitReceiveMessage, handleReceivedMessage);
  _socketInstance?.on(receiveOldMessages, handleReceivedOldMessagesList);
  _socketInstance?.on(emitReceiveUserMessage, handleReceiveUserMessage);
  _socketInstance?.on(
      receiveChangeTicketStatus, handleReceiveChangeTicketStatus);
}

void deInitialize() {
  disconnectSocket();
  _socketInstance = null;
}

bool isConnected() {
  return _socketInstance?.connected ?? false;
}

bool emit(String event, Map<String, dynamic> data) {
  _socketInstance?.emit(event, jsonDecode(json.encode(data)));
  return _socketInstance?.connected ?? false;
}

void on(String event, void Function(dynamic) fn) {
  _socketInstance?.on(event, fn);
}

void off(String event, [void Function(dynamic)? fn]) {
  _socketInstance?.off(event, fn);
}

dynamic onConnect(_) {
  debugPrint("connected socket....................");
}

dynamic onDisconnect(_) {
  debugPrint("Disconnected socket....................");
}

dynamic onConnectError(error) {
  debugPrint("ConnectError socket.................... $error");
}

void handleReceivedMessage(dynamic msg) {
  final ctx = buildContext;
  if (ctx == null) return;
  Provider.of<SupportChatProvider>(ctx, listen: false)
      .addMessage(SupportChatMessage.fromJson(msg));
}

void handleReceivedOldMessagesList(dynamic msg) {
  final ctx = buildContext;
  if (ctx == null) return;
  final provider = Provider.of<SupportChatProvider>(ctx, listen: false);
  try {
    final data = ResSupportTicketOldMessage.fromJson(msg);
    provider.setList(data.result?.message ?? <SupportChatMessage>[]);
    provider.setIsTicketClosed(data.result?.ticketDetails?.status ?? '');
  } catch (_) {
    provider.setLoading(false);
  }
}

void handleReceiveUserMessage(dynamic msg) {
  final data = ResTransactionDetailsItem.fromJson(msg);
  final ctx = buildContext;
  if (ctx == null) return;
  Provider.of<ChatProvider>(ctx, listen: false).addMessage(data);
}

void handleReceiveChangeTicketStatus(dynamic msg) {
  final data = ResTicketStatus.fromJson(msg);
  final ctx = buildContext;
  if (ctx == null) return;
  Provider.of<SupportChatProvider>(ctx, listen: false)
      .setIsTicketClosed(data.status ?? '');
}
