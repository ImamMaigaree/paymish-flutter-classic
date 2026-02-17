import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:http_parser/http_parser.dart';

import '../../ui/accoutSetting/model/req_account_setting.dart';
import '../../ui/auth/forgot_password/model/req_forget_password.dart';
import '../../ui/auth/forgot_password/model/res_forget_password.dart';
import '../../ui/auth/home/model/res_home.dart';
import '../../ui/auth/home/model/res_merchant_home.dart';
import '../../ui/auth/home/model/res_notification.dart';
import '../../ui/auth/login/model/req_add_device.dart';
import '../../ui/auth/login/model/req_login.dart';
import '../../ui/auth/login/model/res_add_device.dart';
import '../../ui/auth/login/model/res_login.dart';
import '../../ui/auth/resetpassword/model/req_reset_password.dart';
import '../../ui/auth/signup/model/req_sign_up.dart';
import '../../ui/auth/signup/model/res_sign_up.dart';
import '../../ui/auth/signup/verify_otp/model/req_resend_otp.dart';
import '../../ui/auth/signup/verify_otp/model/req_verify_otp.dart';
import '../../ui/auth/terms_and_policy/res_cms.dart';
import '../../ui/chat/model/req_approve_request.dart';
import '../../ui/chat/model/req_pay_money.dart';
import '../../ui/chat/model/res_transaction_details_with_user.dart';
import '../../ui/createSupportTicket/model/req_create_support_ticket.dart';
import '../../ui/createSupportTicket/model/res_category_list.dart';
import '../../ui/globalsearch/model/req_search_data.dart';
import '../../ui/globalsearch/model/res_search_data.dart';
import '../../ui/paymentSetting/model/res_bank_details.dart';
import '../../ui/paymentSetting/model/res_bank_list.dart';
import '../../ui/paymentSetting/model/res_card_listing.dart';
import '../../ui/profile/accountSettings/changePassword/model/req_change_password.dart';
import '../../ui/profile/accountSettings/changePassword/model/res_change_password.dart';
import '../../ui/profile/accountSettings/changePin/model/req_change_pin.dart';
import '../../ui/profile/accountSettings/changePin/model/res_change_pin.dart';
import '../../ui/profile/editprofile/model/req_edit_profile.dart';
import '../../ui/profile/editprofile/model/res_edit_profile.dart';
import '../../ui/profile/kyc/model/req_kyc_verification.dart';
import '../../ui/profile/model/res_profile.dart';
import '../../ui/profile/myTransaction/res_my_transaction_model.dart';
import '../../ui/profile/supportTickets/model/res_support_ticket.dart';
import '../../ui/profile/transactionPin/model/req_access_code.dart';
import '../../ui/profile/transactionPin/model/req_transaction_pin.dart';
import '../../ui/profile/transactionPin/model/req_transaction_pin_validation.dart';
import '../../ui/profile/transactionPin/model/req_valid_amount.dart';
import '../../ui/profile/transactionPin/model/req_withdraw_money_to_bank.dart';
import '../../ui/profile/transactionPin/model/res_access_code.dart';
import '../../ui/profile/transactionPin/model/res_transaction_pin_validation.dart';
import '../../ui/profile/transactionPin/model/res_valid_amount.dart';
import '../../ui/profile/uploaddocuments/model/req_upload_documents.dart';
import '../../ui/profile/uploaddocuments/model/res_my_documents.dart';
import '../../ui/profile/uploaddocuments/model/res_upload_document.dart';
import '../../ui/profile/useragentprofile/model/req_upload_picture.dart';
import '../../ui/profile/useragentprofile/model/res_upload_picture.dart';
import '../../ui/profile/wallet/model/req_topup_wallet.dart';
import '../../ui/profile/wallet/model/req_wallet_setup.dart';
import '../../ui/profile/wallet/model/res_topup_wallet.dart';
import '../../ui/profile/wallet/model/res_wallet_overview.dart';
import '../../ui/profile/wallet/model/res_wallet_setup.dart';
import '../../ui/profile/wallet/withdrawMoney/model/req_checkout_withdraw_amount.dart';
import '../../ui/profile/wallet/withdrawMoney/model/res_checkout_withdraw_amount.dart';
import '../../ui/requestmoney/model/req_contact.dart';
import '../../ui/requestmoney/model/req_money.dart';
import '../../ui/requestmoney/model/res_contact.dart';
import '../../ui/requestmoney/model/res_money.dart';
import '../../ui/transfermoney/model/res_transfer_money_list.dart';
import '../../ui/transfermoney/scanandpay/model/req_qr_scan.dart';
import '../../ui/transfermoney/scanandpay/model/res_qr_scan.dart';
import '../../ui/utilityServices/model/req_recharge.dart';
import '../../ui/utilityServices/model/req_verify_numbers.dart';
import '../../ui/utilityServices/model/res_data_plan_list.dart';
import '../../ui/utilityServices/model/res_verify_meter_number.dart';
import '../../ui/utilityServices/model/res_verify_smart_card_number.dart';
import '../../utils/dialog_utils.dart';
import '../../utils/localization/localization.dart';
import '../api_constants.dart';
import '../api_service.dart';
import '../base_model.dart';
import '../dic_params.dart';

