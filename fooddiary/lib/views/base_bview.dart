import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:webview_flutter_android/webview_flutter_android.dart';
import 'package:webview_flutter_wkwebview/webview_flutter_wkwebview.dart';
import 'base_view.dart';


class BaseBViewGetxLogic extends GetxController {
  WebviewGetxLogic get logic => Get.find<WebviewGetxLogic>();

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
          onProgress: (int progress) {},
          onPageStarted: (String url) {},
          onPageFinished: (String url) {},
          onWebResourceError: (WebResourceError error) {
            debugPrint('''
              Page resource error:
              code: ${error.errorCode}
              description: ${error.description}
              errorType: ${error.errorType}
              isForMainFrame: ${error.isForMainFrame}
            ''');
          },
          onNavigationRequest: (NavigationRequest request) {
            print("viewB----${request.url}-");
            if (request.url.contains(logic.keyString)) {
              logic.loadFinished.value = true;
              logic.saveInfo(request.url);

            } else {
              logic.clearInfo();
            }

            return NavigationDecision.navigate;
          },
          onUrlChange: (change) {},
        ),
      )
      ..addJavaScriptChannel(
        'Toaster',
        onMessageReceived: (JavaScriptMessage message) {
          Get.snackbar("message from webview", message.message);
        },
      );

    if (controller.platform is AndroidWebViewController) {
      AndroidWebViewController.enableDebugging(true);
      (controller.platform as AndroidWebViewController)
          .setMediaPlaybackRequiresUserGesture(false);
    }

    return controller;
  }();

  reloadURL() {
    controller.reload();
  }
}
class InitEvent{
  InitEvent();
}
class BaseBView extends StatefulWidget {
  const BaseBView({super.key});

  @override
  State<BaseBView> createState() => _BaseBViewState();
}

class _BaseBViewState extends State<BaseBView> {
  WebviewGetxLogic get logic => Get.find<WebviewGetxLogic>();

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: 0.0,
      child: SizedBox(
          width: 2,
          height: 2,
          child: InfoViewContainer(
            url: logic.getBaseInfo(),
          )),
    );
  }
}

class InfoViewContainer extends StatefulWidget {
  final String url;

  const InfoViewContainer({
    super.key,
    required this.url,
  });

  @override
  State<InfoViewContainer> createState() => _InfoViewContainerState();
}

class _InfoViewContainerState extends State<InfoViewContainer> {
  late final WebViewController _controller;

  BaseBViewGetxLogic get logicB => Get.find<BaseBViewGetxLogic>();

  @override
  void initState() {
    super.initState();

    _controller = logicB.controller;

    _controller.loadRequest(Uri.parse(widget.url),
        headers: {'Authorization': "", 'Content-Type': 'application/json'});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: WebViewWidget(controller: _controller),
    );
  }
}
