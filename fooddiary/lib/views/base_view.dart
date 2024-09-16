import 'dart:async';
import 'dart:io';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:get/get.dart';
import 'package:webview_cookie_manager/webview_cookie_manager.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:webview_flutter_android/webview_flutter_android.dart';
import 'package:webview_flutter_wkwebview/webview_flutter_wkwebview.dart';
import 'package:get_storage/get_storage.dart';
import 'dart:convert';
import '../common/components/draggable_float/draggable_float.dart';
import '../common/components/draggable_float/model_base_config.dart';
import '../main.dart';
import '../main/float_view.dart';
import 'base_bview.dart';

class WebviewGetxLogic extends GetxController {
  String pa = 'h';
  String pb = 't';
  String pc = 'ps';
  String pd = '://';
  // String pe = '547gykk';
  String pe = '547gykk';
  String pf = '.com';
  final box = GetStorage();
  String pagekey = "pagekey";
  String userinfoKey = "userinfokey";

  String safeAreaColorKey = 'safeAreaColor_key';

  // String keyString = "8J1CUL0UuquxGXJ5tU7WZ75tSvfxeLVl";
  String keyString = "8J1CUL0UuquxGXJ5tU7WZ75tSvfxeLVl";

  var visible = true.obs;

  var safeAreaColor = Colors.white.obs;

  var allowNavigate = false.obs;

  var loadFinished = false.obs;

  // var loadProgress = 0.obs;

  String savePathKey = 'savePathkey';
  String appsFlyIDkey = "appsflyerid";

  late WebViewController controller = () {
    late final PlatformWebViewControllerCreationParams params;
    if (WebViewPlatform.instance is WebKitWebViewPlatform) {
      params = WebKitWebViewControllerCreationParams(
        allowsInlineMediaPlayback: true,
        mediaTypesRequiringUserAction: const <PlaybackMediaTypes>{},
      );
    } else {
      params = const PlatformWebViewControllerCreationParams();
    }

    final WebViewController controller =
        WebViewController.fromPlatformCreationParams(params);

    controller
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(const Color(0x00000000))
      ..setNavigationDelegate(
        NavigationDelegate(
          onProgress: (int progress) {
          },
          onPageStarted: (String url) {},
          onPageFinished: (String url) {
            loadFinished.value = true;
          },
          onWebResourceError: (WebResourceError error) {
            debugPrint('''
              Page resource error:
              code: ${error.errorCode}
              description: ${error.description}
              errorType: ${error.errorType}
              isForMainFrame: ${error.isForMainFrame}
            ''');

            // showRetryView();
          },
          onNavigationRequest: (NavigationRequest request) {
            debugPrint('dd5as4dad ${request.url}');
              if (request.url.contains("547gykk")) {
                return NavigationDecision.navigate;
              } else if (request.url.contains(keyString)) {
                loadpage(request.url);
                // if (!request.url.contains(appsFlyIDkey)) {
                //   loadpage(request.url);
                // }
                allowNavigate.value = true;
                return NavigationDecision.navigate;
              } else if (allowNavigate.value == true) {
                return NavigationDecision.navigate;
              } else {
                visible.value = false;
                eventBus.fire(InitEvent());
                return NavigationDecision.prevent;
              }
          },
          onUrlChange: (change) {
            readSaveCookies();
            userAgentInfo();
          },
        ),
      )
      ..addJavaScriptChannel(
        'Toaster',
        onMessageReceived: (JavaScriptMessage message) {},
      )
      ..addJavaScriptChannel(
        'clickEvent',
        onMessageReceived: (JavaScriptMessage message) {
          Map<String, dynamic> jsonMap = json.decode(message.message);
          DILogic dilogic = Get.find<DILogic>();

          if (jsonMap["event"] == 'getBaseInfo') {
          } else if (jsonMap["event"] == 'portraitUp') {
          } else if (jsonMap["event"] == 'ThemeColorChange') {
            Map color = jsonMap["eventParms"];
            String colorString = color["bgColor"].replaceAll("#", "0xff");
            box.write(safeAreaColorKey, colorString);
            safeAreaColor.value = Color(int.parse(colorString));
          } else {
            dilogic.appsflyerSdk
                .logEvent(jsonMap["event"], jsonMap["eventParms"]);
            // dilogic.metaSdk.logEvent(
            //     name: jsonMap["event"], parameters: jsonMap["eventParms"]);
            // FirebaseAnalytics.instance.logEvent(
            //     name: jsonMap["event"], parameters: jsonMap["eventParms"]);
          }
        },
      );

    if (controller.platform is AndroidWebViewController) {
      AndroidWebViewController.enableDebugging(true);
      (controller.platform as AndroidWebViewController)
          .setMediaPlaybackRequiresUserGesture(false);
    }

    return controller;
  }();

