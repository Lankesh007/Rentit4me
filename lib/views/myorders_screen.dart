// ignore_for_file: deprecated_member_use

import 'dart:developer';

import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:rentit4me_new/network/api.dart';
import 'package:rentit4me_new/themes/constant.dart';
import 'package:rentit4me_new/utils/dialog_utils.dart';
import 'package:rentit4me_new/views/order_made_products_details_screen.dart';
import 'package:rentit4me_new/views/order_renew_screen.dart';
import 'package:rentit4me_new/views/renewal_history_screen.dart';
import 'package:rentit4me_new/views/verify_reset_otp.dart';
import 'package:rentit4me_new/widgets/api_helper.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MyOrdersScreen extends StatefulWidget {
  const MyOrdersScreen({Key key}) : super(key: key);

  @override
  State<MyOrdersScreen> createState() => _MyOrdersScreenState();
}

class _MyOrdersScreenState extends State<MyOrdersScreen> {
  String searchvalue = "Enter order id";
  List<dynamic> myorderslist = [];

  bool _progress = false;

  String startdate = "From Date";
  String enddate = "To Date";

  @override
  void initState() {
    super.initState();
    _myorderslist();

    /*Future<ProfileResponse> temp = _getprofile();
    print(temp);
    temp.then((value) {
      setState(() {
        //profileimage = value.avatarBaseUrl.toString()+value.avatarPath.toString();
        name = value.username.toString();
        mobile = value.mobile.toString();
        email = value.email.toString();
        address = value.address.toString();
        print(profileimage);
      });
    });*/
  }

