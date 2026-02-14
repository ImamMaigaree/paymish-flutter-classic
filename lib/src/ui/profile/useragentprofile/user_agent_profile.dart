import 'package:flutter/material.dart';

import '../../../apis/dic_params.dart';
import '../../../main.dart';
import '../../../utils/color_utils.dart';
import '../../../utils/common_methods.dart';
import '../../../utils/constants.dart';
import '../../../utils/dialog_utils.dart';
import '../../../utils/dimens.dart';
import '../../../utils/enum_utils.dart';
import '../../../utils/image_constants.dart';
import '../../../utils/localization/localization.dart';
import '../../../utils/navigation.dart';
import '../../../utils/navigation_params.dart';
import '../../../utils/preference_key.dart';
import '../../../utils/preference_utils.dart';
import '../../../widgets/kyc_details_box.dart';
import '../../../widgets/my_profile_row.dart';
import '../../../widgets/user_profile_picture.dart';

class UserAgentProfileScreen extends StatefulWidget {
  const UserAgentProfileScreen({Key? key}) : super(key: key);

  @override
  _UserAgentProfileScreenState createState() => _UserAgentProfileScreenState();
}

class _UserAgentProfileScreenState
    extends State<UserAgentProfileScreen> // ignore: prefer_mixin
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
            padding: const EdgeInsets.only(bottom: spacingXLarge),
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
                      getString(PreferenceKey.role) == UserType.agent.getName()
                          ? _getSubHeaderView(context)
                          : Container(),
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
                    title: Localization.of(context).acceptReqMoney,
                    image: ImageConstants.icAcceptReqMoney,
                    onTap: () {
                      if (isAccountApproved(context)) {
                        NavigationUtils.push(context, routeTransferMoneyScreen,
                            arguments: {NavigationParams.showBackButton: true});
                      }
                    },
                  ),
                  MyProfileRow(
                    title: Localization.of(context).myWallet,
                    image: ImageConstants.icWalletBlack,
                    onTap: () {
                      if (isAccountApproved(context)) {
                        NavigationUtils.push(context, routeMyWallet);
                      }
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
                    title: Localization.of(context).paymentSettings,
                    image: ImageConstants.icPaymentSettings,
                    onTap: () {
                      NavigationUtils.push(context, routePaymentSetting);
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
                    title: Localization.of(context).supportTickets,
                    image: ImageConstants.icSupportTicket,
                    onTap: () {
                      NavigationUtils.push(context, routeSupportTickets,
                          arguments: {NavigationParams.showBackButton: true});
                    },
                  ),
                  getString(PreferenceKey.role) == UserType.agent.getName()
                      ? MyProfileRow(
                          title: Localization.of(context).myDocuments,
                          image: ImageConstants.icMyDocument,
                          onTap: () {
                            NavigationUtils.push(context, routeUploadDocuments,
                                arguments: {DicParams.isFromUpload: false});
                          },
                        )
                      : Container(),
                  getString(PreferenceKey.role) == UserType.agent.getName()
                      ? MyProfileRow(
                          title: Localization.of(context).myCommissions,
                          image: ImageConstants.icMyCommission,
                          onTap: () {
                          },
                        )
                      : Container(),
                  MyProfileRow(
                    title: Localization.of(context).logoutLabel,
                    image: ImageConstants.icLogout,
                    onTap: () {
                      DialogUtils.showOkCancelAlertDialog(
                          context: context,
                          message: Localization.of(context).msgLogout,
                          okButtonTitle: Localization.of(context).ok,
                          okButtonAction: () async {
                            await logoutAndClearPreference();
                            await NavigationUtils.pushAndRemoveUntil(
                                context, routeIntroduction);
                          },
                          cancelButtonTitle: Localization.of(context).cancel,
                          cancelButtonAction: () {
                            NavigationUtils.pop(context);
                          },
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
                      getString(PreferenceKey.role) == DicParams.roleUser
                          ? "${getString(PreferenceKey.firstName)} "
                              "${getString(PreferenceKey.lastName)}"
                          : getString(PreferenceKey.businessName),
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
          child: Container(
            height: spacingXXLarge,
            width: spacingXXLarge,
            alignment: AlignmentDirectional.topEnd,
            child: Image.asset(
              ImageConstants.icEdit,
              scale: 2.3,
            ),
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
