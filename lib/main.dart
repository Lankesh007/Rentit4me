
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:rentit4me_new/blocs/network_bloc/network_bloc.dart';
import 'package:rentit4me_new/views/splash_screen.dart';
import 'package:flutter_bloc/flutter_bloc.dart';



void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  // FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  // await flutterLocalNotificationsPlugin
  //     .resolvePlatformSpecificImplementation<
  //         AndroidFlutterLocalNotificationsPlugin>()
  //     ?.createNotificationChannel(channel);

  // await FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(
  //   alert: true,
  //   badge: true,
  //   sound: true,
  // );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key key}) : super(key: key);

  // This widget is the root of your application.
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
}
