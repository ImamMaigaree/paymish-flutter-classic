import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../utils/color_utils.dart';
import '../../../../utils/constants.dart';
import '../../../../utils/dimens.dart';
import '../../../../utils/navigation.dart';
import '../../../../utils/navigation_params.dart';
import '../../../../utils/utils.dart';
import '../../../../widgets/paymish_appbar.dart';
import '../../../../widgets/paymish_primary_button.dart';
import '../../../paymentSetting/model/res_bank_details.dart';
import '../../transactionPin/model/req_withdraw_money_to_bank.dart';
import 'provider/withdraw_money_provider.dart';

class ReviewBankTransferScreen extends StatelessWidget {
  final num amount;
  final BankDetail bankDetail;

  const ReviewBankTransferScreen({
    Key? key,
    this.amount = 0,
    required this.bankDetail,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final amountData = context.watch<WithdrawMoneyProvider>().amountData.data;
    final transferFee =
        (amountData?.withdrawalCharges ?? 0) + (amountData?.withdrawalVatAmount ?? 0);
    final totalDebit = amountData?.netPayable ?? (amount + transferFee);
    final accountName = (bankDetail.bankHolderName ?? "").trim().isEmpty
        ? "Recipient"
        : (bankDetail.bankHolderName ?? "").trim();

    return Scaffold(
      appBar: const PaymishAppBar(
        title: "Review Transfer",
        isBackGround: false,
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(
                spacingLarge,
                spacingLarge,
                spacingLarge,
                spacingSmall,
              ),
              child: Column(
                children: [
                  _sectionCard(
                    title: "Beneficiary",
                    child: Column(
                      children: [
                        _kvRow(
                          label: "Bank",
                          valueWidget: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                bankDetail.bankName ?? "Bank",
                                style: _valueTextStyle(),
                              ),
                              const SizedBox(width: spacingXSmall),
                              Container(
                                width: 24,
                                height: 24,
                                decoration: const BoxDecoration(
                                  color: Color(0xFFEAF2F4),
                                  shape: BoxShape.circle,
                                ),
                                child: Center(
                                  child: Image.asset(
                                    'assets/images/ic_bank.png',
                                    width: 12,
                                    height: 12,
                                    color: ColorUtils.primaryColor,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        _kvRow(
                          label: "Account Number",
                          value: bankDetail.maskedAccountNumber ?? "",
                        ),
                        _kvRow(
                          label: "Account Name",
                          value: accountName,
                          hasDivider: false,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: spacingLarge),
                  _sectionCard(
                    title: "Breakdown",
                    child: Column(
                      children: [
                        _kvRow(
                          label: "Amount",
                          value: "₦ ${Utils.currencyFormat.format(amount)}",
                        ),
                        _kvRow(
                          label: "Transfer Fee",
                          value: "₦ ${Utils.currencyFormat.format(transferFee)}",
                        ),
                        _kvRow(
                          label: "Narration",
                          value: "Wallet withdrawal",
                        ),
                        _kvRow(
                          label: "Total Debit",
                          value: "₦ ${Utils.currencyFormat.format(totalDebit)}",
                          hasDivider: false,
                          valueStyle: const TextStyle(
                            fontFamily: fontFamilyPoppinsMedium,
                            color: ColorUtils.primaryColor,
                            fontSize: fontMedium,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(
              spacingLarge,
              spacingSmall,
              spacingLarge,
              spacingLarge,
            ),
            child: PaymishPrimaryButton(
              buttonText: "Proceed to PIN",
              isBackground: true,
              onButtonClick: () {
                NavigationUtils.push(context, routeTransactionPin, arguments: {
                  NavigationParams.paymentAmount: amount,
                  NavigationParams.paymentDetails: ReqWithdrawMoneyToBank(
                    amount: amount,
                    requestedAmount: amount,
                    accountId: bankDetail.id ?? 0,
                  ),
                  NavigationParams.isWithdrawMoneyToBank: true,
                  NavigationParams.isBankPayment: false,
                  NavigationParams.isTransferMoney: false,
                  NavigationParams.isRequestMoney: false,
                  NavigationParams.isCardPayment: false,
                  NavigationParams.isNetBankingPayment: false,
                  NavigationParams.isPayMoney: false,
                  NavigationParams.isDataRecharge: false,
                  NavigationParams.isTvSubscription: false,
                  NavigationParams.isElectricityBill: false,
                });
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionCard({required String title, required Widget child}) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(spacingSmall),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(20),
            blurRadius: spacingLarge,
          ),
        ],
      ),
      padding: const EdgeInsets.all(spacingLarge),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontFamily: fontFamilyPoppinsMedium,
              color: ColorUtils.primaryColor,
              fontSize: fontLarge,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: spacingSmall),
          child,
        ],
      ),
    );
  }

  Widget _kvRow({
    required String label,
    String? value,
    Widget? valueWidget,
    bool hasDivider = true,
    TextStyle? valueStyle,
  }) {
    final effectiveValueStyle = valueStyle ?? _valueTextStyle();
    return Container(
      padding: const EdgeInsets.symmetric(vertical: spacingSmall),
      decoration: BoxDecoration(
        border: hasDivider
            ? const Border(
                bottom: BorderSide(
                  color: ColorUtils.borderColor,
                  width: 0.8,
                ),
              )
            : null,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontFamily: fontFamilyPoppinsRegular,
              color: ColorUtils.merchantHomeRow,
              fontSize: fontSmall,
            ),
          ),
          valueWidget ??
              Text(
                value ?? "",
                style: effectiveValueStyle,
                textAlign: TextAlign.right,
              ),
        ],
      ),
    );
  }

  TextStyle _valueTextStyle() {
    return const TextStyle(
      fontFamily: fontFamilyPoppinsMedium,
      color: ColorUtils.primaryTextColor,
      fontSize: fontSmall,
      fontWeight: FontWeight.w500,
    );
  }
}
