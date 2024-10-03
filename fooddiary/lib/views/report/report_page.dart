import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../main/themes/app_theme.dart';
import '../../main/themes/cus_font_size.dart';
import '../dietary/reports/index.dart';
import '../training/reports/index.dart';

class ReportPage extends StatefulWidget {
  const ReportPage({super.key});

  @override
  State<ReportPage> createState() => _ReportPageState();
}

class _ReportPageState extends State<ReportPage>
    with SingleTickerProviderStateMixin {
  var pages = [const TrainingReports(), const DietaryReports()];
  var titles = ['Training Report', 'Dietary Report'];
  late TabController tabController;
  var currentName = '';

  @override
  void initState() {
    currentName = titles[0];
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
    return CupertinoPageScaffold(
      child:  Column(
        children: [
          const SizedBox(
            height: kToolbarHeight,
          ),
          TabBar(
              controller: tabController,
              indicator: const BoxDecoration(),
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
              fontSize: currentName == e
                  ? CusFontSizes.itemTitle
                  : CusFontSizes.itemSubTitle,
              fontWeight: FontWeight.bold),
        )));
  }
}
