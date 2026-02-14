import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../ui/auth/home/model/res_home.dart';
import '../utils/color_utils.dart';
import '../utils/constants.dart';
import '../utils/dimens.dart';
import '../utils/localization/localization.dart';
import '../utils/navigation.dart';
import '../utils/navigation_params.dart';
import 'profile_image_view.dart';

class RecentListView extends StatelessWidget {
  const RecentListView(
      {Key? key,
      required this.context,
      required this.recentListContact,
      required this.isFromScan})
      : super(key: key);

  final BuildContext context;
  final List<Contacts> recentListContact;
  final bool isFromScan;

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 15.0, vertical: 10.0),
            child: Text(
              Localization.of(context).recent,
              style: const TextStyle(
                color: ColorUtils.recentTextColor,
                fontSize: 16.0,
                fontFamily: fontFamilyPoppinsMedium,
              ),
            ),
          ),
          GridView.count(
            padding: const EdgeInsets.symmetric(horizontal: 15.0),
            crossAxisCount: 5,
            childAspectRatio: 1 / 1.2,
            crossAxisSpacing: 15.0,
            primary: false,
            shrinkWrap: true,
            children: List.generate(
              isFromScan && recentListContact.length > 5
                  ? 5
                  : recentListContact.length,
              (index) {
                return InkWell(
                  onTap: () {
                    final userId = recentListContact[index].id;
                    if (userId == null || userId == 0) {
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                          content: Text(Localization.of(context)
                              .errorSomethingWentWrong)));
                      return;
                    }
                    NavigationUtils.push(context, routeChatScreen, arguments: {
                      NavigationParams.senderUserId: userId,
                      NavigationParams.senderProfileImage:
                          recentListContact[index].profilePicture,
                      NavigationParams.senderName:
                          (recentListContact[index].firstName ?? '').trim(),
                    });
                  },
                  child: Column(
                    children: [
                      ProfileImageView(
                        profileUrl:
                            recentListContact[index].profilePicture ?? '',
                      ),
                      Text(
                        recentListContact[index].firstName ?? '',
                        style: const TextStyle(
                          fontFamily: fontFamilyPoppinsRegular,
                          color: ColorUtils.primaryTextColor,
                          fontSize: fontSmall,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      )
                    ],
                  ),
                );
              },
            ),
          )
        ],
      ),
    );
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(DiagnosticsProperty<BuildContext>('context', context));
    properties.add(
        IterableProperty<Contacts>('recentListContact', recentListContact));
    properties.add(DiagnosticsProperty<bool>('isFromScan', isFromScan));
  }
}
