// ignore_for_file: use_build_context_synchronously

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:rentit4me_new/network/api.dart';
import 'package:rentit4me_new/views/home_screen.dart';
import 'package:rentit4me_new/widgets/api_helper.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({Key key}) : super(key: key);

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  final confirmPasswordController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  double height = 0;
  double width = 0;
  @override
  Widget build(BuildContext context) {
    height = MediaQuery.of(context).size.height;
    width = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: AppBar(
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
                height: 20,
              ),
              Container(
                  alignment: Alignment.centerLeft,
                  margin: const EdgeInsets.symmetric(horizontal: 20),
                  child: Text(
                    "Reset Password",
                    style: TextStyle(
                        color: Colors.blue[900],
                        fontSize: 22,
                        fontWeight: FontWeight.w600),
                  )),
              SizedBox(
                height: 20,
              ),
              // Container(
              //   height: height * 0.055,
              //   width: width * 0.9,
              //   decoration: BoxDecoration(
              //     borderRadius: BorderRadius.circular(5),
              //     border: Border.all(
              //       color: Colors.grey,
              //     ),
              //   ),
              //   child: TextFormField(
              //     keyboardType: TextInputType.number,
              //     controller: emailController,
              //     textAlign: TextAlign.center,
              //     decoration: InputDecoration(
              //       hintText: "Enter your Mobile Number",
              //       hintStyle:
              //           TextStyle(color: Color.fromARGB(137, 131, 122, 122)),
              //       border: InputBorder.none,
              //       counterText: "",
              //     ),
              //     maxLength: 10,
              //   ),
              // ),
              // SizedBox(
              //   height: 20,
              // ),
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
                  controller: passwordController,
                  textAlign: TextAlign.center,
                  decoration: InputDecoration(
                    hintText: "Enter your Password",
                    hintStyle:
                        TextStyle(color: Color.fromARGB(137, 131, 122, 122)),
                    border: InputBorder.none,
                    counterText: "",
                  ),
                  maxLength: 10,
                ),
              ),
              SizedBox(
                height: 20,
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
                  controller: confirmPasswordController,
                  textAlign: TextAlign.center,
                  decoration: InputDecoration(
                    hintText: " Confirm Password",
                    hintStyle:
                        TextStyle(color: Color.fromARGB(137, 131, 122, 122)),
                    border: InputBorder.none,
                    counterText: "",
                  ),
                  maxLength: 10,
                ),
              ),
              SizedBox(
                height: 20,
              ),
              SizedBox(
                height: 20,
              ),
              InkWell(
                onTap: () {
                 if (passwordController.text.isEmpty) {
                    Fluttertoast.showToast(msg: "Please enter password");
                  } else if (confirmPasswordController.text.isEmpty) {
                    Fluttertoast.showToast(
                        msg: "Please enter confirm password");
                  } else if (passwordController.text ==
                      confirmPasswordController.text) {
                    getforgetPasswordDetails();
                  } else {
                    Fluttertoast.showToast(msg: "Password does not Match !!");
                  }
                  //  else {
                  //     // Fluttertoast.showToast(msg: "Please enter Valid Otp");

                  // }
                },
                child: Container(
                  alignment: Alignment.center,
                  height: height * 0.055,
                  width: width * 0.9,
                  decoration: BoxDecoration(
                      color: Colors.deepOrange,
                      borderRadius: BorderRadius.circular(100)),
                  child: Text(
                    buttonLoader == true ? "Please Wait..." : "Submit",
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

  //--------------API CALL----------------//
  bool buttonLoader = false;
  Future getforgetPasswordDetails() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String emailOrPhone = prefs.getString('resetNumber');

    setState(() {
      buttonLoader = true;
    });
    var url = "${BASE_URL}forget-password/reset";
    var body = {
      "email": emailOrPhone.toString(),
      "new_password": passwordController.text.toString(),
      "confirm_password": confirmPasswordController.text.toString(),
    };
    var response = await APIHelper.apiPostRequest(url, body);
    var result = jsonDecode(response);
    if (result['ErrorCode'] == 0) {
      Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => HomeScreen()),
          (route) => false);
      Fluttertoast.showToast(msg: result['ErrorMessage']);
      setState(() {
        buttonLoader = false;
      });
    } else {
      Fluttertoast.showToast(msg: result['ErrorMessage']);
      setState(() {
        buttonLoader = false;
      });
    }
    setState(() {
      buttonLoader = false;
    });
  }
}
