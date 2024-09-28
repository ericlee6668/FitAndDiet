// ignore_for_file: avoid_print

import 'dart:convert';
import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:fit_track/main/float_view.dart';
import 'package:numberpicker/numberpicker.dart';

import '../common/db/db_dietary_helper.dart';
import '../common/db/db_user_helper.dart';
import '../common/global/constants.dart';
import '../common/utils/tool_widgets.dart';
import '../common/utils/tools.dart';
import '../models/cus_app_localizations.dart';
import '../models/dietary_state.dart';
import '../models/food_composition.dart';
import '../models/user_state.dart';
import 'home_page.dart';

///
/// 首次使用的引导页面(占位)
///
/// 当用户首次进入app时，需要他填写一个用户名，作为默认的userId=1的初始用户。
///   不填的话就使用随机数或者获取手机型号？
///   填入或者自动获取手机型号之后，讲这个唯一用户存入sqlite和storage，下次启动时获取storage的数据。
///
/// 如果启动app时获取storage的用户信息是空，就认为是首次使用，就跳动此登录页面。
///   如果能获取到，就从这里跳转到主页面去
class InitGuidePage extends StatefulWidget {
  const InitGuidePage({super.key});

  @override
  State<InitGuidePage> createState() => _InitGuidePageState();
}

class _InitGuidePageState extends State<InitGuidePage> {
  final DBUserHelper _userHelper = DBUserHelper();
  final DBDietaryHelper _dietaryHelper = DBDietaryHelper();
  // 用户输入的称呼
  final TextEditingController _usernameController = TextEditingController();
  // 用户选择的性别
  String selectedGender = "";

  double _currentWeight = 66;
  double _currentHeight = 170;