class UserApiManager {
  static final UserApiManager _instance = UserApiManager._internal();

  factory UserApiManager() {
    return _instance;
  }

  UserApiManager._internal();

  Future<ResLogin> login(ReqLogin reqLogin) async {
    try {
      final response = await ApiService().post(
        ApiConstants.apiLogin,
        data: reqLogin.toJson(),
      );
      return ResLogin.fromJson(response.data);
    } on DioException catch (error) {
      throw ResBaseModel.fromJsonWithCode(error.response);
    }
  }

  Future<ResAddDevice> addDevice(ReqAddDevice reqAddDevice) async {
    try {
      final response = await ApiService().post(
        ApiConstants.apiAddDevice,
        data: reqAddDevice.toJson(),
      );
      return ResAddDevice.fromJson(response.data);
    } on DioException catch (error) {
      throw ResBaseModel.fromJsonWithCode(error.response);
    }
  }

  Future<ResSignUp> signUp(ReqSignUp reqSignUp) async {
    try {
      final response = await ApiService().post(
        ApiConstants.apiSignUp,
        data: reqSignUp.toJson(),
      );
      return ResSignUp.fromJson(response.data);
    } on DioException catch (error) {
      throw ResBaseModel.fromJsonWithCode(error.response);
    }
  }

  Future<ResBaseModel> verifyOTPSignUP(ReqVerifyOtp reqVerifyOtp) async {
    try {
      final response = await ApiService().post(
        ApiConstants.apiVerifyOTP,
        data: reqVerifyOtp.toJson(),
      );
      return ResBaseModel.fromJson(response.data);
    } on DioException catch (error) {
      throw ResBaseModel.fromJsonWithCode(error.response);
    }
  }

  Future<ResBaseModel> resendOTP(ReqResendOtp reqResendOtp) async {
    try {
      final response = await ApiService().post(
        ApiConstants.apiResendOTP,
        data: reqResendOtp.toJson(),
      );
      return ResBaseModel.fromJson(response.data);
    } on DioException catch (error) {
      throw ResBaseModel.fromJsonWithCode(error.response);
    }
  }

  Future<ResForgetPassword> forgetPassword(
      ReqForgetPassword reqForgetPassword) async {
    try {
      final response = await ApiService().post(
        ApiConstants.apiForgetPassword,
        data: reqForgetPassword.toJson(),
      );
      return ResForgetPassword.fromJson(response.data);
    } on DioException catch (error) {
      throw ResBaseModel.fromJsonWithCode(error.response);
    }
  }

