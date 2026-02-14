import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_paystack/flutter_paystack.dart';
import 'package:provider/provider.dart';

import '../../apis/apimanager/user_api_manager.dart';
import '../../apis/base_model.dart';
import '../../apis/dic_params.dart';
import '../../utils/app_config.dart';
import '../../utils/color_utils.dart';
import '../../utils/common_methods.dart';
import '../../utils/constants.dart';
import '../../utils/dialog_utils.dart';
import '../../utils/dimens.dart';
import '../../utils/image_constants.dart';
import '../../utils/localization/localization.dart';
import '../../utils/navigation.dart';
import '../../utils/navigation_params.dart';
import '../../utils/preference_key.dart';
import '../../utils/preference_utils.dart';
import '../../utils/progress_dialog.dart';
import '../../widgets/paymish_appbar.dart';
import '../../widgets/paymish_primary_button.dart';
import '../../widgets/profile_image_view.dart';
import '../chat/model/req_pay_money.dart';
import '../profile/transactionPin/model/req_valid_amount.dart';
import '../requestmoney/model/req_money.dart';
import 'provider/pay_request_provider.dart';

class PayMoneyScreen extends StatefulWidget {
  final bool isPayScreen;

  const PayMoneyScreen({Key? key, this.isPayScreen = false}) : super(key: key);

  @override
  _PayMoneyScreenState createState() => _PayMoneyScreenState();

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(DiagnosticsProperty<bool>('isPayScreen', isPayScreen));
  }
}

class _PayMoneyScreenState extends State<PayMoneyScreen> {
  final FocusNode _payAmountFocus = FocusNode();
  final FocusNode _messageFocus = FocusNode();

  final TextEditingController _payAmountController = TextEditingController();
  final TextEditingController _messageController = TextEditingController();

  final GlobalKey<FormState> _key = GlobalKey<FormState>();

  double _containerWidth = 35.0;
  bool _errorVisible = false;

  @override
  void initState() {
    super.initState();
    paystackPlugin.initialize(publicKey: payStackKey ?? '');
    if (widget.isPayScreen) {
      _getBankDetails();
    }
  }

