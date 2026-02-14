import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../apis/apimanager/user_api_manager.dart';
import '../../apis/base_model.dart';
import '../../main.dart';
import '../../utils/color_utils.dart';
import '../../utils/common_methods.dart';
import '../../utils/constants.dart';
import '../../utils/dialog_utils.dart';
import '../../utils/dimens.dart';
import '../../utils/localization/localization.dart';
import '../../utils/navigation.dart';
import '../../widgets/paymish_appbar.dart';
import '../auth/home/model/res_home.dart';
import 'model/res_data_plan_list.dart';
import 'provider/utility_service_provider.dart';

class BouquetListingScreen extends StatefulWidget {
  final Services services;

  const BouquetListingScreen({Key? key, required this.services})
      : super(key: key);

  @override
  _BouquetListingScreenState createState() => _BouquetListingScreenState();

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(DiagnosticsProperty<Services>('services', services));
  }
}

class _BouquetListingScreenState extends State<BouquetListingScreen>
    with
// ignore: prefer_mixin
        RouteAware {
  List<DataPlanItem> _list = <DataPlanItem>[];

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final route = ModalRoute.of(context);
    if (route is PageRoute) {
      routeObserver.subscribe(this, route);
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
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: PaymishAppBar(
        title: Localization.of(context).labelBouquet,
        isBackGround: false,
      ),
      body: Padding(
        padding: const EdgeInsets.only(
            left: spacingLarge, right: spacingLarge, top: 0.0),
        child: Container(
          child: FutureBuilder<List<DataPlanItem>>(
            future: _getBankDetails(context), // async work
            builder: (context, snapshot) {
              final data = snapshot.data ?? <DataPlanItem>[];
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                    child: CircularProgressIndicator(
                  valueColor:
                      AlwaysStoppedAnimation<Color>(ColorUtils.primaryColor),
                ));
              } else {
                if (snapshot.hasError) {
                  return Center(child: Text(snapshot.error.toString()));
                } else if (data.isEmpty) {
                  return Center(
                      child: Text(
                          Localization.of(context).labelNoPlanFound));
                } else {
                  return ListView.builder(
                    itemCount: data.length,
                    itemBuilder: (context, index) {
                      return InkWell(
                        onTap: () {
                          Provider.of<UtilityServiceProvider>(context,
                                  listen: false)
                              .setSelectedDataPlan(data[index]);
                          NavigationUtils.pop(context);
                        },
                        child: Container(
                          margin: const EdgeInsets.only(bottom: spacingMedium),
                          decoration: BoxDecoration(
                            border: Border.all(color: ColorUtils.borderColor),
                            borderRadius: BorderRadius.circular(4.0),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withAlpha(20),
                                blurRadius: 10.0,
                              )
                            ],
                            color: Colors.white,
                          ),
                          child: Padding(
                            padding: const EdgeInsets.fromLTRB(spacingLarge,
                                spacingMedium, spacingMedium, spacingMedium),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                      child: Text(
                                        data[index].vairationName ?? '',
                                        style: const TextStyle(
                                            fontFamily:
                                                fontFamilyPoppinsRegular,
                                            fontSize: fontMedium,
                                            color: ColorUtils.primaryColor),
                                      ),
                                    ),
                                    Text(
                                      """N ${data[index].variationAmount ?? ''}""",
                                      style: const TextStyle(
                                          fontFamily: fontFamilyPoppinsMedium,
                                          fontWeight: FontWeight.bold,
                                          fontSize: fontLarger,
                                          color: ColorUtils.recentTextColor),
                                    )
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  );
                }
              }
            },
          ),
        ),
      ),
    );
  }

  Future<List<DataPlanItem>> _getBankDetails(BuildContext context) async {
    await UserApiManager()
        .getDataPlanList(
            identifier: widget.services.identifier ?? '',
            serviceID: widget.services.serviceID ?? '')
        .then((value) {
      _list = value.data ?? <DataPlanItem>[];
    }).catchError((dynamic e) {
      if (e is ResBaseModel) {
        if (!checkSessionExpire(e, context)) {
          DialogUtils.showAlertDialog(context, e.error ?? '');
        }
      }
    });
    return _list;
  }
}
