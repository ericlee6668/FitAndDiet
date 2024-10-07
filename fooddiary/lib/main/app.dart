// ignore_for_file: avoid_print

import 'package:app_tracking_transparency/app_tracking_transparency.dart';
import 'package:fit_track/main/themes/cus_font_size.dart';
import 'package:flex_color_scheme/flex_color_scheme.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:fit_track/main/init_guide_page.dart';

import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:fit_track/models/cus_app_localizations.dart';

import '../common/global/constants.dart';

import 'home_page.dart';

class FitTrackApp extends StatefulWidget {
  const FitTrackApp({super.key});

  @override
  State<FitTrackApp> createState() => _FitTrackAppState();
}

class _FitTrackAppState extends State<FitTrackApp> {
  @override
  void initState() {
    super.initState();
    // WidgetsFlutterBinding.ensureInitialized().addPostFrameCallback((_) => initPlugin());
  }
  Future<void> initPlugin() async {
    final TrackingStatus status =
    await AppTrackingTransparency.trackingAuthorizationStatus;
    // If the system can show an authorization request dialog
    if (status == TrackingStatus.notDetermined) {
      // Show a custom explainer dialog before the system dialog
      await showCustomTrackingDialog(context);
      // Wait for dialog popping animation
      await Future.delayed(const Duration(milliseconds: 200));
      // Request system's tracking authorization dialog
      final TrackingStatus status =
      await AppTrackingTransparency.requestTrackingAuthorization();
    }

  }
  Future<void> showCustomTrackingDialog(BuildContext context) async =>
      await SmartDialog.show(
          keepSingle: true,
          clickMaskDismiss: false,
          maskColor: Colors.black.withOpacity(0.8),
          builder: (BuildContext context) {
            return Container(

                width: 300.w,
                height: 300,
                decoration: BoxDecoration(   color: Colors.white,borderRadius: BorderRadius.circular(20)),
                padding: const EdgeInsets.all(10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      'Dear User',
                      style: TextStyle(color: Colors.black,fontSize: CusFontSizes.pageTitle,fontWeight: FontWeight.bold),
                    ),
                    const Text(
                      'We care about your privacy and data security. We keep this app free by showing ads. '
                          'Can we continue to use your data to tailor ads for you?\n\nYou can change your choice anytime in the app settings. '
                          'Our partners will collect data and use a unique identifier on your device to show you ads.',
                    ),
                    SizedBox(height: 20,),
                    TextButton(
                      onPressed: () => SmartDialog.dismiss(),
                      child: Text(
                        CusAL.of(context).confirmLabel,
                        style: TextStyle(fontSize: 18.sp),
                      ),
                    ),
                  ],
                ));
          });
  // 应用程序的根部件
  @override
  Widget build(BuildContext context) {
    print("getUserId---${box.read(LocalStorageKey.userId)}");
    print("language mode---${box.read('language')} ${box.read('mode')}");
    return ScreenUtilInit(
      designSize: const Size(360, 640), // 1080p / 3 ,单位dp
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (_, widget) {
        return CupertinoApp(
          title: 'EE88',
          onGenerateTitle: (context) {
            return CusAL.of(context).appTitle;
          },
          debugShowCheckedModeBanner: false,
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
            // form builder表单验证的多国语言
            FormBuilderLocalizations.delegate,
          ],
          supportedLocales: const [
            Locale('zh', 'CH'),
            Locale('en', 'US'),
            ...FormBuilderLocalizations.supportedLocales,
          ],
          // locale: null,
          // locale: const Locale('en'),

          locale: box.read('language') == 'system'
              ? null
              : Locale(box.read('language')),

          // 默认使用浅色主题，预设一个深色主题使用的预设值
          // 跟随系统的默认深色是一个material主题
          // darkTheme: FlexThemeData.light(scheme: FlexScheme.redM3,transparentStatusBar: true),

          /// 根据系统设置使用深色或浅色主题(当有完善的深色模式之后再启用)
          //android material风格
          // theme: box.read('mode') == 'system'
          //     // 跟随系统的默认浅色是一个绿色主题
          //     ? FlexThemeData.light(scheme: FlexScheme.brandBlue)
          //     : box.read('mode') == 'light'
          //         ? FlexThemeData.light(scheme: FlexScheme.brandBlue)
          //         : FlexThemeData.dark(scheme: FlexScheme.greyLaw),
          //ios Cupertino风格
          theme: CupertinoThemeData(
            brightness: box.read('mode') == 'light'
                ? Brightness.light
                : Brightness.dark,
            primaryColor: CupertinoColors.activeBlue,
          ),
          color: Colors.red,
          // 如果没有在缓存获取到用户信息，就要用户输入；否则就直接进入首页
          home: const HomePage(),
          builder: (context, child) {
            return FlutterSmartDialog(child: child);
          },
        );
      },
    );
  }
}
