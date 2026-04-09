import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:local_auth/local_auth.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';

import '../../../apis/apimanager/user_api_manager.dart';
import '../../../apis/base_model.dart';
import '../../../apis/dic_params.dart';
import '../../../utils/color_utils.dart';
import '../../../utils/common_methods.dart';
import '../../../utils/constants.dart';
import '../../../utils/dialog_utils.dart';
import '../../../utils/dimens.dart';
import '../../../utils/fcm_utils.dart';
import '../../../utils/image_constants.dart';
import '../../../utils/localization/localization.dart';
import '../../../utils/navigation.dart';
import '../../../utils/navigation_params.dart';
import '../../../utils/permission_util.dart';
import '../../../utils/preference_key.dart';
import '../../../utils/preference_utils.dart';
import '../../../utils/utils.dart';
import '../../../widgets/common_permission_popup.dart';
import '../../../widgets/paymish_home_appbar.dart';
import '../../../widgets/recent_list_view.dart';
import '../../profile/wallet/model/res_wallet_overview.dart';
import 'model/res_home.dart';
import 'provider/home_screen_provider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final ScrollController _controller = ScrollController();
  final LocalAuthentication _auth = LocalAuthentication();
  final _canCheckBiometrics = ValueNotifier<bool>(false);
  final _availableBiometrics =
      ValueNotifier<List<BiometricType>>(<BiometricType>[]);
  ResHomeScreen? _homeScreenDataObject;
  ResWalletOverview _walletOverviewObject = ResWalletOverview();
  late Future<ResWalletOverview> _walletOverviewFuture;

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
    _walletOverviewFuture = _getWalletOverview();
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
      backgroundColor: ColorUtils.homeBackgroundColor,
      appBar: PaymishHomeAppbar(),
      body: FutureBuilder<ResHomeScreen>(
        future: _getBankDetails(context),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Container();
          } else if (snapshot.hasData &&
              snapshot.connectionState == ConnectionState.done) {
            final apiData = snapshot.data?.data;
            return Stack(
              children: [
                _getTopHeader(),
                SingleChildScrollView(
                  controller: _controller,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildWalletTile(),
                      (apiData?.utilities?.isNotEmpty ?? false)
                          ? _getUtilityView(apiData?.utilities ?? <Utilities>[])
                          : const SizedBox(),
                      (apiData?.recentContacts?.count ?? 0) != 0
                          ? RecentListView(
                              context: context,
                              recentListContact:
                                  apiData?.recentContacts?.contacts ??
                                      <Contacts>[],
                              isFromScan: false,
                            )
                          : Container(),
                    ],
                  ),
                ),
              ],
            );
          } else {
            return const Center(
              child: CircularProgressIndicator(
                valueColor:
                    AlwaysStoppedAnimation<Color>(ColorUtils.primaryColor),
              ),
            );
          }
        },
      ),
    );
  }

  Widget _buildWalletTile() {
    return FutureBuilder<ResWalletOverview>(
      future: _walletOverviewFuture,
      builder: (context, snapshot) {
        final walletData = snapshot.data?.data ?? _walletOverviewObject.data;
        final bool isLoading = snapshot.connectionState == ConnectionState.waiting;
        final String accountNumber =
            walletData?.virtualAccount?.virtualAccountNumber ?? '--';
        final String bankName =
            _resolveBankName(walletData?.virtualAccount?.bankName);
        final num walletBalance = walletData?.walletBalance ?? 0;

        return Container(
          height: walletCardSize,
          width: MediaQuery.of(context).size.width,
          margin: const EdgeInsets.fromLTRB(15.0, 10.0, 15.0, 0.0),
          child: Stack(
            fit: StackFit.expand,
            children: [
              Image.asset(ImageConstants.icWalletCard, fit: BoxFit.fill),
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  spacingXLarge,
                  spacingXLarge,
                  spacingXLarge,
                  spacingLarge,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _resolveWalletDisplayName(walletData),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: fontXLarge,
                            fontWeight: FontWeight.w600,
                            fontFamily: fontFamilyPoppinsRegular,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: spacingTiny),
                        Text(
                          bankName,
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: fontSmall,
                            fontFamily: fontFamilyPoppinsLight,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: spacing4),
                        Text(
                          accountNumber,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: fontSmall,
                            fontFamily: fontFamilyPoppinsLight,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (isLoading)
                          const SizedBox(
                            height: spacingLarge,
                            width: spacingLarge,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor:
                                  AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                        else
                          RichText(
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                            text: TextSpan(
                              text: countryCurrency,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: fontXLarge,
                                fontWeight: FontWeight.w500,
                                fontFamily: fontFamilySFMonoMedium,
                              ),
                              children: <TextSpan>[
                                TextSpan(
                                  text:
                                      " ${Utils.currencyFormat.format(walletBalance)}",
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: fontXLarge,
                                    fontWeight: FontWeight.w500,
                                    fontFamily: fontFamilyPoppinsMedium,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        const SizedBox(height: spacingTiny),
                        Text(
                          Localization.of(context).labelCurrentWalletStatement,
                          style: const TextStyle(
                            color: ColorUtils.walletBalanceColor,
                            fontSize: fontSmall,
                            fontFamily: fontFamilyPoppinsLight,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  String _resolveWalletDisplayName(Data? walletData) {
    if (getString(PreferenceKey.role) == DicParams.roleMerchant) {
      final businessName = getString(PreferenceKey.businessName).trim();
      return businessName.isEmpty ? '--' : businessName;
    }
    final firstName =
        (walletData?.firstName ?? getString(PreferenceKey.firstName)).trim();
    final lastName =
        (walletData?.lastName ?? getString(PreferenceKey.lastName)).trim();
    final fullName = "$firstName $lastName".trim();
    return fullName.isEmpty ? '--' : fullName;
  }

  String _resolveBankName(String? bankName) {
    final normalized = (bankName ?? '').trim().toUpperCase();
    if (normalized.isEmpty || normalized == 'SQUAD') {
      return 'GTBank';
    }
    return bankName ?? 'GTBank';
  }

  Future<ResWalletOverview> _getWalletOverview() async {
    try {
      _walletOverviewObject = await UserApiManager().walletOverview();
    } catch (_) {
      _walletOverviewObject = ResWalletOverview(
        data: Data(
          firstName: getString(PreferenceKey.firstName),
          lastName: getString(PreferenceKey.lastName),
          walletBalance: 0,
        ),
      );
    }
    return _walletOverviewObject;
  }

  // To get all the bank list
  Future<ResHomeScreen> _getBankDetails(BuildContext context) async {
    // Initially set notification count 0 as default
    await UserApiManager().homeScreen().then((value) {
      _homeScreenDataObject = value;
      final data = _homeScreenDataObject?.data;
      // Set Notification count from API response
      Provider.of<HomeScreenProvider>(context, listen: false)
          .setNotificationCount(data?.unreadCount ?? 0);
      Provider.of<HomeScreenProvider>(context, listen: false)
          .setHomeData(data?.recentContacts?.contacts ?? <Contacts>[]);
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
      _homeScreenDataObject = ResHomeScreen(
          data: ResHomeScreenData(
              recentContacts: RecentContacts(contacts: <Contacts>[], count: 0),
              unreadCount: 0,
              utilities: <Utilities>[],
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

  Widget _getTopHeader() {
    return Container(
      decoration: const BoxDecoration(
        color: ColorUtils.primaryColor,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(circleRadius14),
          bottomRight: Radius.circular(circleRadius14),
        ),
      ),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.fromLTRB(15.0, 0.0, 15.0, 80.0),
        child: const SizedBox(),
      ),
    );
  }

  Widget _getUtilityView(List<Utilities> utilityList) {
    final filteredUtilities = utilityList
        .where((item) => !_shouldHideUtilityCategory(item.name))
        .toList();
    return Container(
      margin: const EdgeInsets.fromLTRB(15.0, 10.0, 15.0, 0.0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15.0),
        color: Colors.white,
      ),
      padding: const EdgeInsets.only(
        left: spacingMedium,
        right: spacingMedium,
        bottom: spacingMedium,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          for (var item in filteredUtilities)
            _getUtilityWidgets(
              title: item.name?.toString() ?? "",
              utilityServices: item.services ?? <Services>[],
            ),
        ],
      ),
    );
  }

  Widget _getUtilityWidgets({
    required String title,
    required List<Services> utilityServices,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Padding(
          padding:
              const EdgeInsets.only(top: spacingMedium, bottom: spacingTiny),
          child: Text(
            title,
            style: const TextStyle(
              fontFamily: fontFamilyPoppinsRegular,
              color: ColorUtils.primaryColor,
              fontSize: fontLarge,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        Container(
          height: spacing45,
          margin:
              const EdgeInsets.only(top: spacingSmall, bottom: spacingSmall),
          width: MediaQuery.of(context).size.width,
          child: ListView.builder(
            primary: false,
            shrinkWrap: true,
            scrollDirection: Axis.horizontal,
            itemCount: utilityServices.length,
            itemBuilder: (context, index) {
              final item = utilityServices[index];
              final imageUrl = item.image ?? "";
              return InkWell(
                onTap: () {
                  _gotoNextScreen(context, item);
                },
                child: Container(
                  width: spacing45,
                  margin: const EdgeInsets.symmetric(
                    horizontal: spacingSmall,
                  ),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(spacingXSmall),
                    color: ColorUtils.homeAirlineBgColor,
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(spacingXSmall),
                    child: checkImageType(imageUrl)
                        ? Image.network(
                            imageUrl,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => Image.asset(
                              ImageConstants.icPaymishWhite,
                              fit: BoxFit.cover,
                            ),
                          )
                        : Image.asset(
                            ImageConstants.icPaymishWhite,
                            fit: BoxFit.cover,
                          ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  void _gotoNextScreen(BuildContext context, Services utilityService) {
    if (getString(PreferenceKey.kycStatus) == DicParams.notVerified) {
      DialogUtils.showOkCancelAlertDialog(
          context: context,
          message: Localization.of(context).errorSetUpTransactionDetails,
          okButtonTitle: Localization.of(context).ok,
          okButtonAction: () => {
                NavigationUtils.push(context, routeCompleteKYC, arguments: {
                  NavigationParams.showBackButton: true,
                  NavigationParams.completeTransactionDetails: true
                })
              },
          cancelButtonTitle: Localization.of(context).cancel,
          cancelButtonAction: () {},
          isCancelEnable: true);
    } else if (getInt(PreferenceKey.isBankAccount) == 0) {
      openTransactionDetailsDialog(context, routeWalletSetup);
    } else if (getInt(PreferenceKey.isTransactionPin) == 0) {
      openTransactionDetailsDialog(context, routeTransactionPinSetup);
    } else {
      NavigationUtils.push(context, routeUtilityServices,
          arguments: {NavigationParams.services: utilityService});
    }
  }

  String _normalizeUtilityCategoryName(String? name) {
    return (name ?? "").toLowerCase().trim().replaceAll(RegExp(r"\s+"), " ");
  }

  bool _shouldHideUtilityCategory(String? name) {
    final normalizedName = _normalizeUtilityCategoryName(name);
    return normalizedName == "insurance" ||
        normalizedName == "other merchants/services" ||
        normalizedName == "other merchants / services" ||
        normalizedName == "other merchants services";
  }
}
