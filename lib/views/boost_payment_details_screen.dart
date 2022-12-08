import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:modal_progress_hud/modal_progress_hud.dart';

import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../network/api.dart';
import '../themes/constant.dart';
import '../widgets/api_helper.dart';
import 'home_screen.dart';

class BoostPaymentDetailsScreen extends StatefulWidget {
  final String postadid;
  final String planName;
  final String amount;
  final String duration;
  final String boostPackageId;

  const BoostPaymentDetailsScreen(
      {this.planName,
      this.amount,
      this.postadid,
      this.duration,
      this.boostPackageId,
      Key key})
      : super(key: key);

  @override
  State<BoostPaymentDetailsScreen> createState() =>
      _BoostPaymentDetailsScreenState();
}

class _BoostPaymentDetailsScreenState extends State<BoostPaymentDetailsScreen> {
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

  int isSignup = 0;
  int paymentStatus = 0;
  var razorpayId;

  Razorpay _razorpay;
  bool buttonLoader = false;
  @override
  void initState() {
    super.initState();
    _getofferdetailproduct();
    _getprofileData();
  }

  void initializeRazorpay() {
    _razorpay = Razorpay();
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);
  }

  void _handlePaymentSuccess(PaymentSuccessResponse response) {
    print("success");
    //print(response.orderId.toString());
    log("payment id-->${response.paymentId}");
    setState(() {
      razorpayId = response.paymentId;
    });
    payForOrder(
      response.paymentId,
    );
  }

  Future payForOrder(String paymentid) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _loading = true;
    });

    var url = "${BASE_URL}pay-for-boostAd";
    var body = {
      "post_id": widget.postadid.toString(),
      "id": widget.boostPackageId.toString(),
      "razorpay_payment_id": paymentid.toString(),
      "amount": couponApplied == true
          ? appliedGrandTotal.toString()
          : widget.amount.toString(),
           "applied_couponcode":
          couponCode == "" || couponCode == null ? "" : couponCode,
      "discount": appliedDiscount == 0 || appliedDiscount == null
          ? ""
          : appliedDiscount.toString(),
    };

    var response = await APIHelper.apiPostRequest(url, body);
    var result = jsonDecode(response);

    log("Payment Respone--->$response");

    if (result["ErrorCode"] == 0) {
      setState(() {
        _loading = false;
      });
      showToast(result['ErrorMessage']).toString();
      Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => HomeScreen()));
    } else {
      setState(() {
        _loading = false;
      });
      showToast(result['ErrorMessage']).toString();
      transactionFailed();
    }
    setState(() {
      _loading = false;
    });
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
        'key': 'rzp_test_NNbwJ9tmM0fbxj',
        'name': 'Rentit4me',
        'amount': couponApplied == true
            ? (double.parse(appliedGrandTotal.toString()) * 100).toString()
            : (double.parse(widget.amount) * 100).toString(),
        'description': '',
        'timeout': 600, // in seconds
        'prefill': {
          'contact': prefs.getString('mobile'),
          'email': prefs.getString('email')
        }
      };
      _razorpay.open(options);
    } catch (e) {
      print("test2-----$e");
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
                  // Text(widget.postadid),
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
                                                productName == null
                                                    ? const SizedBox()
                                                    : Text(
                                                        widget.planName
                                                            .toString(),
                                                        style: TextStyle(
                                                            color: Colors.black,
                                                            fontSize: 16,
                                                            fontWeight:
                                                                FontWeight
                                                                    .w300))
                                              ],
                                            ),
                                            Divider(),
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: [
                                                const Text("Ad",
                                                    style: TextStyle(
                                                        color: kPrimaryColor,
                                                        fontSize: 16,
                                                        fontWeight:
                                                            FontWeight.w400)),
                                                productName == null
                                                    ? const SizedBox()
                                                    : Text(
                                                        productName.toString(),
                                                        style: TextStyle(
                                                            color: Colors.black,
                                                            fontSize: 16,
                                                            fontWeight:
                                                                FontWeight
                                                                    .w300))
                                              ],
                                            ),
                                            Divider(),
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: [
                                                const Text("Price",
                                                    style: TextStyle(
                                                        color: kPrimaryColor,
                                                        fontSize: 16,
                                                        fontWeight:
                                                            FontWeight.w400)),
                                                widget.amount == null
                                                    ? SizedBox()
                                                    : Text(" ${widget.amount}",
                                                        style: TextStyle(
                                                            color: Colors.black,
                                                            fontSize: 16,
                                                            fontWeight:
                                                                FontWeight
                                                                    .w300))
                                              ],
                                            ),
                                            Divider(),
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: [
                                                const Text("Sub Total",
                                                    style: TextStyle(
                                                        color: kPrimaryColor,
                                                        fontSize: 16,
                                                        fontWeight:
                                                            FontWeight.w400)),
                                                widget.amount == null
                                                    ? SizedBox()
                                                    : Text(" ${widget.amount}",
                                                        style: TextStyle(
                                                            color: Colors.black,
                                                            fontSize: 16,
                                                            fontWeight:
                                                                FontWeight
                                                                    .w300))
                                              ],
                                            ),
                                            Divider(),
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: [
                                                const Text("Discount",
                                                    style: TextStyle(
                                                        color: kPrimaryColor,
                                                        fontSize: 16,
                                                        fontWeight:
                                                            FontWeight.w400)),
                                                Text(
                                                    appliedDiscount != 0
                                                        ? appliedDiscount
                                                            .toString()
                                                        : "",
                                                    style: TextStyle(
                                                        color: Colors.black,
                                                        fontSize: 16,
                                                        fontWeight:
                                                            FontWeight.w300))
                                              ],
                                            ),
                                            Divider(),
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: [
                                                const Text("Grand Total",
                                                    style: TextStyle(
                                                        color: kPrimaryColor,
                                                        fontSize: 16,
                                                        fontWeight:
                                                            FontWeight.w400)),
                                                couponApplied == true
                                                    ? Text(
                                                        " ${appliedGrandTotal}",
                                                        style: TextStyle(
                                                            color: Colors.black,
                                                            fontSize: 16,
                                                            fontWeight:
                                                                FontWeight
                                                                    .w300))
                                                    : Text(" ${widget.amount}",
                                                        style: TextStyle(
                                                            color: Colors.black,
                                                            fontSize: 16,
                                                            fontWeight:
                                                                FontWeight
                                                                    .w300))
                                              ],
                                            ),
                                            Divider(),
                                            SizedBox(height: 15),
                                          ],
                                        ),
                                      ),
                                    ),
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
                                                      color: Colors.orange,
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
                                            "Hurrey You : "
                                            "You got $appliedDiscount discount"
                                            "",
                                            style: TextStyle(
                                                color: Colors.deepOrange),
                                          )
                                        : Container(),
                                    SizedBox(
                                      height: 20,
                                    ),
                                    InkWell(
                                      onTap: () {
                                        startPayment(totalAmount.toString());
                                      },
                                      child: Container(
                                        height: 45,
                                        width: double.infinity,
                                        alignment: Alignment.center,
                                        decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(8.0),
                                            color: Colors.orange),
                                        child: Text("Pay",
                                            style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 16)),
                                      ),
                                    ),
                                    SizedBox(
                                      height: 20,
                                    ),
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

  String appliedCouponTitle = '';
  int perPersonCount = 0;
  double appliedDiscount = 0;
  int appliedSubTotal = 0;
  double appliedGrandTotal = 0;
  String couponCode = '';
  int applidTotalAmount = 0;
  Future applyCouponDetails() async {
    setState(() {
      buttonLoader = true;
    });
    var url = "${BASE_URL}apply-coupon";
    var body = {
      "coupon": applyCouponController.text.toString(),
      "type": "boost-listing",
      "sub_total": widget.amount.toString(),
    };

    var response = await APIHelper.apiPostRequest(url, body);
    var result = jsonDecode(response);
    if (result['ErrorCode'] == 0) {
      setState(() {
        couponApplied = true;
        appliedCouponTitle = result['Response']['coupon_title'].toString();
        perPersonCount = result['Response']['per_person_count'];
        appliedDiscount = result['Response']['discount'];
        appliedSubTotal = result['Response']['sub_total'];
        appliedGrandTotal = result['Response']['grand_total'];
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

      initializeRazorpay();
      // removeCouponDetails();
    } else {
      throw Exception('Failed to get data due to ${response.body}');
    }
  }

  Future removeCouponDetails() async {
    setState(() {
      removeCouponButton = true;
    });

    var url = "${BASE_URL}remove-coupon";
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

  String productName = '';
  int quantity;
  String duration;
  String price;
  String securitydeposit;
  double subTotalAmount;
  String convinenceCharge;
  String totalAmount;
  String currencyType;
  String totalRent;
  String totalsecurity;
  int postId = 0;
  int boostPackageId = 0;

  Future<void> _getofferdetailproduct() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _loading = true;
    });
    log("-->${widget.postadid}");

    print(BASE_URL + offerdetail);
    final body = {"id": widget.postadid};
    var response = await http.post(Uri.parse("${BASE_URL}posted-ads/edit"),
        body: jsonEncode(body),
        headers: {
          "Accept": "application/json",
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${prefs.getString("token")}'
        });

    setState(() {
      _loading = false;
    });

    if (response.statusCode == 200) {
      var data = json.decode(response.body)['Response'];
      // print(data['Offer Details']);
      setState(() {
        productName = data['posted_ad']['title'].toString();
        securitydeposit = data['posted_ad']['security'].toString();
        quantity = data['posted_ad']['quantity'];
        boostPackageId = data['posted_ad']['boost_package_id'];
      });
    } else {
      throw Exception('Failed to get data due to ${response.body}');
    }
  }

  Future transactionFailed() async {
    var url = "${BASE_URL}failed-transaction";
    var body = {
      "razorpay_payment_id": razorpayId,
      "amount": couponApplied == true
          ? appliedGrandTotal.toString()
          : widget.amount.toString(),
      "type": "boost-listing"
    };
    var response = await APIHelper.apiPostRequest(url, body);
    var result = jsonDecode(response);
    if (result['ErrorCode'] == 0) {
      showToast(result['ErrorMessage']);
    } else {
      showToast(result['ErrorMessage']);
    }
  }
}