  Future<ResUploadDocument> uploadDocument({
    required ReqUploadDocuments request,
    required String mimeType,
    required String mimeSubType,
  }) async {
    try {
      final image = request.image;
      if (image == null) {
        throw ResBaseModel(error: 'Image is required');
      }
      final fileName = image.path.split('/').last;
      final formData = FormData.fromMap({
        DicParams.image: await MultipartFile.fromFile(
          image.path,
          filename: fileName,
          contentType: MediaType(mimeType, mimeSubType),
        ),
        DicParams.documentType: request.documentType ?? ''
      });

      final response = await ApiService().multipartPost(
        ApiConstants.apiUploadDocuments,
        data: formData,
        options: Options(contentType: DicParams.contentTypeFormUrlEncoded),
      );
      return ResUploadDocument.fromJson(response.data);
    } on DioException catch (error) {
      throw ResBaseModel.fromJsonWithCode(error.response);
    }
  }

  Future<ResForgetPassword> resetPassword(
      ReqResetPassword reqResetPassword) async {
    try {
      final response = await ApiService().post(
        ApiConstants.apiResetPassword,
        data: reqResetPassword.toJson(),
      );
      // need to change the response model below for reset password
      return ResForgetPassword.fromJson(response.data);
    } on DioException catch (error) {
      throw ResBaseModel.fromJsonWithCode(error.response);
    }
  }

  // Change Password API
  Future<ResChangePassword> changePassword(
      ReqChangePassword reqChangePassword) async {
    try {
      final response = await ApiService().post(
        ApiConstants.apiChangePassword,
        data: reqChangePassword.toJson(),
      );
      return ResChangePassword.fromJson(response.data);
    } on DioException catch (error) {
      throw ResBaseModel.fromJsonWithCode(error.response);
    }
  }

  // Change Transaction PIN API
  Future<ResChangePin> changeTransactionPin(ReqChangePin reqChangePin) async {
    try {
      final response = await ApiService().post(
        ApiConstants.apiChangePin,
        data: reqChangePin.toJson(),
      );
      return ResChangePin.fromJson(response.data);
    } on DioException catch (error) {
      throw ResBaseModel.fromJsonWithCode(error.response);
    }
  }

  Future<ResMyDocumentsModel> getDocumentes() async {
    try {
      final response = await ApiService().get(ApiConstants.apiGetDocuments);
      return ResMyDocumentsModel.fromJson(response.data);
    } on DioException catch (error) {
      throw ResBaseModel.fromJsonWithCode(error.response);
    }
  }

  Future<ResBaseModel> setTransactionPin(
      ReqTransactionPin reqTransactionPin) async {
    try {
      final response = await ApiService().post(
        ApiConstants.apiTransactionPin,
        data: reqTransactionPin.toJson(),
      );
      return ResBaseModel.fromJson(response.data);
    } on DioException catch (error) {
      throw ResBaseModel.fromJsonWithCode(error.response);
    }
  }

  Future<ResBaseModel> deleteDocument({required int id}) async {
    try {
      final response = await ApiService().delete(
        '${ApiConstants.apiDeleteDocument}/$id',
      );
      return ResBaseModel.fromJson(response.data);
    } on DioException catch (error) {
      throw ResBaseModel.fromJsonWithCode(error.response);
    }
  }

  Future<ResProfile> getProfile() async {
    try {
      final response = await ApiService().get(
        ApiConstants.apiGetProfile,
      );
      return ResProfile.fromJson(response.data);
    } on DioException catch (error) {
      throw ResBaseModel.fromJsonWithCode(error.response);
    }
  }

  Future<ResEditProfile> editProfile(ReqEditProfile reqEditProfile) async {
    try {
      final response = await ApiService().post(
        ApiConstants.apiGetProfile,
        data: reqEditProfile.toJson(),
      );
      return ResEditProfile.fromJson(response.data);
    } on DioException catch (error) {
      throw ResBaseModel.fromJsonWithCode(error.response);
    }
  }

