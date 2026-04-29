import 'package:flutter/material.dart';

import '../apis/dic_params.dart';
import '../ui/accoutSetting/accout_setting.dart';
import '../ui/auth/forgot_password/forgot_password.dart';
import '../ui/auth/forgot_password/forgot_password_otp.dart';
import '../ui/auth/home/notification.dart';
import '../ui/auth/introduction/introduction.dart';
import '../ui/auth/login/login.dart';
import '../ui/auth/resetpassword/confirm_password.dart';
import '../ui/auth/signup/merchant_sign_up.dart';
import '../ui/auth/signup/user_sign_up.dart';
import '../ui/auth/signup/verify_otp/sign_up_verify_otp.dart';
import '../ui/auth/terms_and_policy/privacy_policy.dart';
import '../ui/chat/chat.dart';
import '../ui/createSupportTicket/create_support_ticket.dart';
import '../ui/globalsearch/global_seach.dart';
import '../ui/paymentSetting/bankSetting/add_bank_details.dart';
import '../ui/paymentSetting/bankSetting/bank_details.dart';
import '../ui/paymentSetting/card/card_details.dart';
import '../ui/paymentSetting/payment_setting.dart';
import '../ui/profile/accountSettings/changePassword/change_password.dart';
import '../ui/profile/accountSettings/changePin/change_pin.dart';
import '../ui/profile/editprofile/edit_profile_details.dart';
import '../ui/profile/kyc/complete_kyc.dart';
import '../ui/profile/myCommissions/my_commissions.dart';
import '../ui/profile/myTransaction/my_transaction.dart';
import '../ui/profile/qrcode/my_qrcode.dart';
import '../ui/profile/requestStatement/request_statement.dart';
import '../ui/profile/supportTickets/support_ticket_chat.dart';
import '../ui/profile/supportTickets/support_tickets.dart';
import '../ui/profile/transactionPin/transaction_pin.dart';
import '../ui/profile/transactionPin/transaction_pin_setup.dart';
import '../ui/profile/uploaddocuments/upload_document.dart';
import '../ui/profile/useragentprofile/merchant_profile.dart';
import '../ui/profile/useragentprofile/user_agent_profile.dart';
import '../ui/profile/wallet/addtowallet/add_money_to_wallet.dart';
import '../ui/profile/wallet/addtowallet/add_money_wallet_payment_selectation.dart';
import '../ui/profile/wallet/my_wallet.dart';
import '../ui/profile/wallet/wallet_setup.dart';
import '../ui/profile/wallet/withdrawMoney/withdraw_money.dart';
import '../ui/profile/wallet/withdrawMoney/review_transfer.dart';
import '../ui/tabbar/main_tabbar.dart';
import '../ui/tabbar/merchant_main_tabbar.dart';
import '../ui/transfermoney/pay_money.dart';
import '../ui/transfermoney/scanandpay/scan_and_pay.dart';
import '../ui/transfermoney/transfer_money.dart';
import '../ui/utilityServices/bouquet_listing.dart';
import '../ui/utilityServices/data_type_listing.dart';
import '../ui/utilityServices/utility_services.dart';
import 'constants.dart';
import 'navigation_params.dart';

