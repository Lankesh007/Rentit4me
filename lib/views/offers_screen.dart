// ignore_for_file: must_be_immutable, no_logic_in_create_state

import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:rentit4me_new/animations/animations.dart';
import 'package:rentit4me_new/network/api.dart';
import 'package:rentit4me_new/themes/constant.dart';
import 'package:rentit4me_new/utils/dialog_utils.dart';
import 'package:rentit4me_new/views/home_screen.dart';
import 'package:rentit4me_new/views/offer_made_product_detail_screen.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class OffersScreen extends StatefulWidget {
  String productid;
  OffersScreen({Key key, this.productid}) : super(key: key);

  @override
  State<OffersScreen> createState() => _OffersScreenState(productid);
}

class _OffersScreenState extends State<OffersScreen> {
  String productid;

  _OffersScreenState(this.productid);

  String searchvalue = "Search for product";
  List<dynamic> offerrecievedlist = [];

  List<String> responselist = ['Accept', 'Reject', 'Final Amount'];
  String responsevalue;
  String response;

  bool _loading = false;
  bool newamtcheck = false;

  String startdate = "From Date";
  String enddate = "To Date";

  @override
  void initState() {
    super.initState();
    _offerrecievedlist();
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
        title: const Text("Offers", style: TextStyle(color: kPrimaryColor)),
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
                      const SizedBox(height: 10),
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
                                      borderRadius: const BorderRadius.all(
                                          Radius.circular(12))),
                                  child: Padding(
                                    padding: const EdgeInsets.only(left: 10.0),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(startdate,
                                            style: const TextStyle(
                                                color: Colors.grey)),
                                        IconButton(
                                            onPressed: () {
                                              _selectStartDate(context);
                                            },
                                            icon: const Icon(
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
                                      borderRadius: const BorderRadius.all(
                                          Radius.circular(12))),
                                  child: Padding(
                                    padding: const EdgeInsets.only(left: 10.0),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(enddate,
                                            style: const TextStyle(
                                                color: Colors.grey)),
                                        IconButton(
                                            onPressed: () {
                                              _selectEndtDate(context);
                                            },
                                            icon: const Icon(
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
                          if (searchvalue == "Search for product" &&
                              startdate == "From Date") {
                            showToast(
                                'Please enter your search or select date');
                          } else {
                            if (searchvalue == "Search for product" ||
                                searchvalue.trim().isEmpty) {
                              _offerrecievedlistByDate();
                            } else {
                              _offerrecievedlistBySearch();
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
              Expanded(
                  child: ListView.separated(
                itemCount: offerrecievedlist.length,
                padding: EdgeInsets.zero,
                shrinkWrap: true,
                separatorBuilder: (BuildContext context, int index) =>
                    const Divider(),
                itemBuilder: (BuildContext context, int index) {
                  return Card(
                    elevation: 4.0,
                    child: InkWell(
                      onTap: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) =>
                                    OfferMadeProductDetailScreen(
                                        postadid: offerrecievedlist[index]
                                                ['offer_status']
                                            .toString(),
                                        offerid: offerrecievedlist[index]['id']
                                            .toString())));
                      },
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            color: Colors.grey,
                            height: 30,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Container(
                                  margin: const EdgeInsets.symmetric(
                                      horizontal: 10),
                                  child: Text(
                                      "Ad Id: ${offerrecievedlist[index]["ad_id"]} "),
                                ),
                                Container(
                                  margin: const EdgeInsets.symmetric(
                                      horizontal: 10),
                                  child: Text(
                                      "Price: ${offerrecievedlist[index]["product_price"]} "),
                                )
                              ],
                            ),
                          ),
                          SizedBox(
                            height: 5,
                          ),
                          Container(
                            margin: const EdgeInsets.symmetric(horizontal: 10),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                    "Renter Amount: ${offerrecievedlist[index]["renter_amount"]} "),
                                Text(
                                    "Security: ${offerrecievedlist[index]["total_security"]} ")
                              ],
                            ),
                          ),
                          SizedBox(
                            height: 5,
                          ),
                          Container(
                            margin: const EdgeInsets.symmetric(horizontal: 10),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                    "Offer Price: ${offerrecievedlist[index]["final_product_selling_amount"]} "),
                                Text(
                                    "Total Amount: ${offerrecievedlist[index]["final_amount"]} "),
                              ],
                            ),
                          ),
                          SizedBox(
                            height: 5,
                          ),
                          Container(
                            alignment: Alignment.centerLeft,
                            height: 30,
                            color: Appcolors.secondaryColor,
                            child: TextButton(
                                onPressed: () {},
                                child: Text(
                                  "Product Name : ${offerrecievedlist[index]['title']}",
                                  style: TextStyle(color: Appcolors.whiteColor),
                                )),
                          ),
                          Container(
                            margin: const EdgeInsets.symmetric(horizontal: 10),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                offerrecievedlist[index]["offer_status"]
                                            .toString() ==
                                        "3"
                                    ? InkWell(
                                        onTap: () {
                                          showGeneralDialog(
                                            context: context,
                                            barrierDismissible: false,
                                            transitionBuilder: (context,
                                                _animation,
                                                _secondaryAnimation,
                                                _child) {
                                              return Animations.fromTop(
                                                  _animation,
                                                  _secondaryAnimation,
                                                  _child);
                                            },
                                            pageBuilder: (_animation,
                                                _secondaryAnimation, _child) {
                                              return StatefulBuilder(
                                                  builder: (context, setState) {
                                                return AlertDialog(
                                                  title: const Text("Response",
                                                      style: TextStyle(
                                                          color: Colors
                                                              .deepOrangeAccent)),
                                                  content: Container(
                                                    child:
                                                        SingleChildScrollView(
                                                            child: Column(
                                                                children: [
                                                          DropdownButtonHideUnderline(
                                                            child:
                                                                DropdownButton<
                                                                    String>(
                                                              hint: const Text(
                                                                  "Select",
                                                                  style: TextStyle(
                                                                      color: Colors
                                                                          .black,
                                                                      fontSize:
                                                                          18)),
                                                              value: response,
                                                              elevation: 16,
                                                              isExpanded: true,
                                                              style: TextStyle(
                                                                  color: Colors
                                                                      .grey
                                                                      .shade700,
                                                                  fontSize: 16),
                                                              onChanged: (String
                                                                  data) {
                                                                setState(() {
                                                                  if (data.toString() ==
                                                                      "Reject") {
                                                                    responsevalue =
                                                                        "2";
                                                                    response = data
                                                                        .toString();
                                                                    newamtcheck =
                                                                        false;
                                                                  } else if (data
                                                                          .toString() ==
                                                                      "Accept") {
                                                                    responsevalue =
                                                                        "1";
                                                                    response = data
                                                                        .toString();
                                                                    newamtcheck =
                                                                        false;
                                                                  } else {
                                                                    responsevalue =
                                                                        "3";
                                                                    response = data
                                                                        .toString();
                                                                    newamtcheck =
                                                                        true;
                                                                  }
                                                                });
                                                              },
                                                              items: responselist.map<
                                                                  DropdownMenuItem<
                                                                      String>>((String
                                                                  value) {
                                                                return DropdownMenuItem<
                                                                    String>(
                                                                  value: value,
                                                                  child: Text(
                                                                      value),
                                                                );
                                                              }).toList(),
                                                            ),
                                                          ),
                                                          const SizedBox(
                                                              height: 2),
                                                          const Divider(
                                                              height: 1,
                                                              color:
                                                                  Colors.grey,
                                                              thickness: 1),
                                                          const SizedBox(
                                                              height: 8),
                                                          newamtcheck
                                                              ? const Padding(
                                                                  padding: EdgeInsets.only(
                                                                      top: 5.0,
                                                                      bottom:
                                                                          5.0),
                                                                  child:
                                                                      TextField(
                                                                    keyboardType:
                                                                        TextInputType
                                                                            .number,
                                                                    decoration:
                                                                        InputDecoration(
                                                                      border:
                                                                          OutlineInputBorder(),
                                                                      labelText:
                                                                          'Your Amount',
                                                                      hintText:
                                                                          'Your Amount',
                                                                    ),
                                                                  ),
                                                                )
                                                              : const SizedBox(),
                                                          const SizedBox(
                                                              height: 15),
                                                          InkWell(
                                                            onTap: () {
                                                              if (responsevalue ==
                                                                      null ||
                                                                  responsevalue ==
                                                                      "" ||
                                                                  responsevalue ==
                                                                      "null") {
                                                                showToast(
                                                                    "Please select your response");
                                                              } else {
                                                                print(offerrecievedlist[
                                                                            index]
                                                                        [
                                                                        'user_id']
                                                                    .toString());
                                                                print(offerrecievedlist[
                                                                            index]
                                                                        [
                                                                        'post_ad_id']
                                                                    .toString());
                                                                print(
                                                                    responsevalue);
                                                                _offeraction(
                                                                    offerrecievedlist[index]
                                                                            [
                                                                            'post_ad_id']
                                                                        .toString(),
                                                                    responsevalue,
                                                                    offerrecievedlist[index]
                                                                            [
                                                                            'user_id']
                                                                        .toString());
                                                              }
                                                            },
                                                            child: Container(
                                                              height: 45,
                                                              width: double
                                                                  .infinity,
                                                              alignment:
                                                                  Alignment
                                                                      .center,
                                                              decoration: const BoxDecoration(
                                                                  color: Colors
                                                                      .deepOrangeAccent,
                                                                  borderRadius:
                                                                      BorderRadius.all(
                                                                          Radius.circular(
                                                                              8.0))),
                                                              child: const Text(
                                                                  "Submit",
                                                                  style: TextStyle(
                                                                      color: Colors
                                                                          .white)),
                                                            ),
                                                          )
                                                        ])),
                                                  ),
                                                );
                                              });
                                            },
                                          );
                                        },
                                        child: Container(
                                            padding: const EdgeInsets.all(4.0),
                                            decoration: BoxDecoration(
                                                borderRadius:
                                                    const BorderRadius.all(
                                                        Radius.circular(4.0)),
                                                border: Border.all(
                                                    color: Colors.blue)),
                                            child: const Text("Respond",
                                                style: TextStyle(
                                                    color: Colors.blue))))
                                    : _getstatus(offerrecievedlist[index]
                                            ["offer_status"]
                                        .toString())
                              ],
                            ),
                          ),
                          SizedBox(
                            height: 5,
                          ),
                          Container(
                            margin: const EdgeInsets.symmetric(horizontal: 10),
                            alignment: Alignment.centerLeft,
                            child: Text(
                              "Start Date : ${offerrecievedlist[index]['start_date']}",
                              style: TextStyle(color: Colors.grey),
                            ),
                          ),
                          SizedBox(
                            height: 5,
                          ),
                          Container(
                            margin: const EdgeInsets.symmetric(horizontal: 10),
                            alignment: Alignment.centerLeft,
                            child: Text(
                              "End Date : ${offerrecievedlist[index]['end_date']}",
                              style: TextStyle(color: Colors.grey),
                            ),
                          ),
                          const SizedBox(height: 5.0),
                          Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 10.0),
                            child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                      "Qty: ${offerrecievedlist[index]['quantity']}"),
                                  const SizedBox(width: 2.0),
                                  Text(
                                      "Duration: ${offerrecievedlist[index]['period']}"),
                                  const SizedBox(width: 2.0),
                                  Text(
                                      "Rent type: ${offerrecievedlist[index]['rent_type_name']}"),
                                ]),
                          ),
                          const SizedBox(height: 5.0),
                        ],
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

  Widget _getstatus(String statusvalue) {
    if (statusvalue == "3") {
      return const Text("Pending");
    } else if (statusvalue == "13") {
      return const Text("Completed");
    } else if (statusvalue == "2") {
      return const Text("Rejected");
    } else {
      return const Text("Accepted");
    }
  }

  Future<void> _offerrecievedlist() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _loading = true;
    });

    final body = {
      "postad_id": widget.productid,
    };
    log("bidy---->$body");
    var response = await http.post(Uri.parse(BASE_URL + viewoffersUrl),
        body: jsonEncode(body),
        headers: {
          "Accept": "application/json",
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${prefs.getString("token")}',
        });
    setState(() {
      _loading = false;
    });
    if (response.statusCode == 200) {
      if (jsonDecode(response.body)['ErrorCode'].toString() == "0") {
        if (jsonDecode(response.body)['Response'] == null) {
          showToast(jsonDecode(response.body)['ErrorMessage'].toString());
        } else {
          setState(() {
            offerrecievedlist
                .addAll(jsonDecode(response.body)['Response']['data']);
          });
        }
      } else {
        showToast(jsonDecode(response.body)['ErrorMessage'].toString());
      }
    } else {
      setState(() {
        _loading = false;
      });
      print(response.body);
      throw Exception('Failed to get data due to ${response.body}');
    }
  }

  Future<void> _offerrecievedlistByDate() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    setState(() {
      offerrecievedlist.clear();
      _loading = true;
    });
    final body = {
      "postad_id": productid,
      "from_date": startdate,
      "to_date": enddate
    };
    var response = await http.post(Uri.parse(BASE_URL + viewoffersUrl),
        body: jsonEncode(body),
        headers: {
          "Accept": "application/json",
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${prefs.getString("token")}',
        });
    print(response.body);
    if (response.statusCode == 200) {
      if (jsonDecode(response.body)['Response']['data'].length == 0) {
        setState(() {
          _loading = false;
        });
        showToast("Data not found");
      } else {
        setState(() {
          _loading = false;
          offerrecievedlist
              .addAll(jsonDecode(response.body)['Response']['data']);
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

  Future<void> _offerrecievedlistBySearch() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      offerrecievedlist.clear();
      _loading = true;
    });
    final body = {
      "postad_id": productid,
      "search": searchvalue,
    };
    var response = await http.post(Uri.parse(BASE_URL + viewoffersUrl),
        body: jsonEncode(body),
        headers: {
          "Accept": "application/json",
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${prefs.getString("token")}',
        });
    if (response.statusCode == 200) {
      if (jsonDecode(response.body)['ErrorCode'].toString() == "0") {
        setState(() {
          offerrecievedlist
              .addAll(jsonDecode(response.body)['Response']['data']);
          _loading = false;
        });
      } else {
        setState(() {
          _loading = false;
        });
        showToast(jsonDecode(response.body)['ErrorMessage'].toString());
      }
    } else {
      setState(() {
        _loading = false;
      });
      print(response.body);
      throw Exception('Failed to get data due to ${response.body}');
    }
  }

  Future<void> _offeraction(
      String postid, String offerstatus, String userid) async {
    print(jsonEncode({
      "post_ad_id": postid,
      "user_id": userid,
      "offer_status": offerstatus
    }));
    final body = {
      "post_ad_id": postid,
      "user_id": userid,
      "offer_status": offerstatus
    };
    var response = await http.post(Uri.parse(BASE_URL + offeraction),
        body: jsonEncode(body),
        headers: {
          "Accept": "application/json",
          'Content-Type': 'application/json'
        });
    print(response.body);
    if (response.statusCode == 200) {
      if (jsonDecode(response.body)['ErrorCode'].toString() == "0") {
        showToast(jsonDecode(response.body)['Response'].toString());
        Navigator.of(context, rootNavigator: true).pop('dialog');
        Navigator.pushReplacement(
            context,
            MaterialPageRoute(
                builder: (BuildContext context) => const HomeScreen()));
        //_offerrecievedlist();
      } else {
        showToast(jsonDecode(response.body)['ErrorMessage'].toString());
      }
    } else {
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
