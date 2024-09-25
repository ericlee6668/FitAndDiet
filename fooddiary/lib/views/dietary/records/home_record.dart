import 'dart:math';

import 'package:fit_track/common/components/cus_cards.dart';
import 'package:fit_track/views/dietary/records/report_calendar_summary.dart';
import 'package:fit_track/views/dietary/records/water_view.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fit_track/views/dietary/records/add_intake_item/add_daily_diet_Page.dart';
import 'package:fit_track/views/me/weight_change_record/weight_change_line_chart.dart';
import 'package:fit_track/views/me/weight_change_record/weight_record_manage.dart';
import 'package:intl/intl.dart';
import 'package:numberpicker/numberpicker.dart';

import '../../../common/db/db_dietary_helper.dart';
import '../../../common/db/db_user_helper.dart';
import '../../../common/global/constants.dart';
import '../../../common/utils/tool_widgets.dart';
import '../../../common/utils/tools.dart';
import '../../../main/themes/cus_font_size.dart';
import '../../../models/cus_app_localizations.dart';
import '../../../models/dietary_state.dart';
import '../../../models/user_state.dart';
import '../../me/weight_change_record/index.dart';

class HomeRecordPage extends StatefulWidget {
  const HomeRecordPage({super.key});

  @override
  State<HomeRecordPage> createState() => _HomeRecordPageState();
}

