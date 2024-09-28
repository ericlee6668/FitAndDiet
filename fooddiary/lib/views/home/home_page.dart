import 'package:fit_track/main/themes/app_theme.dart';
import 'package:fit_track/main/themes/cus_font_size.dart';
import 'package:fit_track/views/home/health_tip_page.dart';
import 'package:fit_track/views/training/exercise/index.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class HomeExercisePage extends StatefulWidget {
  const HomeExercisePage({super.key});

  @override
  State<HomeExercisePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomeExercisePage>
    with SingleTickerProviderStateMixin {
  var pages = [const HealthTipPage(), const TrainingExercise()];
  var titles = ['HealthTip', 'TrainingExercise'];
  late TabController tabController;
  var currentName = 'HealthTip';

  @override
  void initState() {

    super.initState();
    tabController = TabController(length: 2, vsync: this);
    tabController.addListener(() {
      setState(() {
        currentName = titles[tabController.index];
      });
    });

    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.dark);
  }

  @override
  Widget build(BuildContext context) {
    return  Scaffold(
        extendBodyBehindAppBar: false,
        body: Column(
          children: [
            const SizedBox(height: kToolbarHeight,),
            TabBar(
                controller: tabController,
                tabs: titles.map((e) => _buildTileTab(e)).toList()),
            Expanded(
              child: TabBarView(
                controller: tabController,
                children: pages,
              ),
            ),
          ],
        ),
      );
  }
  @override
  void dispose() {
    tabController.dispose(); // 释放 TabController
    super.dispose();
  }
  Widget _buildTileTab(String e) {
    return SizedBox(
        height: 40,
        child: Center(
            child: Text(
          e,
          style: TextStyle(
              color: currentName == e ? AppTheme.text0 : Colors.grey,
              fontSize: currentName == e ? CusFontSizes.itemSubTitle : CusFontSizes.itemTitle,
              fontWeight: FontWeight.bold),
        )));
  }
}
