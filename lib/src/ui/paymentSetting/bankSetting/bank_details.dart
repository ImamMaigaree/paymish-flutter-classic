import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../apis/apimanager/user_api_manager.dart';
import '../../../apis/base_model.dart';
import '../../../main.dart';
import '../../../utils/color_utils.dart';
import '../../../utils/common_methods.dart';
import '../../../utils/constants.dart';
import '../../../utils/dialog_utils.dart';
import '../../../utils/dimens.dart';
import '../../../utils/image_constants.dart';
import '../../../utils/localization/localization.dart';
import '../../../utils/navigation.dart';
import '../../../utils/progress_dialog.dart';
import '../../../widgets/paymish_appbar.dart';
import '../model/res_bank_details.dart';
import '../provider/bank_details_provider.dart';

class BankDetailsScreen extends StatefulWidget {
  const BankDetailsScreen({Key? key}) : super(key: key);

  @override
  _BankDetailsScreenState createState() => _BankDetailsScreenState();
}

class _BankDetailsScreenState extends State<BankDetailsScreen>
    with
// ignore: prefer_mixin
        RouteAware {
  List<BankDetail> _list = <BankDetail>[];

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
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: PaymishAppBar(
        title: Localization.of(context).labelBankDetails,
        isBackGround: false,
      ),
      body: Padding(
        padding: const EdgeInsets.only(
            left: spacingLarge, right: spacingLarge, top: spacingLarge),
        child: Container(
          child: FutureBuilder<List<BankDetail>>(
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
                final banks = snapshot.data ?? <BankDetail>[];
                if (banks.isEmpty) {
                  return Center(
                      child: Text(
                          Localization.of(context).labelNoBankDetailsFound));
                } else {
                  return Consumer<BankDetailsProvider>(
                    builder: (context, myModel, child) => ListView.builder(
                      itemCount: banks.length,
                      itemBuilder: (context, index) {
                        final bankDetails = banks[index];
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
                                        bankDetails.bankName ?? '',
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
                                    Text(bankDetails.maskedAccountNumber ?? '',
                                        style: const TextStyle(
                                            fontFamily:
                                                fontFamilyPoppinsRegular,
                                            fontSize: fontMedium,
                                            color: ColorUtils.recentTextColor)),
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
        onPressed: () {
          NavigationUtils.push(context, routeAddBankDetails);
        },
        backgroundColor: ColorUtils.primaryColor,
        child: Image.asset(
          ImageConstants.icAdd,
          scale: 2.5,
        ),
      ),
    );
  }

  Future<List<BankDetail>> _getBankDetails(BuildContext context) async {
    await UserApiManager().getBankDetails().then((value) {
      _list = value.data ?? <BankDetail>[];
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
      String choice, BankDetail bankDetail, BankDetailsProvider provider) {
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
          .setPrimaryBankAccount(id: bankDetail.id ?? 0)
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

  void _removeBank(BankDetail bankDetail, BankDetailsProvider myModel) {
    ProgressDialogUtils.showProgressDialog(context);
    UserApiManager()
        .deleteBankAccount(id: bankDetail.id ?? 0)
        .then((value) {
      ProgressDialogUtils.dismissProgressDialog();
      DialogUtils.displayToast(value.message ?? '');
      myModel.removeBankFromList(_list, bankDetail);
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
