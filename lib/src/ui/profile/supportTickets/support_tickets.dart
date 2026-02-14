import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../../../apis/apimanager/user_api_manager.dart';
import '../../../apis/base_model.dart';
import '../../../main.dart';
import '../../../utils/color_utils.dart';
import '../../../utils/common_methods.dart';
import '../../../utils/constants.dart';
import '../../../utils/dialog_utils.dart';
import '../../../utils/image_constants.dart';
import '../../../utils/localization/localization.dart';
import '../../../utils/navigation.dart';
import '../../../utils/navigation_params.dart';
import '../../../utils/utils.dart';
import '../../../widgets/paymish_appbar.dart';
import '../../../widgets/paymish_support_ticket.dart';
import 'model/res_support_ticket.dart';

class SupportTicketsScreen extends StatefulWidget {
  final bool showBackButton;

  const SupportTicketsScreen({Key? key, this.showBackButton = false})
      : super(key: key);

  @override
  _SupportTicketsScreenState createState() => _SupportTicketsScreenState();

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(DiagnosticsProperty<bool>('showBackButton', showBackButton));
  }
}

class _SupportTicketsScreenState extends State<SupportTicketsScreen>
    with
        // ignore: prefer_mixin
        RouteAware {
  final List<SupportTicketDetails> _list = <SupportTicketDetails>[];
  int _pageCount = 0;
  bool _isDataAvailable = true;

  final _isLoading = ValueNotifier<bool>(false);
  final ScrollController _controller = ScrollController();

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final route = ModalRoute.of(context);
    if (route is PageRoute) {
      routeObserver.subscribe(this, route);
    }
  }

  void _onEndScroll(ScrollMetrics metrics) {
    if (_controller.offset >= _controller.position.maxScrollExtent &&
        !_controller.position.outOfRange) {
      _getSupportTicketData(isLoading: false);
    }
  }

  @override
  void initState() {
    _list.clear();
    _isDataAvailable = true;
    super.initState();
    _getSupportTicketData();
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
    setState(() {});
    _getSupportTicketData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PaymishAppBar(
        isBackGround: false,
        isHideBackButton: !widget.showBackButton,
        title: Localization.of(context).supportTicket,
      ),
      body: paginationTicketWidget(),
      floatingActionButton: FloatingActionButton(
        heroTag: '',
        onPressed: () {
          NavigationUtils.push(context, routeCreateSupportTicket);
        },
        backgroundColor: ColorUtils.primaryColor,
        child: Image.asset(
          ImageConstants.icAdd,
          scale: 2.5,
        ),
      ),
    );
  }

  Widget paginationTicketWidget() {
    return Column(
      children: [
        Expanded(
          child: ValueListenableBuilder(
            valueListenable: _isLoading,
            builder: (context, isLoading, _) {
              return isLoading
                  ? const Center(
                      child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(
                          ColorUtils.primaryColor),
                    ))
                  : _list.isEmpty
                      ? Center(
                          child: Text(
                              Localization.of(context).labelNoTicketsFound))
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
                              return PaymishSupportTicket(
                                titleText: _list[index].title ?? '',
                                categoryText: _list[index].category ?? '',
                                date: Utils.convertToDateString(
                                    _list[index].createdAt ?? ''),
                                detailsText: _list[index].description ?? '',
                                statusText: _list[index].status ?? '',
                                onClick: () {
                                  NavigationUtils.push(
                                      context, routeSupportTicketsChat,
                                      arguments: {
                                        NavigationParams.senderUserId:
                                            _list[index].id ?? 0
                                      });
                                },
                              );
                            },
                          ));
            },
          ),
        ),
      ],
    );
  }

  List<SupportTicketDetails> _getSupportTicketData({bool isLoading = true}) {
    _isLoading.value = isLoading;
    UserApiManager().getSupportTicketList(page: _pageCount).then((value) {
      _isLoading.value = false;
      if (value.data?.result?.isEmpty ?? true) {
        _isDataAvailable = false;
      } else {
        setState(() {
          _isDataAvailable = true;
          _list.addAll(value.data?.result ?? <SupportTicketDetails>[]);
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
      return <SupportTicketDetails>[];
    }
  }
}
