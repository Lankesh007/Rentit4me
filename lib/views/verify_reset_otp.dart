import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

import 'change_password.dart';

class VerifyResetOtp extends StatefulWidget {
  final String otp;
  const VerifyResetOtp({this.otp, Key key}) : super(key: key);

  @override
  State<VerifyResetOtp> createState() => _VerifyResetOtpState();
}

double height = 0;
double width = 0;
final verifyOtpController = TextEditingController();

class _VerifyResetOtpState extends State<VerifyResetOtp> {
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
                height: 30,
              ),
              Text(
                "Verify Otp",
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
                  keyboardType: TextInputType.number,
                  controller: verifyOtpController,
                  textAlign: TextAlign.center,
                  decoration: InputDecoration(
                    hintText: "Enter your Otp",hintStyle: TextStyle(color: Color.fromARGB(137, 131, 122, 122)),
                    border: InputBorder.none,
                    counterText: "",
                  ),
                  maxLength: 6,
                ),
              ),
              SizedBox(
                height: 30,
              ),
              InkWell(
                onTap: () {
                  if (verifyOtpController.text.isEmpty) {
                    Fluttertoast.showToast(msg: "please enter your Otp");
                  } else {
                    if (widget.otp == verifyOtpController.text.toString()) {
                      Fluttertoast.showToast(msg: "Otp Match Successfully !!");
                      Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(
                              builder: (context) => ChangePasswordScreen()),
                          (route) => false);
                    } else {
                      Fluttertoast.showToast(msg: "Please enter Valid Otp");
                    }
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
                    "Submit",
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
}
