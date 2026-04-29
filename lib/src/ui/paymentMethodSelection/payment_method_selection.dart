import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../../apis/apimanager/user_api_manager.dart';
import '../../apis/base_model.dart';
import '../../utils/color_utils.dart';
import '../../utils/common_methods.dart';
import '../../utils/constants.dart';
import '../../utils/dialog_utils.dart';
import '../../utils/dimens.dart';
import '../../utils/localization/localization.dart';
import '../../utils/navigation.dart';
import '../../utils/navigation_params.dart';
import '../../widgets/bank_card_radio_list.dart';
import '../paymentSetting/model/res_bank_details.dart';
import '../paymentSetting/model/res_card_listing.dart';

// ignore: must_be_immutable
class PaymentMethodSelection extends StatelessWidget {
  final num addToWalletAmount;
  final bool isFromTopUpWallet;
  final bool isWithdrawMoney;

  PaymentMethodSelection(
      {Key? key,
      this.addToWalletAmount = 0,
      this.isFromTopUpWallet = false,
      this.isWithdrawMoney = false})
      : super(key: key);

  List<BankDetail> _list = <BankDetail>[];
  List<CardDetails> _cardList = <CardDetails>[];
  final _selectedIndex = ValueNotifier<int>(0);
  final List<String> _popularBankOrder = const <String>[
    "GTBANK",
    "ACCESS",
    "UBA",
    "ZENITH",
    "FIRSTBANK",
    "FIDELITY",
  ];

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          FutureBuilder<List<BankDetail>>(
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
                  return Center(child: Text('Error: ${snapshot.error}'));
                } else {
                  final bankData = snapshot.data ?? <BankDetail>[];
                  // To visible Pay button with relevant payment type
                  return ListView(
                    shrinkWrap: true,
                    children: [
                      if (isWithdrawMoney) _popularBanksWidget(),
                      // Bank Details List From API
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: spacingLarge),
                        child: ValueListenableBuilder(
                          valueListenable: _selectedIndex,
                          builder: (context, selectedIndex, _) =>
                              ListView.builder(
                            primary: false,
                            shrinkWrap: true,
                            itemCount: bankData.length,
                            itemBuilder: (context, index) {
                              final bankDetails = bankData[index];
                              return BankCardRadioList(
                                index: index,
                                selectedIndex: selectedIndex,
                                bankDetail: bankDetails,
                                paymentAmount: addToWalletAmount,
                                isFromTopUpWallet: isFromTopUpWallet,
                                isWithdrawMoney: isWithdrawMoney,
                                onChanged: (ind) {
                                  _selectedIndex.value = ind ?? 0;
                                },
                              );
                            },
                          ),
                        ),
                      ),
                      isWithdrawMoney
                          ? const SizedBox()
                          : Column(
                              children: [
                                otherMethods(
                                    context, 0, "Bank", bankData.length),
                              ],
                            ),
                      // Debit Card
                      // Debit Card
                    ],
                  );
                }
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _popularBanksWidget() {
    final List<String> banks = const <String>[
      "GTBank",
      "Access",
      "UBA",
      "Zenith",
      "FirstBank",
      "Fidelity",
    ];
    return Container(
      margin: const EdgeInsets.fromLTRB(
        spacingLarge,
        spacingSmall,
        spacingLarge,
        spacingMedium,
      ),
      padding: const EdgeInsets.all(spacingSmall),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(spacingSmall),
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(16),
            blurRadius: spacingLarge,
          ),
        ],
      ),
      child: Wrap(
        spacing: spacingSmall,
        runSpacing: spacingSmall,
        children: banks
            .map(
              (name) => Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: spacingSmall,
                  vertical: spacingXSmall,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFEAF2F4),
                  borderRadius: BorderRadius.circular(spacingXLarge),
                ),
                child: Text(
                  name,
                  style: const TextStyle(
                    fontFamily: fontFamilyPoppinsMedium,
                    color: ColorUtils.primaryColor,
                    fontSize: fontXSmall,
                  ),
                ),
              ),
            )
            .toList(),
      ),
    );
  }

  int _popularBankRank(String? bankName) {
    final normalized = (bankName ?? "").toUpperCase();
    for (var i = 0; i < _popularBankOrder.length; i++) {
      if (normalized.contains(_popularBankOrder[i])) {
        return i;
      }
    }
    return 999;
  }

  Widget otherMethods(
      BuildContext context, int incrementCounter, String text, int count) {
    return Container(
      margin: const EdgeInsets.symmetric(
          vertical: spacingSmall, horizontal: spacingLarge),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(spacingTiny),
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(20),
            blurRadius: spacingLarge,
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: spacingTiny),
        child: ValueListenableBuilder(
          valueListenable: _selectedIndex,
          builder: (context, selectedIndex, _) => RadioGroup<int>(
            groupValue: selectedIndex,
            onChanged: (value) {
              if (value != null) {
                _selectedIndex.value = value;
              }
            },
            child: InkWell(
              onTap: () => _selectedIndex.value = count + incrementCounter,
              child: ListTile(
                leading: Radio(
                  value: count + incrementCounter,
                  activeColor: ColorUtils.primaryColor,
                ),
                title: Text(
                  text,
                  style: const TextStyle(
                    fontFamily: fontFamilyPoppinsMedium,
                    color: ColorUtils.primaryTextColor,
                    fontSize: fontMedium,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                trailing: count + incrementCounter == selectedIndex
                    ? ActionChip(
                        padding: const EdgeInsets.symmetric(
                            horizontal: spacingXSmall),
                        label: Text(
                          Localization.of(context).labelPay.toUpperCase(),
                          style: const TextStyle(
                            fontFamily: fontFamilyCovesBold,
                            fontSize: fontSmall,
                            color: Colors.white,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        backgroundColor: ColorUtils.primaryColor,
                        onPressed: () =>
                            payButtonClick(context, incrementCounter),
                      )
                    : const SizedBox(),
              ),
            ),
          ),
        ),
      ),
    );
  }

  void payButtonClick(BuildContext context, int incrementCounter) {
    // 1) Credit Card Payment
    // 2) Debit Card Payment
    // 3) Net Banking Payment
    if (incrementCounter == 0) {
      NavigationUtils.push(context, routeTransactionPin, arguments: {
        NavigationParams.paymentAmount: addToWalletAmount,
        NavigationParams.paymentDetails: BankDetail(),
        NavigationParams.isBankPayment: true,
        NavigationParams.isTransferMoney: false,
        NavigationParams.isRequestMoney: false,
        NavigationParams.isCardPayment: false,
        NavigationParams.isNetBankingPayment: false,
        NavigationParams.isDataRecharge: false,
        NavigationParams.isTvSubscription: false,
        NavigationParams.isElectricityBill: false,
      });

      // walletTopUpPayment(
      //     context: context, paidFrom: PaymentType.bank.getPaymentType());
    } else if (incrementCounter == 2) {
      // walletTopUpPayment(
      //     context: context, paidFrom: PaymentType.card.getPaymentType());
    } else {}
  }

  // To get all the bank _list
  Future<List<BankDetail>> _getBankDetails(BuildContext context) async {
    _list.clear();
    _cardList.clear();
    if (isWithdrawMoney) {
      await UserApiManager().getBankDetails().then((value) {
        _list = value.data ?? <BankDetail>[];
        _list.sort((a, b) {
          final rankA = _popularBankRank(a.bankName);
          final rankB = _popularBankRank(b.bankName);
          if (rankA != rankB) {
            return rankA.compareTo(rankB);
          }
          return (a.bankName ?? "").compareTo(b.bankName ?? "");
        });
      }).catchError((dynamic e) {
        if (e is ResBaseModel) {
          if (!checkSessionExpire(e, context)) {
            DialogUtils.showAlertDialog(context, e.error ?? '');
          }
        }
      });
    }
    if (!isWithdrawMoney) {
      await UserApiManager().getCardDetails().then((value) {
        _cardList = value.data ?? <CardDetails>[];
        for (var card in _cardList) {
          _list.add(BankDetail(
              id: card.id ?? 0,
              bankName: card.bank ?? '',
              maskedAccountNumber: card.maskedCardNo ?? '',
              accountType: "card",
              isDefault: card.isDefault ?? 0));
        }
      }).catchError((dynamic e) {
        if (e is ResBaseModel) {
          if (!checkSessionExpire(e, context)) {
            DialogUtils.showAlertDialog(context, e.error ?? '');
          }
        }
      });
    }
    return _list;
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
        .add(DiagnosticsProperty<num>('addToWalletAmount', addToWalletAmount));
    properties
        .add(DiagnosticsProperty<bool>('isFromTopUpWallet', isFromTopUpWallet));
    properties
        .add(DiagnosticsProperty<bool>('isWithdrawMoney', isWithdrawMoney));
  }
}
