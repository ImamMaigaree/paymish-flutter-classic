import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_paystack/flutter_paystack.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../apis/apimanager/user_api_manager.dart';
import '../../apis/base_model.dart';
import '../../apis/dic_params.dart';
import '../../main.dart';
import '../../socket/socket_constants.dart';
import '../../socket/socket_mangaer.dart';
import '../../utils/app_config.dart';
import '../../utils/color_utils.dart';
import '../../utils/common_methods.dart';
import '../../utils/constants.dart';
import '../../utils/dialog_utils.dart';
import '../../utils/dimens.dart';
import '../../utils/image_constants.dart';
import '../../utils/localization/localization.dart';
import '../../utils/navigation.dart';
import '../../utils/navigation_params.dart';
import '../../utils/preference_key.dart';
import '../../utils/preference_utils.dart';
import '../../utils/progress_dialog.dart';
import '../../utils/utils.dart';
import '../../widgets/paymish_primary_button.dart';
import '../../widgets/profile_image_view.dart';
import '../transfermoney/model/res_transfer_money_list.dart';
import 'model/res_transaction_details_with_user.dart';
import 'provider/chat_payment_selection_provider.dart';
import 'provider/chat_provider.dart';

class ChatScreen extends StatefulWidget {
  final int senderUserId;
  final String senderProfileImage;
  final String senderName;

  const ChatScreen(
      {Key? key,
      required this.senderUserId,
      required this.senderProfileImage,
      required this.senderName})
      : super(key: key);

  @override
  _ChatScreenState createState() => _ChatScreenState();

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(IntProperty('senderUserId', senderUserId));
    properties.add(StringProperty('senderProfileImage', senderProfileImage));
    properties.add(StringProperty('senderName', senderName));
  }
}

class _ChatScreenState extends State<ChatScreen>
    with
