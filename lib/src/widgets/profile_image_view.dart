import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../utils/dimens.dart';
import '../utils/image_constants.dart';

class ProfileImageView extends StatelessWidget {
  final String profileUrl;
  final bool largeSize;

  const ProfileImageView(
      {Key? key, this.profileUrl = '', this.largeSize = false})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: largeSize ? spacing44 : spacingXXXLarge,
      width: largeSize ? spacing44 : spacingXXXLarge,
      decoration: BoxDecoration(
          shape: BoxShape.circle,
          image: DecorationImage(
              image: profileUrl.isNotEmpty
                  ? NetworkImage(profileUrl)
                  : const AssetImage(ImageConstants.icDefaultProfileImage),
              fit: BoxFit.cover),
          color: Colors.white),
    );
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(StringProperty('profileUrl', profileUrl));
    properties.add(DiagnosticsProperty<bool>('largeSize', largeSize));
  }
}