  Future<ResContactModel> contactSync(ReqContactModel request) async {
    try {
      final response = await ApiService().post(
        ApiConstants.apiContactSync,
        data: request.toJson(),
      );
      return ResContactModel.fromJson(response.data);
    } on DioException catch (error) {
      throw ResBaseModel.fromJsonWithCode(error.response);
    }
  }

  Future<ResWalletSetup> addBankAccount(ReqWalletSetup reqWalletSetup) async {
    try {
      final response = await ApiService().post(
        ApiConstants.apiBankAccount,
        data: reqWalletSetup.toJson(),
      );
      return ResWalletSetup.fromJson(response.data);
    } on DioException catch (error) {
      throw ResBaseModel.fromJsonWithCode(error.response);
    }
  }

  Future<ResBaseModel> setKYCVerification(
      ReqKycVerification reqKycVerification) async {
    try {
      final response = await ApiService().post(
        ApiConstants.apiKycVerification,
        data: reqKycVerification.toJson(),
      );
      return ResBaseModel.fromJson(response.data);
    } on DioException catch (error) {
      throw ResBaseModel.fromJsonWithCode(error.response);
    }
  }

  // Terms And Conditions, Privacy Policy
  Future<dynamic> getCMS({bool isPrivacyPolicy = false}) async {
    try {
      final response = await ApiService().get(
        ApiConstants.apiCms,
      );
      final cmsData = ResCMS.fromJson(response.data).data;
      final index = isPrivacyPolicy ? 3 : 1;
      if (cmsData == null || cmsData.length <= index) {
        return '';
      }
      return cmsData[index].content ?? '';
    } on DioException catch (error) {
      throw ResBaseModel.fromJsonWithCode(error.response);
    }
  }

  Future<ResUploadProfilePicture> uploadProfilePicture(
      ReqUploadProfilePicture request) async {
    try {
      final image = request.image;
      if (image == null) {
        throw ResBaseModel(error: 'Image is required');
      }
      final fileName = image.path.split('/').last;
      final formData = FormData.fromMap({
        DicParams.image: await MultipartFile.fromFile(
          image.path,
          filename: fileName,
          contentType:
              MediaType(DicParams.mediaTypeImage, DicParams.mediaTypejpeg),
        ),
      });

      final response = await ApiService().multipartPost(
        ApiConstants.apiUploadProfilePicture,
        data: formData,
        options: Options(contentType: DicParams.contentTypeFormUrlEncoded),
      );
      return ResUploadProfilePicture.fromJson(response.data);
    } on DioException catch (error) {
      throw ResBaseModel.fromJsonWithCode(error.response);
    }
  }

  Future<ResBankDetails> getBankDetails() async {
    try {
      final response = await ApiService().get(
        ApiConstants.apiBankDetails,
      );
      return ResBankDetails.fromJson(response.data);
    } on DioException catch (error) {
      throw ResBaseModel.fromJsonWithCode(error.response);
    }
  }

  Future<ResBaseModel> deleteBankAccount({required int id}) async {
    try {
      final response = await ApiService().delete(
        '${ApiConstants.apiDeleteBankAccount}/$id',
      );
      return ResBaseModel.fromJson(response.data);
    } on DioException catch (error) {
      throw ResBaseModel.fromJsonWithCode(error.response);
    }
  }

  Future<ResBaseModel> setPrimaryBankAccount({required int id}) async {
    try {
      final response = await ApiService().get(
        '${ApiConstants.apiSetPrimaryBankAccount}/$id',
      );
      return ResBaseModel.fromJson(response.data);
    } on DioException catch (error) {
      throw ResBaseModel.fromJsonWithCode(error.response);
    }
  }

  Future<ResTransferMoneyList> getTransferMoneyList({required int page}) async {
    try {
      final queryParameters = <String, String>{
        "page": "$page",
//        "limit": "$limit"
      };
      final response = await ApiService().get(
        ApiConstants.apiTransferMoneyList,
        params: queryParameters,
      );
      return ResTransferMoneyList.fromJson(response.data);
    } on DioException catch (error) {
      throw ResBaseModel.fromJsonWithCode(error.response);
    }
  }

