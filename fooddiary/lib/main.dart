import 'dart:async';
import 'package:appsflyer_sdk/appsflyer_sdk.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:fit_track/firebase_options.dart';
import 'package:fit_track/main/firebase_init.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fit_track/views/base_bview.dart';
import 'package:fit_track/views/base_view.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:get_storage/get_storage.dart';
import 'package:get/get.dart';
import 'main/app.dart';

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // If you're going to use other Firebase services in the background, such as Firestore,
  // make sure you call `initializeApp` before using other Firebase services.
  await Firebase.initializeApp();

  print("Handling a background message: ${message.messageId}");
}

void main() {
  AppCatchError().run();
}

//全局异常的捕捉
class AppCatchError {
  run() {
    ///Flutter 框架异常

    FlutterError.onError = (FlutterErrorDetails details) async {
      ///线上环境 todo
      if (kReleaseMode) {
        Zone.current.handleUncaughtError(details.exception, details.stack!);
      } else {
        //开发期间 print
        FlutterError.dumpErrorToConsole(details);
      }
    };

    runZonedGuarded(
      () {
        //受保护的代码块
        WidgetsFlutterBinding.ensureInitialized();

        SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp])
            .then((_) async {
          WidgetsFlutterBinding.ensureInitialized();
           FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
          await Firebase.initializeApp(
            options: DefaultFirebaseOptions.currentPlatform,
          );
          await FirebaseService().initNotifications();
          await GetStorage.init();
          runApp(const FitTrackApp());
          pustLogic();
        });
      },
      (error, stack) => catchError(error, stack),
    );
  }

  ///对搜集的 异常进行处理  上报等等
  catchError(Object error, StackTrace stack) async {
    //是否是 Release版本
    debugPrint("AppCatchError>>>>>>>>>> [ kReleaseMode ] $kReleaseMode");
    debugPrint('AppCatchError>>>>>>>>>> [ Message ] $error');
    debugPrint('AppCatchError>>>>>>>>>> [ Stack ] \n$stack');

    // 弹窗提醒用户
    if (kDebugMode) {
      SmartDialog.showToast(
        error.toString(),
        displayTime: const Duration(seconds: 5),
        alignment: Alignment.topCenter,
      );
    }

    // 判断返回数据中是否包含"token失效"的信息
    // 一些错误处理，比如token失效这里退出到登录页面之类的
    if (error.toString().contains("token无效") ||
        error.toString().contains("token已过期") ||
        error.toString().contains("登录出错") ||
        error.toString().toLowerCase().contains("invalid")) {
      if (kDebugMode) {
        print(error);
      }
    }
  }

  pustLogic() async {
    Get.put(WebviewGetxLogic(), permanent: true);
    Get.put(BaseBViewGetxLogic(), permanent: true);
    Get.put(DILogic(), permanent: true);
  }
}

class DILogic extends GetxController {
  var afid = '';
  late AppsflyerSdk appsflyerSdk = () {
    AppsFlyerOptions appsFlyerOptions = AppsFlyerOptions(
        afDevKey: "eyFyB4RVUU4iGJLu9qupr5",
        appId: "6476438817",
        showDebug: true,
        timeToWaitForATTUserAuthorization: 50,
        // for iOS 14.5
        appInviteOneLink: "",
        // Optional field
        disableAdvertisingIdentifier: false,
        // Optional field
        disableCollectASA: false); // Optional field

    return AppsflyerSdk(appsFlyerOptions);
  }();

  late StreamSubscription<List<ConnectivityResult>> subscription;

  // bool netWorkOn = true;
  var netWorkOn = true.obs;
  var isShowDragWidget = false.obs;

  @override
  void onInit() {
    super.onInit();
    loadSDK();
    Connectivity().onConnectivityChanged.listen((event) {});
    subscription = Connectivity()
        .onConnectivityChanged
        .listen((List<ConnectivityResult> result) {
      // Got a new connectivity status!
      if (result.last == ConnectivityResult.none) {
        // print("--11------${result}-------------");
        netWorkOn.value = false;
        // SmartDialog.showToast("msg-off-123--${result}",displayTime: Duration(seconds: 5));
      } else {
        // SmartDialog.showToast("msg-on-456--${result}",displayTime: Duration(seconds: 5));

        if (netWorkOn.value == false) {
          BaseBViewGetxLogic blogic = Get.find<BaseBViewGetxLogic>();
          blogic.controller.reload();
          WebviewGetxLogic slogic = Get.find<WebviewGetxLogic>();
          slogic.controller.reload();
          netWorkOn.value = true;
        }
      }
    });
  }

  loadSDK() async {
    appsflyerSdk.initSdk(
        registerConversionDataCallback: true,
        registerOnAppOpenAttributionCallback: true,
        registerOnDeepLinkingCallback: true);
    var afid = await appsflyerSdk.getAppsFlyerUID();

    this.afid = afid!;

    WebviewGetxLogic slogic = Get.find<WebviewGetxLogic>();
    slogic.loadCookies();

    // await Firebase.initializeApp(
    //   options: DefaultFirebaseOptions.currentPlatform,
    // );
  }

  void showDragWidget() {
    var box = GetStorage();
    if (box.read('savePathkey') != null && box.read('savePathkey') != '') {
      isShowDragWidget.value = true;
    } else {
      isShowDragWidget.value = false;
    }
  }

  @override
  void onClose() {
    subscription.cancel();
    super.onClose();
  }
}
