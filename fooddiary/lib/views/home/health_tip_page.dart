import 'package:fit_track/views/home/health_tip_detail_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';

class HealthTipPage extends StatelessWidget {
  const HealthTipPage({super.key});

  Widget _buildHealthTipItem(BuildContext context, HealthTip healthTip, int index) {
    return PureInkWell(
      onTap: () {
        Navigator.of(context).push(MaterialPageRoute(builder: (context) {
          return HealthTipDetailPage(healthTip,index);
        })
        ).then((value) =>
        Future.delayed(const Duration(milliseconds: 200)).then((value) =>
            SystemChrome.setSystemUIOverlayStyle(
              const SystemUiOverlayStyle(
                statusBarIconBrightness: Brightness.dark, // 设置状态栏图标为黑色
                statusBarBrightness: Brightness.light,    // 设置iOS状态栏文本为黑色
              ),
            )
        )
        );
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          verticalDirection: VerticalDirection.up,
          children: <Widget>[
            Hero(
              tag: healthTip.image!,
              child: Image.asset(healthTip.image!,fit: BoxFit.contain,),
            ),
            FractionalTranslation(
              translation: const Offset(0, 0.25),
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xffFCFBFB),
                  border: Border.all(color: const Color(0xffD4D4D4)),
                  borderRadius: const BorderRadius.all(
                    Radius.circular(14),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      healthTip.title!,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(
                      height: 12,
                    ),
                    Text(
                      healthTip.shortContent!,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 14,
                        color: Color(0xff343334),
                      ),
                    )
                  ],
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return  Container(
        color: Colors.white,
        child: ListView.builder(
          padding: EdgeInsets.zero,
          itemBuilder: (_, index) =>
              _buildHealthTipItem(context, healTips[index],index),
          itemCount: healTips.length,
        ),
      );
  }
}

class PureInkWell extends StatelessWidget {
  final Function()? onTap;
  final Widget? child;

  PureInkWell({this.onTap, this.child});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: this.onTap,
      splashColor: Colors.transparent,
      hoverColor: Colors.transparent,
      focusColor: Colors.transparent,
      highlightColor: Colors.transparent,
      child: this.child,
    );
  }
}

class HealthTip {
  final String? title;
  final String? shortContent;
  final String? image;

  HealthTip({
    @required this.title,
    @required this.shortContent,
    @required this.image,
  });
}

final healTips = <HealthTip>[
  HealthTip(
    title: "A Diet Without Exercise is Useless.",
    shortContent:
        """Interval Training is a form of exercise in which you alternate between two or more different...""",
    image: "assets/healtip/healtip1.png",
  ),
  HealthTip(
    title: "Garlic As fresh and Sweet as baby's Breath.",
    shortContent:
        """Garlic is the plant in the onion family that's grown alternate between  or more exercise...""",
    image: "assets/healtip/healtip2.png",
  ),
  HealthTip(
    title: "How to Building a Strong Body",
    shortContent:
        """Incorporate at least 30 minutes of moderate exercise, like walking or cycling, into your routine...""",
    image: "assets/healtip/healtip3.png",
  ),
];