  //My Transaction list api

  Future<ResMyTransactionModel> getMyTransactionList({
    required int page,
    required String type,
  }) async {
    try {
      final queryParameters = <String, String>{
        "type": type,
        "page": "$page",
      };
      final response = await ApiService().get(
        ApiConstants.apiMyTransaction,
        params: queryParameters,
      );
      return ResMyTransactionModel.fromJson(response.data);
    } on DioException catch (error) {
      throw ResBaseModel.fromJsonWithCode(error.response);
    }
  }

  // Checkout Withdraw money
  Future<ResCheckoutWithdrawMoney> checkoutWithdrawMoney(
      ReqCheckoutWithdrawMoney reqCheckoutWithdrawMoney) async {
    try {
      final response = await ApiService().post(
        ApiConstants.apiWithdrawCheckout,
        data: reqCheckoutWithdrawMoney.toJson(),
      );
      return ResCheckoutWithdrawMoney.fromJson(response.data);
    } on DioException catch (error) {
      throw ResBaseModel.fromJsonWithCode(error.response);
    }
  }

  // Fee quote for withdrawals (server-driven)
  Future<ResCheckoutWithdrawMoney> feeQuoteWithdraw({required num amount}) async {
    try {
      final response = await ApiService().get(
        ApiConstants.apiFeeQuote,
        params: <String, String>{
          "txType": "withdraw",
          "amount": "$amount",
        },
      );
      return ResCheckoutWithdrawMoney.fromJson(response.data);
    } on DioException catch (error) {
      throw ResBaseModel.fromJsonWithCode(error.response);
    }
  }

  // TopUp Wallet
  Future<ResTopUpWallet> topUpWallet(ReqTopUpWallet reqTopUpWallet) async {
    try {
      final response = await ApiService().post(
        ApiConstants.apiTopUpWallet,
        data: reqTopUpWallet.toJson(),
      );
      return ResTopUpWallet.fromJson(response.data);
    } on DioException catch (error) {
      throw ResBaseModel.fromJsonWithCode(error.response);
    }
  }

  // Approve Money Transfer Request
  Future<ResTopUpWallet> approveRequest(
      ReqApproveRequest reqApproveRequest) async {
    try {
      final response = await ApiService().post(
        ApiConstants.apiApproveRequest,
        data: reqApproveRequest.toJson(),
      );
      return ResTopUpWallet.fromJson(response.data);
    } on DioException catch (error) {
      throw ResBaseModel.fromJsonWithCode(error.response);
    }
  }

  // Decline Money Transfer Request
  Future<ResTopUpWallet> declineRequest(int id) async {
    try {
      final response = await ApiService().get(
        '${ApiConstants.apiDeclineRequest}${'/$id'}',
      );
      return ResTopUpWallet.fromJson(response.data);
    } on DioException catch (error) {
      throw ResBaseModel.fromJsonWithCode(error.response);
    }
  }

  // Request Money
  Future<ResMoney> requestMoney(ReqMoney reqMoney) async {
    try {
      final response = await ApiService().post(
        ApiConstants.apiMoneyRequest,
        data: reqMoney.toJson(),
      );
      return ResMoney.fromJson(response.data);
    } on DioException catch (error) {
      throw ResBaseModel.fromJsonWithCode(error.response);
    }
  }

  // Transaction Pin Validation
  Future<ResTransactionPinValidation> validatePin(
      ReqTransactionPinValidation pin, BuildContext context) async {
    try {
      final response = await ApiService().post(
        ApiConstants.apiValidatePin,
        data: pin.toJson(),
      );
      return ResTransactionPinValidation.fromJson(response.data);
    } on DioException catch (error) {
      // If pin is wrong, managed toast from here. (API response is 400 so.)
      await DialogUtils.displayToast(
          Localization.of(context).errorEnterValidTransactionPin);
      throw ResBaseModel.fromJsonWithCode(error.response);
    }
  }

