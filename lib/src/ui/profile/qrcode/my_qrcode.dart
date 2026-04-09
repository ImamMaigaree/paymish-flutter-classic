import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:screenshot/screenshot.dart';

import '../../../utils/color_utils.dart';
import '../../../utils/dialog_utils.dart';
import '../../../utils/dimens.dart';
import '../../../utils/localization/localization.dart';
import '../../../utils/permission_util.dart';
import '../../../utils/preference_key.dart';
import '../../../utils/preference_utils.dart';
import '../../../widgets/paymish_appbar.dart';
import '../../../widgets/paymish_primary_button.dart';

class MyQrCodeScreen extends StatefulWidget {
  const MyQrCodeScreen({Key? key}) : super(key: key);

  @override
  _MyQrCodeScreenState createState() => _MyQrCodeScreenState();
}

class _MyQrCodeScreenState extends State<MyQrCodeScreen> {
  late final ScreenshotController _screenshotController;
  String _qrString = "";

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _getQrString();
    });

    _screenshotController = ScreenshotController();
  }

  Future _getQrString() async {
    _qrString = getString(PreferenceKey.qrCode, "");
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PaymishAppBar(
        title: Localization.of(context).myQrCodeLabel,
        isBackGround: false,
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Expanded(
            child: Container(),
          ),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Screenshot(
                controller: _screenshotController,
                child: Container(
                  color: Colors.white,
                  padding: const EdgeInsets.all(spacingLarge),
                  child: QrImageView(
                    data: _qrString,
                    size: MediaQuery.of(context).size.width * 0.6,
                    foregroundColor: ColorUtils.primaryColor,
                    backgroundColor: Colors.white,
                  ),
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.only(
                top: spacingXXXLarge,
                left: spacingXXXLarge,
                right: spacingXXXLarge),
            child: Text(
              _qrString,
              style: TextStyle(
                  fontSize: fontLarger,
                  color: Theme.of(context).primaryColor,
                  letterSpacing: 5),
              textAlign: TextAlign.center,
            ),
          ),
          Expanded(
            child: Container(),
          ),
          Padding(
            padding: const EdgeInsets.only(
                left: spacingXXXXXLarge + spacingXLarge,
                right: spacingXXXXXLarge + spacingXLarge,
                bottom: spacingLarge),
            child: PaymishPrimaryButton(
              buttonText: Localization.of(context).labelDownload,
              isBackground: true,
              onButtonClick: saveAsImageWithPermission,
            ),
          )
        ],
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }

  // ask permission for storage if not available to store qr-code as image
  Future<void> saveAsImageWithPermission() async {
    PermissionUtils.requestPermission([Permission.storage], context,
        isOpenSettings: true, permissionGrant: () {
      _screenshotController
          .capture(delay: const Duration(milliseconds: 200))
          .then((image) async {
        if (image != null) {
          _saved(image);
        }
      }).catchError((error) {
        DialogUtils.displaySnackBar(message: error);
      });
    }, permissionDenied: () {});
  }

  // file save in local storage
  Future<void> _saved(Uint8List image) async {
    await ImageGallerySaver.saveImage(image);
    await DialogUtils.displayToast(Localization.of(context).qrDownloadSuccess);
  }
}
