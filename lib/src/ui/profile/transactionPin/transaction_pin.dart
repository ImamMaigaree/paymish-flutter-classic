import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_paystack/flutter_paystack.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:provider/provider.dart';

import '../../../apis/apimanager/user_api_manager.dart';
import '../../../apis/base_model.dart';
import '../../../apis/dic_params.dart';
import '../../../utils/app_config.dart';
import '../../../utils/color_utils.dart';
import '../../../utils/common_methods.dart';
import '../../../utils/constants.dart';
import '../../../utils/dialog_utils.dart';
import '../../../utils/dimens.dart';
import '../../../utils/enum_utils.dart';
import '../../../utils/image_constants.dart';
import '../../../utils/localization/localization.dart';
import '../../../utils/navigation.dart';
import '../../../utils/preference_key.dart';
import '../../../utils/preference_utils.dart';
import '../../../utils/progress_dialog.dart';
import '../../../utils/utils.dart';
import '../../../widgets/paymish_appbar.dart';
import '../../../widgets/paymish_primary_button.dart';
import '../../../widgets/pin_input_text_field.dart';
import '../../chat/model/req_approve_request.dart';
import '../../chat/model/req_pay_money.dart';
import '../../chat/provider/chat_payment_selection_provider.dart';
import '../../paymentSetting/model/res_bank_details.dart';
import '../../requestmoney/model/req_money.dart';
import '../../transfermoney/model/res_transfer_money_list.dart';
import '../../utilityServices/model/req_recharge.dart';
import '../wallet/model/req_topup_wallet.dart';
import '../wallet/withdrawMoney/provider/withdraw_money_provider.dart';
import 'model/req_access_code.dart';
import 'model/req_transaction_pin_validation.dart';
import 'model/req_withdraw_money_to_bank.dart';

// ignore: must_be_immutable
class TransactionPinScreen extends StatefulWidget {
  final num paymentAmount;
  final dynamic paymentDetails;
  final bool isPayMoney;
  final bool isTransferMoney;
  final bool isRequestMoney;
  final bool isCardPayment;
  final bool isBankPayment;
  final bool isNetBankingPayment;
  final bool isWithdrawMoneyToBank;
  final bool isDataRecharge;
  final bool isTvSubscription;
  final bool isElectricityBill;

  const TransactionPinScreen(
      {Key? key,
      this.paymentAmount = 0,
      this.paymentDetails,
      this.isTransferMoney = false,
      this.isRequestMoney = false,
      this.isCardPayment = false,
      this.isBankPayment = false,
      this.isPayMoney = false,
      this.isWithdrawMoneyToBank = false,
      this.isNetBankingPayment = false,
      this.isTvSubscription = false,
      this.isElectricityBill = false,
      this.isDataRecharge = false})
      : super(key: key);

  @override
  _TransactionPinScreenState createState() => _TransactionPinScreenState();
}

class _TransactionPinScreenState extends State<TransactionPinScreen> {
  late final FocusNode _transactionPinFocus;
  late final PinDecoration _transactionPinDecoration;
  late final TextEditingController _pinEditingController;
  String _transactionPin = '';

  dynamic bankDetails;
  bool isGeneratingCode = false;