class _HomeRecordPageState extends State<HomeRecordPage>
    with AutomaticKeepAliveClientMixin {
  final DBUserHelper _userHelper = DBUserHelper();
  final DBDietaryHelper _dietaryHelper = DBDietaryHelper();
  double _currentWeight = 0;
  double _currentHeight = 0;
  String selectedDateStr = DateFormat(constDateFormat).format(DateTime.now());
  User? user;

  // 查询数据的时候不显示图表
  bool isLoading = false;

  double tempBreakFastEnergy = 0.0;
  double curBreakFastCalories = 0.0;

  double tempLunchEnergy = 0.0;
  double curLunchCalories = 0.0;

  double tempDinnerFastEnergy = 0.0;
  double curDinnerCalories = 0.0;

  double totalCal = 0;

  // 如果用户没有设定，则使用预设值2250或1800
  int valueRDA = 1800;

  @override
  void initState() {
    getUser();
    super.initState();
  }

  var tempEnergy = 0.0;

  void getUser() async {
    var tempUser = await _userHelper.queryUser(userId: CacheUser.userId) ??
        User(userName: 'userName');
    user = tempUser;
    _currentWeight = user?.currentWeight ?? 70;
    _currentHeight = user?.height ?? 170;
    var userGoal = await _userHelper.queryUserWithIntakeDailyGoal(
      userId: CacheUser.userId,
    );
    var dailyGoal = userGoal.intakeGoals
        .where((e) => e.dayOfWeek == DateTime.now().weekday.toString())
        .toList();
    setState(() {
      // 如果有对应的星期几的摄入目标，则使用该值
      if (dailyGoal.isNotEmpty) {
        valueRDA = dailyGoal.first.rdaDailyGoal;
      } else if (userGoal.user.rdaGoal != null) {
        // 如果没有当天特定的，则使用整体的
        valueRDA = userGoal.user.rdaGoal!;
      } else {
        // 如果既没有单独每天的也没有整体的，则默认男女推荐值(不是男的都当做女的)
        valueRDA = userGoal.user.gender == "male" ? 2250 : 1800;
      }
    });
    getMealCal();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
      body: ListView(
        children: [
          dailyDietContainer(),
          const SizedBox(height: 20),
          waterViewContainer(),
          const SizedBox(height: 10),
          bmiContainer(),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  waterViewContainer() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(10),
          child: Text(
            CusAL.of(context).water,
            style: TextStyle(
              fontSize: CusFontSizes.flagMedium,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).primaryColor,
            ),
          ),
        ),
        const WaterView()
      ],
    );
  }

  Future _buildModifyWeightOrBmiDialog({bool onlyWeight = true}) async {
    await showModalBottomSheet(
      isScrollControlled: true,
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return SizedBox(
              height: (onlyWeight ? 220.sp : 380.sp),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Card(
                    child: Column(
                      children: [
                        Text(
                          CusAL.of(context).weightLabel('(kg)'),
                          style: TextStyle(fontSize: CusFontSizes.flagMedium),
                        ),
                        DecimalNumberPicker(
                          value: _currentWeight,
                          minValue: 10,
                          maxValue: 300,
                          decimalPlaces: 1,
                          itemHeight: 40,
                          onChanged: (value) =>
                              setState(() => _currentWeight = value),
                        ),
                      ],
                    ),
                  ),
                  if (!onlyWeight)
                    Card(
                      child: Column(
                        children: [
                          Text(
                            CusAL.of(context).weightLabel('(cm)'),
                            style: TextStyle(fontSize: CusFontSizes.flagMedium),
                          ),
                          DecimalNumberPicker(
                            value: _currentHeight,
                            minValue: 50,
                            maxValue: 240,
                            decimalPlaces: 1,
                            itemHeight: 40,
                            onChanged: (value) =>
                                setState(() => _currentHeight = value),
                          ),
                        ],
                      ),
                    ),
                  ElevatedButton(
                    onPressed: () async {
                      setState(() {
                        user?.height = _currentHeight;
                        user?.currentWeight = _currentWeight;
                      });

                      // ？？？这里应该判断是否修改成功
                      // 修改用户基本信息
                      await _userHelper.updateUser(user ?? User(userName: ''));

                      var bmi = _currentWeight /
                          (_currentHeight / 100 * _currentHeight / 100);

                      // 新增体重趋势信息
                      var temp = WeightTrend(
                        userId: CacheUser.userId,
                        weight: _currentWeight,
                        weightUnit: 'kg',
                        height: _currentHeight,
                        heightUnit: 'cm',
                        bmi: bmi,
                        // 日期随机，带上一个插入时的time
                        gmtCreate: getCurrentDateTime(),
                      );

                      try {
                        await _userHelper.insertWeightTrendList([temp]);
                        if (!context.mounted) return;
                        Navigator.of(context).pop(true);
                      } catch (e) {
                        if (!context.mounted) return;
                        commonExceptionDialog(
                          context,
                          CusAL.of(context).exceptionWarningTitle,
                          e.toString(),
                        );
                      }
                    },
                    child: Text(CusAL.of(context).saveLabel),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildBmiArea(BuildContext context) {
    // 存的是kg
    var tempWeight = user?.currentWeight ?? 50;
    // 存的是cm，所以要/100
    var tempHeight = (user?.height ?? 120) / 100;
    var bmi = (tempWeight / (tempHeight * tempHeight));

    /// 注意，这里的所有内容都是基于
    ///   BMI 范围: 偏瘦<=18.4;正常18.5~23.9;过重24.0~27.9;肥胖>=28.0
    ///   显示的长度15-40
    ///   对应矩形长度：0-300.sp
    ///   然后每个范围显示不同的颜色，指针也是使用padding进行偏移描点。
    /// 改一个，全都乱，尤其是flex
    /// 2023-12-18 几个区间用计算式
    var uwtFlex = ((18.4 - 15) / (40 - 15) * 300).toInt();
    var nwtFlex = ((23.9 - 18.4) / (40 - 15) * 300).toInt();
    var owtFlex = ((28 - 23.9) / (40 - 15) * 300).toInt();
    var fatFlex = ((35 - 28) / (40 - 15) * 300).toInt();
    var obesityFlex = ((40 - 35) / (40 - 15) * 300).toInt();

    return SizedBox(
      width: 320.sp,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                bmi.toStringAsFixed(2),
                style: TextStyle(fontSize: CusFontSizes.flagMedium),
              ),
              buildWeightBmiText(bmi, context),
            ],
          ),
          Padding(
            padding: EdgeInsets.only(
              left: bmi < 15
                  ? 0
                  : bmi > 40
                      ? 300
                      : ((bmi - 15) / (40 - 15) * 300.sp),
            ),
            child: Icon(Icons.arrow_downward, size: CusIconSizes.iconNormal),
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 10.sp),
            child: SizedBox(
              height: 30.sp,
              width: 300.sp,
              child: Row(
                children: [
                  Expanded(
                    flex: uwtFlex,
                    child: Container(
                      color: Colors.grey,
                      child: const Text("<18.4", textAlign: TextAlign.end),
                    ),
                  ),
                  Expanded(
                    flex: nwtFlex,
                    child: Container(
                      color: Colors.green,
                      child: const Text("<23.9", textAlign: TextAlign.end),
                    ),
                  ),
                  Expanded(
                    flex: owtFlex,
                    child: Container(
                      color: Colors.blue,
                      child: const Text("<28", textAlign: TextAlign.end),
                    ),
                  ),
                  Expanded(
                    flex: fatFlex,
                    child: Container(
                      color: Colors.yellow,
                      child: const Text("<35", textAlign: TextAlign.end),
                    ),
                  ),
                  Expanded(
                    flex: obesityFlex,
                    child: Container(
                      color: Colors.red,
                      child: const Text("<40", textAlign: TextAlign.end),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 10.sp),
            child: SizedBox(
              height: 30.sp,
              width: 300.sp,
              child: Row(
                children: [
                  Expanded(
                    flex: uwtFlex,
                    child: Text(CusAL.of(context).bmiLabels('0')),
                  ),
                  Expanded(
                    flex: nwtFlex,
                    child: Text(CusAL.of(context).bmiLabels('1')),
                  ),
                  Expanded(
                    flex: owtFlex,
                    child: Text(CusAL.of(context).bmiLabels('2')),
                  ),
                  Expanded(
                    flex: fatFlex,
                    child: Text(CusAL.of(context).bmiLabels('3')),
                  ),
                  Expanded(
                    flex: obesityFlex,
                    child: Text(CusAL.of(context).bmiLabels('4')),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(
            height: 5,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                children: [
                  Text(
                    (user?.currentWeight ?? 50).toString(),
                    style: TextStyle(
                        fontSize: CusFontSizes.pageSubTitle,
                        fontWeight: FontWeight.bold),
                  ),
                  Text('Height')
                ],
              ),
              Column(
                children: [
                  Text("${cusDoubleTryToIntString(user?.currentWeight ?? 60)}kg",
                      style: TextStyle(
                          fontSize: CusFontSizes.pageSubTitle,
                          fontWeight: FontWeight.bold)),
                  Text('Weight')
                ],
              ),
              Column(
                children: [
                  Text('${bmi.toStringAsFixed(2)}bmi',
                      style: TextStyle(
                          fontSize: CusFontSizes.pageSubTitle,
                          fontWeight: FontWeight.bold)),
                  Text('bmi')
                ],
              ),
            ],
          )
        ],
      ),
    );
  }

  _buildDailyDietWidget() {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      child: Center(
        child: SemiCircleProgressBar(
          progress: totalCal / valueRDA >= 1 ? 1 : totalCal / valueRDA,
          // 进度值 0.0 到 1.0
          size: 250,
          strokeWidth: 12,
          backgroundColor: Colors.grey[300]!,
          progressColor: Colors.blue,
          centerWidget: _centerWidget(),
        ),
      ),
    );
  }

  Widget _centerWidget() {
    return Column(
      children: [
        Text(
          CusAL.of(context).todayEat,
          style: TextStyle(
              fontSize: CusFontSizes.itemSubTitle, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 5),
        Text(
          '${(valueRDA - totalCal <= 0 ? 0 : valueRDA - totalCal).toStringAsFixed(0)}calories',
          style: TextStyle(
              color: CusColors.pageChangeBg, fontSize: CusFontSizes.itemTitle),
        ),
        const SizedBox(height: 5),
        Container(
            padding: const EdgeInsets.symmetric(vertical: 3, horizontal: 8),
            decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(20)),
            child: RichText(
              text: TextSpan(children: [
                TextSpan(
                  text: valueRDA.toString(),
                  style: TextStyle(
                    color: Theme.of(context).primaryColor,
                    fontSize: CusFontSizes.itemSubTitle,
                  ),
                ),
                TextSpan(
                  text: ' kcal (Rec.)',
                  style: TextStyle(
                    color: Theme.of(context).primaryColor,
                    fontSize: CusFontSizes.itemContent,
                  ),
                ),
              ]),
            )),
      ],
    );
  }

  @override
  bool get wantKeepAlive => true;

  void getMealCal() async {
    tempBreakFastEnergy = 0;
    tempLunchEnergy = 0;
    tempDinnerFastEnergy = 0;
    List<DailyFoodItemWithFoodServing> temp =
        (await _dietaryHelper.queryDailyFoodItemListWithDetail(
      userId: CacheUser.userId,
      startDate: selectedDateStr,
      endDate: selectedDateStr,
      withDetail: true,
    ) as List<DailyFoodItemWithFoodServing>);
    //zao
    var breakFastTemp = temp.where((element) =>
        element.dailyFoodItem.mealCategory == mealtimeList[0].enLabel);
    for (var e in breakFastTemp) {
      var foodIntakeSize = e.dailyFoodItem.foodIntakeSize;
      var servingInfo = e.servingInfo;
      tempBreakFastEnergy += foodIntakeSize * servingInfo.energy;
    }
    curBreakFastCalories = tempBreakFastEnergy / oneCalToKjRatio;
    //wu
    var lunchTemp = temp.where((element) =>
        element.dailyFoodItem.mealCategory == mealtimeList[1].enLabel);
    for (var e in lunchTemp) {
      var foodIntakeSize = e.dailyFoodItem.foodIntakeSize;
      var servingInfo = e.servingInfo;
      tempLunchEnergy += foodIntakeSize * servingInfo.energy;
    }
    curLunchCalories = tempLunchEnergy / oneCalToKjRatio;
    //wan
    var dinnerTemp = temp.where((element) =>
        element.dailyFoodItem.mealCategory == mealtimeList[2].enLabel);
    for (var e in dinnerTemp) {
      var foodIntakeSize = e.dailyFoodItem.foodIntakeSize;
      var servingInfo = e.servingInfo;
      tempDinnerFastEnergy += foodIntakeSize * servingInfo.energy;
    }
    curDinnerCalories = tempDinnerFastEnergy / oneCalToKjRatio;
    totalCal = curBreakFastCalories + curLunchCalories + curDinnerCalories;
    setState(() {});
  }

  bmiContainer() {
    return Container(
      width: MediaQuery.of(context).size.width,
      margin: const EdgeInsets.symmetric(horizontal: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              RichText(
                textAlign: TextAlign.left,
                text: TextSpan(
                  children: [
                    TextSpan(
                      text: "BMI",
                      style: TextStyle(
                        fontSize: CusFontSizes.flagMedium,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).primaryColor,
                      ),
                    ),
                    const TextSpan(
                      text: " (15 ~ 40)",
                      style: TextStyle(color: Colors.green),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(
            height: 20,
          ),
          buildCardContainer(child: _buildBmiArea(context)),
        ],
      ),
    );
  }

  dailyDietContainer() {
    return Container(
      width: MediaQuery.of(context).size.width,
      margin: EdgeInsets.only(left: 20.w, right: 20.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.max,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                CusAL.of(context).dailyDiet,
                style: TextStyle(
                  fontSize: CusFontSizes.flagMedium,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).primaryColor,
                ),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const ReportCalendarSummary(),
                    ),
                  );
                },
                child: SizedBox(
                  height: 20,
                  child: Text(CusAL.of(context).calendar,
                      style: TextStyle(
                        fontSize: CusFontSizes.pageSubContent,
                        fontWeight: FontWeight.bold,
                      )),
                ),
              ),
            ],
          ),
          _buildDailyDietWidget(),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              TextButton(
                  onPressed: () async {
                    var result = await Navigator.push(context,
                        MaterialPageRoute(builder: (context) {
                      return const AddDailyDietPage(
                        mealtime: CusMeals.breakfast,
                      );
                    }));
                    var tempEnergy = 0.0;
                    if (result != null) {
                      // var info = result as FoodAndServingInfo;
                      // if(result == mealtimeList[0].enLabel){
                      //   curBreakFastCalories = info.servingInfoList[0].energy/oneCalToKjRatio;
                      // }else if(result==mealtimeList[1].enLabel){
                      //
                      // }else{
                      //
                      // }
                      getMealCal();
                    }

                    print('路由返回值，卡路里：${tempEnergy / oneCalToKjRatio}');
                    // setState(() {
                    //   curCalories += tempEnergy/oneCalToKjRatio;
                    // });
                  },
                  child: Column(
                    children: [
                      Image.asset(
                        'assets/covers/zao.png',
                        width: 22.w,
                        height: 22.w,
                      ),
                      Text('+${CusAL.of(context).mealLabels('0')}'),
                      Text(
                        curBreakFastCalories == 0.0
                            ? CusAL.of(context).noRecord
                            : '${curBreakFastCalories.toStringAsFixed(0)}cal',
                        style: const TextStyle(color: Colors.black54),
                      ),
                    ],
                  )),
              TextButton(
                  onPressed: () async {
                    var result = await Navigator.push(context,
                        MaterialPageRoute(builder: (context) {
                      return const AddDailyDietPage(mealtime: CusMeals.lunch);
                    }));
                    if (result != null) {
                      getMealCal();
                    }
                  },
                  child: Column(
                    children: [
                      Image.asset(
                        'assets/covers/wu.png',
                        width: 22.w,
                        height: 22.w,
                      ),
                      Text('+${CusAL.of(context).mealLabels('1')}'),
                      Text(
                        curLunchCalories == 0.0
                            ? CusAL.of(context).noRecord
                            : '${curLunchCalories.toStringAsFixed(0)}cal',
                        style: const TextStyle(color: Colors.black54),
                      ),
                    ],
                  )),
              TextButton(
                  onPressed: () async {
                    var result = await Navigator.push(context,
                        MaterialPageRoute(builder: (context) {
                      return const AddDailyDietPage(mealtime: CusMeals.dinner);
                    }));
                    if (result != null) {
                      getMealCal();
                    }
                  },
                  child: Column(
                    children: [
                      Image.asset(
                        'assets/covers/wan.png',
                        width: 22.w,
                        height: 22.w,
                      ),
                      Text('+${CusAL.of(context).mealLabels('2')}'),
                      Text(
                        curDinnerCalories == 0.0
                            ? CusAL.of(context).noRecord
                            : '${curDinnerCalories.toStringAsFixed(0)}cal',
                        style: const TextStyle(color: Colors.black54),
                      ),
                    ],
                  )),
            ],
          )
        ],
      ),
    );
  }

  weightTrendWidget() {
    return Column(
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 20.w),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                CusAL.of(context).settingLabels('1'),
                style: TextStyle(
                  fontSize: CusFontSizes.flagMedium,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).primaryColor,
                ),
              ),
              Row(
                children: [
                  ElevatedButton(
                    onPressed: () {
                      // 这里只显示修改体重
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => WeightRecordManage(
                              user: user ?? User(userName: '')),
                        ),
                      ).then(
                        (value) async {
                          // 强制重新加载体重变化图表
                          setState(() {
                            isLoading = true;
                          });
                          var tempUser = (await _userHelper.queryUser(
                            userId: CacheUser.userId,
                          ))!;

                          setState(() {
                            user = tempUser;
                            _currentWeight = user?.currentWeight ?? 70;
                            _currentHeight = user?.height ?? 170;
                            isLoading = false;
                          });
                        },
                      );
                    },
                    child: Text(CusAL.of(context).manageLabel),
                  ),
                  SizedBox(width: 10.sp),
                  ElevatedButton(
                    onPressed: () {
                      // 这里只显示修改体重
                      _buildModifyWeightOrBmiDialog(onlyWeight: true).then(
                        (value) async {
                          // 强制重新加载体重变化图表
                          setState(() {
                            isLoading = true;
                          });
                          var tempUser = (await _userHelper.queryUser(
                            userId: CacheUser.userId,
                          ))!;

                          setState(() {
                            user = tempUser;
                            _currentWeight = user?.currentWeight ?? 70;
                            _currentHeight = user?.height ?? 170;
                            isLoading = false;
                          });
                        },
                      );
                    },
                    child: Text(CusAL.of(context).recordLabel),
                  ),
                ],
              )
            ],
          ),
        ),
        if (!isLoading)
          Card(child: WeightChangeLineChart(user: user ?? User(userName: ''))),
      ],
    );
  }
}

