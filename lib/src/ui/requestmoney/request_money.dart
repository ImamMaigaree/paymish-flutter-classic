import 'package:contacts_service/contacts_service.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';

import '../../apis/apimanager/user_api_manager.dart';
import '../../apis/base_model.dart';
import '../../apis/dic_params.dart';
import '../../utils/color_utils.dart';
import '../../utils/common_methods.dart';
import '../../utils/constants.dart';
import '../../utils/database_helper.dart';
import '../../utils/db_constant.dart';
import '../../utils/dialog_utils.dart';
import '../../utils/dimens.dart';
import '../../utils/localization/localization.dart';
import '../../utils/navigation.dart';
import '../../utils/navigation_params.dart';
import '../../utils/permission_util.dart';
import '../../utils/preference_key.dart';
import '../../utils/preference_utils.dart';
import '../../utils/utils.dart';
import '../../widgets/paymish_appbar.dart';
import '../../widgets/profile_image_view.dart';
import '../transfermoney/provider/pay_request_provider.dart';
import 'model/req_contact.dart';
import 'model/res_contact.dart';

class RequestMoneyScreen extends StatefulWidget {
  const RequestMoneyScreen({Key? key}) : super(key: key);

  @override
  _RequestMoneyScreenState createState() => _RequestMoneyScreenState();
}

class _RequestMoneyScreenState extends State<RequestMoneyScreen> {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;
  final List<AllContacts> _allContacts = [];
  List<ContactResponseModel> _fetchedContacts = [];
  final _isMainLoading = ValueNotifier<bool>(false);

  @override
  void initState() {
    super.initState();
    whenPermissonAllow();
  }

  Future whenPermissonAllow() async {
    if (await isDatabaseExist()) {
      await _fetchLocalContact();
    } else {
      PermissionUtils.requestPermission([Permission.contacts], context,
          isOpenSettings: true, permissionGrant: () async {
        await _getContacts(isBackGround: false);
      }, permissionDenied: () {});
    }
  }

  Future<bool> isDatabaseExist() async {
    final rows = await _dbHelper.queryRowCount();
    if (rows == 0) {
      return false;
    } else {
      return true;
    }
  }

