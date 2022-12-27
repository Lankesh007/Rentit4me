import 'dart:convert';
import 'dart:developer';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:in_app_update/in_app_update.dart';
import 'package:rentit4me_new/blocs/network_bloc/network_bloc.dart';
import 'package:rentit4me_new/views/PushNotificationService.dart';
import 'package:rentit4me_new/views/splash_screen.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:upgrader/upgrader.dart';

// const AndroidNotificationChannel channel = AndroidNotificationChannel(
//   "id",
//   "name",
//   importance: Importance.high,
//   playSound: true,
// );
// final navigatorKey = GlobalKey<NavigatorState>();

// final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
//     FlutterLocalNotificationsPlugin();

// Future<void> _firebaseMessangingBackgroundHandler(RemoteMessage message) async {
//   final FlutterLocalNotificationsPlugin flutterLocalNotify =
//       FlutterLocalNotificationsPlugin();
//   var initializationSettingsAndroid =
//       AndroidInitializationSettings('@mipmap/ic_launcher');
//   var initializationSettingsIOS = IOSInitializationSettings();

//   var initializationSettings = InitializationSettings(
//       android: initializationSettingsAndroid, iOS: initializationSettingsIOS);
//   flutterLocalNotify.initialize(
//     initializationSettings,
//   );

//   log('A new onMessagep event was published!${message.data['title']}     ${message.data['message']}');

//   log('Data----->   ${message.data}');

