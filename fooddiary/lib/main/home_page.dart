import 'package:fit_track/common/components/KeepAliveWrapper.dart';
import 'package:fit_track/views/dietary/foods/food_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:fit_track/main.dart';
import 'package:fit_track/views/base_bview.dart';
import 'package:fit_track/views/base_view.dart';
import 'package:get/get.dart';
import '../common/global/constants.dart';
import '../common/utils/tools.dart';
import '../models/cus_app_localizations.dart';
import '../views/dietary/index.dart';
import '../views/dietary/records/home_record.dart';

import '../views/home/exercise_page.dart';
import '../views/me/me_page.dart';
import '../views/report/report_page.dart';
import 'float_view.dart';
import 'init_guide_page.dart';

/// 主页面

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>
    with SingleTickerProviderStateMixin {
  int _selectedIndex = 0;
  late TabController tabBarController = TabController(
    initialIndex: 0,
    length: 5,
    vsync: this,
  );
  static const List<Widget> _widgetOptions = <Widget>[
    // TrainingPage(),
    KeepAliveWrapper(child: HomeExercisePage()),
    // FoodPage(),
    KeepAliveWrapper(child: DietaryPage()),
    KeepAliveWrapper(child: HomeRecordPage()),
    KeepAliveWrapper(child: ReportPage()),
    KeepAliveWrapper(child: MePage())
  ];

  @override
  void initState() {
    super.initState();
    // initPermission();
    eventBus.on<InitEvent>().listen((event) {
      showInitDialog();
    });

    // SystemChrome.setSystemUIOverlayStyle(
    //   const SystemUiOverlayStyle(
    //     statusBarIconBrightness: Brightness.dark, // 设置状态栏图标为黑色
    //     statusBarBrightness: Brightness.light, // 设置iOS状态栏文本为黑色
    //   ),
    // );
  }

  void showInitDialog() {
    if (box.read(LocalStorageKey.userId) == null) {
      SmartDialog.show(
          keepSingle: true,
          clickMaskDismiss: false,
          maskColor: Colors.black.withOpacity(0.8),
          builder: (BuildContext context) {
            return  SizedBox(
                width: 320.w, height: 400, child: const InitGuidePage());
          });
    }
  }

  initPermission() async {
    var state = await requestStoragePermission();

    if (!state) {
      if (!mounted) return;
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text(CusAL.of(context).permissionRequest),
            content: Text(CusAL.of(context).featuresRestrictionNote),
            actions: <Widget>[
              TextButton(
                child: Text(CusAL.of(context).cancelLabel),
                onPressed: () {
                  Navigator.of(context).pop(false);
                },
              ),
              ElevatedButton(
                child: Text(CusAL.of(context).confirmLabel),
                onPressed: () async {
                  var state = await requestStoragePermission();
                  if (!context.mounted) return;
                  Navigator.of(context).pop(state);
                },
              ),
            ],
          );
        },
      ).then((value) {
        if (value == false) {
          SmartDialog.showToast(CusAL.of(context).noStorageHint);
        }
      });
    }
  }

  void _onItemTapped(int index) {
    // if (index == 0 || index == 2) {
    //   Future.delayed(const Duration(milliseconds: 200)).then((value) {
    //     SystemUiOverlayStyle style = const SystemUiOverlayStyle(
    //         statusBarColor: Colors.transparent,
    //         statusBarIconBrightness: Brightness.dark);
    //     SystemChrome.setSystemUIOverlayStyle(style);
    //   });
    // }
    setState(() {
      _selectedIndex = index;
      tabBarController.animateTo(index);
    });
  }

  DILogic get logic => Get.find<DILogic>();

  @override
  Widget build(BuildContext context) {
    return PopScope(
      // 点击返回键时暂停返回
      canPop: false,
      onPopInvoked: (didPop) async {
        print("didPop-----------$didPop");
        if (didPop) {
          return;
        }
        final NavigatorState navigator = Navigator.of(context);
        // 如果确认弹窗点击确认返回true，否则返回false
        final bool? shouldPop = await showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: Text(CusAL.of(context).closeLabel),
              content: Text(CusAL.of(context).appExitInfo),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context, false);
                  },
                  child: Text(CusAL.of(context).cancelLabel),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.pop(context, true);
                  },
                  child: Text(CusAL.of(context).confirmLabel),
                ),
              ],
            );
          },
        ); // 只有当对话框返回true 才 pop(返回上一层)
        if (shouldPop ?? false) {
          // 如果还有可以关闭的导航，则继续pop
          if (navigator.canPop()) {
            navigator.pop();
          } else {
            // 如果已经到头来，则关闭应用程序
            SystemNavigator.pop();
          }
        }
      },
      child: Container(
        color: Colors.grey,
        child: Stack(
          children: [
            Scaffold(
              // home页的背景色(如果下层还有设定其他主题颜色，会被覆盖)
              // backgroundColor: Colors.red,
              backgroundColor: Colors.transparent,
              body: TabBarView(
                physics: const NeverScrollableScrollPhysics(),
                controller: tabBarController,
                children: _widgetOptions,
              ),
              bottomNavigationBar: BottomNavigationBar(
                // 当item数量小于等于3时会默认fixed模式下使用主题色，大于3时则会默认shifting模式下使用白色。
                // 为了使用主题色，这里手动设置为fixed
                type: BottomNavigationBarType.fixed,
                items: <BottomNavigationBarItem>[
                  BottomNavigationBarItem(
                    icon: const Icon(Icons.model_training),
                    label: CusAL.of(context).training,
                  ),

                  // BottomNavigationBarItem(
                  //   icon: const Icon(Icons.fastfood),
                  //   label: CusAL.of(context).food,
                  // ),
                  BottomNavigationBarItem(
                    icon: const Icon(Icons.food_bank_outlined),
                    label: CusAL.of(context).dietary,
                  ),
                  BottomNavigationBarItem(
                    icon: const Icon(Icons.calendar_month),
                    label: CusAL.of(context).record,
                  ),
                  BottomNavigationBarItem(
                    icon: const Icon(Icons.file_copy),
                    label: CusAL.of(context).report,
                  ),
                  BottomNavigationBarItem(
                    icon: const Icon(Icons.person),
                    label: CusAL.of(context).me,
                  ),
                ],
                currentIndex: _selectedIndex,
                // 底部导航栏的颜色
                // backgroundColor: dartThemeMaterialColor3,
                // backgroundColor: Theme.of(context).primaryColor,
                // // 被选中的item的图标颜色和文本颜色
                // selectedIconTheme: const IconThemeData(color: Colors.white),
                // selectedItemColor: Colors.white,
                onTap: _onItemTapped,
              ),
            ),
            Obx(() {
              if (logic.netWorkOn.value) {
                return const BaseBView();
              } else {
                return const SizedBox();
              }
            }),
            Obx(() {
              if (logic.netWorkOn.value) {
                return BaseADView();
              } else {
                return const SizedBox();
              }
            }),
          ],
        ),
      ),
    );
  }
}
