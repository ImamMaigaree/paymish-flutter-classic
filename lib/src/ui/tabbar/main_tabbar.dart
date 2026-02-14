import 'package:flutter/material.dart';

import '../../utils/color_utils.dart';
import '../../utils/dimens.dart';
import '../../utils/image_constants.dart';
import '../../utils/localization/localization.dart';
import '../../utils/preference_key.dart';
import '../../utils/preference_utils.dart';
import '../../widgets/user_not_found.dart';
import '../auth/home/home_screen.dart';
import '../profile/wallet/addtowallet/add_money_to_wallet.dart';
import '../profile/wallet/my_wallet.dart';
import '../requestmoney/request_money.dart';
import '../transfermoney/transfer_money.dart';

class MainTabBar extends StatefulWidget {
  const MainTabBar({Key? key}) : super(key: key);

  @override
  _MainTabBarState createState() => _MainTabBarState();
}

class _MainTabBarState extends State<MainTabBar> {
  final List<Widget> _children = [
    const HomeScreen(),
    AddMoneyToWallet(
      isFromBottomNavigation: true,
    ),
    const MyWalletScreen(
      isFromBottomNavigation: true,
    ),
    const RequestMoneyScreen(),
    const TransferMoneyScreen(
      showBackButton: false,
    ),
  ];

  final ValueNotifier<int> _currentIndex = ValueNotifier<int>(0);

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<int>(
      valueListenable: _currentIndex,
      builder: (context, currentIndex, _) => Scaffold(
        body: ((getInt(PreferenceKey.isApprovedByAdmin) == 0) &&
                (_currentIndex.value != 0))
            ? const UserNotVerfied()
            : _children[currentIndex],
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: currentIndex,
          backgroundColor: ColorUtils.tabBackgroundColor,
          type: BottomNavigationBarType.shifting,
          onTap: (index) {
            _currentIndex.value = index;
          },
          selectedFontSize: fontSmall,
          selectedItemColor: ColorUtils.primaryColor,
          unselectedItemColor: Colors.black,
          showUnselectedLabels: true,
          items: [
            _getBottomNavigationBarItem(
                title: Localization.of(context).labelMainTabHome,
                icon: ImageConstants.icHome,
                isSelected: currentIndex == 0),
            _getBottomNavigationBarItem(
                title: Localization.of(context).labelMainTabAddMoney,
                icon: ImageConstants.icAddMoney,
                isSelected: currentIndex == 1),
            _getBottomNavigationBarItem(
                title: Localization.of(context).labelMainTabWallet,
                icon: ImageConstants.icWallet,
                isSelected: currentIndex == 2),
            _getBottomNavigationBarItem(
                title: Localization.of(context).labelMainTabRequestMoney,
                icon: ImageConstants.icRequestMoney,
                isSelected: currentIndex == 3),
            _getBottomNavigationBarItem(
                title: Localization.of(context).labelMainTabTransferMoney,
                icon: ImageConstants.icTransferMoney,
                isSelected: currentIndex == 4),
          ],
        ),
      ),
    );
  }

  BottomNavigationBarItem _getBottomNavigationBarItem(
      {required String icon,
      required String title,
      required bool isSelected}) {
    return BottomNavigationBarItem(
      icon: Image.asset(
        icon,
        color: isSelected ? ColorUtils.primaryColor : Colors.black,
        height: 21.0,
        width: 21.0,
      ),
      label: title,
    );
  }
}
