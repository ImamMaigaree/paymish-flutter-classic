import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:local_auth/local_auth.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';

import '../../../apis/apimanager/user_api_manager.dart';
import '../../../apis/base_model.dart';
import '../../../utils/color_utils.dart';
import '../../../utils/common_methods.dart';
import '../../../utils/constants.dart';
import '../../../utils/dialog_utils.dart';
import '../../../utils/dimens.dart';
import '../../../utils/fcm_utils.dart';
import '../../../utils/image_constants.dart';
import '../../../utils/localization/localization.dart';
import '../../../utils/permission_util.dart';
import '../../../utils/preference_key.dart';
import '../../../utils/preference_utils.dart';
import '../../../utils/utils.dart';
import '../../../widgets/common_permission_popup.dart';
import '../../../widgets/merchant_home_row.dart';
import '../../../widgets/paymish_home_appbar.dart';
import 'model/res_merchant_home.dart';
import 'provider/home_screen_provider.dart';

class MerchantHomeScreen extends StatefulWidget {
  const MerchantHomeScreen({Key? key}) : super(key: key);

  @override
  _MerchantHomeScreenState createState() => _MerchantHomeScreenState();
}

class _MerchantHomeScreenState extends State<MerchantHomeScreen> {
  final LocalAuthentication _auth = LocalAuthentication();
  final _canCheckBiometrics = ValueNotifier<bool>(false);
  final _availableBiometrics =
      ValueNotifier<List<BiometricType>>(<BiometricType>[]);
  ResMerchantHomeScreen? _homeScreenDataObject;

  @override
  void initState() {
    super.initState();
    _getAvailableBiometrics();
    _checkBiometrics();
    PermissionUtils.checkPermissionStatus(Permission.contacts, context,
        permissionGrant: () {
      if (getBool(PreferenceKey.isFingerPrintEnabled) != true &&
          getBool(PreferenceKey.isSkipFingerPrintPermission) != true) {
        showFingerPrintPopupDialog();
      }
    }, permissionDenied: () {
      if (getBool(PreferenceKey.isSkipContactPermission) != true) {
        showContactPopupDialog();
      } else if (getBool(PreferenceKey.isFingerPrintEnabled) != true &&
          getBool(PreferenceKey.isSkipFingerPrintPermission) != true) {
        showFingerPrintPopupDialog();
      }
    });
    registerNotification(context);
  }

