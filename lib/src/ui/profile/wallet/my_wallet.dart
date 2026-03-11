import 'dart:core';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';

import '../../../apis/apimanager/user_api_manager.dart';
import '../../../apis/base_model.dart';
import '../../../apis/dic_params.dart';
import '../../../main.dart';
import '../../../utils/color_utils.dart';
import '../../../utils/constants.dart';
import '../../../utils/dialog_utils.dart';
import '../../../utils/dimens.dart';
import '../../../utils/image_constants.dart';
import '../../../utils/localization/localization.dart';
import '../../../utils/navigation.dart';
import '../../../utils/navigation_params.dart';
import '../../../utils/preference_key.dart';
import '../../../utils/preference_utils.dart';
import '../../../utils/utils.dart';
import '../../../widgets/paymish_appbar.dart';
import '../../../widgets/paymish_menu_list_item.dart';
import 'model/res_wallet_overview.dart';

class MyWalletScreen extends StatefulWidget {
  final bool isFromBottomNavigation;

  const MyWalletScreen({super.key, this.isFromBottomNavigation = false});

  @override
  State<MyWalletScreen> createState() => _MyWalletScreenState();

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(DiagnosticsProperty<bool>(
        'isFromBottomNavigation', isFromBottomNavigation));
  }
}

// ignore: prefer_mixin
class _MyWalletScreenState extends State<MyWalletScreen> with RouteAware {
  ResWalletOverview _list = ResWalletOverview();
  bool _isProvisioningVirtualAccount = false;