  var orderId;
  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      resizeToAvoidBottomInset: false,
      // appBar: AppBar(
      //   backgroundColor: Colors.white,
      //   elevation: 2.0,
      //   // leading: InkWell(
      //   //     onTap: () {
      //   //       Navigator.of(context).pop();
      //   //     },
      //   //     child: const Icon(
      //   //       Icons.arrow_back,
      //   //       color: kPrimaryColor,
      //   //     )),
      //   title: const Text("My Orders", style: TextStyle(color: kPrimaryColor)),
      //   centerTitle: true,
      // ),
      body: RefreshIndicator(
        onRefresh: () async {
          _myorderslist();
        },
        child: ModalProgressHUD(
          inAsyncCall: _progress,
          color: kPrimaryColor,
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                children: [
                  SizedBox(
                    height: 20,
                  ),
                  Card(
                    elevation: 4.0,
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        children: [
                          const SizedBox(height: 5),
                          Padding(
                            padding: const EdgeInsets.only(left: 0.0),
                            child: TextFormField(
                              decoration: InputDecoration(
                                enabled: true,
                                focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                    borderSide: BorderSide(
                                        color: Colors.deepOrangeAccent)),
                                enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                    borderSide: BorderSide(
                                      color: Colors.deepOrangeAccent,
                                    )),
                                contentPadding: EdgeInsets.only(left: 5),
                                hintText: searchvalue,
                                border: InputBorder.none,
                              ),
                              onChanged: (value) {
                                setState(() {
                                  searchvalue = value;
                                });
                              },
                            ),
                          ),
                          SizedBox(height: 10),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                      width: size.width * 0.42,
                                      decoration: BoxDecoration(
                                          border: Border.all(
                                              width: 1,
                                              color: Colors.deepOrangeAccent),
                                          borderRadius: BorderRadius.all(
                                              Radius.circular(12))),
                                      child: Padding(
                                        padding:
                                            const EdgeInsets.only(left: 10.0),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text(startdate,
                                                style: TextStyle(
                                                    color: Colors.grey)),
                                            IconButton(
                                                onPressed: () {
                                                  _selectStartDate(context);
                                                },
                                                icon: Icon(
                                                    Icons.calendar_today_sharp,
                                                    size: 16,
                                                    color: kPrimaryColor))
                                          ],
                                        ),
                                      )),
                                ],
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                      width: size.width * 0.42,
                                      decoration: BoxDecoration(
                                          border: Border.all(
                                              width: 1,
                                              color: Colors.deepOrangeAccent),
                                          borderRadius: BorderRadius.all(
                                              Radius.circular(12))),
                                      child: Padding(
                                        padding:
                                            const EdgeInsets.only(left: 10.0),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text(enddate,
                                                style: TextStyle(
                                                    color: Colors.grey)),
                                            IconButton(
                                                onPressed: () {
                                                  _selectEndtDate(context);
                                                },
                                                icon: Icon(
                                                    Icons.calendar_today_sharp,
                                                    size: 16,
                                                    color: kPrimaryColor))
                                          ],
                                        ),
                                      )),
                                ],
                              )
                            ],
                          ),
                          const SizedBox(height: 10),
                          InkWell(
                            onTap: () {
                              if (searchvalue == "Enter order id" &&
                                  startdate == "From Date") {
                                showToast(
                                    "Please enter order id or select date");
                              } else {
                                if (searchvalue == "Enter order id" ||
                                    searchvalue.isEmpty) {
                                  _myorderslistByDate();
                                } else {
                                  _myorderslistBySearch();
                                }
                              }
                            },
                            child: Card(
                              elevation: 8.0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8.0),
                              ),
                              child: Container(
                                height: 40,
                                width: double.infinity,
                                alignment: Alignment.center,
                                decoration: const BoxDecoration(
                                    color: Colors.deepOrangeAccent,
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(8.0))),
                                child: const Text("Filter",
                                    style: TextStyle(color: Colors.white)),
                              ),
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 5),
                  RefreshIndicator(
                    onRefresh: () async {
                      _myorderslist();
                    },
                    child: SizedBox(
                      height: size.height * 0.50,
                      child: myorderslist.isEmpty
                          ? Column(
                              children: [
                                SizedBox(
                                  height: 20,
                                ),
                                Container(
                                  child: Text("No Products Found !!"),
                                ),
                              ],
                            )
                          : ListView.separated(
                              padding: EdgeInsets.zero,
                              shrinkWrap: true,
                              itemCount: myorderslist.length,
                              separatorBuilder:
                                  (BuildContext context, int index) =>
                                      const Divider(),
                              itemBuilder: (BuildContext context, int index) {
                                orderId = myorderslist[index]['id'];
                                return InkWell(
                                  onTap: () {
                                    // showDialog(
                                    //     context: context,
                                    //     builder: (_) => AlertDialog(
                                    //         title: const Text('Detail Information'),
                                    //         content: SingleChildScrollView(
                                    //             child: Column(children: [
                                    //           Card(
                                    //             color: Colors.grey[100],
                                    //             child: ListTile(
                                    //               title: const Text("Rentee"),
                                    //               subtitle: Text(myorderslist[index]
                                    //                       ['name']
                                    //                   .toString()),
                                    //             ),
                                    //           ),
                                    //           Card(
                                    //             color: Colors.grey[100],
                                    //             child: ListTile(
                                    //               title: const Text("Product Name"),
                                    //               subtitle: Text(myorderslist[index]
                                    //                       ["title"]
                                    //                   .toString()),
                                    //             ),
                                    //           ),
                                    //           Card(
                                    //             color: Colors.grey[100],
                                    //             child: ListTile(
                                    //               title: const Text("Product Quantity"),
                                    //               subtitle: Text(myorderslist[index]
                                    //                       ["quantity"]
                                    //                   .toString()),
                                    //             ),
                                    //           ),
                                    //           Card(
                                    //             color: Colors.grey[100],
                                    //             child: ListTile(
                                    //               title: const Text("Rent Type"),
                                    //               subtitle: Text(myorderslist[index]
                                    //                       ["rent_type_name"]
                                    //                   .toString()),
                                    //             ),
                                    //           ),
                                    //           Card(
                                    //             color: Colors.grey[100],
                                    //             child: ListTile(
                                    //               title: const Text("Period"),
                                    //               subtitle: Text(myorderslist[index]
                                    //                       ["period"]
                                    //                   .toString()),
                                    //             ),
                                    //           ),
                                    //           Card(
                                    //             color: Colors.grey[100],
                                    //             child: ListTile(
                                    //               title: const Text("Product Price(XCD)"),
                                    //               subtitle: Text(myorderslist[index]
                                    //                       ["product_price"]
                                    //                   .toString()),
                                    //             ),
                                    //           ),
                                    //           Card(
                                    //             color: Colors.grey[100],
                                    //             child: ListTile(
                                    //               title: const Text("Offer Amount(XCD)"),
                                    //               subtitle: Text(myorderslist[index]
                                    //                       ["renter_amount"]
                                    //                   .toString()),
                                    //             ),
                                    //           ),
                                    //           Card(
                                    //             color: Colors.grey[100],
                                    //             child: ListTile(
                                    //               title: const Text("Total Rent(XCD)"),
                                    //               subtitle: Text(myorderslist[index]
                                    //                       ["total_rent"]
                                    //                   .toString()),
                                    //             ),
                                    //           ),
                                    //           Card(
                                    //             color: Colors.grey[100],
                                    //             child: ListTile(
                                    //               title:
                                    //                   const Text("Total Security(XCD)"),
                                    //               subtitle: Text(myorderslist[index]
                                    //                       ["total_security"]
                                    //                   .toString()),
                                    //             ),
                                    //           ),
                                    //           Card(
                                    //             color: Colors.grey[100],
                                    //             child: ListTile(
                                    //               title: const Text("Total Rent(XCD)"),
                                    //               subtitle: Text(myorderslist[index]
                                    //                       ["total_rent"]
                                    //                   .toString()),
                                    //             ),
                                    //           ),
                                    //           Card(
                                    //             color: Colors.grey[100],
                                    //             child: ListTile(
                                    //               title: const Text("Final Amount(XCD)"),
                                    //               subtitle: Text(myorderslist[index]
                                    //                       ["final_amount"]
                                    //                   .toString()),
                                    //             ),
                                    //           ),
                                    //         ]))));
                                  },
                                  child: Card(
                                    elevation: 4.0,
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 10, horizontal: 10),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Padding(
                                              padding: const EdgeInsets.only(
                                                  left: 0.0),
                                              child: Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                children: [
                                                  Text(
                                                      "Order Id : ${myorderslist[index]['order_id']}",
                                                      style: TextStyle(
                                                          color: Colors.black,
                                                          fontWeight:
                                                              FontWeight.w500)),
                                                  Text(
                                                      "Ad Id : ${myorderslist[index]['ad_id']}",
                                                      style: TextStyle(
                                                          color: Colors.black,
                                                          fontWeight:
                                                              FontWeight.w500)),
                                                ],
                                              )),
                                          Divider(
                                            thickness: 0.9,
                                          ),
                                          Container(
                                            margin:
                                                const EdgeInsets.only(top: 10),
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: [
                                                Text(
                                                    "Product Name : ${myorderslist[index]['title']}",
                                                    style: TextStyle(
                                                        color: Colors.black,
                                                        fontWeight:
                                                            FontWeight.w500)),
                                                Text(
                                                    "Quantity: ${myorderslist[index]['quantity']}"),
                                              ],
                                            ),
                                          ),
                                          SizedBox(height: 10.0),
                                          Padding(
                                            padding: const EdgeInsets.all(.0),
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: [
                                                myorderslist[index]['period']
                                                                .toString() ==
                                                            "" ||
                                                        myorderslist[index]
                                                                ['period'] ==
                                                            null
                                                    ? SizedBox()
                                                    : Container(
                                                        width: MediaQuery.of(
                                                                    context)
                                                                .size
                                                                .width *
                                                            0.88,
                                                        child: Row(
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .spaceBetween,
                                                          children: [
                                                            Text(
                                                                "Duration: ${myorderslist[index]['period']} ${_getrenttype(myorderslist[index]['period'].toString(), myorderslist[index]['rent_type_name'].toString())}",
                                                                style: TextStyle(
                                                                    color: Colors
                                                                        .black,
                                                                    fontSize:
                                                                        14)),
                                                            Text(
                                                                "Convenince Fee : ${myorderslist[index]['convenience_fee']}",
                                                                style: TextStyle(
                                                                    color: Colors
                                                                        .black,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .w500)),
                                                          ],
                                                        ),
                                                      ),
                                                //Text("Period: "+myorderslist[index]['period'].toString()),
                                              ],
                                            ),
                                          ),
                                          Container(
                                            margin:
                                                const EdgeInsets.only(top: 10),
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: [
                                                Text(
                                                    "Total Rent : ${myorderslist[index]['final_amount']}",
                                                    style: TextStyle(
                                                        color: Colors.black,
                                                        fontWeight:
                                                            FontWeight.w500)),
                                                Text(
                                                    "Security : ${myorderslist[index]['total_security']}",
                                                    style: TextStyle(
                                                        color: Colors.black,
                                                        fontWeight:
                                                            FontWeight.w500)),
                                              ],
                                            ),
                                          ),
                                          Container(
                                            margin:
                                                const EdgeInsets.only(top: 10),
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: [
                                                Text(
                                                    "Start Date : ${myorderslist[index]['start_date']}",
                                                    style: TextStyle(
                                                        color: Colors.black,
                                                        fontWeight:
                                                            FontWeight.w500)),
                                                InkWell(
                                                  onTap: () {
                                                    myorderslist[index][
                                                                'renewal_count'] !=
                                                            0
                                                        ? Navigator.push(
                                                            context,
                                                            MaterialPageRoute(
                                                                builder:
                                                                    (context) =>
                                                                        RenewalHistoryScreen(
                                                                          orderId:
                                                                              myorderslist[index]['id'].toString(),
                                                                        )))
                                                        : SizedBox();
                                                  },
                                                  child: Container(
                                                    alignment: Alignment.center,
                                                    height: 30,
                                                    width: 100,
                                                    decoration: BoxDecoration(
                                                        color: Appcolors
                                                            .primaryColor,
                                                        border: Border.all(
                                                            color: Colors.red),
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(8)),
                                                    child: Text(
                                                        "Renewal : ${myorderslist[index]['renewal_count']}",
                                                        style: TextStyle(
                                                          color: Colors.white,
                                                          fontWeight:
                                                              FontWeight.w600,
                                                        )),
                                                  ),
                                                )
                                              ],
                                            ),
                                          ),
                                          Container(
                                            margin:
                                                const EdgeInsets.only(top: 10),
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: [
                                                Text(
                                                  "End Date : ${myorderslist[index]['end_date']}",
                                                  style: TextStyle(
                                                      color: Colors.black,
                                                      fontWeight:
                                                          FontWeight.w500),
                                                ),
                                              ],
                                            ),
                                          ),
                                          SizedBox(height: 10.0),
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              Container(
                                                child: Text(
                                                    "Status: ${myorderslist[index]['status']}"),
                                              ),
                                              Container(
                                                child: Column(
                                                  children: [
                                                    myorderslist[index][
                                                                'renewal_status'] ==
                                                            true
                                                        ? Column(
                                                            children: [
                                                              InkWell(
                                                                onTap: () {
                                                                  Navigator
                                                                      .push(
                                                                    context,
                                                                    MaterialPageRoute(
                                                                      builder:
                                                                          (context) =>
                                                                              OrderRenewScreen(
                                                                        orderId:
                                                                            myorderslist[index]['id'].toString(),
                                                                      ),
                                                                    ),
                                                                  );
                                                                },
                                                                child:
                                                                    Container(
                                                                  height: 30,
                                                                  width: 100,
                                                                  alignment:
                                                                      Alignment
                                                                          .center,
                                                                  decoration: BoxDecoration(
                                                                      borderRadius:
                                                                          BorderRadius.circular(
                                                                              10),
                                                                      border: Border.all(
                                                                          color:
                                                                              Colors.orange[900])),
                                                                  child: Text(
                                                                    "Renew",
                                                                    style: TextStyle(
                                                                        color: Colors.blue[
                                                                            800],
                                                                        fontWeight:
                                                                            FontWeight.bold),
                                                                  ),
                                                                ),
                                                              ),
                                                              SizedBox(
                                                                height: 10,
                                                              ),
                                                              InkWell(
                                                                onTap: () {
                                                                  orderReturenApi();
                                                                },
                                                                child:
                                                                    Container(
                                                                  height: 30,
                                                                  width: 100,
                                                                  alignment:
                                                                      Alignment
                                                                          .center,
                                                                  decoration: BoxDecoration(
                                                                      borderRadius:
                                                                          BorderRadius.circular(
                                                                              10),
                                                                      border: Border.all(
                                                                          color:
                                                                              Colors.orange[900])),
                                                                  child: Text(
                                                                    "Return",
                                                                    style: TextStyle(
                                                                        color: Colors.blue[
                                                                            800],
                                                                        fontWeight:
                                                                            FontWeight.bold),
                                                                  ),
                                                                ),
                                                              )
                                                            ],
                                                          )
                                                        : SizedBox(),
                                                    SizedBox(
                                                      height: 10,
                                                    ),
                                                    myorderslist[index]
                                                                ['status'] ==
                                                            "expired"
                                                        ? InkWell(
                                                            onTap: () {
                                                              orderReturenApi();
                                                            },
                                                            child: Container(
                                                              height: 30,
                                                              width: 100,
                                                              alignment:
                                                                  Alignment
                                                                      .center,
                                                              decoration: BoxDecoration(
                                                                  borderRadius:
                                                                      BorderRadius
                                                                          .circular(
                                                                              10),
                                                                  border: Border.all(
                                                                      color: Colors
                                                                              .orange[
                                                                          900])),
                                                              child: Text(
                                                                "Return",
                                                                style: TextStyle(
                                                                    color: Colors
                                                                            .blue[
                                                                        800],
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .bold),
                                                              ),
                                                            ),
                                                          )
                                                        : SizedBox()
                                                  ],
                                                ),
                                              ),
                                            ],
                                          ),
                                          SizedBox(
                                            height: 10,
                                          ),
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              InkWell(
                                                onTap: () {
                                                  Navigator.push(
                                                      context,
                                                      MaterialPageRoute(
                                                          builder: (context) =>
                                                              OrderMadeProductsDetailsScreen(
                                                                orderId: myorderslist[
                                                                        index][
                                                                    'order_id'],
                                                                orderIdForFeedback:
                                                                    myorderslist[index]
                                                                            [
                                                                            'id']
                                                                        .toString(),
                                                              )));
                                                },
                                                child: Container(
                                                    height: 30,
                                                    width: 100,
                                                    alignment: Alignment.center,
                                                    decoration: BoxDecoration(
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(10),
                                                        border: Border.all(
                                                            color: Colors
                                                                .orange[900])),
                                                    child: Text(
                                                      "View",
                                                      style: TextStyle(
                                                          color:
                                                              Colors.blue[900]),
                                                    )),
                                              ),
                                              myorderslist[index]['status'] ==
                                                      "delivered"
                                                  ? InkWell(
                                                      onTap: () {
                                                        _submitrespondCancel(
                                                            myorderslist[index]
                                                                    ['id']
                                                                .toString(),
                                                            myorderslist[index][
                                                                        'status'] ==
                                                                    "delivered"
                                                                ? "active"
                                                                : "");
                                                      },
                                                      child: Container(
                                                          height: 30,
                                                          width: 100,
                                                          alignment:
                                                              Alignment.center,
                                                          decoration: BoxDecoration(
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          10),
                                                              border: Border.all(
                                                                  color: Colors
                                                                          .orange[
                                                                      900])),
                                                          child: Text(
                                                            "Mark Received",
                                                            style: TextStyle(
                                                                color: Colors
                                                                    .blue[900]),
                                                          )),
                                                    )
                                                  : SizedBox(),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                    ),
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _submitrespondCancel(String orderid, String respond) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _progress = true;
    });
    final body = {
      "order_id": orderid,
      "status": respond,
    };
    var response = await http.post(Uri.parse(BASE_URL + orderrespond),
        body: jsonEncode(body),
        headers: {
          "Accept": "application/json",
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${prefs.getString("token")}'
        });
    setState(() {
      _progress = false;
    });
    if (response.statusCode == 200) {
      log("response---${response.body}");

      if (jsonDecode(response.body)['ErrorCode'].toString() == "0") {
        // Navigator.of(context, rootNavigator: true).pop('dialog');
        _myorderslist();
      } else {
        // Navigator.of(context, rootNavigator: true).pop('dialog');
      }
    } else {
      setState(() {
        _progress = false;
      });
      print(response.body);
      throw Exception('Failed to get data due to ${response.body}');
    }
  }

  Future<void> _myorderslist() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    print(prefs.getString('userid'));
    setState(() {
      _progress = true;
      myorderslist.clear();
    });
    final body = {};
    var response = await http
        .post(Uri.parse(BASE_URL + myorders), body: jsonEncode(body), headers: {
      "Accept": "application/json",
      'Content-Type': 'application/json',
      'Authorization': 'Bearer ${prefs.getString("token")}',
    });
    print(response.body);
    if (response.statusCode == 200) {
      if (jsonDecode(response.body)['ErrorCode'].toString() == "0") {
        setState(() {
          myorderslist
              .addAll(jsonDecode(response.body)['Response']['Orders']['data']);
          log("orderList-->$myorderslist");
          _progress = false;
          searchvalue.isEmpty;
        });
      } else {
        setState(() {
          _progress = false;
        });
      }
    } else {
      setState(() {
        _progress = false;
      });
      print(response.body);
      throw Exception('Failed to get data due to ${response.body}');
    }
  }

  Future<void> _myorderslistByDate() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _progress = true;
      myorderslist.clear();
    });
    final body = {
      "id": prefs.getString('userid'),
      "from_date": startdate,
      "to_date": enddate
    };
    var response = await http
        .post(Uri.parse(BASE_URL + myorders), body: jsonEncode(body), headers: {
      "Accept": "application/json",
      'Content-Type': 'application/json',
      'Authorization': 'Bearer ${prefs.getString("token")}',
    });
    print(response.body);
    if (response.statusCode == 200) {
      if (jsonDecode(response.body)['ErrorCode'].toString() == "0") {
        setState(() {
          myorderslist
              .addAll(jsonDecode(response.body)['Response']['Orders']['data']);
          _progress = false;
        });
      } else {
        setState(() {
          _progress = false;
        });
      }
    } else {
      setState(() {
        _progress = false;
      });
      print(response.body);
      throw Exception('Failed to get data due to ${response.body}');
    }
  }

  Future<void> _myorderslistBySearch() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _progress = true;
      myorderslist.clear();
    });
    print(jsonEncode({
      "id": prefs.getString('userid'),
      "search": searchvalue,
    }));
    final body = {
      "id": prefs.getString('userid'),
      "search": searchvalue,
    };
    var response = await http
        .post(Uri.parse(BASE_URL + myorders), body: jsonEncode(body), headers: {
      "Accept": "application/json",
      'Content-Type': 'application/json',
      'Authorization': 'Bearer ${prefs.getString("token")}',
    });
    print(response.body);
    if (response.statusCode == 200) {
      if (jsonDecode(response.body)['ErrorCode'].toString() == "0") {
        setState(() {
          myorderslist
              .addAll(jsonDecode(response.body)['Response']['Orders']['data']);
          _progress = false;
        });
      } else {
        setState(() {
          _progress = false;
        });
      }
    } else {
      setState(() {
        _progress = false;
      });
      print(response.body);
      throw Exception('Failed to get data due to ${response.body}');
    }
  }

  Widget _getaction(String statusvalue) {
    if (statusvalue == "pending" ||
        statusvalue == "active" ||
        statusvalue == "cancelled" ||
        statusvalue == "scheduler pickup") {
      return InkWell(
        onTap: () {},
        child: Container(
          width: 80,
          padding: const EdgeInsets.all(4.0),
          decoration: BoxDecoration(
              borderRadius: BorderRadius.all(Radius.circular(4.0)),
              border: Border.all(color: Colors.grey)),
          child: const Text("NA",
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey)),
        ),
      );
    }
  }

  Future<void> _selectStartDate(BuildContext context) async {
    final DateTime picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      //firstDate: DateTime.now().subtract(Duration(days: 0)),
      firstDate: DateTime(2015, 8),
      lastDate: DateTime(2101),
      builder: (BuildContext context, Widget child) {
        return Theme(
          data: ThemeData(
              primaryColor: Colors.indigo,
              accentColor: Colors.indigo,
              primarySwatch: const MaterialColor(
                0xFF3949AB,
                <int, Color>{
                  50: Colors.indigo,
                  100: Colors.indigo,
                  200: Colors.indigo,
                  300: Colors.indigo,
                  400: Colors.indigo,
                  500: Colors.indigo,
                  600: Colors.indigo,
                  700: Colors.indigo,
                  800: Colors.indigo,
                  900: Colors.indigo,
                },
              )),
          child: child,
        );
      },
    );
    if (picked != null) {
      setState(() {
        startdate = DateFormat('yyyy-MM-dd').format(picked);
      });
    }
  }

  Future<void> _selectEndtDate(BuildContext context) async {
    final DateTime picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      //firstDate: DateTime.now().subtract(Duration(days: 0)),
      firstDate: DateTime(2015, 8),
      lastDate: DateTime(2101),
      builder: (BuildContext context, Widget child) {
        return Theme(
          data: ThemeData(
              primaryColor: Colors.indigo,
              accentColor: Colors.indigo,
              primarySwatch: const MaterialColor(
                0xFF3949AB,
                <int, Color>{
                  50: Colors.indigo,
                  100: Colors.indigo,
                  200: Colors.indigo,
                  300: Colors.indigo,
                  400: Colors.indigo,
                  500: Colors.indigo,
                  600: Colors.indigo,
                  700: Colors.indigo,
                  800: Colors.indigo,
                  900: Colors.indigo,
                },
              )),
          child: child,
        );
      },
    );
    if (picked != null) {
      setState(() {
        enddate = DateFormat('yyyy-MM-dd').format(picked);
      });
    }
  }

  // Future<void> _confirmation(BuildContext context, String orderid) {
  //   return showDialog(
  //     builder: (context) => AlertDialog(
  //       actionsPadding: EdgeInsets.all(0),
  //       insetPadding: EdgeInsets.all(0),
  //       title: const Text('Confirmation!!'),
  //       content: const Text(
  //         "Are you sure, product recieved?",
  //         style: TextStyle(color: Colors.black54),
  //       ),
  //       actions: <Widget>[
  //         FlatButton(
  //           onPressed: () {
  //             Navigator.pop(context);
  //           },
  //           child: const Text('CANCEL', style: TextStyle(color: kPrimaryColor)),
  //         ),
  //         FlatButton(
  //           onPressed: () {
  //             Navigator.pop(context);
  //             _submitrespond(orderid, "active");
  //             //Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (_) => SignUp()), (route) => false);
  //           },
  //           child: const Text(
  //             'YES',
  //             style: TextStyle(color: kPrimaryColor),
  //           ),
  //         ),
  //       ],
  //     ),
  //     context: context,
  //   );
  // }

  Future<void> _submitrespond(String orderid, String respond) async {
    setState(() {
      _progress = true;
    });
    final body = {
      "order_id": orderid,
      "status": respond,
    };
    print(body);
    var response = await http.post(Uri.parse(BASE_URL + orderrespond),
        body: jsonEncode(body),
        headers: {
          "Accept": "application/json",
          'Content-Type': 'application/json'
        });
    setState(() {
      _progress = false;
    });
    if (response.statusCode == 200) {
      if (jsonDecode(response.body)['ErrorCode'].toString() == "0") {
        _myorderslist();
      } else {}
    } else {
      setState(() {
        _progress = false;
      });
      print(response.body);
      throw Exception('Failed to get data due to ${response.body}');
    }
  }

  String _getrenttype(String period, String renttypevalue) {
    if (renttypevalue.toLowerCase() == "hourly" && period == "1") {
      return "Hour";
    }
    if (renttypevalue.toLowerCase() == "hourly" && period != "1") {
      return "Hours";
    } else if (renttypevalue.toLowerCase() == "days" && period == "1") {
      return "Day";
    } else if (renttypevalue.toLowerCase() == "days" && period != "1") {
      return "Days";
    } else if (renttypevalue.toLowerCase() == "monthly" && period == "1") {
      return "Month";
    } else if (renttypevalue.toLowerCase() == "monthly" && period != "1") {
      return "Months";
    } else if (renttypevalue == "yearly" && period == "1") {
      return "Year";
    } else if (renttypevalue == "yearly" && period != "1") {
      return "Years";
    }
  }

  Future orderReturenApi() async {
    var url = "${BASE_URL}renter-orders/status";
    var body = {
      "order_id": orderId.toString(),
      "status": "returned",
    };
    var response = await APIHelper.apiPostRequest(url, body);
    var result = jsonDecode(response);
    if (result['ErrorCode'] == 0) {
      showToast(result['ErrorMessage']);
      _myorderslist();
    } else {
      showToast(result['ErrorMessage']);
    }
  }
}