  void showContactPopupDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => CommonPermissionPopup(
        icon: ImageConstants.icContactPopup,
        permissionText: Localization.of(context).msgContactPermission,
        onContinueTap: () {
          PermissionUtils.requestPermission(
            [Permission.contacts, Permission.location],
            context,
            isOpenSettings: true,
            permissionGrant: () {},
            permissionDenied: () {},
          );
          if (getBool(PreferenceKey.isFingerPrintEnabled) != true) {
            showFingerPrintPopupDialog();
          }
        },
        onSkipTap: () async {
          await setBool(PreferenceKey.isSkipContactPermission, true);
          if (getBool(PreferenceKey.isFingerPrintEnabled) != true) {
            showFingerPrintPopupDialog();
          }
        },
      ),
    );
  }

  void showFingerPrintPopupDialog() {
    if (_canCheckBiometrics.value == true &&
        _availableBiometrics.value.contains(BiometricType.fingerprint)) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => CommonPermissionPopup(
          icon: ImageConstants.icFingerPrint,
          permissionText: Localization.of(context).msgFingerprintPermission,
          onContinueTap: () async {
            await _authenticate();
          },
          onSkipTap: () async {
            await setBool(PreferenceKey.isSkipFingerPrintPermission, true);
          },
        ),
      );
    }
  }

  Future<void> _checkBiometrics() async {
    var check = false;
    try {
      check = await _auth.canCheckBiometrics;
    } on PlatformException catch (e) {
      DialogUtils.displaySnackBar(message: e.toString());
    }
    if (!mounted) return;
    _canCheckBiometrics.value = check;
  }

  Future<void> _getAvailableBiometrics() async {
    List<BiometricType> availableBiometrics = <BiometricType>[];
    try {
      availableBiometrics = await _auth.getAvailableBiometrics();
    } on PlatformException catch (e) {
      DialogUtils.displaySnackBar(message: e.toString());
    }
    if (!mounted) return;
    _availableBiometrics.value = availableBiometrics;
  }

  Future<void> _authenticate() async {
    try {
      final authenticated = await _auth.authenticate(
        localizedReason: Localization.of(context).authenticateFingerprint,
        biometricOnly: true,
      );
      if (authenticated) {
        await setBool(PreferenceKey.isFingerPrintEnabled, true);
        await DialogUtils.displayToast(
            Localization.of(context).msgAuthenticateSuccess);
      }
    } on PlatformException catch (e) {
      if (e.code == 'NotEnrolled') {
        DialogUtils.displaySnackBar(message: e.code.toString());
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorUtils.merchantHomeBackgroundWhite,
      appBar: PaymishHomeAppbar(
        isBackGround: false,
        titleVisible: false,
      ),
      body: Column(
        children: [
          _getTopHeader(),
          FutureBuilder<ResMerchantHomeScreen>(
              future: _getBankDetails(context),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Container();
                } else if (snapshot.hasData &&
                    snapshot.connectionState == ConnectionState.done) {
                  final apiData = snapshot.data?.data;
                  return Column(
                    children: [
                      SingleChildScrollView(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            MerchantHomeRow(
                              title: Localization.of(context)
                                  .labelTotalTransactions,
                              description: "${apiData?.totalTransactions ?? 0}",
                              onTap: () {},
                            ),
                            MerchantHomeRow(
                              title: Localization.of(context)
                                  .labelTotalPaymentReceived,
                              description:
                                  """${Utils.currencyFormat.format(apiData?.totalPaymentReceiver ?? 0)} ${Localization.of(context).labelNaira}""",
                              onTap: () {},
                            ),
                            MerchantHomeRow(
                              title: Localization.of(context)
                                  .labelTotalCommissionPaid,
                              description:
                                  """${Utils.currencyFormat.format(apiData?.totalCommissonPaid ?? 0)} ${Localization.of(context).labelNaira}""",
                              onTap: () {},
                            ),
                            MerchantHomeRow(
                              title: Localization.of(context)
                                  .labelTotalRevenueGenerated,
                              description:
                                  """${Utils.currencyFormat.format(apiData?.totalRevenueGenerated ?? 0)} ${Localization.of(context).labelNaira}""",
                              onTap: () {},
                            ),
                          ],
                        ),
                      ),
                    ],
                  );
                } else {
                  return const Center(
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(
                          ColorUtils.primaryColor),
                    ),
                  );
                }
              }),
        ],
      ),
    );
  }

  Widget _getTopHeader() {
    return Container(
      decoration: const BoxDecoration(
        color: ColorUtils.merchantHomeBackgroundWhite,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(circleRadius14),
          bottomRight: Radius.circular(circleRadius14),
        ),
      ),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.fromLTRB(15.0, 0.0, 55.0, spacingSmall),
        child: FittedBox(
          fit: BoxFit.contain,
          child: Text(
            Localization.of(context).labelMerchantHomeScreen,
            style: const TextStyle(
              fontFamily: fontFamilyPoppinsLight,
              fontSize: 24.0,
              color: ColorUtils.primaryColor,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }

  // To get all the bank list
  Future<ResMerchantHomeScreen> _getBankDetails(BuildContext context) async {
    // Initially set notification count 0 as default
    await UserApiManager().merchantHomeScreen().then((value) {
      _homeScreenDataObject = value;
      final data = _homeScreenDataObject?.data;
      // Set Notification count from API response
      Provider.of<HomeScreenProvider>(context, listen: false)
          .setNotificationCount(data?.unreadCount ?? 0);
      _updateSharedPref();
    }).catchError((dynamic e) {
      if (e is ResBaseModel) {
        if (!checkSessionExpire(e, context)) {
          DialogUtils.showAlertDialog(context, e.error ?? '');
        }
      }
      // If error occurs, set notification count as 0 (default)
      Provider.of<HomeScreenProvider>(context, listen: false)
          .setNotificationCount(0);
      _homeScreenDataObject = ResMerchantHomeScreen(
          data: Data(
              totalPaymentReceiver: 0,
              totalRevenueGenerated: 0,
              totalCommissonPaid: 0,
              unreadCount: 0,
              totalTransactions: 0,
              isApprovedByAdmin: 0));
    });
    return _homeScreenDataObject!;
  }

  void _updateSharedPref() {
    setInt(
      PreferenceKey.isApprovedByAdmin,
      _homeScreenDataObject?.data?.isApprovedByAdmin ?? 0,
    );
  }
}
