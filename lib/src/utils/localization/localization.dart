import 'dart:async';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'localization_en.dart';

class MyLocalizationsDelegate extends LocalizationsDelegate<Localization> {
  const MyLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) => [
        'en',
      ].contains(locale.languageCode);

// @override
////   bool isSupported(Locale locale) => ['en', 'fr'].contains(locale.languageCode);

  @override
  Future<Localization> load(Locale locale) => _load(locale);

  static Future<Localization> _load(Locale locale) async {
    final String name =
        (locale.countryCode?.isEmpty ?? true)
            ? locale.languageCode
            : locale.toString();

    final localeName = Intl.canonicalizedLocale(name);
    Intl.defaultLocale = localeName;

    // if( locale.languageCode == "fr" ) {
    //   return LocalizationFR();
    // } else {
    //   return LocalizationEN();
    // }

    return LocalizationEN();
  }

  @override
  bool shouldReload(LocalizationsDelegate<Localization> old) => false;
}

abstract class Localization {
  static Localization of(BuildContext context) {
    return Localizations.of<Localization>(context, Localization)!;
  }

  String get internetNotConnected;

  String get email;

  String get name;

  String get mobileNumber;

  String get phoneNumber;

  String get forgotPassword;

  String get loginTitle;

  String get signInTitle;

  String get signUpTitle;

  String get password;

  String get confirmPassword;

  String get dontHaveAnAccount;

  String get loginWithFingerprint;

  // sign in label
  String get signInLabel;

  // Forgot Password
  String get forgotPasswordDescription;

  String get forgotPasswordOTPDescription;

  String get enterTheCodeSentOn;

  String get forgotPasswordLabel;

  String get expiresInLabel;

  String get resendOtpLabel;

  // terms and condition
  String get labelAgreeTermsAndCondition;

  String get termsAndCondition;

  String get privacyPolicy;

  String get labelAnd;

  String get msgEnterAddress;

  String get msgEnterValidAddress;

  String get msgEnterName;

  String get msgEnterMobile;

  String get msgContactPermission;

  String get msgFingerprintPermission;

  String get allow;

  String get skip;

  String get ok;

  String get cancel;

  String get appName;

  String get alertPermissionNotRestricted;

  String get labelProceed;

  String get submit;

  String get save;

  // Upload Documents Label
  String get uploadDocumentHeader;

  String get myDocumentHeader;

  String get uploadDocumentNote;

  String get browse;

  String get idCard;

  String get bankStatement;

  String get cacCertificate;

  String get cacFormA;

  String get meansOfIdentification;

  String get utilitybill;

  // Home Screen Label
  String get utilityNote;

  String get airline;

  String get electricity;

  String get airtime;

  String get recent;

  String get labelSignInWithFingerPrint;

  String get authenticateFingerprint;

  String get msgAuthenticateSuccess;

  //Sign up form
  String get firstName;

  String get errorFirstName;

  String get lastName;

  String get emailId;

  String get errorlastName;

  String get next;

  String get alreadyHaveAccount;

  String get registerAsAgent;

  String get registerAsUser;

  String get createAccount;

  String get createAccountLabelUser;

  String get createAccountLabelAgent;

  String get businessName;

  String get errorBusinessName;

  String get categoryOfBusiness;

  String get errorCategoryOfBusiness;

  String get errorUtilityPayment;

  String get descOfBusiness;

  String get errorDescOfBusiness;

  String get emailAddress;

  String get errorEmailAddress;

  String get errorPassword;

  String get errorDiffPassword;

  String get errorConfirmPassword;

  String get labelSubmit;

  String get labelSave;

  String get labelDownload;

  String get labelUser;

  String get labelAgent;

  // Verify OTP
  String get verifyLabel;

  String get verifyOTPDescription;

  String get verifyNowLabel;

  // reset password
  String get oldPasswordLabel;

  String get newPasswordLabel;

  String get changePasswordLabel;

  String get confirmNewPasswordLabel;

  String get confirmPasswordLabel;

  String get editDetailsLabel;

  String get descriptionAboutBusiness;

  String get myQrCodeLabel;

  //Introduction Text
  String get introText1;

  String get introDescText1;

  //KYC screen
  String get completeKycLabel;

  String get completeKycLabelDescription;

  String get bvnNumber;

  String get labelSkip;

  // MyProfile Screen
  String get myQrCode;

  String get acceptReqMoney;

  String get myWallet;