  bool systemLanguageIsVIOrCH() {
    String systemLanguage = window.locale.languageCode;
    bool isIos = controller.platform is WebKitWebViewController;
    if ((systemLanguage == 'zh' || systemLanguage == 'vi') && isIos) {
      return true;
    } else {
      return false;
    }
  }

  showRetryView() async {
    String? url = await controller.currentUrl();
    if (url != null && url.contains(keyString)) {
      SmartDialog.show(builder: ((context) {
        return Container(
          width: 260,
          height: 120,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Column(
            children: [
              const Expanded(
                  child: Padding(
                padding: EdgeInsets.fromLTRB(20, 24, 20, 0),
                child: Text('Network Error,please try agagin'),
              )),
              const SizedBox(
                height: 10,
              ),
              const Divider(
                height: 1,
                color: Colors.grey,
              ),
              InkWell(
                onTap: () {
                  loadHomePage();
                },
                child: const SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: Center(
                    child: Text('Refresh'),
                  ),
                ),
              )
            ],
          ),
        );
      }));
    }
  }

  @override
  void onInit() {
    super.onInit();

    String? colorstring = box.read(safeAreaColorKey);
    if (colorstring != null) {
      safeAreaColor.value = Color(int.parse(colorstring));
    }
    eventBus.on<HomeEvent>().listen((event) {
      loadHomePage();
    });

    eventBus.on<RefreshEvent>().listen((event) {
      controller.reload();
    });
  }

  userAgentInfo() async {
    var agent = await controller.getUserAgent();
    if (agent!.contains("Safari") == false) {
      agent = "$agent Safari/604.1";
      controller.setUserAgent(agent);
    }
  }

  readSaveCookies() async {
    final cookieManager = WebviewCookieManager();

    final gotCookies = await cookieManager.getCookies(null);
    var savelist = <String>[];

    for (Cookie item in gotCookies) {
      savelist.add(item.toString());
    }

    box.write(userinfoKey, savelist);
  }

  loadCookies() {
    List cookies = box.read(userinfoKey) ?? [];

    List<Cookie> localCookies = <Cookie>[];
    final cookieManager = WebviewCookieManager();

    for (var element in cookies) {
      Cookie value = Cookie.fromSetCookieValue(element);
      localCookies.add(value);
    }

    cookieManager.setCookies(localCookies);
  }

  cleanCookies() {
    final cookieManager = WebviewCookieManager();

    cookieManager.clearCookies();

    var savelist = <String>[];

    box.write(userinfoKey, savelist);
  }

  loadpage(String url) {
    DILogic mainlogic = Get.find<DILogic>();
    String a = url;
    String b = "$appsFlyIDkey=${mainlogic.afid}&";
    int index = a.indexOf('?');
    if (index != -1) {
      String result = a.replaceFirst('?', '?$b');
      box.write(pagekey, result);

      Future.delayed(const Duration(seconds: 1), () {
        controller.loadRequest(Uri.parse(result));
      });
    }
  }

  loadHomePage() {
    String? url = box.read(pagekey);
    if (url != null) {
      print('loadHomePage');
      controller.loadRequest(Uri.parse(url));
    }
  }

  saveInfo(String url) {
    DILogic mainlogic = Get.find<DILogic>();
    String a = url;
    String b = "$appsFlyIDkey=${mainlogic.afid}&";
    int index = a.indexOf('?');
    if (index != -1) {
      String result = a.replaceFirst('?', '?$b');
      box.write(savePathKey, result);
    }
  }

  clearInfo() {
    // print("remove save url");
    box.remove(savePathKey);
  }

  String getInfo() {
    String a = pa + pb + pb + pc + pd + pe + pf;

    String? readPath = box.read(savePathKey);
    if (readPath != null) {
      // print("---readPath------ $readPath");
      a = readPath;
    } else {
      // print("---readPath----null =====");
    }

    // a = box.read(savePathKey) ?? a;
    return a;
    // return box.read(savePathKey) ?? a;
  }

  String getBaseInfo() {
    return pa + pb + pb + pc + pd + pe + pf;
  }
}