  @override
  void dispose() {
    _payAmountFocus.dispose();
    _messageFocus.dispose();
    _payAmountController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorUtils.primaryColor,
      appBar: PaymishAppBar(
        title: Localization.of(context).labelPayment,
        isBackGround: true,
      ),
      body: Form(
        autovalidateMode: AutovalidateMode.disabled,
        key: _key,
        child: SingleChildScrollView(
          child: Consumer<PayRequestProvider>(
            builder: (context, providerModel, child) => Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.only(top: 90.0),
                  child: transactionImages(providerModel),
                ),
                transactionDetail(context, providerModel),
                transactionAmountTextField(context),
                transactionMessageTextField(context),
                _errorVisible
                    ? Visibility(
                        child: Text(
                        Localization.of(context).errorPaymentAmount,
                        style: const TextStyle(
                            color: Colors.white,
                            fontFamily: fontFamilySFMonoMedium),
                      ))
                    : const SizedBox()
              ],
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        heroTag: 'floatingButton',
        onPressed: () {
          if (_payAmountFocus.hasFocus) {
            _payAmountFocus.unfocus();
            FocusScope.of(context).requestFocus(_messageFocus);
          } else {
            _payAmountFocus.unfocus();
            _messageFocus.unfocus();

            final amount =
                num.tryParse(_payAmountController.text.trim()) ?? 0;
            if (amount > 0) {
              setState(() {
                _errorVisible = false;
              });
              _key.currentState?.save();
              selectPaymentMethodDialog(context);
            } else {
              setState(() {
                _errorVisible = true;
              });
            }
          }
        },
        backgroundColor: Colors.white,
        child: _payAmountFocus.hasFocus && !_messageFocus.hasFocus
            ? const Icon(
                Icons.arrow_forward,
                color: ColorUtils.primaryColor,
                size: spacingXXXLarge,
              )
            : const Icon(
                Icons.done,
                color: ColorUtils.primaryColor,
                size: spacingXXXLarge,
              ),
      ),
    );
  }

  void selectPaymentMethodDialog(BuildContext context) {
    showModalBottomSheet(
      backgroundColor: Colors.transparent,
      context: context,
      builder: (ctx) => Consumer<PayRequestProvider>(
        builder: (context, providerModel, child) => Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
                topLeft: Radius.circular(spacingLarge),
                topRight: Radius.circular(spacingLarge)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.fromLTRB(
                    spacingMedium, spacingLarge, spacingMedium, spacingLarge),
                child: Text(
                  Localization.of(context).labelSelectPaymentMethod,
                  style: const TextStyle(
                      fontFamily: fontFamilyPoppinsMedium,
                      fontSize: fontLarger,
                      color: ColorUtils.recentTextColor),
                ),
              ),
              RadioGroup<String>(
                groupValue: providerModel.getSelectedRadioValue(),
                onChanged: (value) {
                  if (value != null) {
                    providerModel.setSelectedRadioValue(value);
                  }
                },
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _getWalletOption(providerModel, context),
                    _getBankOption(providerModel, context),
                    widget.isPayScreen
                        ? providerModel.getCardDetails().isNotEmpty
                            ? Column(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      GestureDetector(
                                        onTap: () {
                                          providerModel
                                              .setSelectedRadioValue(
                                                  DicParams.card);
                                        },
                                        child:
                                            _getCardDetailsRow(providerModel),
                                      ),
                                      _getCardNumber(providerModel)
                                    ],
                                  ),
                                  _changeCard(context, providerModel)
                                ],
                              )
                            : const SizedBox()
                        : const SizedBox(),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(
                    spacingMedium, spacing45, spacingMedium, spacingLarge),
                child: PaymishPrimaryButton(
                    buttonText: Localization.of(context).labelProceedToPayment,
                    isBackground: true,
                    onButtonClick: () async {
                      if (_key.currentState?.validate() ?? false) {
                        // To close bottom sheet
                        // To navigate to transaction pin screen
                        ProgressDialogUtils.showProgressDialog(context);
                        await UserApiManager()
                            .validateAmount(
                                ReqValidAmount(
                                    amount: num.parse(
                                        _payAmountController.text.trim()),
                                    payingTo: widget.isPayScreen
                                        ? (providerModel
                                                .getPaymentModel()
                                                .mobile ??
                                            '')
                                        : providerModel
                                                .getRequestModel()
                                                .mobile ??
                                            ''),
                                context)
                            .then((value) async {
                          // If API response is SUCCESS
                          ProgressDialogUtils.dismissProgressDialog();
                          if (value.data?.isValid == 1) {
                            _navigateToTransactionPinScreen(
                                context, providerModel);
                          } else {
                            await DialogUtils.displayToast(
                                value.data?.isValid?.toString() ?? '');
                          }
                        }).catchError((dynamic e) {
                          // If API response is FAILURE or ANY EXCEPTION
                          ProgressDialogUtils.dismissProgressDialog();
                          NavigationUtils.pop(context);
                          if (e is ResBaseModel) {
                            DialogUtils.showAlertDialog(
                                context, e.error ?? '');
                          }
                        });
                      }
                    }),
              )
            ],
          ),
        ),
      ),
    );
  }

  Padding _getCardNumber(PayRequestProvider providerModel) {
    return Padding(
      padding: const EdgeInsets.only(right: 10.0),
      child: Text(
        providerModel.getSelectedCard().maskedCardNo ?? '',
        style: TextStyle(color: ColorUtils.primaryColor, fontSize: fontSmall),
      ),
    );
  }

  Row _changeCard(BuildContext context, PayRequestProvider providerModel) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        InkWell(
          onTap: () {
            _openCardSelectionDialog(context, providerModel);
          },
          child: Padding(
            padding: const EdgeInsets.only(right: 10.0),
            child: Text(
              Localization.of(context).changeCard,
              style: TextStyle(
                  color: ColorUtils.primaryColor, fontSize: fontSmall),
            ),
          ),
        ),
      ],
    );
  }

  GestureDetector _getBankOption(
      PayRequestProvider providerModel, BuildContext context) {
    return GestureDetector(
      onTap: () => providerModel.setSelectedRadioValue(DicParams.bank),
      child: AbsorbPointer(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Radio(
              activeColor: ColorUtils.primaryColor,
              focusColor: ColorUtils.primaryColor,
              value: DicParams.bank,
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            Text(
              Localization.of(context).labelBank,
              style: const TextStyle(
                  fontFamily: fontFamilyPoppinsRegular,
                  fontSize: fontMedium,
                  color: ColorUtils.primaryTextColor),
            ),
          ],
        ),
      ),
    );
  }

  GestureDetector _getWalletOption(
      PayRequestProvider providerModel, BuildContext context) {
    return GestureDetector(
      onTap: () => {
        providerModel.setSelectedRadioValue(DicParams.wallet),
      },
      child: AbsorbPointer(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            Radio(
              activeColor: ColorUtils.primaryColor,
              focusColor: ColorUtils.primaryColor,
              value: DicParams.wallet,
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            Text(
              Localization.of(context).labelPaymishWallet,
              style: const TextStyle(
                  fontFamily: fontFamilyPoppinsRegular,
                  fontSize: fontMedium,
                  color: ColorUtils.primaryTextColor),
            ),
          ],
        ),
      ),
    );
  }

  Row _getCardDetailsRow(PayRequestProvider providerModel) {
    return Row(
      children: [
        Radio(
          activeColor: ColorUtils.primaryColor,
          focusColor: ColorUtils.primaryColor,
          value: DicParams.card,
          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
        ),
        Text(
          Localization.of(context).labelCard,
          style: const TextStyle(
              fontFamily: fontFamilyPoppinsRegular,
              fontSize: fontMedium,
              color: ColorUtils.primaryTextColor),
        ),
      ],
    );
  }

  void _navigateToTransactionPinScreen(
      BuildContext context, PayRequestProvider providerModel) {
    NavigationUtils.pop(context);
    if (widget.isPayScreen) {
      NavigationUtils.push(context, routeTransactionPin, arguments: {
        NavigationParams.paymentAmount:
            num.parse(_payAmountController.text.trim()),
        NavigationParams.paymentDetails: ReqPayMoney(
            amount: num.parse(_payAmountController.text.trim()),
            remarks: _messageController.text.trim(),
            paidFrom: providerModel.getSelectedRadioValue(),
            payingTo:
                int.tryParse(providerModel.getPaymentModel().mobile ?? '') ??
                    0,
            cardId: providerModel.getSelectedCard().id ?? 0),
        NavigationParams.isTransferMoney: false,
        NavigationParams.isPayMoney: true,
        NavigationParams.isRequestMoney: false,
        NavigationParams.isBankPayment: false,
        NavigationParams.isCardPayment: false,
        NavigationParams.isNetBankingPayment: false,
        NavigationParams.isDataRecharge: false,
        NavigationParams.isTvSubscription: false,
        NavigationParams.isElectricityBill: false,
      });
    } else {
      NavigationUtils.push(context, routeTransactionPin, arguments: {
        NavigationParams.paymentAmount:
            num.parse(_payAmountController.text.trim()),
        NavigationParams.paymentDetails: ReqMoney(
          amount: num.parse(_payAmountController.text.trim()),
          remarks: _messageController.text.trim(),
          paymentMethod: providerModel.getSelectedRadioValue(),
          requestTo:
              int.tryParse(providerModel.getRequestModel().mobile ?? '') ?? 0,
        ),
        NavigationParams.isTransferMoney: false,
        NavigationParams.isRequestMoney: true,
        NavigationParams.isBankPayment: false,
        NavigationParams.isPayMoney: false,
        NavigationParams.isCardPayment: false,
        NavigationParams.isNetBankingPayment: false,
        NavigationParams.isDataRecharge: false,
        NavigationParams.isTvSubscription: false,
        NavigationParams.isElectricityBill: false,
      });
    }
  }

  Widget transactionMessageTextField(BuildContext context) {
    return TextFormField(
      maxLength: 50,
      style: const TextStyle(color: Colors.white, fontSize: fontSmall),
      cursorColor: Colors.white,
      textAlign: TextAlign.center,
      textInputAction: TextInputAction.done,
      controller: _messageController,
      focusNode: _messageFocus,
      onFieldSubmitted: (value) {
        _messageFocus.unfocus();
      },
      decoration: InputDecoration(
          counterText: "",
          border: InputBorder.none,
          hintStyle: const TextStyle(
              color: ColorUtils.whiteColorLight, fontSize: fontSmall),
          hintText: Localization.of(context).hintWhatIsPaymentFor),
    );
  }

  Widget transactionAmountTextField(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 80),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Image.asset(
            ImageConstants.icNigeriaCurrencySymbol,
            height: 50.0,
            width: 40.0,
          ),
          Center(
            child: SizedBox(
              width: _containerWidth,
              child: TextFormField(
                controller: _payAmountController,
                focusNode: _payAmountFocus,
                cursorColor: Colors.white,
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: fontXXXXXLarge,
                    fontFamily: fontFamilyPoppinsMedium),
                inputFormatters: <TextInputFormatter>[
                  FilteringTextInputFormatter.allow(RegExp(decimalAmountRegex)),
                ],
                keyboardType: const TextInputType.numberWithOptions(
                    decimal: true, signed: false),
                textInputAction: TextInputAction.next,
                textAlign: TextAlign.start,
                onChanged: (value) {
                  if (value.length == 5) {
                    _payAmountFocus.unfocus();
                    FocusScope.of(context).requestFocus(_messageFocus);
                  }
                  if (value.isEmpty) {
                    setState(() {
                      _containerWidth = 35.0;
                    });
                  } else {
                    setState(() {
                      _containerWidth = value.length * 35.0;
                    });
                  }
                },
                onFieldSubmitted: (value) {
                  _payAmountFocus.unfocus();
                  FocusScope.of(context).requestFocus(FocusNode());
                },
                decoration: const InputDecoration(
                  hintText: "0",
                  counterText: "",
                  hintStyle: TextStyle(color: Colors.white, fontSize: 50),
                  border: InputBorder.none,
                ),
                maxLength: 5,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget transactionDetail(
      BuildContext context, PayRequestProvider providerModel) {
    return Text(
      widget.isPayScreen
          ? """${Localization.of(context).labelPayment} ${providerModel.getPaymentModel().firstName ?? ''} ${providerModel.getPaymentModel().lastName ?? ''}"""
          : """${Localization.of(context).labelRequestingFrom} ${providerModel.getRequestModel().firstName ?? ''} ${providerModel.getRequestModel().lastName ?? ''}""",
      style: const TextStyle(
          fontFamily: fontFamilyPoppinsRegular,
          fontSize: fontSmall,
          color: Colors.white),
    );
  }

  Widget transactionImages(PayRequestProvider providerModel) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        ProfileImageView(
          profileUrl: getString(PreferenceKey.profilePicture),
          largeSize: true,
        ),
        Padding(
          padding: const EdgeInsets.all(spacingLarge),
          child: Image.asset(
            ImageConstants.icArrow,
            scale: 2.5,
          ),
        ),
        ProfileImageView(
          profileUrl: widget.isPayScreen
              ? providerModel.getPaymentModel().profilePicture ?? ''
              : providerModel.getRequestModel().profilePicture ?? '',
          largeSize: true,
        )
      ],
    );
  }

  void _getBankDetails() async {
    await UserApiManager().getCardDetails().then((value) {
      Provider.of<PayRequestProvider>(context, listen: false)
          .setCardList(value.data ?? []);
    }).catchError((dynamic e) {
      if (e is ResBaseModel) {
        if (!checkSessionExpire(e, context)) {
          DialogUtils.showAlertDialog(context, e.error ?? '');
        }
      }
    });
  }

  void _openCardSelectionDialog(
      BuildContext context, PayRequestProvider providerModel) {
    NavigationUtils.pop(context);
    providerModel.setTemoSelectedCard(providerModel.getSelectedCard().id ?? 0);
    showModalBottomSheet(
        isDismissible: false,
        backgroundColor: Colors.transparent,
        context: context,
        builder: (ctx) => Consumer<PayRequestProvider>(
              builder: (context, providerModel, child) => Container(
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(spacingLarge),
                      topRight: Radius.circular(spacingLarge)),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.fromLTRB(spacingMedium,
                          spacingLarge, spacingMedium, spacingLarge),
                      child: Text(
                        Localization.of(context).selectCard,
                        style: const TextStyle(
                            fontFamily: fontFamilyPoppinsMedium,
                            fontSize: fontLarger,
                            color: ColorUtils.recentTextColor),
                      ),
                    ),
                    providerModel.getCardDetails().isNotEmpty
                        ? RadioGroup<int>(
                            groupValue: providerModel.getTempSelectedCard(),
                            onChanged: (value) {
                              if (value != null) {
                                providerModel.setTemoSelectedCard(value);
                              }
                            },
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                for (var card
                                    in providerModel.getCardDetails())
                                  GestureDetector(
                                    onTap: () => {
                                      providerModel.setTemoSelectedCard(
                                          card.id ?? 0)
                                    },
                                    child: AbsorbPointer(
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Row(
                                            children: [
                                              Radio(
                                                activeColor:
                                                    ColorUtils.primaryColor,
                                                focusColor:
                                                    ColorUtils.primaryColor,
                                                value: card.id ?? 0,
                                                materialTapTargetSize:
                                                    MaterialTapTargetSize
                                                        .shrinkWrap,
                                              ),
                                              Text(
                                                card.maskedCardNo ?? '',
                                                style: const TextStyle(
                                                    fontFamily:
                                                        fontFamilyPoppinsRegular,
                                                    fontSize: fontMedium,
                                                    color: ColorUtils
                                                        .primaryTextColor),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                  )
                              ],
                            ),
                          )
                        : const SizedBox(),
                    _addNewCardText(),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(spacingMedium,
                          spacingXXLarge, spacingMedium, spacingLarge),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _getCancelButton(context),
                          _getSelectButton(context, providerModel)
                        ],
                      ),
                    )
                  ],
                ),
              ),
            ));
  }

  Row _addNewCardText() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        InkWell(
          onTap: chargeCard,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(
                spacingMedium, spacingLarge, spacingMedium, spacingLarge),
            child: Text(
              Localization.of(context).addNewCard,
              style: const TextStyle(
                  fontFamily: fontFamilyPoppinsMedium,
                  fontSize: fontLarger,
                  color: ColorUtils.recentTextColor),
            ),
          ),
        ),
      ],
    );
  }

  Widget _getSelectButton(
      BuildContext context, PayRequestProvider providerModel) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.only(
          left: spacingSmall,
        ),
        child: PaymishPrimaryButton(
            buttonText: Localization.of(context).labelSelect,
            isBackground: true,
            onButtonClick: () async {
              providerModel
                  .setSelectedCardId(providerModel.getTempSelectedCard());
              NavigationUtils.pop(context);
              selectPaymentMethodDialog(context);
            }),
      ),
    );
  }

  Widget _getCancelButton(BuildContext context) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.only(
          right: spacingSmall,
        ),
        child: PaymishPrimaryButton(
            buttonText: Localization.of(context).cancel,
            isBackground: false,
            onButtonClick: () async {
              NavigationUtils.pop(context);
              selectPaymentMethodDialog(context);
            }),
      ),
    );
  }

  void chargeCard() async {
    var charge = Charge()
      ..amount = 5000
      ..reference = _getReference()
      ..email = getString(PreferenceKey.email, "");
    final plugin = paystackPlugin;
    var response = await plugin.checkout(
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

  void _addBank(String authID) {
    ProgressDialogUtils.showProgressDialog(context);
    UserApiManager().addCard(id: authID).then((value) {
      ProgressDialogUtils.dismissProgressDialog();
      DialogUtils.displayToast(value.message ?? '');
      setState(_getBankDetails);
    }).catchError((dynamic e) {
      ProgressDialogUtils.dismissProgressDialog();
      if (e is ResBaseModel) {
        if (!checkSessionExpire(e, context)) {
          DialogUtils.showAlertDialog(
              context,
              e.message ??
                  e.error ??
                  Localization.of(context).errorSomethingWentWrong);
        }
      }
    });
  }
}