  String get myTransactions;

  String get paymentSettings;

  String get accountSettings;

  String get supportTickets;

  String get supportTicket;

  String get myDocuments;

  String get kycDetails;

  String get bvnNo;

  String get galleryTitle;

  String get cameraTitle;

  String get pdfTitle;

  String get myCommissions;

  String get bankDetails;

  String get logout;

  String get qrDownloadSuccess;

  String get msgLogout;

  //Wallet Setup
  String get labelWalletSetup;

  String get labelWalletSetupUserDescription;

  String get labelWalletSetupMerchantDescription;

  String get labelBankAccount;

  String get labelCreditCard;

  String get bankName;

  String get errorBankName;

  String get accountNumber;

  String get errorAccountNumber;

  String get errorInvalidAccountNumber;

  String get cardNumber;

  String get errorCardNumber;

  String get cardHolderName;

  String get errorCardHolderName;

  String get expiryMonth;

  String get errorExpiryMonth;

  String get expiryYear;

  String get errorExpiryYear;

  String get cvvNumber;

  String get labelCvv;

  String get errorCvvNumber;

  //Transaction Pin Setup

  String get labelTransActionPinSetup;

  String get labelTransActionPinSetupDescription;

  String get transActionPin;

  String get confirmTransActionPin;

  String get errorTransActionPin;

  String get errorOldTransActionPin;

  String get errorNewTransActionPin;

  String get errorConfirmTransActionPin;

  String get errorMinimumLength;

  String get errorPinDoesNotMatch;

  String get errorPinAndConfirmNewPinNotMatch;

  String get errorValidMobileNumber;

  String get errorValidPassword;

  String get labelIndividual;

  String get labelCorporate;

  String get msgSignUpSuccess;

  String get msgResendOtpSuccess;

  String get msgVerifyEmailAndLogin;

  String get labelOr;

  String get errorEnterPhoneOrEmail;

  //Merchant Home Screen
  String get labelMerchantHomeScreen;

  String get labelTotalTransactions;

  String get labelTotalPaymentReceived;

  String get labelTotalCommissionPaid;

  String get labelTotalRevenueGenerated;

  String get logoutLabel;

  String get errorMerchantApp;

  String get errorUserApp;

  //Request Money
  String get requestMoneyHeader;

  String get errorMobileNotVerified;

  String get errorEmailNotVerified;

  String get labelBack;

  String get labelClose;

  String get errorBVNNumber;

  String get errorValidBVNNumber;

  String get errorVerifyEmail;

  String get labelBusinessCategory;

  String get errorSomethingWentWrong;

  String get kycPending;

  String get msgCompleteKyc;

  String get errorEnterOTP;

  String get labelAuthWithFingerPrint;

  String get labelEmailChangeDescription;

  String get hintFileSelection;

  String get errorUploadAllDocument;

  // Bottom Navigation Tab
  String get labelMainTabHome;

  String get labelMainTabAddMoney;

  String get labelMainTabWallet;

  String get labelMainTabRequestMoney;

  String get labelMainTabTransferMoney;

  // Scan & Pay
  String get scanAndPayHeader;

  String get msgResetPasswordFromEmail;

  //Payment setting
  String get labelPaymentMethod;

  String get labelBankOfNigeria;

  String get labelBankDetails;

  String get labelWithdrawMoneyToBank;

  String get labelRequestStatement;

  String get labelCurrentWalletStatement;

  String get labelWalletId;

  String get labelAddMoneyToWallet;

  String get labelWithDrawMoneyToWallet;

  String get hintEnterAmount;

  String get errorAmount;

  String get errorValidAmount;

  String get errorValidAndBoundedAmount;

  String get labelAvailableBalance;

  String get labelPay;

  String get msgRemoveBankAccount;

  String get labelAddMoney;

  String get labelSelectPaymentMethod;

  String get labelEnterTransactionPin;

  String get labelEnterPin;

  String get creditCard;

  String get debitCard;

  String get netBanking;

  String get labelAddBankDetails;

  String get labelAddBankDetailsDesc;

  String get labelBankAccountNumber;

  String get labelTransferMoney;

  String get labelAcceptRequest;

  String get labelNoDataFound;

  String get msgStatementSendToEmail;

  String get labelRequestingFrom;

  String get labelPayment;

  String get hintWhatIsPaymentFor;

  String get hintWriteMessage;

  String get labelDecline;

  String get labelDeclined;