class SemiCircleProgressBar extends StatelessWidget {
  final double progress;
  final double size;
  final double strokeWidth;
  final Color backgroundColor;
  final Color progressColor;
  final Widget centerWidget;

  const SemiCircleProgressBar({
    super.key,
    required this.progress,
    required this.size,
    required this.strokeWidth,
    required this.backgroundColor,
    required this.progressColor,
    required this.centerWidget,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        CustomPaint(
          size: Size(size, size / 2), // 半圆的高度是宽度的一半
          painter: _SemiCirclePainter(
            progress: progress,
            strokeWidth: strokeWidth,
            backgroundColor: backgroundColor,
            progressColor: progressColor,
          ),
        ),
        Positioned(
          bottom: 5,
          child: centerWidget,
        ),
      ],
    );
  }
}

class _SemiCirclePainter extends CustomPainter {
  final double progress;
  final double strokeWidth;
  final Color backgroundColor;
  final Color progressColor;

  _SemiCirclePainter({
    required this.progress,
    required this.strokeWidth,
    required this.backgroundColor,
    required this.progressColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Rect.fromLTWH(0, 0, size.width, size.height * 2);

    const startAngle = -pi;
    final sweepAngle = pi * progress;

    // 绘制背景半圆
    final backgroundPaint = Paint()
      ..color = backgroundColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(
      rect,
      startAngle,
      pi,
      false,
      backgroundPaint,
    );

    // 绘制进度条半圆
    final progressPaint = Paint()
      ..color = progressColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(
      rect,
      startAngle,
      sweepAngle,
      false,
      progressPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
