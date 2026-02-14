import 'package:contacts_service/contacts_service.dart';
import 'package:flutter/foundation.dart';
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
import '../../utils/debouncer.dart';
import '../../utils/dialog_utils.dart';
import '../../utils/dimens.dart';
import '../../utils/image_constants.dart';
import '../../utils/localization/localization.dart';
import '../../utils/navigation.dart';
import '../../utils/navigation_params.dart';
import '../../utils/permission_util.dart';
import '../../utils/preference_key.dart';
import '../../utils/preference_utils.dart';
import '../../utils/utils.dart';
import '../../widgets/profile_image_view.dart';
import '../requestmoney/model/req_contact.dart';
import '../requestmoney/model/res_contact.dart';
import '../transfermoney/model/res_transfer_money_list.dart';
import '../transfermoney/provider/pay_request_provider.dart';
import 'model/req_search_data.dart';
import 'model/res_search_data.dart';

class GlobalSearch extends StatefulWidget {
  final bool isPayScreen;

  const GlobalSearch({Key? key, this.isPayScreen = false}) : super(key: key);

  @override
  _GlobalSearchState createState() => _GlobalSearchState();

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(DiagnosticsProperty<bool>('isPayScreen', isPayScreen));
  }
}

class _GlobalSearchState extends State<GlobalSearch> {
  final FocusNode _searchFocus = FocusNode();
  final TextEditingController _searchController = TextEditingController();
  final _deBouncer = Debouncer(milliseconds: 200);
  final _isLoading = ValueNotifier<bool>(false);
  final _searchString = ValueNotifier<String>("");

  final DatabaseHelper _dbHelper = DatabaseHelper.instance;
  final List<AllContacts> _allContacts = [];
  List<ContactResponseModel> _fetchedContacts = [];

  List<SearchData> _searchData = [];

  @override
  void initState() {
    super.initState();
    _fetchLocalContact();
  }

