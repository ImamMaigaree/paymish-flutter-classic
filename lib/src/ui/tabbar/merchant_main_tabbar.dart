import 'package:flutter/material.dart';

import '../../utils/color_utils.dart';
import '../../utils/dimens.dart';
import '../../utils/image_constants.dart';
import '../../utils/localization/localization.dart';
import '../../utils/preference_key.dart';
import '../../utils/preference_utils.dart';
import '../../widgets/user_not_found.dart';
import '../auth/home/merchant_home_screen.dart';
import '../profile/supportTickets/support_tickets.dart';
import '../profile/wallet/my_wallet.dart';
import '../requestmoney/request_money.dart';

class MerchantMainTabBar extends StatelessWidget {
  MerchantMainTabBar({Key? key}) : super(key: key);
  final List<Widget> _children = [
    const MerchantHomeScreen(),
    const MyWalletScreen(isFromBottomNavigation: true),
    const RequestMoneyScreen(),
    const SupportTicketsScreen(),
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
                title: Localization.of(context).labelMainTabWallet,
                icon: ImageConstants.icWallet,
                isSelected: currentIndex == 1),
            _getBottomNavigationBarItem(
                title: Localization.of(context).labelMainTabRequestMoney,
                icon: ImageConstants.icRequestMoney,
                isSelected: currentIndex == 2),
            _getBottomNavigationBarItem(
                title: Localization.of(context).supportTicket,
                icon: ImageConstants.icSupportTicket,
                isSelected: currentIndex == 3),
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
