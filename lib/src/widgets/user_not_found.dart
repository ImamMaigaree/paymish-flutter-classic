import 'package:flutter/material.dart';

import '../utils/constants.dart';
import '../utils/localization/localization.dart';

class UserNotVerfied extends StatelessWidget {
  const UserNotVerfied({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Center(
        child: Text(
          Localization.of(context).msgAccountNotApproved,
          style: const TextStyle(
            color: Colors.grey,
            fontSize: 16.0,
            fontFamily: fontFamilyPoppinsMedium,
          ),
        ),
      ),
    );
  }
}
