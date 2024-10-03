// ignore_for_file: avoid_print

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../common/components/cus_cards.dart';
import '../../common/global/constants.dart';
import '../../models/cus_app_localizations.dart';
import 'exercise/index.dart';
import 'plans/index.dart';
import 'reports/index.dart';
import 'workouts/index.dart';

class TrainingPage extends StatefulWidget {
  const TrainingPage({super.key});

  @override
  State<TrainingPage> createState() => _TrainingState();
}

class _TrainingState extends State<TrainingPage> {
  @override
  void initState() {
    // 进入运动模块就获取存储授权(应该是启动app就需要这个请求)
    // _requestPermission();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    // 计算屏幕剩余的高度
    // 设备屏幕的总高度
    //  - 屏幕顶部的安全区域高度，即状态栏的高度
    //  - 屏幕底部的安全区域高度，即导航栏的高度或者虚拟按键的高度
    //  - 应用程序顶部的工具栏（如 AppBar）的高度
    //  - 应用程序底部的导航栏的高度
    //  - 组件的边框间隔(不一定就是2)
    double screenHeight = MediaQuery.of(context).size.height -
        MediaQuery.of(context).padding.top -
        MediaQuery.of(context).padding.bottom -
        kToolbarHeight -
        kBottomNavigationBarHeight -
        2 * 12.sp; // 减的越多，上下空隙越大

    return  buildFixedBody(screenHeight);
  }

  // 可视页面固定等分居中、不可滚动的首页
  buildFixedBody(double screenHeight) {
    return Center(
      child: GridView(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 1,
          childAspectRatio: 2

        ),

        children: [
          // SizedBox(
          //   height: screenHeight / 4,
          //   child: buildSmallCoverCard(
          //     context,
          //     const TrainingReports(),
          //     CusAL.of(context).report,
          //   ),
          // ),
          // buildCoverCard(
          //   context,
          //   const TrainingReports(),
          //   CusAL.of(context).trainingReports,
          //   CusAL.of(context).trainingReportsSubtitle,
          //   reportImageUrl,
          // ),
          buildCardContainer2(
            context,
            const TrainingExercise(),
            CusAL.of(context).exerciseLabel,
            CusAL.of(context).exerciseSubtitle,
            workoutWoman,
          ),
          buildCardContainer2(
            context,
            const TrainingWorkouts(),
            CusAL.of(context).workout,
            CusAL.of(context).workoutSubtitle,
            workoutMan,
          ),
          buildCardContainer2(
            context,
            const TrainingPlans(),
            CusAL.of(context).plan,
            CusAL.of(context).planSubtitle,
            exercisePlan,
          ),
        ],
      ),
    );
  }
}