  // Wallet Overview
  Future<ResWalletOverview> walletOverview() async {
    try {
      final response = await ApiService().get(
        ApiConstants.apiWalletOverview,
      );
      return ResWalletOverview.fromJson(response.data);
    } on DioException catch (error) {
      throw ResBaseModel.fromJsonWithCode(error.response);
    }
  }

  // Home Screen API
  Future<ResHomeScreen> homeScreen() async {
    try {
      final response = await ApiService().get(
        ApiConstants.apiHone,
      );
      return ResHomeScreen.fromJson(response.data);
    } on DioException catch (error) {
      throw ResBaseModel.fromJsonWithCode(error.response);
    }
  }

  //Create Support ticket
  Future<ResBaseModel> createSupportTicket(
      ReqCreateSupportTicket reqCreateSupportTicket) async {
    try {
      final response = await ApiService().post(
        ApiConstants.apiCreateSupportTicket,
        data: reqCreateSupportTicket.toJson(),
      );
      return ResBaseModel.fromJson(response.data);
    } on DioException catch (error) {
      throw ResBaseModel.fromJsonWithCode(error.response);
    }
  }

  //Get support ticket Category
  Future<ResCategoryList> getCategoryList() async {
    try {
      final response = await ApiService().get(
        ApiConstants.apiCategoryList,
      );
      return ResCategoryList.fromJson(response.data);
    } on DioException catch (error) {
      throw ResBaseModel.fromJsonWithCode(error.response);
    }
  }

  // Scan And Pay
  Future<ResQRScan> scanAndPay(ReqQRScan request) async {
    try {
      final response = await ApiService().get(
        ApiConstants.apiQRDetails,
        params: request.toJson(),
      );
      return ResQRScan.fromJson(response.data);
    } on DioException catch (error) {
      throw ResBaseModel.fromJsonWithCode(error.response);
    }
  }

  // Global Search
  Future<ResSearchModel> globalSearch(ReqSearchModel request) async {
    try {
      final response = await ApiService().get(
        ApiConstants.apiGlobalSearch,
        params: request.toJson(),
      );
      return ResSearchModel.fromJson(response.data);
    } on DioException catch (error) {
      throw ResBaseModel.fromJsonWithCode(error.response);
    }
  }

  // Notification listing
  Future<ResNotification> getNotificationList({required int page}) async {
    try {
      final queryParameters = <String, String>{
        "page": "$page",
//        "limit": "$limit"
      };
      final response = await ApiService().get(
        ApiConstants.apiNotificationList,
        params: queryParameters,
      );
      return ResNotification.fromJson(response.data);
    } on DioException catch (error) {
      throw ResBaseModel.fromJsonWithCode(error.response);
    }
  }

  //Detele Notification
  Future<ResBaseModel> deleteNotification({required int id}) async {
    try {
      final response = await ApiService().delete(
        '${ApiConstants.apiNotificationList}/$id',
      );
      return ResBaseModel.fromJson(response.data);
    } on DioException catch (error) {
      throw ResBaseModel.fromJsonWithCode(error.response);
    }
  }

  Future<ResBaseModel> payMoney(ReqPayMoney reqPayMoney) async {
    try {
      final response = await ApiService().post(
        ApiConstants.apiPayMoney,
        data: reqPayMoney.toJson(),
      );
      return ResBaseModel.fromJson(response.data);
    } on DioException catch (error) {
      throw ResBaseModel.fromJsonWithCode(error.response);
    }
  }

  Future<ResBaseModel> withdrawMoney(
      ReqWithdrawMoneyToBank reqWithdrawMoneyToBank) async {
    try {
      final response = await ApiService().post(
        ApiConstants.apiWithdrawMoney,
        data: reqWithdrawMoneyToBank.toJson(),
      );
      return ResBaseModel.fromJson(response.data);
    } on DioException catch (error) {
      throw ResBaseModel.fromJsonWithCode(error.response);
    }
  }

