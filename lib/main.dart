import 'dart:convert';
import 'dart:developer';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:rentit4me_new/blocs/network_bloc/network_bloc.dart';
import 'package:rentit4me_new/views/splash_screen.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

const AndroidNotificationChannel channel = AndroidNotificationChannel(
  "id",
  "name",
  importance: Importance.high,
  playSound: true,
);
final navigatorKey = GlobalKey<NavigatorState>();

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

Future<void> _firebaseMessangingBackgroundHandler(RemoteMessage message) async {
  final FlutterLocalNotificationsPlugin flutterLocalNotify =
      FlutterLocalNotificationsPlugin();
  var initializationSettingsAndroid =
      AndroidInitializationSettings('@mipmap/ic_launcher');
  var initializationSettingsIOS = IOSInitializationSettings();

  var initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid, iOS: initializationSettingsIOS);
  flutterLocalNotify.initialize(
    initializationSettings,
  );

  log('A new onMessagep event was published!${message.data['title']}     ${message.data['message']}');

  log('Data----->   ${message.data}');

  RemoteNotification notification = message.notification;
  AndroidNotification android = message.notification?.android;
  if (notification != null && android != null) {
    flutterLocalNotify.show(
      notification.hashCode,
      message.data['title'],
      message.data['message'],
      NotificationDetails(
        android: AndroidNotificationDetails(
          'channel_ID',
          'channel name',
          channelDescription: 'channel description',
          importance: Importance.max,
          playSound: true,
          showProgress: true,
          priority: Priority.high,
          ticker: 'test ticker',
        ),
      ),
      payload: json.encode(message.data),
      // payload: message.data['payload']
    );
  } else {
    log("----->NO data Found !!");
  }
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  FirebaseMessaging.onBackgroundMessage(_firebaseMessangingBackgroundHandler);
  await flutterLocalNotificationsPlugin
      .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>()
      ?.createNotificationChannel(channel);
  await FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(
    alert: true,
    badge: true,
    sound: true,
  );
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({Key key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  Future onSelectNotification(String payload) async {
    Map data = json.decode(payload);
    log('message======>>>>  $data');
  }

  @override
  void initState() {
    showNotify();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => InternetBloc(),
      child: MaterialApp(
          debugShowCheckedModeBanner: false,
          //theme: lightThemeData(context),
          //darkTheme: darkThemeData(context),
          title: 'Rentit4me',
          theme: ThemeData(
            fontFamily: "Regular",
            primarySwatch: Colors.indigo,
          ),
          home: SplashScreen()
          // home: PersonalDetailScreen(),
          //home: SignupConsumerScreen(),
          //home: SignupScreen(),
          //home: const CurrentUserLocationScreen(),
          ),
    );
  }

  showNotify() async {
    final FlutterLocalNotificationsPlugin flutterLocalNotify =
        FlutterLocalNotificationsPlugin();
    var initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    var initializationSettingsIOS = IOSInitializationSettings();

    var initializationSettings = InitializationSettings(
        android: initializationSettingsAndroid, iOS: initializationSettingsIOS);
    flutterLocalNotify.initialize(initializationSettings,
        onSelectNotification: 
        
        onSelectNotification);

    FirebaseMessaging.onMessage.listen(
      (RemoteMessage message) {
        log('Ass new onMessagep event was published!${message.data['title']}     ${message.data['message']}');

        log('Data----->   ${message.data}');

        RemoteNotification notification = message.notification;
        // if (notification != null && android != null) {
        flutterLocalNotify.show(
          notification.hashCode,
          message.data['title'],
          message.data['message'],
          NotificationDetails(
            android: AndroidNotificationDetails(
              'channel_ID',
              'channel name',
              channelDescription: 'channel description',
              importance: Importance.max,
              playSound: true,
              showProgress: true,
              priority: Priority.high,
              ticker: 'test ticker',
            ),
          ),
          payload: json.encode(message.data),
          // payload: message.data['payload']
        );
        /*   Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => OrderDetails(
              deliveryBoyId: message.data['deliveruboyid'].toString(),
              orderId: message.data['order_id'].toString(),
              userId: message.data['user_id'].toString(),
            ),
          ),
        ); */
        // }
      },
    );
    FirebaseMessaging.onMessageOpenedApp.listen(
      (RemoteMessage message) {
        log('A new onMessageOpenedApp event was published!');
        RemoteNotification notification = message.notification;
        AndroidNotification android = message.notification?.android;

        // if (notification != null && android != null) {
        flutterLocalNotify.show(
          notification.hashCode,
          message.data['title'],
          message.data['message'],
          NotificationDetails(
            android: AndroidNotificationDetails(
              'channel_ID',
              'channel name',
              channelDescription: 'channel description',
              importance: Importance.max,
              playSound: true,
              showProgress: true,
              priority: Priority.high,
              ticker: 'test ticker',
            ),
          ),
          payload: json.encode(message.data),
          // payload: message.data['payload']
        );
        /*  Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => OrderDetails(
              deliveryBoyId: message.data['deliveruboyid'].toString(),
              orderId: message.data['order_id'].toString(),
              userId: message.data['user_id'].toString(),
            ),
          ),
        ); */
      },
    );
  }
}
