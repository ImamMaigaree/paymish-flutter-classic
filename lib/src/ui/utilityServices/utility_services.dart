import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_paystack/flutter_paystack.dart';
import 'package:intl/intl.dart';
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
import '../../utils/enum_utils.dart';
import '../../utils/image_constants.dart';
import '../../utils/localization/localization.dart';
import '../../utils/navigation.dart';
import '../../utils/navigation_params.dart';
import '../../utils/preference_key.dart';
import '../../utils/preference_utils.dart';
import '../../utils/progress_dialog.dart';
import '../../utils/utils.dart';
import '../../widgets/paymish_appbar.dart';
import '../../widgets/paymish_menu_list_item.dart';
import '../../widgets/paymish_primary_button.dart';
import '../../widgets/paymish_text_field.dart';
import '../auth/home/model/res_home.dart';
import '../chat/provider/chat_payment_selection_provider.dart';
import '../paymentSetting/model/res_card_listing.dart';
import 'model/req_recharge.dart';
import 'model/req_verify_numbers.dart';
import 'provider/utility_service_provider.dart';

// ignore: must_be_immutable
class UtilityServicesScreen extends StatefulWidget {
  final Services services;

  const UtilityServicesScreen({Key? key, required this.services})
      : super(key: key);

  @override
  _UtilityServicesScreenState createState() => _UtilityServicesScreenState();

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(DiagnosticsProperty<Services>('services', services));
  }
}

class _UtilityServicesScreenState extends State<UtilityServicesScreen> {
  String _meterType = "";
  bool _isNumberChanged = true;

  final TextEditingController _phoneNumberController = TextEditingController();

  TextEditingController _amountController = TextEditingController();
  TextEditingController _customerNameController = TextEditingController();
  final FocusNode _amountFocus = FocusNode();

  final TextEditingController _smartCardNumberController =
      TextEditingController();

  final TextEditingController _meterNumberController = TextEditingController();

