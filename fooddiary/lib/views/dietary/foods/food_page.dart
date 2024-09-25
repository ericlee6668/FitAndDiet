import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../common/db/db_dietary_helper.dart';
import '../../../common/global/constants.dart';
import '../../../common/utils/tool_widgets.dart';
import '../../../common/utils/tools.dart';
import '../../../main/float_view.dart';
import '../../../main/themes/cus_font_size.dart';
import '../../../models/cus_app_localizations.dart';
import '../../../models/dietary_state.dart';
import 'food_nutrient_detail.dart';

class FoodPage extends StatefulWidget {
  const FoodPage({super.key});

  @override
  State<FoodPage> createState() => _FoodPageState();
}

class _FoodPageState extends State<FoodPage> with SingleTickerProviderStateMixin{
  final DBDietaryHelper _dietaryHelper = DBDietaryHelper();
  int itemsCount = 0;
  int currentPage = 1; // 数据库查询的时候会从0开始offset
  int pageSize = 50;
  String query = '';
  bool isLoading = false;
  ScrollController scrollController = ScrollController();
  var selectText = 'all'.obs;
  List<FoodAndServingInfo> foodItems = [];
  List<String> foodsTypeZh = [
    'all',
    'staple food',
    'fruit',
    'meat',
    'Fish and shrimp',
    'vegetable',
    'Milk and dairy products'
  ];
  List<String> queryCode = ['', 'a1', 'b1', 'c1', 'd1', 'e1', 'f1'];
  late TabController controller;
  var currentName = 'all';
  var currentCode = '';
  var curTitle = 'dietary';
  @override
  void initState() {
    scrollController.addListener(_scrollListener);
    controller = TabController(length: foodsTypeZh.length, vsync: this);
    controller.addListener(() {
      if (controller.indexIsChanging) {
        currentName = foodsTypeZh[controller.index];
        selectText.value = currentName;

        currentCode = queryCode[controller.index];
        queryFoodList(queryCode[controller.index]);
        print('ccupage:${currentName}');
      }
    });
    _loadFoodData();
    eventBus.on<String>().listen((event) {
      if (event == 'loadJsonEvent') {
        _loadFoodData();
      }
    });
    super.initState();
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
    queryFoodList('');
  }

  queryFoodList(String query) async {
    currentPage = 1;
    foodItems.clear();
    CusDataResult temp = await _dietaryHelper
        .searchFoodWithServingInfoWithPagination(query, currentPage, pageSize);
    var newData = temp.data as List<FoodAndServingInfo>;
    setState(() {
      foodItems.addAll(newData);
      itemsCount = temp.total;
      isLoading = false;
    });
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

  _buildSimpleFoodTile(FoodAndServingInfo fsi, int index) {
    var food = fsi.food;
    var servingList = fsi.servingInfoList;
    // var foodName = "${food.product} (${food.brand})";
    var foodName = food.productEn ?? (food.product ?? "");
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

    return Container(
      color: Color(box.read('mode') == 'dark' ? 0xff232229 : 0xffffffff),
      height: 70.w,
      child: ListTile(
        minVerticalPadding: 5,
        enableFeedback: true,
        isThreeLine: true,
        // 食物名称
        title: Text(
          "${index + 1} - $foodName",
          maxLines: 2,
          softWrap: true,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
              fontSize: CusFontSizes.itemSubTitle,
              color: Theme.of(context).primaryColor,
              fontWeight: FontWeight.bold),
        ),
        // 单份食物营养素
        subtitle: Text(
          "$text1\n$text2 , $text3 , $text4",
          style: TextStyle(fontSize: CusFontSizes.pageSubContent),
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
        // onLongPress: () {
        //   showDialog(
        //     context: context,
        //     builder: (context) {
        //       return AlertDialog(
        //         title: Text(CusAL.of(context).deleteConfirm),
        //         content: Text(
        //           CusAL.of(context)
        //               .deleteNote('\n${food.product}(${food.brand})'),
        //         ),
        //         actions: [
        //           TextButton(
        //             onPressed: () {
        //               Navigator.pop(context, false);
        //             },
        //             child: Text(CusAL.of(context).cancelLabel),
        //           ),
        //           TextButton(
        //             onPressed: () {
        //               Navigator.pop(context, true);
        //             },
        //             child: Text(CusAL.of(context).confirmLabel),
        //           ),
        //         ],
        //       );
        //     },
        //   ).then((value) async {
        //     if (value != null && value) {
        //       try {
        //         await _dietaryHelper.deleteFoodWithServingInfo(food.foodId!);
        //
        //         // 删除后重新查询
        //         setState(() {
        //           foodItems.clear();
        //           currentPage = 1;
        //         });
        //         _loadFoodData();
        //       } catch (e) {
        //         if (!mounted) return;
        //         commonExceptionDialog(
        //           context,
        //           CusAL.of(context).exceptionWarningTitle,
        //           e.toString(),
        //         );
        //       }
        //     }
        //   });
        // },
      ),
    );
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: RichText(
          text: TextSpan(
            children: [
              TextSpan(
                text: "${CusAL.of(context).food}\n",
                style: TextStyle(fontSize: CusFontSizes.pageTitle),
              ),
              TextSpan(
                text: CusAL.of(context).itemCount(itemsCount),
                style: TextStyle(fontSize: CusFontSizes.pageAppendix),
              ),
            ],
          ),
        ),
      ),
      body: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            color: Color(box.read('mode') == 'dark'
                ? 0xff232229
                : 0xffffffff),
            height: 42.w,
            child: TabBar(
              tabs: foodsTypeZh
                  .map((e) =>
                  SizedBox(
                    height: 28,
                    child: Text(
                      e,
                      style: TextStyle(
                          color: selectText.value == e
                              ? Colors.red
                              : Colors.black54,
                          fontSize: 16),
                    ),
                  ))
                  .toList(),
              controller: controller,
              indicatorColor: Colors.red,
              indicatorPadding:
              const EdgeInsets.symmetric(horizontal: 8),
              isScrollable: true,
            ),
          ),
          Expanded(
            child: ListView.separated(
              shrinkWrap: true,
                itemCount: foodItems.length + 1,
                itemBuilder: (context, index) {
                  if (index == foodItems.length) {
                    return buildLoader(isLoading);
                  } else {
                    return _buildSimpleFoodTile(foodItems[index], index);
                  }
                },
                separatorBuilder: (context, i) {
                  return const Divider(
                    height: 2,
                  );
                },controller: scrollController,),
          )
        ],
      ),
    );
  }
}
