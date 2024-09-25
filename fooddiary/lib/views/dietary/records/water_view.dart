// import 'package:financialtools/main.dart';
import 'package:fit_track/main/themes/app_theme.dart';
import 'package:fit_track/views/dietary/records/water_logic.dart';
import 'package:fit_track/views/dietary/records/wave_view.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class WaterView extends StatefulWidget {
  const WaterView(
      {Key? key, this.mainScreenAnimationController, this.mainScreenAnimation})
      : super(key: key);

  final AnimationController? mainScreenAnimationController;
  final Animation<double>? mainScreenAnimation;

  @override
  _WaterViewState createState() => _WaterViewState();
}

class _WaterViewState extends State<WaterView> with TickerProviderStateMixin {
  Future<bool> getData() async {
    await Future<dynamic>.delayed(const Duration(milliseconds: 50));
    return true;
  }

  WaterLogic get logic => Get.put(WaterLogic());

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(
          left: 24, right: 24, top: 16, bottom: 18),
      child: Container(
        decoration: BoxDecoration(
          color: AppTheme.white,
          borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(8.0),
              bottomLeft: Radius.circular(8.0),
              bottomRight: Radius.circular(8.0),
              topRight: Radius.circular(68.0)),
          boxShadow: <BoxShadow>[
            BoxShadow(
                color: AppTheme.grey.withOpacity(0.2),
                offset: const Offset(1.1, 1.1),
                blurRadius: 10.0),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.only(
              top: 16, left: 16, right: 16, bottom: 16),
          child: Row(
            children: <Widget>[
              Expanded(
                child: Column(
                  children: <Widget>[
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: <Widget>[
                            Padding(
                              padding:
                                  const EdgeInsets.only(left: 4, bottom: 3),
                              child: Obx(() => Text(
                                    logic.waterDrink.value.toString(),
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(
                                      fontFamily:
                                          AppTheme.fontName,
                                      fontWeight: FontWeight.w600,
                                      fontSize: 32,
                                      color: AppTheme
                                          .nearlyDarkBlue,
                                    ),
                                  )),
                            ),
                            const Padding(
                              padding:
                                  EdgeInsets.only(left: 8, bottom: 8),
                              child: Text(
                                'ml',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontFamily: AppTheme.fontName,
                                  fontWeight: FontWeight.w500,
                                  fontSize: 18,
                                  letterSpacing: -0.2,
                                  color: AppTheme.nearlyDarkBlue,
                                ),
                              ),
                            ),
                          ],
                        ),
                        Padding(
                          padding: EdgeInsets.only(
                              left: 4, top: 2, bottom: 14),
                          child: Text(
                            'of daily goal ${logic.waterTotal.value.toString()} ml',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontFamily: AppTheme.fontName,
                              fontWeight: FontWeight.w500,
                              fontSize: 14,
                              letterSpacing: 0.0,
                              color: AppTheme.darkText,
                            ),
                          ),
                        ),
                      ],
                    ),
                    Padding(
                      padding: const EdgeInsets.only(
                          left: 4, right: 4, top: 8, bottom: 16),
                      child: Container(
                        height: 2,
                        decoration: const BoxDecoration(
                          color: AppTheme.background,
                          borderRadius:
                              BorderRadius.all(Radius.circular(4.0)),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 16),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: <Widget>[
                          Padding(
                            padding: const EdgeInsets.only(top: 4),
                            child: Row(
                              mainAxisAlignment:
                                  MainAxisAlignment.start,
                              crossAxisAlignment:
                                  CrossAxisAlignment.center,
                              children: <Widget>[
                                SizedBox(
                                  width: 24,
                                  height: 24,
                                  child: Image.asset(
                                      'assets/covers/bell.png'),
                                ),
                                const Flexible(
                                  child: Text(
                                    'Drinking water is good for your health.',
                                    textAlign: TextAlign.start,
                                    style: TextStyle(
                                      fontFamily:
                                          AppTheme.fontName,
                                      fontWeight: FontWeight.w500,
                                      fontSize: 12,
                                      letterSpacing: 0.0,
                                      // color: HexColor('#F65283'),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    )
                  ],
                ),
              ),
              SizedBox(
                width: 34,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    InkWell(
                      onTap: () {
                        logic.drinkwater();
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          color: AppTheme.nearlyWhite,
                          shape: BoxShape.circle,
                          boxShadow: <BoxShadow>[
                            BoxShadow(
                                color: AppTheme.nearlyDarkBlue
                                    .withOpacity(0.4),
                                offset: const Offset(4.0, 4.0),
                                blurRadius: 8.0),
                          ],
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(6.0),
                          child: Icon(
                            Icons.add,
                            color: AppTheme.nearlyDarkBlue,
                            size: 24,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(
                      height: 28,
                    ),
                    InkWell(
                      onTap: () {
                        logic.reducewater();
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          color: AppTheme.nearlyWhite,
                          shape: BoxShape.circle,
                          boxShadow: <BoxShadow>[
                            BoxShadow(
                                color: AppTheme.nearlyDarkBlue
                                    .withOpacity(0.4),
                                offset: const Offset(4.0, 4.0),
                                blurRadius: 8.0),
                          ],
                        ),
                        child: const Padding(
                          padding: EdgeInsets.all(6.0),
                          child: Icon(
                            Icons.remove,
                            color: AppTheme.nearlyDarkBlue,
                            size: 24,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding:
                    const EdgeInsets.only(left: 16, right: 8, top: 16),
                child: Container(
                  width: 60,
                  height: 160,
                  decoration: BoxDecoration(
                    color: Color(0xffE8EDFE),
                    borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(80.0),
                        bottomLeft: Radius.circular(80.0),
                        bottomRight: Radius.circular(80.0),
                        topRight: Radius.circular(80.0)),
                    boxShadow: <BoxShadow>[
                      BoxShadow(
                          color: AppTheme.grey.withOpacity(0.4),
                          offset: const Offset(2, 2),
                          blurRadius: 4),
                    ],
                  ),
                  child: Obx(() {
                    var value = logic.waterDrink.value /
                        logic.waterTotal.value *
                        100;
                    value = value >= 100.0 ? 100 : value;

                    return WaveView(
                      percentageValue: value,
                    );
                  }),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
