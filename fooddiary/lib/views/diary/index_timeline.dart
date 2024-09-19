// ignore_for_file: avoid_print

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:timeline_tile/timeline_tile.dart';

import '../../common/global/constants.dart';
import '../../common/utils/db_diary_helper.dart';
import '../../common/utils/tool_widgets.dart';
import '../../main/themes/cus_font_size.dart';
import '../../models/cus_app_localizations.dart';
import '../../models/diary_state.dart';
import 'diary_modify_rich_text.dart';

class IndexTimeline extends StatefulWidget {
  const IndexTimeline({super.key});

  @override
  State<IndexTimeline> createState() => _IndexTimelineState();
}

class _IndexTimelineState extends State<IndexTimeline> {
  final DBDiaryHelper _dbHelper = DBDiaryHelper();

  // 展示手记列表(手记一次性10条，上滑加载更多)
  List<Diary> diaryList = [];
  // 数据库中符合条件的手记一共有多少
  int diaryCount = 0;

  int currentPage = 1; // 数据库查询的时候会从0开始offset
  int pageSize = 10;
  bool isLoading = false;

  ScrollController scrollController = ScrollController();

  // 手记关键字查询
  TextEditingController searchController = TextEditingController();
  String query = '';

  // 时间线连接线的颜色
  Color borderColor = const Color.fromARGB(255, 112, 78, 78).withOpacity(0.5);

  @override
  void initState() {
    super.initState();

    loadMoreDiary();
    scrollController.addListener(_scrollListener);
  }

  @override
  void dispose() {
    scrollController.removeListener(_scrollListener);
    scrollController.dispose();
    searchController.dispose();
    super.dispose();
  }

  void _scrollListener() {
    if (isLoading) return;

    final maxScrollExtent = scrollController.position.maxScrollExtent;
    final currentPosition = scrollController.position.pixels;

    // 上滑滚动到底部加载更多数据
    if (maxScrollExtent <= currentPosition) {
      loadMoreDiary();
    }
  }

  // 加载更多
  loadMoreDiary() async {
    // 如果已经在查询数据中，则忽略此次新的查询
    if (isLoading) return;

    // 如果没在查询中，设置状态为查询中
    setState(() {
      isLoading = true;
    });

    // 等待查询结果，处理条件，使用条件查询
    CusDataResult temp = await _dbHelper.queryDiaryByKeyword(
      userId: CacheUser.userId,
      pageSize: pageSize,
      page: currentPage,
      keyword: query,
    );

    List<Diary> newData = temp.data as List<Diary>;

    print(newData);

    // 如果没有更多数据，则在底部显示回弹
    if (newData.isEmpty) {
      if (!mounted) return;
      scrollController.animateTo(
        scrollController.position.pixels, // 回弹的距离
        duration: const Duration(milliseconds: 300), // 动画持续300毫秒
        curve: Curves.easeOut,
      );
    }

    // 设置查询结果
    setState(() {
      // 因为没有分页查询，所有这里直接替换已有的数组
      diaryList.addAll(newData);
      diaryCount = temp.total;
      currentPage++;
      // 重置状态为查询完成
      isLoading = false;
    });
  }

  /// 处理点击了搜索按钮
  _handleSearch() {
    // 取消键盘输入框聚焦
    FocusScope.of(context).unfocus();
    setState(() {
      diaryList.clear();
      currentPage = 1;
      query = searchController.text;
    });
    loadMoreDiary();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: RichText(
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          text: TextSpan(
            children: [
              TextSpan(
                text: CusAL.of(context).diaryLables("1"),
                style: TextStyle(fontSize: CusFontSizes.pageTitle),
              ),
              TextSpan(
                text: "\n${CusAL.of(context).itemCount(diaryCount)}",
                style: TextStyle(fontSize: CusFontSizes.pageAppendix),
              ),
            ],
          ),
        ),
      ),

