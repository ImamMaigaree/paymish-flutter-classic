import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:provider/provider.dart';

import '../../../apis/apimanager/user_api_manager.dart';
import '../../../apis/base_model.dart';
import '../../../utils/color_utils.dart';
import '../../../utils/common_methods.dart';
import '../../../utils/constants.dart';
import '../../../utils/dialog_utils.dart';
import '../../../utils/dimens.dart';
import '../../../utils/image_constants.dart';
import '../../../utils/localization/localization.dart';
import '../../../utils/navigation.dart';
import '../../../utils/navigation_params.dart';
import '../../../utils/notification_constants.dart';
import '../../../utils/progress_dialog.dart';
import '../../../utils/utils.dart';
import '../../../widgets/paymish_appbar.dart';
import 'model/res_notification.dart';
import 'provider/home_screen_provider.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({Key? key}) : super(key: key);

  @override
  _NotificationScreenState createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  final List<NotificationListData> _list = <NotificationListData>[];
  final _isLoading = ValueNotifier<bool>(false);
  int _pageCount = 0;
  bool _isDataAvailable = true;
  int _unReadCount = 0;
  final ScrollController _controller = ScrollController();

  @override
  void initState() {
    _unReadCount = 0;
    _list.clear();
    _isDataAvailable = true;
    super.initState();
    _getNotificationListData();
  }

  void _onEndScroll(ScrollMetrics metrics) {
    if (_controller.offset >= _controller.position.maxScrollExtent &&
        !_controller.position.outOfRange) {
      _getNotificationListData(isLoading: false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PaymishAppBar(
        isBackGround: false,
        title: Localization.of(context).labelNotification,
      ),
      body: ValueListenableBuilder(
        valueListenable: _isLoading,
        builder: (context, isLoading, _) {
          return isLoading
              ? const Center(child: CircularProgressIndicator())
              : _list.isEmpty
              ? Center(
                  child: Text(
                    Localization.of(context).labelNoNotificationFound,
                  ),
                )
              : NotificationListener(
                  onNotification: (scrollNotification) {
                    if (scrollNotification is ScrollEndNotification) {
                      _onEndScroll(scrollNotification.metrics);
                    }
                    return false;
                  },
                  child: ListView.builder(
                    controller: _controller,
                    itemCount: _list.length,
                    itemBuilder: (context, index) {
                      return slideAbleNotificationCell(
                        data: _list[index],
                        index: index,
                      );
                    },
                  ),
                );
        },
      ),
    );
  }

  void _getNotificationListData({bool isLoading = true}) {
    _isLoading.value = isLoading;
    UserApiManager()
        .getNotificationList(page: _pageCount)
        .then((value) {
          _isLoading.value = false;
          final results = value.data?.result ?? <NotificationListData>[];
          if (results.isEmpty) {
            _isDataAvailable = false;
          } else {
            setState(() {
              _isDataAvailable = true;
              _list.addAll(results);
              _unReadCount = value.data?.unReadCount ?? _unReadCount;
            });
          }
        })
        .catchError((dynamic e) {
          _isLoading.value = false;
          if (e is ResBaseModel) {
            if (!checkSessionExpire(e, context)) {
              DialogUtils.showAlertDialog(context, e.error ?? '');
            } else {
              DialogUtils.showAlertDialog(context, e.error ?? '');
            }
          }
        });
    if (_isDataAvailable) {
      _pageCount++;
    } else {
      _isDataAvailable = false;
    }
  }

  Widget slideAbleNotificationCell({
    required int index,
    required NotificationListData data,
  }) => Padding(
    padding: const EdgeInsets.only(
      left: spacingLarge,
      right: spacingLarge,
      bottom: spacingMedium,
    ),
    child: Slidable(
      endActionPane: ActionPane(
        motion: const ScrollMotion(),
        children: <Widget>[
          CustomSlidableAction(
            backgroundColor: ColorUtils.deleteNotificationBGColor,
            onPressed: (context) {
              DialogUtils.showOkCancelAlertDialog(
                context: context,
                message: Localization.of(context).msgDeleteNotification,
                cancelButtonTitle: Localization.of(context).cancel,
                okButtonTitle: Localization.of(context).ok,
                cancelButtonAction: () {},
                okButtonAction: () {
                  final notificationId = data.id;
                  if (notificationId == null) {
                    DialogUtils.displayToast(
                      Localization.of(context).errorSomethingWentWrong,
                    );
                    return;
                  }
                  ProgressDialogUtils.showProgressDialog(context);
                  UserApiManager()
                      .deleteNotification(id: notificationId)
                      .then((value) {
                        ProgressDialogUtils.dismissProgressDialog();
                        DialogUtils.displayToast(value.message ?? '');
                        if ((data.isRead ?? 0) == 0) {
                          Provider.of<HomeScreenProvider>(
                            context,
                            listen: false,
                          ).setNotificationCount(_unReadCount - 1);
                        }
                        setState(() {
                          _list.removeAt(index);
                        });
                      })
                      .catchError((dynamic e) {
                        ProgressDialogUtils.dismissProgressDialog();
                        if (e is ResBaseModel) {
                          if (!checkSessionExpire(e, context)) {
                            DialogUtils.showAlertDialog(context, e.error ?? '');
                          }
                        }
                      });
                },
              );
            },
            child: Image.asset(
              ImageConstants.icDelete,
              height: 20,
              width: 20,
              color: Colors.white,
            ),
          ),
        ],
      ),
      child: _getNotificationCell(data: data, index: index),
    ),
  );

  InkWell _getNotificationCell({
    required int index,
    required NotificationListData data,
  }) => InkWell(
    onTap: () {
      if ((data.isRead ?? 0) == 0) {
        final notificationId = data.id;
        if (notificationId == null) {
          DialogUtils.displayToast(
            Localization.of(context).errorSomethingWentWrong,
          );
          return;
        }
        ProgressDialogUtils.showProgressDialog(context);
        UserApiManager()
            .readNotification(id: notificationId)
            .then((value) {
              ProgressDialogUtils.dismissProgressDialog();
              setState(() {
                data.isRead = 1;
              });
              if (_unReadCount > 0) {
                Provider.of<HomeScreenProvider>(
                  context,
                  listen: false,
                ).setNotificationCount(_unReadCount - 1);
                _unReadCount = _unReadCount - 1;
              }
              _goToNextScreen(data);
            })
            .catchError((dynamic e) {
              ProgressDialogUtils.dismissProgressDialog();
              if (e is ResBaseModel) {
                if (!checkSessionExpire(e, context)) {
                  DialogUtils.showAlertDialog(context, e.error ?? '');
                }
              }
            });
      } else {
        _goToNextScreen(data);
      }
    },
    child: Container(
      decoration: BoxDecoration(
        border: Border.all(color: ColorUtils.cardBorderNotification),
        borderRadius: BorderRadius.circular(4.0),
        color: (data.isRead ?? 0) == 0
            ? ColorUtils.cardBgNotificationUnRead
            : Colors.white,
      ),
      child: Padding(
        padding: const EdgeInsets.all(spacingMedium),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Expanded(
                  child: Text(
                    data.title ?? '',
                    style: const TextStyle(
                      fontFamily: fontFamilyRobotoLight,
                      fontSize: fontXXLarge / 2,
                      letterSpacing: 1,
                      fontWeight: FontWeight.w700,
                      color: ColorUtils.notificationTextColor,
                    ),
                  ),
                ),
                Text(
                  Utils.convertDateFromString(data.createdAt ?? '', context),
                  style: const TextStyle(
                    fontFamily: fontFamilyPoppinsLight,
                    fontSize: fontXSmall,
                    color: ColorUtils.notificationDescriptionColor,
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.only(top: spacingMedium),
              child: Text(
                data.body ?? '',
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontFamily: fontFamilyPoppinsLight,
                  fontSize: fontSmall,
                  color: ColorUtils.notificationDescriptionColor,
                ),
              ),
            ),
          ],
        ),
      ),
    ),
  );

  void _goToNextScreen(NotificationListData data) {
    final category = data.category ?? '';
    if (_isTransferCategory(category)) {
      final senderId = data.senderId ?? 0;
      if (senderId > 0) {
        NavigationUtils.push(
          context,
          routeChatScreen,
          arguments: {NavigationParams.senderUserId: senderId},
        );
      } else {
        NavigationUtils.push(
          context,
          routeTransferMoneyScreen,
          arguments: {NavigationParams.showBackButton: true},
        );
      }
      return;
    }

    if (_isSupportCategory(category)) {
      final ticketId = data.ticketId ?? 0;
      if (ticketId > 0) {
        NavigationUtils.push(
          context,
          routeSupportTicketsChat,
          arguments: {NavigationParams.senderUserId: ticketId},
        );
      } else {
        NavigationUtils.push(
          context,
          routeSupportTickets,
          arguments: {NavigationParams.showBackButton: true},
        );
      }
      return;
    }

    if (_isUtilityCategory(category)) {
      NavigationUtils.push(context, routeMyWallet);
      return;
    }

    NavigationUtils.push(context, routeMyWallet);
  }

  bool _isTransferCategory(String category) {
    return category == NotificationConstants.requested ||
        category == NotificationConstants.approved ||
        category == NotificationConstants.declined ||
        category == NotificationConstants.paid ||
        category == NotificationConstants.chat ||
        category == NotificationConstants.userChat;
  }

  bool _isSupportCategory(String category) {
    return category == NotificationConstants.support ||
        category == NotificationConstants.supportTicket ||
        category == NotificationConstants.supportChat ||
        category == NotificationConstants.newMessage ||
        category == NotificationConstants.ticketClosed;
  }

  bool _isUtilityCategory(String category) {
    return category == NotificationConstants.utilityBillPayment;
  }
}