  @override
  void initState() {
    super.initState();
  }

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
      appBar: PaymishAppBar(
        title: Localization.of(context).myWallet,
        isBackGround: false,
        isHideBackButton: widget.isFromBottomNavigation,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: spacingLarge),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.max,
            children: <Widget>[
              Container(
                height: walletCardSize,
                width: MediaQuery.of(context).size.width,
                margin: const EdgeInsets.only(top: spacingMedium),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    // Card Background Image
                    Image.asset(ImageConstants.icWalletCard),
                    // Card Details
                    FutureBuilder<ResWalletOverview>(
                      future: _walletOverviewRequest(),
                      builder: (context, snapshot) {
                        if (snapshot.hasError) {
                          return Container();
                        } else if (snapshot.hasData &&
                            snapshot.connectionState == ConnectionState.done) {
                          final data = snapshot.data?.data;
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            mainAxisSize: MainAxisSize.max,
                            children: [
                              nameAndWalletIdWidget(
                                  firstName: data?.firstName ?? '',
                                  lastName: data?.lastName ?? '',
                                  walletId: data?.qrCode ?? ''),
                              currentWalletBalanceWidget(
                                  currentBalance: data?.walletBalance ?? 0,
                                  isLoading: false),
                            ],
                          );
                        } else {
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            mainAxisSize: MainAxisSize.max,
                            children: [
                              nameAndWalletIdWidget(
                                  firstName:
                                      getString(PreferenceKey.firstName),
                                  lastName:
                                      getString(PreferenceKey.lastName),
                                  walletId:
                                      getString(PreferenceKey.qrCode)),
                              currentWalletBalanceWidget(
                                  currentBalance: 0, isLoading: true),
                            ],
                          );
                        }
                      },
                    )
                  ],
                ),
              ),
              const SizedBox(height: spacingXXLarge),
              dedicatedBankTransferWidget(),
              const SizedBox(height: spacingLarge),
              getString(PreferenceKey.role) != DicParams.roleMerchant
                  ? PaymishMenuListItem(
                      titleText: Localization.of(context).labelAddMoney,
                      onClick: () {
                        labelMainTabAddMoneyClick();
                      },
                    )
                  : const SizedBox(),
              PaymishMenuListItem(
                titleText: Localization.of(context).labelWithdrawMoneyToBank,
                onClick: () {
                  labelWithdrawMoneyToBankClick();
                },
              ),
              PaymishMenuListItem(
                titleText: Localization.of(context).labelRequestStatement,
                onClick: () {
                  labelRequestStatementClick();
                },
              ),
            ],
          ),
        ),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }

  void labelMainTabAddMoneyClick() {
    NavigationUtils.push(context, routeAddMoneyToWallet,
        arguments: {
          NavigationParams.walletAmount: _list.data?.walletBalance ?? 0
        });
  }

  void labelWithdrawMoneyToBankClick() {
    if ((_list.data?.walletBalance ?? 0) != 0) {
      NavigationUtils.push(context, routeWithdrawMoney,
          arguments: {
            NavigationParams.walletAmount: _list.data?.walletBalance ?? 0
          });
    } else {
      DialogUtils.displayToast(
          Localization.of(context).msgInsufficientWalletBalance);
    }
  }

  void labelRequestStatementClick() {
    NavigationUtils.push(context, routeRequestStatement);
  }

  Widget nameAndWalletIdWidget(
      {String firstName = '',
      String lastName = '',
      String walletId = ''}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Padding(
          padding: const EdgeInsets.only(
              left: spacingXLarge, top: spacingXLarge, right: spacingXLarge),
          child: Text(
            getString(PreferenceKey.role) == DicParams.roleUser
                ? "${getString(PreferenceKey.firstName)} "
                    "${getString(PreferenceKey.lastName)}"
                : getString(PreferenceKey.businessName),
            style: const TextStyle(
              color: Colors.white,
              fontSize: fontXMLarge,
              fontWeight: FontWeight.bold,
              fontFamily: fontFamilyPoppinsRegular,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(
            top: spacingSmall,
            left: spacingXLarge,
            right: spacingXLarge,
          ),
          child: Text(
            "${Localization.of(context).labelWalletId}\n$walletId",
            style: const TextStyle(
              color: Colors.white,
              fontSize: fontSmall,
              fontWeight: FontWeight.normal,
              fontFamily: fontFamilyPoppinsLight,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget currentWalletBalanceWidget(
      {num currentBalance = 0, bool isLoading = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.max,
      children: [
        Padding(
          padding: const EdgeInsets.only(
            top: spacingSmall,
            left: spacingXLarge,
            right: spacingXLarge,
          ),
          child: Text(
            Localization.of(context).labelCurrentWalletStatement,
            style: const TextStyle(
              color: ColorUtils.walletBalanceColor,
              fontSize: fontSmall,
              fontWeight: FontWeight.normal,
              fontFamily: fontFamilyPoppinsLight,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(
            left: spacingXLarge,
            right: spacingXLarge,
            bottom: spacingXLarge,
          ),
          child: isLoading
              ? const SizedBox(
                  height: fontXLarge,
                  width: fontXLarge,
                  child: CircularProgressIndicator(),
                )
              : RichText(
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
                          text: currentBalance != 0.0
                              ? """ ${Utils.currencyFormat.format(currentBalance)}"""
                              : " ${0.0}",
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: fontXLarge,
                            fontWeight: FontWeight.w500,
                            fontFamily: fontFamilyPoppinsMedium,
                          ),
                        )
                      ]),
                ),
        ),
      ],
    );
  }

  Widget dedicatedBankTransferWidget() {
    final virtualAccount = _list.data?.virtualAccount;
    final eligibility = _list.data?.virtualAccountEligibility;
    final canProvision = eligibility?.eligible == true && virtualAccount == null;

    return Container(
      width: MediaQuery.of(context).size.width,
      padding: const EdgeInsets.all(spacingMedium),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE7ECF3)),
      ),
      child: virtualAccount != null
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Dedicated Bank Transfer",
                  style: TextStyle(
                    color: ColorUtils.primaryColor,
                    fontSize: fontMedium,
                    fontWeight: FontWeight.w600,
                    fontFamily: fontFamilyPoppinsMedium,
                  ),
                ),
                const SizedBox(height: spacingSmall),
                Text(
                  virtualAccount.bankName ?? "SQUAD",
                  style: const TextStyle(
                    color: ColorUtils.blackColor,
                    fontSize: fontSmall,
                    fontFamily: fontFamilyPoppinsRegular,
                  ),
                ),
                const SizedBox(height: spacingSmall),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        virtualAccount.virtualAccountNumber ?? '',
                        style: const TextStyle(
                          color: ColorUtils.blackColor,
                          fontSize: fontLarge,
                          fontWeight: FontWeight.bold,
                          fontFamily: fontFamilyPoppinsMedium,
                        ),
                      ),
                    ),
                    TextButton(
                      onPressed: () async {
                        final accountNumber =
                            virtualAccount.virtualAccountNumber ?? '';
                        if (accountNumber.isEmpty) {
                          return;
                        }
                        await Clipboard.setData(
                            ClipboardData(text: accountNumber));
                        DialogUtils.displayToast("Account number copied");
                      },
                      child: const Text("Copy"),
                    ),
                  ],
                ),
                Text(
                  virtualAccount.virtualAccountName ??
                      "Paymish Wallet Funding",
                  style: const TextStyle(
                    color: ColorUtils.blackColor,
                    fontSize: fontSmall,
                    fontFamily: fontFamilyPoppinsLight,
                  ),
                ),
              ],
            )
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Dedicated Bank Transfer",
                  style: TextStyle(
                    color: ColorUtils.primaryColor,
                    fontSize: fontMedium,
                    fontWeight: FontWeight.w600,
                    fontFamily: fontFamilyPoppinsMedium,
                  ),
                ),
                const SizedBox(height: spacingSmall),
                Text(
                  canProvision
                      ? "Create your dedicated account to fund wallet via bank transfer."
                      : "Complete KYC and admin approval to unlock dedicated account funding.",
                  style: const TextStyle(
                    color: ColorUtils.blackColor,
                    fontSize: fontSmall,
                    fontFamily: fontFamilyPoppinsRegular,
                  ),
                ),
                if (canProvision) ...[
                  const SizedBox(height: spacingMedium),
                  SizedBox(
                    height: 42,
                    child: ElevatedButton(
                      onPressed: _isProvisioningVirtualAccount
                          ? null
                          : () async {
                              await _provisionVirtualAccount();
                            },
                      child: Text(
                        _isProvisioningVirtualAccount
                            ? "Creating..."
                            : "Create Dedicated Account",
                      ),
                    ),
                  ),
                ]
              ],
            ),
    );
  }

  Future<void> _provisionVirtualAccount() async {
    setState(() {
      _isProvisioningVirtualAccount = true;
    });
    try {
      await UserApiManager().provisionVirtualAccount();
      if (!mounted) {
        return;
      }
      await _walletOverviewRequest();
      if (mounted) {
        setState(() {});
      }
      DialogUtils.displayToast("Dedicated account is ready");
    } catch (e) {
      if (e is ResBaseModel) {
        DialogUtils.displayToast(e.error ?? "Unable to create virtual account");
      } else {
        DialogUtils.displayToast("Unable to create virtual account");
      }
    } finally {
      if (mounted) {
        setState(() {
          _isProvisioningVirtualAccount = false;
        });
      }
    }
  }

  // Wallet Overview API
  Future<ResWalletOverview> _walletOverviewRequest() async {
    try {
      _list = await UserApiManager().walletOverview();
    } catch (e) {
      if (e is ResBaseModel) {
        if (!mounted) {
          return _list;
        }
        DialogUtils.showAlertDialog(context, e.error ?? '');
      }
      // If Error occurs return amount as 0
      _list = ResWalletOverview(
        data: Data(
          walletBalance: 0,
          firstName: getString(PreferenceKey.firstName),
          lastName: getString(PreferenceKey.lastName),
          qrCode: getString(PreferenceKey.qrCode),
        ),
      );
    }
    return _list;
  }
}
