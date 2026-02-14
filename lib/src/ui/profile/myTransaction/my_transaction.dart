import 'package:flutter/material.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';

import '../../../apis/apimanager/user_api_manager.dart';
import '../../../apis/base_model.dart';
import '../../../apis/dic_params.dart';
import '../../../utils/color_utils.dart';
import '../../../utils/common_methods.dart';
import '../../../utils/constants.dart';
import '../../../utils/dialog_utils.dart';
import '../../../utils/dimens.dart';
import '../../../utils/image_constants.dart';
import '../../../utils/localization/localization.dart';
import '../../../utils/navigation.dart';
import 'res_my_transaction_model.dart';
import 'transaction_list.dart';

class MyTransaction extends StatefulWidget {
  const MyTransaction({Key? key}) : super(key: key);

  @override
  _MyTransactionState createState() => _MyTransactionState();
}

class _MyTransactionState extends State<MyTransaction>
    with SingleTickerProviderStateMixin {
  static const int _firstPageKey = 0;

  late final TabController _tabController;
  late final PagingController<int, TransactionDataItem> _allPagingController;
  late final PagingController<int, TransactionDataItem> _debitPagingController;
  late final PagingController<int, TransactionDataItem> _creditPagingController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(vsync: this, length: 3);

    _allPagingController = PagingController<int, TransactionDataItem>(
      getNextPageKey: (state) {
        if (state.keys == null || state.keys!.isEmpty) {
          return _firstPageKey;
        }
        return state.keys!.last + 1;
      },
      fetchPage: (pageKey) =>
          _fetchTransactionPage(pageKey: pageKey, type: DicParams.all),
    );

    _debitPagingController = PagingController<int, TransactionDataItem>(
      getNextPageKey: (state) {
        if (state.keys == null || state.keys!.isEmpty) {
          return _firstPageKey;
        }
        return state.keys!.last + 1;
      },
      fetchPage: (pageKey) =>
          _fetchTransactionPage(pageKey: pageKey, type: DicParams.debit),
    );

    _creditPagingController = PagingController<int, TransactionDataItem>(
      getNextPageKey: (state) {
        if (state.keys == null || state.keys!.isEmpty) {
          return _firstPageKey;
        }
        return state.keys!.last + 1;
      },
      fetchPage: (pageKey) =>
          _fetchTransactionPage(pageKey: pageKey, type: DicParams.credit),
    );
  }

  @override
  void dispose() {
    _allPagingController.dispose();
    _debitPagingController.dispose();
    _creditPagingController.dispose();
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            color: ColorUtils.primaryColor,
            padding: const EdgeInsets.only(top: 12.0, left: 20.0),
            child: SafeArea(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  IconButton(
                    icon: Image.asset(ImageConstants.icBackArrow,
                        fit: BoxFit.contain,
                        height: spacingMedium,
                        color: Colors.white),
                    onPressed: () {
                      NavigationUtils.pop(context);
                    },
                    padding: const EdgeInsets.all(0),
                    alignment: Alignment.centerLeft,
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 16.0, bottom: 16.0),
                    child: Text(
                      Localization.of(context).myTransactions,
                      style: const TextStyle(
                        fontSize: fontXMLarge,
                        fontFamily: fontFamilyPoppinsMedium,
                        color: Colors.white,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Container(
            height: spacingXXXSLarge,
            decoration: const BoxDecoration(
              color: ColorUtils.primaryColor,
              borderRadius:
                  BorderRadius.vertical(bottom: Radius.circular(spacingMedium)),
            ),
            padding: const EdgeInsets.only(
                bottom: spacingMedium, left: spacingLarge, right: spacingLarge),
            child: TabBar(
              indicatorSize: TabBarIndicatorSize.tab,
              controller: _tabController,
              unselectedLabelStyle: const TextStyle(
                fontSize: fontMedium,
                fontFamily: fontFamilyPoppinsMedium,
                color: Colors.yellow,
                letterSpacing: 1,
                height: 1.0,
              ),
              labelStyle: const TextStyle(
                fontSize: fontMedium,
                fontFamily: fontFamilyPoppinsMedium,
                color: Colors.white,
                letterSpacing: 1,
                height: 1.0,
              ),
              indicator: BoxDecoration(
                borderRadius: BorderRadius.circular(spacingXXXSLarge),
                border: Border.all(
                  color: Colors.white,
                  width: 1,
                ),
              ),
              tabs: [
                Tab(text: Localization.of(context).labelAll),
                Tab(text: Localization.of(context).labelDebit),
                Tab(text: Localization.of(context).labelCredit)
              ],
            ),
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _getAllTypeOfTransaction(context),
                _getDebitTransactionList(context),
                _getCreditTransactionList(context),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _getCreditTransactionList(BuildContext context) {
    return _buildPagedList(
      controller: _creditPagingController,
      itemBuilder: (transferListItem) {
        return TransactionListItem(
            amount: transferListItem.amount ?? 0,
            firstName: transferListItem.senderFirstName ?? '',
            lastName: transferListItem.senderLastName ?? '',
            title: transferListItem.type == DicParams.topup
                ? Localization.of(context).labelCreditToWallet
                : Localization.of(context).labelReceivedFrom,
            profilePicture: transferListItem.type == DicParams.topup
                ? transferListItem.receiverProfilePicture ?? ''
                : transferListItem.senderProfilePicture ?? '',
            time: transferListItem.createdAt ?? '');
      },
    );
  }

  Widget _getDebitTransactionList(BuildContext context) {
    return _buildPagedList(
      controller: _debitPagingController,
      itemBuilder: (transferListItem) {
        return TransactionListItem(
            amount: transferListItem.amount ?? 0,
            firstName: transferListItem.utilityName ??
                transferListItem.receiverFirstName ??
                '',
            lastName: transferListItem.utilityName != null
                ? ""
                : transferListItem.receiverLastName ?? '',
            title: transferListItem.type == DicParams.withdraw
                ? Localization.of(context).labelWithdrawMoneyToBank
                : transferListItem.utilityName != null
                    ? Localization.of(context).labelUtilityPayment
                    : Localization.of(context).labelPaidTo,
            profilePicture: transferListItem.utilityImage ??
                transferListItem.receiverProfilePicture ??
                '',
            time: transferListItem.createdAt ?? '');
      },
    );
  }

  Widget _getAllTypeOfTransaction(BuildContext context) {
    return _buildPagedList(
      controller: _allPagingController,
      itemBuilder: (transferListItem) {
        return TransactionListItem(
            amount: transferListItem.amount ?? 0,
            firstName: transferListItem.senderFirstName ?? '',
            lastName: transferListItem.senderLastName ?? '',
            title: transferListItem.type == DicParams.withdraw
                ? Localization.of(context).labelWithdrawMoneyToBank
                : transferListItem.type == DicParams.utility
                    ? Localization.of(context).labelUtilityPayment
                    : transferListItem.type == DicParams.topup
                        ? Localization.of(context).labelCreditToWallet
                        : Localization.of(context).labelReceivedFrom,
            profilePicture: transferListItem.type == DicParams.utility
                ? transferListItem.utilityImage ?? ''
                : transferListItem.type == DicParams.topup
                    ? transferListItem.receiverProfilePicture ?? ''
                    : transferListItem.type == DicParams.debit
                        ? transferListItem.receiverProfilePicture ?? ''
                        : transferListItem.senderProfilePicture ?? '',
            time: transferListItem.createdAt ?? '');
      },
    );
  }

  Widget _buildPagedList({
    required PagingController<int, TransactionDataItem> controller,
    required Widget Function(TransactionDataItem) itemBuilder,
  }) {
    return PagedListView<int, TransactionDataItem>(
      state: controller.value,
      fetchNextPage: controller.fetchNextPage,
      builderDelegate: PagedChildBuilderDelegate<TransactionDataItem>(
        itemBuilder: (context, item, index) => itemBuilder(item),
        firstPageProgressIndicatorBuilder: (_) =>
            const Center(child: CircularProgressIndicator()),
        newPageProgressIndicatorBuilder: (_) =>
            const Center(child: CircularProgressIndicator()),
        noItemsFoundIndicatorBuilder: (_) => Center(
          child: Text(Localization.of(context).labelNoTransactionDetailsFound),
        ),
        firstPageErrorIndicatorBuilder: (_) => Center(
          child: Text(Localization.of(context).errorSomethingWentWrong),
        ),
        newPageErrorIndicatorBuilder: (_) => Center(
          child: Text(Localization.of(context).errorSomethingWentWrong),
        ),
      ),
    );
  }

  Future<List<TransactionDataItem>> _fetchTransactionPage({
    required int pageKey,
    required String type,
  }) async {
    try {
      final value =
          await UserApiManager().getMyTransactionList(page: pageKey, type: type);
      final result = value.data?.result ?? <TransactionDataItem>[];
      final newItems = result
          .where((datalist) => datalist.status == DicParams.success)
          .toList();
      return newItems;
    } catch (e) {
      if (e is ResBaseModel) {
        if (!checkSessionExpire(e, context)) {
          DialogUtils.showAlertDialog(context, e.error ?? '');
        }
      }
      rethrow;
    }
  }
}
