import 'package:flutter/material.dart';
import 'package:flutter_native_timezone/flutter_native_timezone.dart';
import 'package:intl/intl.dart';

import '../../../apis/apimanager/user_api_manager.dart';
import '../../../apis/base_model.dart';
import '../../../utils/color_utils.dart';
import '../../../utils/common_methods.dart';
import '../../../utils/constants.dart';
import '../../../utils/dialog_utils.dart';
import '../../../utils/dimens.dart';
import '../../../utils/enum_utils.dart';
import '../../../utils/font_sizes.dart';
import '../../../utils/image_constants.dart';
import '../../../utils/localization/localization.dart';
import '../../../utils/navigation.dart';
import '../../../utils/preference_key.dart';
import '../../../utils/preference_utils.dart';
import '../../../utils/progress_dialog.dart';
import '../../../utils/utils.dart';
import '../../../widgets/paymish_appbar.dart';
import '../../../widgets/paymish_primary_button.dart';
import '../../../widgets/paymish_text_field.dart';

class RequestStatement extends StatefulWidget {
  const RequestStatement({Key? key}) : super(key: key);

  @override
  _RequestStatementState createState() => _RequestStatementState();
}

class _RequestStatementState extends State<RequestStatement> {
  final DateTime _currentDate = DateTime.now();
  final TextEditingController _endingController = TextEditingController();
  final TextEditingController _startingController = TextEditingController();
  late DateTime _startingDate;
  late DateTime _endingDate;
  String? _selectedPaymentType;
  String? _selectedChannelType;
  final GlobalKey<FormState> _key = GlobalKey<FormState>();
  final _paymentStatusList = [
    PaymentStatus.pending,
    PaymentStatus.success,
    PaymentStatus.failed
  ];
  final _channelList = [
    PaymentChannel.channel1,
    PaymentChannel.channel2,
    PaymentChannel.channel3,
    PaymentChannel.channel4,
    PaymentChannel.channel5,
    PaymentChannel.channel6,
    PaymentChannel.channel7,
    PaymentChannel.channel8,
    PaymentChannel.channel9,
    PaymentChannel.channel10,
    PaymentChannel.channel11,
    PaymentChannel.channel12,
  ];

  @override
  void initState() {
    super.initState();
    _startingDate = _currentDate;
    _endingDate = _currentDate;
  }

  // Call Date Picker and managed selected data from it
  Future<void> callDatePicker({bool isStartingDate = true}) async {
    final order = await getDateFromDatePicker(isStartingDate: isStartingDate);
    if (order == null) {
      return;
    }
    if (isStartingDate) {
      _startingDate = order;
      _startingController.text = "${order.day}/${order.month}/${order.year}";
    } else {
      _endingDate = order;
      _endingController.text = "${order.day}/${order.month}/${order.year}";
    }
  }

