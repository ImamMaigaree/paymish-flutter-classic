import 'package:date_format/date_format.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';
import 'package:libphonenumber/libphonenumber.dart';

import '../utils/localization/localization.dart';
import 'constants.dart';

// ignore: avoid_classes_with_only_static_members
class Utils {
  static bool isEmailValid(String value) {
    const pattern =
        r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$';
    final regex = RegExp(pattern);
    if (!regex.hasMatch(value)) {
      return true;
    } else {
      return false;
    }
  }

  static InputDecoration styleInputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      labelStyle: styleTextStyleTextField(),
      counterText: "",
      border: const OutlineInputBorder(),
    );
  }

  static TextStyle styleTextStyleTextField() {
    return const TextStyle(
      fontSize: 20,
    );
  }

  static String? isValidEmail(BuildContext context, String? value) {
    final emailValue = value ?? '';
    if (emailValue.isEmpty) {
      return Localization.of(context).msgEnterAddress;
    } else if (Utils.isEmailValid(emailValue)) {
      return Localization.of(context).msgEnterValidAddress;
    } else {
      return null;
    }
  }

  static String? isEmpty(BuildContext context, String? value, String message) {
    if ((value ?? '').trim().isEmpty) {
      return message;
    } else {
      return null;
    }
  }

  static String? isValidMoneyAmount(BuildContext context, String value) {
    if (value.trim().isEmpty) {
      return Localization.of(context).errorAmount;
    } else if (num.parse(value) == 0) {
      return Localization.of(context).errorValidAmount;
    } else {
      return null;
    }
  }

  static String? isValidMinimumMoneyAmount(BuildContext context, String value,
      num minimumAmount, num maximumAmount) {
    if (value.trim().isEmpty) {
      return Localization.of(context).errorAmount;
    } else if (num.parse(value) == 0) {
      return Localization.of(context).errorValidAmount;
    } else if (num.parse(value) < minimumAmount) {
      return """${Localization.of(context).msgMinimumAmountRequired} $minimumAmount""";
    } else if (num.parse(value) > maximumAmount) {
      return """${Localization.of(context).msgMaximumAmountRequired} $maximumAmount""";
    } else {
      return null;
    }
  }

  static String? isValidAndBoundedAmount(
      BuildContext context, String enteredAmount, String walletAmount) {
    if (enteredAmount.trim().isEmpty) {
      return Localization.of(context).errorAmount;
    } else if (num.parse(enteredAmount) == 0) {
      return Localization.of(context).errorValidAmount;
    } else if (num.parse(enteredAmount) < 20) {
      return Localization.of(context).errorMinimumWithdrawAmount;
    } else if (num.parse(enteredAmount) > num.parse(walletAmount)) {
      return Localization.of(context).errorValidAndBoundedAmount;
    } else {
      return null;
    }
  }

  static String? isValidPin(
      BuildContext context, String? value, String errorString) {
    final pinValue = value ?? '';
    if (pinValue.isEmpty) {
      return errorString;
    } else if (pinValue.length != 4) {
      return Localization.of(context).errorMinimumLength;
    } else {
      return null;
    }
  }

  static String? isValidBVN(BuildContext context, String? value) {
    final bvnValue = value ?? '';
    if (bvnValue.isEmpty) {
      return Localization.of(context).errorBVNNumber;
    } else if (bvnValue.length != 11) {
      return Localization.of(context).errorValidBVNNumber;
    } else {
      return null;
    }
  }

  static String? isValidAccountNumber(BuildContext context, String? value) {
    final accountValue = value ?? '';
    if (accountValue.trim().isEmpty) {
      return Localization.of(context).errorAccountNumber;
    } else if (accountValue.length < 8) {
      return Localization.of(context).errorInvalidAccountNumber;
    } else {
      return null;
    }
  }

  static String? isPinValueSame(
      BuildContext context, String value1, String value2, String errorText) {
    if (value1.isEmpty) {
      return Localization.of(context).errorConfirmTransActionPin;
    } else if (value1 != value2) {
      return errorText;
    } else {
      return null;
    }
  }

  static String? isMobileNumberValid(BuildContext context, String? value) {
    final mobileValue = value ?? '';
    const pattern = r'(^(?:[+0]9)?[0-9]{10,12}$)';
    final regExp = RegExp(pattern);
    if (mobileValue.isEmpty) {
      return Localization.of(context).msgEnterMobile;
    } else if (!regExp.hasMatch(mobileValue)) {
      return Localization.of(context).errorValidMobileNumber;
    }
    return null;
  }

  static bool isPasswordValidate(String? value) {
    final passwordValue = value ?? '';
    const pattern =
        r'^(?=.*?[A-Z])(?=.*?[a-z])(?=.*?[0-9])(?=.*?[!@#\$&*~]).{8,}$';
    final regex = RegExp(pattern);
    if (passwordValue.isEmpty) {
      return false;
    } else if (!regex.hasMatch(passwordValue)) {
      return true;
    } else {
      return false;
    }
  }

  static String? isValidPassword(BuildContext context, String? value) {
    if ((value ?? '').isEmpty) {
      return Localization.of(context).errorPassword;
    } else if (Utils.isPasswordValidate(value)) {
      return Localization.of(context).errorValidPassword;
    } else {
      return null;
    }
  }

  static String? isValidConfirmPassword(BuildContext context, String? value) {
    if ((value ?? '').isEmpty) {
      return Localization.of(context).errorConfirmPassword;
    } else if (Utils.isPasswordValidate(value)) {
      return Localization.of(context).errorValidPassword;
    } else {
      return null;
    }
  }

  // Is Password and ConfirmPassword are SAME or DIFFERENT
  static String? isPasswordMatched(
      BuildContext context, String password, String confirmPassword) {
    if (password.isEmpty || confirmPassword.isEmpty) {
      return Localization.of(context).errorConfirmPassword;
    } else if (password != confirmPassword) {
      return Localization.of(context).errorDiffPassword;
    } else {
      return null;
    }
  }

  static Future<String> formatMobileNumber(String value) async {
//    String countryCode;
//    try {
//      countryCode = await FlutterSimCountryCode.simCountryCode;
//      if (countryCode == null || countryCode.isEmpty) {
//        countryCode = countryCodeNG;
//      }
//    } on Exception {
//      countryCode = countryCodeNG;
//    }

    final formatNumber = value.replaceAll(RegExp(r'[^+\d]+'), '');

    try {
      final normalizedNumber = await PhoneNumberUtil.normalizePhoneNumber(
          phoneNumber: formatNumber, isoCode: countryCodeNG);
      return normalizedNumber ?? formatNumber;
    } on PlatformException {
      return formatNumber;
    }
  }

  static NumberFormat currencyFormat = NumberFormat.currency(symbol: "");

  static String convertDateFromString(String strDate, BuildContext context) {
    initializeDateFormatting();

    final givenDate = DateFormat(dateFormatServerDate).parse(strDate, true);
    final nowDate = DateTime.now().toUtc();
    final difference = nowDate.difference(givenDate);
    if (difference.inMinutes < 1) {
      return Localization.of(context).labelJustNow;
    } else if (difference.inMinutes < 60) {
      return """${difference.inMinutes} ${Localization.of(context).labelMinutesAgo}""";
    } else if (difference.inHours < 24) {
      return "${difference.inHours} ${Localization.of(context).labelHoursAgo}";
    } else if (difference.inDays <= 2) {
      return "${difference.inDays} ${Localization.of(context).labelDayAgo}";
    } else {
      return formatDate(givenDate, [dd, '/', mm, '/', yyyy]);
    }
  }

  static String convertChatTimeFromString(String strDate) {
    initializeDateFormatting();
    final givenDate = DateFormat(dateFormatServerDate).parse(strDate, true);
    final dateLocal = givenDate.toLocal();
    return formatDate(dateLocal, [hh, ':', nn, ' ', am]);
  }

  static String convertTimeFromString(String strDate) {
    initializeDateFormatting();
    final givenDate = DateFormat(dateFormatServerDate).parse(strDate, true);
    final dateLocal = givenDate.toLocal();
    return formatDate(dateLocal, [hh, ':', nn, ' ', am]);
  }

  static String convertToDateString(String strDate) {
    final todayDate = DateTime.parse(strDate);
    return formatDate(todayDate, [dd, ' ', M, ' ', yyyy]);
  }

  String getUtcDate() {
    initializeDateFormatting();
    final dateUtc = DateTime.now().toUtc();
    final date = DateFormat(dateFormatServerDate).format(dateUtc);
    return date;
  }

  static String convertStringWithTimeDifference(
      String strDate, BuildContext context) {
    initializeDateFormatting();
    final givenDate = DateFormat(dateFormatChatDate).parse(strDate, false);
    final nowDate = DateTime.now().toUtc();
    final difference = nowDate.difference(givenDate);
    if (difference.inDays < 1) {
      return Localization.of(context).labelToday;
    } else if (difference.inDays == 1) {
      return Localization.of(context).labelYesterday;
    } else {
      return formatDate(givenDate, [dd, ' ', MM, ' ', yyyy]);
    }
  }
}
