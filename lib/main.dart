import 'package:device_preview/device_preview.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:sanitary_mart/auth/provider/auth_provider.dart';
import 'package:sanitary_mart/auth/screen/login_screen.dart';
import 'package:sanitary_mart/auth/service/auth_service.dart';
import 'package:sanitary_mart/brand/provider/brand_provider.dart';
import 'package:sanitary_mart/brand/service/brand_firebase_service.dart';
import 'package:sanitary_mart/cart/provider/cart_provider.dart';
import 'package:sanitary_mart/cart/service/cart_firebase_service.dart';
import 'package:sanitary_mart/category/provider/category_provider.dart';
import 'package:sanitary_mart/category/service/category_firebase_service.dart';
import 'package:sanitary_mart/dashboard/ui/dashboard_screen.dart';
import 'package:sanitary_mart/firebase_options.dart';
import 'package:sanitary_mart/notification/service/notification_service.dart';
import 'package:sanitary_mart/order/provider/order_provider.dart';
import 'package:sanitary_mart/order/service/order_service.dart';
import 'package:sanitary_mart/payment/provider/payment_info_provider.dart';
import 'package:sanitary_mart/payment/service/payment_firebase_service.dart';
import 'package:sanitary_mart/payment/service/payment_service.dart';
import 'package:sanitary_mart/product/provider/product_provider.dart';
import 'package:sanitary_mart/product/service/product_service.dart';
import 'package:sanitary_mart/profile/provider/user_provider.dart';
import 'package:sanitary_mart/profile/service/user_firebase_service.dart';
import 'package:sanitary_mart/util/storage_helper.dart';

import 'core/constant/constant.dart';

Future main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initFirebase();
  FlutterError.onError = (errorDetails) {
    FirebaseCrashlytics.instance.recordFlutterFatalError(errorDetails);
  };
  PlatformDispatcher.instance.onError = (error, stack) {
    FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
    return true;
  };

  runApp(DevicePreview(
      enabled: false,
      builder: (BuildContext context) {
        return const VendorApp();
      },));
}

Future<void> initFirebase() async {
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
}

class VendorApp extends StatelessWidget {
  const VendorApp({super.key});

  static FirebaseAnalytics analytics = FirebaseAnalytics.instance;
  static FirebaseAnalyticsObserver observer =
  FirebaseAnalyticsObserver(analytics: analytics);

  @override
  Widget build(BuildContext context) {
    StorageHelper storageHelper = StorageHelper();
    Get.put(UserFirebaseService());
    Get.put(storageHelper);
    Get.put(CartFirebaseService());
    Get.put(OrderService());
    Get.put(PaymentFirebaseService());
    Get.put(PaymentService());
    Get.put(NotificationService());

    final authProvider = AuthenticationProvider(
      authService: AuthService(),
      storageHelper: storageHelper,
    );
    //TODO remove it later
    //  authProvider.loadLoggedStatus();
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (context) => authProvider,
        ),
        ChangeNotifierProvider(
          create: (context) => ProductProvider(
            ProductService(),
          ),
        ),
        ChangeNotifierProvider(
          create: (context) => CartProvider(
          ),
        ),
        ChangeNotifierProvider(
          create: (context) => CategoryProvider(
            CategoryFirebaseService(),
          ),
        ),
        ChangeNotifierProvider(
          create: (context) => BrandProvider(
            BrandFirebaseService(),
          ),
        ),
        ChangeNotifierProvider(
          create: (context) => UserProvider(),
        ),
        ChangeNotifierProvider(
          create: (context) => OrderProvider(),
        ),
        ChangeNotifierProvider(
          create: (context) => PaymentInfoProvider()..fetchPaymentInfo(),
        ),
      ],
      child: Consumer<AuthenticationProvider>(
        builder: (context, provider, child) {
          return GetMaterialApp(
            debugShowCheckedModeBanner: false,
            title: AppText.appName,
            navigatorObservers: [observer],
            theme: ThemeData(
              primarySwatch: AppColor.primaryColor,
            ),
            home:
                provider.isLoggedIn() ? const DashboardScreen() : LoginScreen(),
          );
        },
      ),
    );
  }
}