      // 设置整个背景色为渐变色
      // body: DecoratedBox(
      //   decoration: const BoxDecoration(
      //       // 设置渐变色
      //       // gradient: LinearGradient(
      //       //   begin: Alignment.topCenter,
      //       //   end: Alignment.bottomCenter,
      //       //   colors: [Colors.blue, Colors.green],
      //       // ),
      //       // 纯背景色
      //       // color: Color.fromARGB(255, 219, 214, 223),
      //       ),
      //   child: Column(
      //     mainAxisSize: MainAxisSize.min,
      //     children: <Widget>[
      //       Expanded(
      //         child: _buildListArea(),
      //       ),
      //     ],
      //   ),
      // ),
      body: Column(
        children: [
          /// 搜索区域
          _buildSearchRowArea(),
          SizedBox(height: 5.sp),

          /// 食物列表区域
          Expanded(child: _buildListArea()),
        ],
      ),
    );
  }

  /// 查询条件输入行
  _buildSearchRowArea() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 10.sp),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: searchController,
              decoration: InputDecoration(
                hintText: CusAL.of(context).queryKeywordHintText(
                  CusAL.of(context).diary,
                ),
                // 设置透明底色
                filled: true,
                fillColor: Colors.transparent,
              ),
            ),
          ),
          TextButton(
            onPressed: _handleSearch,
            child: Text(CusAL.of(context).searchLabel),
          ),
        ],
      ),
    );
  }

  _buildListArea() {
    return ListView.builder(
      itemCount: diaryList.length + 1,
      controller: scrollController,
      shrinkWrap: true,
      itemBuilder: (context, index) {
        if (index == diaryList.length) {
          return buildLoader(isLoading);
        } else {
          // 示意图可以有多个，就去第一张好了
          var diaryItem = diaryList[index];

          return TimelineTile(
            alignment: TimelineAlign.manual,
            lineXY: 0.32,
            isFirst: index == 0,
            isLast: index == diaryList.length - 1,
            indicatorStyle: IndicatorStyle(
              width: 65,
              height: 40,
              indicator: _CusIndicator(
                category: '${diaryItem.category}',
                // borderColor: borderColor,
                borderColor: Theme.of(context).disabledColor,
              ),
              // 连接线是否画在图标的后面(默认是false，表示线没有画在图标后面)
              drawGap: true,
            ),
            beforeLineStyle: LineStyle(color: borderColor),
            startChild: _buildListStartChild(diaryItem),
            endChild: _buildListEndChild(diaryItem),
          );
        }
      },
    );
  }

  _buildListStartChild(Diary diaryItem) {
    // 创建时间(不使用最后修改时间是避免时间线显示出现时间不连续的尴尬)
    var createTime = DateFormat(constTimeFormat).format(
      DateTime.parse(diaryItem.gmtCreate ?? unknownDateTimeString),
    );

    var createDate = DateFormat(constDateFormat).format(
      DateTime.parse(diaryItem.gmtCreate ?? unknownDateTimeString),
    );
    return Container(
      // 内外边距
      // padding: EdgeInsets.all(5.sp),
      margin: EdgeInsets.all(5.sp),
      // 限制盒子最低高度
      constraints: BoxConstraints(minHeight: 40.sp),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(
            createDate,
            style: TextStyle(fontSize: CusFontSizes.pageSubContent),
          ),
          Text(
            createTime,
            style: TextStyle(fontSize: CusFontSizes.pageContent),
          ),
        ],
      ),
    );
  }

  _buildListEndChild(Diary diaryItem) {
    return GestureDetector(
      child: Card(
        elevation: 4,
        child: Container(
          constraints: BoxConstraints(minHeight: 80.sp),
          // 内外边距
          padding: EdgeInsets.all(2.sp),
          margin: EdgeInsets.all(2.sp),
          // color: Colors.transparent,
          // 装饰和颜色不能同时设置
          // decoration: BoxDecoration(
          //   border: Border.all(color: Colors.black54, width: 1),
          //   borderRadius: BorderRadius.circular(10),
          // ),
          // 不要用ListTile，很难看也很难布局
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Expanded(
                      flex: 4,
                      child: Text(
                        diaryItem.title,
                        maxLines: 2,
                        softWrap: true,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: Theme.of(context).primaryColor,
                          fontSize: CusFontSizes.itemTitle,
                        ),
                      )),
                  Expanded(
                    flex: 1,
                    child: Icon(
                      Icons.arrow_forward,
                      size: CusIconSizes.iconSmall,
                      color: Theme.of(context).primaryColor,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 5.sp),
              Wrap(
                // 子组件横向的间距
                // spacing: 2,
                // 子组件纵向的间距
                runSpacing: 5,
                // 排布方向
                alignment: WrapAlignment.start,
                children: [
                  // 分类放在连接指示器中了
                  // if (diaryItem.category != null)
                  //   buildTinyButtonTag(
                  //     diaryItem.category!,
                  //     bgColor: CusColors.cateTinyTagBg,
                  //     labelTextSize: CusFontSizes.flagTiny,
                  //   ),
                  // 先排除原本就是空字符串之后再分割
                  ...((diaryItem.mood != null &&
                              diaryItem.mood!.trim().isNotEmpty)
                          ? diaryItem.mood!.trim().split(",")
                          : [])
                      .map((mood) {
                    return buildTinyButtonTag(
                      mood,
                      bgColor: CusColors.moodTinyTagBg,
                      labelTextSize: CusFontSizes.flagMinute,
                    );
                  }),
                  ...((diaryItem.tags != null &&
                              diaryItem.tags!.trim().isNotEmpty)
                          ? diaryItem.tags!.trim().split(",")
                          : [])
                      .map((tag) {
                    return buildTinyButtonTag(
                      tag,
                      bgColor: CusColors.tagTinyTagBg,
                      labelTextSize: CusFontSizes.flagMinute,
                    );
                  }),
                ],
              ),
            ],
          ),
        ),
      ),
      onTap: () {
        Navigator.of(context)
            .push(
          MaterialPageRoute(
            builder: (BuildContext ctx) => DiaryModifyRichText(
              diaryItem: diaryItem,
            ),
          ),
        )
            .then((value) {
          // 编辑页面返回后，重新加载手记数据
          setState(() {
            currentPage = 1; // 数据库查询的时候会从0开始offset
            pageSize = 10;
            diaryList = [];
          });
          loadMoreDiary();
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
                CusAL.of(context).deleteNote('\n${diaryItem.title}'),
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
              await _dbHelper.deleteDiaryById(diaryItem.diaryId!);

              // 删除后重新查询
              setState(() {
                currentPage = 1; // 数据库查询的时候会从0开始offset
                pageSize = 10;
                diaryList.clear();
              });
              loadMoreDiary();
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
    );
  }
}