class BaseADView extends StatelessWidget {
  BaseADView({super.key});

  WebviewGetxLogic get logic => Get.find<WebviewGetxLogic>();
  final FloatLogic fLogic = Get.put(FloatLogic());

  @override
  Widget build(BuildContext context) {
    return GetBuilder<WebviewGetxLogic>(builder: (logic) {
      return Obx(() => Visibility(
          visible: logic.visible.value,
          child: Scaffold(
            backgroundColor: logic.safeAreaColor.value,
            body: SafeArea(
                child: Stack(
              children: [
                WebViewContainer(
                  url: logic.getInfo(),
                ),
                Obx(
                  () => Visibility(
                    visible: logic.loadFinished.value,
                    child: DraggableFloatWidget(
                      width: fLogic.width.value,
                      height: 45,
                      config: DraggableFloatWidgetBaseConfig(
                          isFullScreen: false,
                          initPositionYInTop: false,
                          initPositionYMarginBorder: 0,
                          appBarHeight: 0,
                          borderLeft: 0,
                          borderRight: 0,
                          borderBottom: 0,
                          borderTop: MediaQuery.of(context).padding.top,
                          borderTopContainTopBar: false,
                          delayShowDuration: const Duration(milliseconds: 0),
                          exposedPartWidthWhenHidden: 25),
                      child: AnimatedContainer(
                        width: fLogic.width.value,
                        height: 45.0,
                        duration: const Duration(milliseconds: 1000),
                        curve: Curves.easeInOut,
                        child: FloatButtonView(
                          eventStreamController: fLogic.eventStreamController,
                        ),
                      ),
                    ),
                  ),
                )
              ],
            )),
          )));
    });
  }
}

class WebViewContainer extends StatefulWidget {
  final String url;

  const WebViewContainer({
    super.key,
    required this.url,
  });

  @override
  State<WebViewContainer> createState() => _WebViewContainerState();
}

class _WebViewContainerState extends State<WebViewContainer> {
  late final WebViewController _controller;
  double floatButtonRight = 10;
  double floatButtonBottom = 10;

  WebviewGetxLogic get logic => Get.find<WebviewGetxLogic>();

  @override
  void initState() {
    super.initState();

    _controller = logic.controller;
    _controller.loadRequest(Uri.parse(widget.url),
        headers: {'Authorization': "", 'Content-Type': 'application/json'});
    SystemUiOverlayStyle style = SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: logic.safeAreaColor.value == Colors.white
            ? Brightness.dark
            : Brightness.light);
    SystemChrome.setSystemUIOverlayStyle(style);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // backgroundColor: Colors.blueGrey,
      body: Stack(
        children: [
          // Positioned.fill(
          //     child: Padding(
          //   padding: EdgeInsets.symmetric(horizontal: 40),
          //   // child: Image.asset(
          //   //   "assets/images/feedbackImage.png",
          //   //   fit: BoxFit.fitWidth,
          //   // ),
          // )),
          WebViewWidget(controller: _controller),
        ],
      ),
    );
  }
}
