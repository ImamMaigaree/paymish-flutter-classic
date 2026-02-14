import 'package:flutter/material.dart';

import '../model/res_home.dart';

class HomeScreenProvider extends ChangeNotifier {
  // Notification Count over bell icon in User home screen
  int _notificationCount = 0;
  List<Contacts> _homeScreenData = <Contacts>[];

  int getNotificationCount() => _notificationCount;

  List<Contacts> getHomeData() => _homeScreenData;

  void setNotificationCount(int index) {
    _notificationCount = index;
    notifyListeners();
  }

  void setHomeData(List<Contacts> data) {
    _homeScreenData = data;
    notifyListeners();
  }
}
