import 'package:fit_track/common/global/constants.dart';
import 'package:fit_track/main/themes/app_theme.dart';
import 'package:fit_track/main/themes/cus_font_size.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// 子组件是带text的容器的卡片
/// 用于显示模块首页一排两列的标题
buildSmallCoverCard(
  BuildContext context,
  Widget widget,
  String title, {
  String? routeName,
}) {
  return Card(
    clipBehavior: Clip.hardEdge,
    elevation: 5,
    child: InkWell(
      splashColor: Theme.of(context).splashColor,
      onTap: () {
        if (routeName != null) {
          // 这里需要使用pushName 带上指定的路由名称，后续跨层级popUntil的时候才能指定路由名称进行传参
          Navigator.pushNamed(context, routeName);
        } else {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (BuildContext ctx) => widget,
            ),
          );
        }
      },
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Icon(
            Icons.bar_chart,
            size: 72.sp,
          ),
          Center(
            child: Text(
              title,
              style: TextStyle(
                fontSize: 20.sp,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).primaryColor,
              ),
            ),
          ),
        ],
      ),
      // child: Container(
      //   color: Theme.of(context).secondaryHeaderColor,
      //   child: Center(
      //     child: Text(
      //       title,
      //       style: TextStyle(
      //         fontSize: 20.sp,
      //         fontWeight: FontWeight.bold,
      //         color: Theme.of(context).primaryColor,
      //       ),
      //     ),
      //   ),
      // ),
    ),
  );
}

/// 子组件是带listtile和图片的一行row容器的卡片
/// 用于显示模块首页一排一个带封面图的标题
buildCoverCard(
  BuildContext context,
  Widget widget,
  String title,
  String subtitle,
  String imageUrl, {
  String? routeName,
}) {
  return Card(
    clipBehavior: Clip.hardEdge,
    elevation: 5,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
    margin: const EdgeInsets.all(8),
    child: InkWell(
      onTap: () {
        if (routeName != null) {
          // 这里需要使用pushName 带上指定的路由名称，后续跨层级popUntil的时候才能指定路由名称进行传参
          Navigator.pushNamed(context, routeName);
        } else {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (BuildContext ctx) => widget,
            ),
          );
        }
      },
      child: Row(
        children: [
          Padding(
            padding: EdgeInsets.only(left: 5.sp),
            child: Image.asset(
              imageUrl,
              fit: BoxFit.contain,
              height: 45,
              width: 45,
            ),
          ),
          const SizedBox(width: 5),
          Expanded(
            child:
                Column(mainAxisAlignment: MainAxisAlignment.center, children: [
              Text(
                title,
                maxLines: 2,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 13.sp,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).primaryColor,
                ),
              ),
              SizedBox(
                width: 100.w,
                child: Text(
                  textAlign: TextAlign.center,
                  subtitle,
                  maxLines: 2,
                  style: TextStyle(
                    fontSize: 12.sp,
                  ),
                ),
              ),
            ]),
          ),
        ],
      ),
    ),
  );
}

buildCardContainer({Widget? child, double? radius, BuildContext? context}) {
  return Container(
    decoration: BoxDecoration(
      color:
          box.read('mode') == 'light' ? Colors.white : const Color(0xff232229),
      borderRadius: BorderRadius.only(
          topLeft: Radius.circular(radius ?? 8),
          bottomLeft: Radius.circular(radius ?? 8),
          bottomRight: Radius.circular(radius ?? 8),
          topRight: Radius.circular(radius ?? 8)),
      boxShadow: <BoxShadow>[
        BoxShadow(
            color: AppTheme.grey.withOpacity(0.2),
            offset: const Offset(1.1, 1.1),
            blurRadius: 10.0),
      ],
    ),
    child: Padding(
      padding: const EdgeInsets.all(16),
      child: child,
    ),
  );
}

buildCardContainer2(
  BuildContext context,
  Widget widget,
  String title,
  String subtitle,
  String imageUrl, {
  String? routeName,
}) {
  return Container(
    decoration: BoxDecoration(
      color:
          box.read('mode') == 'light' ? Colors.white : const Color(0xff232229),
      borderRadius: const BorderRadius.only(
          topLeft: Radius.circular( 8),
          bottomLeft: Radius.circular( 8),
          bottomRight: Radius.circular( 8),
          topRight: Radius.circular( 8)),
      boxShadow: <BoxShadow>[
        BoxShadow(
            color: AppTheme.grey.withOpacity(0.2),
            offset: const Offset(1.1, 1.1),
            blurRadius: 10.0),
      ],
    ),
    child: CupertinoButton(
      pressedOpacity: 0.8,
      onPressed: () {
        if (routeName != null) {
          // 这里需要使用pushName 带上指定的路由名称，后续跨层级popUntil的时候才能指定路由名称进行传参
          Navigator.pushNamed(context, routeName);
        } else {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (BuildContext ctx) => widget,
            ),
          );
        }
      },
      child: Row(
        children: [
          Padding(
            padding: EdgeInsets.only(left: 5.sp),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: Image.asset(
                imageUrl,
                fit: BoxFit.contain,
                height: 165,
                width: 165,
              ),
            ),
          ),
          const SizedBox(width: 5),
          Expanded(
            child:
            Column(mainAxisAlignment: MainAxisAlignment.center, children: [
              Text(
                title,
                maxLines: 2,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: CusFontSizes.itemTitle,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).primaryColor,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                textAlign: TextAlign.center,
                subtitle,
                maxLines: 1,
                style: TextStyle(
                  fontSize: 12.sp,
                  color: Colors.black87
                ),
              ),
            ]),
          ),
        ],
      ),
    ),
  );
}
