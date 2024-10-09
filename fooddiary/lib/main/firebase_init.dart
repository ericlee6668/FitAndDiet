import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:fit_track/main/home_page.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';

class FirebaseService {
  final _localNotifications = FlutterLocalNotificationsPlugin();
  final _androidChannel =
      const AndroidNotificationChannel('title', 'EE88', // 这些信息根据自己的app定义
          description: "ios des",
          importance: Importance.defaultImportance);

  Future<void> initNotifications() async {
    try {
      _requestPermissions();
      // //后台运行通知回调
      // FirebaseMessaging.onBackgroundMessage( _firebaseMessagingBackgroundHandler);
      //前台运行通知回调
      FirebaseMessaging.onMessage.listen(handleMessage);
      //监听后台运行时通过系统信息打开应用
      FirebaseMessaging.onMessageOpenedApp.listen(onMessageOpenedApp);
      const android = AndroidInitializationSettings('@mipmap/ic_launcher');
      const iOS = DarwinInitializationSettings();
      InitializationSettings settings = const InitializationSettings(android: android, iOS: iOS);

      await _localNotifications.initialize(settings,
          onDidReceiveNotificationResponse: (NotificationResponse response) {
        //  前台消息点击
        final message =
            RemoteMessage.fromMap(jsonDecode(response.payload ?? ''));
        print(response.toString());
        // 处理收到消息
        handleFrontMessage(message);
      });
      final platform =
          _localNotifications.resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>();
      await platform?.createNotificationChannel(_androidChannel);
    } catch (e) {
      print('FirebaseMessaging:error$e');
    }
  }
  Future<void> _requestPermissions() async {
    if (Platform.isIOS || Platform.isMacOS) {
      await _localNotifications
          .resolvePlatformSpecificImplementation<
          IOSFlutterLocalNotificationsPlugin>()
          ?.requestPermissions(
        alert: true,
        badge: true,
        sound: true,
      );
      await _localNotifications
          .resolvePlatformSpecificImplementation<
          MacOSFlutterLocalNotificationsPlugin>()
          ?.requestPermissions(
        alert: true,
        badge: true,
        sound: true,
      );
    } else if (Platform.isAndroid) {
      final AndroidFlutterLocalNotificationsPlugin? androidImplementation =
      _localNotifications.resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>();

      final bool? grantedNotificationPermission =
      await androidImplementation?.requestNotificationsPermission();
      print('User granted permission: $grantedNotificationPermission');

    }
  }

  void onMessageOpenedApp(RemoteMessage message) {
    print('FirebaseMessaging:后台运行打开通知');
    Get.to(const HomePage());
  }

  void handleMessage(RemoteMessage? message) {
    if (message == null) return;
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
        ),
        iOS: const DarwinNotificationDetails()
        ),
        payload: jsonEncode(message.toMap()));
  }

  //前台消息点击处理
  void handleFrontMessage(RemoteMessage message) {
    print('FirebaseMessaging:前台运行打开通知');
  }
  //测试通知
  var id=0;
  Future<void> testNotification() async {
    const AndroidNotificationDetails androidNotificationDetails =
    AndroidNotificationDetails('your channel id', 'your channel name',
        channelDescription: 'your channel description',
        importance: Importance.max,
        priority: Priority.high,
        ticker: 'ticker');
    const NotificationDetails notificationDetails =
    NotificationDetails(android: androidNotificationDetails);
    await _localNotifications.show(
        id++, 'plain title', 'plain body', notificationDetails,
        payload: 'item x');
  }
}
class ReceivedNotification {
  ReceivedNotification({
    required this.id,
    required this.title,
    required this.body,
    required this.payload,
  });

  final int id;
  final String? title;
  final String? body;
  final String? payload;
}