// ignore: prefer_mixin
        RouteAware {
  final List<ResTransactionDetailsItem> _list = <ResTransactionDetailsItem>[];
  final _isLoading = ValueNotifier<bool>(false);
  int _pageCount = 0;
  ResTransactionDetailsItem? itemDetails;

  bool _isDataAvailable = true;
  final ScrollController _controller = ScrollController();
  int _userId = 0;
  String _headerName = "";
  String _profileImage = "";
  final TextEditingController _messageTextController = TextEditingController();

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final route = ModalRoute.of(context);
    if (route is PageRoute) {
      routeObserver.subscribe(this, route);
    }
  }

  // Called when the top route has been popped off,
  // and the current route shows up.
  @override
  void didPopNext() {
    setState(() {});
    _pageCount = 0;
    _list.clear();
    _isDataAvailable = true;
    Provider.of<ChatProvider>(context, listen: false).clearAllMessages();

    _getTransactionListWithUser();
  }

  @override
  void initState() {
    super.initState();
    SchedulerBinding.instance.addPostFrameCallback((_) {
      Provider.of<ChatProvider>(context, listen: false).clearAllMessages();
      _pageCount = 0;
      initSocketManager(context);
      _list.clear();
      _isDataAvailable = true;

      _getTransactionListWithUser();
      setState(() {
        _userId = getInt(PreferenceKey.id);
        Provider.of<ChatProvider>(context, listen: false).userId =
            widget.senderUserId;
        Provider.of<ChatProvider>(context, listen: false).isScreenOpen = true;
      });
      _getBankDetails();
      paystackPlugin.initialize(publicKey: payStackKey ?? '');
    });
  }

  void _onEndScroll(ScrollMetrics metrics) {
    if (_controller.offset >= _controller.position.maxScrollExtent &&
        !_controller.position.outOfRange) {
      _getTransactionListWithUser(isLoading: false);
    }
  }

  @override
  void deactivate() {
    routeObserver.unsubscribe(this);
    super.deactivate();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) {
        if (didPop) {
          return;
        }
        Provider.of<ChatProvider>(context, listen: false).userId = 0;
        Provider.of<ChatProvider>(context, listen: false).isScreenOpen = false;
        NavigationUtils.pop(context);
      },
      child: Scaffold(
          backgroundColor: Colors.white,
          body: SafeArea(
            child: Consumer<ChatProvider>(
              builder: (context, myModel, child) => Column(
                children: [
                  Container(
                    margin: const EdgeInsets.only(
                        right: spacingMedium,
                        top: spacingMedium,
                        bottom: spacingMedium),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        FloatingActionButton(
                          backgroundColor: Colors.transparent,
                          elevation: 0,
                          highlightElevation: 0,
                          hoverElevation: 0,
                          focusElevation: 0,
                          disabledElevation: 0,
                          child: Image.asset(
                            ImageConstants.icBackArrow,
                            fit: BoxFit.contain,
                            height: spacingMedium,
                            color: ColorUtils.primaryColor,
                          ),
                          onPressed: () {
                            Provider.of<ChatProvider>(context, listen: false)
                                .userId = 0;
                            Provider.of<ChatProvider>(context, listen: false)
                                .isScreenOpen = false;
                            NavigationUtils.pop(context);
                          },
                        ),
                      ],
                    ),
                  ),
                  _getTopHeader(),
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.only(bottom: spacingLarge),
                      height: MediaQuery.of(context).size.height * 0.72,
                      child: ValueListenableBuilder(
                        valueListenable: _isLoading,
                        builder: (context, isLoading, _) {
                          return isLoading
                              ? const Center(child: CircularProgressIndicator())
                              : myModel.list.isEmpty
                                  ? Center(
                                      child: Text(Localization.of(context)
                                          .labelNoMessageFound))
                                  : NotificationListener(
                                      onNotification: (scrollNotification) {
                                        if (scrollNotification
                                            is ScrollEndNotification) {
                                          _onEndScroll(
                                              scrollNotification.metrics);
                                        }
                                        return false;
                                      },
                                      child: Align(
                                        alignment: Alignment.topCenter,
                                        child: ListView.builder(
                                          controller: _controller,
                                          shrinkWrap: true,
                                          itemCount: myModel.list.keys.length,
                                          reverse: true,
                                          itemBuilder: (context, index) {
                                            final date = myModel.list.keys
                                                .toList()[index];
                                            final messages =
                                                myModel.list[date] ??
                                                    <ResTransactionDetailsItem>[];
                                            return Column(
                                              children: [
                                                _buildDateField(date, context),
                                                _getListViewFromMessage(
                                                    messages),
                                              ],
                                            );
                                          },
                                        ),
                                      ),
                                    );
                        },
                      ),
                    ),
                  ),
                  getChatTextFieldUI(context, myModel),
                ],
              ),
            ),
          )),
    );
  }

  void _getBankDetails() async {
    await UserApiManager().getCardDetails().then((value) {
      Provider.of<ChatPaymentSelectionProvider>(context, listen: false)
          .setCardList(value.data ?? []);
    }).catchError((dynamic e) {
      if (e is ResBaseModel) {
        if (!checkSessionExpire(e, context)) {
          DialogUtils.showAlertDialog(context, e.error ?? '');
        }
      }
    });
  }

  Widget _buildDateField(String date, BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: spacingSmall),
      child: Container(
        padding: const EdgeInsets.fromLTRB(
            spacingSmall, spacingTiny, spacingSmall, spacingTiny),
        decoration: BoxDecoration(
          border:
              Border.all(
                  color: ColorUtils.secondaryTextColor
                      .withValues(alpha: 0.5)),
          borderRadius: BorderRadius.circular(spacingXXLarge),
          color: ColorUtils.unCheckedSwitchColor.withValues(alpha: 0.5),
        ),
        child: Text(
          Utils.convertStringWithTimeDifference(date.toString(), context),
          style: const TextStyle(
              color: Colors.black, fontFamily: fontFamilyCovesBold),
        ),
      ),
    );
  }

  Widget _getListViewFromMessage(List<ResTransactionDetailsItem> messages) {
    return ListView.builder(
      primary: false,
      shrinkWrap: true,
      itemCount: messages.length,
      itemBuilder: (context, index) => messages.elementAt(index).type !=
              DicParams.text
          ? getCardViewForRequestedPayment(context, messages.elementAt(index))
          : getViewForTextMessage(context, messages.elementAt(index)),
    );
  }

  Widget getChatTextFieldUI(BuildContext context, ChatProvider provider) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: ColorUtils.borderColor),
        borderRadius: BorderRadius.circular(4.0),
        color: Colors.white,
      ),
      child: Padding(
        padding: const EdgeInsets.only(right: spacingLarge, left: spacingLarge),
        child: TextFormField(
          controller: _messageTextController,
          style: const TextStyle(
              fontFamily: fontFamilyPoppinsRegular,
              color: ColorUtils.primaryTextColor,
              fontSize: fontMedium),
          cursorColor: ColorUtils.primaryTextColor,
          textInputAction: TextInputAction.done,
          decoration: InputDecoration(
              counterText: "",
              suffixIcon: InkWell(
                onTap: () {
                  if (_messageTextController.text.trim().isNotEmpty) {
                    onSendMessage(_messageTextController.text, provider);
                  }
                },
                child: Image.asset(
                  ImageConstants.icSendMessage,
                  scale: 3.5,
                ),
              ),
              border: InputBorder.none,
              hintStyle: const TextStyle(
                  fontFamily: fontFamilyPoppinsRegular,
                  color: ColorUtils.primaryTextColor,
                  fontSize: fontMedium),
              hintText: Localization.of(context).hintWriteMessage),
        ),
      ),
    );
  }

  Widget getViewForTextMessage(
      BuildContext context, ResTransactionDetailsItem transactionDetailsItem) {
    final senderId = transactionDetailsItem.senderId ?? 0;
    return Row(
        mainAxisAlignment: _userId != senderId
            ? MainAxisAlignment.start
            : MainAxisAlignment.end,
        children: [
          Column(
            crossAxisAlignment: _userId != senderId
                ? CrossAxisAlignment.start
                : CrossAxisAlignment.end,
            children: [
              _userId != senderId
                  ? _buildReceiverMessageView(transactionDetailsItem)
                  : _buildSenderMessageView(transactionDetailsItem),
            ],
          )
        ]);
  }

  Widget _buildSenderMessageView(ResTransactionDetailsItem item) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Container(
                constraints: BoxConstraints(
                    maxWidth: MediaQuery.of(context).size.width * 0.7),
                padding: const EdgeInsets.fromLTRB(16.0, 12.0, 16.0, 12.0),
                decoration: const BoxDecoration(
                  color: ColorUtils.recentTextColor,
                  borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(spacing17),
                      topRight: Radius.circular(spacing17),
                      bottomRight: Radius.circular(spacing4),
                      bottomLeft: Radius.circular(spacing17)),
                ),
                margin: const EdgeInsets.only(right: 10.0),
                child: Text(
                  item.message ?? '',
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: fontMedium,
                      fontWeight: FontWeight.w400),
                ),
              ),
              _buildTimeView(item.createdAt, true)
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildReceiverMessageView(ResTransactionDetailsItem item) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                constraints: BoxConstraints(
                    maxWidth: MediaQuery.of(context).size.width * 0.7),
                padding: const EdgeInsets.fromLTRB(16.0, 12.0, 16.0, 12.0),
                decoration: const BoxDecoration(
                  color: ColorUtils.chatPaymentCardColour,
                  borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(spacing17),
                      topRight: Radius.circular(spacing17),
                      bottomRight: Radius.circular(spacing17),
                      bottomLeft: Radius.circular(spacing4)),
                ),
                margin: const EdgeInsets.only(left: 10.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Text(
                      item.message ?? '',
                      style: const TextStyle(
                          color: ColorUtils.chatMessageColor,
                          fontSize: fontMedium,
                          fontWeight: FontWeight.w400),
                    ),
                  ],
                ),
              ),
              _buildTimeView(item.createdAt, false)
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTimeView(String? timeStamp, bool isSender) {
    return Container(
      margin: const EdgeInsets.only(top: 6.0, bottom: 15.0),
      child: Text(
        Utils.convertChatTimeFromString(timeStamp ?? ''),
        style: const TextStyle(
          fontSize: 9,
          fontFamily: fontFamilyPoppinsLight,
          color: ColorUtils.chatTimeColor,
        ),
      ),
    );
  }

  Widget getCardViewForRequestedPayment(
      BuildContext context, ResTransactionDetailsItem transactionDetailsItem) {
    final senderId = transactionDetailsItem.senderId ?? 0;
    final requestStatus = transactionDetailsItem.requestStatus ?? '';
    final type = transactionDetailsItem.type ?? '';
    final createdAt = transactionDetailsItem.createdAt ?? '';
    return Row(
      mainAxisAlignment: _userId != senderId
          ? MainAxisAlignment.start
          : MainAxisAlignment.end,
      children: [
        Padding(
          padding: const EdgeInsets.all(spacingMedium),
          child: Row(
            // mainAxisSize: MainAxisSize.min,
            children: [
              Column(
                crossAxisAlignment: _userId != senderId
                    ? CrossAxisAlignment.end
                    : CrossAxisAlignment.start,
                children: [
                  Container(
                    decoration: BoxDecoration(
                      border:
                          Border.all(color: ColorUtils.chatPaymentCardColour),
                      borderRadius: BorderRadius.only(
                          topLeft: const Radius.circular(spacing17),
                          topRight: const Radius.circular(spacing17),
                          bottomRight:
                              _userId != transactionDetailsItem.senderId
                                  ? const Radius.circular(spacing17)
                                  : const Radius.circular(spacing4),
                          bottomLeft: _userId != transactionDetailsItem.senderId
                              ? const Radius.circular(spacing4)
                              : const Radius.circular(spacing17)),
                      color: ColorUtils.chatPaymentCardColour,
                    ),
                    child: Consumer<ChatPaymentSelectionProvider>(
                      builder: (context, providerModel, child) => Padding(
                        padding: const EdgeInsets.fromLTRB(spacingSmall,
                            spacingSmall, spacingXXLarge, spacingSmall),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            getAmount(transactionDetailsItem),
                            getRowDecAndTime(
                                context, providerModel, transactionDetailsItem),
                            _userId != senderId
                                ? requestStatus == DicParams.pending
                                    ? getRowPayDecline(context, providerModel,
                                        transactionDetailsItem)
                                    : const SizedBox()
                                : Padding(
                                    padding: const EdgeInsets.only(
                                        top: spacingMedium,
                                        left: spacingTiny,
                                        right: spacingXLarge),
                                    child: Text(
                                      type == DicParams.request
                                          ? requestStatus == DicParams.pending
                                              ? Localization.of(context)
                                                  .labelPending
                                              : toBeginningOfSentenceCase(
                                                      requestStatus) ??
                                                  ''
                                          : toBeginningOfSentenceCase(
                                                  transactionDetailsItem
                                                          .transactionStatus ??
                                                      '') ??
                                              '',
                                      style: TextStyle(
                                        color: type == DicParams.request
                                            ? requestStatus ==
                                                    DicParams.pending
                                                ? Colors.lime
                                                : requestStatus ==
                                                        DicParams.success
                                                    ? ColorUtils
                                                        .transferAcceptColor
                                                    : requestStatus ==
                                                            DicParams.failed
                                                        ? Colors.red
                                                        : requestStatus ==
                                                                DicParams
                                                                    .declined
                                                            ? Colors.red
                                                            : ColorUtils
                                                                .transferAcceptColor
                                            : ColorUtils.transferAcceptColor,
                                        fontSize: fontSmall,
                                        fontFamily: fontFamilyPoppinsMedium,
                                      ),
                                    ),
                                  )
                          ],
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: spacingTiny),
                    child: Text(
                      Utils.convertChatTimeFromString(
                          createdAt),
                      style: const TextStyle(
                          fontSize: 9,
                          fontFamily: fontFamilyPoppinsLight,
                          color: ColorUtils.chatTimeColor),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Row getAmount(ResTransactionDetailsItem transactionDetailsItem) {
    final type = transactionDetailsItem.type ?? '';
    return Row(
      children: [
        Image.asset(
          ImageConstants.icNigeriaCurrencySymbol,
          color: ColorUtils.primaryColor,
          scale: 4.0,
        ),
        Padding(
          padding: const EdgeInsets.only(left: spacingTiny, top: spacingTiny),
          child: Text(
            type == DicParams.request
                ? Utils.currencyFormat
                    .format(transactionDetailsItem.requestedAmount ?? 0)
                : Utils.currencyFormat
                    .format(transactionDetailsItem.transactionAmount ?? 0),
            style: const TextStyle(
                fontFamily: fontFamilyPoppinsMedium,
                fontSize: fontXMLarge,
                color: ColorUtils.primaryColor),
          ),
        ),
      ],
    );
  }

  Row getRowDecAndTime(
      BuildContext context,
      ChatPaymentSelectionProvider providerModel,
      ResTransactionDetailsItem transactionDetailsItem) {
    final receiverId = transactionDetailsItem.receiverId ?? 0;
    final requestStatus = transactionDetailsItem.requestStatus ?? '';
    return Row(
      children: [
        _userId == receiverId &&
                requestStatus == DicParams.pending
            ? Text(
                Localization.of(context).labelRequested,
                style: const TextStyle(
                    fontSize: fontSmall,
                    fontFamily: fontFamilyPoppinsMedium,
                    color: ColorUtils.primaryTextColor),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              )
            : const SizedBox(),
        requestStatus == DicParams.pending
            ? const SizedBox()
            : _userId == receiverId
                ? Padding(
                    padding: const EdgeInsets.only(top: spacingMedium),
                    child: Text(
                      requestStatus == DicParams.declined
                          ? Localization.of(context).labelDeclined
                          : requestStatus == DicParams.failed
                              ? Localization.of(context).labelFailed
                              : Localization.of(context).labelPaid,
                      style: TextStyle(
                          fontSize: fontSmall,
                          fontFamily: fontFamilyPoppinsMedium,
                          color: requestStatus == DicParams.declined
                              ? Colors.red
                              : requestStatus == DicParams.failed
                                  ? Colors.red
                                  : ColorUtils.transferAcceptColor),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  )
                : const SizedBox(),
      ],
    );
  }

  Row getRowPayDecline(
      BuildContext context,
      ChatPaymentSelectionProvider providerModel,
      ResTransactionDetailsItem transactionDetailsItem) {
    return Row(
      children: [
        ActionChip(
          shape: const StadiumBorder(
            side: BorderSide(color: ColorUtils.transferAcceptColor),
          ),
          label: Padding(
            padding:
                const EdgeInsets.only(left: spacingTiny, right: spacingTiny),
            child: Text(
              Localization.of(context).labelPay,
            ),
          ),
          backgroundColor: ColorUtils.transferAcceptColor,
          labelStyle: const TextStyle(
              fontFamily: fontFamilyPoppinsMedium,
              fontSize: fontXMSmall,
              color: Colors.white),
          onPressed: () {
            _gotoNextScreen(context, transactionDetailsItem);
          },
        ),
        Padding(
          padding: const EdgeInsets.only(left: spacingSmall),
          child: ActionChip(
            shape: const StadiumBorder(
              side: BorderSide(color: ColorUtils.primaryTextColor),
            ),
            label: Padding(
              padding:
                  const EdgeInsets.only(left: spacingTiny, right: spacingTiny),
              child: Text(
                Localization.of(context).labelDecline,
              ),
            ),
            backgroundColor: Colors.white,
            labelStyle: const TextStyle(
                fontFamily: fontFamilyPoppinsMedium,
                fontSize: fontXMSmall,
                color: ColorUtils.primaryTextColor),
          onPressed: () {
            DialogUtils.showOkCancelAlertDialog(
                context: context,
                message: Localization.of(context).msgDeclineRequest,
                okButtonTitle: Localization.of(context).ok,
                okButtonAction: () {
                  _declinePressed(
                        transactionDetailsItem.requestId ?? 0, providerModel);
                },
                cancelButtonTitle: Localization.of(context).cancel,
                cancelButtonAction: () {},
                isCancelEnable: true);
          },
          ),
        )
      ],
    );
  }

  void _gotoNextScreen(
      BuildContext context, ResTransactionDetailsItem transactionDetailsItem) {
    if (getString(PreferenceKey.kycStatus) == DicParams.notVerified) {
      DialogUtils.showOkCancelAlertDialog(
          context: context,
          message: Localization.of(context).errorSetUpTransactionDetails,
          okButtonTitle: Localization.of(context).ok,
          okButtonAction: () => {
                NavigationUtils.push(context, routeCompleteKYC, arguments: {
                  NavigationParams.showBackButton: true,
                  NavigationParams.completeTransactionDetails: true
                })
              },
          cancelButtonTitle: Localization.of(context).cancel,
          cancelButtonAction: () {},
          isCancelEnable: true);
    } else if (getInt(PreferenceKey.isBankAccount) == 0) {
      openTransactionDetailsDialog(context, routeWalletSetup);
    } else if (getInt(PreferenceKey.isTransactionPin) == 0) {
      openTransactionDetailsDialog(context, routeTransactionPinSetup);
    } else {
      payMoneyClicked(context, transactionDetailsItem);
    }
  }

  // Decline Payment Money Request
  Future<void> _declinePressed(
      int id, ChatPaymentSelectionProvider providerModel) async {
    ProgressDialogUtils.showProgressDialog(context);
    await UserApiManager().declineRequest(id).then((value) {
      // If API response is SUCCESS
      // Update Provider to show the status in request widget
      _pageCount = 0;
      _list.clear();
      _isDataAvailable = true;
      Provider.of<ChatProvider>(context, listen: false).clearAllMessages();
      _getTransactionListWithUser();
      ProgressDialogUtils.dismissProgressDialog();
      DialogUtils.displayToast(value.message ?? '');
    }).catchError((dynamic e) {
      // If API response is FAILURE or ANY EXCEPTION
      ProgressDialogUtils.dismissProgressDialog();
      if (e is ResBaseModel) {
        DialogUtils.showAlertDialog(context, e.error ?? '');
      }
    });
  }

  void payMoneyClicked(
      BuildContext context, ResTransactionDetailsItem transactionDetailsItem) {
    itemDetails = transactionDetailsItem;
    showModalBottomSheet(
      backgroundColor: Colors.transparent,
      context: context,
      // We had to define Consumer again for bottomSheet
      // reason: bottom sheet doesn't belong to scaffold,
      // bottom sheet is it's an individual component with scaffold
      builder: (ctx) => Consumer<ChatPaymentSelectionProvider>(
        builder: (context, providerModel, child) => Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(spacingLarge),
              topRight: Radius.circular(spacingLarge),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              moneyAmountWidget(transactionDetailsItem),
              sendMoneyDetails(transactionDetailsItem),
              labelSelectPaymentMethod(context, transactionDetailsItem),
              RadioGroup<String>(
                groupValue: providerModel.getSelectedRadioValue(),
                onChanged: (value) {
                  if (value != null) {
                    providerModel.setSelectedRadioValue(value);
                  }
                },
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    walletRadioSelection(
                        providerModel, context, transactionDetailsItem),
                    bankRadioSelection(
                        providerModel, context, transactionDetailsItem),
                    providerModel.getCardDetails().isNotEmpty
                        ? Column(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  GestureDetector(
                                    onTap: () {
                                      providerModel.setSelectedRadioValue(
                                          DicParams.card);
                                    },
                                    child: _getCardDetailsRow(providerModel),
                                  ),
                                  _getCardNumber(providerModel)
                                ],
                              ),
                              _changeCard(context, providerModel)
                            ],
                          )
                        : const SizedBox(),
                  ],
                ),
              ),
              proceedButton(providerModel, context, transactionDetailsItem)
            ],
          ),
        ),
      ),
    );
  }

  Padding _getCardNumber(ChatPaymentSelectionProvider providerModel) {
    return Padding(
      padding: const EdgeInsets.only(right: 10.0),
      child: Text(
        providerModel.getSelectedCard().maskedCardNo ?? '',
        style: TextStyle(color: ColorUtils.primaryColor, fontSize: fontSmall),
      ),
    );
  }

  Row _changeCard(
      BuildContext context, ChatPaymentSelectionProvider providerModel) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        InkWell(
          onTap: () {
            _openCardSelectionDialog(context, providerModel);
          },
          child: Padding(
            padding: const EdgeInsets.only(right: 10.0),
            child: Text(
              Localization.of(context).changeCard,
              style: TextStyle(
                  color: ColorUtils.primaryColor, fontSize: fontSmall),
            ),
          ),
        ),
      ],
    );
  }

  Row _getCardDetailsRow(ChatPaymentSelectionProvider providerModel) {
    return Row(
      children: [
        Radio(
          activeColor: ColorUtils.primaryColor,
          focusColor: ColorUtils.primaryColor,
          value: DicParams.card,
          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
        ),
        Text(
          """Card""",
          style: const TextStyle(
              fontFamily: fontFamilyPoppinsRegular,
              fontSize: fontMedium,
              color: ColorUtils.primaryTextColor),
        ),
      ],
    );
  }

  Widget cardRadioSelection(
      ChatPaymentSelectionProvider providerModel, BuildContext context) {
    return GestureDetector(
      onTap: () => {
        providerModel.setSelectedRadioValue(DicParams.card),
      },
      child: AbsorbPointer(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            Radio(
              activeColor: ColorUtils.primaryColor,
              focusColor: ColorUtils.primaryColor,
              value: DicParams.card,
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            Text(
              Localization.of(context).labelCreditDebitCard,
              style: const TextStyle(
                  fontFamily: fontFamilyPoppinsRegular,
                  fontSize: fontMedium,
                  color: ColorUtils.primaryTextColor),
            ),
          ],
        ),
      ),
    );
  }

  Widget moneyAmountWidget(ResTransactionDetailsItem transactionDetailsItem) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
          spacingMedium, spacingMedium, spacingMedium, spacingTiny),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Image.asset(
            ImageConstants.icNigeriaCurrencySymbol,
            color: ColorUtils.merchantHomeRow,
            scale: 4.0,
          ),
          Padding(
            padding: const EdgeInsets.only(left: spacingTiny),
            child: Text(
              Utils.currencyFormat
                  .format(transactionDetailsItem.requestedAmount ?? 0),
              style: const TextStyle(
                  color: ColorUtils.merchantHomeRow,
                  fontSize: fontXXXXXLarge,
                  fontFamily: fontFamilyPoppinsRegular),
            ),
          ),
        ],
      ),
    );
  }

  Widget sendMoneyDetails(ResTransactionDetailsItem transactionDetailsItem) {
    return Padding(
      padding: const EdgeInsets.only(
          left: spacingMedium, right: spacingMedium, bottom: spacingLarge),
      child: Text(
        """${Localization.of(context).lblYouAreSendingTo} ${transactionDetailsItem.senderFirstName ?? ''} ${transactionDetailsItem.senderLastName ?? ''}""",
        style: const TextStyle(
            fontFamily: fontFamilyPoppinsMedium,
            fontSize: fontSmall,
            color: ColorUtils.primaryTextColor),
      ),
    );
  }

  Widget labelSelectPaymentMethod(
      BuildContext context, ResTransactionDetailsItem transactionDetailsItem) {
    return Padding(
      padding: const EdgeInsets.all(spacingMedium),
      child: Text(
        Localization.of(context).labelSelectPaymentMethod,
        style: const TextStyle(
            color: ColorUtils.recentTextColor,
            fontSize: fontMedium,
            fontFamily: fontFamilyPoppinsMedium),
      ),
    );
  }

  Widget proceedButton(ChatPaymentSelectionProvider providerModel,
      BuildContext context, ResTransactionDetailsItem transactionDetailsItem) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
          spacingMedium, spacing45, spacingMedium, spacingLarge),
      child: PaymishPrimaryButton(
        buttonText: Localization.of(context).labelProceed,
        isBackground: true,
        onButtonClick: () {
          // To close the bottom sheet
          NavigationUtils.pop(context);
          // To navigate to transaction pin screen with data
          NavigationUtils.push(context, routeTransactionPin, arguments: {
            NavigationParams.paymentAmount:
                transactionDetailsItem.requestedAmount ?? 0,
            NavigationParams.paymentDetails: TransferMoneyListData(
                amount: transactionDetailsItem.requestedAmount ?? 0,
                firstName: transactionDetailsItem.senderFirstName ?? '',
                lastName: transactionDetailsItem.senderLastName ?? '',
                id: transactionDetailsItem.requestId ?? 0,
                cardId: providerModel.getSelectedCard().id ?? 0,
                status: transactionDetailsItem.requestStatus ?? '',
                remarks: transactionDetailsItem.message ?? ''),
            NavigationParams.isTransferMoney: true,
            NavigationParams.isRequestMoney: false,
            NavigationParams.isBankPayment: false,
            NavigationParams.isCardPayment: false,
            NavigationParams.isPayMoney: false,
            NavigationParams.isNetBankingPayment: false,
            NavigationParams.isDataRecharge: false,
            NavigationParams.isTvSubscription: false,
            NavigationParams.isElectricityBill: false,
          });
        },
      ),
    );
  }

  Widget bankRadioSelection(ChatPaymentSelectionProvider providerModel,
      BuildContext context, ResTransactionDetailsItem transactionDetailsItem) {
    return GestureDetector(
      onTap: () => providerModel.setSelectedRadioValue(DicParams.bank),
      child: AbsorbPointer(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            Radio(
              value: DicParams.bank,
              activeColor: ColorUtils.primaryColor,
              focusColor: ColorUtils.primaryColor,
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            Text(
              Localization.of(context).labelBank,
              style: const TextStyle(
                  fontFamily: fontFamilyPoppinsRegular,
                  fontSize: fontMedium,
                  color: ColorUtils.primaryTextColor),
            ),
          ],
        ),
      ),
    );
  }

  Widget walletRadioSelection(ChatPaymentSelectionProvider providerModel,
      BuildContext context, ResTransactionDetailsItem transactionDetailsItem) {
    return GestureDetector(
      onTap: () => providerModel.setSelectedRadioValue(DicParams.wallet),
      child: AbsorbPointer(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            Radio(
              activeColor: ColorUtils.primaryColor,
              focusColor: ColorUtils.primaryColor,
              value: DicParams.wallet,
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            Text(
              Localization.of(context).labelPaymishWallet,
              style: const TextStyle(
                  fontFamily: fontFamilyPoppinsRegular,
                  fontSize: fontMedium,
                  color: ColorUtils.primaryTextColor),
            ),
          ],
        ),
      ),
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
        padding: const EdgeInsets.fromLTRB(
            spacingMedium, 0.0, spacingSmall, spacingSmall),
        child: Row(
          children: [
            ProfileImageView(
              profileUrl: widget.senderProfileImage.isNotEmpty
                  ? widget.senderProfileImage
                  : _profileImage,
              largeSize: true,
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(left: spacingMedium),
                child: Text(
                  widget.senderName.isNotEmpty
                      ? widget.senderName
                      : _headerName,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontFamily: fontFamilyPoppinsMedium,
                    fontSize: 24.0,
                    color: ColorUtils.primaryColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _getTransactionListWithUser({bool isLoading = true}) {
    _isLoading.value = isLoading;
    UserApiManager()
        .getTransactionListWithUser(page: _pageCount, id: widget.senderUserId)
        .then((value) {
      _isLoading.value = false;
      final result = value.data?.result ?? <ResTransactionDetailsItem>[];
      if (result.isEmpty) {
        _isDataAvailable = false;
      } else {
        setState(() {
          _isDataAvailable = true;
          _list.addAll(result);
          Provider.of<ChatProvider>(context, listen: false)
              .setList(result);
          final item = _list.elementAt(0);
          if (_userId == (item.receiverId ?? 0)) {
            _headerName =
                """${item.senderFirstName ?? ''} ${item.senderLastName ?? ''}""";
            _profileImage = item.senderProfilePicture ?? '';
          } else {
            _headerName =
                """${item.receiverFirstName ?? ''} ${item.receiverLastName ?? ''}""";
            _profileImage = item.receiverProfilePicture ?? '';
          }
        });
      }
    }).catchError((dynamic e) {
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

  Future<void> onSendMessage(String content, ChatProvider provider) async {
    emit(emitNewUserMessage,
        ({DicParams.userId: widget.senderUserId, DicParams.message: content}));
    provider.addMessage(ResTransactionDetailsItem(
        message: content,
        createdAt: Utils().getUtcDate(),
        senderId: _userId,
        receiverId: widget.senderUserId,
        type: DicParams.text));
    setState(() {
      _messageTextController.text = "";
      Timer(const Duration(milliseconds: 500),
          () => _controller.jumpTo(_controller.position.minScrollExtent));
    });
  }

  void _openCardSelectionDialog(
      BuildContext context, ChatPaymentSelectionProvider providerModel) {
    NavigationUtils.pop(context);
    providerModel
        .setTemoSelectedCard(providerModel.getSelectedCard().id ?? 0);
    showModalBottomSheet(
        isDismissible: false,
        backgroundColor: Colors.transparent,
        context: context,
        builder: (ctx) => Consumer<ChatPaymentSelectionProvider>(
              builder: (context, providerModel, child) => Container(
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(spacingLarge),
                      topRight: Radius.circular(spacingLarge)),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.fromLTRB(spacingMedium,
                          spacingLarge, spacingMedium, spacingLarge),
                      child: Text(
                        Localization.of(context).selectCard,
                        style: const TextStyle(
                            fontFamily: fontFamilyPoppinsMedium,
                            fontSize: fontLarger,
                            color: ColorUtils.recentTextColor),
                      ),
                    ),
                    providerModel.getCardDetails().isNotEmpty
                        ? RadioGroup<int>(
                            groupValue: providerModel.getTempSelectedCard(),
                            onChanged: (value) {
                              if (value != null) {
                                providerModel.setTemoSelectedCard(value);
                              }
                            },
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                for (var card
                                    in providerModel.getCardDetails())
                                  GestureDetector(
                                    onTap: () => {
                                      providerModel
                                          .setTemoSelectedCard(card.id ?? 0)
                                    },
                                    child: AbsorbPointer(
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Row(
                                            children: [
                                              Radio(
                                                activeColor:
                                                    ColorUtils.primaryColor,
                                                focusColor:
                                                    ColorUtils.primaryColor,
                                                value: card.id ?? 0,
                                                materialTapTargetSize:
                                                    MaterialTapTargetSize
                                                        .shrinkWrap,
                                              ),
                                              Text(
                                                card.maskedCardNo ?? '',
                                                style: const TextStyle(
                                                    fontFamily:
                                                        fontFamilyPoppinsRegular,
                                                    fontSize: fontMedium,
                                                    color: ColorUtils
                                                        .primaryTextColor),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                  )
                              ],
                            ),
                          )
                        : const SizedBox(),
                    _addNewCardText(),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(spacingMedium,
                          spacingXXLarge, spacingMedium, spacingLarge),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _getCancelButton(context),
                          _getSelectButton(context, providerModel)
                        ],
                      ),
                    )
                  ],
                ),
              ),
            ));
  }

  Row _addNewCardText() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        InkWell(
          onTap: chargeCard,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(
                spacingMedium, spacingLarge, spacingMedium, spacingLarge),
            child: Text(
              Localization.of(context).addNewCard,
              style: const TextStyle(
                  fontFamily: fontFamilyPoppinsMedium,
                  fontSize: fontLarger,
                  color: ColorUtils.recentTextColor),
            ),
          ),
        ),
      ],
    );
  }

  Widget _getSelectButton(
      BuildContext context, ChatPaymentSelectionProvider providerModel) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.only(
          left: spacingSmall,
        ),
        child: PaymishPrimaryButton(
            buttonText: Localization.of(context).labelSelect,
            isBackground: true,
            onButtonClick: () async {
              providerModel
                  .setSelectedCardId(providerModel.getTempSelectedCard());
              NavigationUtils.pop(context);
              final details = itemDetails;
              if (details != null) {
                payMoneyClicked(context, details);
              }
            }),
      ),
    );
  }

  Widget _getCancelButton(BuildContext context) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.only(
          right: spacingSmall,
        ),
        child: PaymishPrimaryButton(
            buttonText: Localization.of(context).cancel,
            isBackground: false,
            onButtonClick: () async {
              NavigationUtils.pop(context);
              final details = itemDetails;
              if (details != null) {
                payMoneyClicked(context, details);
              }
            }),
      ),
    );
  }

  void chargeCard() async {
    var charge = Charge()
      ..amount = 5000
      ..reference = _getReference()
      ..email = getString(PreferenceKey.email, "");
    var response = await paystackPlugin.checkout(
      context,
      method: CheckoutMethod.card,
      charge: charge,
    );
    if (response.status == true) {
      _addBank(response.reference ?? '');
    } else {
      DialogUtils.displayToast("Process cancelled");
    }
  }

  String _getReference() {
    var userId = getInt(PreferenceKey.id).toString();
    String platform;
    if (Platform.isIOS) {
      platform = 'IOS';
    } else {
      platform = 'AN';
    }
    return """PAYMISH_${platform}_${userId}_${DateTime.now().millisecondsSinceEpoch}""";
  }

  void _addBank(String authID) {
    ProgressDialogUtils.showProgressDialog(context);
    UserApiManager().addCard(id: authID).then((value) {
      ProgressDialogUtils.dismissProgressDialog();
      DialogUtils.displayToast(value.message ?? '');
      setState(_getBankDetails);
    }).catchError((dynamic e) {
      ProgressDialogUtils.dismissProgressDialog();
      if (e is ResBaseModel) {
        if (!checkSessionExpire(e, context)) {
          DialogUtils.showAlertDialog(context, e.message ?? '');
        }
      }
    });
  }
}