  // 初始化使用时的默认用户信息(根据用户是否有填写对应栏位修改对应栏位)
  var defaultUser = User(
    userId: 1,
    userName: "defaultUser",
    userCode: "defaultUser",
    gender: genderOptions.first.value,
    description: "lose fat program",
    password: "123456",
    dateOfBirth: "1994-07-02",
    height: 170,
    currentWeight: 66,
    targetWeight: 66,
    rdaGoal: 1800,
    proteinGoal: 120,
    fatGoal: 60,
    choGoal: 120,
    actionRestTime: 30,
  );
@override
  void initState() {
    loadJsonData();
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    String currentLanguage = Localizations.localeOf(context).languageCode;

    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Padding(
        padding: EdgeInsets.all(16.sp),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(CusAL.of(context).initInfo),
            Padding(
              padding: EdgeInsets.all(10.sp),
              child: TextFormField(
                controller: _usernameController,
                decoration: InputDecoration(
                  labelText: CusAL.of(context).nameLabel,
                  // 设置透明底色
                  filled: true,
                  fillColor: Colors.transparent,
                ),
              ),
            ),
            // Padding(
            //   padding: EdgeInsets.all(10.sp),
            //   child: DropdownButtonFormField<CusLabel>(
            //     decoration: const InputDecoration(
            //       isDense: true,
            //       // 设置透明底色
            //       filled: true,
            //       fillColor: Colors.transparent,
            //     ),
            //     items: genderOptions.map((CusLabel gender) {
            //       return DropdownMenuItem<CusLabel>(
            //         value: gender,
            //         child: Text(
            //           currentLanguage == "zh" ? gender.cnLabel : gender.enLabel,
            //         ),
            //       );
            //     }).toList(),
            //     onChanged: (CusLabel? value) async {
            //       setState(() {
            //         selectedGender = value?.value;
            //       });
            //     },
            //     hint: Text(CusAL.of(context).genderLabel),
            //   ),
            // ),
            Card(
              child: Padding(
                padding: EdgeInsets.all(10.sp),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  mainAxisSize: MainAxisSize.max,
                  children: <Widget>[
                    Column(
                      children: [
                        Text(CusAL.of(context).heightLabel("(cm)")),
                        SizedBox(height: 10.sp),
                        DecimalNumberPicker(
                          value: _currentHeight,
                          minValue: 50,
                          maxValue: 240,
                          decimalPlaces: 1,
                          itemHeight: 30,
                          itemWidth: 60.sp,
                          onChanged: (value) =>
                              setState(() => _currentHeight = value),
                        ),
                      ],
                    ),
                    Column(
                      children: [
                        Text(CusAL.of(context).weightLabel("(kg)")),
                        SizedBox(height: 10.sp),
                        DecimalNumberPicker(
                          value: _currentWeight,
                          minValue: 10,
                          maxValue: 300,
                          decimalPlaces: 1,
                          itemHeight: 30,
                          itemWidth: 60.sp,
                          onChanged: (value) =>
                              setState(() => _currentWeight = value),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 20.sp),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                TextButton(
                  onPressed: _login,
                  child: Text(
                    CusAL.of(context).confirmLabel,
                    style: TextStyle(fontSize: 18.sp),
                  ),
                ),
                // TextButton(
                //   onPressed: _skip,
                //   child: Text(
                //     CusAL.of(context).skipLabel,
                //     style: TextStyle(fontSize: 18.sp),
                //   ),
                // ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _login() async {
    final String username = _usernameController.text;
    // 用户有输入就用输入的，没有就使用默认的
    if (username.isNotEmpty) {
      defaultUser.userName = username;
    }
    if (selectedGender.isNotEmpty) {
      defaultUser.gender = selectedGender;
    }

    defaultUser.currentWeight = _currentWeight;
    defaultUser.height = _currentHeight;

    // ？？？这里应该检查保存是否成功
    await _userHelper.insertUserList([defaultUser]);
    // 注意用户编号类型要一致都用int，storage支持的类型String, int, double, Map and List
    await box.write(LocalStorageKey.userId, 1);
    await box.write(LocalStorageKey.userName, username);

    var bmi = _currentWeight / (_currentHeight / 100 * _currentHeight / 100);
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

    // ？？？这里应该判断是否新增成功
    await _userHelper.insertWeightTrendList([temp]);


    if (!mounted) return;
    SmartDialog.dismiss();
  }

  // 解析后的食物营养素列表(文件和食物都不支持移除)
  List<FoodComposition> foodComps = [];
  // 异步函数读取和解析 JSON 文件
  Future<void> loadJsonData() async {

    // 读取 assets 中的 JSON 文件
    String jsonString = await rootBundle.loadString('assets/json/data.json');
    // 解析 JSON 数据
    List jsonResponse = json.decode(jsonString);
    var temp = jsonResponse.map((e) => FoodComposition.fromJson(e)).toList();
    foodComps.addAll(temp);
    _saveToDb();
    box.write('isReadJson', true);
  }
  _saveToDb() async {
    // 这里导入去重的工作要放在上面解析文件时，这里就全部保存了。
    // 而且id自增，食物或者编号和数据库重复，这里插入数据库中也不会报错。
    for (var e in foodComps) {
      var tempFood = Food(
        // 转型会把前面的0去掉(让id自增，否则下面serving的id也要指定)
        brand: e.foodCode ?? '',
        product: e.foodName ?? "",
        productEn: e.foodNameEn ?? "",
        tags: e.tags?? "",
        category: e.category?? "",
        // ？？？2023-11-30 这里假设传入的图片是完整的，就不像动作那样再指定文件夹前缀了
        photos: e.photos?.join(","),
        contributor: CacheUser.userName,
        gmtCreate: getCurrentDateTime(),
        isDeleted: false,
      );

      /// 营养素值全是字符串，而且由于是orc识别，还可以包含无法转换的内容
      /// size都应该都是1；unit则是标准单份为100g或100ml，自定义则为1份
      ///   原书全是标准值，都是100g，但是有分可食用部分，这里排除
      /// 也是因为有可食用部分的栏位，这里就不计算单克的值来
      var tempServing = ServingInfo(
        // 因为同时新增食物和单份营养素，所以这个foodId会被上面的替换掉
        foodId: 0,
        servingSize: 1,
        servingUnit: "100g",
        energy: double.tryParse(e.energyKJ ?? "0") ?? 0,
        protein: double.tryParse(e.protein ?? "0") ?? 0,
        totalFat: double.tryParse(e.fat ?? "0") ?? 0,
        totalCarbohydrate: double.tryParse(e.cHO ?? "0") ?? 0,
        sodium: double.tryParse(e.na ?? "0") ?? 0,
        cholesterol: double.tryParse(e.cholesterol ?? "0") ?? 0,
        dietaryFiber: double.tryParse(e.dietaryFiber ?? "0") ?? 0,
        // 其他可选值暂时不对应
        contributor: CacheUser.userName,
        gmtCreate: getCurrentDateTime(),
        isDeleted: false,
      );

      try {
        await _dietaryHelper.insertFoodWithServingInfoList(
          food: tempFood,
          servingInfoList: [tempServing],
        );

      } on Exception catch (e) {
        // 将错误信息展示给用户
        if (!mounted) return;
        commonExceptionDialog(
          context,
          CusAL.of(context).exceptionWarningTitle,
          e.toString(),
        );
        return;
      }
    }
    eventBus.fire('loadJsonEvent');
  }

  void _skip() async {
    DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();

    var deviceName = "free-fitness-user";

    if (Platform.isAndroid) {
      AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
      deviceName = androidInfo.model;
    } else if (Platform.isIOS) {
      IosDeviceInfo iosInfo = await deviceInfo.iosInfo;
      deviceName = iosInfo.utsname.machine;
    }

    defaultUser.userName = "$deviceName 用户";
    defaultUser.userName = deviceName;
    defaultUser.description = "一位在使用free-fitness的$deviceName用户";

    // ？？？这里应该检查保存是否成功
    await _userHelper.insertUserList([defaultUser]);
    // 注意用户编号类型要一致都用int，storage支持的类型String, int, double, Map and List
    await box.write(LocalStorageKey.userId, 1);
    await box.write(LocalStorageKey.userName, "$deviceName 用户");

    if (!mounted) return;
    SmartDialog.dismiss();
    // Navigator.pushReplacement(
    //   context,
    //   MaterialPageRoute(builder: (context) => const HomePage()),
    // );
  }

}

