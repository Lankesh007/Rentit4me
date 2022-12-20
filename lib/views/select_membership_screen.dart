// ignore_for_file: use_build_context_synchronously, must_be_immutable, library_private_types_in_public_api, no_logic_in_create_state, non_constant_identifier_names

import 'dart:convert';
import 'dart:developer';
import 'package:badges/badges.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'package:rentit4me_new/network/api.dart';
import 'package:rentit4me_new/themes/constant.dart';
import 'package:rentit4me_new/views/dashboard.dart';
import 'package:rentit4me_new/views/make_payment_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SelectMemberShipScreen extends StatefulWidget {
  String pageswitch;
  SelectMemberShipScreen({Key key, this.pageswitch}) : super(key: key);

  @override
  _SelectMemberShipScreenState createState() =>
      _SelectMemberShipScreenState(pageswitch);
}

class _SelectMemberShipScreenState extends State<SelectMemberShipScreen> {
  String pageswitch;
  _SelectMemberShipScreenState(this.pageswitch);

  List<dynamic> membershipplanlist = [];
  bool _loading = false;

  Razorpay _razorpay;
  String package_id;

  String selectedPack_id;

  @override
  void initState() {
    super.initState();
    _getprofileData();
    _getmembershipplan();
    initializeRazorpay();
  }