  Future _fetchLocalContact() async {
    _fetchedContacts = await _dbHelper.fetchAllContact();
    setState(() {});
    await _getContacts(isBackGround: true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: PaymishAppBar(
        title: Localization.of(context).requestMoneyHeader,
        isBackGround: false,
        isHideBackButton: true,
      ),
      body: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.all(spacingMedium),
            child: _getSearchTextField(),
          ),
          Expanded(
            child: ValueListenableBuilder(
              valueListenable: _isMainLoading,
              builder: (context, isMainLoading, _) => !isMainLoading
                  ? _fetchedContacts.isEmpty
                      ? Center(
                          child: Text(
                              Localization.of(context).labelNoContactsFound))
                      : _getUserList()
                  : const Center(
                      child: CircularProgressIndicator(
                      backgroundColor: ColorUtils.primaryColor,
                    )),
            ),
          ),
        ],
      ),
    );
  }

  Widget _getSearchTextField() {
    return TextField(
      decoration: InputDecoration(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(avatarMSmall),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(avatarMSmall),
        ),
        contentPadding: const EdgeInsets.only(left: 16.0),
        suffixIcon: const Icon(Icons.search),
        hintText: Localization.of(context).labelSearch,
      ),
      textInputAction: TextInputAction.search,
      readOnly: true,
      onTap: () {
        NavigationUtils.push(context, routeGlobalSearch,
            arguments: {NavigationParams.isPayScreen: false});
      },
    );
  }

  ListView _getUserList() {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
      itemCount: _fetchedContacts.length,
      itemBuilder: (context, index) {
        return InkWell(
          onTap: () {
            if (getString(PreferenceKey.kycStatus) == DicParams.notVerified) {
              openTransactionDetailsDialog(context, routeCompleteKYC);
            } else if (getInt(PreferenceKey.isBankAccount) == 0) {
              openTransactionDetailsDialog(context, routeWalletSetup);
            } else if (getInt(PreferenceKey.isTransactionPin) == 0) {
              openTransactionDetailsDialog(context, routeTransactionPinSetup);
            } else {
              final mobile = _fetchedContacts[index].mobile ?? '';
              final trimmedMobile =
                  mobile.length > 4 ? mobile.substring(4) : mobile;
              Provider.of<PayRequestProvider>(context, listen: false)
                  .setRequestModel(ContactResponseModel(
                firstName: _fetchedContacts[index].firstName,
                lastName: _fetchedContacts[index].lastName,
                id: _fetchedContacts[index].id,
                mobile: trimmedMobile,
                profilePicture: _fetchedContacts[index].profilePicture,
              ));
              NavigationUtils.push(context, routePayMoneyScreen,
                  arguments: {NavigationParams.isPayScreen: false});
            }
          },
          child: Container(
            decoration: BoxDecoration(
              border: Border.all(color: ColorUtils.borderColor),
              borderRadius: BorderRadius.circular(4.0),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withAlpha(20),
                  blurRadius: 5.0,
                )
              ],
              color: Colors.white,
            ),
            margin: const EdgeInsets.only(bottom: spacingTiny),
            child: ListTile(
              leading: ProfileImageView(
                  profileUrl: _fetchedContacts[index].profilePicture ?? ''),
              title: Text(
                "${_fetchedContacts[index].firstName ?? ''} "
                "${_fetchedContacts[index].lastName ?? ''}",
                style: const TextStyle(
                    fontFamily: fontFamilyPoppinsMedium,
                    fontSize: fontSmall,
                    color: ColorUtils.secondaryColor),
              ),
              subtitle: Text(
                _fetchedContacts[index].mobile ?? '',
                style: const TextStyle(
                    fontFamily: fontFamilyPoppinsRegular,
                    fontSize: fontXMSmall,
                    color: ColorUtils.merchantHomeRow),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
        );
      },
    );
  }

  Future _getContacts({bool isBackGround = false}) async {
    PermissionUtils.checkPermissionStatus(Permission.contacts, context,
        permissionDenied: () {}, permissionGrant: () async {
      await ContactsService.getContacts(
              withThumbnails: false,
              orderByGivenName: true,
              photoHighResolution: false)
          .then((value) async {
        for (final contacts in value) {
          final phones = contacts.phones ?? <Item>[];
          for (final phone in phones) {
            if (phone.value != null && phone.value!.isNotEmpty) {
              _allContacts.add(AllContacts(
                  contactNo: await Utils.formatMobileNumber(phone.value!)));
            }
          }
        }
        _contactSyncApiCall(isBackGround: isBackGround);
      });
    });
  }

  void _contactSyncApiCall({bool isBackGround = false}) {
    if (!isBackGround) {
      _isMainLoading.value = true;
    }

    UserApiManager()
        .contactSync(ReqContactModel(allContacts: _allContacts))
        .then((value) {
      if (!isBackGround) {
        _isMainLoading.value = false;
      }
      setState(() {
        _fetchedContacts = value.data ?? [];
      });
      _storeContacts(contacts: value.data ?? []);
    }).catchError((dynamic e) {
      if (!isBackGround) {
        _isMainLoading.value = false;
      }
      if (e is ResBaseModel) {
        if (!checkSessionExpire(e, context)) {
          DialogUtils.showAlertDialog(context, e.error ?? '');
        }
      }
    });
  }

  Future _storeContacts(
      {List<ContactResponseModel> contacts = const []}) async {
    await _dbHelper.delete();
    for (final element in contacts) {
      final row = {
        DBConstant.dbColumnId: element.id,
        DBConstant.dbColumnFirstName: element.firstName,
        DBConstant.dbColumnLastName: element.lastName,
        DBConstant.dbColumnMobile: element.mobile,
        DBConstant.dbColumnProfilePicture: element.profilePicture,
      };
      await _dbHelper.insert(row);
    }
  }
}