// 自定义的时间线指示器养蛇
class _CusIndicator extends StatelessWidget {
  const _CusIndicator({
    required this.category,
    required this.borderColor,
  });

  final String category;
  final Color borderColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.rectangle,
        border: Border.fromBorderSide(
          BorderSide(color: Colors.green, width: 4.sp),
        ),
        borderRadius: BorderRadius.all(Radius.circular(20.sp)),
      ),
      child: Center(
        child: Text(
          category,
          style: TextStyle(
            fontSize: CusFontSizes.pageSubContent,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
class ColorPicker extends StatefulWidget {
  /// Create a widget to select one color from a list.
  const ColorPicker({super.key,
    required this.onColorSelected,
    this.availableColors,
    this.initialColor,
    this.showTransparentColor = true,
    this.circleSize = 50,
  });

  /// Colors to choose from.
  ///
  /// Defaults to [ColorPicker.allColors].
  final List<Color>? availableColors;

  /// Color that starts out highlighted.
  ///
  /// When [initialColor] is null the transparent color is selected. When
  /// [showTransparentColor] is false as well no color is selected.
  final Color? initialColor;

  /// Called after a click on a color.
  final FutureOr<void> Function(Color? color) onColorSelected;

  /// Controls whether a option for selecting that no color is displayed.
  final bool showTransparentColor;

  /// List of all material colors and black/white
  static final List<Color> allColors = [
    const Color(0xFFFFFFFF),
    const Color(0xFF000000),
    Colors.red,
    Colors.redAccent,
    Colors.pink,
    Colors.pinkAccent,
    Colors.purple,
    Colors.purpleAccent,
    Colors.deepPurple,
    Colors.deepPurpleAccent,
    Colors.indigo,
    Colors.indigoAccent,
    Colors.blue,
    Colors.blueAccent,
    Colors.lightBlue,
    Colors.lightBlueAccent,
    Colors.cyan,
    Colors.cyanAccent,
    Colors.teal,
    Colors.tealAccent,
    Colors.green,
    Colors.greenAccent,
    Colors.lightGreen,
    Colors.lightGreenAccent,
    Colors.lime,
    Colors.limeAccent,
    Colors.yellow,
    Colors.yellowAccent,
    Colors.amber,
    Colors.amberAccent,
    Colors.orange,
    Colors.orangeAccent,
    Colors.deepOrange,
    Colors.deepOrangeAccent,
    Colors.brown,
    Colors.grey,
    Colors.blueGrey,
  ];

  /// Size of the color circles.
  final double circleSize;

  @override
  State<ColorPicker> createState() => _ColorPickerState();
}

class _ColorPickerState extends State<ColorPicker> {
  /// Currently selected color.
  late Color _selected;
  late final List<Color> availableColors;

  @override
  void initState() {
    super.initState();
    _selected = widget.initialColor ?? Colors.transparent;
    availableColors = widget.availableColors ?? ColorPicker.allColors;
  }
  @override
  Widget build(BuildContext context) => Wrap(
    children: [
      for (final color in availableColors)
        InkWell(
          onTap: () {
            setState(() {
              _selected = color;
              widget.onColorSelected(_selected);
            });
          },
          child: Container(
            decoration: BoxDecoration(
              color: _selected == color
                  ? Theme.of(context).disabledColor
                  : Colors.transparent,
              shape: BoxShape.circle,),
            padding: const EdgeInsets.all(5),
            child: Container(
              height: widget.circleSize,
              width: widget.circleSize,
              decoration: BoxDecoration(
                color: color,
                shape: BoxShape.circle,
              ),
            ),
          ),
        ),
      if (widget.showTransparentColor)
        InkWell(
          onTap: () {
            setState(() {
              _selected = Colors.transparent;
              widget.onColorSelected(_selected);
            });
          },
          child: Container(
            padding: const EdgeInsets.all(5),
            decoration: BoxDecoration(
              color: _selected == Colors.transparent
                  ? Theme.of(context).disabledColor
                  : Colors.transparent,
              shape: BoxShape.circle,),
            child: SizedBox(
              height: widget.circleSize,
              width: widget.circleSize,
              child: const Icon(Icons.block),
            ),
          ),
        ),
    ],
  );
}

/// Shows a dialog with a ColorPicker and with an cancel button inside.
///
/// Returns the selected color or null when cancel is pressed.
Future<Color?> showColorPickerDialog(
    BuildContext context, [
      Color? initialColor,
    ]) async => showDialog(
  context: context,
  builder: (_) => AlertDialog(
    contentPadding: const EdgeInsets.all(6.0),
    content: ColorPicker(
      initialColor: initialColor,
      onColorSelected: (color) {
        Navigator.pop(context, color);
      },
    ),
    actions: [
      TextButton(
        onPressed: Navigator.of(context).pop,
        child: Text('Cancel'),
      ),
    ],
  ),
);