  void initializeRazorpay() {
    _razorpay = Razorpay();
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);
  }

  void _handlePaymentSuccess(PaymentSuccessResponse response) {
     log("success");
    //print(response.orderId.toString());
    // print(response.paymentId.toString());
    _payformembership(package_id, response.paymentId.toString());
  }

  void _handlePaymentError(PaymentFailureResponse response) {
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
      content: Text("You have cancelled the payment process.",
          style: TextStyle(color: Colors.white)),
      backgroundColor: Colors.red,
    ));
  }

  void _handleExternalWallet(ExternalWalletResponse response) {}
  @override
  void dispose() {
    _razorpay.clear();
    super.dispose();
  }

  void startPayment(String amount) async {
    log(amount.toString());
    SharedPreferences prefs = await SharedPreferences.getInstance();
    try {
      var options = {
        'key': 'rzp_live_8NG6IItB9AtBhV',
        'name': 'Rentit4me',
        'amount': int.parse(amount) * 100,
        'description': '',
        'timeout': 600, // in seconds
        'prefill': {
          'contact': prefs.getString('mobile'),
          'email': prefs.getString('email')
        }
      };
      _razorpay.open(options);
    } catch (e) {
      log("test2-----$e");
    }
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return WillPopScope(
        onWillPop: _willPopCallback,
        child: Scaffold(
          backgroundColor: Colors.white,
          appBar: AppBar(
            backgroundColor: Colors.white,
            elevation: 2.0,
            title: const Text("Membership",
                style: TextStyle(color: kPrimaryColor)),
            centerTitle: true,
            leading: IconButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                icon: Icon(
                  Icons.arrow_back,
                  color: Colors.black,
                )),
          ),
          body: ModalProgressHUD(
            inAsyncCall: _loading,
            child: Padding(
              padding: const EdgeInsets.all(7.0),
              child: membershipplanlist.isEmpty || membershipplanlist.isEmpty
                  ? const Center(
                      child: CircularProgressIndicator(),
                    )
                  : ListView.separated(
                      itemCount: membershipplanlist.length,
                      shrinkWrap: true,
                      scrollDirection: Axis.vertical,
                      separatorBuilder: (BuildContext context, int index) =>
                          const Divider(
                              height: 10, thickness: 0, color: Colors.white),
                      itemBuilder: (BuildContext context, int index) {
                        return SizedBox(
                          height: size.height * 0.40,
                          width: double.infinity,
                          child: Card(
                            elevation: 8.0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16.0),
                            ),
                            child: Column(
                              children: [
                                const SizedBox(height: 10.0),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                        membershipplanlist[index]['name']
                                            .toString(),
                                        style: const TextStyle(
                                            color: kPrimaryColor,
                                            fontSize: 21,
                                            fontWeight: FontWeight.w500)),
                                  ],
                                ),
                                const SizedBox(height: 10.0),
                                Container(
                                  height: size.height * 0.14,
                                  width: double.infinity,
                                  decoration: const BoxDecoration(
                                      color: Colors.deepOrangeAccent),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                          membershipplanlist[index]['amount']
                                              .toString(),
                                          style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 28,
                                              fontWeight: FontWeight.w700)),
                                      const Text("/",
                                          style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 16)),
                                      const Text("month",
                                          style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 16))
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 5.0),
                                const Text("Ad Duration",
                                    style: TextStyle(
                                        color: Colors.deepOrangeAccent,
                                        fontSize: 14)),
                                const SizedBox(height: 5.0),
                                Text(
                                    membershipplanlist[index]['ad_duration']
                                        .toString(),
                                    style: TextStyle(
                                        color: Colors.black, fontSize: 14)),
                                const SizedBox(height: 5.0),
                                const Text("Ad Limit",
                                    style: TextStyle(
                                        color: Colors.deepOrangeAccent,
                                        fontSize: 14)),
                                Text(
                                    membershipplanlist[index]['ad_limit']
                                        .toString(),
                                    style: TextStyle(
                                        color: Colors.black, fontSize: 14)),
                                const SizedBox(height: 5.0),
                                membershipplanlist[index]['current_plan'] ==
                                        true
                                    ? Container(
                                        width: size.width * 0.25,
                                        height: 35,
                                        alignment: AlignmentDirectional.center,
                                        decoration: BoxDecoration(
                                            color: Colors.grey.shade400,
                                            borderRadius: BorderRadius.all(
                                                Radius.circular(8.0))),
                                        child: const Text("Get Plan",
                                            style: TextStyle(
                                                color: Colors.black,
                                                fontSize: 14)),
                                      )
                                    : InkWell(
                                        onTap: () {
                                          if (pageswitch == "Home") {
                                            if (membershipplanlist[index]['id']
                                                    .toString() ==
                                                "1") {
                                              _selectmembership(
                                                  membershipplanlist[index]
                                                          ['id']
                                                      .toString(),
                                                  membershipplanlist[index]
                                                          ['amount']
                                                      .toString());
                                            } else {
                                              // print(membershipplanlist[index]
                                              //         ['id']
                                              //     .toString());
                                              setState(() {
                                                package_id =
                                                    membershipplanlist[index]
                                                            ['id']
                                                        .toString();
                                              });
                                              // startPayment(
                                              //     membershipplanlist[index]
                                              //             ['amount']
                                              //         .toString());
                                              _selectmembership(
                                                  membershipplanlist[index]
                                                          ['id']
                                                      .toString(),
                                                  membershipplanlist[index]
                                                          ['amount']
                                                      .toString());
                                            }
                                          } else {
                                            _selectmembership(
                                                membershipplanlist[index]['id']
                                                    .toString(),
                                                membershipplanlist[index]
                                                        ['amount']
                                                    .toString());
                                          }
                                        },
                                        child: Container(
                                            width: size.width * 0.25,
                                            height: 35,
                                            alignment:
                                                AlignmentDirectional.center,
                                            decoration: const BoxDecoration(
                                                color: kPrimaryColor,
                                                borderRadius: BorderRadius.all(
                                                    Radius.circular(8.0))),
                                            child: Text("Get Plan",
                                                style: TextStyle(
                                                    color: Colors.white,
                                                    fontSize: 14))),
                                      ),
                                SizedBox(
                                  height: 20,
                                ),
                                membershipplanlist[index]['current_plan'] ==
                                        true
                                    ? Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Container(
                                            alignment: Alignment.centerLeft,
                                            margin: const EdgeInsets.symmetric(
                                                horizontal: 10),
                                            child: Badge(
                                              toAnimate: false,
                                              shape: BadgeShape.square,
                                              badgeColor: Colors.blue[900],
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                              badgeContent: Text('Current Plan',
                                                  style: TextStyle(
                                                      color: Colors.white)),
                                            ),
                                          ),
                                        ],
                                      )
                                    : SizedBox(),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ),
        ));
  }

  Future<bool> _willPopCallback() async {
    if (pageswitch == "Home") {
      Navigator.of(context).pop();
    } else {
      SystemNavigator.pop();
    }
    return Future.value(true);
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
    // print(response.body);
    setState(() {
      _loading = false;
    });
    if (response.statusCode == 200) {
      var data = json.decode(response.body)['Response'];
      setState(() {
        selectedPack_id = data['User']['package_id'].toString();
      });
    } else {
      throw Exception('Failed to get data due to ${response.body}');
    }
  }

  Future _getmembershipplan() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    var response = await http.get(
        Uri.parse(
          BASE_URL + getmembership,
        ),
        headers: {
          'Authorization': 'Bearer ${prefs.getString("token")}',
        });
    // response.headers.addAll({
    //   'Authorization': 'Bearer ${prefs.getString("token")}',
    // });
    log(response.body);
    if (response.statusCode == 200) {
      setState(() {
        membershipplanlist.addAll(json.decode(response.body)['Response']);
      });
    } else {
      throw Exception('Failed to get data due to ${response.body}');
    }
  }

  int packageId = 0;
  Future _selectmembership(String membershipid, String amount) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _loading = true;
    });
    final body = {
      "id": membershipid.toString(),
    };
    var response = await http.post(Uri.parse(BASE_URL + selectmembership),
        body: jsonEncode(body),
        headers: {
          "Accept": "application/json",
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${prefs.getString("token")}',
        });
    log("Bearer ${prefs.getString("token")}");
    log(body.toString());

    log("response---->${response.body.toString()}");
    if (response.statusCode == 200) {
      setState(() {
        _loading = false;
      });

      if (jsonDecode(response.body)['ErrorCode'] == 0) {
        if (jsonDecode(response.body)['Response'] == null) {
          if (jsonDecode(response.body)['redirection'] == "profile") {
            Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (context) => Dashboard()));
          }
        } else {
          // Navigator.of(context).pushReplacement(MaterialPageRoute(
          //     builder: (context) => const MakePaymentScreen()));
          packageId = jsonDecode(response.body)['Response']['package_id'];
          log("package Id--->$packageId");
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => MakePaymentScreen(
                        packageId: packageId.toString(),
                      )));
        }
      } else {}
    } else {
      setState(() {
        _loading = false;
      });
      log(response.body.toString());
      throw Exception('Failed to get data due to ${response.body}');
    }
  }

  Future _payformembership(String packageId, String paymentid) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _loading = true;
    });
    final body = {
      "user_id": prefs.getString('userid'),
      "package_id": packageId,
      "razorpay_payment_id": paymentid,
    };
    var response = await http
        .post(Uri.parse(BASE_URL + payformembership), body: body, headers: {
      "Accept": "application/json",
      'Content-Type': 'application/json',
      'Authorization': 'Bearer ${prefs.getString("token")}',
    });

    log(response.body);
    setState(() {
      _loading = false;
    });
    if (response.statusCode == 200) {
      if (jsonDecode(response.body)['ErrorCode'] == 0) {
        setState(() {
          _loading = false;
        });
        Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => Dashboard()));
      } else {
        setState(() {
          _loading = false;
        });
      }
    } else {
      setState(() {
        _loading = false;
      });
      // print(response.body);
      throw Exception('Failed to get data due to ${response.body}');
    }
  }
}
