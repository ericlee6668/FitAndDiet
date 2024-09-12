// ignore_for_file: avoid_print

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../common/components/cus_cards.dart';
import '../../common/global/constants.dart';
import '../../common/utils/db_dietary_helper.dart';
import '../../common/utils/tool_widgets.dart';
import '../../common/utils/tools.dart';
import '../../layout/themes/cus_font_size.dart';
import '../../models/cus_app_localizations.dart';
import '../../models/dietary_state.dart';
import 'foods/food_nutrient_detail.dart';
import 'foods/index.dart';
import 'meal_gallery/meal_photo_gallery.dart';
import 'records/index.dart';
import 'reports/index.dart';

class DietaryPage extends StatefulWidget {
  const DietaryPage({super.key});

  @override
  State<DietaryPage> createState() => _DietaryPageState();
}

class _DietaryPageState extends State<DietaryPage> {
  final DBDietaryHelper _dietaryHelper = DBDietaryHelper();
  int itemsCount = 0;
  int currentPage = 1; // 数据库查询的时候会从0开始offset
  int pageSize = 10;
  String query = '';
  bool isLoading = false;
  ScrollController scrollController = ScrollController();
  List<FoodAndServingInfo> foodItems = [];
  @override
  Widget build(BuildContext context) {
    // 计算屏幕剩余的高度
    double screenHeight = MediaQuery.of(context).size.height -
        MediaQuery.of(context).padding.top -
        MediaQuery.of(context).padding.bottom -
        kToolbarHeight -
        kBottomNavigationBarHeight -
        2 * 12.sp; // 减的越多，上下空隙越大


    return Scaffold(
      // 避免搜索时弹出键盘，让底部的minibar位置移动到tab顶部导致溢出的问题
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: Text(CusAL.of(context).dietary),
      ),
      body: Column(
        children: [
          buildFixedBody(screenHeight),
          Expanded(
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: foodItems.length + 1,
              itemBuilder: (context, index) {
                if (index == foodItems.length) {
                  return buildLoader(isLoading);
                } else {
                  return _buildSimpleFoodTile(foodItems[index], index);
                }
              },
              controller: scrollController,
            ),
          ),
        ],
      ),
    );
  }

  /// 可视页面固定等分居中、不可滚动的首页
  Widget buildFixedBody(double screenHeight) {
    return GridView(
         shrinkWrap: true,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2

      ),
      children: [

        buildCoverCard(
          context,
          const DietaryReports(),
          CusAL.of(context).dietaryReports,
          CusAL.of(context).dietaryReportsSubtitle,
          reportImageUrl,
        ),
        buildCoverCard(
          context,
          const DietaryFoods(),
          CusAL.of(context).foodCompo,
          CusAL.of(context).foodCompoSubtitle,
          dietaryNutritionImageUrl,
        ),
        buildCoverCard(
          context,
          const MealPhotoGallery(),
          CusAL.of(context).mealGallery,
          CusAL.of(context).mealGallerySubtitle,
          dietaryMealImageUrl,
        ),
        buildCoverCard(
          context,
          const DietaryRecords(),
          CusAL.of(context).dietaryRecords,
          CusAL.of(context).dietaryRecordsSubtitle,
          dietaryLogCoverImageUrl,
        ),
      ],
    );
  }
  @override
  void initState() {
    scrollController.addListener(_scrollListener);
    _loadFoodData();
    super.initState();
  }
  void _scrollListener() {
    if (isLoading) return;

    final maxScrollExtent = scrollController.position.maxScrollExtent;
    final currentPosition = scrollController.position.pixels;
    final delta = 50.0.sp;

    if (maxScrollExtent - currentPosition <= delta) {
      _loadFoodData();
    }
  }
  Future<void> _loadFoodData() async {
    if (isLoading) return;

    setState(() {
      isLoading = true;
    });

    CusDataResult temp = await _dietaryHelper
        .searchFoodWithServingInfoWithPagination(query, currentPage, pageSize);

    var newData = temp.data as List<FoodAndServingInfo>;

    setState(() {
      foodItems.addAll(newData);
      itemsCount = temp.total;
      currentPage++;
      isLoading = false;
    });
  }

  _buildSimpleFoodTile(FoodAndServingInfo fsi, int index) {
    var food = fsi.food;
    var servingList = fsi.servingInfoList;
    var foodName = "${food.product} (${food.brand})";

    var firstServing = servingList.isNotEmpty ? servingList[0] : null;
    var foodUnit = firstServing?.servingUnit;
    var foodEnergy =
    (firstServing?.energy ?? 0 / oneCalToKjRatio).toStringAsFixed(0);

    // 能量文字
    var text1 = "$foodUnit - $foodEnergy ${CusAL.of(context).unitLabels('2')}";
    // 碳水文字
    var text2 =
        "${CusAL.of(context).mainNutrients('4')} ${formatDoubleToString(firstServing?.totalCarbohydrate ?? 0)} ${CusAL.of(context).unitLabels('0')}";
    // 脂肪文字
    var text3 =
        "${CusAL.of(context).mainNutrients('3')} ${formatDoubleToString(firstServing?.totalFat ?? 0)} ${CusAL.of(context).unitLabels('0')}";
    // 蛋白质文字
    var text4 =
        "${CusAL.of(context).mainNutrients('2')} ${formatDoubleToString(firstServing?.protein ?? 0)} ${CusAL.of(context).unitLabels('0')}";

    return Card(
      elevation: 5,
      child: ListTile(
        // 食物名称
        title: Text(
          "${index + 1} - $foodName",
          maxLines: 2,
          softWrap: true,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontSize: CusFontSizes.itemTitle,
            color: Theme.of(context).primaryColor,
          ),
        ),
        // 单份食物营养素
        subtitle: Text(
          "$text1\n$text2 , $text3 , $text4",
          style: TextStyle(fontSize: CusFontSizes.itemSubTitle),
          maxLines: 2,
          softWrap: true,
          overflow: TextOverflow.ellipsis,
        ),

        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => FoodNutrientDetail(
                foodItem: fsi,
              ),
            ),
          ).then((value) {
            // 从详情页返回后需要重新查询，因为不知道在内部是不是有变动单份营养素。
            // 有变动，退出不刷新，再次进入还是能看到旧的；但是返回就刷新对于只是浏览数据不友好。
            // 因此，详情页会有一个是否被异动的标志，返回true则重新查询；否则就不更新
            if (value != null && value) {
              setState(() {
                foodItems.clear();
                currentPage = 1;
              });
              _loadFoodData();
            }
          });
        },
        // 长按点击弹窗提示是否删除
        onLongPress: () {
          showDialog(
            context: context,
            builder: (context) {
              return AlertDialog(
                title: Text(CusAL.of(context).deleteConfirm),
                content: Text(
                  CusAL.of(context)
                      .deleteNote('\n${food.product}(${food.brand})'),
                ),
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
          ).then((value) async {
            if (value != null && value) {
              try {
                await _dietaryHelper.deleteFoodWithServingInfo(food.foodId!);

                // 删除后重新查询
                setState(() {
                  foodItems.clear();
                  currentPage = 1;
                });
                _loadFoodData();
              } catch (e) {
                if (!mounted) return;
                commonExceptionDialog(
                  context,
                  CusAL.of(context).exceptionWarningTitle,
                  e.toString(),
                );
              }
            }
          });
        },
      ),
    );
  }

}
