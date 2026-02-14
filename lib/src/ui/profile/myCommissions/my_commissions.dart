import 'package:flutter/material.dart';

import '../../../utils/color_utils.dart';
import '../../../utils/constants.dart';
import '../../../utils/dialog_utils.dart';
import '../../../utils/dimens.dart';
import '../../../utils/enum_utils.dart';
import '../../../utils/localization/localization.dart';
import '../../../widgets/paymish_appbar.dart';
import '../../../widgets/paymish_commission_view.dart';

class MyCommissionsScreen extends StatefulWidget {
  const MyCommissionsScreen({Key? key}) : super(key: key);

  @override
  _MyCommissionsScreenState createState() => _MyCommissionsScreenState();
}

class _MyCommissionsScreenState extends State<MyCommissionsScreen> {
  final __categoryOfCommissionDropDowns = [
    UtilityPaymentCommission.airtimeRecharge,
    UtilityPaymentCommission.dataServices,
    UtilityPaymentCommission.tvSubscription,
    UtilityPaymentCommission.electricityBill,
  ];

  String? _categoryOfBusinessDropDown;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PaymishAppBar(
        isBackGround: false,
        title: Localization.of(context).myCommissions,
      ),
      body: Column(
        children: [
          // Utility Payment Category Dropdown Widget
          utilityPaymentCategoryWidget(context),
          Expanded(
            child: ListView.builder(
              itemCount: 10,
              itemBuilder: (context, pos) {
                // Implement Data As Per API Response Here
                return PaymishCommission(
                  userImage: "https://via.placeholder.com/40",
                  amount: 100,
                  date: "1 Day Ago",
                  commissionType: "Commissions Earned",
                  userName: "Richard Gruger",
                  commissionDetails: "Electricity Bill",
                  onClick: () {
                    DialogUtils.displayToast(
                        "${_categoryOfBusinessDropDown ?? ''} Selected");
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // Utility Payment Category Dropdown Widget
  Widget utilityPaymentCategoryWidget(BuildContext context) {
    return Container(
        padding: const EdgeInsets.only(
            top: spacingMedium, left: spacingLarge, right: spacingLarge),
        child: DropdownButtonFormField<String>(
          isExpanded: true,
          style: const TextStyle(
              color: ColorUtils.primaryColor,
              fontSize: fontLarge,
              fontFamily: fontFamilyPoppinsRegular),
          validator: (value) => value == null
              ? Localization.of(context).errorUtilityPayment
              : null,
          hint: Text(
            Localization.of(context).labelUtilityPayment,
            style: const TextStyle(color: ColorUtils.primaryColor),
          ),
          items: __categoryOfCommissionDropDowns.map((value) {
            return DropdownMenuItem<String>(
              value: value.getPaymentChannel(),
              child: Text(value.getPaymentChannel()),
            );
          }).toList(),
          initialValue: _categoryOfBusinessDropDown,
          onChanged: (String? newValueSelected) {
            setState(() {
              _categoryOfBusinessDropDown = newValueSelected;
            });
          },
        ));
  }
}
