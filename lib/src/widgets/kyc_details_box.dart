import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../apis/dic_params.dart';
import '../utils/color_utils.dart';
import '../utils/constants.dart';
import '../utils/image_constants.dart';
import '../utils/localization/localization.dart';
import '../utils/navigation.dart';
import '../utils/navigation_params.dart';
import '../utils/preference_key.dart';
import '../utils/preference_utils.dart';

class KycDetailsBox extends StatelessWidget {
  final String bvnNo;

  const KycDetailsBox({super.key, this.bvnNo = ''});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
        padding: const EdgeInsets.all(20.0),
        margin: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 20.0),
        decoration: BoxDecoration(
          color: ColorUtils.bvnBgColor,
          border: Border.all(color: ColorUtils.bvnBorderColor),
          borderRadius: BorderRadius.circular(4.0),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Row(
              children: [
                Text(
                  Localization.of(context).kycDetails,
                  style: const TextStyle(
                    fontFamily: fontFamilyPoppinsMedium,
                    fontSize: 14.0,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child:
                      getString(PreferenceKey.kycStatus) ==
                          DicParams.notVerified
                      ? GestureDetector(
                          onTap: () {
                            NavigationUtils.push(
                              context,
                              routeCompleteKYC,
                              arguments: {
                                NavigationParams.showBackButton: true,
                                NavigationParams.completeTransactionDetails:
                                    false,
                              },
                            );
                          },
                          child: Text(
                            Localization.of(context).verifyNowLabel,
                            style: const TextStyle(color: Colors.red),
                          ),
                        )
                      : Image.asset(ImageConstants.icVerified, scale: 2.0),
                ),
              ],
            ),
            const SizedBox(height: 8.0),
            getString(PreferenceKey.kycStatus) != DicParams.notVerified
                ? Row(
                    children: [
                      Text(
                        '${Localization.of(context).bvnNo} : ',
                        style: const TextStyle(
                          fontFamily: fontFamilyPoppinsRegular,
                          fontSize: 14.0,
                        ),
                      ),
                      Text(
                        getString(PreferenceKey.bvnNumber).isEmpty
                            ? ""
                            : getString(PreferenceKey.bvnNumber),
                        style: const TextStyle(
                          fontFamily: fontFamilyPoppinsRegular,
                          fontSize: 12.0,
                        ),
                      ),
                    ],
                  )
                : Text(
                    Localization.of(context).msgCompleteKyc,
                    style: const TextStyle(
                      fontFamily: fontFamilyPoppinsRegular,
                      fontSize: 14.0,
                    ),
                  ),
          ],
        ),
      ),
    );
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(StringProperty('bvnNo', bvnNo));
  }
}
