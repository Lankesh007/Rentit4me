// ignore_for_file: prefer_interpolation_to_compose_strings

import 'dart:convert';
import 'dart:developer';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'package:rentit4me_new/network/api.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:rentit4me_new/themes/constant.dart';
import 'package:rentit4me_new/views/dashboard.dart';
import 'package:rentit4me_new/views/home_screen.dart';
import 'package:rentit4me_new/widgets/api_helper.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MakePaymentScreen extends StatefulWidget {
  final String packageId;
  final String totalAmount;
  const MakePaymentScreen({this.packageId, this.totalAmount, Key key})
      : super(key: key);

  @override
  State<MakePaymentScreen> createState() => _MakePaymentScreenState();
}

class _MakePaymentScreenState extends State<MakePaymentScreen> {
  bool _loading = false;

  String package_id;
  String package_name;
  String plan_id;
  String ad_limit;
  String ad_duration;
  String type;
  String amount;
  String active;
  bool couponApplied = false;
  final applyCouponController = TextEditingController();
  bool removeCouponButton = false;

  Razorpay _razorpay;
  bool buttonLoader = false;
  @override
  void initState() {
    super.initState();
    _getprofileData();
  }

  void initializeRazorpay() {
    _razorpay = Razorpay();
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);
  }

  var razorpayId;

  void _handlePaymentSuccess(PaymentSuccessResponse response) {
    print("success");
    //print(response.orderId.toString());
    log("payment id-->" + response.paymentId.toString());
    setState(() {
      razorpayId = response.paymentId;
    });
    _payformembership(
      response.paymentId,
    );
  }

  void _handlePaymentError(PaymentFailureResponse response) {
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
      content: Text("You have cancelled the payment process.",
          style: TextStyle(color: Colors.white)),
      backgroundColor: Colors.red,
    ));
  }

  void _handleExternalWallet(ExternalWalletResponse response) {}

  void dispose() {
    _razorpay.clear();
    super.dispose();
  }

  void startPayment(String amount) async {
    print(amount);
    SharedPreferences prefs = await SharedPreferences.getInstance();
    try {
      var options = {
        'key': 'rzp_live_8NG6IItB9AtBhV',
        'name': 'Rentit4me',
        'amount': couponApplied == true
            ? (double.parse(appliedGrandTotal.toString()) * 100).toString()
            : (double.parse(amount) * 100).toString(),
        'description': '',
        'timeout': 600, // in seconds
        'prefill': {
          'contact': prefs.getString('mobile'),
          'email': prefs.getString('email')
        }
      };
      _razorpay.open(options);
    } catch (e) {
      print("test2-----" + e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 2.0,
        leading: InkWell(
            onTap: () {
              // removeCouponDetails();
              Navigator.of(context).pop();
            },
            child: const Icon(
              Icons.arrow_back,
              color: kPrimaryColor,
            )),
        title:
            const Text("Make Payment", style: TextStyle(color: kPrimaryColor)),
        centerTitle: true,
      ),
      body: ModalProgressHUD(
        inAsyncCall: _loading,
        child: _loading == true
            ? Center(child: CircularProgressIndicator(color: kPrimaryColor))
            : ListView(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      children: [
                        SizedBox(
                            width: double.infinity,
                            child: Padding(
                                padding: EdgeInsets.all(16.0),
                                child: Column(
                                  children: [
                                    const Align(
                                        alignment: Alignment.topLeft,
                                        child: Text("Make Payment",
                                            style: TextStyle(
                                                color: kPrimaryColor,
                                                fontSize: 24,
                                                fontWeight: FontWeight.w600))),
                                    SizedBox(height: 15),
                                    Divider(thickness: 0.9),
                                    Container(
                                        alignment: Alignment.centerLeft,
                                        child: Text(
                                          "Apply Coupoun",
                                          style: TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.w600,
                                              color: kPrimaryColor),
                                        )),
                                    SizedBox(height: 15),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Container(
                                          height: 40,
                                          width: MediaQuery.of(context)
                                                  .size
                                                  .width *
                                              0.45,
                                          alignment: Alignment.topCenter,
                                          decoration: BoxDecoration(
                                              border: Border.all(
                                                color: Colors.grey,
                                              ),
                                              borderRadius:
                                                  BorderRadius.circular(3)),
                                          child: TextFormField(
                                            readOnly: couponApplied == false
                                                ? false
                                                : true,
                                            controller: applyCouponController,
                                            textAlign: TextAlign.center,
                                            decoration: InputDecoration(
                                                hintText: couponApplied == true
                                                    ? "Apply Coupon"
                                                    : appliedCouponTitle,
                                                border: InputBorder.none),
                                          ),
                                        ),
                                        couponApplied == false
                                            ? InkWell(
                                                onTap: () {
                                                  if (applyCouponController
                                                      .text.isEmpty) {
                                                    Fluttertoast.showToast(
                                                        msg:
                                                            "Please Enter Coupon !!");
                                                  } else {
                                                    applyCouponDetails();
                                                  }
                                                },
                                                child: Container(
                                                  alignment: Alignment.center,
                                                  height: 40,
                                                  width: MediaQuery.of(context)
                                                          .size
                                                          .width *
                                                      0.4,
                                                  decoration: BoxDecoration(
                                                      color: Colors.deepOrange,
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              3)),
                                                  child: Text(
                                                    buttonLoader == true
                                                        ? "please wait..."
                                                        : "Apply",
                                                    style: TextStyle(
                                                        color: Colors.white,
                                                        fontWeight:
                                                            FontWeight.w600),
                                                  ),
                                                ),
                                              )
                                            : InkWell(
                                                onTap: () {
                                                  removeCouponDetails();
                                                },
                                                child: Container(
                                                  alignment: Alignment.center,
                                                  height: 40,
                                                  width: MediaQuery.of(context)
                                                          .size
                                                          .width *
                                                      0.4,
                                                  decoration: BoxDecoration(
                                                      color: Colors.deepOrange,
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              3)),
                                                  child: Text(
                                                    removeCouponButton == true
                                                        ? "Please wait..."
                                                        : "Remove",
                                                    style: TextStyle(
                                                        color: Colors.white,
                                                        fontWeight:
                                                            FontWeight.w600),
                                                  ),
                                                ),
                                              ),
                                      ],
                                    ),
                                    SizedBox(
                                      height: 10,
                                    ),
                                    Divider(thickness: 0.9),
                                    SizedBox(
                                      height: 10,
                                    ),
                                    couponApplied == true
                                        ? Text(
                                            "Hurrey You : $appliedCouponTitle",
                                            style: TextStyle(
                                                color: Colors.deepOrange),
                                          )
                                        : Container(),
                                    SizedBox(height: 15),
                                    Container(
                                      alignment: Alignment.centerLeft,
                                      height: 40,
                                      width: MediaQuery.of(context).size.width,
                                      color: Color.fromARGB(77, 108, 105, 105),
                                      child: Padding(
                                        padding:
                                            const EdgeInsets.only(left: 8.0),
                                        child: Text(
                                          "Payment Details",
                                          style: TextStyle(
                                              fontWeight: FontWeight.w600),
                                        ),
                                      ),
                                    ),
                                    SizedBox(
                                      height: 20,
                                    ),
                                    Card(
                                      elevation: 5,
                                      child: Container(
                                        margin: const EdgeInsets.symmetric(
                                            horizontal: 10, vertical: 10),
                                        child: Column(
                                          children: [
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: [
                                                const Text("Plan",
                                                    style: TextStyle(
                                                        color: kPrimaryColor,
                                                        fontSize: 16,
                                                        fontWeight:
                                                            FontWeight.w400)),
                                                planName == null
                                                    ? const SizedBox()
                                                    : Text(planName.toString(),
                                                        style: TextStyle(
                                                            color: Colors.black,
                                                            fontSize: 16,
                                                            fontWeight:
                                                                FontWeight
                                                                    .w300))
                                              ],
                                            ),
                                            const SizedBox(height: 10),
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: [
                                                const Text("Ad Duration",
                                                    style: TextStyle(
                                                        color: kPrimaryColor,
                                                        fontSize: 16,
                                                        fontWeight:
                                                            FontWeight.w400)),
                                                adDuration == null
                                                    ? SizedBox()
                                                    : Text(
                                                        adDuration.toString(),
                                                        style: TextStyle(
                                                            color: Colors.black,
                                                            fontSize: 16,
                                                            fontWeight:
                                                                FontWeight
                                                                    .w300))
                                              ],
                                            ),
                                            SizedBox(height: 10),
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: [
                                                const Text("Ad Limit",
                                                    style: TextStyle(
                                                        color: kPrimaryColor,
                                                        fontSize: 16,
                                                        fontWeight:
                                                            FontWeight.w400)),
                                                adLimit == null
                                                    ? SizedBox()
                                                    : Text(adLimit.toString(),
                                                        style: TextStyle(
                                                            color: Colors.black,
                                                            fontSize: 16,
                                                            fontWeight:
                                                                FontWeight
                                                                    .w300))
                                              ],
                                            ),
                                            Column(
                                              children: [
                                                couponApplied == false
                                                    ? SizedBox()
                                                    : Column(
                                                        children: [
                                                          SizedBox(height: 10),
                                                          Row(
                                                            mainAxisAlignment:
                                                                MainAxisAlignment
                                                                    .spaceBetween,
                                                            children: [
                                                              const Text(
                                                                  "Sub Total Amount",
                                                                  style: TextStyle(
                                                                      color:
                                                                          kPrimaryColor,
                                                                      fontSize:
                                                                          16,
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .w400)),
                                                              Container(
                                                                  height: 25,
                                                                  width: 60,
                                                                  alignment:
                                                                      Alignment
                                                                          .center,
                                                                  decoration: BoxDecoration(
                                                                      borderRadius:
                                                                          BorderRadius.circular(
                                                                              8.0),
                                                                      color: Colors
                                                                          .green),
                                                                  child: Text(
                                                                      appliedSubTotal
                                                                          .toString(),
                                                                      style: TextStyle(
                                                                          color: Colors
                                                                              .white,
                                                                          fontSize:
                                                                              16,
                                                                          fontWeight:
                                                                              FontWeight.w500)))
                                                            ],
                                                          ),
                                                        ],
                                                      ),
                                              ],
                                            ),
                                            Column(
                                              children: [
                                                couponApplied == false
                                                    ? SizedBox()
                                                    : Column(
                                                        children: [
                                                          SizedBox(height: 10),
                                                          Row(
                                                            mainAxisAlignment:
                                                                MainAxisAlignment
                                                                    .spaceBetween,
                                                            children: [
                                                              const Text(
                                                                  "Discount Amount",
                                                                  style: TextStyle(
                                                                      color:
                                                                          kPrimaryColor,
                                                                      fontSize:
                                                                          16,
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .w400)),
                                                              Container(
                                                                  height: 25,
                                                                  width: 60,
                                                                  alignment:
                                                                      Alignment
                                                                          .center,
                                                                  decoration: BoxDecoration(
                                                                      borderRadius:
                                                                          BorderRadius.circular(
                                                                              8.0),
                                                                      color: Colors
                                                                          .green),
                                                                  child: Text(
                                                                      appliedDiscount
                                                                          .toString(),
                                                                      style: TextStyle(
                                                                          color: Colors
                                                                              .white,
                                                                          fontSize:
                                                                              16,
                                                                          fontWeight:
                                                                              FontWeight.w500)))
                                                            ],
                                                          ),
                                                        ],
                                                      ),
                                              ],
                                            ),
                                            SizedBox(height: 10),
                                            Divider(
                                              thickness: 0.9,
                                            ),
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: [
                                                const Text("Payable Amount",
                                                    style: TextStyle(
                                                        color: kPrimaryColor,
                                                        fontSize: 16,
                                                        fontWeight:
                                                            FontWeight.w400)),
                                                planAmount == null
                                                    ? SizedBox()
                                                    : Container(
                                                        height: 25,
                                                        width: 60,
                                                        alignment:
                                                            Alignment.center,
                                                        decoration: BoxDecoration(
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        8.0),
                                                            color:
                                                                Colors.green),
                                                        child: Text(
                                                            couponApplied ==
                                                                    false
                                                                ? planAmount
                                                                    .toString()
                                                                : appliedGrandTotal
                                                                    .toString(),
                                                            style: TextStyle(
                                                                color: Colors
                                                                    .white,
                                                                fontSize: 16,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w500)))
                                              ],
                                            ),
                                            Divider(
                                              thickness: 0.9,
                                            ),
                                            SizedBox(height: 15),
                                          ],
                                        ),
                                      ),
                                    ),
                                    SizedBox(
                                      height: 30,
                                    ),
                                    InkWell(
                                      onTap: () {
                                        if (couponApplied == true &&
                                            appliedGrandTotal == 0) {
                                          getFreeMemberShipAppliedCoupon();
                                        } else {
                                          startPayment(planAmount.toString());
                                        }
                                      },
                                      child: Container(
                                        height: 45,
                                        width: double.infinity,
                                        alignment: Alignment.center,
                                        decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(8.0),
                                            color: Colors.deepOrange),
                                        child: Text(
                                            getFreeMem == true
                                                ? "Please wait..."
                                                : "Pay",
                                            style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 16)),
                                      ),
                                    )
                                  ],
                                )))
                      ],
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  int id = 0;
  String planName = '';
  int planId = 0;
  int planFor = 0;
  int adLimit = 0;
  int adDuration = 0;
  int planAmount = 0;
  String planType = '';
  int planActive = 0;
  int planBy = 0;
  String couponType = '';

  Future<void> _getmakepayment() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _loading = true;
    });
    final data = {
      "id": widget.packageId.toString(),
    };
    var url = BASE_URL + "get-membership-details";
    var body = data;

    var response = await APIHelper.apiPostRequest(url, body);
    var result = jsonDecode(response);
    log("res--->$result");
    if (result['ErrorCode'] == 0) {
      setState(() {
        id = result['Response']['id'];
        planName = result['Response']['name'].toString();
        planId = result['Response']['plan_id'];
        planFor = result['Response']['plan_for'];
        planBy = result['Response']['plan_by'];
        adDuration = result['Response']['ad_duration'];
        planAmount = result['Response']['amount'];
        planType = result['Response']['type'];
        planActive = result['Response']['active'];
        couponType = result['Response']['coupon_type'].toString();
        adLimit = result['Response']['ad_limit'];
      });
      setState(() {
        _loading = false;
      });
    }
    setState(() {
      _loading = false;
    });
  }

  Future _payformembership(String paymentid) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _loading = true;
    });

    var url = BASE_URL + "signup-membership";
    var body = {
      "id": widget.packageId,
      "razorpay_payment_id": paymentid.toString(),
      "amount": couponApplied == true
          ? appliedGrandTotal.toString()
          : planAmount.toString(),
      "applied_couponcode":
          couponCode == "" || couponCode == null ? "" : couponCode,
      "discount": appliedDiscount == 0 || appliedDiscount == null
          ? ""
          : appliedDiscount.toString(),
    };

    log("body-->$body");
    var response = await APIHelper.apiPostRequest(url, body);
    var result = jsonDecode(response);
    log(result.toString());
    if (result["ErrorCode"] == 0) {
      setState(() {
        _loading = false;
      });
      if (isSignup == 1 && paymentStatus == 1) {
        showToast("Your Payment is Sucessfull !!");
        Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => HomeScreen()));
      } else {
        showToast("Your Payment is Sucessfull !!");
        Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => Dashboard()));
      }
    } else {
      transactionFailed();

      setState(() {
        _loading = false;
      });
    }
    setState(() {
      _loading = false;
    });
  }

  Future transactionFailed() async {
    var url = "${BASE_URL}failed-transaction";
    var body = {
      "razorpay_payment_id": razorpayId,
      "amount": couponApplied == true
          ? appliedGrandTotal.toString()
          : amount.toString(),
      "type": couponType
    };
    var response = await APIHelper.apiPostRequest(url, body);
    var result = jsonDecode(response);
    if (result['ErrorCode'] == 0) {
      showToast(result['ErrorMessage']);
    } else {
      showToast(result['ErrorMessage']);
    }
  }

  Future removeCouponDetails() async {
    setState(() {
      removeCouponButton = true;
    });

    var url = BASE_URL + "remove-coupon";
    var response = await APIHelper.apiGetRequest(url);

    var result = jsonDecode(response);
    if (result['ErrorCode'] == 0) {
      setState(() {
        couponApplied = false;
        applyCouponController.clear();
      });

      // Fluttertoast.showToast(msg: result['ErrorMessage'].toString());
    } else {
      Fluttertoast.showToast(msg: result['ErrorMessage'].toString());
      setState(() {
        removeCouponButton = false;
      });
    }
    setState(() {
      removeCouponButton = false;
    });
  }

  String appliedCouponTitle = '';
  int perPersonCount = 0;
  int appliedDiscount = 0;
  int appliedSubTotal = 0;
  int appliedGrandTotal = 0;
  String couponCode = '';

  Future applyCouponDetails() async {
    setState(() {
      buttonLoader = true;
    });
    var url = BASE_URL + "apply-coupon";
    var body = {
      "coupon": applyCouponController.text.toString(),
      "type": couponType.toString(),
      "sub_total": planAmount.toString(),
    };

    var response = await APIHelper.apiPostRequest(url, body);
    var result = jsonDecode(response);
    if (result['ErrorCode'] == 0) {
      setState(() {
        couponApplied = true;
        appliedCouponTitle = result['Response']['coupon_title'].toString();
        perPersonCount = result['Response']['per_person_count'];
        appliedDiscount = result['Response']['discount'];
        log("applied dis-->$appliedDiscount");
        appliedSubTotal = result['Response']['sub_total'];
        appliedGrandTotal = result['Response']['grand_total'];
        log("applied total-->$appliedGrandTotal");

        couponCode = result['Response']['coupon_code'].toString();
      });
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

  bool getFreeMem = false;

  Future getFreeMemberShipAppliedCoupon() async {
    setState(() {
      getFreeMem = true;
    });
    var url = BASE_URL + "signup-membership";
    var body = {
      "id": widget.packageId,
      "razorpay_payment_id": "",
      "amount": "0",
      "applied_couponcode":
          couponCode == "" || couponCode == null ? "" : couponCode,
      "discount": appliedDiscount == 0 || appliedDiscount == null
          ? ""
          : appliedDiscount.toString(),
    };
    log("body-->$body");
    var response = await APIHelper.apiPostRequest(url, body);
    var result = jsonDecode(response);
    if (result['ErrorCode'] == 0) {
      Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => Dashboard()),
          (route) => false);
      Fluttertoast.showToast(msg: result['ErrorMessage']);
      setState(() {
        getFreeMem = false;
      });
    } else {
      Fluttertoast.showToast(msg: result['ErrorMessage']);
      setState(() {
        getFreeMem = false;
      });
    }
    setState(() {
      getFreeMem = false;
    });
  }

  int isSignup = 0;
  int paymentStatus = 0;

  Future _getprofileData() async {
    setState(() {
      _loading = true;
    });
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
    log('Bearer ${prefs.getString("token")}');
    print(response.body);
    setState(() {
      _loading = false;
    });
    if (response.statusCode == 200) {
      var data = json.decode(response.body)['Response'];
      isSignup = data['User']['is_signup_complete'];
      paymentStatus = data['User']['payment_status'];

      _getmakepayment();
      initializeRazorpay();
      // removeCouponDetails();
    } else {
      throw Exception('Failed to get data due to ${response.body}');
    }
  }
}
