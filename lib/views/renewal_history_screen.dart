import 'dart:convert';
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:rentit4me_new/network/api.dart';
import 'package:rentit4me_new/utils/dialog_utils.dart';
import 'package:rentit4me_new/views/renewd_order_details.dart';
import 'package:rentit4me_new/widgets/api_helper.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../themes/constant.dart';

class RenewalHistoryScreen extends StatefulWidget {
  final String orderId;
  const RenewalHistoryScreen({this.orderId, Key key}) : super(key: key);

  @override
  State<RenewalHistoryScreen> createState() => _RenewalHistoryScreenState();
}

class _RenewalHistoryScreenState extends State<RenewalHistoryScreen> {
  double height = 0;
  double width = 0;
  List orderRenewalList = [];
  String userId;
  bool pageLoader = false;

  _getPrefsValue() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    userId = preferences.getString('userid');
    log("userId-->$userId");
  }

  @override
  void initState() {
    _getPrefsValue();
    getRenewalDetails();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    height = MediaQuery.of(context).size.height;
    width = MediaQuery.of(context).size.width;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Appcolors.primaryColor,
        title: Text(
          "Renewal History",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
      body: ListView(
        physics: NeverScrollableScrollPhysics(),
        children: [
          Divider(),
          // order details part
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 10),
            alignment: Alignment.centerLeft,
            child: Text(
              "Order Details",
              style: TextStyle(
                  color: Appcolors.secondaryColor,
                  fontSize: 20,
                  fontWeight: FontWeight.w600),
            ),
          ),
          pageLoader == true
              ? Container(
                  height: height * 0.4,
                  alignment: Alignment.center,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      CircularProgressIndicator(),
                      SizedBox(
                        height: 10,
                      ),
                      Text(
                        "Please Wait...",
                        style: TextStyle(
                            fontWeight: FontWeight.w600, fontSize: 18),
                      )
                    ],
                  ),
                )
              : orderRenewalList.isEmpty
                  ? Container(
                      alignment: Alignment.center,
                      child: Text("No data found !!"))
                  : SizedBox(
                      height: height * 0.32,
                      width: width,
                      child: ListView.builder(
                        physics: NeverScrollableScrollPhysics(),
                        shrinkWrap: true,
                        itemCount: orderRenewalList.length,
                        itemBuilder: (context, index) {
                          var items = orderRenewalList[index];
                          return items['renewal_status'] == 0
                              ? Column(
                                  children: [
                                    InkWell(
                                      onTap: () {
                                        Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                                builder: (context) =>
                                                    OrderRenewdDetailsScreen(
                                                      renewalOrderId:
                                                          items['id']
                                                              .toString(),
                                                    )));
                                      },
                                      child: SizedBox(
                                        width: width * 0.95,
                                        child: Card(
                                          elevation: 5,
                                          child: Column(
                                            children: [
                                              SizedBox(height: 3),
                                              Container(
                                                  width: width * 0.95,
                                                  margin: const EdgeInsets
                                                      .symmetric(horizontal: 2),
                                                  height: 30,
                                                  color:
                                                      Appcolors.secondaryColor,
                                                  child: Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .spaceBetween,
                                                    children: [
                                                      Text(
                                                        "Order id : ",
                                                        style: TextStyle(
                                                            fontSize: 16,
                                                            color:
                                                                Colors.white),
                                                      ),
                                                      Text(
                                                        items['order_id']
                                                            .toString(),
                                                        style: TextStyle(
                                                            fontSize: 16,
                                                            color:
                                                                Colors.white),
                                                      ),
                                                    ],
                                                  )),
                                              Divider(),
                                              SizedBox(
                                                  width: width * 0.9,
                                                  child: Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .spaceBetween,
                                                    children: [
                                                      Text(
                                                        "Quantity : ",
                                                        style: TextStyle(
                                                            fontSize: 16),
                                                      ),
                                                      Text(
                                                        items['quantity']
                                                            .toString(),
                                                        style: TextStyle(
                                                            fontSize: 16),
                                                      ),
                                                    ],
                                                  )),
                                              Divider(),
                                              SizedBox(
                                                  width: width * 0.9,
                                                  child: Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .spaceBetween,
                                                    children: [
                                                      Text(
                                                        "Duration : ",
                                                        style: TextStyle(
                                                            fontSize: 16),
                                                      ),
                                                      Text(
                                                        items['period']
                                                            .toString(),
                                                        style: TextStyle(
                                                            fontSize: 16),
                                                      ),
                                                    ],
                                                  )),
                                              userId !=
                                                      items['advertiser_id']
                                                          .toString()
                                                  ? Column(
                                                      children: [
                                                        Divider(),
                                                        SizedBox(
                                                            width: width * 0.9,
                                                            child: Row(
                                                              mainAxisAlignment:
                                                                  MainAxisAlignment
                                                                      .spaceBetween,
                                                              children: [
                                                                Text(
                                                                  "Convenience Fee : ",
                                                                  style: TextStyle(
                                                                      fontSize:
                                                                          16),
                                                                ),
                                                                Text(
                                                                  items[
                                                                      'convenience_fee'],
                                                                  style: TextStyle(
                                                                      fontSize:
                                                                          16),
                                                                ),
                                                              ],
                                                            )),
                                                      ],
                                                    )
                                                  : SizedBox(),
                                              Divider(),
                                              SizedBox(
                                                  width: width * 0.9,
                                                  child: Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .spaceBetween,
                                                    children: [
                                                      Text(
                                                        "Total Rent (INR) : ",
                                                        style: TextStyle(
                                                            fontSize: 16),
                                                      ),
                                                      Text(
                                                        items['total_amount']
                                                            .toString(),
                                                        style: TextStyle(
                                                            fontSize: 16),
                                                      ),
                                                    ],
                                                  )),
                                              items['convenience_fee'] == null
                                                  ? SizedBox()
                                                  : Column(
                                                      children: [
                                                        Divider(),
                                                        SizedBox(
                                                            width: width * 0.9,
                                                            child: Row(
                                                              mainAxisAlignment:
                                                                  MainAxisAlignment
                                                                      .spaceBetween,
                                                              children: [
                                                                Text(
                                                                  "Security : ",
                                                                  style: TextStyle(
                                                                      fontSize:
                                                                          16),
                                                                ),
                                                                Text(
                                                                  items['convenience_fee']
                                                                      .toString(),
                                                                  style: TextStyle(
                                                                      fontSize:
                                                                          16),
                                                                ),
                                                              ],
                                                            )),
                                                      ],
                                                    ),
                                              Divider(),
                                              SizedBox(
                                                  width: width * 0.9,
                                                  child: Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .spaceBetween,
                                                    children: [
                                                      Text(
                                                        "Start Date : ",
                                                        style: TextStyle(
                                                            fontSize: 16),
                                                      ),
                                                      Text(
                                                        items['start_date'],
                                                        style: TextStyle(
                                                            fontSize: 16),
                                                      ),
                                                    ],
                                                  )),
                                              Divider(),
                                              SizedBox(
                                                  width: width * 0.9,
                                                  child: Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .spaceBetween,
                                                    children: [
                                                      Text(
                                                        "End Date : ",
                                                        style: TextStyle(
                                                            fontSize: 16),
                                                      ),
                                                      Text(
                                                        items['end_date'],
                                                        style: TextStyle(
                                                            fontSize: 16),
                                                      ),
                                                    ],
                                                  )),
                                              SizedBox(height: 3),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                )
                              : SizedBox();
                        },
                      ),
                    ),
          Divider(),

          // renewal history part

          Container(
            margin: const EdgeInsets.symmetric(horizontal: 10),
            alignment: Alignment.centerLeft,
            child: Text(
              "Renewal History",
              style: TextStyle(
                  color: Appcolors.secondaryColor,
                  fontSize: 20,
                  fontWeight: FontWeight.w600),
            ),
          ),
          Divider(),
          SizedBox(
            height: 10,
          ),
          pageLoader == true
              ? Container(
                  height: height * 0.4,
                  alignment: Alignment.center,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      CircularProgressIndicator(),
                      SizedBox(
                        height: 10,
                      ),
                      Text(
                        "Please Wait...",
                        style: TextStyle(
                            fontWeight: FontWeight.w600, fontSize: 18),
                      )
                    ],
                  ),
                )
              : orderRenewalList.isEmpty
                  ? Container(
                      alignment: Alignment.center,
                      child: Text("No data found !!"))
                  : SizedBox(
                      height: height * 0.4,
                      width: width,
                      child: ListView.builder(
                        physics: BouncingScrollPhysics(),
                        itemCount: orderRenewalList.length,
                        itemBuilder: (context, index) {
                          var items = orderRenewalList[index];
                          return items['renewal_status'] >= 1
                              ? Column(
                                  children: [
                                    InkWell(
                                      onTap: () {
                                        Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                                builder: (context) =>
                                                    OrderRenewdDetailsScreen(
                                                      renewalOrderId:
                                                          items['id']
                                                              .toString(),
                                                    )));
                                      },
                                      child: SizedBox(
                                        width: width * 0.95,
                                        child: Card(
                                          elevation: 5,
                                          child: Column(
                                            children: [
                                              SizedBox(height: 3),
                                              Container(
                                                  width: width * 0.95,
                                                  margin: const EdgeInsets
                                                      .symmetric(horizontal: 2),
                                                  height: 30,
                                                  color: Appcolors.primaryColor,
                                                  child: Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .spaceBetween,
                                                    children: [
                                                      Text(
                                                        "Order id : ",
                                                        style: TextStyle(
                                                            fontSize: 16,
                                                            color:
                                                                Colors.white),
                                                      ),
                                                      Text(
                                                        items['order_id']
                                                            .toString(),
                                                        style: TextStyle(
                                                            fontSize: 16,
                                                            color:
                                                                Colors.white),
                                                      ),
                                                    ],
                                                  )),
                                              Divider(),
                                              SizedBox(
                                                  width: width * 0.9,
                                                  child: Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .spaceBetween,
                                                    children: [
                                                      Text(
                                                        "Quantity : ",
                                                        style: TextStyle(
                                                            fontSize: 16),
                                                      ),
                                                      Text(
                                                        items['quantity']
                                                            .toString(),
                                                        style: TextStyle(
                                                            fontSize: 16),
                                                      ),
                                                    ],
                                                  )),
                                              Divider(),
                                              SizedBox(
                                                  width: width * 0.9,
                                                  child: Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .spaceBetween,
                                                    children: [
                                                      Text(
                                                        "Duration : ",
                                                        style: TextStyle(
                                                            fontSize: 16),
                                                      ),
                                                      Text(
                                                        items['period']
                                                            .toString(),
                                                        style: TextStyle(
                                                            fontSize: 16),
                                                      ),
                                                    ],
                                                  )),
                                              userId !=
                                                      items['advertiser_id']
                                                          .toString()
                                                  ? Column(
                                                      children: [
                                                        Divider(),
                                                        SizedBox(
                                                            width: width * 0.9,
                                                            child: Row(
                                                              mainAxisAlignment:
                                                                  MainAxisAlignment
                                                                      .spaceBetween,
                                                              children: [
                                                                Text(
                                                                  "Convenience Fee : ",
                                                                  style: TextStyle(
                                                                      fontSize:
                                                                          16),
                                                                ),
                                                                Text(
                                                                  items['convenience_fee']
                                                                      .toString(),
                                                                  style: TextStyle(
                                                                      fontSize:
                                                                          16),
                                                                ),
                                                              ],
                                                            )),
                                                      ],
                                                    )
                                                  : SizedBox(),
                                              Divider(),
                                              SizedBox(
                                                  width: width * 0.9,
                                                  child: Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .spaceBetween,
                                                    children: [
                                                      Text(
                                                        "Total Rent (INR) : ",
                                                        style: TextStyle(
                                                            fontSize: 16),
                                                      ),
                                                      Text(
                                                        items['total_amount']
                                                            .toString(),
                                                        style: TextStyle(
                                                            fontSize: 16),
                                                      ),
                                                    ],
                                                  )),
                                              items['convenience_fee'] == null
                                                  ? SizedBox()
                                                  : Column(
                                                      children: [
                                                        Divider(),
                                                        SizedBox(
                                                            width: width * 0.9,
                                                            child: Row(
                                                              mainAxisAlignment:
                                                                  MainAxisAlignment
                                                                      .spaceBetween,
                                                              children: [
                                                                Text(
                                                                  "Security : ",
                                                                  style: TextStyle(
                                                                      fontSize:
                                                                          16),
                                                                ),
                                                                Text(
                                                                  items['convenience_fee']
                                                                      .toString(),
                                                                  style: TextStyle(
                                                                      fontSize:
                                                                          16),
                                                                ),
                                                              ],
                                                            )),
                                                      ],
                                                    ),
                                              Divider(),
                                              SizedBox(
                                                  width: width * 0.9,
                                                  child: Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .spaceBetween,
                                                    children: [
                                                      Text(
                                                        "Start Date : ",
                                                        style: TextStyle(
                                                            fontSize: 16),
                                                      ),
                                                      Text(
                                                        items['start_date'],
                                                        style: TextStyle(
                                                            fontSize: 16),
                                                      ),
                                                    ],
                                                  )),
                                              Divider(),
                                              SizedBox(
                                                  width: width * 0.9,
                                                  child: Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .spaceBetween,
                                                    children: [
                                                      Text(
                                                        "End Date : ",
                                                        style: TextStyle(
                                                            fontSize: 16),
                                                      ),
                                                      Text(
                                                        items['end_date'],
                                                        style: TextStyle(
                                                            fontSize: 16),
                                                      ),
                                                    ],
                                                  )),
                                              SizedBox(height: 3),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                )
                              : SizedBox();
                        },
                      ),
                    ),
        ],
      ),
    );
  }

// -------------API CALL----------------------//

  Future getRenewalDetails() async {
    setState(() {
      pageLoader = true;
    });
    var url = "${BASE_URL}order-renewals";
    var body = {
      "order_id": widget.orderId,
    };

    var response = await APIHelper.apiPostRequest(url, body);

    var result = jsonDecode(response);
    if (result['ErrorCode'] == 0) {
      setState(() {
        orderRenewalList.addAll(result['Response']['order_renewals']);
      });
      setState(() {
        pageLoader = false;
      });
    } else {
      showToast(result['ErrorMessage']);
      setState(() {
        pageLoader = false;
      });
    }
    setState(() {
      pageLoader = false;
    });
  }
}
