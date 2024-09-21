import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fit_track/views/dietary/records/add_intake_item/simple_food_detail.dart';
import 'package:intl/intl.dart';

import '../../../../common/global/constants.dart';
import '../../../../common/utils/db_dietary_helper.dart';
import '../../../../common/utils/tool_widgets.dart';
import '../../../../common/utils/tools.dart';
import '../../../../models/cus_app_localizations.dart';
import '../../../../models/dietary_state.dart';

class AddDailyDietPage extends StatefulWidget {
  final CusMeals mealtime;
  const AddDailyDietPage({super.key, required this.mealtime});

  @override
  State<AddDailyDietPage> createState() => _AddDailyDietPageState();
}

class _AddDailyDietPageState extends State<AddDailyDietPage> {
  List<FoodAndServingInfo> foodItems = [];
  int currentPage = 1; // 数据库查询的时候会从0开始offset
  int pageSize = 10;
  bool isFoodLoading = false;
  ScrollController scrollController = ScrollController();
  final DBDietaryHelper _dietaryHelper = DBDietaryHelper();
  late CusMeals currentMealtime;
  late String currentDate;
  String query = '';
  @override
  void initState() {
    currentMealtime = widget.mealtime;
    currentDate=DateFormat(constDateFormat).format(DateTime.now());
    // 监听上滑滚动
    scrollController.addListener(_scrollListener);
    _loadFoodListData();
    super.initState();
  }
  /// 滚动到底部加载更多数据
  _scrollListener() {
    if (isFoodLoading) return;

    final maxScrollExtent = scrollController.position.maxScrollExtent;
    final currentPosition = scrollController.position.pixels;
    final delta = 50.0.sp;

    if (maxScrollExtent - currentPosition <= delta) {
      _loadFoodListData();
    }
  }
  /// 加载食物数据，每次10条
  _loadFoodListData() async {
    if (isFoodLoading) return;

    setState(() {
      isFoodLoading = true;
    });

    CusDataResult temp =
    await _dietaryHelper.searchFoodWithServingInfoWithPagination(
      query,
      currentPage,
      pageSize,
    );

    List<FoodAndServingInfo> newData = temp.data as List<FoodAndServingInfo>;

    setState(() {
      foodItems.addAll(newData);
      currentPage++;
      isFoodLoading = false;
    });
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(currentMealtime.name),
      ),
      body:  buildSimpleFoodListTabView(),
    );
  }
  ///
  /// 构建简单食物列表条目数据
  ///
  buildSimpleFoodListTabView() {
    return Padding(
      padding: EdgeInsets.all(8.sp),
      child: Column(
        children: [
          /// 搜索区域
          // _buildSearchRowArea(),
          SizedBox(height: 5.sp),

          /// 食物列表区域
          Expanded(
            child: ListView.builder(
              itemCount: foodItems.length + 1,
              itemBuilder: (context, index) {
                if (index == foodItems.length) {
                  return buildLoader(isFoodLoading);
                } else {
                  return _buildFoodItemCard(foodItems[index]);
                }
              },
              controller: scrollController,
            ),
          ),
        ],
      ),
    );
  }

  _buildFoodItemCard(FoodAndServingInfo item) {
    var food = item.food;
    var foodName = "${box.read('language')=='zh'?food.product:food.productEn} (${food.brand})";

    var fistServingInfo = item.servingInfoList[0];
    var foodUnit = fistServingInfo.servingUnit;
    var foodEnergy = (fistServingInfo.energy /oneCalToKjRatio);

    return Card(
      elevation: 2,
      child: ListTile(
        // 食物名称
        title: Text(
          foodName,
          softWrap: true,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        // 单份食物营养素
        subtitle: Text(
          "$foodUnit - ${cusDoubleToString(foodEnergy)} ${CusAL.of(context).unitLabels('2')}",
        ),
        // 点击这个添加就是默认添加单份营养素的食物，那就直接返回日志页面。
        trailing: IconButton(
          onPressed: () async {
            var tempStr =
            mealtimeList.firstWhere((e) => e.value == currentMealtime);
            var dailyFoodItem = DailyFoodItem(
              date: currentDate,
              mealCategory: tempStr.enLabel,
              foodId: food.foodId!,
              servingInfoId: fistServingInfo.servingInfoId!,
              foodIntakeSize: fistServingInfo.servingSize.toDouble(),
              userId: CacheUser.userId,
              gmtCreate: getCurrentDateTime(),
            );
            // ？？？这里应该有插入是否成功的判断
            var rst = await _dietaryHelper.insertDailyFoodItemList(
              [
                dailyFoodItem
              ],
            );

            if (!mounted) return;
            Navigator.pop(context,tempStr.enLabel);
            // if (rst.isNotEmpty) {
            //   // 返回餐次，让主页面展开新增的那个折叠栏
            //   Navigator.of(context).pop(tempStr.enLabel);
            // } else {
            //   Navigator.of(context).pop(tempStr.enLabel);
            // }
          },
          icon: Icon(Icons.add, color: Theme.of(context).primaryColor),
        ),
        onTap: () {
          // Navigator.push(
          //   context,
          //   MaterialPageRoute(
          //     builder: (context) => SimpleFoodDetail(
          //       foodItem: item,
          //       mealtime: currentMealtime,
          //       logDate: currentDate,
          //     ),
          //   ),
          // );
          var tempStr =
          mealtimeList.firstWhere((e) => e.value == currentMealtime);
          var dailyFoodItem = DailyFoodItem(
            date: currentDate,
            mealCategory: tempStr.enLabel,
            foodId: food.foodId!,
            servingInfoId: fistServingInfo.servingInfoId!,
            foodIntakeSize: fistServingInfo.servingSize.toDouble(),
            userId: CacheUser.userId,
            gmtCreate: getCurrentDateTime(),
          );
          // Navigator.pop(context,tempStr.enLabel);
        },
      ),
    );
  }
}