  //Read Notification
  Future<bool> readNotification({required int id}) async {
    try {
      final _ = await ApiService().get(
        '${ApiConstants.apiReadNotification}/$id',
      );
      return true;
    } on DioException catch (error) {
      throw ResBaseModel.fromJsonWithCode(error.response);
    }
  }

  // Get Transaction Details with particular user
  Future<ResTransactionDetailsWithUser> getTransactionListWithUser({
    required int page,
    required int id,
  }) async {
    try {
      final queryParameters = <String, String>{
        "page": "$page",
      };
      final response = await ApiService().get(
        "${ApiConstants.apiGetTransactionListWithUser}/$id",
        params: queryParameters,
      );
      return ResTransactionDetailsWithUser.fromJson(response.data);
    } on DioException catch (error) {
      throw ResBaseModel.fromJsonWithCode(error.response);
    }
  }

  //Merchant home screen api
  Future<ResMerchantHomeScreen> merchantHomeScreen() async {
    try {
      final response = await ApiService().get(
        ApiConstants.apiMerchantHome,
      );
      return ResMerchantHomeScreen.fromJson(response.data);
    } on DioException catch (error) {
      throw ResBaseModel.fromJsonWithCode(error.response);
    }
  }

  // Support ticket Listing
  Future<ResSupportTicket> getSupportTicketList({required int page}) async {
    try {
      final queryParameters = <String, String>{
        "page": "$page",
      };
      final response = await ApiService().get(
        ApiConstants.apiCreateSupportTicket,
        params: queryParameters,
      );
      return ResSupportTicket.fromJson(response.data);
    } on DioException catch (error) {
      throw ResBaseModel.fromJsonWithCode(error.response);
    }
  }

  Future<ResValidAmount> validateAmount(
      ReqValidAmount reqValidAmount, BuildContext context) async {
    try {
      final response = await ApiService().post(
        ApiConstants.apiValidAmount,
        data: reqValidAmount.toJson(),
      );
      return ResValidAmount.fromJson(response.data);
    } on DioException catch (error) {
      throw ResBaseModel.fromJsonWithCode(error.response);
    }
  }

  // Update Account Settings
  Future<ResBaseModel> updateAccountSettings(
      ReqAccountSetting reqAccountSetting) async {
    try {
      final response = await ApiService().post(
        ApiConstants.apiUpdateAccountSettings,
        data: reqAccountSetting.toJson(),
      );
      return ResBaseModel.fromJson(response.data);
    } on DioException catch (error) {
      throw ResBaseModel.fromJsonWithCode(error.response);
    }
  }

  //Get Data Plan List for Services
  Future<ResDataPlanList> getDataPlanList({
    required String serviceID,
    required String identifier,
  }) async {
    try {
      final queryParameters = <String, String>{
        "serviceID": serviceID,
        "identifier": identifier,
      };
      final response = await ApiService().get(
        ApiConstants.apiDataPlan,
        params: queryParameters,
      );
      return ResDataPlanList.fromJson(response.data);
    } on DioException catch (error) {
      throw ResBaseModel.fromJsonWithCode(error.response);
    }
  }

  Future<ResBaseModel> utilityRecharge(ReqRechargeModel request) async {
    try {
      final response = await ApiService().post(
        ApiConstants.apiUtilityRecharge,
        data: request.toJson(),
      );
      return ResBaseModel.fromJson(response.data);
    } on DioException catch (error) {
      throw ResBaseModel.fromJsonWithCode(error.response);
    }
  }

  Future<ResBaseModel> utilityTvSubscription(ReqRechargeModel request) async {
    try {
      final response = await ApiService().post(
        ApiConstants.apiTvSubscription,
        data: request.toJson(),
      );
      return ResBaseModel.fromJson(response.data);
    } on DioException catch (error) {
      throw ResBaseModel.fromJsonWithCode(error.response);
    }
  }

  Future<ResBaseModel> utilityBillPayment(ReqRechargeModel request) async {
    try {
      final response = await ApiService().post(
        ApiConstants.apiBillPayment,
        data: request.toJson(),
      );
      return ResBaseModel.fromJson(response.data);
    } on DioException catch (error) {
      throw ResBaseModel.fromJsonWithCode(error.response);
    }
  }