  Future _fetchLocalContact() async {
    _fetchedContacts =
        (await _dbHelper.fetchAllContact()).cast<ContactResponseModel>();
    setState(() {});
    await _getContacts(isBackGround: false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding:
                  const EdgeInsets.only(top: 8.0, right: 8.0, bottom: 16.0),
              child: Row(
                children: [
                  IconButton(
                    padding: const EdgeInsets.all(0),
                    icon: Image.asset(
                      ImageConstants.icBackArrow,
                      scale: 1.5,
                    ),
                    onPressed: () {
                      NavigationUtils.pop(context);
                    },
                  ),
                  Expanded(child: _getSearchTextField()),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 18.0),
              child: Row(
                children: [
                  Text(Localization.of(context).labelFindByPhoneNumberOrName,
                      style: const TextStyle(
                          color: ColorUtils.merchantHomeRow,
                          fontSize: 11.0,
                          fontFamily: fontFamilyPoppinsRegular)),
                ],
              ),
            ),
            ValueListenableBuilder(
              valueListenable: _isLoading,
              builder: (context, isLoading, _) =>
                  isLoading ? _getLoadingIndicator() : Container(),
            ),
            Expanded(child: _getSearchUserList())
          ],
        ),
      ),
    );
  }

  Widget _getLoadingIndicator() {
    return Row(
      children: [
        Container(
          height: 20,
          width: 20,
          margin: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
          child: const CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(ColorUtils.primaryColor),
            strokeWidth: 3.0,
          ),
        ),
        ValueListenableBuilder(
          valueListenable: _searchString,
          builder: (context, searchString, _) => Text(
            '${Localization.of(context).searchingFor} $searchString...',
            style: const TextStyle(
              fontSize: 16.0,
              fontFamily: fontFamilyPoppinsRegular,
            ),
          ),
        )
      ],
    );
  }

  Widget _getSearchTextField() {
    return TextField(
      focusNode: _searchFocus,
      controller: _searchController,
      keyboardType: TextInputType.visiblePassword,
      decoration: InputDecoration(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(avatarMSmall),
        ),
        contentPadding: const EdgeInsets.all(0),
        prefixIcon: const Icon(Icons.search),
        hintText: Localization.of(context).searchForPeople,
      ),
      textInputAction: TextInputAction.search,
      onChanged: (value) {
        _searchString.value = value;
        if (value.isNotEmpty) {
          _isLoading.value = true;
          _deBouncer.run(() => _getSearchResult(value: value.trim()));
        } else {
          _isLoading.value = false;
        }
      },
      onEditingComplete: _searchFocus.unfocus,
    );
  }

  Widget _getSearchUserList() {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
      itemCount: _searchData.length,
      itemBuilder: (context, index) {
        final data = _searchData[index];
        return GestureDetector(
          child: (data.role ?? '') == DicParams.roleMerchant &&
                  !widget.isPayScreen
              ? const SizedBox()
              : Container(
                  height: 70,
                  margin: const EdgeInsets.only(bottom: 10.0),
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(4.0),
                      border: Border.all(color: ColorUtils.borderColor),
                      boxShadow: <BoxShadow>[
                        BoxShadow(
                          color: Colors.black.withAlpha(20),
                          blurRadius: 20.0,
                        )
                      ]),
                  child: Row(
                    children: [
                      ProfileImageView(
                          profileUrl: data.profilePicture ?? ''),
                      Padding(
                        padding: const EdgeInsets.only(left: 16.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              (data.businessName ?? '').isEmpty
                                  ? '''${data.firstName ?? ''} ${data.lastName ?? ''}'''
                                  : (data.businessName ?? ''),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                  color: ColorUtils.primaryTextColor,
                                  fontSize: 12.0,
                                  fontFamily: fontFamilyPoppinsMedium),
                            ),
                            Text(
                              data.mobile ?? '',
                              style: const TextStyle(
                                  color: ColorUtils.merchantHomeRow,
                                  fontSize: 11.0,
                                  fontFamily: fontFamilyPoppinsRegular),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
          onTap: () {
            _gotoNextScreen(context, data);
          },
        );
      },
    );
  }

  void _gotoNextScreen(BuildContext context, SearchData data) {
    if (getString(PreferenceKey.kycStatus) == DicParams.notVerified) {
      openTransactionDetailsDialog(context, routeCompleteKYC);
    } else if (getInt(PreferenceKey.isBankAccount) == 0) {
      openTransactionDetailsDialog(context, routeWalletSetup);
    } else if (getInt(PreferenceKey.isTransactionPin) == 0) {
      openTransactionDetailsDialog(context, routeTransactionPinSetup);
    } else {
      if (widget.isPayScreen) {
        Provider.of<PayRequestProvider>(context, listen: false)
            .setPaymentModel(TransferMoneyListData(
          firstName: data.businessName ?? '',
          lastName: "",
          id: data.id ?? 0,
          mobile: data.mobile ?? '',
          profilePicture: data.profilePicture ?? '',
        ));
      } else {
        Provider.of<PayRequestProvider>(context, listen: false)
            .setRequestModel(ContactResponseModel(
          firstName: data.businessName ?? '',
          lastName: "",
          id: data.id ?? 0,
          mobile: data.mobile ?? '',
          profilePicture: data.profilePicture ?? '',
        ));
      }
      NavigationUtils.push(context, routePayMoneyScreen,
          arguments: {NavigationParams.isPayScreen: widget.isPayScreen});
    }
  }

  void _getSearchResult({required String value}) {
    UserApiManager().globalSearch(ReqSearchModel(keyword: value)).then((value) {
      _isLoading.value = false;
      setState(() {
        _searchData = value.data ?? <SearchData>[];
      });
    }).catchError((dynamic e) {
      _isLoading.value = false;
      if (e is ResBaseModel) {
        if (!checkSessionExpire(e, context)) {
          DialogUtils.showAlertDialog(context, e.error ?? '');
        }
      } else {
        DialogUtils.showAlertDialog(context, e.toString());
      }
    });
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
          final phones = contacts.phones ?? [];
          for (final phone in phones) {
            _allContacts.add(AllContacts(
                contactNo:
                    await Utils.formatMobileNumber(phone.value ?? '')));
          }
        }
        _contactSyncApiCall(isBackGround: isBackGround);
      });
    });
  }

  void _contactSyncApiCall({bool isBackGround = false}) {
    if (!isBackGround) {
      _isLoading.value = true;
    }

    UserApiManager()
        .contactSync(ReqContactModel(allContacts: _allContacts))
        .then((value) {
      if (!isBackGround) {
        _isLoading.value = false;
      }
      setState(() {
        _fetchedContacts = value.data ?? <ContactResponseModel>[];
        for (final element in _fetchedContacts) {
          final mobile = element.mobile ?? '';
          _searchData.add(SearchData(
              firstName: element.firstName,
              lastName: element.lastName,
              profilePicture: element.profilePicture,
              mobile: mobile.length > 4 ? mobile.substring(4) : mobile));
        }
      });
      _storeContacts(contacts: value.data ?? <ContactResponseModel>[]);
    }).catchError((dynamic e) {
      if (!isBackGround) {
        _isLoading.value = false;
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
        DBConstant.dbColumnId: element.id ?? 0,
        DBConstant.dbColumnFirstName: element.firstName ?? '',
        DBConstant.dbColumnLastName: element.lastName ?? '',
        DBConstant.dbColumnMobile: element.mobile ?? '',
        DBConstant.dbColumnProfilePicture: element.profilePicture ?? '',
      };
      await _dbHelper.insert(row);
    }
  }
}
