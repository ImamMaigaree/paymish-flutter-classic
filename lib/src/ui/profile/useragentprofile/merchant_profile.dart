import 'package:flutter/material.dart';

import '../../../apis/dic_params.dart';
import '../../../main.dart';
import '../../../utils/color_utils.dart';
import '../../../utils/common_methods.dart';
import '../../../utils/constants.dart';
import '../../../utils/dialog_utils.dart';
import '../../../utils/dimens.dart';
import '../../../utils/image_constants.dart';
import '../../../utils/localization/localization.dart';
import '../../../utils/navigation.dart';
import '../../../utils/preference_key.dart';
import '../../../utils/preference_utils.dart';
import '../../../widgets/kyc_details_box.dart';
import '../../../widgets/my_profile_row.dart';
import '../../../widgets/user_profile_picture.dart';

class MerchantProfileScreen extends StatefulWidget {
  const MerchantProfileScreen({Key? key}) : super(key: key);

  @override
  _MerchantProfileScreenState createState() => _MerchantProfileScreenState();
}

class _MerchantProfileScreenState extends State<MerchantProfileScreen>
    with
// ignore: prefer_mixin
        RouteAware {
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final route = ModalRoute.of(context);
    if (route is PageRoute) {
      routeObserver.subscribe(this, route);
    }
  }

  @override
  void dispose() {
    routeObserver.unsubscribe(this);
    super.dispose();
  }

  // Called when the top route has been popped off,
  // and the current route shows up.
  @override
  void didPopNext() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.only(bottom: 0),
            decoration: const BoxDecoration(
              color: ColorUtils.primaryColor,
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(circleRadius14),
                bottomRight: Radius.circular(circleRadius14),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.only(
                      top: spacingXXMLarge, left: spacingTiny),
                  height: spacingXXXXXLarge,
                  child: FloatingActionButton(
                    backgroundColor: Colors.transparent,
                    elevation: 0,
                    highlightElevation: 0,
                    hoverElevation: 0,
                    focusElevation: 0,
                    disabledElevation: 0,
                    tooltip: Localization.of(context).labelBack,
                    child: Image.asset(ImageConstants.icBackArrow,
                        fit: BoxFit.contain,
                        height: spacingMedium,
                        color: Colors.white),
                    onPressed: () {
                      NavigationUtils.pop(context);
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(spacingMedium),
                  child: Column(
                    children: [
                      _getHeaderView(context),
                      _getSubHeaderView(context),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.only(
                  top: spacingXSmall, left: spacingLarge, right: spacingMedium),
              child: Column(
                children: [
                  MyProfileRow(
                    title: Localization.of(context).myQrCode,
                    image: ImageConstants.icQrCodeBlack,
                    onTap: () {
                      NavigationUtils.push(context, routeMyQrCode);
                    },
                  ),
                  MyProfileRow(
                    title: Localization.of(context).myTransactions,
                    image: ImageConstants.icMyTransactions,
                    onTap: () {
                      if (isAccountApproved(context)) {
                        NavigationUtils.push(context, routeMyTransaction);
                      }
                    },
                  ),
                  MyProfileRow(
                    title: Localization.of(context).accountSettings,
                    image: ImageConstants.icAccountSettings,
                    onTap: () {
                      NavigationUtils.push(context, routeAccountSetting);
                    },
                  ),
                  MyProfileRow(
                    title: Localization.of(context).bankDetails,
                    image: ImageConstants.icBankDetails,
                    onTap: () {
                      NavigationUtils.push(context, routeBankDetails);
                    },
                  ),
                  MyProfileRow(
                    title: Localization.of(context).myDocuments,
                    image: ImageConstants.icMyDocument,
                    onTap: () {
                      NavigationUtils.push(context, routeUploadDocuments,
                          arguments: {DicParams.isFromUpload: false});
                    },
                  ),
                  MyProfileRow(
                    title: Localization.of(context).logoutLabel,
                    image: ImageConstants.icLogout,
                    onTap: () {
                      DialogUtils.showOkCancelAlertDialog(
                          context: context,
                          message: Localization.of(context).msgLogout,
                          okButtonTitle: Localization.of(context).ok,
                          okButtonAction: () => _logOut(context),
                          cancelButtonTitle: Localization.of(context).cancel,
                          cancelButtonAction: () {},
                          isCancelEnable: true);
                    },
                  ),
                ],
              ),
            ),
          ),
          KycDetailsBox(bvnNo: getString(PreferenceKey.bvnNumber)),
        ],
      ),
    );
  }

  Future _logOut(BuildContext context) async {
    await logoutAndClearPreference();
    await NavigationUtils.pushAndRemoveUntil(context, routeIntroduction);
  }

  Widget _getHeaderView(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Hero(
          tag: routeMyProfile,
          transitionOnUserGestures: true,
          child: UserProfilePicture(),
        ),
        const SizedBox(width: spacingXLarge),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  Flexible(
                    child: Text(
                      getString(PreferenceKey.businessName),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontFamily: fontFamilyPoppinsMedium,
                        fontSize: fontLarge,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: spacingXSmall),
                    child: getInt(PreferenceKey.isApprovedByAdmin) == 1
                        ? Image.asset(
                            ImageConstants.icVerified,
                            scale: 2.0,
                          )
                        : Container(),
                  ),
                ],
              ),
              Text(
                getString(PreferenceKey.email),
                style: const TextStyle(
                  fontFamily: fontFamilyPoppinsRegular,
                  fontSize: fontSmall,
                  color: ColorUtils.secondaryTextColor,
                ),
              ),
              Text(
                "$countryCode ${getString(PreferenceKey.mobile)}",
                style: const TextStyle(
                  fontFamily: fontFamilyPoppinsRegular,
                  fontSize: fontSmall,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
        GestureDetector(
          onTap: () {
            NavigationUtils.push(context, routeEditProfile);
          },
          child: Image.asset(
            ImageConstants.icEdit,
            scale: 2.3,
          ),
        ),
      ],
    );
  }

  Widget _getSubHeaderView(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(bottom: spacingSmall, top: spacingMedium),
          child: Divider(
            color: ColorUtils.secondaryTextColor,
            thickness: 1.0,
          ),
        ),
        Text(
          Localization.of(context).labelBusinessCategory +
              getString(PreferenceKey.businessCategories),
          style: const TextStyle(
            color: Colors.white,
            fontFamily: fontFamilyPoppinsRegular,
            fontSize: fontSmall,
          ),
        ),
        Padding(
                padding: const EdgeInsets.only(top: spacingTiny),
                child: Text(
                  getString(PreferenceKey.businessDescription),
                  style: const TextStyle(
                      color: ColorUtils.descriptionColor,
                      fontFamily: fontFamilyPoppinsRegular,
                      fontSize: fontSmall),
                ),
              )
      ],
    );
  }
}
