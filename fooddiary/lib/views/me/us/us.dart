import 'package:flutter/material.dart';
import 'package:fit_track/views/base_view.dart';
import 'package:get/get.dart';

class UsPage extends StatelessWidget {
  const UsPage({super.key});
  WebviewGetxLogic get logic => Get.find<WebviewGetxLogic>();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('About Us'),
      ),
      body: const WebViewContainer(url: 'https://appfittrack.com'),
    );
  }
}