class NavigationUtils {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    final Map<String, dynamic> args =
        (settings.arguments as Map<String, dynamic>?) ?? <String, dynamic>{};
    switch (settings.name) {
      case routePrivacyPolicy:
        return MaterialPageRoute(
            builder: (_) => PrivacyPolicyScreen(
                  isPrivacyPolicy:
                      (args[NavigationParams.isPrivacyPolicy] as bool?) ??
                          false,
                ));
      case routeLogin:
        return MaterialPageRoute(builder: (_) => const LoginScreen());
      case routeForgotPassword:
        return MaterialPageRoute(builder: (_) => ForgotPasswordScreen());
      case routeForgotPasswordOTP:
        return MaterialPageRoute(
            builder: (_) => ForgotPasswordOtpScreen(
                  phoneNumber: args[NavigationParams.phoneNumber],
                  model: args[NavigationParams.model],
                ));
      case routeLoginVerifyOTP:
        return MaterialPageRoute(
            builder: (_) => LoginVerifyOtpScreen(
                  phoneNumber: args[NavigationParams.phoneNumber],
                  type: args[NavigationParams.type],
                  isFromAuth:
                      (args[NavigationParams.isFromAuth] as bool?) ?? false,
                ));
      case routeConfirmPassword:
        return MaterialPageRoute(
            builder: (_) => ConfirmPasswordScreen(
                  phoneNumber: args[NavigationParams.phoneNumber],
                  model: args[NavigationParams.model],
                ));
      case routeUploadDocuments:
        return MaterialPageRoute(
            builder: (_) => UploadDocumentScreen(
                  isFromUpload: (args[DicParams.isFromUpload] as bool?) ?? false,
                ));
      case routeMainTab:
        return MaterialPageRoute(builder: (_) => const MainTabBar());
      case routeIntroduction:
        return MaterialPageRoute(builder: (_) => const IntroductionScreen());
      case routeUserSignUp:
        return MaterialPageRoute(
            builder: (_) => UserSignUpScreen(
                  isFromIntroduction:
                      (args[NavigationParams.isFromIntroduction] as bool?) ??
                          false,
                ));
      case routeEditProfile:
        return MaterialPageRoute(builder: (_) => EditProfileDetailsScreen());
      case routeMyQrCode:
        return MaterialPageRoute(builder: (_) => const MyQrCodeScreen());
      case routeMyWallet:
        return MaterialPageRoute(builder: (_) => const MyWalletScreen());
      case routeMerchantSignUp:
        return MaterialPageRoute(
            builder: (_) => MerchantSignUpScreen(
                  isFromIntroduction:
                      (args[NavigationParams.isFromIntroduction] as bool?) ??
                          false,
                ));
      case routeCompleteKYC:
        return MaterialPageRoute(
            builder: (_) => CompleteKYCScreen(
                  showBackButton:
                      (args[NavigationParams.showBackButton] as bool?) ?? false,
                  completeTransactionDetails:
                      (args[NavigationParams.completeTransactionDetails]
                              as bool?) ??
                          false,
                ));
      case routeMyProfile:
        return MaterialPageRoute(
            builder: (_) => const UserAgentProfileScreen());
      case routeWalletSetup:
        return MaterialPageRoute(
            builder: (_) => WalletSetupScreen(
                  showBackButton:
                      (args[NavigationParams.showBackButton] as bool?) ?? false,
                ));
      case routeTransactionPinSetup:
        return MaterialPageRoute(
            builder: (_) => TransactionPinSetupScreen(
                  showBackButton:
                      (args[NavigationParams.showBackButton] as bool?) ?? false,
                ));
      case routeMerchantMainTab:
        return MaterialPageRoute(builder: (_) => MerchantMainTabBar());
      case routeMerchantProfile:
        return MaterialPageRoute(builder: (_) => const MerchantProfileScreen());
      case routeScanAndPay:
        return MaterialPageRoute(builder: (_) => const ScanAndPay());
      case routeMyTransaction:
        return MaterialPageRoute(builder: (_) => const MyTransaction());
      case routePaymentSetting:
        return MaterialPageRoute(builder: (_) => const PaymentSettingScreen());
      case routeBankDetails:
        return MaterialPageRoute(builder: (_) => const BankDetailsScreen());
      case routeCardDetails:
        return MaterialPageRoute(builder: (_) => const CardDetailsScreen());
      case routeAccountSetting:
        return MaterialPageRoute(builder: (_) => const AccountSettingScreen());
      case routeTransferMoneyScreen:
        return MaterialPageRoute(
            builder: (_) => TransferMoneyScreen(
                  showBackButton:
                      (args[NavigationParams.showBackButton] as bool?) ?? false,
                ));
      case routeAddMoneyToWallet:
        return MaterialPageRoute(
            builder: (_) => AddMoneyToWallet(
                  walletAmount: args[NavigationParams.walletAmount],
                ));
      case routeWithdrawMoney:
        return MaterialPageRoute(
            builder: (_) => WithDrawMoneyScreen(
                  walletAmount: args[NavigationParams.walletAmount],
                ));
      case routeAddBankDetails:
        return MaterialPageRoute(builder: (_) => const AddBankDetailsScreen());
      case routeTransactionPin:
        return MaterialPageRoute(
            builder: (_) => TransactionPinScreen(
                  paymentAmount: args[NavigationParams.paymentAmount],
                  paymentDetails: args[NavigationParams.paymentDetails],
                  isCardPayment:
                      (args[NavigationParams.isCardPayment] as bool?) ?? false,
                  isBankPayment:
                      (args[NavigationParams.isBankPayment] as bool?) ?? false,
                  isTransferMoney:
                      (args[NavigationParams.isTransferMoney] as bool?) ?? false,
                  isRequestMoney:
                      (args[NavigationParams.isRequestMoney] as bool?) ?? false,
                  isPayMoney:
                      (args[NavigationParams.isPayMoney] as bool?) ?? false,
                  isWithdrawMoneyToBank:
                      (args[NavigationParams.isWithdrawMoneyToBank] as bool?) ??
                          false,
                  isNetBankingPayment:
                      (args[NavigationParams.isNetBankingPayment] as bool?) ??
                          false,
                  isDataRecharge:
                      (args[NavigationParams.isDataRecharge] as bool?) ?? false,
                  isTvSubscription:
                      (args[NavigationParams.isTvSubscription] as bool?) ??
                          false,
                  isElectricityBill:
                      (args[NavigationParams.isElectricityBill] as bool?) ??
                          false,
                ));
      case routePayMoneyScreen:
        return MaterialPageRoute(
            builder: (_) => PayMoneyScreen(
                  isPayScreen:
                      (args[NavigationParams.isPayScreen] as bool?) ?? false,
                ));
      case routeRequestStatement:
        return MaterialPageRoute(builder: (_) => const RequestStatement());
      case routeNotification:
        return MaterialPageRoute(builder: (_) => const NotificationScreen());
      case routeAddMoneyToWalletSelectPaymentMethod:
        return MaterialPageRoute(
            builder: (_) => AddMoneyToWalletSelectPaymentMethodScreen(
                  addToWalletAmount: args[NavigationParams.addToWalletAmount],
                  isWithdrawMoney:
                      (args[NavigationParams.isWithdrawMoney] as bool?) ??
                          false,
                ));
      case routeReviewBankTransfer:
        return MaterialPageRoute(
          builder: (_) => ReviewBankTransferScreen(
            amount: (args[NavigationParams.paymentAmount] as num?) ?? 0,
            bankDetail: args[NavigationParams.paymentDetails],
          ),
        );
      case routeChatScreen:
        return MaterialPageRoute(
            builder: (_) => ChatScreen(
                  senderUserId:
                      (args[NavigationParams.senderUserId] as int?) ?? 0,
                  senderProfileImage:
                      (args[NavigationParams.senderProfileImage] as String?) ??
                          '',
                  senderName:
                      (args[NavigationParams.senderName] as String?) ?? '',
                ));
      case routeChangePassword:
        return MaterialPageRoute(builder: (_) => ChangePasswordScreen());
      case routeChangePin:
        return MaterialPageRoute(builder: (_) => ChangePinScreen());
      case routeGlobalSearch:
        return MaterialPageRoute(
            builder: (_) => GlobalSearch(
                  isPayScreen:
                      (args[NavigationParams.isPayScreen] as bool?) ?? false,
                ));
      case routeMyCommissions:
        return MaterialPageRoute(builder: (_) => const MyCommissionsScreen());
      case routeSupportTickets:
        return MaterialPageRoute(
            builder: (_) => SupportTicketsScreen(
                  showBackButton:
                      (args[NavigationParams.showBackButton] as bool?) ?? false,
                ));
      case routeCreateSupportTicket:
        return MaterialPageRoute(builder: (_) => const CreateSupportTicket());
      case routeSupportTicketsChat:
        return MaterialPageRoute(
            builder: (_) => SupportTicketChatScreen(
                  senderUserId: args[NavigationParams.senderUserId],
                ));
      case routeUtilityServices:
        return MaterialPageRoute(
            builder: (_) => UtilityServicesScreen(
                  services: args[NavigationParams.services],
                ));
      case routeDataTypeListing:
        return MaterialPageRoute(
            builder: (_) => DataTypeListingScreen(
                services: args[NavigationParams.services]));
      case routeBouquetListing:
        return MaterialPageRoute(
            builder: (_) => BouquetListingScreen(
                services: args[NavigationParams.services]));

      default:
        return _errorRoute(" Comming soon...");
    }
  }

  static Route<dynamic> _errorRoute(String message) {
    return MaterialPageRoute(builder: (_) {
      return Scaffold(
          appBar: AppBar(title: const Text('Error')),
          body: Center(child: Text(message)));
    });
  }

  static void pushReplacement(BuildContext context, String routeName,
      {Object? arguments}) {
    Navigator.of(context).pushReplacementNamed(routeName, arguments: arguments);
  }

  static Future<dynamic> push(BuildContext context, String routeName,
      {Object? arguments}) {
    return Navigator.of(context).pushNamed(routeName, arguments: arguments);
  }

  static void pop(BuildContext context, {dynamic args}) {
    Navigator.of(context).pop(args);
  }

  static Future<dynamic> pushAndRemoveUntil(
      BuildContext context, String routeName,
      {Object? arguments}) {
    return Navigator.of(context).pushNamedAndRemoveUntil(
        routeName, (route) => false,
        arguments: arguments);
  }
}