  String get labelRequested;

  String get labelPaid;

  String get errorPaymentAmount;

  String get labelProceedToPayment;

  String get labelCreditDebitCard;

  String get labelBank;

  String get labelPaymishWallet;

  String get labelSearch;

  String get labelAll;

  String get labelDebit;

  String get labelCredit;

  String get labelReceivedFrom;

  String get labelPaidTo;

  String get requestStatement;

  String get msgRequestStatement;

  // Request Statement Calender Strings
  String get labelStartDate;

  String get labelEndDate;

  String get labelSelect;

  String get paymentStatus;

  String get channelStatus;

  String get errorPaymentStatus;

  String get errorChannelStatus;

  String get errorStartDate;

  String get errorEndDate;

  // Notification
  String get labelNotification;

  String get msgDeleteNotification;

  // Payment Decline Message Popup
  String get msgDeclineRequest;

  String get errorEnterValidTransactionPin;

  String get lblYouAreSendingTo;

  String get lblChangePin;

  String get lblOldPin;

  String get lblNewPin;

  String get lblConfirmNewPin;

  //Account Setting
  String get labelChangePassword;

  String get labelChangeTransactionPIN;

  String get labelEmailNotification;

  String get labelPushNotification;

  String get labelDayAgo;

  String get labelHoursAgo;

  String get labelMinutesAgo;

  String get labelJustNow;

  //Support Ticket
  String get labelCreateSupportTicket;

  String get labelSelectCategory;

  String get errorTitle;

  String get labelTitle;

  String get labelDescription;

  String get errorDescription;

  String get errorSelectSupportCategory;

  String get errorLocationPermissionNotAllowed;

  String get labelEnterAmountSendToBank;

  String get labelCharges;

  String get labelNetPayable;

  String get labelUtilityPayment;

  String get errorSetUpTransactionDetails;

  String get labelCreditToWallet;

  //No data found for listing

  String get labelNoNotificationFound;

  String get labelNoBankDetailsFound;

  String get labelNoTransferRequestFound;

  String get labelNoTransactionDetailsFound;

  String get labelNoContactsFound;

  String get labelNoRecentContactsFound;

  String get labelNoTicketsFound;

  String get labelSuccess;

  String get labelPending;

  String get searchingFor;

  String get searchForPeople;

  String get successful;

  String get msgSuccessfulSend;

  String get msgSuccessfulAdded;

  String get msgSuccessfulTransferred;

  String get msgSuccessfulRequested;

  String get labelNaira;

  String get msgToYourWallet;

  String get remove;

  String get setAsPrimary;

  String get msgAccountNotApproved;

  String get labelSelectBank;

  String get msgInsufficientWalletBalance;

  String get labelContinue;

  String get msgMinimumAmountRequired;

  String get msgMaximumAmountRequired;

  String get labelPleaseSelectType;

  String get labelBouquet;

  String get labelPrepaid;

  String get labelPostPaid;

  String get labelMeterType;

  String get labelSmartCardNumber;

  String get errorSmartCardNumber;

  String get errorValidSmartCardNumber;

  String get labelMeterNumber;

  String get errorMeterNumber;

  String get labelDataType;

  String get labelData;

  String get labelValidity;

  String get labelChat;

  String get labelYesterday;

  String get labelToday;

  String get msgSelectDataPlan;

  String get msgSelectBouquet;

  String get titleRequestStatement;

  String get labelNoMessageFound;

  String get labelNoPlanFound;

  String get errorMinimumWithdrawAmount;

  String get labelWithdrawToBank;

  String get labelFindByPhoneNumberOrName;

  String get labelCustomerName;

  String get intro1User;

  String get intro2User;

  String get intro3User;

  String get intro4User;

  String get intro1Merchant;

  String get intro2Merchant;

  String get intro3Merchant;

  String get intro4Merchant;

  String get desc1User;

  String get desc2User;

  String get desc3User;

  String get desc4User;

  String get desc1Merchant;

  String get desc2Merchant;

  String get desc3Merchant;

  String get desc4Merchant;

  String get errorSelectBank;

  String get labelCard;

  String get cardDetails;

  String get labelBankHolderName;

  String get labelEnterBankHolderName;

  String get labelFailed;

  String get labelNoCardDetailsFound;

  String get processTerminated;

  String get addNewCard;

  String get selectCard;
  String get changeCard;
  String get pleaseOnGPSForSignIn;
}
