import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';

import 'ui/auth/home/provider/home_screen_provider.dart';
import 'ui/auth/home/provider/notification_provider.dart';
import 'ui/chat/provider/chat_payment_selection_provider.dart';
import 'ui/chat/provider/chat_provider.dart';
import 'ui/paymentSetting/provider/bank_details_provider.dart';
import 'ui/profile/supportTickets/provider/support_chat_provider.dart';
import 'ui/profile/wallet/bank_selection_provider.dart';
import 'ui/profile/wallet/withdrawMoney/provider/withdraw_money_provider.dart';
import 'ui/transfermoney/provider/pay_request_provider.dart';
import 'ui/utilityServices/provider/utility_service_provider.dart';
import 'utils/color_utils.dart';
import 'utils/common_methods.dart';
import 'utils/constants.dart';
import 'utils/localization/localization.dart';
import 'utils/navigation.dart';
import 'utils/app_config.dart';
import 'utils/fcm_utils.dart';
import 'utils/preference_utils.dart';
import 'widgets/slide_transition_builder.dart';

class MyHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..badCertificateCallback = (cert, host, port) => true;
  }
}

Future<void> main() async {
  await mainDelegate();
}

Future<void> mainDelegate() async {
  HttpOverrides.global = MyHttpOverrides();
  WidgetsFlutterBinding.ensureInitialized();
  await _initializeFirebaseSafely();
  await init();
  paystackPlugin.initialize(publicKey: payStackKey ?? '');
  runApp(const MyApp());
}

Future<void> _initializeFirebaseSafely() async {
  try {
    await Firebase.initializeApp().timeout(const Duration(seconds: 10));
    await configureFirebaseMessaging().timeout(const Duration(seconds: 10));
  } on TimeoutException catch (_) {
    debugPrint("BOOT: Firebase init timed out, continuing app startup.");
  } catch (e) {
    debugPrint(
      "BOOT: Firebase init failed, continuing app startup without FCM. error=$e",
    );
  }
}

// To Observe route and manage back flow with navigation
final RouteObserver<PageRoute> routeObserver = RouteObserver<PageRoute>();

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: ColorUtils.primaryColor, // status bar color
      ),
    );
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => HomeScreenProvider()),
        ChangeNotifierProvider(create: (_) => BankSelectionProvider()),
        ChangeNotifierProvider(create: (_) => BankDetailsProvider()),
        ChangeNotifierProvider(create: (_) => PayRequestProvider()),
        ChangeNotifierProvider(create: (_) => NotificationProvider()),
        ChangeNotifierProvider(create: (_) => ChatPaymentSelectionProvider()),
        ChangeNotifierProvider(create: (_) => SupportChatProvider()),
        ChangeNotifierProvider(create: (_) => ChatProvider()),
        ChangeNotifierProvider(create: (_) => WithdrawMoneyProvider()),
        ChangeNotifierProvider(create: (_) => UtilityServiceProvider()),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        navigatorObservers: <NavigatorObserver>[routeObserver],
        builder: (context, child) {
          return MediaQuery(
            data: MediaQuery.of(
              context,
            ).copyWith(textScaler: const TextScaler.linear(1.0)),
            child: child ?? const SizedBox.shrink(),
          );
        },
        home: gotoNextScreen(),
        theme: ThemeData(
          pageTransitionsTheme: const PageTransitionsTheme(
            builders: {
              TargetPlatform.iOS: SlideTransitionBuilder(),
              TargetPlatform.android: SlideTransitionBuilder(),
            },
          ),
          primaryColor: ColorUtils.primaryColor,
          fontFamily: fontFamilyPoppinsRegular,
          scaffoldBackgroundColor: Colors.white,
          colorScheme: ColorScheme.fromSwatch().copyWith(
            secondary: ColorUtils.accentColor,
          ),
        ),
        onGenerateRoute: NavigationUtils.generateRoute,
        localizationsDelegates: [
          const MyLocalizationsDelegate(),
          DefaultMaterialLocalizations.delegate,
          DefaultWidgetsLocalizations.delegate,
        ],
        supportedLocales: [const Locale('en', '')],
      ),
    );
  }
}
