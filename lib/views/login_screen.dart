// ignore_for_file: use_build_context_synchronously

import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:contained_tab_bar_view/contained_tab_bar_view.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:rentit4me_new/network/api.dart';
import 'package:rentit4me_new/themes/constant.dart';
import 'package:http/http.dart' as http;
import 'package:google_sign_in/google_sign_in.dart';
import 'package:rentit4me_new/utils/dialog_utils.dart';
import 'package:rentit4me_new/views/dashboard.dart';
import 'package:rentit4me_new/views/forgot_password.dart';
import 'package:rentit4me_new/views/home_screen.dart';
import 'package:rentit4me_new/views/make_payment_screen.dart';
import 'package:rentit4me_new/views/otp_screen.dart';
import 'package:rentit4me_new/views/personal_detail_screen.dart';
import 'package:rentit4me_new/views/signup_business_screen.dart';
import 'package:rentit4me_new/views/signup_consumer_screen.dart';
import 'package:rentit4me_new/views/signup_users_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key key}) : super(key: key);

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool buttonLoading = false;
  bool _loading = true;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  String _connectionStatus = 'Unknown';
  final Connectivity _connectivity = Connectivity();

  String fcmToken = "";

  bool _pwdvisible = true;
  void getToken() async {
    fcmToken = await FirebaseMessaging.instance.getToken();
    log("fcm token--->$fcmToken");
  }

  double height = 0;
  double width = 0;

  @override
  void initState() {
    super.initState();
    initConnectivity();
    setState(() {
      _loading = false;
    });
    getToken();
  }

  Future<void> initConnectivity() async {
    ConnectivityResult result;
    try {
      result = await _connectivity.checkConnectivity();
    } on Exception catch (e) {
      print(e.toString());
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
        }
        break;
      default:
        setState(() {
          _connectionStatus = 'Failed to get connectivity.';
        });
        break;
    }
  }

  int userId = 0;

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  Future<bool> onWillPop() {
    exit(0);
  }

  @override
  Widget build(BuildContext context) {
    width = MediaQuery.of(context).size.width;
    height = MediaQuery.of(context).size.height;
    Size size = MediaQuery.of(context).size;

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Appcolors.whiteColor,
        title: Image.asset(
          'assets/images/logo.png',
          scale: 22,
        ),
        automaticallyImplyLeading: false,
        centerTitle: true,
        actions: [
          IconButton(
              onPressed: () {
                Navigator.of(context).pushReplacement(MaterialPageRoute(
                    builder: (context) => const HomeScreen()));
              },
              icon: const Icon(Icons.home, color: Colors.black))
        ],
      ),
      body: ContainedTabBarView(
        tabs: const [
          Text('Sign In',
              style: TextStyle(
                  color: Colors.black,
                  fontSize: 20,
                  fontWeight: FontWeight.bold)),
          Text('SignUp',
              style: TextStyle(
                  color: Colors.black,
                  fontSize: 20,
                  fontWeight: FontWeight.bold))
        ],
        views: [
          // ----------------For Log In---------------//

          SingleChildScrollView(
            child: Container(
              height: height * 0.8,
              decoration: const BoxDecoration(color: Appcolors.whiteColor),
              child: Column(
                // mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(
                    height: 50,
                  ),
                  // Image.asset(
                  //   "assets/images/logo.png",
                  //   scale: 10,
                  // ),
                  const SizedBox(
                    height: 20,
                  ),
                  Container(
                    height: 60,
                    width: width * 0.9,
                    alignment: Alignment.center,
                    decoration: const BoxDecoration(
                        borderRadius: BorderRadius.all(Radius.circular(5.0))),
                    child: Card(
                      elevation: 5,
                      color: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(5.0),
                      ),
                      child: TextField(
                        decoration: const InputDecoration(
                          hintText: "Email",
                          contentPadding: EdgeInsets.all(15),
                          hintStyle: TextStyle(
                              color: kPrimaryColor,
                              fontWeight: FontWeight.w500,
                              fontSize: 14),
                          border: InputBorder.none,
                        ),
                        onChanged: (String value) {
                          emailController.text = value.toString();
                        },
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  Container(
                    height: 55,
                    width: width * 0.9,
                    decoration: const BoxDecoration(
                        borderRadius: BorderRadius.all(Radius.circular(5.0))),
                    child: Card(
                        elevation: 5,
                        color: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(5.0),
                        ),
                        child: TextFormField(
                          obscureText: _pwdvisible,
                          decoration: InputDecoration(
                              hintText: "Password",
                              contentPadding: EdgeInsets.all(15),
                              hintStyle: const TextStyle(
                                  color: kPrimaryColor,
                                  fontWeight: FontWeight.w500,
                                  fontSize: 14),
                              border: InputBorder.none,
                              suffixIcon: IconButton(
                                  onPressed: () {
                                    setState(() {
                                      _pwdvisible = !_pwdvisible;
                                    });
                                  },
                                  icon: _pwdvisible == false
                                      ? const Icon(Icons.visibility_off,
                                          color: kPrimaryColor)
                                      : const Icon(Icons.visibility,
                                          color: kPrimaryColor))),
                          onChanged: (String value) {
                            passwordController.text = value.toString();
                          },
                        )),
                  ),
                  const SizedBox(
                    height: 30,
                  ),
                  InkWell(
                    onTap: () {
                      if (emailController.text.toString().trim().isEmpty ||
                          emailController.text.toString().trim().isEmpty) {
                        showToast("Please enter valid email address");
                        return;
                      } else if (passwordController.text.isEmpty ||
                          passwordController.text.toString().trim().isEmpty) {
                        showToast("Please enter valid password");
                        return;
                      } else {
                        _login(emailController.text.toString().trim(),
                            passwordController.text.toString().trim(), "app");
                      }
                    },
                    child: Container(
                      height: height * 0.06,
                      width: width * 0.9,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                          color: Appcolors.primaryColor,
                          borderRadius: BorderRadius.all(Radius.circular(21))),
                      child: Text(
                          buttonLoading == true ? "Please Wait..." : "Login",
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 22,
                              fontWeight: FontWeight.bold)),
                    ),
                  ),
                  const SizedBox(height: 5.0),
                  const SizedBox(
                    height: 20,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Container(
                        margin: const EdgeInsets.symmetric(horizontal: 20),
                        child: InkWell(
                          onTap: () {
                            // launch("https://rentit4me.com/forget-password");
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: ((context) => ForgotPassword())));
                          },
                          child: Text(
                            "Forgot Password ?",
                            style: TextStyle(
                                fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  Container(
                    width: 400,
                    child: Stack(alignment: Alignment.center, children: [
                      Divider(
                        thickness: 1,
                        height: 60,
                        indent: 20,
                        endIndent: 20,
                      ),
                      Container(
                          color: Appcolors.whiteColor,
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(
                              "OR",
                              style: GoogleFonts.inter(
                                  fontWeight: FontWeight.w700,
                                  fontSize: 16,
                                  color: Color(0xff344054)),
                            ),
                          ))
                    ]),
                  ),
                  // Container(
                  //   margin: const EdgeInsets.symmetric(horizontal: 10),
                  //   width: width,
                  //   height: 20,
                  //   child: Row(
                  //     crossAxisAlignment: CrossAxisAlignment.center,
                  //     children: [
                  //       // SizedBox(
                  //       //   width: size.width * 0.45,
                  //       //   child:
                  //       //       const Divider(thickness: 1, color: Colors.black),
                  //       // ),
                  //       const Text("OR", style: TextStyle(color: Colors.black)),
                  //       // SizedBox(
                  //       //   width: size.width * 0.45,
                  //       //   child:
                  //       //       const Divider(thickness: 1, color: Colors.black),
                  //       // ),
                  //     ],
                  //   ),
                  // ),

                  const SizedBox(
                    height: 40,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      InkWell(
                          onTap: () {
                            facebooklogin();
                            //await initiateFacebookLogin();
                          },
                          child: Image.asset(
                            "assets/images/facebook (1).png",
                            scale: 12,
                          )),
                      SizedBox(
                        width: 40,
                      ),
                      InkWell(
                        onTap: () {
                          googleLogin();
                        },
                        child: (Image.asset(
                          'assets/images/google1.png',
                          scale: 12,
                        )),
                      ),
                    ],
                  ),
                  SizedBox(
                    height: 50,
                  ),
                  InkWell(
                    onTap: (){},
                    child: Text(
                      "Privacy Policy !",
                      style: TextStyle(
                          color: Appcolors.secondaryColor,
                          fontSize: 16,
                          fontWeight: FontWeight.w600),
                    ),
                  )
                ],
              ),
            ),
          ),

          // ----------------for sign up---------------//

          SingleChildScrollView(
            child: Container(
              color: Appcolors.whiteColor,
              child: Column(
                children: [
                  const SizedBox(
                    height: 50,
                  ),
                  // Container(
                  //   padding: const EdgeInsets.fromLTRB(0, 15, 0, 0),
                  //   child: const Text("Are you a Business?",
                  //       style: TextStyle(
                  //           color: kPrimaryColor,
                  //           fontSize: 16,
                  //           fontWeight: FontWeight.w400)),
                  // ),
                  Padding(
                      padding: const EdgeInsets.fromLTRB(0, 15, 0, 0),
                      child: InkWell(
                        onTap: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (BuildContext context) =>
                                      const SignupScreen()));
                        },
                        child: Container(
                          height: 45,
                          width: size.width * 0.80,
                          decoration: BoxDecoration(
                              borderRadius:
                                  const BorderRadius.all(Radius.circular(20.0)),
                              color: Appcolors.primaryColor),
                          child: const Center(
                            child: Text(
                              'Are you a Business',
                              style: TextStyle(
                                fontSize: 18.0,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      )),

                  const SizedBox(
                    height: 20,
                  ),
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 10),
                    width: width,
                    height: 20,
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        SizedBox(
                          width: size.width * 0.45,
                          child:
                              const Divider(thickness: 1, color: Colors.black),
                        ),
                        const Text("OR", style: TextStyle(color: Colors.black)),
                        SizedBox(
                          width: size.width * 0.45,
                          child:
                              const Divider(thickness: 1, color: Colors.black),
                        ),
                      ],
                    ),
                  ),

                  // const Padding(
                  //   padding: EdgeInsets.fromLTRB(0, 15, 0, 0),
                  //   child: Text("Are you a Consumer?",
                  //       style: TextStyle(
                  //           color: kPrimaryColor,
                  //           fontSize: 16,
                  //           fontWeight: FontWeight.w400)),
                  // ),

                  Padding(
                      padding: const EdgeInsets.fromLTRB(0, 15, 0, 0),
                      child: InkWell(
                        onTap: () {
                          Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                  builder: (BuildContext context) =>
                                      const SignupConsumerScreen()));
                        },
                        child: Container(
                          height: 45,
                          width: size.width * 0.80,
                          decoration: const BoxDecoration(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(20.0)),
                              color: Appcolors.secondaryColor),
                          child: const Center(
                            child: Text(
                              'Are you a Consumer?',
                              style: TextStyle(
                                fontSize: 18.0,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      )),
                ],
              ),
            ),
          ),
        ],
        onChange: (index) => print(index),
      ),
    );
  }

  facebooklogin() async {
    try {
      final result =
          await FacebookAuth.i.login(permissions: ['public_profile', 'email']);
      if (result.status == LoginStatus.success) {
        final userData = await FacebookAuth.i.getUserData();
        log("userData=-->$userData");
        if (userData.isNotEmpty) {
          userData.addAll(userData);

          log(userData['email']);

          if (userData['email'] != null) {
            _checkloginSocial(userData['email'], userData['name'], "social");
          } else {
            _checklogin(userData['email'], userData['name'], "social");
          }
          // showDialog(
          //   context: context,
          //   builder: (ctx) => AlertDialog(
          //     title: const Text("Information!!",
          //         style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
          //     content: const Text(
          //         "We are not able to receive your email from facebook, you can signup through google or manually.",
          //         style: TextStyle(fontSize: 14)),
          //     actions: <Widget>[
          //       TextButton(
          //         onPressed: () {
          //           Navigator.of(ctx).pop();
          //         },
          //         child: Container(
          //           alignment: Alignment.center,
          //           width: 90,
          //           decoration: BoxDecoration(
          //               color: kPrimaryColor,
          //               borderRadius: BorderRadius.circular(12.0)),
          //           padding: const EdgeInsets.all(14),
          //           child: const Text("Ok",
          //               style: TextStyle(color: Colors.white, fontSize: 16)),
          //         ),
          //       ),
          //     ],
          //   ),
          // );

        } else {
          log(userData.toString());
        }
      }
    } catch (error) {
      print(error);
    }
  }

  googleLogin() async {
    print("object");
    GoogleSignIn googleSignIn = GoogleSignIn();

    var result = await googleSignIn.signIn();
    log(result.toString());

    if (result != null) {
      _checkloginSocial(result.email, result.displayName, "social");
    } else {
      _checklogin(result.email, result.displayName, "social");
    }
  }

  // void initiateFacebookLogin() async {
  //   var facebookLoginResult =
  //       await FacebookLogin().logInWithReadPermissions(['email']);
  //   print(facebookLoginResult.status.toString() + "______________");
  //   print(facebookLoginResult.status);
  //   switch (facebookLoginResult.status) {
  //     case FacebookLoginStatus.error:
  //       //onLoginStatusChanged(false);
  //       print(facebookLoginResult.errorMessage);
  //       break;
  //     case FacebookLoginStatus.cancelledByUser:
  //       break;
  //     case FacebookLoginStatus.loggedIn:
  //       var graphResponse = await http.get(Uri.parse(
  //           'https://graph.facebook.com/v2.12/me?fields=name,first_name,last_name,email,picture.width(400)&access_token=${facebookLoginResult.accessToken.token}'));
  //       var profile = json.decode(graphResponse.body);
  //       print(profile.toString());
  //       break;
  //   }
  // }

  Future _checkloginSocial(String email, String name, String logintype) async {
    setState(() {
      _loading = true;
    });
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final body = {
      "email": email,
      "login_type": "social",
      "app_token": fcmToken.toString(),
      // "password": "",
    };
    var response = await http.post(Uri.parse(BASE_URL + login),
        body: jsonEncode(body),
        headers: {
          "Accept": "application/json",
          'Content-Type': 'application/json'
        });
    log("response--->${response.body}");
    if (response.statusCode == 200) {
      setState(() {
        _loading = false;
      });
      if (jsonDecode(response.body)['ErrorCode'] == 0) {
        // prefs.setBool('logged_in', true);
        prefs.setString(
            'userid', jsonDecode(response.body)['Response']['id'].toString());
        prefs.setString('usertype',
            jsonDecode(response.body)['Response']['user_type'].toString());
        prefs.setString('token', jsonDecode(response.body)['token']);
        _getprofileData();
        //Navigator.pushReplacement(context, MaterialPageRoute(builder: (BuildContext context) => HomeScreen()));

      } else {
        Navigator.of(context).push(MaterialPageRoute(
          builder: (context) => SignupUserScreen(name: name, email: email),
        ));
      }
    } else {
      setState(() {
        _loading = false;
      });
    }
  }

  Future _checklogin(String email, String name, String logintype) async {
    setState(() {
      _loading = true;
    });
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final body = {
      "email": email,
      "login_type": logintype,
      "app_token": fcmToken.toString(),
      "password": "",
    };
    var response = await http.post(Uri.parse(BASE_URL + login),
        body: jsonEncode(body),
        headers: {
          "Accept": "application/json",
          'Content-Type': 'application/json'
        });
    print(response.body);
    if (response.statusCode == 200) {
      setState(() {
        _loading = false;
      });
      if (jsonDecode(response.body)['ErrorCode'].toString() == "0") {
        prefs.setBool('logged_in', true);
        prefs.setString(
            'userid', jsonDecode(response.body)['Response']['id'].toString());
        prefs.setString('usertype',
            jsonDecode(response.body)['Response']['user_type'].toString());
        _getprofileData();
        //Navigator.pushReplacement(context, MaterialPageRoute(builder: (BuildContext context) => HomeScreen()));

      } else {
        Navigator.of(context).push(MaterialPageRoute(
          builder: (context) => SignupUserScreen(name: name, email: email),
        ));
      }
    } else {
      setState(() {
        _loading = false;
      });
      print(response.body);
      throw Exception('Failed to get data due to ${response.body}');
    }
  }

  Future _login(String email, String password, String logintype) async {
    setState(() {
      buttonLoading = true;
      _loading = true;
    });
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final body = {
      "email": email,
      "password": password,
      "login_type": logintype,
      "app_token": fcmToken.toString(),
    };
    print(jsonEncode(body));
    print(BASE_URL + login);
    var response = await http.post(Uri.parse(BASE_URL + login),
        body: jsonEncode(body),
        headers: {
          "Accept": "application/json",
          'Content-Type': 'application/json'
        });
    log(response.body.toString());
    if (response.statusCode == 200) {
      setState(() {
        _loading = false;
      });
      if (jsonDecode(response.body)['ErrorCode'].toString() == "0") {
        // prefs.setBool('logged_in', true);
        var result = jsonDecode(response.body);
        userId = result['Response']['id'];
        log("userId---->$userId");
        prefs.setString('userid', userId.toString());
        prefs.setString("fcm_token", fcmToken.toString());
        prefs.setString('usertype',
            jsonDecode(response.body)['Response']['user_type'].toString());
        setState(() {
          prefs.setString("token", jsonDecode(response.body)['token']);
          log("token---->${prefs.getString('token')}");
        });
        _getprofileData();

        //Navigator.pushReplacement(context, MaterialPageRoute(builder: (BuildContext context) => HomeScreen()));
      } else {
        buttonLoading = false;
      }
      showToast(jsonDecode(response.body)['ErrorMessage']);
    } else {
      setState(() {
        buttonLoading = false;
        _loading = false;
      });
      showToast(jsonDecode(response.body)['ErrorMessage']);
      log(response.body);
      throw Exception('Failed to get data due to ${response.body}');
    }
  }

  Future _getprofileData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final body = {
      "id": prefs.getString('userid'),
    };
    var response = await http.post(Uri.parse(BASE_URL + profileUrl),
        body: jsonEncode(body),
        headers: {
          "Accept": "application/json",
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${prefs.getString("token")}',
        });
    log(jsonEncode({
      "Accept": "application/json",
      'Content-Type': 'application/json',
      'Authorization': 'Bearer ${prefs.getString("token")}',
    }));
    print(body);
    log(response.body);
    if (response.statusCode == 200) {
      // prefs.setString('token', '')
      var data = json.decode(response.body)['Response']['User'];

      if (data['package_id'] != null || data['package_id'] != 0) {
        if (data['otp_verify'] == "1") {
          if (data['is_signup_complete'] == 1) {
            if (data['payment_status'] == 1) {
              prefs.setString('userquickid', data['quickblox_id'].toString());
              prefs.setString('quicklogin', data['quickblox_email'].toString());
              prefs.setString(
                  'quickpassword', data['quickblox_password'].toString());
              Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                      builder: (BuildContext context) => Dashboard()));
            } else {
              Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                      builder: (BuildContext context) =>
                          const PersonalDetailScreen()));
            }
          } else {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                  builder: (BuildContext context) => PersonalDetailScreen()),
            );
            Fluttertoast.showToast(msg: "Your Signup is not completed ");
          }
        }
      } else {
        Navigator.pushReplacement(context,
            MaterialPageRoute(builder: (BuildContext context) => OtpScreen()));
      }
    } else {
      throw Exception('Failed to get data due to ${response.body}');
    }
  }
}
