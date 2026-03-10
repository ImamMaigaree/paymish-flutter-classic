import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../utils/color_utils.dart';
import '../utils/constants.dart';

class MyProfileRow extends StatelessWidget {
  final String image;
  final String title;
  final GestureTapCallback? onTap;

  const MyProfileRow(
      {super.key, required this.image, required this.title, this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Row(
        children: [
          SizedBox(
            height: 25,
            width: 25,
            child: Image.asset(
              image,
              scale: 1,
            ),
          ),
          Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 25.0, vertical: 20.0),
            child: Text(
              title,
              style: const TextStyle(
                color: ColorUtils.primaryTextColor,
                fontSize: 12.0,
                fontFamily: fontFamilyPoppinsRegular,
              ),
            ),
          )
        ],
      ),
    );
  }
  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(StringProperty('image', image));
    properties.add(StringProperty('title', title));
    properties.add(DiagnosticsProperty<GestureTapCallback?>('onTap', onTap));
  }
}
