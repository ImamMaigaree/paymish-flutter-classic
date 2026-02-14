import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';

import '../../../apis/apimanager/user_api_manager.dart';
import '../../../apis/base_model.dart';
import '../../../apis/dic_params.dart';
import '../../../utils/common_methods.dart';
import '../../../utils/constants.dart';
import '../../../utils/dialog_utils.dart';
import '../../../utils/localization/localization.dart';
import '../../../utils/navigation.dart';
import '../../../utils/navigation_params.dart';
import '../../../utils/preference_key.dart';
import '../../../utils/preference_utils.dart';
import '../../../utils/progress_dialog.dart';
import '../../../widgets/paymish_appbar.dart';
import '../../../widgets/recent_list_view.dart';
import '../../auth/home/provider/home_screen_provider.dart';
import '../../transfermoney/model/res_transfer_money_list.dart';
import '../../transfermoney/provider/pay_request_provider.dart';
import '../../transfermoney/scanandpay/model/req_qr_scan.dart';

const flashOn = 'FLASH ON';
const flashOff = 'FLASH OFF';
const frontCamera = 'FRONT CAMERA';
const backCamera = 'BACK CAMERA';

class ScanAndPay extends StatefulWidget {
  const ScanAndPay({Key? key}) : super(key: key);

  @override
  _ScanAndPayState createState() => _ScanAndPayState();
}

class _ScanAndPayState extends State<ScanAndPay> {
  late QRViewController _controller;
  final GlobalKey _qrKey = GlobalKey(debugLabel: 'QR');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: PaymishAppBar(
        title: Localization.of(context).scanAndPayHeader,
        isBackGround: false,
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              flex: 2,
              child: QRView(
                key: _qrKey,
                onQRViewCreated: _onQRViewCreated,
                overlay: QrScannerOverlayShape(
                  borderColor: Colors.black,
                  borderLength: 60,
                  borderWidth: 10,
                ),
              ),
            ),
            Expanded(
              flex: 1,
              child: Column(
                children: [
                  _getPhoneNumberTextField(),
                  Provider.of<HomeScreenProvider>(context, listen: true)
                          .getHomeData()
                          .isNotEmpty
                      ? RecentListView(
                          context: context,
                          recentListContact: Provider.of<HomeScreenProvider>(
                                  context,
                                  listen: true)
                              .getHomeData(),
                          isFromScan: true,
                        )
                      : Container(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _getPhoneNumberTextField() {
    return Container(
      padding: const EdgeInsets.only(left: 15.0, top: 8.0, right: 15.0),
      child: TextField(
        decoration: InputDecoration(
          focusedBorder: const UnderlineInputBorder(),
          border: const UnderlineInputBorder(),
          suffixIcon: const Icon(Icons.search),
          hintText: Localization.of(context).mobileNumber,
        ),
        textInputAction: TextInputAction.search,
        readOnly: true,
        onTap: () {
          NavigationUtils.push(context, routeGlobalSearch,
              arguments: {NavigationParams.isPayScreen: true});
        },
      ),
    );
  }

  void _onQRViewCreated(QRViewController controller) {
    _controller = controller;
    controller.scannedDataStream.listen((scanData) {
      controller.pauseCamera();
      final scannedCode = scanData.code;
      if (scannedCode?.isNotEmpty ?? false) {
        _getScanQRDataApiCall(qrCode: scannedCode!);
      } else {
        controller.resumeCamera();
      }
    });
  }

  void _getScanQRDataApiCall({String qrCode = ''}) {
    if (qrCode.isEmpty) {
      _controller.resumeCamera();
      return;
    }
    ProgressDialogUtils.showProgressDialog(context);
    UserApiManager().scanAndPay(ReqQRScan(qrCode: qrCode)).then((value) async {
      ProgressDialogUtils.dismissProgressDialog();
      if (getString(PreferenceKey.kycStatus) == DicParams.notVerified) {
        openTransactionDetailsDialog(context, routeCompleteKYC);
      } else if (getInt(PreferenceKey.isBankAccount) == 0) {
        openTransactionDetailsDialog(context, routeWalletSetup);
      } else if (getInt(PreferenceKey.isTransactionPin) == 0) {
        openTransactionDetailsDialog(context, routeTransactionPinSetup);
      } else {
        final scanData = value.data;
        Provider.of<PayRequestProvider>(context, listen: false)
            .setPaymentModel(TransferMoneyListData(
          firstName: scanData?.firstName,
          lastName: scanData?.lastName,
          id: scanData?.id,
          mobile: scanData?.mobile,
          profilePicture: scanData?.profilePicture,
        ));
        final data = await NavigationUtils.push(context, routePayMoneyScreen,
            arguments: {'isPayScreen': true});
        if (data == null) {
          _controller.dispose();
          _controller.resumeCamera();
        }
      }
    }).catchError((dynamic e) {
      ProgressDialogUtils.dismissProgressDialog();
      if (e is ResBaseModel) {
        if (!checkSessionExpire(e, context)) {
          DialogUtils.showAlertDialog(context, e.error ?? '');
        }
      } else {
        DialogUtils.showAlertDialog(context, e.error ?? '');
      }
      _controller.resumeCamera();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
