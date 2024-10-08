import 'dart:convert';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:fit_track/main/home_page.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';

// @pragma('vm:entry-point')
// Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
//   // If you're going to use other Firebase services in the background, such as Firestore,
//   // make sure you call `initializeApp` before using other Firebase services.
//   await Firebase.initializeApp();
//
//   print("FirebaseMessaging:Handling a background message: ${message.messageId}");
// }
class FirebaseService{
  final _firebaseMessaging = FirebaseMessaging.instance;
  final _localNotifications = FlutterLocalNotificationsPlugin();
  final _androidChannel = const AndroidNotificationChannel(
      'title', '2010.com',  // 这些信息根据自己的app定义
      description: "android fds",
      importance: Importance.defaultImportance);

  Future<void>  initNotifications() async{
    try{
      await _firebaseMessaging.requestPermission();
      final fcmToken = await _firebaseMessaging.getToken();
      // //后台运行通知回调
      // FirebaseMessaging.onBackgroundMessage( _firebaseMessagingBackgroundHandler);
      //前台运行通知回调
      FirebaseMessaging.onMessage.listen(handleMessage);
      //监听后台运行时通过系统信息打开应用
      FirebaseMessaging.onMessageOpenedApp.listen(onMessageOpenedApp);
      print('FirebaseMessaging Token:${fcmToken}');
      const android = AndroidInitializationSettings('@mipmap/ic_launcher');
      const iOS = DarwinInitializationSettings();
      const settings = InitializationSettings(android: android, iOS: iOS);

      await _localNotifications.initialize(settings,
          onDidReceiveNotificationResponse: (NotificationResponse response) {
            // android 前台消息点击
            final message = RemoteMessage.fromMap(jsonDecode(response.payload??''));
            print(response.toString());
            // 处理收到消息
            handleFrontMessage(message);
          });
      final platform = _localNotifications.resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>();
      await platform?.createNotificationChannel(_androidChannel);
    }catch(e){
      print('FirebaseMessaging:error');
    }

  }
  void onMessageOpenedApp(RemoteMessage message){
    print('FirebaseMessaging:后台运行打开通知');
    Get.to(HomePage());

  }
  void handleMessage(RemoteMessage? message){
    if(message==null) return;
    print('FirebaseMessaging:前台通知');
    final notification = message.notification;
    if (notification == null) return;
    _localNotifications.show(
        notification.hashCode,
        notification.title,
        notification.body,
        NotificationDetails(
            android: AndroidNotificationDetails(
              _androidChannel.id,
              _androidChannel.name,
              channelDescription: _androidChannel.description,
              icon: '@mipmap/ic_launcher',
            )),
        payload: jsonEncode(message.toMap()));
  }
  //前台消息点击处理
  void handleFrontMessage(RemoteMessage message) {
    print('FirebaseMessaging:前台运行打开通知');
  }


}