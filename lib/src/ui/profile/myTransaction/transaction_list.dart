import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../../../utils/color_utils.dart';
import '../../../utils/constants.dart';
import '../../../utils/dimens.dart';
import '../../../utils/utils.dart';

class TransactionListItem extends StatelessWidget {
  final String profilePicture;
  final String title;
  final String firstName;
  final String lastName;
  final String time;
  final num amount;

  const TransactionListItem({
    Key? key,
    required this.profilePicture,
    required this.title,
    required this.firstName,
    required this.lastName,
    required this.time,
    required this.amount,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: imageXLarge / 2,
      margin: const EdgeInsets.symmetric(
          horizontal: spacingLarge, vertical: spacingTiny),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(spacingTiny),
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(20),
            blurRadius: circleTiny,
          ),
        ],
      ),
      child: ListTile(
        isThreeLine: false,
        leading: Container(
                width: spacingXXXLarge,
                height: spacingXXXLarge,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  image: DecorationImage(
                      image: NetworkImage(profilePicture), fit: BoxFit.cover),
                ),
              ),
        title: Text(
          title,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
              fontFamily: fontFamilyPoppinsMedium,
              fontSize: fontSmall,
              color: ColorUtils.primaryTextColor),
        ),
        subtitle: Text(
          "$firstName $lastName",
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
              fontFamily: fontFamilyPoppinsRegular,
              fontSize: fontXSmall,
              color: ColorUtils.merchantHomeRow),
        ),
        trailing: Column(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(Utils.convertDateFromString(time, context),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: ColorUtils.merchantHomeRow,
                  fontSize: fontXSmall,
                  fontFamily: fontFamilyPoppinsRegular,
                )),
            RichText(
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
              text: TextSpan(
                text: countryCurrency,
                style: const TextStyle(
                  color: ColorUtils.primaryColor,
                  fontSize: fontLarge,
                  fontFamily: fontFamilySFMonoMedium,
                  fontWeight: FontWeight.w900,
                ),
                children: <TextSpan>[
                  TextSpan(
                    text: ' ${Utils.currencyFormat.format(amount)}',
                    style: const TextStyle(
                      color: ColorUtils.primaryColor,
                      fontSize: fontLarge,
                      fontFamily: fontFamilyPoppinsMedium,
                      fontWeight: FontWeight.w900,
                    ),
                  )
                ],
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
    properties.add(StringProperty('profilePicture', profilePicture));
    properties.add(StringProperty('title', title));
    properties.add(StringProperty('firstName', firstName));
    properties.add(StringProperty('lastName', lastName));
    properties.add(StringProperty('time', time));
    properties.add(DiagnosticsProperty<num>('amount', amount));
  }
}
