import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../common/global/constants.dart';
import '../../../main/app.dart';
// import '../../../layout/themes/cus_font_size.dart';
import '../../../models/cus_app_localizations.dart';

class MoreSettings extends StatefulWidget {
  const MoreSettings({super.key});

  @override
  State<MoreSettings> createState() => _MoreSettingsState();
}

class _MoreSettingsState extends State<MoreSettings> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(CusAL.of(context).moreSettings),
      ),
      body: ListView(
        children: [
          SizedBox(height: 10.sp),
          ExpansionTile(
            title: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(CusAL.of(context).languageSetting),
                Text(
                  box.read("language") == "zh"
                      ? "简体中文"
                      : box.read("language") == "en"
                          ? "English"
                          : CusAL.of(context).followSystem,
                ),
              ],
            ),
            children: [
              _buildLanguageListItem(
                CusAL.of(context).followSystem,
                'system',
              ),
              _buildLanguageListItem('简体中文', 'zh'),
              _buildLanguageListItem('English', 'en'),
            ],
          ),
          // SizedBox(height: 10.sp),
          // ExpansionTile(
          //   title: Row(
          //     mainAxisAlignment: MainAxisAlignment.spaceBetween,
          //     children: [
          //       Text(CusAL.of(context).themeSetting),
          //       Text(
          //         box.read("mode") == "dark"
          //             ? CusAL.of(context).darkMode
          //             : box.read("mode") == "light"
          //                 ? CusAL.of(context).lightMode
          //                 : CusAL.of(context).followSystem,
          //       ),
          //     ],
          //   ),
          //   children: [
          //     _buildModeListItem(
          //       const Icon(Icons.sync),
          //       CusAL.of(context).followSystem,
          //       'system',
          //     ),
          //     _buildModeListItem(
          //       const Icon(Icons.wb_sunny_outlined),
          //       CusAL.of(context).darkMode,
          //       'dark',
          //     ),
          //     _buildModeListItem(
          //       const Icon(Icons.brightness_2),
          //       CusAL.of(context).lightMode,
          //       'light',
          //     ),
          //   ],
          // ),

          ListTile(
            title: Text(CusAL.of(context).appNote),
            trailing: const Icon(Icons.info_outlined),
            onTap: (){
              showCupertinoDialog(
                context: context,
                builder: (BuildContext context)
              {
                return CupertinoAlertDialog(
                  title: const Text('Notice'),
                  content: const Text(textAlign: TextAlign.justify,'EE88 FitTrack is a highly customizable fitness and diet management application designed to provide users with personalized health solutions. Users can flexibly adjust their fitness plans and dietary recommendations according to their individual needs and goals to achieve optimal health results. The app allows users to create detailed personal profiles, including weight, height, fitness goals, and dietary preferences. Users can monitor their fitness progress, nutritional intake, and habit changes in real time through highly customized fitness and dietary plans. With these highly tailored features, EE88 FitTrack aims to help each user find the best way to pursue health on their journey.'),
                  actions: <Widget>[
                    CupertinoDialogAction(
                      isDefaultAction: true,
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      child: const Text('OK'),
                    ),

                  ],
                );
              });
            },
            // onTap: () {
            //   showAboutDialog(
            //     context: context,
            //     applicationName: 'Free Fitness',
            //     children: [
            //       const Row(
            //         mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            //         children: [
            //           Expanded(flex: 1, child: Text("Author")),
            //           Expanded(flex: 3, child: Text("SanotSu")),
            //         ],
            //       ),
            //       Row(
            //         mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            //         children: [
            //           const Expanded(flex: 1, child: Text("Email")),
            //           Expanded(
            //             flex: 3,
            //             child: Text(
            //               "callmedavidsu@gmail.com",
            //               style: TextStyle(fontSize: 13.sp),
            //             ),
            //           ),
            //         ],
            //       ),
            //       SizedBox(height: 20.sp),
            //       Text(
            //         "Not for commercial use.",
            //         style: TextStyle(fontSize: 20.sp, color: Colors.blue),
            //       ),
            //     ],
            //   );
            // },
          ),

          // SizedBox(height: 10.sp),
          // ListTile(
          //   leading: const Icon(Icons.description),
          //   title: Text(
          //     "${CusAL.of(context).userGuide}(todo)",
          //     style: TextStyle(
          //       fontSize: CusFontSizes.pageSubTitle,
          //       fontWeight: FontWeight.bold,
          //       color: Theme.of(context).primaryColor,
          //     ),
          //   ),
          //   onTap: null,
          // ),
          // SizedBox(height: 10.sp),
          // ListTile(
          //   leading: const Icon(Icons.question_answer),
          //   title: Text(
          //     "${CusAL.of(context).questionAndAnswer}(todo)",
          //     style: TextStyle(
          //       fontSize: CusFontSizes.pageSubTitle,
          //       fontWeight: FontWeight.bold,
          //       color: Theme.of(context).primaryColor,
          //     ),
          //   ),
          //   onTap: null,
          // ),
        ],
      ),
    );
  }

  Widget _buildLanguageListItem(String text, String value) {
    return Container(
      padding: EdgeInsets.only(left: 15.sp, right: 15.sp, top: 0, bottom: 0),
      child: ListTile(
        leading: const Icon(Icons.drag_handle),
        title: Container(
          // 缩小 leading 和 title之的间隔
          transform: Matrix4.translationValues(-20, 0.0, 0.0),
          child: Text(text),
        ),
        trailing: value == box.read("language") ? const Icon(Icons.done) : null,
        onTap: () async {
          await box.write('language', value);
          if (!mounted) return;
          _reloadApp(context);
        },
      ),
    );
  }

  Widget _buildModeListItem(Icon icon, String text, String value) {
    return Container(
      padding: EdgeInsets.only(left: 15.sp, right: 15.sp, top: 0, bottom: 0),
      child: ListTile(
        leading: icon,
        title: Container(
          // 缩小 leading 和 title之的间隔
          transform: Matrix4.translationValues(-20, 0.0, 0.0),
          child: Text(text),
        ),
        trailing: value == box.read("mode") ? const Icon(Icons.done) : null,
        onTap: () async {
          await box.write('mode', value);
          if (!mounted) return;
          _reloadApp(context);
        },
      ),
    );
  }

  // 重新加载应用程序以更新UI
  void _reloadApp(BuildContext context) {
    // ???2024-07-12 这里有问题，新版本在切换语言后重载，会出现OnBackInvokedCallback is not enabled for the application.
    // 即便已经在manifest文件进行配置了，现象类似：https://github.com/flutter/flutter/issues/146132
    // 这会导致在连续的pop 例如Navigator.of(context)..pop()..pop();
    //    或者两个Navigator.of(context).pop();Navigator.of(context).pop(); 的地方出现白屏，找不到路径的现象
    // 暂未解决
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const FitTrackApp()),
      (route) => false,
    );
  }
}