//   RemoteNotification notification = message.notification;
//   AndroidNotification android = message.notification.android;
//   if (notification != null && android != null) {
//     flutterLocalNotify.show(
//       notification.hashCode,
//       message.data['title'],
//       message.data['message'],
//       NotificationDetails(
//         android: AndroidNotificationDetails(
//           'channel_ID',
//           'channel name',
//           channelDescription: 'channel description',
//           importance: Importance.max,
//           playSound: true,
//           showProgress: true,
//           priority: Priority.high,
//           ticker: 'test ticker',
//         ),
//       ),
//       payload: json.encode(message.data),
//       // payload: message.data['payload']
//     );
//   } else {
//     log("----->NO data Found !!");
//   }
// }

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Upgrader.clearSavedSettings();

  await PushNotificationService().setupInteractedMessage();

  // await Firebase.initializeApp();
  // FirebaseMessaging.onBackgroundMessage(_firebaseMessangingBackgroundHandler);
  // await flutterLocalNotificationsPlugin
  //     .resolvePlatformSpecificImplementation<
  //         AndroidFlutterLocalNotificationsPlugin>()
  //     ?.createNotificationChannel(channel);
  // await FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(
  //   alert: true,
  //   badge: true,
  //   sound: true,
  // );
  runApp(MyApp());
  RemoteMessage initialMessage =
      await FirebaseMessaging.instance.getInitialMessage();
  if (initialMessage != null) {
    // App received a notification when it was killed
  }
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
    // showNotify();
    checkForUpdate();
    super.initState();
  }

  AppUpdateInfo _updateInfo;

  GlobalKey<ScaffoldState> scaffoldKey = GlobalKey();

  bool _flexibleUpdateAvailable = false;

  // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> checkForUpdate() async {
    InAppUpdate.checkForUpdate().then((info) {
      setState(() {
        _updateInfo = info;
      });
    }).catchError((e) {
      showSnack(e.toString());
    });
  }

  void showSnack(String text) {
    if (scaffoldKey.currentContext != null) {
      ScaffoldMessenger.of(scaffoldKey.currentContext)
          .showSnackBar(SnackBar(content: Text(text)));
    }
  }

  bool updateer = false;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
        create: (context) => InternetBloc(),
        child: MaterialApp(
            debugShowCheckedModeBanner: false,
            title: 'Rentit4me',
            theme: ThemeData(
              fontFamily: "Regular",
              primarySwatch: Colors.indigo,
            ),
            home: SplashScreen())
        //  MaterialApp(
        //     debugShowCheckedModeBanner: false,
        //     //theme: lightThemeData(context),
        //     //darkTheme: darkThemeData(context),
        //     title: 'Rentit4me',
        //     theme: ThemeData(
        //       fontFamily: "Regular",
        //       primarySwatch: Colors.indigo,
        //     ),
        //     home: Scaffold(),

        //   ),
        );
  }

  // showNotify() async {
  //   final FlutterLocalNotificationsPlugin flutterLocalNotify =
  //       FlutterLocalNotificationsPlugin();
  //   var initializationSettingsAndroid =
  //       AndroidInitializationSettings('@mipmap/ic_launcher');
  //   var initializationSettingsIOS = IOSInitializationSettings();

  //   var initializationSettings = InitializationSettings(
  //       android: initializationSettingsAndroid, iOS: initializationSettingsIOS);
  //   flutterLocalNotify.initialize(initializationSettings,
  //       onSelectNotification: onSelectNotification);

  //   FirebaseMessaging.onMessage.listen(
  //     (RemoteMessage message) {
  //       log("All data--->${message.notification}");
  //       log('As new onMessagep event was published!${message.notification.title}     ${message.notification.body}');

  //       // log('Data----->   ${message.data}');

  //       RemoteNotification notification = message.notification;
  //       AndroidNotification android = message.notification.android;
  //       // log("A--->${message.notification.android}");
  //       // log("N--->${message.notification.body}");

  //       if (notification != null && android != null) {
  //         flutterLocalNotify.show(
  //           notification.hashCode,
  //           message.notification.title,
  //           message.notification.body,
  //           NotificationDetails(
  //             android: AndroidNotificationDetails(
  //               'channel_ID',
  //               'channel name',
  //               channelDescription: 'channel description',
  //               importance: Importance.max,
  //               playSound: true,
  //               showProgress: true,
  //               priority: Priority.high,
  //               ticker: 'test ticker',
  //             ),
  //           ),
  //           payload: json.encode(message.data),
  //           // payload: message.data['payload']
  //         );
  //       } else {
  //         log("No data found!!");
  //       }
  //       /*   Navigator.of(context).push(
  //         MaterialPageRoute(
  //           builder: (context) => OrderDetails(
  //             deliveryBoyId: message.data['deliveruboyid'].toString(),
  //             orderId: message.data['order_id'].toString(),
  //             userId: message.data['user_id'].toString(),
  //           ),
  //         ),
  //       ); */
  //       // }
  //     },
  //   );

  //   FirebaseMessaging.onMessageOpenedApp.listen(
  //     (RemoteMessage message) {
  //       log('A new onMessageOpenedApp event was published!');
  //       RemoteNotification notification = message.notification;
  //       AndroidNotification android = message.notification.android;

  //       if (notification != null && android != null) {
  //         flutterLocalNotify.show(
  //           notification.hashCode,
  //           message.data['title'],
  //           message.data['message'],
  //           NotificationDetails(
  //             android: AndroidNotificationDetails(
  //               'channel_ID',
  //               'channel name',
  //               channelDescription: 'channel description',
  //               importance: Importance.max,
  //               playSound: true,
  //               showProgress: true,
  //               priority: Priority.high,
  //               ticker: 'test ticker',
  //             ),
  //           ),
  //           payload: json.encode(message.data),
  //           // payload: message.data['payload']
  //         );
  //         /*  Navigator.of(context).push(
  //         MaterialPageRoute(
  //           builder: (context) => OrderDetails(
  //             deliveryBoyId: message.data['deliveruboyid'].toString(),
  //             orderId: message.data['order_id'].toString(),
  //             userId: message.data['user_id'].toString(),
  //           ),
  //         ),
  //       ); */
  //       } else {
  //         print("No data");
  //       }
  //     },
  //   );
  // }

}
