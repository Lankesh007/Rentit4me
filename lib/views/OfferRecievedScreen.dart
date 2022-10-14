// ignore_for_file: prefer_const_constructors, use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:rentit4me_new/animations/animations.dart';
import 'package:rentit4me_new/network/api.dart';
import 'package:rentit4me_new/themes/constant.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:rentit4me_new/views/dashboard.dart';
import 'package:rentit4me_new/views/home_screen.dart';
import 'package:rentit4me_new/views/offer_made_product_detail_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

class OfferRecievedScreen extends StatefulWidget {
  const OfferRecievedScreen({Key key}) : super(key: key);

  @override
  State<OfferRecievedScreen> createState() => _OfferRecievedScreenState();
}

class _OfferRecievedScreenState extends State<OfferRecievedScreen> {
  String searchvalue = "Search for product";
  TextEditingController rentee_amount = TextEditingController();
  List<dynamic> offerrecievedlist = [];

  List<String> responselist = [
    'Accept',
    'Reject',
    'Final Product Selling Amount'
  ];
  String responsevalue;
  String response;

  bool _loading = false;
  bool newamtcheck = false;

  String startdate = "From Date";
  String enddate = "To Date";

  double conPer = 0;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _offerrecievedlist();
  }

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
      //   title: const Text("Offer Received",
      //       style: TextStyle(color: kPrimaryColor)),
      //   centerTitle: true,
      // ),
      body: ModalProgressHUD(
        inAsyncCall: _loading,
        color: kPrimaryColor,
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
                                searchvalue.trim().length == 0 ||
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
                  return InkWell(
                    onTap: () {
                      print(offerrecievedlist[index]);
                      double total = double.parse(offerrecievedlist[index]
                                  ["total_security"]
                              .toString()) +
                          double.parse(offerrecievedlist[index]["total_rent"]
                              .toString());

                      double taxValue = (conPer / 100) * total;

                      showDialog(
                          context: context,
                          builder: (_) => AlertDialog(
                              title: const Text('Detail Information'),
                              content: SingleChildScrollView(
                                  child: Column(children: [
                                Card(
                                  color: Colors.grey[100],
                                  child: ListTile(
                                    title: const Text("Rentee"),
                                    subtitle: Text(offerrecievedlist[index]
                                            ['name']
                                        .toString()),
                                  ),
                                ),
                                Card(
                                  color: Colors.grey[100],
                                  child: ListTile(
                                    title: const Text("Product Name"),
                                    subtitle: Text(offerrecievedlist[index]
                                            ["title"]
                                        .toString()),
                                  ),
                                ),
                                Card(
                                  color: Colors.grey[100],
                                  child: ListTile(
                                    title: const Text("Product Quantity"),
                                    subtitle: Text(offerrecievedlist[index]
                                            ["quantity"]
                                        .toString()),
                                  ),
                                ),
                                Card(
                                  color: Colors.grey[100],
                                  child: ListTile(
                                    title: const Text("Rent Type"),
                                    subtitle: Text(offerrecievedlist[index]
                                            ["rent_type_name"]
                                        .toString()),
                                  ),
                                ),
                                Card(
                                  color: Colors.grey[100],
                                  child: ListTile(
                                    title: const Text("Duration"),
                                    subtitle: Text(offerrecievedlist[index]
                                            ["period"]
                                        .toString()),
                                  ),
                                ),
                                Card(
                                  color: Colors.grey[100],
                                  child: ListTile(
                                    title: const Text("Product Price(INR)"),
                                    subtitle: Text(offerrecievedlist[index]
                                            ["product_price"]
                                        .toString()),
                                  ),
                                ),
                                Card(
                                  color: Colors.grey[100],
                                  child: ListTile(
                                    title: const Text("Offer Amount(INR)"),
                                    subtitle: Text(offerrecievedlist[index]
                                            ["renter_amount"]
                                        .toString()),
                                  ),
                                ),
                                Card(
                                  color: Colors.grey[100],
                                  child: ListTile(
                                    title: const Text("Total Rent(INR)"),
                                    subtitle: Text(offerrecievedlist[index]
                                            ["total_rent"]
                                        .toString()),
                                  ),
                                ),
                                Card(
                                  color: Colors.grey[100],
                                  child: ListTile(
                                    title: const Text("Total Security(INR)"),
                                    subtitle: Text(offerrecievedlist[index]
                                            ["total_security"]
                                        .toString()),
                                  ),
                                ),
                                Card(
                                    color: Colors.grey[100],
                                    child: ListTile(
                                        title: Text("Convenience Charges (" +
                                            conPer
                                                .toStringAsFixed(0)
                                                .toString() +
                                            "%)"),
                                        subtitle: Text(taxValue.toString()))),
                                Card(
                                    color: Colors.grey[100],
                                    child: ListTile(
                                        title: const Text("Final Amount(INR)"),
                                        subtitle: Text((double.parse(
                                                    offerrecievedlist[index]
                                                            ["final_amount"]
                                                        .toString()) -
                                                taxValue)
                                            .toString())))
                              ]))));
                    },
                    child: Card(
                      elevation: 4.0,
                      child: Padding(
                        padding: const EdgeInsets.only(top: 8.0, bottom: 8.0),
                        child: Column(
                            // mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.only(left: 10.0),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text("Rentee :",
                                            style: const TextStyle(
                                                color: Colors.black,
                                                fontSize: 14,
                                                fontWeight: FontWeight.w500)),
                                        Text(
                                            "${offerrecievedlist[index]['name']}",
                                            style: const TextStyle(
                                                color: Colors.black,
                                                fontSize: 16,
                                                fontWeight: FontWeight.w600)),
                                      ],
                                    ),
                                  ),
                                  InkWell(
                                    onTap: () {
                                      Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) =>
                                                  OfferMadeProductDetailScreen(
                                                      postadid:
                                                          offerrecievedlist[
                                                                      index]
                                                                  ['post_ad_id']
                                                              .toString(),
                                                      offerid: offerrecievedlist[
                                                                  index][
                                                              'offer_request_id']
                                                          .toString())));
                                    },
                                    child: Padding(
                                      padding: const EdgeInsets.only(
                                          left: 10.0, right: 10),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text("Product Name :",
                                              style: const TextStyle(
                                                  color: Colors.black,
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.w500)),
                                          Text(
                                              "${offerrecievedlist[index]['title']}",
                                              style: TextStyle(
                                                  color: Colors.blue[800],
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.w600)),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              Divider(
                                thickness: 0.9,
                                height: 20,
                              ),
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 10.0),
                                child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Row(
                                        children: [
                                          Text("Qty: "),
                                          Text(
                                            "${offerrecievedlist[index]['quantity']}",
                                            style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 16),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(width: 2.0),
                                      Row(
                                        children: [
                                          Text("Duration: "),
                                          Text(
                                            "${offerrecievedlist[index]['period']}",
                                            style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 16),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(width: 2.0),
                                      Row(
                                        children: [
                                          Text("Rent Type: "),
                                          Text(
                                            "${offerrecievedlist[index]['rent_type_name']}"
                                                .toUpperCase(),
                                            style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 16),
                                          ),
                                        ],
                                      ),
                                    ]),
                              ),
                              Divider(
                                thickness: 0.9,
                                height: 20,
                              ),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Row(
                                      children: [
                                        Text(
                                          "Status: ",
                                        ),
                                        offerrecievedlist[index]['offer_status'] ==
                                                3
                                            ? Text(
                                                "Pending",
                                                style: TextStyle(
                                                    fontWeight:
                                                        FontWeight.bold),
                                              )
                                            : offerrecievedlist[index]
                                                        ['offer_status'] ==
                                                    2
                                                ? Text("Rejected",
                                                    style: TextStyle(
                                                        fontWeight:
                                                            FontWeight.bold))
                                                : offerrecievedlist[index]
                                                            ['offer_status'] ==
                                                        1
                                                    ? Text("Accepted",
                                                        style: TextStyle(
                                                            fontWeight: FontWeight
                                                                .bold))
                                                    : offerrecievedlist[index]['offer_status'] ==
                                                            12
                                                        ? Text(
                                                            "Final Amount Offered",
                                                            style: TextStyle(
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold))
                                                        : SizedBox(),
                                      ],
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child:
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
                                                        _secondaryAnimation,
                                                        _child) {
                                                      return StatefulBuilder(
                                                          builder: (context,
                                                              setState) {
                                                        return AlertDialog(
                                                          title: const Text(
                                                              "Response",
                                                              style: TextStyle(
                                                                  color: Colors
                                                                      .deepOrangeAccent)),
                                                          content: Container(
                                                            child:
                                                                SingleChildScrollView(
                                                                    child: Column(
                                                                        children: [
                                                                  DropdownButtonHideUnderline(
                                                                    child: DropdownButton<
                                                                        String>(
                                                                      hint: const Text(
                                                                          "Select",
                                                                          style: TextStyle(
                                                                              color: Colors.black,
                                                                              fontSize: 18)),
                                                                      value:
                                                                          response,
                                                                      elevation:
                                                                          16,
                                                                      isExpanded:
                                                                          true,
                                                                      style: TextStyle(
                                                                          color: Colors
                                                                              .grey
                                                                              .shade700,
                                                                          fontSize:
                                                                              16),
                                                                      onChanged:
                                                                          (String
                                                                              data) {
                                                                        setState(
                                                                            () {
                                                                          if (data.toString() ==
                                                                              "Reject") {
                                                                            responsevalue =
                                                                                "2";
                                                                            response =
                                                                                data.toString();
                                                                            newamtcheck =
                                                                                false;
                                                                          } else if (data.toString() ==
                                                                              "Accept") {
                                                                            responsevalue =
                                                                                "1";
                                                                            response =
                                                                                data.toString();
                                                                            newamtcheck =
                                                                                false;
                                                                          } else {
                                                                            responsevalue =
                                                                                "12";
                                                                            response =
                                                                                data.toString();
                                                                            newamtcheck =
                                                                                true;
                                                                          }
                                                                        });
                                                                      },
                                                                      items: offerrecievedlist[index]["negotiate"].toString() ==
                                                                              "1"
                                                                          ? [
                                                                              'Accept',
                                                                              'Reject',
                                                                              'Final Product Selling Amount'
                                                                            ].map<DropdownMenuItem<String>>((String
                                                                              value) {
                                                                              return DropdownMenuItem<String>(
                                                                                value: value,
                                                                                child: Text(value),
                                                                              );
                                                                            }).toList()
                                                                          : [
                                                                              'Accept',
                                                                              'Reject',
                                                                            ].map<DropdownMenuItem<String>>((String
                                                                              value) {
                                                                              return DropdownMenuItem<String>(
                                                                                value: value,
                                                                                child: Text(value),
                                                                              );
                                                                            }).toList(),
                                                                    ),
                                                                  ),
                                                                  const SizedBox(
                                                                      height:
                                                                          2),
                                                                  const Divider(
                                                                      height: 1,
                                                                      color: Colors
                                                                          .grey,
                                                                      thickness:
                                                                          1),
                                                                  const SizedBox(
                                                                      height:
                                                                          8),
                                                                  newamtcheck
                                                                      ? Padding(
                                                                          padding: EdgeInsets.only(
                                                                              top: 5.0,
                                                                              bottom: 5.0),
                                                                          child:
                                                                              TextField(
                                                                            keyboardType:
                                                                                TextInputType.number,
                                                                            controller:
                                                                                rentee_amount,
                                                                            decoration:
                                                                                InputDecoration(
                                                                              border: OutlineInputBorder(),
                                                                              labelText: 'Your Amount',
                                                                              hintText: 'Your Amount',
                                                                            ),
                                                                          ),
                                                                        )
                                                                      : const SizedBox(),
                                                                  const SizedBox(
                                                                      height:
                                                                          15),
                                                                  InkWell(
                                                                    onTap: () {
                                                                      if (responsevalue == null ||
                                                                          responsevalue ==
                                                                              "" ||
                                                                          responsevalue ==
                                                                              "null") {
                                                                        showToast(
                                                                            "Please select your response");
                                                                      } else {
                                                                        _offeraction(
                                                                            offerrecievedlist[index]['post_ad_id'].toString(),
                                                                            responsevalue,
                                                                            offerrecievedlist[index]['user_id'].toString(),
                                                                            rentee_amount,
                                                                            offerrecievedlist[index]['offer_request_id'].toString());
                                                                      }
                                                                    },
                                                                    child:
                                                                        Container(
                                                                      height:
                                                                          45,
                                                                      width: double
                                                                          .infinity,
                                                                      alignment:
                                                                          Alignment
                                                                              .center,
                                                                      decoration: const BoxDecoration(
                                                                          color: Colors
                                                                              .deepOrangeAccent,
                                                                          borderRadius:
                                                                              BorderRadius.all(Radius.circular(8.0))),
                                                                      child: const Text(
                                                                          "Submit",
                                                                          style:
                                                                              TextStyle(color: Colors.white)),
                                                                    ),
                                                                  )
                                                                ])),
                                                          ),
                                                        );
                                                      });
                                                    },
                                                    // builder: (context)=> StatefulBuilder(
                                                    //     builder: (context, setState){
                                                    //       return AlertDialog(
                                                    //         title: const Text("Response", style: TextStyle(color: Colors.deepOrangeAccent)),
                                                    //         content: Container(
                                                    //           child: SingleChildScrollView(
                                                    //               child: Column(
                                                    //                 children: [
                                                    //                   DropdownButtonHideUnderline(
                                                    //                      child: DropdownButton<String>(
                                                    //                      hint: const Text("Select", style: TextStyle(color: Colors.black, fontSize: 18)),
                                                    //                      value: response,
                                                    //                      elevation: 16,
                                                    //                      isExpanded: true,
                                                    //                      style: TextStyle(color: Colors.grey.shade700, fontSize: 16),
                                                    //                       onChanged: (String data) {
                                                    //                       setState(() {
                                                    //                         if(data.toString() == "Reject"){
                                                    //                           responsevalue = "2";
                                                    //                           response = data.toString();
                                                    //                         }
                                                    //                         else if(data.toString() == "Accept"){
                                                    //                           responsevalue = "1";
                                                    //                           response = data.toString();
                                                    //                         }
                                                    //                         else{
                                                    //                            newamtcheck = true;
                                                    //                         }
                                                    //                       });
                                                    //                     },
                                                    //                     items: responselist.map<DropdownMenuItem<String>>((String value) {
                                                    //                       return DropdownMenuItem<String>(
                                                    //                         value: value,
                                                    //                         child: Text(value),
                                                    //                       );
                                                    //                     }).toList(),
                                                    //                   ),
                                                    //                 ),
                                                    //                   const SizedBox(height: 2),
                                                    //                   const Divider(height: 1, color: Colors.grey, thickness: 1),
                                                    //                   const SizedBox(height: 5),
                                                    //                   newamtcheck ? const TextField(
                                                    //                     decoration: InputDecoration(
                                                    //                       border: OutlineInputBorder(),
                                                    //                       labelText: 'Your Amount',
                                                    //                       hintText: 'Your Amount',
                                                    //                     ),
                                                    //                   ) : const SizedBox(),
                                                    //                   const SizedBox(height: 15),
                                                    //                   InkWell(onTap:() {
                                                    //                    if(responsevalue == null || responsevalue == "" || responsevalue == "null"){
                                                    //                      showToast("Please select your response");
                                                    //                    }
                                                    //                    else{
                                                    //                      print(offerrecievedlist[index]['user_id'].toString());
                                                    //                      print(offerrecievedlist[index]['post_ad_id'].toString());
                                                    //                      print(responsevalue);
                                                    //                     _offeraction(offerrecievedlist[index]['post_ad_id'].toString(), responsevalue, offerrecievedlist[index]['user_id'].toString());
                                                    //                    }
                                                    //                   },
                                                    //                   child: Container(
                                                    //                     height: 45,
                                                    //                     width: double.infinity,
                                                    //                     alignment: Alignment.center,
                                                    //                     decoration: const BoxDecoration(
                                                    //                         color: Colors.deepOrangeAccent,
                                                    //                         borderRadius: BorderRadius.all(Radius.circular(8.0))
                                                    //                     ),
                                                    //                     child: const Text("Submit", style: TextStyle(color: Colors.white)),
                                                    //                   ),
                                                    //                 )
                                                    //               ])
                                                    //           ),
                                                    //         ),
                                                    //
                                                    //       );
                                                    //     }
                                                    // )
                                                  );
                                                },
                                                child: Container(
                                                    padding:
                                                        const EdgeInsets.all(
                                                            4.0),
                                                    decoration: BoxDecoration(
                                                        borderRadius:
                                                            const BorderRadius.all(
                                                                Radius.circular(
                                                                    4.0)),
                                                        border: Border.all(
                                                            color:
                                                                Colors.blue)),
                                                    child: const Text("Respond",
                                                        style:
                                                            TextStyle(color: Colors.blue))))
                                            : _getstatus(offerrecievedlist[index]["offer_status"].toString()),
                                  ),
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

  Widget _getstatus(String statusvalue) {
    if (statusvalue == "3") {
      return Row(
        children: [
          Text(
            "Pending",
            style: TextStyle(color: Colors.yellow[800]),
          ),
          SizedBox(
            width: 5,
          ),
          Image.asset(
            "assets/images/pending.png",
            scale: 3,
            color: Colors.yellow[800],
          ),
        ],
      );
    } else if (statusvalue == "13") {
      return Row(
        children: [
          Text(
            "Completed",
            style: TextStyle(color: Colors.green[800]),
          ),
          SizedBox(
            width: 5,
          ),
          Image.asset(
            "assets/images/accept.png",
            scale: 3,
          ),
        ],
      );
    } else if (statusvalue == "2") {
      return Row(
        children: [
          Text("Rejected", style: TextStyle(color: Colors.red[800])),
          SizedBox(
            width: 5,
          ),
          Image.asset(
            "assets/images/cross.png",
            scale: 3,
          ),
        ],
      );
    } else {
      return Row(
        children: [
          Text("Accepted", style: TextStyle(color: Colors.blue[800])),
          SizedBox(
            width: 5,
          ),
          Image.asset(
            "assets/images/check.png",
            scale: 3,
          ),
        ],
      );
    }
  }

  Future<void> _offerrecievedlist() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _loading = true;
    });
    final body = {
      "user_id": prefs.getString('userid'),
    };
    print(jsonEncode(body));
    print(BASE_URL + offerrecieve);
    var response = await http.post(Uri.parse(BASE_URL + offerrecieve),
        body: jsonEncode(body),
        headers: {
          "Accept": "application/json",
          'Content-Type': 'application/json'
        });

    setState(() {
      _loading = false;
    });

    // print(response.body);
    if (response.statusCode == 200) {
      if (jsonDecode(response.body)['ErrorCode'].toString() == "0") {
        if (jsonDecode(response.body)['Response'] == null) {
          showToast(jsonDecode(response.body)['ErrorMessage'].toString());
        } else {
          setState(() {
            offerrecievedlist
                .addAll(jsonDecode(response.body)['Response']['data']);
            conPer = double.parse(jsonDecode(response.body)['Response']
                    ['convenience_charges']['charge']
                .toString());
          });
          print(offerrecievedlist[0]);
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
      "user_id": prefs.getString('userid'),
      "from_date": startdate,
      "to_date": enddate
    };
    var response = await http.post(Uri.parse(BASE_URL + offerrecieve),
        body: jsonEncode(body),
        headers: {
          "Accept": "application/json",
          'Content-Type': 'application/json'
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
      "user_id": prefs.getString('userid'),
      "search": searchvalue,
    };
    var response = await http.post(Uri.parse(BASE_URL + offerrecieve),
        body: jsonEncode(body),
        headers: {
          "Accept": "application/json",
          'Content-Type': 'application/json'
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

  Future<void> _offeraction(String postid, String offerstatus, String userid,
      TextEditingController rentiee_amount, String offerrequestid) async {
    print(jsonEncode({
      "post_ad_id": postid,
      "user_id": userid,
      "offer_status": offerstatus,
      "rentee_amount": rentee_amount.text.toString(),
      "offer_request_id": offerrequestid.toString()
    }));
    final body = {
      "post_ad_id": postid,
      "user_id": userid,
      "offer_status": offerstatus,
      "rentee_amount": rentee_amount.text.toString(),
      "offer_request_id": offerrequestid.toString()
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
                builder: (BuildContext context) =>  Dashboard()));
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
    if (picked != null)
      setState(() {
        startdate = DateFormat('yyyy-MM-dd').format(picked);
      });
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
    if (picked != null)
      setState(() {
        enddate = DateFormat('yyyy-MM-dd').format(picked);
      });
  }

  _categoryDialogBox() {
    return showGeneralDialog(
      context: context,
      barrierLabel: '',
      barrierDismissible: true,
      transitionDuration: Duration(milliseconds: 300),
      transitionBuilder: (context, _animation, _secondaryAnimation, _child) {
        return Animations.grow(_animation, _secondaryAnimation, _child);
      },
      pageBuilder: (_animation, _secondaryAnimation, _child) {
        return _categoryDialog(context);
      },
    );
  }

  Widget _categoryDialog(context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
      elevation: 0,
      backgroundColor: Colors.transparent,
      child: _buildChild(context),
    );
  }

  _buildChild(BuildContext context) => Container(
        height: 250,
        decoration: const BoxDecoration(
            color: Colors.white,
            shape: BoxShape.rectangle,
            borderRadius: BorderRadius.all(Radius.circular(12))),
        child: Column(
          children: <Widget>[
            SizedBox(height: 10),
            Container(
                child: Scrollbar(
              thickness: 2,
              child: ListView.separated(
                padding: EdgeInsets.zero,
                shrinkWrap: true,
                primary: false,
                //controller: controller,
                separatorBuilder: (BuildContext context, int index) =>
                    Divider(),
                //itemCount: restlist.length,
                itemBuilder: (BuildContext context, int index) {
                  //return _catlist(context, index, restlist[index].name, restlist[index].items.length.toString());
                },
              ),
            ))
          ],
        ),
      );
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
    } else if (renttypevalue.toLowerCase() == "yearly" && period == "1") {
      return "Year";
    } else if (renttypevalue.toLowerCase() == "yearly" && period != "1") {
      return "Years";
    }
  }
}
