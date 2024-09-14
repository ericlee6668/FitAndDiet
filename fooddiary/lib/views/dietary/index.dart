// ignore_for_file: avoid_print

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:free_fitness/views/me/intake_goals/intake_target.dart';

import '../../common/components/cus_cards.dart';
import '../../common/global/constants.dart';
import '../../common/utils/db_dietary_helper.dart';
import '../../common/utils/tool_widgets.dart';
import '../../common/utils/tools.dart';
import '../../main/themes/cus_font_size.dart';
import '../../models/cus_app_localizations.dart';
import '../../models/dietary_state.dart';
import '../me/weight_change_record/index.dart';
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

class _DietaryPageState extends State<DietaryPage>
    with SingleTickerProviderStateMixin {
  final DBDietaryHelper _dietaryHelper = DBDietaryHelper();
  int itemsCount = 0;
  int currentPage = 1; // 数据库查询的时候会从0开始offset
  int pageSize = 50;
  String query = '';
  bool isLoading = false;
  ScrollController scrollController = ScrollController();

  List<FoodAndServingInfo> foodItems = [];
  List<String> foodsTypeZh = ['全部', '主食', '水果', '肉类', '鱼虾类', '蔬菜', '奶及奶制品'];
  List<String> queryCode = ['', 'a1', 'b1', 'c1', 'd1', 'e1', 'f1'];
  late TabController controller;
  var currentName = 'all';
  var currentCode = '';
  var curTitle ='dietary';
  @override
  void initState() {
    scrollController.addListener(_scrollListener);
    controller = TabController(length: foodsTypeZh.length, vsync: this);
    controller.addListener(() {
      if (controller.indexIsChanging) {
        setState(() {
          currentName = foodsTypeZh[controller.index];
        });
        currentCode = queryCode[controller.index];
        queryFoodList(queryCode[controller.index]);
        print('ccupage:${currentName}');
      }
    });

    _loadFoodData();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // 避免搜索时弹出键盘，让底部的minibar位置移动到tab顶部导致溢出的问题
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: Text(curTitle),
      ),
      backgroundColor: const Color(0xfff5f5f5),
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
              pinned: false,
              expandedHeight: 260.w,
              automaticallyImplyLeading: false,
              flexibleSpace: FlexibleSpaceBar(
                background: Container(
                  color: const Color(0xfff5f5f5),
                  child: buildFixedBody(),
                ),
              )),
          SliverToBoxAdapter(
            child: Center(
                child: Text(
              CusAL.of(context).calorieQuery,
              style: TextStyle(
                  color: Theme.of(context).primaryColor,
                  fontSize: 16.sp,
                  fontWeight: FontWeight.bold),
            )),
          ),
          SliverPersistentHeader(
              pinned: true,
              delegate: SliverHeaderDelegate.builder(
                  minHeight: 45.sp,
                  maxHeight: 45.sp,
                  builder: (contex, shrinkOffset, overlapsContent) {
                    print(' shrink: $shrinkOffset, overlaps:$overlapsContent');
                    WidgetsBinding.instance
                        .addPostFrameCallback((timeStamp) {
                      if (shrinkOffset == 0) {
                        setState(() {
                          curTitle=CusAL.of(context).dietary;
                        });
                      } else if (shrinkOffset == 45.sp) {
                     setState(() {
                       curTitle=CusAL.of(context).calorieQuery;
                     });
                      }
                    });

                    return Column(
                      children: [
                        Container(
                          color: Colors.white,
                          height: 38.w,
                          child: TabBar(
                            tabs: foodsTypeZh
                                .map((e) => SizedBox(
                                      height: 28,
                                      child: Text(
                                        e,
                                        style: TextStyle(
                                            color: currentName == e
                                                ? Colors.red
                                                : Colors.black87,
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
                      ],
                    );
                  })),
          SliverList.separated(
              itemCount: foodItems.length + 1,
              itemBuilder: (context, index) {
                if (index == foodItems.length) {
                  return buildLoader(isLoading);
                } else {
                  return _buildSimpleFoodTile(foodItems[index], index);
                }
              },
              separatorBuilder: (context, i) {
                return const SizedBox(
                  height: 2,
                );
              })
        ],
      ),
    );
  }

  /// 可视页面固定等分居中、不可滚动的首页
  Widget buildFixedBody() {
    return GridView(
      shrinkWrap: true,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2, childAspectRatio: 2.1),
      children: [
        buildCoverCard(
          context,
          const WeightChangeRecord(),
          CusAL.of(context).weightRecords,
          CusAL.of(context).weightRecordsSubtitle,
          weightImageUrl,
        ),
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
        buildCoverCard(
          context,
          const IntakeTargetPage(),
          CusAL.of(context).settingLabels('2'),
          CusAL.of(context).dietaryRecordsSubtitle,
          goalImage,
        ),
      ],
    );
  }

  void _scrollListener() {
    if (isLoading) return;

    final maxScrollExtent = scrollController.position.maxScrollExtent;
    final currentPosition = scrollController.position.pixels;
    final delta = 50.0.sp;

    if (maxScrollExtent - currentPosition <= delta) {
      // _loadFoodData();
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

  _buildSimpleFoodTile(FoodAndServingInfo fsi, int index) {
    var food = fsi.food;
    var servingList = fsi.servingInfoList;
    // var foodName = "${food.product} (${food.brand})";
    var foodName = food.productEn??(food.product??"");
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
      color: Colors.white,
      child: ListTile(
        minVerticalPadding: 5,
        enableFeedback: true,
        // 食物名称
        title: Text(
          "${index + 1} - $foodName",
          maxLines: 2,
          softWrap: true,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontSize: CusFontSizes.itemSubTitle,
            color: Theme.of(context).primaryColor,
          ),
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
}

typedef SliverHeaderBuilder = Widget Function(
    BuildContext context, double shrinkOffset, bool overlapsContent);

class SliverHeaderDelegate extends SliverPersistentHeaderDelegate {
  // child 为 header
  SliverHeaderDelegate({
    required this.maxHeight,
    this.minHeight = 0,
    required Widget child,
  })  : builder = ((a, b, c) => child),
        assert(minHeight <= maxHeight && minHeight >= 0);

  //最大和最小高度相同
  SliverHeaderDelegate.fixedHeight({
    required double height,
    required Widget child,
  })  : builder = ((a, b, c) => child),
        maxHeight = height,
        minHeight = height;

  //需要自定义builder时使用
  SliverHeaderDelegate.builder({
    required this.maxHeight,
    this.minHeight = 0,
    required this.builder,
  });

  final double maxHeight;
  final double minHeight;
  final SliverHeaderBuilder builder;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    Widget child = builder(context, shrinkOffset, overlapsContent);
    //测试代码：如果在调试模式，且子组件设置了key，则打印日志
    assert(() {
      if (child.key != null) {
        print('${child.key}: shrink: $shrinkOffset，overlaps:$overlapsContent');
      }

      return true;
    }());
    // 让 header 尽可能充满限制的空间；宽度为 Viewport 宽度，
    // 高度随着用户滑动在[minHeight,maxHeight]之间变化。
    return SizedBox.expand(child: child);
  }

  @override
  double get maxExtent => maxHeight;

  @override
  double get minExtent => minHeight;

  @override
  bool shouldRebuild(SliverHeaderDelegate old) {
    return old.maxExtent != maxExtent || old.minExtent != minExtent;
  }
}