  @override
  void initState() {
    initializeDateFormatting();
    paystackPlugin.initialize(publicKey: payStackKey ?? '');
    _transactionPinFocus = FocusNode();
    _transactionPinDecoration = UnderlineDecoration(
        enteredColor: ColorUtils.primaryColor,
        obscureStyle: ObscureStyle(isTextObscure: true));
    _pinEditingController = TextEditingController();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    // casting of dynamic paymentDetails into relevant model object
    if (widget.isCardPayment) {
      bankDetails = widget.paymentDetails as BankDetail;
    } else if (widget.isBankPayment) {
      bankDetails = widget.paymentDetails as BankDetail;
    } else if (widget.isTransferMoney) {
      bankDetails = widget.paymentDetails as TransferMoneyListData;
    } else if (widget.isRequestMoney) {
      bankDetails = widget.paymentDetails as ReqMoney;
    } else if (widget.isPayMoney) {
      bankDetails = widget.paymentDetails as ReqPayMoney;
    } else if (widget.isWithdrawMoneyToBank) {
      bankDetails = widget.paymentDetails as ReqWithdrawMoneyToBank;
    } else if (widget.isDataRecharge ||
        widget.isElectricityBill ||
        widget.isTvSubscription) {
      bankDetails = widget.paymentDetails as ReqRechargeModel;
    } else if (widget.isElectricityBill) {
      bankDetails = widget.paymentDetails as ReqRechargeModel;
    } else if (widget.isTvSubscription) {
      bankDetails = widget.paymentDetails as ReqRechargeModel;
    } else {
      bankDetails = widget.paymentDetails as BankDetail;
    }

    _transactionPin = "";
    _pinEditingController.clear();
    return Scaffold(
      appBar: PaymishAppBar(
        title: Localization.of(context).labelEnterTransactionPin,
        isBackGround: false,
        isFromAuth: false,
        isCloseIcon: true,
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  enterPinText(context),
                  transactionPinField(),
                ],
              ),
            ),
          ),
          proceedButtonWidget(context)
        ],
      ),
    );
  }

  Widget enterPinText(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: spacingXXXSLarge),
      child: Text(
        Localization.of(context).labelEnterPin,
        style: const TextStyle(
          fontSize: fontXMLarge,
          fontFamily: fontFamilyPoppinsMedium,
          color: ColorUtils.primaryColor,
          fontWeight: FontWeight.w500,
        ),
        maxLines: 1,
      ),
    );
  }

  Widget proceedButtonWidget(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(
          left: spacingLarge, right: spacingLarge, bottom: spacingLarge),
      child: PaymishPrimaryButton(
        buttonText: Localization.of(context).labelProceed,
        isBackground: true,
        onButtonClick: () {
          paymentTransaction(context);
        },
      ),
    );
  }

  void paymentTransaction(BuildContext context) {
    FocusScope.of(context).requestFocus(FocusNode());
    // relevant payment transaction API call
    if (_transactionPin.length != 4) {
      DialogUtils.displayToast(Localization.of(context).errorMinimumLength);
    } else {
      // To handle pin validation for both: request & transfer money
      _transactionPinValidation(context: context);
      _pinEditingController.clear();
    }
  }

  Future<void> _transactionPinValidation(
      {required BuildContext context}) async {
    ProgressDialogUtils.showProgressDialog(context);
    await UserApiManager()
        .validatePin(
            ReqTransactionPinValidation(
                transactionPin: _pinEditingController.text.trim()),
            context)
        .then((value) async {
      // If API response is SUCCESS
      // Navigation to relevant API call method if pin is valid
      if (value.data?.isValid == 1) {
        if (widget.isBankPayment) {
          await walletTopUpPayment(
              context: context,
              paidFrom: bankDetails.accountType == null
                  ? PaymentType.bank.getPaymentType()
                  : DicParams.card);
        } else if (widget.isRequestMoney) {
          await _requestPaymentPressed(context: context);
        } else if (widget.isTransferMoney) {
          if (Provider.of<ChatPaymentSelectionProvider>(context, listen: false)
                  .getSelectedRadioValue() ==
              "bank") {
            chargeCard();
          } else {
            await _approvePressed(context: context);
          }
        } else if (widget.isPayMoney) {
          if ((widget.paymentDetails as ReqPayMoney).paidFrom == "bank") {
            chargeCard();
          } else {
            await _payMoney(context: context);
          }
        } else if (widget.isWithdrawMoneyToBank) {
          await _withdrawMoneyToBank(context: context);
        } else if (widget.isDataRecharge) {
          if ((widget.paymentDetails as ReqRechargeModel).paidFrom == "bank") {
            chargeCard();
          } else {
            await _dataRecharge(context: context);
          }
        } else if (widget.isTvSubscription) {
          if ((widget.paymentDetails as ReqRechargeModel).paidFrom == "bank") {
            chargeCard();
          } else {
            await _tvSubscriptionRecharge(context: context);
          }
        } else if (widget.isElectricityBill) {
          if ((widget.paymentDetails as ReqRechargeModel).paidFrom == "bank") {
            chargeCard();
          } else {
            await _payElectricityBill(context: context);
          }
        }
      }
    }).catchError((dynamic e) {
      // If API response is FAILURE or ANY EXCEPTION
      ProgressDialogUtils.dismissProgressDialog();
      if (e is ResBaseModel) {
        DialogUtils.showAlertDialog(context, e.error ?? '');
      }
      NavigationUtils.pop(context);
    });
  }

  Future<void> _approvePressed(
      {required BuildContext context,
      String reference = '',
      String status = ''}) async {
    await UserApiManager()
        .approveRequest(
      ReqApproveRequest(
        payFrom:
            Provider.of<ChatPaymentSelectionProvider>(context, listen: false)
                .getSelectedRadioValue(),
        remarks: (widget.paymentDetails as TransferMoneyListData).remarks ?? '',
        cardId: (widget.paymentDetails as TransferMoneyListData).cardId ?? 0,
        requestId: (widget.paymentDetails as TransferMoneyListData).id ?? 0,
        reference: reference,
        status: status,
      ),
    )
        .then((value) {
      // If API response is SUCCESS
      // Update Provider to show the status in request widget

      ProgressDialogUtils.dismissProgressDialog();
      // To close bottom sheet
      NavigationUtils.pop(context);

      DialogUtils.showStatementDialog(
          image: ImageConstants.icSuccess,
          subHeaderText: Localization.of(context).successful,
          headerText:
              """${Localization.of(context).msgSuccessfulTransferred} ${Utils.currencyFormat.format((widget.paymentDetails as TransferMoneyListData).amount ?? 0)} to ${(widget.paymentDetails as TransferMoneyListData).firstName ?? ''} ${(widget.paymentDetails as TransferMoneyListData).lastName ?? ''}""",
          onOkClick: () {},
          context: context);
    }).catchError((dynamic e) {
      // If API response is FAILURE or ANY EXCEPTION
      ProgressDialogUtils.dismissProgressDialog();
      if (e is ResBaseModel) {
        DialogUtils.showAlertDialog(context, e.error ?? '');
        DialogUtils.displayToast(e.error ?? '');
        NavigationUtils.pop(context);
      }
      NavigationUtils.pop(context);
    });
  }

  Future<void> _payMoney(
      {required BuildContext context,
      String reference = '',
      String status = ''}) async {
    await UserApiManager()
        .payMoney(ReqPayMoney(
      paidFrom: (widget.paymentDetails as ReqPayMoney).paidFrom,
      amount: (widget.paymentDetails as ReqPayMoney).amount,
      remarks: (widget.paymentDetails as ReqPayMoney).remarks,
      payingTo: (widget.paymentDetails as ReqPayMoney).payingTo,
      cardId: (widget.paymentDetails as ReqPayMoney).cardId ?? 0,
      reference: reference,
      status: status,
    ))
        .then((value) {
      // If API response is SUCCESS
      // Update Provider to show the status in request widget
      final reqPayMoney = widget.paymentDetails as ReqPayMoney;
      ProgressDialogUtils.dismissProgressDialog();
      // To navigate to home screen
      NavigationUtils.pushAndRemoveUntil(
          context, isUserApp() ? routeMainTab : routeMerchantMainTab);

      DialogUtils.showStatementDialog(
          image: ImageConstants.icSuccess,
          subHeaderText: Localization.of(context).successful,
          headerText:
              """${Localization.of(context).msgSuccessfulSend} ${Utils.currencyFormat.format(reqPayMoney.amount ?? 0)} to ${reqPayMoney.payingTo ?? ''}""",
          onOkClick: () {},
          context: context);
    }).catchError((dynamic e) {
      // If API response is FAILURE or ANY EXCEPTION
      ProgressDialogUtils.dismissProgressDialog();
      if (e is ResBaseModel) {
        DialogUtils.showAlertDialog(context, e.error ?? '');
        DialogUtils.displayToast(e.error ?? '');
        NavigationUtils.pop(context);
      }
      NavigationUtils.pop(context);
    });
  }

  Future<void> _requestPaymentPressed({required BuildContext context}) async {
    await UserApiManager()
        .requestMoney(widget.paymentDetails as ReqMoney)
        .then((value) {
      // If API response is SUCCESS
      // Update Provider to show the status in request widget
      final reqMoney = widget.paymentDetails as ReqMoney;
      ProgressDialogUtils.dismissProgressDialog();
      // To close bottom sheet
      NavigationUtils.pop(context);
      // To navigate back to chat screen
      NavigationUtils.pop(context);
      DialogUtils.showStatementDialog(
          image: ImageConstants.icSuccess,
          subHeaderText: Localization.of(context).successful,
          headerText:
              """${Localization.of(context).msgSuccessfulRequested} ${Utils.currencyFormat.format(reqMoney.amount ?? 0)} to ${reqMoney.requestTo ?? ''}""",
          onOkClick: () {},
          context: context);
    }).catchError((dynamic e) {
      // If API response is FAILURE or ANY EXCEPTION
      ProgressDialogUtils.dismissProgressDialog();
      if (e is ResBaseModel) {
        DialogUtils.showAlertDialog(context, e.error ?? '');
        DialogUtils.displayToast(e.error ?? '');
        NavigationUtils.pop(context);
      }
      NavigationUtils.pop(context);
    });
  }

  Future<void> walletTopUpPayment(
      {required BuildContext context, required String paidFrom}) async {
    if (paidFrom == PaymentType.bank.getPaymentType()) {
      print("open bank UI");
      chargeCard();
    } else {
      await proccedForAddMoney(paidFrom, context);
    }
  }

  Future<void> proccedForAddMoney(String paidFrom, BuildContext context,
      {String reference = "", String status = ""}) async {
    await UserApiManager()
        .topUpWallet(ReqTopUpWallet(
            amount: widget.paymentAmount,
            paidFrom: paidFrom,
            cardId: bankDetails.id ?? 0,
            reference: reference,
            status: status))
        .then((value) async {
      // If API response is SUCCESS
      ProgressDialogUtils.dismissProgressDialog();
      DialogUtils.showStatementDialog(
          image: ImageConstants.icSuccess,
          subHeaderText: Localization.of(context).successful,
          headerText:
              """${Localization.of(context).msgSuccessfulAdded} ${Utils.currencyFormat.format(widget.paymentAmount)} ${Localization.of(context).msgToYourWallet}""",
          onOkClick: () {
            NavigationUtils.pushAndRemoveUntil(
                context, isUserApp() ? routeMainTab : routeMerchantMainTab);
          },
          context: context);
    }).catchError((dynamic e) {
      // If API response is FAILURE or ANY EXCEPTION
      ProgressDialogUtils.dismissProgressDialog();
      NavigationUtils.pop(context);
      if (e is ResBaseModel) {
        if (!checkSessionExpire(e, context)) {
          DialogUtils.showAlertDialog(context, e.error ?? '');
                } else {
          DialogUtils.showAlertDialog(context, e.message ?? '');
          DialogUtils.displayToast(e.error ?? '');
          NavigationUtils.pop(context);
        }
      } else {
        DialogUtils.showAlertDialog(context, e.toString());
      }
    });
  }

  Widget transactionPinField() {
    return Padding(
      padding: const EdgeInsets.only(left: spacingXLarge, right: imageSmall),
      child: PinInputTextField(
        pinLength: 4,
        focusNode: _transactionPinFocus,
        keyboardType: TextInputType.number,
        decoration: _transactionPinDecoration,
        controller: _pinEditingController,
        textInputAction: TextInputAction.done,
        autoFocus: true,
        onChanged: (pin) {
          _transactionPin = pin;
        },
        onSubmit: (pin) {
          if (pin.length == 4) {
            _transactionPin = pin;
          }
        },
      ),
    );
  }

  Future<void> _withdrawMoneyToBank({required BuildContext context}) async {
    await UserApiManager()
        .withdrawMoney(widget.paymentDetails as ReqWithdrawMoneyToBank)
        .then((value) {
      // If API response is SUCCESS
      // Update Provider to show the status in request widget
      ProgressDialogUtils.dismissProgressDialog();
      final amountDetails =
          Provider.of<WithdrawMoneyProvider>(context, listen: false).amountData;
      // To navigate to home screen
      NavigationUtils.pushAndRemoveUntil(
          context, isUserApp() ? routeMainTab : routeMerchantMainTab);
      DialogUtils.showStatementDialog(
          image: ImageConstants.icSuccess,
          subHeaderText: Localization.of(context).successful,
          headerText:
              """${Localization.of(context).msgSuccessfulTransferred} ${Utils.currencyFormat.format(amountDetails.data?.amount ?? 0)} to bank with charges ₦ ${Utils.currencyFormat.format((amountDetails.data?.withdrawalVatAmount ?? 0) + (amountDetails.data?.withdrawalCharges ?? 0))}""",
          onOkClick: () {},
          context: context);
    }).catchError((dynamic e) {
      // If API response is FAILURE or ANY EXCEPTION
      ProgressDialogUtils.dismissProgressDialog();
      if (e is ResBaseModel) {
        DialogUtils.showAlertDialog(context, e.error ?? '');
        DialogUtils.displayToast(e.error ?? '');
        NavigationUtils.pop(context);
      }
      NavigationUtils.pop(context);
    });
  }

  Future<void> _dataRecharge(
      {required BuildContext context,
      String reference = '',
      String status = ''}) async {
    await UserApiManager()
        .utilityRecharge(ReqRechargeModel(
            mobile: (widget.paymentDetails as ReqRechargeModel).mobile,
            serviceID: (widget.paymentDetails as ReqRechargeModel).serviceID,
            amount: (widget.paymentDetails as ReqRechargeModel).amount,
            type: (widget.paymentDetails as ReqRechargeModel).type,
            paidFrom: (widget.paymentDetails as ReqRechargeModel).paidFrom,
            variationCode:
                (widget.paymentDetails as ReqRechargeModel).variationCode,
            billersCode:
                (widget.paymentDetails as ReqRechargeModel).billersCode,
            reference: reference,
            status: status,
            cardId: (widget.paymentDetails as ReqRechargeModel).cardId ?? 0))
        .then((value) {
      // If API response is SUCCESS
      // Update Provider to show the status in request widget
      final reqPayMoney = widget.paymentDetails as ReqRechargeModel;
      ProgressDialogUtils.dismissProgressDialog();
      // To navigate to home screen
      NavigationUtils.pushAndRemoveUntil(
          context, isUserApp() ? routeMainTab : routeMerchantMainTab);
      DialogUtils.showStatementDialog(
          image: ImageConstants.icSuccess,
          subHeaderText: Localization.of(context).successful,
          headerText:
              """${Localization.of(context).msgSuccessfulTransferred} ${Utils.currencyFormat.format(reqPayMoney.amount ?? 0)} to ${reqPayMoney.serviceID ?? ''}""",
          onOkClick: () {},
          context: context);
    }).catchError((dynamic e) {
      // If API response is FAILURE or ANY EXCEPTION
      ProgressDialogUtils.dismissProgressDialog();
      if (e is ResBaseModel) {
        DialogUtils.showAlertDialog(context, e.error ?? '');
        DialogUtils.displayToast(e.error ?? '');
        NavigationUtils.pop(context);
      }
      NavigationUtils.pop(context);
    });
  }

  Future<void> _tvSubscriptionRecharge(
      {required BuildContext context,
      String reference = '',
      String status = ''}) async {
    await UserApiManager()
        .utilityTvSubscription(ReqRechargeModel(
            mobile: (widget.paymentDetails as ReqRechargeModel).mobile,
            serviceID: (widget.paymentDetails as ReqRechargeModel).serviceID,
            amount: (widget.paymentDetails as ReqRechargeModel).amount,
            type: (widget.paymentDetails as ReqRechargeModel).type,
            paidFrom: (widget.paymentDetails as ReqRechargeModel).paidFrom,
            variationCode:
                (widget.paymentDetails as ReqRechargeModel).variationCode,
            billersCode:
                (widget.paymentDetails as ReqRechargeModel).billersCode,
            reference: reference,
            status: status,
            cardId: (widget.paymentDetails as ReqRechargeModel).cardId ?? 0))
        .then((value) {
      // If API response is SUCCESS
      // Update Provider to show the status in request widget
      final reqPayMoney = widget.paymentDetails as ReqRechargeModel;
      ProgressDialogUtils.dismissProgressDialog();
      // To navigate to home screen
      NavigationUtils.pushAndRemoveUntil(
          context, isUserApp() ? routeMainTab : routeMerchantMainTab);
      DialogUtils.showStatementDialog(
          image: ImageConstants.icSuccess,
          subHeaderText: Localization.of(context).successful,
          headerText:
              """${Localization.of(context).msgSuccessfulTransferred} ${Utils.currencyFormat.format(reqPayMoney.amount ?? 0)} to ${reqPayMoney.serviceID ?? ''}""",
          onOkClick: () {},
          context: context);
    }).catchError((dynamic e) {
      // If API response is FAILURE or ANY EXCEPTION
      ProgressDialogUtils.dismissProgressDialog();
      if (e is ResBaseModel) {
        DialogUtils.showAlertDialog(context, e.error ?? '');
        DialogUtils.displayToast(e.error ?? '');
        NavigationUtils.pop(context);
      }
      NavigationUtils.pop(context);
    });
  }

  Future<void> _payElectricityBill(
      {required BuildContext context,
      String reference = '',
      String status = ''}) async {
    await UserApiManager()
        .utilityBillPayment(ReqRechargeModel(
            mobile: (widget.paymentDetails as ReqRechargeModel).mobile,
            serviceID: (widget.paymentDetails as ReqRechargeModel).serviceID,
            amount: (widget.paymentDetails as ReqRechargeModel).amount,
            type: (widget.paymentDetails as ReqRechargeModel).type,
            paidFrom: (widget.paymentDetails as ReqRechargeModel).paidFrom,
            variationCode:
                (widget.paymentDetails as ReqRechargeModel).variationCode,
            billersCode:
                (widget.paymentDetails as ReqRechargeModel).billersCode,
            reference: reference,
            status: status,
            cardId: (widget.paymentDetails as ReqRechargeModel).cardId ?? 0))
        .then((value) {
      // If API response is SUCCESS
      // Update Provider to show the status in request widget
      final reqPayMoney = widget.paymentDetails as ReqRechargeModel;
      ProgressDialogUtils.dismissProgressDialog();
      // To navigate to home screen
      NavigationUtils.pushAndRemoveUntil(
          context, isUserApp() ? routeMainTab : routeMerchantMainTab);
      DialogUtils.showStatementDialog(
          image: ImageConstants.icSuccess,
          subHeaderText: Localization.of(context).successful,
          headerText:
              """${Localization.of(context).msgSuccessfulTransferred} ${Utils.currencyFormat.format(reqPayMoney.amount ?? 0)} to ${reqPayMoney.serviceID ?? ''}""",
          onOkClick: () {},
          context: context);
    }).catchError((dynamic e) {
      // If API response is FAILURE or ANY EXCEPTION
      ProgressDialogUtils.dismissProgressDialog();
      if (e is ResBaseModel) {
        DialogUtils.showAlertDialog(context, e.error ?? '');
        DialogUtils.displayToast(e.error ?? '');
        NavigationUtils.pop(context);
      }
      NavigationUtils.pop(context);
    });
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
        .add(DiagnosticsProperty<num>('paymentAmount', widget.paymentAmount));
    properties
        .add(DiagnosticsProperty('paymentDetails', widget.paymentDetails));
    properties.add(DiagnosticsProperty<bool>('isPayMoney', widget.isPayMoney));
    properties.add(
        DiagnosticsProperty<bool>('isTransferMoney', widget.isTransferMoney));
    properties.add(
        DiagnosticsProperty<bool>('isRequestMoney', widget.isRequestMoney));
    properties
        .add(DiagnosticsProperty<bool>('isBankPayment', widget.isBankPayment));
    properties.add(DiagnosticsProperty<bool>(
        'isNetBankingPayment', widget.isNetBankingPayment));
    properties.add(DiagnosticsProperty<bool>(
        'isWithdrawMoneyToBank', widget.isWithdrawMoneyToBank));
    properties.add(
        DiagnosticsProperty<bool>('isDataRecharge', widget.isDataRecharge));
    properties.add(
        DiagnosticsProperty<bool>('isTvSubscription', widget.isTvSubscription));
    properties.add(DiagnosticsProperty<bool>(
        'isElectricityBill', widget.isElectricityBill));
    properties.add(DiagnosticsProperty('bankDetails', bankDetails));
    properties
        .add(DiagnosticsProperty<bool>('isCardPayment', widget.isCardPayment));
  }

  Future<void> chargeFromBank(String accessCode) async {
    setState(() {
      isGeneratingCode = !isGeneratingCode;
    });

    setState(() {
      isGeneratingCode = !isGeneratingCode;
    });

    await paystackPlugin.initialize(publicKey: payStackKey ?? '');

    var charge = Charge()
      ..amount = (widget.paymentAmount * 100).toInt()
      ..accessCode = accessCode
      ..email = getString(PreferenceKey.email, "") ?? '';
    var response = await paystackPlugin.checkout(
      context,
      method: CheckoutMethod.bank, // Defaults to CheckoutMethod.selectable
      charge: charge,
    );
    print("respone ==== $response");
    if (response.status == true) {
      sendStatus(response);
    } else {
      DialogUtils.displayToast(Localization.of(context).processTerminated);
      ProgressDialogUtils.dismissProgressDialog();
      NavigationUtils.pop(context);
    }
  }

  Future<void> sendStatus(CheckoutResponse response) async {
    final reference = response.reference ?? '';
    if (widget.isBankPayment) {
      proccedForAddMoney("bank", context,
          reference: reference, status: DicParams.success);
    } else if (widget.isPayMoney) {
      await _payMoney(
          context: context,
          reference: reference,
          status: DicParams.success);
    } else if (widget.isTransferMoney) {
      await _approvePressed(
          context: context,
          reference: reference,
          status: DicParams.success);
    } else if (widget.isDataRecharge) {
      await _dataRecharge(
          context: context,
          reference: reference,
          status: DicParams.success);
    } else if (widget.isTvSubscription) {
      await _tvSubscriptionRecharge(
          context: context,
          reference: reference,
          status: DicParams.success);
    } else if (widget.isElectricityBill) {
      await _payElectricityBill(
          context: context,
          reference: reference,
          status: DicParams.success);
    }
  }

  Future<void> chargeCard() async {
    await UserApiManager()
        .requestAccessCode(ReqAccessCode(
            amount: (widget.paymentAmount * 100).toInt().toString(),
            email: getString(PreferenceKey.email, "")))
        .then((value) {
      final accessCode = value.data?.accessCode ?? '';
      if (accessCode.isEmpty) {
        DialogUtils.displayToast(Localization.of(context).errorSomethingWentWrong);
        return;
      }
      chargeFromBank(accessCode);
        }).catchError((dynamic e) {
      ProgressDialogUtils.dismissProgressDialog();
      if (e is ResBaseModel) {
        DialogUtils.showAlertDialog(context, e.error ?? '');
        DialogUtils.displayToast(e.error ?? '');
        NavigationUtils.pop(context);
      }
      NavigationUtils.pop(context);
    });
  }
}
