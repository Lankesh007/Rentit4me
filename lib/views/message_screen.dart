// ignore_for_file: deprecated_member_use

import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:intl/intl.dart';
import 'dart:convert';
import 'package:rentit4me_new/network/api.dart';
import 'package:http/http.dart' as http;
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:rentit4me_new/themes/constant.dart';
import 'package:rentit4me_new/views/alllisting_screen.dart';
import 'package:rentit4me_new/views/offers_view.dart';
import 'package:rentit4me_new/views/order_view.dart';
import 'package:rentit4me_new/views/trusted_badge_payment_details.dart';
import 'package:rentit4me_new/views/upgrade_membership_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MessageScreen extends StatefulWidget {
  const MessageScreen({Key key}) : super(key: key);

  @override
  State<MessageScreen> createState() => _MessageScreenState();
}

class _MessageScreenState extends State<MessageScreen> {
  bool _loading = false;
  List<dynamic> messageslist = [];
  String searchvalue = "Search for Notification";
  String startdate = "From Date";
  String enddate = "To Date";

  @override
  void initState() {
    super.initState();
    _messageslist();
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      resizeToAvoidBottomInset: false,
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
            const Text("Notifications", style: TextStyle(color: kPrimaryColor)),
        centerTitle: true,
      ),
      body: ModalProgressHUD(
        inAsyncCall: _loading,
        color: kPrimaryColor,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
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
                                borderSide: const BorderSide(
                                    color: Colors.deepOrangeAccent)),
                            enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: const BorderSide(
                                  color: Colors.deepOrangeAccent,
                                )),
                            contentPadding: const EdgeInsets.only(left: 5),
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
                              //Text("From Date", style: TextStyle(color: kPrimaryColor, fontSize: 14, fontWeight: FontWeight.w500)),
                              //SizedBox(height: 10),
                              Container(
                                  width: size.width * 0.42,
                                  decoration: BoxDecoration(
                                      border: Border.all(
                                          width: 1,
                                          color: Colors.deepOrangeAccent),
                                      borderRadius: BorderRadius.all(
                                          Radius.circular(12))),
                                  child: Padding(
                                    padding: const EdgeInsets.only(left: 10.0),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(startdate,
                                            style:
                                                TextStyle(color: Colors.grey)),
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
                              //Text("To Date", style: TextStyle(color: kPrimaryColor, fontSize: 14, fontWeight: FontWeight.w500)),
                              //SizedBox(height: 10),
                              Container(
                                  width: size.width * 0.42,
                                  decoration: BoxDecoration(
                                      border: Border.all(
                                          width: 1,
                                          color: Colors.deepOrangeAccent),
                                      borderRadius: BorderRadius.all(
                                          Radius.circular(12))),
                                  child: Padding(
                                    padding: const EdgeInsets.only(left: 10.0),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(enddate,
                                            style:
                                                TextStyle(color: Colors.grey)),
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
                          if (searchvalue == "Search for Notification" &&
                              startdate == "From Date") {
                            showToast(
                                "Please enter your search or select date");
                          } else {
                            if (searchvalue == "Search for Notification" ||
                                searchvalue.isEmpty) {
                              _messageslistByDate();
                            } else {
                              _messageslistBySearch();
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
              messageslist.isEmpty
                  ? Column(
                      children: const [
                        SizedBox(
                          height: 10,
                        ),
                        Text("No records found !!"),
                      ],
                    )
                  : Expanded(
                      child: ListView.separated(
                      itemCount: messageslist.length,
                      padding: EdgeInsets.zero,
                      shrinkWrap: true,
                      separatorBuilder: (BuildContext context, int index) =>
                          const Divider(),
                      itemBuilder: (BuildContext context, int index) {
                        return InkWell(
                          onTap: () {
                            messageslist[index]['app_url'] == null ||
                                    messageslist[index]['app_url'] == "" ||
                                    messageslist[index]['app_url'] == "null"
                                ? ""
                                : messageslist[index]['app_url'] ==
                                        "offers-made"
                                    ? Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: ((context) =>
                                                OffersViewScreen())))
                                    : messageslist[index]['app_url'] ==
                                            "orders-made"
                                        ? Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                                builder: ((context) =>
                                                    OrderViewScreen())))
                                        : messageslist[index]['app_url'] ==
                                                "offers-recieved"
                                            ? Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                    builder: ((context) =>
                                                        OffersViewScreen())))
                                            : messageslist[index]['app_url'] ==
                                                    "listings"
                                                ? Navigator.push(
                                                    context,
                                                    MaterialPageRoute(
                                                        builder: ((context) =>
                                                            AlllistingScreen())))
                                                : messageslist[index]['app_url'] ==
                                                        "membership/get"
                                                    ? Navigator.push(
                                                        context,
                                                        MaterialPageRoute(
                                                            builder: ((context) =>
                                                                UpgradeMemberShip())))
                                                    : messageslist[index]
                                                                ['app_url'] ==
                                                            "my-orders"
                                                        ? Navigator.push(
                                                            context,
                                                            MaterialPageRoute(
                                                                builder: ((context) => OrderViewScreen())))
                                                        : messageslist[index]['app_url'] == "trusted-badge-payment"
                                                            ? Navigator.push(context, MaterialPageRoute(builder: ((context) => TrustedBadgePaymentDetails())))
                                                            : "";
                          },
                          child: Card(
                            elevation: 4.0,
                            child: Padding(
                              padding: EdgeInsets.all(8.0),
                              child: Column(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text("Type",
                                                  style: TextStyle(
                                                      color: Colors.black,
                                                      fontWeight:
                                                          FontWeight.w500)),
                                              SizedBox(height: 5.0),
                                              Text(
                                                  messageslist[index]['type']
                                                      .toString(),
                                                  style: TextStyle(
                                                      color: Colors.black))
                                            ],
                                          ),
                                          Column(
                                            children: [
                                              Text("Created At",
                                                  style: TextStyle(
                                                      color: Colors.black,
                                                      fontWeight:
                                                          FontWeight.w500)),
                                              SizedBox(height: 5.0),
                                              Text(
                                                  messageslist[index]
                                                          ['created_at']
                                                      .toString()
                                                      .split("T")[0]
                                                      .toString(),
                                                  style: TextStyle(
                                                      color: Colors.black))
                                            ],
                                          ),
                                        ]),
                                    const SizedBox(height: 10.0),
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      children: [
                                        const SizedBox(height: 5.0),
                                        Html(
                                            data: messageslist[index]['message']
                                                .toString()),
                                        Text(
                                            messageslist[index]['app_url'] ??
                                                "",
                                            style: TextStyle(
                                                color: Colors.blue[800]))
                                      ],
                                    )
                                  ]),
                            ),
                          ),
                        );
                      },
                    ))
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _messageslist() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _loading = true;
    });

    var response = await http.get(Uri.parse(BASE_URL + messagesurl), headers: {
      "Accept": "application/json",
      'Content-Type': 'application/json',
      'Authorization': 'Bearer ${prefs.getString("token")}',
    });
    if (response.statusCode == 200) {
      if (jsonDecode(response.body)['ErrorCode'].toString() == "0") {
        setState(() {
          messageslist
              .addAll(jsonDecode(response.body)['Response']['Data']['data']);
          _loading = false;
        });
      } else {
        setState(() {
          _loading = false;
        });
      }
    } else {
      setState(() {
        _loading = false;
      });
      print(response.body);
      throw Exception('Failed to get data due to ${response.body}');
    }
  }

  Future _messageslistByDate() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      messageslist.clear();
      _loading = true;
    });
    // final body = {
    //   // "user_id": prefs.getString('userid'),
    //   "from_date": startdate.toString(),
    //   "to_date": enddate.toString(),
    // };
    print("$BASE_URL$messagesurl?from_date=$startdate&end_date=$enddate");
    var response = await http.get(Uri.parse("$BASE_URL$messagesurl?from_date=$startdate&end_date=$enddate"),
        // body: jsonEncode(body),
        headers: {
          "Accept": "application/json",
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${prefs.getString("token")}',
        });

    var result = jsonDecode(response.body);
    log("--->$result");
    if (response.statusCode == 200) {
      if (jsonDecode(response.body)['ErrorCode'].toString() == "0") {
        setState(() {
          messageslist.clear();
          messageslist
              .addAll(jsonDecode(response.body)['Response']['Data']['data']);
          _loading = false;
        });
      } else {
        setState(() {
          _loading = false;
        });
      }
    } else {
      setState(() {
        _loading = false;
      });
      print(response.body);
      throw Exception('Failed to get data due to ${response.body}');
    }
  }

  Future<void> _messageslistBySearch() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      messageslist.clear();
      _loading = true;
    });
    // final body = {
    //   "user_id": prefs.getString('userid'),
    //   "search": searchvalue,
    // };
    var response = await http.get(Uri.parse("$BASE_URL$messagesurl?search=$searchvalue"),
        // body: jsonEncode(body),
        headers: {
          "Accept": "application/json",
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${prefs.getString("token")}',
        });
    if (response.statusCode == 200) {
      if (jsonDecode(response.body)['ErrorCode'].toString() == "0") {
        setState(() {
          messageslist
              .addAll(jsonDecode(response.body)['Response']['Data']['data']);
          _loading = false;
        });
      } else {
        setState(() {
          _loading = false;
        });
      }
    } else {
      setState(() {
        _loading = false;
      });
      print(response.body);
      throw Exception('Failed to get data due to ${response.body}');
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
}
