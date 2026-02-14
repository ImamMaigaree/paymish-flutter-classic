import 'package:expandable/expandable.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../utils/color_utils.dart';
import '../utils/constants.dart';
import '../utils/dialog_utils.dart';
import '../utils/dimens.dart';
import '../utils/localization/localization.dart';
import '../utils/utils.dart';
import 'paymish_text_field.dart';

class ExpandableCardCell extends StatefulWidget {
  final int bankId;
  final String bankName;
  final String bankAccountNumber;
  final VoidCallback? onPayClick;

  const ExpandableCardCell(
      {Key? key,
      required this.bankId,
      required this.bankName,
      required this.bankAccountNumber,
      this.onPayClick})
      : super(key: key);

  @override
  _ExpandableCardCellState createState() => _ExpandableCardCellState();

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(IntProperty('bankId', bankId));
    properties.add(StringProperty('bankName', bankName));
    properties.add(StringProperty('bankAccountNumber', bankAccountNumber));
    properties
        .add(DiagnosticsProperty<VoidCallback?>('onPayClick', onPayClick));
  }
}

class _ExpandableCardCellState extends State<ExpandableCardCell> {
  late final ExpandableController _expandableController;
  late final TextEditingController _cvvController;
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _expandableController = ExpandableController();
    _cvvController = TextEditingController();
  }

  @override
  Widget build(BuildContext context) {
    getScreenSize(context);
    _getCollapsedCard(isPayVisible: false);
    return ExpandableNotifier(
      controller: _expandableController,
      child: ScrollOnExpand(
        scrollOnExpand: true,
        scrollOnCollapse: false,
        child: ExpandablePanel(
          controller: _expandableController,
          theme: const ExpandableThemeData(
            hasIcon: false,
          ),
          collapsed: _getCollapsedCard(isPayVisible: false),
          expanded: _getCollapsedCard(isPayVisible: true),
        ),
      ),
    );
  }

  InkWell _getCollapsedCard({required bool isPayVisible}) => InkWell(
        splashColor: Colors.transparent,
        highlightColor: Colors.transparent,
        onTap: () {
          setState(() {
            _expandableController.toggle();
          });
        },
        child: Card(
          margin: const EdgeInsets.symmetric(
              horizontal: spacingLarge, vertical: spacingTiny),
          shadowColor: ColorUtils.blackColor,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: spacingLarge),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                RadioGroup<int>(
                  groupValue: widget.bankId,
                  onChanged: (value) {},
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Radio(
                        value: isPayVisible ? widget.bankId : 0,
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.bankName,
                            style: const TextStyle(
                              fontSize: fontMedium,
                              fontWeight: FontWeight.w100,
                              fontFamily: fontFamilyPoppinsMedium,
                              color: ColorUtils.primaryTextColor,
                              letterSpacing: 1.5,
                            ),
                          ),
                          Text(
                            widget.bankAccountNumber,
                            style: const TextStyle(
                              fontSize: fontXSmall,
                              fontWeight: FontWeight.w100,
                              fontFamily: fontFamilyPoppinsRegular,
                              color: ColorUtils.primaryTextColor,
                              letterSpacing: 5,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                !isPayVisible
                    ? Container()
                    : Padding(
                        padding: const EdgeInsets.only(
                          left: spacingXXXSLarge,
                          right: spacingLarge,
                        ),
                        child: Form(
                          key: _formKey,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.baseline,
                            textBaseline: TextBaseline.alphabetic,
                            children: <Widget>[
                              Expanded(
                                flex: 1,
                                child: PaymishTextField(
                                  controller: _cvvController,
                                  enabled: true,
                                  hint: Localization.of(context).labelCvv,
                                  label: Localization.of(context).labelCvv,
                                  isPassword: false,
                                  maxLength: 3,
                                  textInputAction: TextInputAction.done,
                                  type: TextInputType.number,
                                  validateFunction: (value) {
                                    return Utils.isEmpty(
                                        context,
                                        value ?? '',
                                        Localization.of(context)
                                            .errorCvvNumber);
                                  },
                                ),
                              ),
                              Padding(
                                padding:
                                    const EdgeInsets.only(left: spacingLarge),
                                child: InkWell(
                                  highlightColor: Colors.transparent,
                                  splashColor: Colors.transparent,
                                  onTap: () {
                                    FocusScope.of(context)
                                        .requestFocus(FocusNode());
                                    if (_formKey.currentState?.validate() ??
                                        false) {
                                      DialogUtils.displayToast(
                                          Localization.of(context)
                                              .msgSuccessfulSend);
                                      // widget.onPayClick;
                                    }
                                  },
                                  child: Container(
                                    height: spacingXXLarge,
                                    width: spacingXXXMLarge,
                                    decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(
                                            spacingMedium),
                                        color: ColorUtils.primaryColor,
                                        boxShadow: [
                                          const BoxShadow(
                                            blurRadius: 1,
                                            color: ColorUtils.primaryColor,
                                          )
                                        ]),
                                    child: Center(
                                      child: Text(
                                        Localization.of(context)
                                            .labelPay
                                            .toUpperCase(),
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                          fontSize: fontSmall,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      )
              ],
            ),
          ),
        ),
      );
}