  //To request Statement

  Future<ResBaseModel> requestStatement({
    required String endDate,
    required String startDate,
    String? channel,
    String? status,
    required String timeZone,
  }) async {
    try {
      final queryParameters = <String, String>{
        "endDate": endDate,
        "startDate": startDate,
        "channel": channel ?? "",
        "status": status ?? "",
        "timeZone": timeZone,
      };
      final response = await ApiService().get(
        ApiConstants.apiRequestStatement,
        params: queryParameters,
      );
      return ResBaseModel.fromJsonWithCode(response);
    } on DioException catch (error) {
      throw ResBaseModel.fromJsonWithCode(error.response);
    }
  }

  //for checking smart card number
  Future<ResVerifySmartCardNumber> verifySmartCardNumber(
      ReqVerifyNumbers reqVerifyNumbers) async {
    try {
      final response = await ApiService().post(
        ApiConstants.apiVerifySmartCardNumber,
        data: reqVerifyNumbers.toJson(),
      );
      return ResVerifySmartCardNumber.fromJson(response.data);
    } on DioException catch (error) {
      throw ResBaseModel.fromJsonWithCode(error.response);
    }
  }

  //for checking meter number

  Future<ResVerifyMeterNumber> verifyMeterNumber(
      ReqVerifyNumbers reqVerifyNumbers) async {
    try {
      final response = await ApiService().post(
        ApiConstants.apiVerifyMeterNumber,
        data: reqVerifyNumbers.toJson(),
      );
      return ResVerifyMeterNumber.fromJson(response.data);
    } on DioException catch (error) {
      throw ResBaseModel.fromJsonWithCode(error.response);
    }
  }

  //Get Bank Listing
  Future<ResBankList> getBankList() async {
    try {
      final response = await ApiService().get(
        ApiConstants.apiBankList,
      );
      return ResBankList.fromJson(response.data);
    } on DioException catch (error) {
      throw ResBaseModel.fromJsonWithCode(error.response);
    }
  }

  //Set Primary Card
  Future<ResBaseModel> setPrimaryCard({required int id}) async {
    try {
      final response = await ApiService().get(
        '${ApiConstants.apiSetPrimaryCard}/$id',
      );
      return ResBaseModel.fromJson(response.data);
    } on DioException catch (error) {
      throw ResBaseModel.fromJsonWithCode(error.response);
    }
  }

  //Remove Card
  Future<ResBaseModel> deleteCard({required int id}) async {
    try {
      final response = await ApiService().delete(
        '${ApiConstants.apiDeleteCard}/$id',
      );
      return ResBaseModel.fromJson(response.data);
    } on DioException catch (error) {
      throw ResBaseModel.fromJsonWithCode(error.response);
    }
  }

  //Get cardd listing
  Future<ResCardListing> getCardDetails() async {
    try {
      final response = await ApiService().get(
        ApiConstants.apiCardDetails,
      );
      return ResCardListing.fromJson(response.data);
    } on DioException catch (error) {
      throw ResBaseModel.fromJsonWithCode(error.response);
    }
  }

  //Add Card
  Future<ResBaseModel> addCard({required String id}) async {
    try {
      final response = await ApiService().get(
        '${ApiConstants.apiAddCard}/$id',
      );
      return ResBaseModel.fromJson(response.data);
    } on DioException catch (error) {
      throw ResBaseModel.fromJsonWithCode(error.response);
    }
  }

  //Request Access code
  Future<ResAccessCode> requestAccessCode(ReqAccessCode request) async {
    try {
      final response = await ApiService().post(
        ApiConstants.apiAccessCode,
        data: request.toJson(),
      );
      return ResAccessCode.fromJson(response.data);
    } on DioException catch (error) {
      throw ResBaseModel.fromJsonWithCode(error.response);
    }
  }
}
