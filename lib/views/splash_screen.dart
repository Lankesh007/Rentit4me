// ignore_for_file: use_build_context_synchronously, library_private_types_in_public_api, deprecated_member_use, unused_field

import 'dart:async';
import 'dart:developer';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:rentit4me_new/network/api.dart';
import 'package:rentit4me_new/views/dashboard.dart';
import 'package:rentit4me_new/views/home_screen.dart';
import 'package:http/http.dart' as http;
import 'package:rentit4me_new/views/otp_screen.dart';
import 'package:rentit4me_new/views/personal_detail_screen.dart';
import 'dart:convert';
import 'package:rentit4me_new/views/select_membership_screen.dart';
import 'package:rentit4me_new/views/user_location_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SplashScreen extends StatefulWidget {
  final Color backgroundColor = Colors.white;
  final TextStyle styleTextUnderTheLoader = const TextStyle(
      fontSize: 18.0, fontWeight: FontWeight.bold, color: Colors.black);

  const SplashScreen({Key key}) : super(key: key);

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  bool _loggedIn = false;
  final splashDelay = 1;

  int _checkvalue;
  int isSignUp = 0;

  bool internetCheck = false;
  String _connectionStatus = 'Unknown';
  final Connectivity _connectivity = Connectivity();

  String _latitutevalue;
  String _longitutevalue;

  @override
  void initState() {
    super.initState();
    //initConnectivity();
    _checklocation();
  }

  _checklocation() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (prefs.getString('latitude') == null ||
        prefs.getString('latitude') == "") {
      Navigator.pushReplacement(
          context,
          MaterialPageRoute(
              builder: (BuildContext context) => const UserlocationScreen()));
    } else {
      // _checkLoggedIn()
      //     .then((value) => _getprofileData().then((value) => _loadWidget()));

      if (prefs.getString('userid') == "" ||
          prefs.getString('userid') == null) {
        Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => HomeScreen()),
            (route) => false);
      } else {
        getprofileData();
      }
    }
  }

  // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> initConnectivity() async {
    ConnectivityResult result;
    try {
      result = await _connectivity.checkConnectivity();
    } on Exception catch (e) {
      log(e.toString());
    }
    if (!mounted) {
      return Future.value(null);
    }
    return _updateConnectionStatus(result);
  }

  Future<void> _updateConnectionStatus(ConnectivityResult result) async {
    switch (result) {
      case ConnectivityResult.wifi:
      case ConnectivityResult.mobile:
      case ConnectivityResult.none:
        setState(() {
          _connectionStatus = result.toString();
        });
        if (_connectionStatus.toString() ==
            ConnectivityResult.none.toString()) {
          _scaffoldKey.currentState.showSnackBar(const SnackBar(
              content: Text("Please check your internet connection.",
                  style: TextStyle(color: Colors.white)),
              backgroundColor: Colors.red));
        } else if (_connectionStatus.toString() ==
            ConnectivityResult.wifi.toString()) {
          getprofileData();
          _checkLoggedIn().then((value) => _loadWidget());
        } else if (_connectionStatus.toString() ==
            ConnectivityResult.mobile.toString()) {
          getprofileData();
          _checkLoggedIn().then((value) => _loadWidget());
        }
        break;
      default:
        setState(() {
          _connectionStatus = 'Failed to get connectivity.';
        });
        break;
    }
  }

  Future _checkLoggedIn() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    //_latitutevalue = prefs.getString('latitude');
    //_longitutevalue = prefs.getString('longitude');
    var isLoggedIn = prefs.getBool('logged_in');
    if (isLoggedIn == true) {
      setState(() {
        _loggedIn = isLoggedIn;
      });
    } else {
      setState(() {
        _loggedIn = false;
      });
    }
  }

  _loadWidget() async {
    var duration = Duration(seconds: splashDelay);
    return Timer(duration, navigationPage);
  }

  void navigationPage() {
    Navigator.pushReplacement(context,
        MaterialPageRoute(builder: (BuildContext context) => homeOrLog()));
  }

  Widget homeOrLog() {
    if (_loggedIn) {
      if (_checkvalue == 1) {
        return Dashboard();
      } else if (_checkvalue == 2) {
        // return MakePaymentScreen();
        return SelectMemberShipScreen();
      } else {
        return SelectMemberShipScreen();
      }
    } else {
      return const HomeScreen();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        key: _scaffoldKey,
        body: Center(
          child: Image.asset(
            'assets/images/logo.png',
            scale: 10,
          ),
        ));
  }

  Future getprofileData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final body = {};
    var response = await http.post(Uri.parse(BASE_URL + profileUrl),
        body: jsonEncode(body),
        headers: {
          "Accept": "application/json",
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${prefs.getString("token")}',
        });
    print("Bearer ${prefs.getString("token")}");
    if (response.statusCode == 200) {
      var data = json.decode(response.body)['Response'];
      log("data----->$data");
      if (data != null) {
        if (data['User']['otp_verify'] == "1") {
          if (data['User']['is_signup_complete'] == 1 &&
              data['User']['payment_status'] == 1) {
            Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => Dashboard()),
                (route) => false);
          } else {
            Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => PersonalDetailScreen()),
                (route) => false);
          }
        } else {
          Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (context) => OtpScreen()),
              (route) => false);
        }
      } else {
        Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => PersonalDetailScreen()),
            (route) => false);
      }
      //   if (data['User']['package_id'].toString() != null) {
      //     if (data['User']['payment_status'].toString() == "1") {
      //       setState(() {
      //         _checkvalue = 1;
      //       });
      //     } else {
      //       setState(() {
      //         _checkvalue = 2;
      //       });
      //     }
      //   }
      // } else {
      //   setState(() {
      //     _checkvalue = 3;
      //   });
      // }
    } else {
      throw Exception('Failed to get data due to ${response.body}');
    }
  }
}
