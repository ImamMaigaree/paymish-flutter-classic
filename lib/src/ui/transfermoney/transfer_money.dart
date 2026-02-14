import 'package:contacts_service/contacts_service.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../apis/apimanager/user_api_manager.dart';
import '../../apis/base_model.dart';
import '../../apis/dic_params.dart';
import '../../main.dart';
import '../../utils/color_utils.dart';
import '../../utils/common_methods.dart';
import '../../utils/constants.dart';
import '../../utils/database_helper.dart';
import '../../utils/db_constant.dart';
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
import '../requestmoney/model/req_contact.dart';
import '../requestmoney/model/res_contact.dart';
import 'model/res_transfer_money_list.dart';

class TransferMoneyScreen extends StatefulWidget {
  final bool showBackButton;

  const TransferMoneyScreen({Key? key, this.showBackButton = false})
      : super(key: key);

  @override
  _TransferMoneyScreenState createState() => _TransferMoneyScreenState();

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(DiagnosticsProperty<bool>('showBackButton', showBackButton));
  }
}

class _TransferMoneyScreenState extends State<TransferMoneyScreen>
    with
// ignore: prefer_mixin
        RouteAware {
  final _isUpdate = ValueNotifier<bool>(false);
  final _isLoading = ValueNotifier<bool>(false);
  final ScrollController _controller = ScrollController();

  final DatabaseHelper _dbHelper = DatabaseHelper.instance;
  final List<AllContacts> _allContacts = [];
  List<ContactResponseModel> _fetchedContacts = [];

  final List<TransferMoneyListData> _list = <TransferMoneyListData>[];
  final List<TransferMoneyListData> _contactList = <TransferMoneyListData>[];
  int _pageCount = 0;
  bool _isDataAvailable = true;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final route = ModalRoute.of(context);
    if (route is PageRoute) {
      routeObserver.subscribe(this, route);
    }
  }

  @override
  void initState() {
    _pageCount = 0;
    _list.clear();
    _isDataAvailable = true;
    super.initState();
    _getTransferMoneyData();
    _fetchLocalContact();
  }

  Future _fetchLocalContact() async {
    _fetchedContacts = await _dbHelper.fetchAllContact();
    setState(() {});
    await _getContacts(isBackGround: false);
  }

  void _onEndScroll(ScrollMetrics metrics) {
    if (_controller.offset >= _controller.position.maxScrollExtent &&
        !_controller.position.outOfRange) {
      _getTransferMoneyData(isLoading: false);
    }
  }

  @override
  void dispose() {
    routeObserver.unsubscribe(this);
    super.dispose();
  }

  // Called when the top route has been popped off,
  // and the current route shows up.
  @override
  void didPopNext() {
    _pageCount = 0;
    _list.clear();
    _isDataAvailable = true;
    _getTransferMoneyData(isLoading: false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            widget.showBackButton
                ? Container(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        FloatingActionButton(
                          tooltip: Localization.of(context).labelBack,
                          elevation: 0,
                          heroTag: "",
                          hoverElevation: 0,
                          focusElevation: 0,
                          disabledElevation: 0,
                          highlightElevation: 0,
                          backgroundColor: Colors.transparent,
                          onPressed: () {
                            NavigationUtils.pop(context);
                          },
                          child: Container(
                            padding: const EdgeInsets.all(spacingMedium),
                            child: Image.asset(
                              ImageConstants.icBackArrow,
                              fit: BoxFit.contain,
                              scale: 1.6,
                              color: ColorUtils.primaryColor,
                            ),
                          ),
                        ),
                        _getTopHeader()
                      ],
                    ),
                  )
                : Container(
                    margin: const EdgeInsets.all(spacingMedium),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        GestureDetector(
                          onTap: () async {
                            final data = await NavigationUtils.push(
                                context,
                                isUserApp()
                                    ? routeMyProfile
                                    : routeMerchantProfile);
                            if (data == null) {
                              _isUpdate.value = true;
                            }
                          },
                          child: Hero(
                            tag: routeMyProfile,
                            transitionOnUserGestures: true,
                            child: ValueListenableBuilder(
                              valueListenable: _isUpdate,
                              builder: (context, isUpdate, _) => Container(
                                height: spacingXXXLarge,
                                width: spacingXXXLarge,
                                decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    image: DecorationImage(
                                        image: getString(PreferenceKey
                                                        .profilePicture) !=
                                                    ""
                                            ? NetworkImage(
                                                getString(PreferenceKey
                                                    .profilePicture),
                                              )
                                            : const AssetImage(ImageConstants
                                                .icDefaultProfileImage),
                                        fit: BoxFit.cover),
                                    color: Colors.white),
                              ),
                            ),
                          ),
                        ),
                        FloatingActionButton(
                          tooltip: Localization.of(context).scanAndPayHeader,
                          elevation: 0,
                          heroTag: "",
                          hoverElevation: 0,
                          focusElevation: 0,
                          disabledElevation: 0,
                          highlightElevation: 0,
                          backgroundColor: Colors.transparent,
                          onPressed: () {
                            NavigationUtils.push(context, routeScanAndPay);
                          },
                          child: Container(
                            padding: const EdgeInsets.all(10.0),
                            child: Image.asset(
                              ImageConstants.icQrCode,
                              scale: 3.0,
                              color: ColorUtils.primaryColor,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
            widget.showBackButton ? const SizedBox() : _getTopHeader(),
            Padding(
              padding: const EdgeInsets.all(spacingMedium),
              child: _getSearchTextField(),
            ),
            Expanded(
              child: ValueListenableBuilder(
                valueListenable: _isLoading,
                builder: (context, isLoading, _) {
                  return isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : _list.length + _contactList.length == 0
                          ? Center(
                              child: Text(Localization.of(context)
                                  .labelNoTransferRequestFound))
                          : NotificationListener(
                              onNotification: (scrollNotification) {
                                if (scrollNotification
                                    is ScrollEndNotification) {
                                  _onEndScroll(scrollNotification.metrics);
                                }
                                return false;
                              },
                              child: ListView.builder(
                                controller: _controller,
                                itemCount: _list.length + _contactList.length,
                                itemBuilder: (context, index) {
                                  final finalList = _list + _contactList;
                                  final profilePicture =
                                      finalList[index].profilePicture;
                                  final ImageProvider profileImage =
                                      (profilePicture?.isNotEmpty ?? false)
                                          ? NetworkImage(profilePicture!)
                                          : const AssetImage(
                                              ImageConstants.icDefaultProfileImage);
                                  return InkWell(
                                    onTap: () {
                                      final senderId = finalList[index].requestBy ?? finalList[index].id;
                                      if (senderId == null || senderId == 0) {
                                        DialogUtils.showAlertDialog(
                                            context,
                                            Localization.of(context)
                                                .errorSomethingWentWrong);
                                        return;
                                      }
                                      NavigationUtils.push(
                                          context, routeChatScreen,
                                          arguments: {
                                            NavigationParams.senderUserId:
                                                senderId,
                                            NavigationParams.senderProfileImage:
                                                finalList[index].profilePicture,
                                            NavigationParams.senderName:
                                                """${finalList[index].firstName ?? ''} ${finalList[index].lastName ?? ''}""".trim(),
                                          });
                                    },
                                    child: Container(
                                      decoration: BoxDecoration(
                                        border: Border.all(
                                            color: ColorUtils.borderColor),
                                        borderRadius:
                                            BorderRadius.circular(4.0),
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.black.withAlpha(20),
                                            blurRadius: 5.0,
                                          )
                                        ],
                                        color: Colors.white,
                                      ),
                                      margin: const EdgeInsets.fromLTRB(
                                          spacingLarge,
                                          spacingSmall,
                                          spacingLarge,
                                          spacingTiny),
                                      child: ListTile(
                                        leading:
                                            Container(
                                                    width: spacingXXXLarge,
                                                    height: spacingXXXLarge,
                                                    decoration: BoxDecoration(
                                                      shape: BoxShape.circle,
                                                      image: DecorationImage(
                                                        image: profileImage,
                                                        fit: BoxFit.cover,
                                                      ),
                                                    ),
                                                  ),
                                        title: Text(
                                          "${finalList[index].firstName} "
                                          "${finalList[index].lastName}",
                                          style: const TextStyle(
                                              fontFamily:
                                                  fontFamilyPoppinsMedium,
                                              fontSize: fontSmall,
                                              color: ColorUtils.secondaryColor),
                                        ),
                                        subtitle: Text(
                                          countryCodeAddToString +
                                              (finalList[index].mobile ?? ''),
                                          style: const TextStyle(
                                              fontFamily:
                                                  fontFamilyPoppinsRegular,
                                              fontSize: fontXMSmall,
                                              color:
                                                  ColorUtils.merchantHomeRow),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        trailing: ActionChip(
                                                shape: StadiumBorder(
                                                    side: BorderSide(
                                                        color: finalList[index]
                                                                    .status ==
                                                                DicParams
                                                                    .pending
                                                            ? ColorUtils
                                                                .primaryColor
                                                            : Colors.white)),
                                                label: getTextstatus(
                                                    finalList, index, context),
                                                backgroundColor: Colors.white,
                                                labelStyle: buildTextStyle(
                                                    finalList, index),
                                                onPressed: () {
                                                  final senderId =
                                                      finalList[index].requestBy ??
                                                          finalList[index].id;
                                                  if (senderId == null ||
                                                      senderId == 0) {
                                                    DialogUtils.showAlertDialog(
                                                        context,
                                                        Localization.of(context)
                                                            .errorSomethingWentWrong);
                                                    return;
                                                  }
                                                  NavigationUtils.push(
                                                      context, routeChatScreen,
                                                      arguments: {
                                                        NavigationParams
                                                                .senderUserId:
                                                            senderId,
                                                        NavigationParams
                                                                .senderProfileImage:
                                                            finalList[index]
                                                                .profilePicture,
                                                        NavigationParams
                                                                .senderName:
                                                            """${finalList[index].firstName ?? ''} ${finalList[index].lastName ?? ''}"""
                                                                .trim(),
                                                      });
                                                },
                                              ),
                                      ),
                                    ),
                                  );
                                },
                              ),
                            );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  TextStyle buildTextStyle(List<TransferMoneyListData> finalList, int index) {
    return TextStyle(
        fontFamily: fontFamilyPoppinsMedium,
        fontSize: fontXMSmall,
        color: finalList[index].status == DicParams.pending
            ? ColorUtils.primaryColor
            : finalList[index].status == DicParams.failed
                ? Colors.red
                : finalList[index].status == DicParams.declined
                    ? Colors.red
                    : ColorUtils.transferAcceptColor);
  }

  Text getTextstatus(
      List<TransferMoneyListData> finalList, int index, BuildContext context) {
    return Text(finalList[index].status == DicParams.pending
        ? Localization.of(context).labelAcceptRequest
        : finalList[index].status == DicParams.failed
            ? Localization.of(context).labelFailed
            : finalList[index].status == DicParams.declined
                ? Localization.of(context).labelDeclined
                : Localization.of(context).labelSuccess);
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
            arguments: {NavigationParams.isPayScreen: true});
      },
    );
  }

  Widget _getTopHeader() {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(circleRadius14),
          bottomRight: Radius.circular(circleRadius14),
        ),
      ),
      child: Container(
        width: double.infinity,
        padding:
            const EdgeInsets.fromLTRB(spacingMedium, 0.0, 55.0, spacingSmall),
        child: Text(
          Localization.of(context).labelTransferMoney,
          style: const TextStyle(
            fontFamily: fontFamilyPoppinsMedium,
            fontSize: 24.0,
            color: ColorUtils.primaryColor,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  List<TransferMoneyListData> _getTransferMoneyData({bool isLoading = true}) {
    _isLoading.value = isLoading;
    UserApiManager().getTransferMoneyList(page: _pageCount).then((value) {
      _isLoading.value = false;
      if (value.data?.result?.isEmpty ?? true) {
        _isDataAvailable = false;
      } else {
        setState(() {
          _list.addAll(value.data?.result ?? <TransferMoneyListData>[]);
        });
      }
    }).catchError((dynamic e) {
      _isLoading.value = false;
      if (e is ResBaseModel) {
        if (!checkSessionExpire(e, context)) {
          DialogUtils.showAlertDialog(context, e.error ?? '');
        }
      }
    });
    if (_isDataAvailable) {
      _pageCount++;
      return _list;
    } else {
      _isDataAvailable = false;
      return <TransferMoneyListData>[];
    }
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
          for (final phone in contacts.phones ?? <Item>[]) {
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
        if (_fetchedContacts.isNotEmpty) {
          for (final element in _fetchedContacts) {
            final mobile = element.mobile ?? '';
            _contactList.add(TransferMoneyListData(
              id: element.id,
              requestBy: element.id,
              status: null,
              lastName: element.lastName,
              mobile: mobile.length > 4 ? mobile.substring(4) : mobile,
              profilePicture: element.profilePicture,
              requestedAt: null,
              paymentMethod: null,
              firstName: element.firstName,
            ));
          }
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
      {List<ContactResponseModel> contacts = const <ContactResponseModel>[]})
      async {
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
