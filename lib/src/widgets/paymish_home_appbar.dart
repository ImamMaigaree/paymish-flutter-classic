import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../ui/auth/home/provider/home_screen_provider.dart';
import '../utils/color_utils.dart';
import '../utils/common_methods.dart';
import '../utils/constants.dart';
import '../utils/dimens.dart';
import '../utils/image_constants.dart';
import '../utils/navigation.dart';
import '../utils/preference_key.dart';
import '../utils/preference_utils.dart';
import 'profile_image_view.dart';

class PaymishHomeAppbar extends StatelessWidget
    implements PreferredSizeWidget {
  final bool titleVisible;
  final bool isBackGround;
  final ValueNotifier<bool> _isUpdate = ValueNotifier<bool>(false);

  PaymishHomeAppbar(
      {super.key, this.titleVisible = false, this.isBackGround = false});

  @override
  Size get preferredSize => const Size.fromHeight(80.0);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: ColorUtils.merchantHomeBackgroundWhite,
      child: SafeArea(
        child: Container(
          margin: const EdgeInsets.all(15.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  GestureDetector(
                    onTap: () async {
                      final data = await NavigationUtils.push(context,
                          isUserApp() ? routeMyProfile : routeMerchantProfile);
                      if (data == null) {
                        _isUpdate.value = true;
                      }
                    },
                    child: Hero(
                      tag: routeMyProfile,
                      transitionOnUserGestures: true,
                      child: ValueListenableBuilder(
                        valueListenable: _isUpdate,
                        builder: (context, isUpdate, _) => ProfileImageView(
                          profileUrl: getString(PreferenceKey.profilePicture),
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: const SizedBox(),
                  )
                ],
              ),
              Row(
                children: [
                  GestureDetector(
                    child: Container(
                      padding: const EdgeInsets.all(10.0),
                      child: const SizedBox(),
                    ),
                    onTap: () {
                      if (isAccountApproved(context)) {
                        NavigationUtils.push(context, routeScanAndPay);
                      }
                    },
                  ),
                  GestureDetector(
                    onTap: () {
                      NavigationUtils.push(context, routeNotification);
                    },
                    child: Stack(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(spacingSmall),
                          child: Image.asset(
                                  ImageConstants.icNotification,
                                  color: ColorUtils.primaryColor,
                                  scale: 3.0,
                                ),
                        ),
                        Provider.of<HomeScreenProvider>(context, listen: true)
                                    .getNotificationCount() !=
                                0
                            ? Positioned(
                                right: 0,
                                top: 0,
                                child: Container(
                                  decoration: BoxDecoration(
                                    border: Border.all(
                                        color: ColorUtils.primaryColor,
                                        width: 2),
                                    borderRadius:
                                        BorderRadius.circular(circleSmall),
                                  ),
                                  child: CircleAvatar(
                                    maxRadius: spacingSmall,
                                    minRadius: spacingTiny,
                                    backgroundColor: Colors.white,
                                    child: FittedBox(
                                      fit: BoxFit.cover,
                                      child: Center(
                                        child: Text(
                                          Provider.of<HomeScreenProvider>(
                                                  context,
                                                  listen: true)
                                              .getNotificationCount()
                                              .toString(),
                                          style: const TextStyle(
                                            fontFamily: fontFamilyPoppinsMedium,
                                            fontSize: fontSmall,
                                            color: ColorUtils.primaryColor,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              )
                            : Container(),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(DiagnosticsProperty<bool>('titleVisible', titleVisible));
    properties.add(DiagnosticsProperty<bool>('isBackGround', isBackGround));
  }
}
