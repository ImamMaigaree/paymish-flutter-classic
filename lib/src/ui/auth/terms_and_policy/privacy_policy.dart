import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';

import '../../../apis/apimanager/user_api_manager.dart';
import '../../../apis/base_model.dart';
import '../../../utils/dialog_utils.dart';
import '../../../utils/dimens.dart';
import '../../../utils/localization/localization.dart';
import '../../../utils/progress_dialog.dart';
import '../../../widgets/paymish_appbar.dart';

class PrivacyPolicyScreen extends StatefulWidget {
  final bool isPrivacyPolicy;

  const PrivacyPolicyScreen({Key? key, this.isPrivacyPolicy = false})
      : super(key: key);

  @override
  _PrivacyPolicyScreenState createState() => _PrivacyPolicyScreenState();

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
        .add(DiagnosticsProperty<bool>('isPrivacyPolicy', isPrivacyPolicy));
  }
}

class _PrivacyPolicyScreenState extends State<PrivacyPolicyScreen> {
  String _dataString = "";

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _getTermsAndCondition();
    });
  }

  Future<void> _getTermsAndCondition() async {
    ProgressDialogUtils.showProgressDialog(context);
    await UserApiManager()
        .getCMS(isPrivacyPolicy: widget.isPrivacyPolicy)
        .then((value) {
      setState(() {
        _dataString = value;
      });
      // If API response is SUCCESS
      ProgressDialogUtils.dismissProgressDialog();
    }).catchError((dynamic e) {
      // If API response is FAILURE or ANY EXCEPTION
      ProgressDialogUtils.dismissProgressDialog();
      if (e is ResBaseModel) {
        DialogUtils.showAlertDialog(context, e.error ?? '');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PaymishAppBar(
        title: widget.isPrivacyPolicy
            ? Localization.of(context).privacyPolicy
            : Localization.of(context).termsAndCondition,
        isBackGround: false,
      ),
      body: SingleChildScrollView(
          child: Padding(
        padding: const EdgeInsets.only(left: spacingLarge, right: spacingLarge),
        child: Html(data: _dataString),
      )),
    );
  }
}
