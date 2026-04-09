import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_paystack/flutter_paystack.dart';
import 'package:provider/provider.dart';

import '../../../apis/apimanager/user_api_manager.dart';
import '../../../apis/base_model.dart';
import '../../../main.dart';
import '../../../utils/app_config.dart';
import '../../../utils/color_utils.dart';
import '../../../utils/common_methods.dart';
import '../../../utils/constants.dart';
import '../../../utils/dialog_utils.dart';
import '../../../utils/dimens.dart';
import '../../../utils/image_constants.dart';
import '../../../utils/localization/localization.dart';
import '../../../utils/preference_key.dart';
import '../../../utils/preference_utils.dart';
import '../../../utils/progress_dialog.dart';
import '../../../widgets/paymish_appbar.dart';
import '../model/res_card_listing.dart';
import '../provider/bank_details_provider.dart';

class CardDetailsScreen extends StatefulWidget {
  const CardDetailsScreen({Key? key}) : super(key: key);

  @override
  _CardDetailsScreenState createState() => _CardDetailsScreenState();
}

class _CardDetailsScreenState extends State<CardDetailsScreen>
    with
// ignore: prefer_mixin
        RouteAware {
  List<CardDetails> _list = <CardDetails>[];

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
  void initState() {
    paystackPlugin.initialize(publicKey: payStackKey ?? '');
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: PaymishAppBar(
        title: Localization.of(context).cardDetails,
        isBackGround: false,
      ),
      body: Padding(
        padding: const EdgeInsets.only(
            left: spacingLarge, right: spacingLarge, top: spacingLarge),
        child: Container(
          child: FutureBuilder<List<CardDetails>>(
            future: _getBankDetails(context), // async work
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                    child: CircularProgressIndicator(
                  valueColor:
                      AlwaysStoppedAnimation<Color>(ColorUtils.primaryColor),
                ));
              } else {
                if (snapshot.hasError) {
                  return Center(child: Text(snapshot.error.toString()));
                }
                final cards = snapshot.data ?? <CardDetails>[];
                if (cards.isEmpty) {
                  return Center(
                      child: Text(
                          Localization.of(context).labelNoCardDetailsFound));
                } else {
                  return Consumer<BankDetailsProvider>(
                    builder: (context, myModel, child) => ListView.builder(
                      itemCount: cards.length,
                      itemBuilder: (context, index) {
                        final bankDetails = cards[index];
                        return Container(
                          margin: const EdgeInsets.only(bottom: spacingMedium),
                          decoration: BoxDecoration(
                            border: Border.all(color: ColorUtils.borderColor),
                            borderRadius: BorderRadius.circular(4.0),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withAlpha(20),
                                blurRadius: 10.0,
                              )
                            ],
                            color: Colors.white,
                          ),
                          child: Padding(
                            padding: const EdgeInsets.fromLTRB(
                                spacingLarge, spacingTiny, 0.0, spacingMedium),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                      child: Text(
                                        bankDetails.maskedCardNo ?? '',
                                        style: const TextStyle(
                                            fontFamily: fontFamilyPoppinsMedium,
                                            fontSize: fontLarge,
                                            color: ColorUtils.secondaryColor),
                                      ),
                                    ),
                                    Row(
                                      children: [
                                        (bankDetails.isDefault ?? 0) == 1
                                            ? Padding(
                                                padding: const EdgeInsets.only(
                                                    right: spacingSmall),
                                                child: Image.asset(
                                                  ImageConstants.icStar,
                                                  scale: 2.8,
                                                ),
                                              )
                                            : const SizedBox(),
                                        PopupMenuButton<String>(
                                          padding: const EdgeInsets.all(0.0),
                                          onSelected: (choices) => {
                                            choiceAction(
                                                choices, bankDetails, myModel)
                                          },
                                          icon: Image.asset(
                                            ImageConstants.icMore,
                                            scale: 2.8,
                                          ),
                                          elevation: 1,
                                          itemBuilder: (context) {
                                            final items =
                                                <PopupMenuEntry<String>>[
                                              PopupMenuItem<String>(
                                                value: Localization.of(context)
                                                    .remove,
                                                child: Text(
                                                  Localization.of(context)
                                                      .remove,
                                                  style: const TextStyle(
                                                      fontSize: fontSmall,
                                                      color: ColorUtils
                                                          .merchantHomeRow),
                                                ),
                                              ),
                                            ];
                                            if ((bankDetails.isDefault ?? 0) ==
                                                0) {
                                              items.add(
                                                PopupMenuItem<String>(
                                                  value: Localization.of(
                                                          context)
                                                      .setAsPrimary,
                                                  child: Text(
                                                    Localization.of(context)
                                                        .setAsPrimary,
                                                    style: const TextStyle(
                                                      fontSize: fontSmall,
                                                      color: ColorUtils
                                                          .merchantHomeRow,
                                                    ),
                                                  ),
                                                ),
                                              );
                                            }
                                            return items;
                                          },
                                        )
                                      ],
                                    ),
                                  ],
                                ),
                                Row(
                                  children: [
                                    Text(bankDetails.bank ?? '',
                                        style: const TextStyle(
                                            fontFamily:
                                                fontFamilyPoppinsRegular,
                                            fontSize: fontSmall,
                                            color: ColorUtils.recentTextColor)),
                                  ],
                                ),
                                const SizedBox(
                                  height: spacingTiny,
                                ),
                                Row(
                                  children: [
                                    Text(bankDetails.expiry ?? '',
                                        style: const TextStyle(
                                            fontFamily:
                                                fontFamilyPoppinsRegular,
                                            fontSize: fontSmall,
                                            color: ColorUtils
                                                .cardExpireTextColor)),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  );
                }
              }
            },
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        heroTag: 'floatingButton',
        onPressed: chargeCard,
        backgroundColor: ColorUtils.primaryColor,
        child: Image.asset(
          ImageConstants.icAdd,
          scale: 2.5,
        ),
      ),
    );
  }

  Future<List<CardDetails>> _getBankDetails(BuildContext context) async {
    await UserApiManager().getCardDetails().then((value) {
      _list = value.data ?? <CardDetails>[];
    }).catchError((dynamic e) {
      if (e is ResBaseModel) {
        if (!checkSessionExpire(e, context)) {
          DialogUtils.showAlertDialog(context, e.error ?? '');
        }
      }
    });
    return _list;
  }

  void choiceAction(
      String choice, CardDetails bankDetail, BankDetailsProvider provider) {
    if (choice == Localization.of(context).remove) {
      DialogUtils.showOkCancelAlertDialog(
          context: context,
          message: Localization.of(context).msgRemoveBankAccount,
          okButtonTitle: Localization.of(context).ok,
          okButtonAction: () => {_removeBank(bankDetail, provider)},
          cancelButtonTitle: Localization.of(context).cancel,
          cancelButtonAction: () {},
          isCancelEnable: false);
    } else if (choice == Localization.of(context).setAsPrimary) {
      ProgressDialogUtils.showProgressDialog(context);
      UserApiManager()
          .setPrimaryCard(id: bankDetail.id ?? 0)
          .then((value) {
        ProgressDialogUtils.dismissProgressDialog();
        DialogUtils.displayToast(value.message ?? '');
        setState(() {
          _getBankDetails(context);
        });
      }).catchError((dynamic e) {
        ProgressDialogUtils.dismissProgressDialog();
        if (e is ResBaseModel) {
          if (!checkSessionExpire(e, context)) {
            debugPrint(e.error);
            DialogUtils.showAlertDialog(context, e.error ?? '');
          }
        }
      });
    }
  }

  void _removeBank(CardDetails bankDetail, BankDetailsProvider myModel) {
    ProgressDialogUtils.showProgressDialog(context);
    UserApiManager()
        .deleteCard(id: bankDetail.id ?? 0)
        .then((value) {
      ProgressDialogUtils.dismissProgressDialog();
      DialogUtils.displayToast(value.message ?? '');
      myModel.removeCardFromList(_list, bankDetail);
    }).catchError((dynamic e) {
      ProgressDialogUtils.dismissProgressDialog();
      if (e is ResBaseModel) {
        if (!checkSessionExpire(e, context)) {
          DialogUtils.showAlertDialog(context, e.message ?? '');
        }
      }
    });
  }

  String _getReference() {
    var userId = getInt(PreferenceKey.id).toString();
    String platform;
    if (Platform.isIOS) {
      platform = 'IOS';
    } else {
      platform = 'AN';
    }
    return """PAYMISH_${platform}_${userId}_${DateTime.now().millisecondsSinceEpoch}""";
  }

  void chargeCard() async {
    var charge = Charge()
      ..amount = 5000
      ..reference = _getReference()
      ..email = getString(PreferenceKey.email, "");
    var response = await paystackPlugin.checkout(
      context,
      method: CheckoutMethod.card,
      charge: charge,
    );
    if (response.status == true) {
      _addBank(response.reference ?? '');
    } else {
      DialogUtils.displayToast(Localization.of(context).processTerminated);
    }
  }

  void _addBank(String authID) {
    ProgressDialogUtils.showProgressDialog(context);
    UserApiManager().addCard(id: authID).then((value) {
      ProgressDialogUtils.dismissProgressDialog();
      DialogUtils.displayToast(value.message ?? '');
      setState(() {
        _getBankDetails(context);
      });
    }).catchError((dynamic e) {
      ProgressDialogUtils.dismissProgressDialog();
      if (e is ResBaseModel) {
        if (!checkSessionExpire(e, context)) {
          DialogUtils.showAlertDialog(context, e.message ?? '');
        }
      }
    });
  }
}
