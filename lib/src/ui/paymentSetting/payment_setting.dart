import 'package:flutter/material.dart';

import '../../utils/color_utils.dart';
import '../../utils/constants.dart';
import '../../utils/dimens.dart';
import '../../utils/image_constants.dart';
import '../../utils/localization/localization.dart';
import '../../utils/navigation.dart';
import '../../widgets/paymish_appbar.dart';

class PaymentSettingScreen extends StatefulWidget {
  const PaymentSettingScreen({Key? key}) : super(key: key);

  @override
  _PaymentSettingScreenState createState() => _PaymentSettingScreenState();
}

class _PaymentSettingScreenState extends State<PaymentSettingScreen> {
  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: PaymishAppBar(
        title: Localization.of(context).paymentSettings,
        isBackGround: false,
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(
                        left: spacingLarge,
                        right: spacingLarge,
                        bottom: spacingSmall,
                        top: spacingLarge),
                    child: Text(
                      Localization.of(context).labelPaymentMethod,
                      style: const TextStyle(
                          fontSize: fontLarge,
                          fontFamily: fontFamilyPoppinsMedium,
                          color: ColorUtils.recentTextColor),
                    ),
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.only(
                              left: spacingLarge, right: spacingXSmall),
                          child: InkWell(
                            onTap: (){
                              NavigationUtils.push(context, routeCardDetails);
                            },
                            child: Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10.0),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withAlpha(20),
                                    blurRadius: 20.0,
                                  )
                                ],
                                color: Colors.white,
                              ),
                              child: Padding(
                                padding: const EdgeInsets.fromLTRB(
                                    spacingMedium,
                                    spacingXXLarge,
                                    spacingMedium,
                                    spacingXXLarge),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Image.asset(
                                      ImageConstants.icPay,
                                      scale: 2.8,
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.only(
                                          top: spacingSmall),
                                      child: Text(
                                        Localization.of(context).labelCard,
                                        style: const TextStyle(
                                            fontSize: fontSmall,
                                            color: ColorUtils.merchantHomeRow),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.only(
                              right: spacingLarge, left: spacingXSmall),
                          child: InkWell(
                            onTap: () {
                              NavigationUtils.push(context, routeBankDetails);
                            },
                            child: Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10.0),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withAlpha(20),
                                    blurRadius: 20.0,
                                  )
                                ],
                                color: Colors.white,
                              ),
                              child: Padding(
                                padding: const EdgeInsets.fromLTRB(
                                    spacingMedium,
                                    spacingXXLarge,
                                    spacingMedium,
                                    spacingXXLarge),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Image.asset(
                                      ImageConstants.icBank,
                                      scale: 2.8,
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.only(
                                          top: spacingSmall),
                                      child: Text(
                                        Localization.of(context)
                                            .labelBankOfNigeria,
                                        style: const TextStyle(
                                            fontSize: fontSmall,
                                            color: ColorUtils.merchantHomeRow),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      )
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
