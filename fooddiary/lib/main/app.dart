// ignore_for_file: avoid_print

import 'package:flex_color_scheme/flex_color_scheme.dart';
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
        return MaterialApp(
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
          darkTheme: FlexThemeData.dark(scheme: FlexScheme.material,transparentStatusBar: false),

          /// 根据系统设置使用深色或浅色主题(当有完善的深色模式之后再启用)
          theme: box.read('mode') == 'system'
              // 跟随系统的默认浅色是一个绿色主题
              ? FlexThemeData.dark(scheme: FlexScheme.cyanM3)
              : box.read('mode') == 'dark'
                  ? FlexThemeData.dark(scheme: FlexScheme.cyanM3)
                  : FlexThemeData.light(scheme: FlexScheme.greyLaw),

          // 如果没有在缓存获取到用户信息，就要用户输入；否则就直接进入首页
          home: const HomePage(),
          builder: (context,child){
            return FlutterSmartDialog(child: child);
          },
        );
      },
    );
  }
}
