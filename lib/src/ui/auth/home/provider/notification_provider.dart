import 'package:flutter/cupertino.dart';

import '../model/res_notification.dart';

class NotificationProvider extends ChangeNotifier {
  NotificationProvider();

  List<NotificationListData> _list = <NotificationListData>[];

  List<NotificationListData> getList() => _list;

  void removeNotificationFrom(List<NotificationListData> notificationList,
      NotificationListData notificationDetail) {
    _list = notificationList;
    _list.remove(notificationDetail);
    notifyListeners();
  }

}