  final GlobalKey<FormState> _globalKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    Provider.of<UtilityServiceProvider>(context, listen: false).clearData();
    setState(() {
      _meterType = DicParams.prepaid;
    });
    _getBankDetails();
    paystackPlugin.initialize(publicKey: payStackKey ?? '');
  }

  @override
  void dispose() {
    _amountFocus.dispose();
    _amountController.dispose();
    _customerNameController.dispose();
    _phoneNumberController.dispose();
    _smartCardNumberController.dispose();
    _meterNumberController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final identifier = widget.services.identifier ?? '';
    return Scaffold(
        backgroundColor: Colors.white,
        appBar: PaymishAppBar(
          title: toBeginningOfSentenceCase(identifier) ?? '',
          isBackGround: false,
        ),
        body: Form(
          autovalidateMode: AutovalidateMode.disabled, key: _globalKey,
          child: Consumer<UtilityServiceProvider>(
            builder: (context, myModel, child) => Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    child: Padding(
                      padding: const EdgeInsets.only(
                          left: spacingLarge,
                          right: spacingLarge,
                          bottom: spacingXXXXLarge),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              _getImageOfService(),
                              _getServiceNameAndDetail()
                            ],
                          ),
                          const SizedBox(height: spacingLarge),
                          widget.services.identifier == DicParams.tvSubscription
                              ? _getTextForTvSubscription()
                              : const SizedBox(),
                          widget.services.identifier ==
                                  DicParams.electricityBill
                              ? Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Padding(
                                      padding:
                                          EdgeInsets.only(bottom: spacingSmall),
                                      child: Text(
                                        "Prepaid and Postpaid IKEDC payment.",
                                        style: TextStyle(
                                            fontSize: fontMedium,
                                            color: Colors.grey,
                                            fontFamily:
                                                fontFamilyPoppinsRegular),
                                      ),
                                    ),
                                    const Text(
                                      """Select "Prepaid" if you load token on your meter. Select "Postpaid" if you get a bill at the end of the month.""",
                                      style: TextStyle(
                                          fontSize: fontMedium,
                                          color: Colors.grey,
                                          fontFamily: fontFamilyPoppinsRegular),
                                    ),
                                  ],
                                )
                              : const SizedBox(),
                          widget.services.identifier == DicParams.data ||
                                  widget.services.identifier ==
                                      DicParams.tvSubscription
                              ? PaymishMenuListItem(
                                  titleText:
                                      myModel.selectedDataPlan.vairationName ??
                                          '',
                                  onClick: () {
                                    widget.services.identifier == DicParams.data
                                        ? NavigationUtils.push(
                                            context, routeDataTypeListing,
                                            arguments: {
                                                NavigationParams.services:
                                                    widget.services
                                              })
                                        : NavigationUtils.push(
                                            context, routeBouquetListing,
                                            arguments: {
                                                NavigationParams.services:
                                                    widget.services
                                              });
                                  },
                                )
                              : const SizedBox(),
                          const SizedBox(height: spacingLarge),
                          widget.services.identifier ==
                                  DicParams.electricityBill
                              ? _getOptionsForAccount()
                              : const SizedBox(),
                          _getPhoneNumberTextField(context),
                          const SizedBox(height: spacingLarge),
                          _getAmountTextField(context, myModel.amount),
                          const SizedBox(height: spacingLarge),
                          widget.services.identifier == DicParams.tvSubscription
                              ? _getSmartCardNumberTextField(context)
                              : const SizedBox(),
                          widget.services.identifier ==
                                  DicParams.electricityBill
                              ? _getMeterNumberTextField(context)
                              : const SizedBox(),
                          const SizedBox(height: spacingLarge),
                          myModel.customerName.isNotEmpty
                              ? _getCustomerNameTextField(
                                  context, myModel.customerName)
                              : const SizedBox()
                        ],
                      ),
                    ),
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: <Widget>[
                    _getCancelButton(context),
                    _getContinueButton(context),
                  ],
                )
              ],
            ),
          ),
        ));
  }

  Widget _getTextForTvSubscription() => RichText(
        text: const TextSpan(
            text: "Note",
            style: TextStyle(
                color: Colors.pink,
                fontSize: fontMedium,
                fontFamily: fontFamilyPoppinsRegular),
            children: <TextSpan>[
              TextSpan(
                text:
                    """ that the following bouquets (DStv Access, \nDStv Family) have been removed by DSTV and \nreplaced with (DStv Padi, DStv Yanga and DStv \nConfam). \n \nThe prices of all the bouquets have also been adjusted by DStv to reflect the VAT rate \nadjustment.""",
                style: TextStyle(
                  fontSize: fontMedium,
                  fontFamily: fontFamilyPoppinsRegular,
                  color: Colors.grey,
                ),
              )
            ]),
      );

  Widget _getOptionsForAccount() => Padding(
        padding: const EdgeInsets.fromLTRB(
            0.0, spacingSmall, spacingSmall, spacingMedium),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              Localization.of(context).labelMeterType,
              style: const TextStyle(
                  fontSize: fontLarge,
                  fontFamily: fontFamilyPoppinsMedium,
                  color: ColorUtils.primaryColor),
            ),
            RadioGroup<String>(
              groupValue: _meterType,
              onChanged: (value) {
                setState(() {
                  _meterType = value ?? _meterType;
                });
              },
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  Radio(
                    activeColor: ColorUtils.primaryColor,
                    focusColor: ColorUtils.primaryColor,
                    value: DicParams.prepaid,
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  Text(Localization.of(context).labelPrepaid),
                  Radio(
                    activeColor: ColorUtils.primaryColor,
                    focusColor: ColorUtils.primaryColor,
                    value: DicParams.postpaid,
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  Text(Localization.of(context).labelPostPaid),
                ],
              ),
            ),
          ],
        ),
      );

  Widget _getContinueButton(BuildContext context) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.only(
            left: spacingSmall, right: spacingLarge, bottom: spacingLarge),
        child: PaymishPrimaryButton(
          buttonText: Localization.of(context).labelContinue,
          isBackground: true,
          onButtonClick: () {
            if (widget.services.identifier == DicParams.tvSubscription ||
                widget.services.identifier == DicParams.data) {
              checkValues(context);
                        } else {
              checkValues(context);
            }
          },
        ),
      ),
    );
  }

  void checkValues(BuildContext context) {
    _globalKey.currentState?.save();
    if (_globalKey.currentState?.validate() ?? false) {
      _verifyPressed(context);
    }
  }

  Widget _getCancelButton(BuildContext context) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.only(
            left: spacingLarge, right: spacingSmall, bottom: spacingLarge),
        child: PaymishPrimaryButton(
          buttonText: Localization.of(context).cancel,
          isBackground: false,
          onButtonClick: () {
            NavigationUtils.pop(context);
          },
        ),
      ),
    );
  }

  Widget _getAmountTextField(BuildContext context, String amount) {
    _syncAmountController(amount);
    return PaymishTextField(
      controller: _amountController,
      focusNode: _amountFocus,
      hint: Localization.of(context).hintEnterAmount,
      label: Localization.of(context).hintEnterAmount,
      enabled: (widget.services.identifier == DicParams.airtime) ||
              (widget.services.identifier == DicParams.electricityBill)
          ? true
          : false,
      textInputFormatter: <TextInputFormatter>[
        FilteringTextInputFormatter.allow(RegExp(decimalAmountRegex)),
      ],
      type: const TextInputType.numberWithOptions(decimal: true, signed: false),
      textInputAction: TextInputAction.done,
      onChanged: (value) {
        Provider.of<UtilityServiceProvider>(context, listen: false)
            .setAmount(value);
      },
      onFieldSubmitted: (_) {
        FocusScope.of(context).requestFocus(FocusNode());
      },
      maxLength: 10,
      validateFunction: (value) {
        return (widget.services.identifier == DicParams.airtime) ||
                (widget.services.identifier == DicParams.electricityBill)
            ? Utils.isValidMinimumMoneyAmount(
                context,
                value ?? '',
                widget.services.minimumAmount ?? 0,
                widget.services.maximumAmount ?? 0)
            : null;
      },
    );
  }

  void _syncAmountController(String amount) {
    if (amount.isEmpty) {
      return;
    }
    if (_amountController.text == amount) {
      return;
    }
    if (_amountFocus.hasFocus) {
      return;
    }
    _amountController.text = amount;
    _amountController.selection = TextSelection.fromPosition(
      TextPosition(offset: _amountController.text.length),
    );
  }

  Widget _getCustomerNameTextField(BuildContext context, String customerName) {
    _customerNameController = TextEditingController(text: customerName);
    return PaymishTextField(
      controller: _customerNameController,
      label: Localization.of(context).labelCustomerName,
      hint: Localization.of(context).labelCustomerName,
      enabled: false,
    );
  }

  Widget _getPhoneNumberTextField(BuildContext context) {
    return PaymishTextField(
      controller: _phoneNumberController,
      hint: Localization.of(context).phoneNumber,
      label: Localization.of(context).phoneNumber,
      type: TextInputType.number,
      textInputFormatter: <TextInputFormatter>[
        FilteringTextInputFormatter.digitsOnly
      ],
      maxLength: 10,
      isLeadingIcon: true,
      leadingIcon: ImageConstants.icNigeria,
      prefixCountryCode: countryCode,
      validateFunction: (value) {
        return Utils.isMobileNumberValid(context, value ?? '');
      },
    );
  }

  Widget _getSmartCardNumberTextField(BuildContext context) {
    return PaymishTextField(
      controller: _smartCardNumberController,
      hint: Localization.of(context).labelSmartCardNumber,
      label: Localization.of(context).labelSmartCardNumber,
      maxLength: 20,
      onChanged: (value) {
        _isNumberChanged = true;
      },
      validateFunction: (value) {
        return Utils.isEmpty(context, value ?? '',
            Localization.of(context).errorSmartCardNumber);
      },
    );
  }

  Widget _getMeterNumberTextField(BuildContext context) {
    return PaymishTextField(
      controller: _meterNumberController,
      hint: Localization.of(context).labelMeterNumber,
      label: Localization.of(context).labelMeterNumber,
      maxLength: 13,
      type: TextInputType.number,
      onChanged: (value) {
        _isNumberChanged = true;
      },
      textInputFormatter: <TextInputFormatter>[
        FilteringTextInputFormatter.digitsOnly
      ],
      validateFunction: (value) {
        return Utils.isValidMeterNumber(context, value);
      },
    );
  }

  Widget _getServiceNameAndDetail() {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            widget.services.name ?? '',
            style: const TextStyle(
                fontFamily: fontFamilyPoppinsMedium,
                fontSize: font22,
                color: ColorUtils.primaryColor),
          ),
          widget.services.identifier == DicParams.electricityBill ||
                  widget.services.identifier == DicParams.tvSubscription
              ? const SizedBox()
              : Text("Airtel airtime - Get instant top up",
                  style: TextStyle(
                      fontFamily: fontFamilyPoppinsRegular,
                      fontSize: fontMedium,
                      color: ColorUtils.merchantHomeRow
                          .withValues(alpha: 0.5))),
        ],
      ),
    );
  }

  Widget _getImageOfService() {
    final imageUrl = widget.services.image ?? '';
    return Container(
      margin: const EdgeInsets.only(right: spacingMedium),
      height: spacingXXXXXLarge,
      width: spacingXXXXXLarge,
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
    );
  }

  void _verifyPressed(BuildContext context) {
    Provider.of<UtilityServiceProvider>(context, listen: false)
        .setAmount(_amountController.text);
    if ((widget.services.identifier == DicParams.tvSubscription ||
            widget.services.identifier == DicParams.electricityBill) &&
        _isNumberChanged) {
      ProgressDialogUtils.showProgressDialog(context);
      if (widget.services.identifier == DicParams.electricityBill) {
        UserApiManager()
            .verifyMeterNumber(ReqVerifyNumbers(
          serviceID: widget.services.serviceID ?? '',
          billersCode: _meterNumberController.text.trim(),
          variationCode: _meterType,
        ))
            .then((value) {
          _isNumberChanged = false;
          ProgressDialogUtils.dismissProgressDialog();
          Provider.of<UtilityServiceProvider>(context, listen: false)
              .setCustomerName(value.data?.customerName ?? '');
        }).catchError((dynamic e) {
          ProgressDialogUtils.dismissProgressDialog();
          if (e is ResBaseModel) {
            if (!checkSessionExpire(e, context)) {
              DialogUtils.showAlertDialog(context, e.error ?? '');
            }
          }
        });
      } else {
        UserApiManager()
            .verifySmartCardNumber(ReqVerifyNumbers(
          serviceID: widget.services.serviceID ?? '',
          billersCode: _smartCardNumberController.text.trim(),
        ))
            .then((value) {
          _isNumberChanged = false;
          ProgressDialogUtils.dismissProgressDialog();
          Provider.of<UtilityServiceProvider>(context, listen: false)
              .setCustomerName(value.data?.customerName ?? '');
        }).catchError((dynamic e) {
          ProgressDialogUtils.dismissProgressDialog();
          if (e is ResBaseModel) {
            if (!checkSessionExpire(e, context)) {
              DialogUtils.showAlertDialog(context, e.error ?? '');
            }
          }
        });
      }
      FocusScope.of(context).unfocus();
    } else {
      payMoneyClicked(context);
    }
  }

  void payMoneyClicked(BuildContext context) {
    showModalBottomSheet(
        backgroundColor: Colors.transparent,
        context: context,
        // We had to define Consumer again for bottomSheet
        // reason: bottom sheet doesn't belong to scaffold,
        // bottom sheet is it's an individual component with scaffold
        builder: (ctx) => Consumer<ChatPaymentSelectionProvider>(
              builder: (context, providerModel, child) => Container(
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(spacingLarge),
                    topRight: Radius.circular(spacingLarge),
                  ),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    moneyAmountWidget(),
                    sendMoneyDetails(),
                    labelSelectPaymentMethod(context),
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
                          walletRadioSelection(providerModel, context),
                          bankRadioSelection(providerModel, context),
                          providerModel.getCardDetails().isNotEmpty
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
                              : const SizedBox(),
                        ],
                      ),
                    ),
                    proceedButton(providerModel, context)
                  ],
                ),
              ),
            ));
  }

  Padding _getCardNumber(ChatPaymentSelectionProvider providerModel) {
    return Padding(
      padding: const EdgeInsets.only(right: 10.0),
      child: Text(
        providerModel.getSelectedCard().maskedCardNo ?? '',
        style: TextStyle(color: ColorUtils.primaryColor, fontSize: fontSmall),
      ),
    );
  }

  Row _changeCard(
      BuildContext context, ChatPaymentSelectionProvider providerModel) {
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

  Row _getCardDetailsRow(ChatPaymentSelectionProvider providerModel) {
    return Row(
      children: [
        Radio(
          activeColor: ColorUtils.primaryColor,
          focusColor: ColorUtils.primaryColor,
          value: DicParams.card,
          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
        ),
        Text(
          """Card""",
          style: const TextStyle(
              fontFamily: fontFamilyPoppinsRegular,
              fontSize: fontMedium,
              color: ColorUtils.primaryTextColor),
        ),
      ],
    );
  }

  Widget cardRadioSelection(
      ChatPaymentSelectionProvider providerModel, BuildContext context) {
    return GestureDetector(
      onTap: () => {
        providerModel.setSelectedRadioValue(DicParams.card),
      },
      child: AbsorbPointer(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            Radio(
              activeColor: ColorUtils.primaryColor,
              focusColor: ColorUtils.primaryColor,
              value: DicParams.card,
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            Text(
              Localization.of(context).labelCreditDebitCard,
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

  Widget moneyAmountWidget() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
          spacingMedium, spacingMedium, spacingMedium, spacingTiny),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Image.asset(
            ImageConstants.icNigeriaCurrencySymbol,
            color: ColorUtils.merchantHomeRow,
            scale: 4.0,
          ),
          Padding(
            padding: const EdgeInsets.only(left: spacingTiny),
            child: Text(
              Utils.currencyFormat.format(num.parse(_amountController.text)),
              style: const TextStyle(
                  color: ColorUtils.merchantHomeRow,
                  fontSize: fontXXXXXLarge,
                  fontFamily: fontFamilyPoppinsRegular),
            ),
          ),
        ],
      ),
    );
  }

  Widget sendMoneyDetails() {
    return Padding(
      padding: const EdgeInsets.only(
          left: spacingMedium, right: spacingMedium, bottom: spacingLarge),
      child: Text(
        """${Localization.of(context).lblYouAreSendingTo} ${widget.services.name}""",
        style: const TextStyle(
            fontFamily: fontFamilyPoppinsMedium,
            fontSize: fontSmall,
            color: ColorUtils.primaryTextColor),
      ),
    );
  }

  Widget labelSelectPaymentMethod(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(spacingMedium),
      child: Text(
        Localization.of(context).labelSelectPaymentMethod,
        style: const TextStyle(
            color: ColorUtils.recentTextColor,
            fontSize: fontMedium,
            fontFamily: fontFamilyPoppinsMedium),
      ),
    );
  }

  Widget proceedButton(
      ChatPaymentSelectionProvider providerModel, BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
          spacingMedium, spacing45, spacingMedium, spacingLarge),
      child: PaymishPrimaryButton(
        buttonText: Localization.of(context).labelProceed,
        isBackground: true,
        onButtonClick: () {
          if (widget.services.identifier == DicParams.airtime) {
            // To close the bottom sheet
            NavigationUtils.pop(context);
            // To navigate to transaction pin screen with data
            NavigationUtils.push(context, routeTransactionPin, arguments: {
              NavigationParams.paymentAmount: num.parse(_amountController.text),
              NavigationParams.paymentDetails: ReqRechargeModel(
                  amount: num.parse(_amountController.text.trim()),
                  mobile: _phoneNumberController.text.trim(),
                  paidFrom: Provider.of<ChatPaymentSelectionProvider>(context,
                          listen: false)
                      .getSelectedRadioValue(),
                  serviceID: widget.services.serviceID ?? '',
                  type: widget.services.identifier ==
                          UtilityRechargeIdentifier.data.getType()
                      ? UtilityRecharge.dataRecharge.getType()
                      : UtilityRecharge.recharge.getType(),
                  cardId: Provider.of<ChatPaymentSelectionProvider>(context,
                                  listen: false)
                              .getSelectedRadioValue() ==
                          "card"
                      ? providerModel.getSelectedCard().id ?? 0
                      : 0),
              NavigationParams.isTransferMoney: false,
              NavigationParams.isRequestMoney: false,
              NavigationParams.isBankPayment: false,
              NavigationParams.isCardPayment: false,
              NavigationParams.isPayMoney: false,
              NavigationParams.isWithdrawMoneyToBank: false,
              NavigationParams.isNetBankingPayment: false,
              NavigationParams.isDataRecharge: true,
              NavigationParams.isTvSubscription: false,
              NavigationParams.isElectricityBill: false,
            });
          } else if (widget.services.identifier == DicParams.data) {
            // To close the bottom sheet
            NavigationUtils.pop(context);
            // To navigate to transaction pin screen with data
            NavigationUtils.push(context, routeTransactionPin, arguments: {
              NavigationParams.paymentAmount: num.parse(_amountController.text),
              NavigationParams.paymentDetails: ReqRechargeModel(
                  amount: num.parse(_amountController.text.trim()),
                  mobile: _phoneNumberController.text.trim(),
                  paidFrom: Provider.of<ChatPaymentSelectionProvider>(context,
                          listen: false)
                      .getSelectedRadioValue(),
                  serviceID: widget.services.serviceID ?? '',
                  variationCode: Provider.of<UtilityServiceProvider>(context,
                          listen: false)
                      .selectedDataPlan
                      .variationCode ??
                      '',
                  type: widget.services.identifier ==
                          UtilityRechargeIdentifier.data.getType()
                      ? UtilityRecharge.dataRecharge.getType()
                      : UtilityRecharge.recharge.getType(),
                  cardId: Provider.of<ChatPaymentSelectionProvider>(context,
                                  listen: false)
                              .getSelectedRadioValue() ==
                          "card"
                      ? providerModel.getSelectedCard().id ?? 0
                      : 0),
              NavigationParams.isTransferMoney: false,
              NavigationParams.isRequestMoney: false,
              NavigationParams.isBankPayment: false,
              NavigationParams.isCardPayment: false,
              NavigationParams.isPayMoney: false,
              NavigationParams.isWithdrawMoneyToBank: false,
              NavigationParams.isNetBankingPayment: false,
              NavigationParams.isDataRecharge: true,
              NavigationParams.isTvSubscription: false,
              NavigationParams.isElectricityBill: false,
            });
          } else if (widget.services.identifier == DicParams.tvSubscription) {
            // To close the bottom sheet
            NavigationUtils.pop(context);
            // To navigate to transaction pin screen with data
            NavigationUtils.push(context, routeTransactionPin, arguments: {
              NavigationParams.paymentAmount: num.parse(_amountController.text),
              NavigationParams.paymentDetails: ReqRechargeModel(
                  amount: num.parse(_amountController.text.trim()),
                  mobile: _phoneNumberController.text.trim(),
                  paidFrom: Provider.of<ChatPaymentSelectionProvider>(context,
                          listen: false)
                      .getSelectedRadioValue(),
                  serviceID: widget.services.serviceID ?? '',
                  billersCode: _smartCardNumberController.text.trim(),
                  variationCode: Provider.of<UtilityServiceProvider>(context,
                          listen: false)
                      .selectedDataPlan
                      .variationCode ??
                      '',
                  cardId: Provider.of<ChatPaymentSelectionProvider>(context,
                                  listen: false)
                              .getSelectedRadioValue() ==
                          "card"
                      ? providerModel.getSelectedCard().id ?? 0
                      : 0),
              NavigationParams.isTransferMoney: false,
              NavigationParams.isRequestMoney: false,
              NavigationParams.isBankPayment: false,
              NavigationParams.isCardPayment: false,
              NavigationParams.isPayMoney: false,
              NavigationParams.isWithdrawMoneyToBank: false,
              NavigationParams.isNetBankingPayment: false,
              NavigationParams.isDataRecharge: false,
              NavigationParams.isTvSubscription: true,
              NavigationParams.isElectricityBill: false,
            });
          } else if (widget.services.identifier == DicParams.electricityBill) {
            // To close the bottom sheet
            NavigationUtils.pop(context);
            // To navigate to transaction pin screen with data
            NavigationUtils.push(context, routeTransactionPin, arguments: {
              NavigationParams.paymentAmount: num.parse(_amountController.text),
              NavigationParams.paymentDetails: ReqRechargeModel(
                  amount: num.parse(_amountController.text.trim()),
                  mobile: _phoneNumberController.text.trim(),
                  paidFrom: Provider.of<ChatPaymentSelectionProvider>(context,
                          listen: false)
                      .getSelectedRadioValue(),
                  serviceID: widget.services.serviceID ?? '',
                  billersCode: _meterNumberController.text.trim(),
                  variationCode: _meterType,
                  cardId: Provider.of<ChatPaymentSelectionProvider>(context,
                                  listen: false)
                              .getSelectedRadioValue() ==
                          "card"
                      ? providerModel.getSelectedCard().id ?? 0
                      : 0),
              NavigationParams.isTransferMoney: false,
              NavigationParams.isRequestMoney: false,
              NavigationParams.isBankPayment: false,
              NavigationParams.isCardPayment: false,
              NavigationParams.isPayMoney: false,
              NavigationParams.isWithdrawMoneyToBank: false,
              NavigationParams.isNetBankingPayment: false,
              NavigationParams.isDataRecharge: false,
              NavigationParams.isTvSubscription: false,
              NavigationParams.isElectricityBill: true,
            });
          } else {
            NavigationUtils.pop(context);
          }
        },
      ),
    );
  }

  Widget bankRadioSelection(
      ChatPaymentSelectionProvider providerModel, BuildContext context) {
    return GestureDetector(
      onTap: () => providerModel.setSelectedRadioValue(DicParams.bank),
      child: AbsorbPointer(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            Radio(
              value: DicParams.bank,
              activeColor: ColorUtils.primaryColor,
              focusColor: ColorUtils.primaryColor,
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

  Widget walletRadioSelection(
      ChatPaymentSelectionProvider providerModel, BuildContext context) {
    return GestureDetector(
      onTap: () => providerModel.setSelectedRadioValue(DicParams.wallet),
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

  void billPaymentApiCall() {
    ProgressDialogUtils.showProgressDialog(context);
    UserApiManager().utilityBillPayment(ReqRechargeModel()).then((value) {
      ProgressDialogUtils.dismissProgressDialog();
      DialogUtils.displayToast(value.message ?? '');
    }).catchError((dynamic e) {
      ProgressDialogUtils.dismissProgressDialog();
      if (e is ResBaseModel) {
        if (!checkSessionExpire(e, context)) {
          DialogUtils.showAlertDialog(context, e.error ?? '');
        }
      }
    });
  }

  void _getBankDetails() async {
    await UserApiManager().getCardDetails().then((value) {
      Provider.of<ChatPaymentSelectionProvider>(context, listen: false)
          .setCardList(value.data ?? <CardDetails>[]);
    }).catchError((dynamic e) {
      if (e is ResBaseModel) {
        if (!checkSessionExpire(e, context)) {
          DialogUtils.showAlertDialog(context, e.error ?? '');
        }
      }
    });
  }

  void _openCardSelectionDialog(
      BuildContext context, ChatPaymentSelectionProvider providerModel) {
    NavigationUtils.pop(context);
    providerModel.setTemoSelectedCard(providerModel.getSelectedCard().id ?? 0);
    showModalBottomSheet(
        isDismissible: false,
        backgroundColor: Colors.transparent,
        context: context,
        builder: (ctx) => Consumer<ChatPaymentSelectionProvider>(
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
                                      providerModel
                                          .setTemoSelectedCard(card.id ?? 0)
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
                          _getCancelButtonForCard(context),
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
      BuildContext context, ChatPaymentSelectionProvider providerModel) {
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
              payMoneyClicked(context);
            }),
      ),
    );
  }

  Widget _getCancelButtonForCard(BuildContext context) {
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
              payMoneyClicked(context);
            }),
      ),
    );
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
      DialogUtils.displayToast("Process cancelled");
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
          DialogUtils.showAlertDialog(context, e.message ?? '');
        }
      }
    });
  }
}
