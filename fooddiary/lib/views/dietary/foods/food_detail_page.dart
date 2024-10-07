// ignore_for_file: avoid_print

import 'package:fit_track/common/db/db_dietary_helper.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../common/global/constants.dart';
import '../../../../models/dietary_state.dart';
import '../../../common/components/dialog_widgets.dart';
import '../../../common/utils/tool_widgets.dart';
import '../../../common/utils/tools.dart';
import '../../../main/themes/cus_font_size.dart';
import '../../../models/cus_app_localizations.dart';
import 'detail_modify_food.dart';
import 'detail_modify_serving_info.dart';


class FoodNutrientDetailNew extends StatefulWidget {
  // 这个是食物搜索页面点击食物进来详情页时传入的数据
  final FoodAndServingInfo foodItem;

  const FoodNutrientDetailNew({super.key, required this.foodItem});

  @override
  State<FoodNutrientDetailNew> createState() => _FoodNutrientDetailNewState();
}

class _FoodNutrientDetailNewState extends State<FoodNutrientDetailNew> {
  final DBDietaryHelper _dietaryHelper = DBDietaryHelper();

  // 传入的食物详细数据
  late FoodAndServingInfo fsInfo;

  // 页面添加了滚动条
  final ScrollController _scrollController = ScrollController();

  // 构建食物的单份营养素列表，可以多选，然后进行相关操作
  // 待上传的动作数量已经每个动作的选中状态
  int servingItemsNum = 0;
  List<bool> servingSelectedList = [false];

  // 新增单份营养素时，选择的营养素类型(标准或者自制)
  CusLabel dropdownValue = servingTypeList.first;

  // 数据是否被修改
  // (这个标志要返回，如果有被修改，返回上一页列表时要重新查询；没有被修改则不用重新查询)
  bool isModified = false;
  // 用户输入的食物摄入数量
  double inputServingValue = 1;
  // 用户输入的食物摄入单位，就是上面选项选中的单位（主要是根据单位找到用于计算的营养素信息）
  var inputServingUnit = "100g";
  // 保存要用于计算的单份营养素信息
  late ServingInfo nutrientsInfo;
  @override
  void initState() {
    super.initState();

    setState(() {
      fsInfo = widget.foodItem;
      nutrientsInfo = fsInfo.servingInfoList[0];
      // 更新需要构建的表格的长度和每条数据的可选中状态(初始状态是都未选中)
      servingItemsNum = fsInfo.servingInfoList.length;
      servingSelectedList =
          List<bool>.generate(servingItemsNum, (int index) => false);
    });
  }

  //

  // 在修改了食物基本信息或者单份营养素之和，重新查询该食物信息
  refreshFoodAndServing() async {
    var newItem = await _dietaryHelper.searchFoodWithServingInfoByFoodId(
      widget.foodItem.food.foodId!,
    );

    if (newItem != null) {
      setState(() {
        fsInfo = newItem;

        // 重新查询后也要更新单份营养素的列表复选框数量及其状态
        servingItemsNum = fsInfo.servingInfoList.length;
        servingSelectedList =
            List<bool>.generate(servingItemsNum, (int index) => false);
      });
    }
  }

