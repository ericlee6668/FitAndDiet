import 'package:fit_track/main/themes/app_theme.dart';
import 'package:fit_track/main/themes/cus_font_size.dart';
import 'package:fit_track/views/home/health_tip_page.dart';
import 'package:fit_track/views/training/exercise/index.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class HomeExercisePage extends StatefulWidget  {
  const HomeExercisePage({super.key});

  @override
  State<HomeExercisePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomeExercisePage>
    with SingleTickerProviderStateMixin  {
  var pages = [const HealthTipPage(), const TrainingExercise()];
  var titles = ['Health Tip', 'Training Exercise'];
  late TabController tabController;
  var currentName = '';

  @override
  void initState() {
    currentName=titles[0];
        tabController = TabController(length: 2, vsync: this);
    tabController.addListener(() {
      setState(() {
        currentName = titles[tabController.index];
      });
    });
    super.initState();

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
    tabController.dispose();
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
              fontSize: currentName == e ? CusFontSizes.itemTitle : CusFontSizes.itemSubTitle,
              fontWeight: FontWeight.bold),
        )));
  }
}