  // To call Date Picker With the range selection
  // Based on starting and ending date,
  Future<DateTime?> getDateFromDatePicker({bool isStartingDate = true}) {
    return showDatePicker(
      context: context,
      currentDate: _currentDate,
      confirmText: Localization.of(context).labelSelect.toUpperCase(),
      initialDate: isStartingDate
          ? DateTime(
              _startingDate.year,
              _startingDate.month,
              _startingDate.day,
            )
          : DateTime(
              _endingDate.year,
              _endingDate.month,
              _endingDate.day,
            ),
      // Allowed only last 3 months of starting date selection
      firstDate: isStartingDate
          ? DateTime(
              _currentDate.year - 3, _currentDate.month, _currentDate.day)
          : DateTime(
              _startingDate.year,
              _startingDate.month,
              _startingDate.day,
            ),
      lastDate:
          isStartingDate ? _endingDate : _currentDate,
      builder: (context, child) {
        return Theme(
          data: ThemeData.from(
              colorScheme: const ColorScheme(
                  primary: ColorUtils.primaryColor,
                  secondary: Colors.white,
                  surface: ColorUtils.whiteColorLight,
                  error: Colors.red,
                  onPrimary: Colors.white,
                  onSecondary: Colors.white,
                  onSurface: ColorUtils.primaryColor,
                  onError: Colors.red,
                  brightness: Brightness.light)),
          child: child ?? const SizedBox(),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PaymishAppBar(
        isBackGround: false,
        title: Localization.of(context).requestStatement,
      ),
      body: Form(
        key: _key,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(
                  left: spacingLarge, bottom: spacingSmall),
              child: Text(
                Localization.of(context).titleRequestStatement,
                style: const TextStyle(
                    fontSize: FontSizes.fontSize14,
                    fontFamily: fontFamilyPoppinsRegular,
                    fontWeight: FontWeight.w500,
                    color: ColorUtils.primaryTextColor),
                maxLines: 2,
              ),
            ),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                startDateWidget(context),
                endDateWidget(context),
              ],
            ),
            paymentStatusWidget(context),
            paymentChannelWidget(context),
            const Expanded(
              child: SizedBox(),
            ),
            submitButtonWidget(context)
          ],
        ),
      ),
    );
  }

  Widget paymentChannelWidget(BuildContext context) {
    return Container(
        padding: const EdgeInsets.only(
            top: spacingLarge, left: spacingLarge, right: spacingLarge),
        child: DropdownButtonFormField<String>(
          isExpanded: true,
          style: const TextStyle(
              color: ColorUtils.primaryColor,
              fontSize: fontLarge,
              fontFamily: fontFamilyPoppinsRegular),
          hint: Text(
            Localization.of(context).channelStatus,
            style: const TextStyle(color: ColorUtils.primaryColor),
          ),
          items: _channelList.map((value) {
            return DropdownMenuItem<String>(
              value: value.getPaymentChannel(),
              child: Text(toBeginningOfSentenceCase(value.getPaymentChannel()) ?? ''),
            );
          }).toList(),
          initialValue: _selectedChannelType,
          onChanged: (newValueSelected) {
            setState(() {
              _selectedChannelType = newValueSelected;
            });
          },
        ));
  }

  Widget paymentStatusWidget(BuildContext context) {
    return Container(
        padding: const EdgeInsets.only(
            top: spacingSmall, left: spacingLarge, right: spacingLarge),
        child: DropdownButtonFormField<String>(
          isExpanded: true,
          style: const TextStyle(
              color: ColorUtils.primaryColor,
              fontSize: fontLarge,
              fontFamily: fontFamilyPoppinsRegular),
          hint: Text(
            Localization.of(context).paymentStatus,
            style: const TextStyle(color: ColorUtils.primaryColor),
          ),
          items: _paymentStatusList.map((value) {
            return DropdownMenuItem<String>(
              value: value.getPaymentStatus(),
              child: Text(toBeginningOfSentenceCase(value.getPaymentStatus()) ?? ''),
            );
          }).toList(),
          initialValue: _selectedPaymentType,
          onChanged: (newValueSelected) {
            setState(() {
              _selectedPaymentType = newValueSelected;
            });
          },
        ));
  }

  Widget endDateWidget(BuildContext context) {
    return Flexible(
      child: GestureDetector(
        child: AbsorbPointer(
          child: Padding(
            padding:
                const EdgeInsets.only(left: spacingSmall, right: spacingLarge),
            child: PaymishTextField(
              trailingIcon: ImageConstants.icCalender,
              hint: Localization.of(context).labelEndDate,
              label: Localization.of(context).labelEndDate,
              controller: _endingController,
              validateFunction: (value) {
                return Utils.isEmpty(
                    context, value, Localization.of(context).errorEndDate);
              },
            ),
          ),
        ),
        onTap: () => callDatePicker(isStartingDate: false),
      ),
    );
  }

  Widget startDateWidget(BuildContext context) {
    return Flexible(
      child: GestureDetector(
        child: AbsorbPointer(
          child: Padding(
            padding:
                const EdgeInsets.only(left: spacingLarge, right: spacingSmall),
            child: PaymishTextField(
              trailingIcon: ImageConstants.icCalender,
              hint: Localization.of(context).labelStartDate,
              label: Localization.of(context).labelStartDate,
              controller: _startingController,
              validateFunction: (value) {
                return Utils.isEmpty(
                    context, value, Localization.of(context).errorStartDate);
              },
            ),
          ),
        ),
        onTap: () => callDatePicker(isStartingDate: true),
      ),
    );
  }

  Widget submitButtonWidget(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(
          left: spacingLarge, right: spacingLarge, bottom: spacingLarge),
      child: PaymishPrimaryButton(
        buttonText: Localization.of(context).labelSubmit,
        isBackground: true,
        onButtonClick: () => _submitPressed(context),
      ),
    );
  }

  // API Call for Request Wallet Statement Remaining
  Future<void> _submitPressed(BuildContext context) async {
    final currentTimeZone = await FlutterNativeTimezone.getLocalTimezone();
    if (_key.currentState?.validate() ?? false) {
      FocusScope.of(context).requestFocus(FocusNode());
      _key.currentState?.save();
      ProgressDialogUtils.showProgressDialog(context);
      await UserApiManager()
          .requestStatement(
              endDate: _endingController.text.trim(),
              startDate: _startingController.text.trim(),
              status: _selectedPaymentType ?? '',
              channel: _selectedChannelType ?? '',
              timeZone: currentTimeZone)
          .then((value) {
        ProgressDialogUtils.dismissProgressDialog();
        if (value.code == 200) {
          DialogUtils.showStatementDialog(
              context: context,
              image: ImageConstants.icStatement,
              headerText: Localization.of(context).msgStatementSendToEmail,
              subHeaderText: getString(PreferenceKey.email),
              onOkClick: () {
                NavigationUtils.pop(context);
              });
        } else {
          DialogUtils.displayToast(value.message ?? '');
        }
      }).catchError((dynamic e) {
        ProgressDialogUtils.dismissProgressDialog();
        if (e is ResBaseModel) {
          if (!checkSessionExpire(e, context)) {
            DialogUtils.showAlertDialog(context, e.error ?? '');
          }
        }
      });
    }
  }
}