  /// 新结构，上面是食物基本信息，下面是单份营养素详情表格；
  /// 右上角修改按钮，修改基本信息；
  /// 表格的单份营养素可选中索引进行删除，可新增；
  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: true,
      onPopInvoked: (didPop) async {
        if (didPop) return;

        // 返回上一页时，返回是否被修改标识，用于父组件判断是否需要重新查询
        Navigator.pop(context, isModified);
      },
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        appBar: AppBar(
          title: Text(CusAL.of(context).foodDetail),
          actions: [
            IconButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => DetailModifyFood(food: fsInfo.food),
                  ),
                ).then((value) {
                  // 不管是否修改成功，这里都重新加载
                  // 还是稍微判断一下吧
                  if (value != null && value == true) {
                    refreshFoodAndServing();
                  }
                });
              },
              icon: const Icon(Icons.edit),
            ),
          ],
        ),
        body: ListView(
          children: [
            /// 展示食物基本信息表格
            ...buildFoodTable(fsInfo),

            /// 展示所有单份的数据，不用实时根据摄入数量修改值
            Padding(
              padding:  EdgeInsets.only(left: 15.sp),
              child: Text(
                CusAL.of(context).foodNutrientInfo,
                style: TextStyle(
                  fontSize: CusFontSizes.pageTitle,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).primaryColor,
                ),
                textAlign: TextAlign.left,
              ),
            ),

            // 主要营养素表格
            buildNutrientTableArea(),
            // 详细营养素区域
            SizedBox(height: 10.sp),
            buildAllNutrientTableArea(),
            SizedBox(height: 20.sp),
          ],
        ),
      ),
    );
  }
  /// 构建主要营养素表格区域
  buildNutrientTableArea() {
    return Padding(
      padding:  EdgeInsets.only(top: 10.sp,left: 15.sp,right: 15.sp),
      child: Column(
        children: [
          Text(
            CusAL.of(context).mainNutrientLabel,
            style: TextStyle(
              fontSize: CusFontSizes.flagMedium,
              fontWeight: FontWeight.bold,
            ),
          ),
          DecoratedBox(
            // 设置背景色
            decoration: BoxDecoration(
              // color: Theme.of(context).disabledColor,
              border: Border.all(
                color: Theme.of(context).colorScheme.tertiaryContainer,
              ),
            ),
            child: Table(
              border: TableBorder.all(color: Theme.of(context).disabledColor),
              columnWidths: const <int, TableColumnWidth>{
                1: FlexColumnWidth(),
                2: FlexColumnWidth(),
              },
              defaultVerticalAlignment: TableCellVerticalAlignment.middle,
              children: <TableRow>[
                TableRow(
                  children: <Widget>[
                    _genEssentialNutrientsTableCell(
                      CusAL.of(context).mainNutrients('1'),
                      '${cusDoubleTryToIntString(inputServingValue * nutrientsInfo.energy / oneCalToKjRatio)} ${CusAL.of(context).unitLabels('2')}',
                    ),
                    _genEssentialNutrientsTableCell(
                      CusAL.of(context).mainNutrients('4'),
                      '${cusDoubleTryToIntString(inputServingValue * nutrientsInfo.totalCarbohydrate)} ${CusAL.of(context).unitLabels('0')}',
                    ),
                  ],
                ),
                TableRow(
                  children: <Widget>[
                    _genEssentialNutrientsTableCell(
                      CusAL.of(context).mainNutrients('3'),
                      '${cusDoubleTryToIntString(inputServingValue * nutrientsInfo.totalFat)} ${CusAL.of(context).unitLabels('0')}',
                    ),
                    _genEssentialNutrientsTableCell(
                      CusAL.of(context).mainNutrients('2'),
                      '${cusDoubleTryToIntString(inputServingValue * nutrientsInfo.protein)} ${CusAL.of(context).unitLabels('0')}',
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
  _genEssentialNutrientsTableCell(String title, String value) {
    return TableCell(
      verticalAlignment: TableCellVerticalAlignment.middle,
      child: Padding(
        padding: EdgeInsets.all(5.sp),
        child: Center(
          child: RichText(
            textAlign: TextAlign.center,
            text: TextSpan(
              children: [
                TextSpan(
                  text: '$title\n',
                  style: TextStyle(
                    color: Theme.of(context).primaryColor,
                    fontSize: CusFontSizes.itemContent,
                  ),
                ),
                TextSpan(
                  text: value,
                  style: TextStyle(
                    fontSize: CusFontSizes.itemTitle,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  buildAllNutrientTableArea() {
    return Padding(
      padding:  EdgeInsets.only(top: 10.sp,left: 15.sp,right: 15.sp),
      child: Column(
        children: [
          Text(
            CusAL.of(context).allNutrientLabel,
            style: TextStyle(
              fontSize: CusFontSizes.flagMedium,
              fontWeight: FontWeight.bold,
            ),
          ),
          Table(
            // 设置表格边框
            border: TableBorder.all(color: Theme.of(context).disabledColor),
            // 设置每列的宽度占比
            columnWidths: const {
              0: FlexColumnWidth(2),
              1: FlexColumnWidth(3),
            },
            defaultVerticalAlignment: TableCellVerticalAlignment.middle,
            children: [
              _buildTableRow(
                CusAL.of(context).eatableSize,
                '${cusDoubleTryToIntString(inputServingValue)} X $inputServingUnit',
              ),
              _buildTableRow(
                CusAL.of(context).mainNutrients('1'),
                '${cusDoubleTryToIntString(inputServingValue * nutrientsInfo.energy / oneCalToKjRatio)} ${CusAL.of(context).unitLabels('2')}',
              ),
              _buildTableRow(
                CusAL.of(context).mainNutrients('0'),
                '${cusDoubleTryToIntString(inputServingValue * nutrientsInfo.energy)} ${CusAL.of(context).unitLabels('3')}',
                labelAligh: TextAlign.right,
                fontColor: Theme.of(context).primaryColor,
              ),
              _buildTableRow(
                CusAL.of(context).mainNutrients('2'),
                '${cusDoubleTryToIntString(inputServingValue * nutrientsInfo.protein)} ${CusAL.of(context).unitLabels('0')}',
              ),
              _buildTableRow(
                CusAL.of(context).fatNutrients('0'),
                '${cusDoubleTryToIntString(inputServingValue * nutrientsInfo.totalFat)} ${CusAL.of(context).unitLabels('0')}',
              ),
              if (nutrientsInfo.saturatedFat != null)
                _buildTableRow(
                  CusAL.of(context).fatNutrients('1'),
                  '${cusDoubleTryToIntString(inputServingValue * nutrientsInfo.saturatedFat!)} ${CusAL.of(context).unitLabels('0')}',
                  labelAligh: TextAlign.right,
                  fontColor: Theme.of(context).primaryColor,
                ),
              if (nutrientsInfo.transFat != null)
                _buildTableRow(
                  CusAL.of(context).fatNutrients('2'),
                  '${cusDoubleTryToIntString(inputServingValue * nutrientsInfo.transFat!)} ${CusAL.of(context).unitLabels('0')}',
                  labelAligh: TextAlign.right,
                  fontColor: Theme.of(context).primaryColor,
                ),
              if (nutrientsInfo.polyunsaturatedFat != null)
                _buildTableRow(
                  CusAL.of(context).fatNutrients('3'),
                  '${cusDoubleTryToIntString(inputServingValue * nutrientsInfo.polyunsaturatedFat!)} ${CusAL.of(context).unitLabels('0')}',
                  labelAligh: TextAlign.right,
                  fontColor: Theme.of(context).primaryColor,
                ),
              if (nutrientsInfo.monounsaturatedFat != null)
                _buildTableRow(
                  CusAL.of(context).fatNutrients('4'),
                  '${cusDoubleTryToIntString(inputServingValue * nutrientsInfo.monounsaturatedFat!)} ${CusAL.of(context).unitLabels('0')}',
                  labelAligh: TextAlign.right,
                  fontColor: Theme.of(context).primaryColor,
                ),
              _buildTableRow(
                CusAL.of(context).choNutrients('0'),
                '${cusDoubleTryToIntString(inputServingValue * nutrientsInfo.totalCarbohydrate)} ${CusAL.of(context).unitLabels('0')}',
              ),
              if (nutrientsInfo.sugar != null)
                _buildTableRow(
                  CusAL.of(context).choNutrients('1'),
                  '${cusDoubleTryToIntString(inputServingValue * nutrientsInfo.sugar!)} ${CusAL.of(context).unitLabels('0')}',
                  labelAligh: TextAlign.right,
                  fontColor: Theme.of(context).primaryColor,
                ),
              if (nutrientsInfo.dietaryFiber != null)
                _buildTableRow(
                  CusAL.of(context).choNutrients('2'),
                  '${cusDoubleTryToIntString(inputServingValue * nutrientsInfo.dietaryFiber!)} ${CusAL.of(context).unitLabels('0')}',
                  labelAligh: TextAlign.right,
                  fontColor: Theme.of(context).primaryColor,
                ),
              _buildTableRow(
                CusAL.of(context).microNutrients('0'),
                '${cusDoubleTryToIntString(inputServingValue * nutrientsInfo.sodium)} ${CusAL.of(context).unitLabels('1')}',
              ),
              if (nutrientsInfo.cholesterol != null)
                _buildTableRow(
                  CusAL.of(context).microNutrients('2'),
                  '${cusDoubleTryToIntString(inputServingValue * nutrientsInfo.cholesterol!)} ${CusAL.of(context).unitLabels('1')}',
                ),
              if (nutrientsInfo.potassium != null)
                _buildTableRow(
                  CusAL.of(context).microNutrients('1'),
                  '${cusDoubleTryToIntString(inputServingValue * nutrientsInfo.potassium!)} ${CusAL.of(context).unitLabels('1')}',
                ),
            ],
          ),
        ],
      ),
    );
  }
  // todo 2023-12-05 因为单份营养素基础表没有是否标准的栏位，所以没法传servingType。
  // 所以以新增+删除代替修改
  clickServingInfoModify() {
    // 先找到被选中的索引，应该只有一个
    int trueIndices =
        List.generate(servingSelectedList.length, (index) => index)
            .firstWhere((i) => servingSelectedList[i]);

    var servingInfo = fsInfo.servingInfoList[trueIndices];

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => DetailModifyServingInfo(
          /// 这个值真没地方取啊
          /// 2023-12-06 简单判断是否是标准度量
          servingType: (servingInfo.servingUnit.toLowerCase() == "100ml" ||
                  servingInfo.servingUnit.toLowerCase() == "100g" ||
                  servingInfo.servingUnit.toLowerCase() == "1mg" ||
                  servingInfo.servingUnit.toLowerCase() == "1g")
              ? servingTypeList.first
              : servingTypeList.last,
          food: fsInfo.food,
          currentServingInfo: servingInfo,
        ),
      ),
    ).then((value) {
      // 返回单份营养素新增成功的话重新查询当前食物详情数据
      if (value != null && value == true) {
        refreshFoodAndServing();
        // 如果食物相关数据被修改，则变动标识设为true
        setState(() {
          isModified = true;
        });
      }
    });
  }

  clickServingInfoDelete() {
    if (servingSelectedList.where((e) => e == true).length == servingItemsNum) {
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text(CusAL.of(context).alertTitle),
            content: const Text(
              '''至少保留一个单份营养素信息。
              \n若要删除所有数据，请考虑删除该条食物信息。
              \n若要更新全部单份营养素，请先新增完成后，再删除旧的数据。''',
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: Text(CusAL.of(context).confirmLabel),
              ),
            ],
          );
        },
      );
    } else {
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text(CusAL.of(context).deleteConfirm),
            content: Text(CusAL.of(context).deleteNote("")),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: Text(CusAL.of(context).cancelLabel),
              ),
              TextButton(
                onPressed: () async {
                  // 先找到被选中的索引
                  List<int> trueIndices = List.generate(
                          servingSelectedList.length, (index) => index)
                      .where((i) => servingSelectedList[i])
                      .toList();

                  // 找到选择的索引对应的营养素列表
                  List<int> selecteds = [];
                  for (var index in trueIndices) {
                    selecteds.add(fsInfo.servingInfoList[index].servingInfoId!);
                  }
                  // ？？？删除对应的单份营养素列表，应该要检测执行结果
                  await _dietaryHelper.deleteServingInfoList(selecteds);

                  if (!context.mounted) return;
                  Navigator.pop(context);
                  // 如果食物相关数据被修改，则变动标识设为true
                  setState(() {
                    isModified = true;
                  });
                },
                child: Text(CusAL.of(context).confirmLabel),
              ),
            ],
          );
        },
      ).then((value) => refreshFoodAndServing());
    }
  }

  clickServingInfoAdd() {
    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: Text(CusAL.of(ctx).optionsLabel),
          content: DropdownMenu<CusLabel>(
            initialSelection: servingTypeList.first,
            width: 0.6.sw,
            onSelected: (CusLabel? value) {
              setState(() {
                dropdownValue = value!;
              });
            },
            dropdownMenuEntries: servingTypeList
                .map<DropdownMenuEntry<CusLabel>>((CusLabel value) {
              return DropdownMenuEntry<CusLabel>(
                value: value,
                label: showCusLable(value),
              );
            }).toList(),
            textStyle: TextStyle(fontSize: CusFontSizes.itemContent),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(ctx, false);
              },
              child: Text(CusAL.of(ctx).cancelLabel),
            ),
            TextButton(
              onPressed: () {
                if (!mounted) return;
                Navigator.pop(ctx, true);
              },
              child: Text(CusAL.of(ctx).confirmLabel),
            ),
          ],
        );
      },
    ).then((value) {
      // 因为默认有选中新增单份营养素的类型，所以返回true确认新增时，一定有该type
      if (value != null && value) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => DetailModifyServingInfo(
              food: fsInfo.food,
              servingType: dropdownValue,
            ),
          ),
        ).then((value) {
          // 返回单份营养素新增成功的话重新查询当前食物详情数据
          if (value != null && value == true) {
            refreshFoodAndServing();
            // 如果食物相关数据被修改，则变动标识设为true
            setState(() {
              isModified = true;
            });
          }
        });
      }
    });
  }

  /// 表格显示食物基本信息
  buildFoodTable(FoodAndServingInfo info) {
    var food = info.food;
    List<String> imageList = [];
    // 先要排除image是个空字符串在分割
    if (food.photos != null && food.photos!.trim().isNotEmpty) {
      imageList = food.photos!.split(",");
    }

    return [
      buildImageCarouselSlider(imageList),
      Padding(
        padding:  EdgeInsets.only(top: 15.sp,left: 15.sp,bottom: 15.sp),
        child: Text(
          CusAL.of(context).foodBasicInfo,
          style: TextStyle(
            fontSize: CusFontSizes.flagMedium,
            fontWeight: FontWeight.bold,
            color: Theme.of(context).primaryColor,
          ),
          textAlign: TextAlign.start,
        ),
      ),
      Padding(
        padding: EdgeInsets.symmetric(horizontal: 15.sp),
        child: Table(
          // 设置表格边框
          border: TableBorder.all(
            color: Theme.of(context).disabledColor,
          ),
          // 设置每列的宽度占比
          columnWidths: const {
            0: FlexColumnWidth(4),
            1: FlexColumnWidth(9),
          },
          defaultVerticalAlignment: TableCellVerticalAlignment.middle,
          children: [
            _buildTableRow(
              CusAL.of(context).foodLabels("0"),
              food.productEn??'',
            ),
            _buildTableRow(
              CusAL.of(context).foodLabels("1"),
              food.brand,
            ),
            _buildTableRow(
              CusAL.of(context).foodLabels("2"),
              food.tags ?? "",
            ),
            _buildTableRow(
              CusAL.of(context).foodLabels("3"),
              food.category ?? "",
            ),
            _buildTableRow(
              CusAL.of(context).foodLabels("4"),
              food.description ?? "",
            ),
          ],
        ),
      ),

      SizedBox(height: 20.sp),
    ];
  }

  // 构建食物基本信息表格的行数据
  _buildTableRow(String label, String value, {
    TextAlign? labelAligh = TextAlign.left,
    Color? fontColor,
  }) {
    return TableRow(
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 10.sp,vertical: 5),
          child: Text(
            label,
            style: TextStyle(
              fontSize: CusFontSizes.itemSubTitle,
              fontWeight: FontWeight.bold,
              color: fontColor
            ),
            textAlign: labelAligh,
          ),
        ),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 10.sp),
          child: Text(
            value,
            style: TextStyle(
              fontSize: CusFontSizes.itemSubTitle,
              color: fontColor,
            ),
            textAlign: labelAligh,
          ),
        ),
      ],
    );
  }

  /// 表格展示单份营养素信息
  buildFoodServingDataTable(FoodAndServingInfo fsi) {
    var servingList = fsi.servingInfoList;

    return buildDataTableWithHorizontalScrollbar(
      scrollController: _scrollController,
      columns: [
        _buildDataColumn(CusAL.of(context).foodTableMainLabels("0")),
        _buildDataColumn(CusAL.of(context).foodTableMainLabels("1")),
        _buildDataColumn(CusAL.of(context).foodTableMainLabels("2")),
        _buildDataColumn(CusAL.of(context).foodTableMainLabels("3")),
        _buildDataColumn(CusAL.of(context).foodTableMainLabels("4")),
        _buildDataColumn(CusAL.of(context).foodTableMainLabels("5")),
      ],
      rows: List<DataRow>.generate(servingList.length, (index) {
        var serving = servingList[index];

        return DataRow(
          // 偶数行(算上标题行)添加灰色背景色，和选中时的背景色
          color: MaterialStateProperty.resolveWith<Color?>(
              (Set<MaterialState> states) {
            // 所有行被选中后都使用统一的背景
            if (states.contains(MaterialState.selected)) {
              return Theme.of(context).colorScheme.primary.withOpacity(0.08);
            }
            // 偶数行使用灰色背景
            if (index.isEven) {
              return Colors.grey.withOpacity(0.3);
            }
            // 对其他状态和奇数行使用默认值。
            return null;
          }),
          // 是否被选中
          selected: servingSelectedList[index],
          // 选中变化的回调
          onSelectChanged: (bool? value) {
            setState(() {
              servingSelectedList[index] = value!;
            });
          },
          cells: [
            _buildDataCell(serving.servingUnit),
            _buildDataCell(cusDoubleToString(serving.energy / oneCalToKjRatio)),
            _buildDataCell(cusDoubleToString(serving.protein)),
            _buildFatDataCell(
              cusDoubleToString(serving.totalFat),
              cusDoubleToString(serving.transFat),
              cusDoubleToString(serving.saturatedFat),
              cusDoubleToString(serving.monounsaturatedFat),
              cusDoubleToString(serving.polyunsaturatedFat),
            ),
            _buildChoDataCell(
              cusDoubleToString(serving.totalCarbohydrate),
              cusDoubleToString(serving.sugar),
              cusDoubleToString(serving.dietaryFiber),
            ),
            _buildMicroDataCell(
              cusDoubleToString(serving.sodium),
              cusDoubleToString(serving.cholesterol),
              cusDoubleToString(serving.potassium),
            ),
          ],
        );
      }),
    );
  }

  // 表格的标题和单元格样式
  _buildDataColumn(String text) {
    return DataColumn(
      label: Text(
        text,
        style: TextStyle(
          fontSize: CusFontSizes.itemSubTitle,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  // 构建单个值的单元格
  _buildDataCell(String text) {
    return DataCell(
      Text(text, style: TextStyle(fontSize: CusFontSizes.itemSubTitle)),
    );
  }

  // 脂肪、碳水、蛋白质单元格有多个不同的值，要单独构建
  _buildFatDataCell(
    String totalFat,
    String transFat,
    String saturatedFat,
    String muFat,
    String puFat,
  ) {
    return DataCell(
      Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${CusAL.of(context).fatNutrients("0")}  ',
                style: TextStyle(fontSize: CusFontSizes.itemSubTitle),
              ),
              Text(
                totalFat,
                style: TextStyle(fontSize: CusFontSizes.itemSubTitle),
              ),
            ],
          ),
          if (saturatedFat.isNotEmpty)
            _buildDetailRowCellText(
              '${CusAL.of(context).fatNutrients("1")}  ',
              saturatedFat,
            ),
          if (transFat.isNotEmpty)
            _buildDetailRowCellText(
              '${CusAL.of(context).fatNutrients("2")}  ',
              transFat,
            ),
          if (puFat.isNotEmpty)
            _buildDetailRowCellText(
              '${CusAL.of(context).fatNutrients("3")}  ',
              puFat,
            ),
          if (muFat.isNotEmpty)
            _buildDetailRowCellText(
              '${CusAL.of(context).fatNutrients("4")}  ',
              muFat,
            ),
        ],
      ),
    );
  }

  _buildChoDataCell(String totalCho, String sugar, String dietaryFiber) {
    return DataCell(
      Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${CusAL.of(context).choNutrients("0")}  ',
                style: TextStyle(fontSize: CusFontSizes.itemSubTitle),
              ),
              Text(
                totalCho,
                style: TextStyle(fontSize: CusFontSizes.itemSubTitle),
              ),
            ],
          ),
          if (sugar.isNotEmpty)
            _buildDetailRowCellText(
              '${CusAL.of(context).choNutrients("1")}  ',
              sugar,
            ),
          if (dietaryFiber.isNotEmpty)
            _buildDetailRowCellText(
              '${CusAL.of(context).choNutrients("2")}  ',
              dietaryFiber,
            ),
        ],
      ),
    );
  }

  _buildMicroDataCell(
    String sodium,
    String potassium,
    String cholesterol,
  ) {
    return DataCell(
      Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${CusAL.of(context).microNutrients("0")}  ',
                style: TextStyle(fontSize: CusFontSizes.itemSubTitle),
              ),
              Text(
                sodium,
                style: TextStyle(fontSize: CusFontSizes.itemSubTitle),
              ),
            ],
          ),
          if (potassium.isNotEmpty)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${CusAL.of(context).microNutrients("1")}  ',
                  style: TextStyle(fontSize: CusFontSizes.itemSubTitle),
                ),
                Text(
                  potassium,
                  style: TextStyle(fontSize: CusFontSizes.itemSubTitle),
                ),
              ],
            ),
          if (cholesterol.isNotEmpty)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${CusAL.of(context).microNutrients("2")}  ',
                  style: TextStyle(fontSize: CusFontSizes.itemSubTitle),
                ),
                Text(
                  cholesterol,
                  style: TextStyle(fontSize: CusFontSizes.itemSubTitle),
                ),
              ],
            ),
        ],
      ),
    );
  }

  // 单元格中有多个值，每个值都还有label和value
  _buildDetailRowCellText(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: CusFontSizes.itemContent,
            color: Colors.grey[600]!,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: CusFontSizes.itemContent,
            color: Colors.grey[600]!,
          ),
        ),
      ],
    );
  }
}
