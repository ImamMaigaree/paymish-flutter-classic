import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../../apis/apimanager/user_api_manager.dart';
import '../../../apis/dic_params.dart';
import '../../../main.dart';
import '../../../socket/socket_constants.dart';
import '../../../socket/socket_mangaer.dart';
import '../../../utils/color_utils.dart';
import '../../../utils/constants.dart';
import '../../../utils/dimens.dart';
import '../../../utils/image_constants.dart';
import '../../../utils/localization/localization.dart';
import '../../../utils/navigation.dart';
import '../../../utils/utils.dart';
import 'model/res_support_ticket_old_messages.dart';
import 'provider/support_chat_provider.dart';

class SupportTicketChatScreen extends StatefulWidget {
  final int senderUserId;

  const SupportTicketChatScreen({Key? key, required this.senderUserId})
    : super(key: key);

  @override
  _SupportTicketChatScreenState createState() =>
      _SupportTicketChatScreenState();

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(IntProperty('senderUserId', senderUserId));
  }
}

class _SupportTicketChatScreenState extends State<SupportTicketChatScreen>
    with
        // ignore: prefer_mixin
        RouteAware {
  int _pageCount = 0;
  final ScrollController _controller = ScrollController();
  final TextEditingController _messageTextController = TextEditingController();
  Timer? _loadingTimeoutTimer;
  Timer? _pollingTimer;
  bool _isSendingMessage = false;

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
  }

  @override
  void initState() {
    super.initState();
    SchedulerBinding.instance.addPostFrameCallback((_) {
      final provider = Provider.of<SupportChatProvider>(context, listen: false);
      provider.clearAllMessages();
      provider.setLoading(true);
      _pageCount = 0;
      reInitializeAndConnectSocket();

      emit(join, ({DicParams.ticketId: widget.senderUserId}));
      emit(requestOldMessages, ({
        DicParams.page: _pageCount,
        DicParams.ticketId: widget.senderUserId,
        DicParams.limit: 20,
      }));
      _loadMessagesFromApi(reset: true, page: _pageCount);
      _startLoadingTimeout();
      _startPolling();
      provider.ticketId = widget.senderUserId;
      provider.isScreenOpen = true;
    });
  }

  void _startLoadingTimeout() {
    _loadingTimeoutTimer?.cancel();
    _loadingTimeoutTimer = Timer(const Duration(seconds: 8), () {
      if (!mounted) {
        return;
      }
      final provider = Provider.of<SupportChatProvider>(context, listen: false);
      if (provider.isLoading.value) {
        _loadMessagesFromApi(reset: true, page: 0);
      }
    });
  }

  void _onEndScroll(ScrollMetrics metrics) {
    if (_controller.offset >= _controller.position.maxScrollExtent &&
        !_controller.position.outOfRange) {
      setState(() {
        _pageCount = _pageCount + 1;
      });
      emit(requestOldMessages, ({
        DicParams.page: _pageCount,
        DicParams.ticketId: widget.senderUserId,
        DicParams.limit: 20,
      }));
      _loadMessagesFromApi(page: _pageCount);
    }
  }

  Future<void> _loadMessagesFromApi({
    bool reset = false,
    required int page,
  }) async {
    try {
      final provider = Provider.of<SupportChatProvider>(context, listen: false);
      final response = await UserApiManager().getSupportTicketMessages(
        ticketId: widget.senderUserId,
        page: page,
        limit: 20,
      );
      final ticketStatus = response.result?.ticketDetails?.status ?? '';
      provider.setIsTicketClosed(ticketStatus);
      final messages = response.result?.message ?? <SupportChatMessage>[];
      if (reset) {
        provider.replaceMessages(messages);
      } else if (page > 0) {
        provider.prependOlderMessages(messages);
      } else {
        provider.mergeNewMessages(messages);
      }
    } catch (_) {
      if (!mounted) {
        return;
      }
      final provider = Provider.of<SupportChatProvider>(context, listen: false);
      provider.setLoading(false);
    }
  }

  void _startPolling() {
    _pollingTimer?.cancel();
    _pollingTimer = Timer.periodic(const Duration(seconds: 4), (_) {
      _loadMessagesFromApi(page: 0);
    });
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
        Provider.of<SupportChatProvider>(context, listen: false).ticketId = 0;
        Provider.of<SupportChatProvider>(context, listen: false).isScreenOpen =
            false;
        NavigationUtils.pop(context);
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          child: Consumer<SupportChatProvider>(
            builder: (context, myModel, child) => Column(
              children: [
                Container(
                  margin: const EdgeInsets.only(
                    right: spacingMedium,
                    top: spacingMedium,
                    bottom: spacingMedium,
                  ),
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
                          Provider.of<SupportChatProvider>(
                            context,
                            listen: false,
                          ).ticketId = 0;
                          Provider.of<SupportChatProvider>(
                            context,
                            listen: false,
                          ).isScreenOpen = false;
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
                      valueListenable: myModel.isLoading,
                      builder: (context, isLoading, _) {
                        return isLoading
                            ? const Center(child: CircularProgressIndicator())
                            : myModel.list.isEmpty
                            ? Center(
                                child: Text(
                                  Localization.of(context).labelNoMessageFound,
                                ),
                              )
                            : NotificationListener(
                                onNotification: (scrollNotification) {
                                  if (scrollNotification
                                      is ScrollEndNotification) {
                                    _onEndScroll(scrollNotification.metrics);
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
                                          <SupportChatMessage>[];
                                      return Column(
                                        children: [
                                          _buildDateField(date, context),
                                          _getListViewFromMessage(messages),
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
                myModel.isTicketClosed
                    ? const SizedBox()
                    : getChatTextFieldUI(context, myModel),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDateField(String date, BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(
        spacingSmall,
        spacingTiny,
        spacingSmall,
        spacingTiny,
      ),
      decoration: BoxDecoration(
        border: Border.all(
          color: ColorUtils.secondaryTextColor.withValues(alpha: 0.5),
        ),
        borderRadius: BorderRadius.circular(spacingXXLarge),
        color: ColorUtils.unCheckedSwitchColor.withValues(alpha: 0.5),
      ),
      child: Text(
        Utils.convertStringWithTimeDifference(date.toString(), context),
        style: const TextStyle(
          color: Colors.black,
          fontFamily: fontFamilyCovesBold,
        ),
      ),
    );
  }

  Widget _getListViewFromMessage(List<SupportChatMessage> messages) {
    return ListView.builder(
      primary: false,
      shrinkWrap: true,
      itemCount: messages.length,
      itemBuilder: (context, index) =>
          getCardViewForRequestedPayment(context, messages.elementAt(index)),
    );
  }

  Widget _buildSenderMessageView(SupportChatMessage item) {
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
                  maxWidth: MediaQuery.of(context).size.width * 0.7,
                ),
                padding: const EdgeInsets.fromLTRB(16.0, 12.0, 16.0, 12.0),
                decoration: const BoxDecoration(
                  color: ColorUtils.recentTextColor,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(spacing17),
                    topRight: Radius.circular(spacing17),
                    bottomRight: Radius.circular(spacing4),
                    bottomLeft: Radius.circular(spacing17),
                  ),
                ),
                margin: const EdgeInsets.only(right: 10.0),
                child: Text(
                  item.message ?? '',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: fontMedium,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ),
              _buildTimeView(item.createdAt, true),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildReceiverMessageView(SupportChatMessage item) {
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
                  maxWidth: MediaQuery.of(context).size.width * 0.7,
                ),
                padding: const EdgeInsets.fromLTRB(16.0, 12.0, 16.0, 12.0),
                decoration: const BoxDecoration(
                  color: ColorUtils.chatPaymentCardColour,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(spacing17),
                    topRight: Radius.circular(spacing17),
                    bottomRight: Radius.circular(spacing17),
                    bottomLeft: Radius.circular(spacing4),
                  ),
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
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ],
                ),
              ),
              _buildTimeView(item.createdAt, false),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTimeView(String? timeStamp, bool isSender) {
    return Container(
      margin: isSender
          ? const EdgeInsets.only(top: 6.0, bottom: 15.0)
          : const EdgeInsets.only(top: 6.0, bottom: 15.0),
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
    BuildContext context,
    SupportChatMessage message,
  ) {
    return Row(
      mainAxisAlignment: message.type == DicParams.receiver
          ? MainAxisAlignment.start
          : MainAxisAlignment.end,
      children: [
        Column(
          crossAxisAlignment: message.type == DicParams.receiver
              ? CrossAxisAlignment.start
              : CrossAxisAlignment.end,
          children: [
            Padding(
              padding: const EdgeInsets.only(
                right: spacingLarge,
                left: spacingLarge,
              ),
              child: Text(
                toBeginningOfSentenceCase(message.senderName) ?? '',
                style: const TextStyle(
                  fontWeight: fontWeightSemiBold,
                  fontSize: fontXSmall,
                  color: ColorUtils.chatNameColor,
                ),
              ),
            ),
            message.type == DicParams.receiver
                ? _buildReceiverMessageView(message)
                : _buildSenderMessageView(message),
          ],
        ),
      ],
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
          spacingMedium,
          0.0,
          55.0,
          spacingSmall,
        ),
        child: Text(
          Localization.of(context).labelChat,
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

  Widget getChatTextFieldUI(
    BuildContext context,
    SupportChatProvider provider,
  ) {
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
            fontSize: fontMedium,
          ),
          cursorColor: ColorUtils.primaryTextColor,
          textInputAction: TextInputAction.done,
          decoration: InputDecoration(
            counterText: "",
            suffixIcon: InkWell(
              onTap: () {
                if (!_isSendingMessage &&
                    _messageTextController.text.trim().isNotEmpty) {
                  onSendMessage(_messageTextController.text);
                }
              },
              child: Image.asset(ImageConstants.icSendMessage, scale: 3.5),
            ),
            border: InputBorder.none,
            hintStyle: const TextStyle(
              fontFamily: fontFamilyPoppinsRegular,
              color: ColorUtils.primaryTextColor,
              fontSize: fontMedium,
            ),
            hintText: Localization.of(context).hintWriteMessage,
          ),
        ),
      ),
    );
  }

  Future<void> onSendMessage(String content) async {
    final message = content.trim();
    if (message.isEmpty || _isSendingMessage) {
      return;
    }

    setState(() {
      _isSendingMessage = true;
    });

    try {
      await UserApiManager().sendSupportTicketMessage(
        ticketId: widget.senderUserId,
        message: message,
      );

      setState(() {
        _messageTextController.clear();
      });

      _loadMessagesFromApi(page: 0);
      Timer(
        const Duration(milliseconds: 300),
        () => _controller.jumpTo(_controller.position.minScrollExtent),
      );
    } catch (_) {
      return;
    } finally {
      if (mounted) {
        setState(() {
          _isSendingMessage = false;
        });
      } else {
        _isSendingMessage = false;
      }
    }
  }

  @override
  void dispose() {
    _loadingTimeoutTimer?.cancel();
    _pollingTimer?.cancel();
    Provider.of<SupportChatProvider>(context, listen: false).ticketId = 0;
    Provider.of<SupportChatProvider>(context, listen: false).isScreenOpen =
        false;
    super.dispose();
  }
}
