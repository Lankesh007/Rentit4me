// ignore_for_file: prefer_const_literals_to_create_immutables, prefer_const_constructors, prefer_interpolation_to_compose_strings

import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:rentit4me_new/network/api.dart';
import 'package:rentit4me_new/themes/constant.dart';
import 'package:rentit4me_new/views/order_detail_screen.dart';
import 'package:rentit4me_new/views/shiprocket_place_order.dart';
import 'package:shared_preferences/shared_preferences.dart';

class OrderRecievedScreen extends StatefulWidget {
  const OrderRecievedScreen({Key key}) : super(key: key);

  @override
  State<OrderRecievedScreen> createState() => _OrderRecievedScreenState();
}

class _OrderRecievedScreenState extends State<OrderRecievedScreen> {
  String searchvalue = "Enter order id";
  List<dynamic> myactiveorderslist = [];

  bool _progress = false;

  String startdate = "From Date";
  String enddate = "To Date";

  String pickup;

  List<String> responselist = ['Scheduler Pickup', 'Self Delivered', 'Cancel'];
  String responsevalue;
  String response;
  double conPer = 0;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _myrecievedorderslist();
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
      //       // child: const Icon(Icons.arrow_back, color: kPrimaryColor)),
      //   title: Text("Orders Received", style: TextStyle(color: kPrimaryColor)),
      //   centerTitle: true,
      // ),
      body: ModalProgressHUD(
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
                        SizedBox(height: 5),
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
                              searchvalue = value;
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
                        SizedBox(height: 10),
                        InkWell(
                          onTap: () {
                            if (searchvalue == "Enter order id" &&
                                startdate == "From Date") {
                              showToast(
                                  "Please enter your search or select date");
                            } else {
                              if (searchvalue == "Enter order id" ||
                                  searchvalue.length == 0 ||
                                  searchvalue.isEmpty) {
                                _myrecievedorderslistByDate();
                              } else {
                                _myrecievedorderslistBySearch();
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
                Container(
                  height: size.height * 0.50,
                  child: ListView.separated(
                    padding: EdgeInsets.zero,
                    shrinkWrap: true,
                    itemCount: myactiveorderslist.length,
                    separatorBuilder: (BuildContext context, int index) =>
                        const Divider(),
                    itemBuilder: (BuildContext context, int index) {
                      return InkWell(
                        onTap: () {
                          double total = double.parse(myactiveorderslist[index]
                                      ["total_security"]
                                  .toString()) +
                              double.parse(myactiveorderslist[index]
                                      ["total_rent"]
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
                                        title: Text("Order Id"),
                                        subtitle: Text(myactiveorderslist[index]
                                                ['order_id']
                                            .toString()),
                                      ),
                                    ),
                                    Card(
                                      color: Colors.grey[100],
                                      child: ListTile(
                                        title: Text("Product Name"),
                                        subtitle: Text(myactiveorderslist[index]
                                                ["title"]
                                            .toString()),
                                      ),
                                    ),
                                    Card(
                                      color: Colors.grey[100],
                                      child: ListTile(
                                        title: Text("Product Quantity"),
                                        subtitle: Text(myactiveorderslist[index]
                                                ["quantity"]
                                            .toString()),
                                      ),
                                    ),
                                    Card(
                                      color: Colors.grey[100],
                                      child: ListTile(
                                        title: Text("Rent Type"),
                                        subtitle: Text(myactiveorderslist[index]
                                                ["rent_type_name"]
                                            .toString()),
                                      ),
                                    ),
                                    Card(
                                      color: Colors.grey[100],
                                      child: ListTile(
                                        title: Text("Period"),
                                        subtitle: Text(myactiveorderslist[index]
                                                ["period"]
                                            .toString()),
                                      ),
                                    ),
                                    Card(
                                      color: Colors.grey[100],
                                      child: ListTile(
                                        title: Text("Product Price(INR)"),
                                        subtitle: Text(myactiveorderslist[index]
                                                ["product_price"]
                                            .toString()),
                                      ),
                                    ),
                                    Card(
                                      color: Colors.grey[100],
                                      child: ListTile(
                                        title: Text("Offer Amount(INR)"),
                                        subtitle: Text(myactiveorderslist[index]
                                                ["renter_amount"]
                                            .toString()),
                                      ),
                                    ),
                                    Card(
                                      color: Colors.grey[100],
                                      child: ListTile(
                                        title: Text("Total Rent(INR)"),
                                        subtitle: Text(myactiveorderslist[index]
                                                ["total_rent"]
                                            .toString()),
                                      ),
                                    ),
                                    Card(
                                      color: Colors.grey[100],
                                      child: ListTile(
                                        title: Text("Total Security(INR)"),
                                        subtitle: Text(myactiveorderslist[index]
                                                ["total_security"]
                                            .toString()),
                                      ),
                                    ),
                                    Card(
                                        color: Colors.grey[100],
                                        child: ListTile(
                                            title: Text(
                                                "Convenience Charges (" +
                                                    conPer
                                                        .toStringAsFixed(0)
                                                        .toString() +
                                                    "%)"),
                                            subtitle:
                                                Text(taxValue.toString()))),
                                    Card(
                                        color: Colors.grey[100],
                                        child: ListTile(
                                            title:
                                                const Text("Final Amount(INR)"),
                                            subtitle: Text((double.parse(
                                                        myactiveorderslist[
                                                                    index]
                                                                ["final_amount"]
                                                            .toString()) -
                                                    taxValue)
                                                .toString())))
                                  ]))));
                        },
                        child: Card(
                          elevation: 4.0,
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
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
                                                    OrderDetailScreen(
                                                        orderid:
                                                            myactiveorderslist[
                                                                    index]['id']
                                                                .toString())));
                                      },
                                      child: Text(
                                          "Order Id : ${myactiveorderslist[index]['order_id']}",
                                          style: TextStyle(
                                              color: kPrimaryColor,
                                              fontWeight: FontWeight.w500)),
                                    ),
                                    myactiveorderslist[index]["offer_status"]
                                                .toString() ==
                                            "1"
                                        ? InkWell(
                                            onTap: () {},
                                            child: Container(
                                              padding: EdgeInsets.all(4.0),
                                              decoration: BoxDecoration(
                                                  borderRadius:
                                                      BorderRadius.all(
                                                          Radius.circular(4.0)),
                                                  border: Border.all(
                                                      color: Colors.blue)),
                                              child: const Text("Action",
                                                  style: TextStyle(
                                                      color: Colors.blue)),
                                            ),
                                          )
                                        : _getaction(
                                            myactiveorderslist[index]["status"]
                                                .toString(),
                                          ),
                                  ],
                                ),
                                const SizedBox(height: 5.0),
                                Text(
                                    "Product : ${myactiveorderslist[index]['title']}"),
                                const SizedBox(height: 5.0),
                                Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                          "Qty: ${myactiveorderslist[index]['quantity']}"),
                                      Text(
                                          "Duration: ${myactiveorderslist[index]['period']}"),
                                      Text(
                                          "Rent type: ${myactiveorderslist[index]['rent_type_name']}"),
                                    ]),
                                const SizedBox(height: 10.0),
                                Row(
                                  children: [
                                    const Text("Delivery Type :",
                                        style: TextStyle(
                                            color: Colors.black, fontSize: 14)),
                                    const SizedBox(width: 4.0),
                                    myactiveorderslist[index]["status"]
                                                    .toString() ==
                                                "cancelled" ||
                                            myactiveorderslist[index]["status"]
                                                    .toString() ==
                                                "pending"
                                        ? const Text("N/A",
                                            textAlign: TextAlign.center,
                                            style:
                                                TextStyle(color: Colors.black))
                                        : myactiveorderslist[index]
                                                        ["scheduler_pickup"]
                                                    .toString() ==
                                                "0"
                                            ? const Text("Self Deliver",
                                                textAlign: TextAlign.center,
                                                style: TextStyle(
                                                    color: Colors.black))
                                            : const Text("Schedular Pickup",
                                                textAlign: TextAlign.center,
                                                style: TextStyle(
                                                    color: Colors.black)),
                                    const SizedBox(width: 12.0),
                                    Expanded(
                                        child: _getStatus(
                                                    myactiveorderslist[index]
                                                            ["status"]
                                                        .toString()) ==
                                                "Respond"
                                            ? InkWell(
                                                onTap: () {
                                                  showDialog(
                                                      context: context,
                                                      barrierDismissible: false,
                                                      builder: (context) =>
                                                          StatefulBuilder(
                                                              builder: (context,
                                                                  setState) {
                                                            return AlertDialog(
                                                              title: const Text(
                                                                  "Response",
                                                                  style: TextStyle(
                                                                      color: Colors
                                                                          .deepOrangeAccent)),
                                                              content:
                                                                  Container(
                                                                child:
                                                                    SingleChildScrollView(
                                                                        child: Column(
                                                                            children: [
                                                                      DropdownButtonHideUnderline(
                                                                        child: DropdownButton<
                                                                            String>(
                                                                          hint: const Text(
                                                                              "Select",
                                                                              style: TextStyle(color: Colors.black, fontSize: 18)),
                                                                          value:
                                                                              response,
                                                                          elevation:
                                                                              16,
                                                                          isExpanded:
                                                                              true,
                                                                          style: TextStyle(
                                                                              color: Colors.grey.shade700,
                                                                              fontSize: 16),
                                                                          onChanged:
                                                                              (String data) {
                                                                            setState(() {
                                                                              if (data.toString() == "Cancel") {
                                                                                responsevalue = "cancelled";
                                                                                response = data.toString();
                                                                              } else if (data.toString() == "Self Delivered") {
                                                                                responsevalue = "delivered";
                                                                                response = data.toString();
                                                                              } else {
                                                                                responsevalue = "scheduler pickup";
                                                                                response = data.toString();
                                                                              }
                                                                            });
                                                                          },
                                                                          items:
                                                                              responselist.map<DropdownMenuItem<String>>((String value) {
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
                                                                          height:
                                                                              1,
                                                                          color: Colors
                                                                              .grey,
                                                                          thickness:
                                                                              1),
                                                                      const SizedBox(
                                                                          height:
                                                                              25),
                                                                      InkWell(
                                                                        onTap:
                                                                            () {
                                                                          if (responsevalue == null ||
                                                                              responsevalue == "" ||
                                                                              responsevalue == "null") {
                                                                            showToast("Please select your response");
                                                                          } else {
                                                                            _submitrespond(myactiveorderslist[index]["id"].toString(),
                                                                                responsevalue);
                                                                          }
                                                                        },
                                                                        child:
                                                                            Container(
                                                                          height:
                                                                              45,
                                                                          width:
                                                                              double.infinity,
                                                                          alignment:
                                                                              Alignment.center,
                                                                          decoration: const BoxDecoration(
                                                                              color: Colors.deepOrangeAccent,
                                                                              borderRadius: BorderRadius.all(Radius.circular(8.0))),
                                                                          child: Text(
                                                                              "Submit",
                                                                              style: TextStyle(color: Colors.white)),
                                                                        ),
                                                                      )
                                                                    ])),
                                                              ),
                                                            );
                                                          }));
                                                },
                                                child: Container(
                                                  height: 40,
                                                  width: 80,
                                                  alignment: Alignment.center,
                                                  decoration: BoxDecoration(
                                                      color: kPrimaryColor,
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              8.0)),
                                                  child: Text(
                                                      _getStatus(
                                                          myactiveorderslist[
                                                                      index]
                                                                  ["status"]
                                                              .toString()),
                                                      style: TextStyle(
                                                          color: Colors.white)),
                                                ),
                                              )
                                            : InkWell(
                                                onTap: () {
                                                  if (_getStatus(
                                                          myactiveorderslist[
                                                                      index]
                                                                  ["status"]
                                                              .toString()) ==
                                                      "Recieved") {
                                                    _confirmation(
                                                        context,
                                                        myactiveorderslist[
                                                                index]["id"]
                                                            .toString());
                                                  }
                                                },
                                                child: Container(
                                                  height: 40,
                                                  width: 80,
                                                  alignment: Alignment.center,
                                                  decoration: BoxDecoration(
                                                      color: Colors.lightGreen,
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              8.0)),
                                                  child: Text(
                                                      _getStatus(
                                                          myactiveorderslist[
                                                                      index]
                                                                  ["status"]
                                                              .toString()),
                                                      style: TextStyle(
                                                          color: Colors.white)),
                                                ),
                                              ))
                                  ],
                                ),
                                TextButton(
                                    style: ButtonStyle(
                                        padding: MaterialStateProperty.all(
                                            EdgeInsets.zero)),
                                    onPressed: () async {
                                      if (myactiveorderslist[index]['status']
                                                  .toString() ==
                                              "scheduler pickup" &&
                                          myactiveorderslist[index]
                                                      ['scheduler_pickup']
                                                  .toString() ==
                                              "1" &&
                                          myactiveorderslist[index]
                                                  ['shiprocket_id'] ==
                                              null) {
                                        Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                                builder: (context) =>
                                                    ShipRocketPlaceOrder(
                                                        id: myactiveorderslist[
                                                                index]['id']
                                                            .toString()))).then(
                                            (value) {
                                          _myrecievedorderslist();
                                        });
                                      } else if (myactiveorderslist[index]
                                                      ['status']
                                                  .toString() ==
                                              "scheduler pickup" &&
                                          myactiveorderslist[index]
                                                      ['scheduler_pickup']
                                                  .toString() ==
                                              "1" &&
                                          myactiveorderslist[index]
                                                  ['shiprocket_id'] !=
                                              null) {
                                        print("del");

                                        setState(() {
                                          _progress = true;
                                        });
                                        final body = {
                                          "orderid": myactiveorderslist[index]
                                                  ['id']
                                              .toString(),
                                        };
                                        var response = await http.post(
                                            Uri.parse(BASE_URL +
                                                "shiprocket-delivery-status"),
                                            body: jsonEncode(body),
                                            headers: {
                                              "Accept": "application/json",
                                              'Content-Type': 'application/json'
                                            });
                                        setState(() {
                                          _progress = false;
                                        });
                                        if (jsonDecode(
                                                response.body)['ErrorCode'] ==
                                            0) {
                                          showDeliveryStatus(jsonDecode(
                                              response.body)['Response']);
                                        } else {
                                          showToast("No data found");
                                        }
                                      }
                                    },
                                    child: myactiveorderslist[index]['status']
                                                    .toString() ==
                                                "scheduler pickup" &&
                                            myactiveorderslist[index]
                                                        ['scheduler_pickup']
                                                    .toString() ==
                                                "1" &&
                                            myactiveorderslist[index]
                                                    ['shiprocket_id'] ==
                                                null
                                        ? Text("ShipRocket : Place Order")
                                        : myactiveorderslist[index]['status'].toString() ==
                                                    "scheduler pickup" &&
                                                myactiveorderslist[index]
                                                            ['scheduler_pickup']
                                                        .toString() ==
                                                    "1" &&
                                                myactiveorderslist[index]
                                                        ['shiprocket_id'] !=
                                                    null
                                            ? Text("ShipRocket : Delivery Status")
                                            : Text("ShipRocket : N/A"))
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _getaction(String statusvalue) {
    // if (statusvalue == "3") {
    //   return Container(
    //     padding: EdgeInsets.all(4.0),
    //     decoration: BoxDecoration(
    //         borderRadius: BorderRadius.all(Radius.circular(4.0)),
    //         border: Border.all(color: Colors.blue)),
    //     child: Text("Edit", style: TextStyle(color: Colors.blue)),
    //   );
    // } else
    if (statusvalue == "scheduler pickup") {
      return Text("Pickup Scheduled", style: TextStyle(color: Colors.grey));
    } else if (statusvalue == "pending") {
      return Text("Delivery Pending", style: TextStyle(color: Colors.grey));
    } else {
      return Text(statusvalue, style: TextStyle(color: Colors.grey));
    }
  }

  Future<void> _myrecievedorderslist() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    setState(() {
      myactiveorderslist.clear();
      _progress = true;
    });
    final body = {
      "user_id": prefs.getString('userid'),
    };
    print(BASE_URL + orderreceived);
    print(jsonEncode(body));
    var response = await http.post(Uri.parse(BASE_URL + orderreceived),
        body: jsonEncode(body),
        headers: {
          "Accept": "application/json",
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${prefs.getString("token")}',
        });
    setState(() {
      _progress = false;
    });
    if (response.statusCode == 200) {
      if (jsonDecode(response.body)['ErrorCode'].toString() == "0") {
        setState(() {
          myactiveorderslist
              .addAll(jsonDecode(response.body)['Response']['Orders']);
          conPer = double.parse(jsonDecode(response.body)['Response']
                  ['convenience_charges']['charge']
              .toString());
        });
      } else {
        showToast(jsonDecode(response.body)['ErrorMessage'].toString());
      }
    } else {
      throw Exception('Failed to get data due to ${response.body}');
    }
  }

  Future<void> _myrecievedorderslistByDate() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      myactiveorderslist.clear();
      _progress = true;
    });
    final body = {
      "id": prefs.getString('userid'),
      "from_date": startdate,
      "to_date": enddate
    };
    var response = await http.post(Uri.parse(BASE_URL + orderreceived),
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
        setState(() {
          myactiveorderslist
              .addAll(jsonDecode(response.body)['Response']['Orders']);
        });
      } else {
        showToast(jsonDecode(response.body)['ErrorMessage'].toString());
      }
    } else {
      setState(() {
        _progress = false;
      });
      print(response.body);
      throw Exception('Failed to get data due to ${response.body}');
    }
  }

  Future<void> _myrecievedorderslistBySearch() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      myactiveorderslist.clear();
      _progress = true;
    });
    final body = {
      "id": prefs.getString('userid'),
      "search": searchvalue,
    };
    var response = await http.post(Uri.parse(BASE_URL + orderreceived),
        body: jsonEncode(body),
        headers: {
          "Accept": "application/json",
          'Content-Type': 'application/json'
        });
    print(response.body);
    if (response.statusCode == 200) {
      if (jsonDecode(response.body)['ErrorCode'].toString() == "0") {
        setState(() {
          myactiveorderslist
              .addAll(jsonDecode(response.body)['Response']['Orders']);
          _progress = false;
        });
      } else {
        setState(() {
          _progress = false;
        });
        showToast(jsonDecode(response.body)['ErrorMessage'].toString());
      }
    } else {
      setState(() {
        _progress = false;
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
    if (picked != null)
      setState(() {
        enddate = DateFormat('yyyy-MM-dd').format(picked);
      });
  }

  _getStatus(String status) {
    if (status == "pending") {
      return "Respond"; //
    } else if (status == "returned") {
      return "Recieved"; //
    } else {
      return "NA";
    }
  }

  Future<void> _submitrespond(String orderid, String respond) async {
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
          'Content-Type': 'application/json'
        });
    setState(() {
      _progress = false;
    });
    if (response.statusCode == 200) {
      if (jsonDecode(response.body)['ErrorCode'].toString() == "0") {
        Navigator.of(context, rootNavigator: true).pop('dialog');
        showToast(jsonDecode(response.body)['ErrorMessage'].toString());
        _myrecievedorderslist();
      } else {
        Navigator.of(context, rootNavigator: true).pop('dialog');
        showToast(jsonDecode(response.body)['ErrorMessage'].toString());
      }
    } else {
      setState(() {
        _progress = false;
      });
      print(response.body);
      throw Exception('Failed to get data due to ${response.body}');
    }
  }

  Future<void> _confirmation(BuildContext context, String orderid) {
    return showDialog(
      builder: (context) => AlertDialog(
        actionsPadding: EdgeInsets.all(0),
        insetPadding: EdgeInsets.all(0),
        title: const Text('Confirmation'),
        content: const Text(
          "Are you recieved your product?",
          style: TextStyle(color: Colors.black54),
        ),
        actions: <Widget>[
          FlatButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text('CANCEL', style: TextStyle(color: kPrimaryColor)),
          ),
          FlatButton(
            onPressed: () {
              Navigator.pop(context);
              _submitrespond(orderid, "complete");
              //Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (_) => SignUp()), (route) => false);
            },
            child: const Text(
              'Yes',
              style: TextStyle(color: kPrimaryColor),
            ),
          ),
        ],
      ),
      context: context,
    );
  }

  Future<void> showDeliveryStatus(Map m) async {
    print(m);
    await showModalBottomSheet(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(20.0))),
        backgroundColor: Colors.white,
        context: context,
        isScrollControlled: true,
        builder: (context) => StatefulBuilder(
                builder: (BuildContext context, StateSetter setState) {
              return SizedBox(
                  height: MediaQuery.of(context).size.height / 1.5,
                  child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: SingleChildScrollView(
                          child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                    child: Text(
                                  "Product",
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                )),
                                Expanded(
                                    flex: 2,
                                    child: Text(
                                      m['Postad']['title'].toString(),
                                      style: TextStyle(),
                                    ))
                              ],
                            ),
                            SizedBox(
                              height: 10,
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                    child: Text(
                                  "Order Placed",
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                )),
                                Expanded(
                                    flex: 2,
                                    child: Text(
                                      DateFormat("d/MMM/yy").add_jm().format(
                                          DateTime.parse(m['data']['created_at']
                                              .toString())),
                                      style: TextStyle(),
                                    ))
                              ],
                            ),
                            SizedBox(
                              height: 10,
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                    child: Text(
                                  "Total",
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                )),
                                Expanded(
                                    flex: 2,
                                    child: Text(
                                      m['data']['sub_total'].toString(),
                                      style: TextStyle(),
                                    ))
                              ],
                            ),
                            SizedBox(
                              height: 10,
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                    child: Text(
                                  "Ship To",
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                )),
                                Expanded(
                                    flex: 2,
                                    child: Text(
                                      m['data']['shipping_customer_name']
                                          .toString(),
                                      style: TextStyle(),
                                    ))
                              ],
                            ),
                            SizedBox(
                              height: 10,
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                    child: Text(
                                  "Address",
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                )),
                                Expanded(
                                    flex: 2,
                                    child: Text(
                                      m['data']['billing_address'].toString(),
                                      style: TextStyle(),
                                    ))
                              ],
                            ),
                            SizedBox(
                              height: 10,
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                    child: Text(
                                  "Order From",
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                )),
                                Expanded(
                                    flex: 2,
                                    child: Text(
                                      "gagan",
                                      style: TextStyle(),
                                    ))
                              ],
                            ),
                            SizedBox(
                              height: 10,
                            ),
                            InkWell(
                              onTap: () {
                                print("object");
                              },
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Expanded(
                                      child: Text(
                                    "Action",
                                    style:
                                        TextStyle(fontWeight: FontWeight.bold),
                                  )),
                                  Expanded(
                                    flex: 2,
                                    child: Text(
                                      "View",
                                      style: TextStyle(color: Colors.blue),
                                    ),
                                  )
                                ],
                              ),
                            ),
                            Divider(
                              thickness: 0.9,
                              height: 30,
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                    child: Text(
                                  "Order Id",
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                )),
                                Expanded(
                                    flex: 2,
                                    child: Text(
                                      m['data']['shiprocket_order_id']
                                          .toString(),
                                      style: TextStyle(),
                                    ))
                              ],
                            ),
                            SizedBox(
                              height: 10,
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                    child: Text(
                                  "Payment Method",
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                )),
                                Expanded(
                                    flex: 2,
                                    child: Text(
                                      m['data']['payment_method']
                                          .toString()
                                          .toUpperCase(),
                                      style: TextStyle(),
                                    ))
                              ],
                            ),
                            SizedBox(
                              height: 10,
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                    child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: ElevatedButton(
                                      onPressed: () {},
                                      child: Text("Track Order")),
                                )),
                                Expanded(
                                    child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: ElevatedButton(
                                      onPressed: () {
                                        showDialog(
                                            context: context,
                                            builder: (context) => AlertDialog(
                                                  title: Text("Confirmation"),
                                                  content: Text(
                                                      "Do you want to cancel"),
                                                  actions: [
                                                    TextButton(
                                                        onPressed: () {
                                                          Navigator.of(context)
                                                              .pop();
                                                        },
                                                        child: Text("Cancel")),
                                                    TextButton(
                                                        onPressed: () async {
                                                          SharedPreferences
                                                              prefs =
                                                              await SharedPreferences
                                                                  .getInstance();
                                                          var response = await http.post(
                                                              Uri.parse(BASE_URL +
                                                                  "shiprocket-cancel-order"),
                                                              body: jsonEncode({
                                                                "orderid": m[
                                                                            'data']
                                                                        [
                                                                        'order_id']
                                                                    .toString(),
                                                                "userid": prefs
                                                                    .getString(
                                                                        'userid'),
                                                              }),
                                                              headers: {
                                                                "Accept":
                                                                    "application/json",
                                                                'Content-Type':
                                                                    'application/json'
                                                              });
                                                          print(response.body);
                                                          if (jsonDecode(response
                                                                      .body)[
                                                                  'ErrorCode'] ==
                                                              0) {
                                                            showToast(jsonDecode(
                                                                    response
                                                                        .body)[
                                                                'ErrorMessage']);
                                                            Navigator.of(
                                                                    context)
                                                                .pop();

                                                            _myrecievedorderslist();
                                                          } else {
                                                            showToast(jsonDecode(
                                                                    response
                                                                        .body)[
                                                                'ErrorMessage']);
                                                            Navigator.of(
                                                                    context)
                                                                .pop();
                                                          }
                                                        },
                                                        child: Text("OK"))
                                                  ],
                                                ));
                                      },
                                      child: Text("Cancel Order")),
                                ))
                              ],
                            )
                          ]))));
            }));
  }
}
