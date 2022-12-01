// ignore_for_file: use_build_context_synchronously

import 'dart:convert';
import 'dart:developer';

import 'package:dropdown_search/dropdown_search.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:email_validator/email_validator.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:rentit4me_new/network/api.dart';
import 'package:rentit4me_new/themes/constant.dart';
import 'package:rentit4me_new/views/otp_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({Key key}) : super(key: key);

  @override
  _SignupScreenState createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  bool _loading = false;

  final nameController = TextEditingController();
  final businessController = TextEditingController();
  final emailController = TextEditingController();
  final mobileController = TextEditingController();
  final countrynameController = TextEditingController();
  final alternamemobileContoller = TextEditingController();
  final pwdController = TextEditingController();
  final confirmpwdController = TextEditingController();
  int _value = 0;

  //int usertypevalue = 0;
  //bool _businessnamevisibility = false;

  String selectedCode = "India +91";
  String countrycode = "91";

  String countryname;
  var countrycodelistwithname = [''];
  var countrycodelist = [''];
  var countrynamelist = [''];

  String fcmToken;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    // _getCountryData();
    getToken();
  }

  void getToken() async {
    fcmToken = await FirebaseMessaging.instance.getToken();
    log("fcm token--->$fcmToken");
  }

  @override
  void dispose() {
    nameController.dispose();
    businessController.dispose();
    emailController.dispose();
    mobileController.dispose();
    alternamemobileContoller.dispose();
    countrynameController.dispose();
    pwdController.dispose();
    confirmpwdController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 2.0,
          leading: Padding(
            padding: const EdgeInsets.only(left: 10),
            child: Image.asset('assets/images/logo.png'),
          ),
          title: const Text("Business Signup",
              style: TextStyle(color: kPrimaryColor)),
          centerTitle: true,
          /*actions: [
          IconButton(onPressed:(){}, icon: Icon(Icons.edit, color: kPrimaryColor)),
          IconButton(onPressed:(){}, icon: Icon(Icons.account_circle, color: kPrimaryColor)),
          IconButton(onPressed:(){}, icon: Icon(Icons.menu, color: kPrimaryColor))
        ],*/
        ),
        body: ModalProgressHUD(
          inAsyncCall: _loading,
          color: kPrimaryColor,
          child: SingleChildScrollView(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(
                      vertical: 5.0, horizontal: 5.0),
                  child: _fullnameTextbox("Full Name"),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(
                      vertical: 5.0, horizontal: 5.0),
                  child: _businessnameTextbox("Business Name"),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(
                      vertical: 5.0, horizontal: 5.0),
                  child: _emailTextbox("Email Address"),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(15, 0, 15, 0),
                  child: DropdownSearch(
                    selectedItem: selectedCode,
                    mode: Mode.DIALOG,
                    showSelectedItem: true,
                    autoFocusSearchBox: true,
                    showSearchBox: true,
                    hint: 'Country Code',
                    showFavoriteItems: true,
                    favoriteItems: (val) {
                      return [selectedCode];
                    },
                    dropdownSearchDecoration: InputDecoration(
                        enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none),
                        contentPadding: EdgeInsets.only(left: 10)),
                    items: countrycodelistwithname.map((e) {
                      return e.toString();
                    }).toList(),
                    onChanged: (value) {
                      if (value != "Country Code") {
                        countrycodelistwithname.forEach((element) {
                          if (element.toString() == value) {
                            setState(() {
                              countrycode = "";
                              countrycode = element.split("+")[1];
                            });
                          }
                        });
                      } else {
                        showToast("Select Country Code");
                      }
                      print(countrycode);
                    },
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.only(left: 20.0, right: 20.0),
                  child: Divider(
                    color: Colors.black,
                  ),
                ),
                Padding(
                  padding: EdgeInsets.symmetric(vertical: 5.0, horizontal: 5.0),
                  child: _mobileTextbox(),
                ),
                Padding(
                  padding: EdgeInsets.symmetric(vertical: 5.0, horizontal: 5.0),
                  child: _alternamemobileTextbox("Alternate Mobile"),
                ),
                Padding(
                  padding: EdgeInsets.symmetric(vertical: 5.0, horizontal: 5.0),
                  child: _passwordTextbox("Password"),
                ),
                Padding(
                  padding: EdgeInsets.symmetric(vertical: 5.0, horizontal: 5.0),
                  child: _confirmpwdTextbox("Confirm Password"),
                ),
                Padding(
                  padding:
                      EdgeInsets.symmetric(vertical: 10.0, horizontal: 15.0),
                  child: InkWell(
                    onTap: () {
                      if (nameController.text.toString().trim().isEmpty) {
                        showToast("Please enter your name");
                        return;
                      } else if (countrycode == null ||
                          countrycode == "" ||
                          countrycode == "Country Code") {
                        showToast("Please select country code");
                        return;
                      } else if (businessController.text
                          .toString()
                          .trim()
                          .isEmpty) {
                        showToast("Please enter your business name");
                        return;
                      } else if (emailController.text
                              .toString()
                              .trim()
                              .isEmpty &&
                          EmailValidator.validate(
                                  emailController.text.toString().trim()) ==
                              false) {
                        showToast("Please enter valid email address");
                        return;
                      } else if (mobileController.text
                          .toString()
                          .trim()
                          .isEmpty) {
                        showToast("Please enter mobile number");
                        return;
                      } else if (pwdController.text.toString().trim().isEmpty) {
                        showToast("Please enter password");
                        return;
                      } else if (mobileController.text.length < 10) {
                        showToast("Mobile No should be 10 digits");
                      } else if (pwdController.text !=
                          confirmpwdController.text) {
                        showToast(
                            "Your password & confirm password does not match");
                      } else {
                        _register(
                            nameController.text.toString(),
                            businessController.text.toString(),
                            emailController.text.toString(),
                            countrycode,
                            mobileController.text.toString(),
                            pwdController.text.toString(),
                            confirmpwdController.text.toString());
                      }
                    },
                    child: Container(
                      height: 45,
                      width: double.infinity,
                      alignment: Alignment.center,
                      decoration: const BoxDecoration(
                          color: Colors.deepOrangeAccent,
                          borderRadius:
                              BorderRadius.all(Radius.circular(24.0))),
                      child: Text("Register",
                          style: TextStyle(color: Colors.white, fontSize: 18)),
                    ),
                  ),
                )
              ],
            ),
          ),
        ));
  }

  Widget _fullnameTextbox(_initialValue) {
    return Container(
      margin: EdgeInsets.only(left: 20, right: 20, bottom: 10),
      child: TextFormField(
        textCapitalization: TextCapitalization.sentences,
        validator: (value) {
          return null;
        },
        onSaved: (String value) {
          nameController.text = value;
        },
        onChanged: (value) {
          nameController.text = value;
        },
        cursorColor: kPrimaryColor,
        decoration: InputDecoration(
            hintText: _initialValue.toString(), labelText: 'Full Name*'),
      ),
    );
  }

  Widget _businessnameTextbox(_initialValue) {
    return Container(
      margin: EdgeInsets.only(left: 20, right: 20, bottom: 10),
      child: TextFormField(
        textCapitalization: TextCapitalization.sentences,
        validator: (value) {
          return null;
        },
        onSaved: (String value) {
          businessController.text = value;
        },
        onChanged: (value) {
          businessController.text = value;
        },
        cursorColor: kPrimaryColor,
        decoration: InputDecoration(
            hintText: _initialValue.toString(), labelText: 'Business Name*'),
      ),
    );
  }

  Widget _emailTextbox(_initialValue) {
    return Container(
      margin: EdgeInsets.only(left: 20, right: 20, bottom: 10),
      child: TextFormField(
        textCapitalization: TextCapitalization.sentences,
        keyboardType: TextInputType.emailAddress,
        validator: (value) {
          return null;
        },
        onSaved: (String value) {
          emailController.text = value;
        },
        onChanged: (value) {
          emailController.text = value;
        },
        cursorColor: kPrimaryColor,
        decoration: InputDecoration(
            hintText: _initialValue.toString(), labelText: 'Email Address*'),
      ),
    );
  }

  Widget _CountrynameTextbox(_initialValue) {
    return Container(
      margin: EdgeInsets.only(left: 20, right: 20, bottom: 10),
      child: TextFormField(
        textCapitalization: TextCapitalization.sentences,
        validator: (value) {
          return null;
        },
        onSaved: (String value) {
          countrynameController.text = value;
        },
        onChanged: (value) {
          countrynameController.text = value;
        },
        cursorColor: kPrimaryColor,
        decoration: InputDecoration(
            hintText: _initialValue.toString(), labelText: 'Country Name*'),
      ),
    );
  }

  Widget _mobileTextbox() {
    return Container(
      margin: EdgeInsets.only(left: 20, right: 20, bottom: 10),
      child: TextFormField(
        controller: mobileController,
        keyboardType: TextInputType.number,
        maxLength: 10,
        cursorColor: kPrimaryColor,
        decoration: InputDecoration(
          hintText: "Mobile",
          labelText: 'Mobile*',
          counterText: "",
        ),
      ),
    );
  }
  // Widget _mobileTextbox(_initialValue) {
  //   return Container(
  //     margin: EdgeInsets.only(left: 20, right: 20, bottom: 10),
  //     child: TextFormField(
  //       keyboardType: TextInputType.number,
  //       maxLength: 10,
  //       validator: (value) {
  //         return null;
  //       },
  //       onSaved: (String value) {
  //         mobileController.text = value;
  //       },
  //       onChanged: (value) {
  //         mobileController.text = value;
  //       },
  //       cursorColor: kPrimaryColor,
  //       decoration: InputDecoration(
  //         hintText: _initialValue.toString(),
  //         labelText: 'Mobile*',
  //         counterText: "",
  //       ),
  //     ),
  //   );
  // }

  Widget _alternamemobileTextbox(_initialValue) {
    return Container(
      margin: EdgeInsets.only(left: 20, right: 20, bottom: 10),
      child: TextFormField(
        keyboardType: TextInputType.number,
        maxLength: 10,
        validator: (value) {
          return null;
        },
        onSaved: (String value) {
          alternamemobileContoller.text = value;
        },
        onChanged: (value) {
          alternamemobileContoller.text = value;
        },
        cursorColor: kPrimaryColor,
        decoration: InputDecoration(
          hintText: _initialValue.toString(),
          labelText: 'Alternate Mobile(optional)',
          counterText: "",
        ),
      ),
    );
  }

  Widget _passwordTextbox(_initialValue) {
    return Container(
      margin: EdgeInsets.only(left: 20, right: 20, bottom: 10),
      child: TextFormField(
        obscureText: showPassword,
        textCapitalization: TextCapitalization.sentences,
        validator: (value) {
          return null;
        },
        onSaved: (String value) {
          pwdController.text = value;
        },
        onChanged: (value) {
          pwdController.text = value;
        },
        cursorColor: kPrimaryColor,
        decoration: InputDecoration(
            suffixIcon: IconButton(
              onPressed: () {
                setState(() {
                  showPassword = !showPassword;
                });
              },
              icon: showPassword == false
                  ? Icon(Icons.visibility)
                  : Icon(Icons.visibility_off),
            ),
            hintText: _initialValue.toString(),
            labelText: 'Password*'),
      ),
    );
  }

  bool showPassword = true;
  bool showConfirmPassword = true;
  Widget _confirmpwdTextbox(_initialValue) {
    return Container(
      margin: EdgeInsets.only(left: 20, right: 20, bottom: 10),
      child: TextFormField(
        obscureText: showConfirmPassword,
        textCapitalization: TextCapitalization.sentences,
        validator: (value) {
          return null;
        },
        onSaved: (String value) {
          confirmpwdController.text = value;
        },
        onChanged: (value) {
          confirmpwdController.text = value;
        },
        cursorColor: kPrimaryColor,
        decoration: InputDecoration(
            suffixIcon: IconButton(
              onPressed: () {
                setState(() {
                  showConfirmPassword = !showConfirmPassword;
                });
              },
              icon: showConfirmPassword == false
                  ? Icon(Icons.visibility)
                  : Icon(Icons.visibility_off),
            ),
            hintText: _initialValue.toString(),
            labelText: 'Confirm Password*'),
      ),
    );
  }

  Future _getCountryData() async {
    var response = await http.get(Uri.parse(BASE_URL + countrycodeUrl));
    if (response.statusCode == 200) {
      setState(() {
        countrycodelistwithname.clear();
        countrycodelist.clear();
        countrynamelist.clear();

        jsonDecode(response.body)['Response'].forEach((element) {
          countrycodelistwithname
              .add("${element['name']} +${element['dialcode']}");
          countrycodelist.add("+${element['dialcode']}");
          countrynamelist.add(element['name'].toString());
        });
      });
    }
  }

  Future _register(
      String name,
      String business,
      String email,
      String countrycode,
      String mobile,
      String password,
      String confirmpwd) async {
    setState(() {
      _loading = true;
    });
    SharedPreferences prefs = await SharedPreferences.getInstance();
    log(jsonEncode({
      "name": name,
      "business_name": business,
      "email": email,
      "countrycode": countrycode,
      "mobile": mobile,
      "user_type": "4",
      "password": password,
      "token": fcmToken,
      //"latitude" : prefs.getString('latitude'),
      //"longitude" : prefs.getString('longitude'),
      "latitude": "44.534721",
      "longitude": "24.307261",
    }));
    final body = {
      "name": name,
      "business_name": business,
      "email": email,
      "countrycode": countrycode,
      "mobile": mobile,
      "user_type": "4",
      "password": password,
      "password_confirmation": confirmpwd,
      "token": fcmToken,
      "latitude": prefs.getString('latitude'),
      "longitude": prefs.getString('longitude'),
      "app_token": fcmToken.toString(),

      //"latitude" : "44.534721",
      //"longitude" : "24.307261",
    };
    var response = await http
        .post(Uri.parse(BASE_URL + register), body: jsonEncode(body), headers: {
      "Accept": "application/json",
      'Content-Type': 'application/json',
    });
    log("response---->${response.body}");
    if (response.statusCode == 200) {
      setState(() {
        _loading = false;
      });
      if (jsonDecode(response.body)['ErrorCode'].toString() == "0") {
        prefs.setString('userid',
            jsonDecode(response.body)['Response']['user']['id'].toString());
        prefs.setString(
            'token', jsonDecode(response.body)['Response']['token'].toString());
        log("token---->${prefs.getString('token')}");
        prefs.setString('businessName', businessController.text.toString());
        _sendotp(mobile);
      } else {
        if (jsonDecode(response.body)['ErrorMessage'].toString() ==
            "The email has already been taken.") {
          showToast('Email address already exists');
          return;
        } else if (jsonDecode(response.body)['ErrorMessage'].toString() ==
            "The mobile has already been taken.") {
          showToast('Mobile number already exists');
          return;
        } else {
          return;
        }
      }
    } else {
      setState(() {
        _loading = false;
      });

      log(response.body.toString());
      throw Exception('Failed to get data due to ${response.body}');
    }
  }

  Future _sendotp(String mobile) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final body = {
      "mobile": mobile,
    };
    var response = await http
        .post(Uri.parse(BASE_URL + sendotp), body: jsonEncode(body), headers: {
      "Accept": "application/json",
      'Content-Type': 'application/json',
      'Authorization': 'Bearer ${prefs.getString("token")}',
    });
    if (jsonDecode(response.body)['ErrorCode'].toString() == "0") {
      log("otp----->${jsonDecode(response.body)['Response']['otp']}");

      prefs.setString('phoneNumber', mobile);
      log("Phone number =====>${prefs.getString('phoneNumber')}");
      Navigator.pushReplacement(
          context,
          MaterialPageRoute(
              builder: (BuildContext context) => OtpScreen(
                  phone: mobile,
                  otp: jsonDecode(response.body)['Response']['otp']
                      .toString())));
    }
  }
}
