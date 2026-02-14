import 'package:flutter/material.dart';

import '../../apis/apimanager/user_api_manager.dart';
import '../../apis/base_model.dart';
import '../../utils/color_utils.dart';
import '../../utils/common_methods.dart';
import '../../utils/constants.dart';
import '../../utils/dialog_utils.dart';
import '../../utils/dimens.dart';
import '../../utils/localization/localization.dart';
import '../../utils/navigation.dart';
import '../../utils/progress_dialog.dart';
import '../../utils/utils.dart';
import '../../widgets/paymish_appbar.dart';
import '../../widgets/paymish_primary_button.dart';
import '../../widgets/paymish_text_field.dart';
import 'model/req_create_support_ticket.dart';
import 'model/res_category_list.dart';

class CreateSupportTicket extends StatefulWidget {
  const CreateSupportTicket({Key? key}) : super(key: key);

  @override
  _CreateSupportTicketState createState() => _CreateSupportTicketState();
}

class _CreateSupportTicketState extends State<CreateSupportTicket> {
  final GlobalKey<FormState> _key = GlobalKey<FormState>();

  List<CategoryListItem> _categoryList = <CategoryListItem>[];
  CategoryListItem? _categoryOfSupportTicket;
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  final FocusNode _titleFocus = FocusNode();
  final FocusNode _descriptionFocus = FocusNode();

  @override
  void initState() {
    super.initState();
    _getCategory(context);
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PaymishAppBar(
        isBackGround: false,
        title: Localization.of(context).labelCreateSupportTicket,
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Form(
                    key: _key,
                    child: Column(
                      children: [
                        _paymentCategoryWidget(context),
                        _supportTitleWidget(context),
                        _supportDescriptionWidget(context),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          _submitButtonWidget(context)
        ],
      ),
    );
  }

  Widget _supportDescriptionWidget(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(
          top: spacingLarge, left: spacingLarge, right: spacingLarge),
      child: PaymishTextField(
        maxLength: 150,
        controller: _descriptionController,
        hint: Localization.of(context).labelDescription,
        label: Localization.of(context).labelDescription,
        type: TextInputType.text,
        focusNode: _descriptionFocus,
        textInputAction: TextInputAction.done,
        onFieldSubmitted: (_) {
          _descriptionFocus.unfocus();
          _submitPressed(context);
        },
        validateFunction: (value) {
          return Utils.isEmpty(
              context, value, Localization.of(context).errorDescription);
        },
      ),
    );
  }

  Widget _supportTitleWidget(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(
          top: spacingLarge, left: spacingLarge, right: spacingLarge),
      child: PaymishTextField(
        maxLength: 60,
        controller: _titleController,
        hint: Localization.of(context).labelTitle,
        label: Localization.of(context).labelTitle,
        type: TextInputType.text,
        focusNode: _titleFocus,
        textInputAction: TextInputAction.next,
        onFieldSubmitted: (_) {
          _titleFocus.unfocus();
          FocusScope.of(context).requestFocus(_descriptionFocus);
        },
        validateFunction: (value) {
          return Utils.isEmpty(
              context, value, Localization.of(context).errorTitle);
        },
      ),
    );
  }

  Widget _paymentCategoryWidget(BuildContext context) {
    return Container(
        padding: const EdgeInsets.only(
            top: spacingLarge, left: spacingLarge, right: spacingLarge),
        child: DropdownButtonFormField<CategoryListItem>(
          isExpanded: true,
          style: const TextStyle(
              color: ColorUtils.primaryColor,
              fontSize: fontLarge,
              fontFamily: fontFamilyPoppinsRegular),
          validator: (value) => value == null
              ? Localization.of(context).errorSelectSupportCategory
              : null,
          hint: Text(
            Localization.of(context).labelSelectCategory,
            style: const TextStyle(color: ColorUtils.primaryColor),
          ),
          items: _categoryList.map((value) {
            return DropdownMenuItem<CategoryListItem>(
              value: value,
              child: Text(value.name ?? ''),
            );
          }).toList(),
          initialValue: _categoryOfSupportTicket,
          onChanged: (CategoryListItem? newValueSelected) {
            setState(() {
              _categoryOfSupportTicket = newValueSelected;
            });
          },
        ));
  }

  Widget _submitButtonWidget(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(
          left: spacingLarge, right: spacingLarge, bottom: spacingLarge),
      child: PaymishPrimaryButton(
        buttonText: Localization.of(context).save,
        isBackground: true,
        onButtonClick: () => _submitPressed(context),
      ),
    );
  }

  // Set support Ticket Id for API call
  void _submitPressed(BuildContext context) {
    if (_key.currentState?.validate() ?? false) {
      FocusScope.of(context).requestFocus(FocusNode());
      _key.currentState?.save();
      ProgressDialogUtils.showProgressDialog(context);
      UserApiManager()
          .createSupportTicket(ReqCreateSupportTicket(
              supportCategoryId: _categoryOfSupportTicket?.id ?? 0,
              title: _titleController.text.trim().toString(),
              description: _descriptionController.text.trim().toString()))
          .then((value) {
        ProgressDialogUtils.dismissProgressDialog();
        DialogUtils.displayToast(value.message ?? '');
        NavigationUtils.pop(context);
      }).catchError((dynamic e) {
        ProgressDialogUtils.dismissProgressDialog();
        if (e is ResBaseModel) {
          if (!checkSessionExpire(e, context)) {
            debugPrint(e.error);
            DialogUtils.showAlertDialog(context, e.error ?? '');
          } else {
            DialogUtils.showAlertDialog(context, e.message ?? '');
          }
        } else {
          DialogUtils.showAlertDialog(context, e.toString());
        }
      });
    }
  }

  void _getCategory(BuildContext context) {
    UserApiManager().getCategoryList().then((value) {
      setState(() {
        _categoryList = value.data ?? <CategoryListItem>[];
      });
    }).catchError((dynamic e) {
      ProgressDialogUtils.dismissProgressDialog();
      if (e is ResBaseModel) {
        if (!checkSessionExpire(e, context)) {
          debugPrint(e.error);
          DialogUtils.showAlertDialog(context, e.error ?? '');
        } else {
          DialogUtils.showAlertDialog(context, e.message ?? '');
        }
      } else {
        DialogUtils.showAlertDialog(context, e.toString());
      }
    });
  }
}
