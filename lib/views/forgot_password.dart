// ignore_for_file: use_build_context_synchronously

import 'dart:convert';
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:rentit4me_new/network/api.dart';
import 'package:rentit4me_new/themes/constant.dart';
import 'package:rentit4me_new/views/login_screen.dart';
import 'package:rentit4me_new/widgets/api_helper.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'verify_reset_otp.dart';

class ForgotPassword extends StatefulWidget {
  const ForgotPassword({Key key}) : super(key: key);

  @override
  State<ForgotPassword> createState() => _ForgotPasswordState();
}

class _ForgotPasswordState extends State<ForgotPassword> {
  double height = 0;
  double width = 0;
  final resetController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    height = MediaQuery.of(context).size.height;
    width = MediaQuery.of(context).size.width;
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
            onPressed: () {
              Navigator.pop(context);
            },
            icon: Icon(
              Icons.arrow_back_ios_new,
              color: Colors.black,
            )),
        backgroundColor: Colors.orange.shade400,
        title: Image.asset(
          'assets/images/logo.png',
          scale: 22,
        ),
        automaticallyImplyLeading: false,
        centerTitle: true,
      ),
      body: ListView(
        children: [
          Column(
            children: [
              SizedBox(
                height: 90,
              ),
              Text(
                "Reset Password",
                style: TextStyle(
                    color: Color.fromARGB(255, 4, 26, 156),
                    fontSize: 24,
                    fontWeight: FontWeight.bold),
              ),
              SizedBox(
                height: 30,
              ),
              Container(
                height: height * 0.055,
                width: width * 0.9,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(5),
                  border: Border.all(
                    color: Colors.grey,
                  ),
                ),
                child: TextFormField(
                  controller: resetController,
                  textAlign: TextAlign.center,
                  decoration: InputDecoration(
                    hintText: "Enter your Email/Mobile to reset your password",
                    hintStyle:
                        TextStyle(color: Color.fromARGB(137, 131, 122, 122)),
                    border: InputBorder.none,
                  ),
                ),
              ),
              SizedBox(
                height: 30,
              ),
              InkWell(
                onTap: () {
                  if (resetController.text.isEmpty) {
                    Fluttertoast.showToast(
                        msg: "please enter your mobile/email");
                  } else {
                    getOtpDetails();
                  }
                },
                child: Container(
                  alignment: Alignment.center,
                  height: height * 0.055,
                  width: width * 0.7,
                  decoration: BoxDecoration(
                      color: Colors.deepOrange,
                      borderRadius: BorderRadius.circular(100)),
                  child: Text(
                    buttonLoader == true ? "Please wait..." : "Submit",
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w600),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
  // ---------------------API Call --------------------//

  int otp = 0;
  bool buttonLoader = false;
  Future getOtpDetails() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      buttonLoader = true;
    });
    var url = "${BASE_URL}forget-password";
    var body = {"email": resetController.text.toString()};
    var response = await APIHelper.apiPostRequest(url, body);

    var result = jsonDecode(response);

    if (result['ErrorCode'] == 0) {
      otp = result['Response'];
      log("otp-->$otp");
      prefs.setString("resetNumber", resetController.text.toString());
      log("reset number---->${prefs.getString("resetNumber")}");
      if (result['ErrorMessage'] ==
          "We have emailed your password reset link!") {
        Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => LoginScreen()),
            (route) => false);
      } else {
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => VerifyResetOtp(
                      otp: otp.toString(),
                    )));
      }

      setState(() {
        buttonLoader = false;
      });
      Fluttertoast.showToast(msg: result['ErrorMessage'].toString());
    } else {
      Fluttertoast.showToast(msg: result['ErrorMessage'].toString());
      setState(() {
        buttonLoader = false;
      });
    }
    setState(() {
      buttonLoader = false;
    });
  }
}
