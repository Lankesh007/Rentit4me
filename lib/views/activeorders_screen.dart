// ignore_for_file: prefer_const_constructors, prefer_interpolation_to_compose_strings

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'dart:convert';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'package:rentit4me_new/network/api.dart';
import 'package:rentit4me_new/themes/constant.dart';
import 'package:rentit4me_new/views/order_detail_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ActiveOrderScreen extends StatefulWidget {
  const ActiveOrderScreen({Key key}) : super(key: key);

  @override
  State<ActiveOrderScreen> createState() => _ActiveOrderScreenState();
}

class _ActiveOrderScreenState extends State<ActiveOrderScreen> {
  String searchvalue = "Enter order id";
  List<dynamic> myactiveorderslist = [];

  bool _progress = false;

  String startdate = "From Date";
  String enddate = "To Date";
  static const platform = const MethodChannel("razorpay_flutter");

  Razorpay _razorpay;

  @override
  void dispose() {
    super.dispose();
    _razorpay.clear();
  }

  void openCheckout(double amount) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var options = {
      'key': 'rzp_test_NNbwJ9tmM0fbxj',
      'name': 'Rentit4me',
      'amount': (amount * 100).toString(),
      'description': '',
      'timeout': 600, // in seconds
      'prefill': {
        'contact': prefs.getString('mobile'),
        'email': prefs.getString('email')
      }
    };

    try {
      _razorpay.open(options);
    } catch (e) {
      debugPrint('Error: e');
    }
  }

  Map map = {};

  void _handlePaymentSuccess(PaymentSuccessResponse response) async {
    map['razorpay_payment_id'] = response.paymentId.toString();
    print(map);
    var response1 = await http.post(Uri.parse(BASE_URL + "post-ad/renew/order"),
        body: jsonEncode(map),
        headers: {
          "Accept": "application/json",
          'Content-Type': 'application/json'
        });

    if (jsonDecode(response1.body)['ErrorCode'] == 0) {
      showToast(jsonDecode(response1.body)['ErrorMessage']);
      _myactiveorderslist();
    }
  }

  void _handlePaymentError(PaymentFailureResponse response) {
    print('Error Response: $response');
    /* Fluttertoast.showToast(
        msg: "ERROR: " + response.code.toString() + " - " + response.message!,
        toastLength: Toast.LENGTH_SHORT); */
  }

  void _handleExternalWallet(ExternalWalletResponse response) {
    print('External SDK Response: $response');
    /* Fluttertoast.showToast(
        msg: "EXTERNAL_WALLET: " + response.walletName!,
        toastLength: Toast.LENGTH_SHORT); */
  }

  List duration = [];
  Map durationValue = {};
  double listPrice = 0;
  String type = "";
  double securityDeposite = 0;
  double quantity = 0;
  double totalRent = 0;
  double convPer = 0;
  double tax = 0;
  double finalAmount = 0;
  TextEditingController enterValue = TextEditingController();
  int rentType = 0;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _razorpay = Razorpay();
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);
    _myactiveorderslist();
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
      //   title:
      //       const Text("Active Orders", style: TextStyle(color: kPrimaryColor)),
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
                  height: 
                  20,
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
                            if (searchvalue == "Enter order id" &&
                                startdate == "From Date") {
                              showToast(
                                  "Please enter your search or select date");
                            } else {
                              if (searchvalue == "Enter order id" ||
                                  searchvalue.length == 0 ||
                                  searchvalue.isEmpty) {
                                _myactiveorderslistByDate();
                              } else {
                                _myactiveorderslistBySearch();
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
                          showDialog(
                              context: context,
                              builder: (_) => AlertDialog(
                                  title: const Text('Detail Information'),
                                  content: SingleChildScrollView(
                                      child: Column(children: [
                                    Card(
                                      color: Colors.grey[100],
                                      child: ListTile(
                                        title: const Text("Order Id"),
                                        subtitle: Text(myactiveorderslist[index]
                                                ['order_id']
                                            .toString()),
                                      ),
                                    ),
                                    Card(
                                      color: Colors.grey[100],
                                      child: ListTile(
                                        title: const Text("Product Name"),
                                        subtitle: Text(myactiveorderslist[index]
                                                ["title"]
                                            .toString()),
                                      ),
                                    ),
                                    Card(
                                      color: Colors.grey[100],
                                      child: ListTile(
                                        title: const Text("Product Quantity"),
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
                                        title: const Text("Period"),
                                        subtitle: Text(myactiveorderslist[index]
                                                ["period"]
                                            .toString()),
                                      ),
                                    ),
                                    Card(
                                      color: Colors.grey[100],
                                      child: ListTile(
                                        title: const Text("Product Price(INR)"),
                                        subtitle: Text(myactiveorderslist[index]
                                                ["product_price"]
                                            .toString()),
                                      ),
                                    ),
                                    Card(
                                      color: Colors.grey[100],
                                      child: ListTile(
                                        title: const Text("Offer Amount(INR)"),
                                        subtitle: Text(myactiveorderslist[index]
                                                ["renter_amount"]
                                            .toString()),
                                      ),
                                    ),
                                    Card(
                                      color: Colors.grey[100],
                                      child: ListTile(
                                        title: const Text("Total Rent(INR)"),
                                        subtitle: Text(myactiveorderslist[index]
                                                ["total_rent"]
                                            .toString()),
                                      ),
                                    ),
                                    Card(
                                      color: Colors.grey[100],
                                      child: ListTile(
                                        title:
                                            const Text("Total Security(INR)"),
                                        subtitle: Text(myactiveorderslist[index]
                                                ["total_security"]
                                            .toString()),
                                      ),
                                    ),
                                    Card(
                                      color: Colors.grey[100],
                                      child: ListTile(
                                        title: const Text("Total Rent(INR)"),
                                        subtitle: Text(myactiveorderslist[index]
                                                ["total_rent"]
                                            .toString()),
                                      ),
                                    ),
                                    Card(
                                      color: Colors.grey[100],
                                      child: ListTile(
                                        title: const Text("Final Amount(INR)"),
                                        subtitle: Text(myactiveorderslist[index]
                                                ["final_amount"]
                                            .toString()),
                                      ),
                                    ),
                                  ]))));
                        },
                        child: Card(
                          elevation: 4.0,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                                vertical: 10, horizontal: 10),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Padding(
                                    padding: const EdgeInsets.only(left: 8.0),
                                    child: Text(
                                        "Order Id : ${myactiveorderslist[index]['order_id']}",
                                        style: TextStyle(
                                            color: Colors.black,
                                            fontWeight: FontWeight.w500))),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    TextButton(
                                        onPressed: () {
                                          Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                  builder: (context) =>
                                                      OrderDetailScreen(
                                                          orderid:
                                                              myactiveorderslist[
                                                                          index]
                                                                      ['id']
                                                                  .toString())));
                                        },
                                        child: SizedBox(
                                            width: size.width * 0.60,
                                            child: Text(
                                                "Product Name : ${myactiveorderslist[index]['title']}"))),
                                    const SizedBox(width: 4.0),
                                    InkWell(
                                        onTap: () {
                                          //_confirmation(context, myorderslist[index]['id'].toString());
                                        },
                                        child: Container(
                                            width: 80,
                                            alignment: Alignment.center,
                                            padding: EdgeInsets.all(4.0),
                                            decoration: BoxDecoration(
                                                borderRadius: BorderRadius.all(
                                                    Radius.circular(4.0)),
                                                border: Border.all(
                                                    color: Colors.grey)),
                                            child: const Text("NA",
                                                textAlign: TextAlign.center,
                                                style: TextStyle(
                                                    color: Colors.grey))))
                                  ],
                                ),
                                const SizedBox(height: 10.0),
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                          "Quantity: ${myactiveorderslist[index]['quantity']}"),
                                      myactiveorderslist[index]['period']
                                                      .toString() ==
                                                  "" ||
                                              myactiveorderslist[index]
                                                      ['period'] ==
                                                  null
                                          ? SizedBox()
                                          : Text(
                                              "Duration: " +
                                                  myactiveorderslist[index]
                                                          ['period']
                                                      .toString() +
                                                  " " +
                                                  _getrenttype(
                                                      myactiveorderslist[index]
                                                              ['period']
                                                          .toString(),
                                                      myactiveorderslist[index]
                                                              ['rent_type_name']
                                                          .toString()),
                                              style: TextStyle(
                                                  color: Colors.black,
                                                  fontSize: 14)),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 5.0),
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                          "Rent type: ${myactiveorderslist[index]['rent_type_name']}"),
                                      Text(
                                          "Status: ${myactiveorderslist[index]['status']}"),
                                    ],
                                  ),
                                ),
                                myactiveorderslist[index]['renew_and_return']
                                            .toString() ==
                                        "true"
                                    ? Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            ElevatedButton(
                                                onPressed: () async {
                                                  SharedPreferences prefs =
                                                      await SharedPreferences
                                                          .getInstance();
                                                  setState(() {
                                                    _progress = true;
                                                  });
                                                  final body = {
                                                    "user_id": prefs
                                                        .getString('userid'),
                                                    "orderid":
                                                        myactiveorderslist[
                                                                index]['id']
                                                            .toString()
                                                  };
                                                  print(jsonEncode(body));
                                                  print(BASE_URL +
                                                      "post-ad/renew/create");
                                                  var response = await http.post(
                                                      Uri.parse(BASE_URL +
                                                          "post-ad/renew/create"),
                                                      body: jsonEncode(body),
                                                      headers: {
                                                        "Accept":
                                                            "application/json",
                                                        'Content-Type':
                                                            'application/json'
                                                      });

                                                  if (jsonDecode(response.body)[
                                                          'ErrorCode'] ==
                                                      0) {
                                                    setState(() {
                                                      duration = [];
                                                      durationValue = {};
                                                      listPrice = 0;
                                                      type = "";
                                                      securityDeposite = 0;
                                                      quantity = 0;
                                                      totalRent = 0;
                                                      convPer = 0;
                                                      tax = 0;
                                                      finalAmount = 0;
                                                      enterValue.clear();
                                                      rentType = 0;
                                                      duration.addAll(jsonDecode(
                                                                      response
                                                                          .body)[
                                                                  'Response']
                                                              ['posted_ad']
                                                          ['prices']);
                                                      durationValue =
                                                          duration[0];
                                                      listPrice = double.parse(
                                                          duration[0]['price']
                                                              .toString());
                                                      type = duration[0][
                                                              'rent_type_alias']
                                                          .toString();
                                                      rentType = int.parse(
                                                          duration[0][
                                                                  'rent_type_id']
                                                              .toString());
                                                      securityDeposite = double
                                                          .parse(jsonDecode(response
                                                                          .body)[
                                                                      'Response']
                                                                  [
                                                                  'posted_ad']['security']
                                                              .toString());
                                                      quantity = double.parse(
                                                          jsonDecode(response
                                                                          .body)[
                                                                      'Response']
                                                                  [
                                                                  'data']['quantity']
                                                              .toString());
                                                      convPer = double.parse(
                                                          jsonDecode(response
                                                                          .body)[
                                                                      'Response']
                                                                  [
                                                                  'convenience_charges']['charge']
                                                              .toString());
                                                      // totalRent = quantity *
                                                      //     securityDeposite *
                                                      //     listPrice *
                                                      //     double.parse(
                                                      //         enterValue.text
                                                      //             .toString());
                                                      tax = (convPer / 100) *
                                                          (totalRent +
                                                              securityDeposite);
                                                      finalAmount = (totalRent +
                                                          securityDeposite +
                                                          tax);
                                                    });

                                                    showDialog(
                                                        context: context,
                                                        builder: (context) =>
                                                            AlertDialog(content:
                                                                StatefulBuilder(builder:
                                                                    (BuildContext
                                                                            context,
                                                                        StateSetter
                                                                            setState) {
                                                              return Container(
                                                                height: MediaQuery.of(
                                                                            context)
                                                                        .size
                                                                        .height /
                                                                    1.9,
                                                                child:
                                                                    SingleChildScrollView(
                                                                  child: Column(
                                                                    crossAxisAlignment:
                                                                        CrossAxisAlignment
                                                                            .start,
                                                                    children: [
                                                                      FormField(
                                                                        builder:
                                                                            (FormFieldState
                                                                                state) {
                                                                          return InputDecorator(
                                                                            decoration: InputDecoration(
                                                                                fillColor: Colors.white,
                                                                                filled: true,
                                                                                isDense: true,
                                                                                contentPadding: EdgeInsets.all(10),
                                                                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(5.0))),
                                                                            child:
                                                                                DropdownButtonHideUnderline(
                                                                              child: DropdownButton(
                                                                                isExpanded: true,
                                                                                value: durationValue,
                                                                                isDense: true,
                                                                                onChanged: (newValue) {
                                                                                  setState(() {
                                                                                    durationValue = newValue;
                                                                                    listPrice = double.parse(newValue['price'].toString());
                                                                                    type = newValue['rent_type_alias'].toString();
                                                                                    rentType = int.parse(newValue['rent_type_id'].toString());
                                                                                  });

                                                                                  if (enterValue.text.isEmpty) {
                                                                                    setState(() {
                                                                                      totalRent = quantity * listPrice * 0;
                                                                                      tax = (convPer / 100) * (totalRent + securityDeposite);
                                                                                      finalAmount = (totalRent + securityDeposite + tax);
                                                                                    });
                                                                                  } else {
                                                                                    setState(() {
                                                                                      totalRent = quantity * listPrice * double.parse(enterValue.text.toString());
                                                                                      tax = (convPer / 100) * (totalRent + securityDeposite);
                                                                                      finalAmount = (totalRent + securityDeposite + tax);
                                                                                    });
                                                                                  }
                                                                                },
                                                                                items: duration.map((value) {
                                                                                  return DropdownMenuItem(
                                                                                    value: value,
                                                                                    child: Text(value['rent_type_name'].toString()),
                                                                                  );
                                                                                }).toList(),
                                                                              ),
                                                                            ),
                                                                          );
                                                                        },
                                                                      ),
                                                                      SizedBox(
                                                                        height:
                                                                            10,
                                                                      ),
                                                                      Text("Listed Price : " +
                                                                          listPrice
                                                                              .toString() +
                                                                          " / " +
                                                                          type),
                                                                      SizedBox(
                                                                        height:
                                                                            10,
                                                                      ),
                                                                      Text("Security Deposit : " +
                                                                          securityDeposite
                                                                              .toString()),
                                                                      SizedBox(
                                                                        height:
                                                                            10,
                                                                      ),
                                                                      Text("Quantity : " +
                                                                          quantity
                                                                              .toStringAsFixed(0)),
                                                                      SizedBox(
                                                                        height:
                                                                            10,
                                                                      ),
                                                                      TextFormField(
                                                                        controller:
                                                                            enterValue,
                                                                        onChanged:
                                                                            (value) {
                                                                          if (value
                                                                              .isEmpty) {
                                                                            setState(() {
                                                                              totalRent = quantity * listPrice * 0;
                                                                              tax = (convPer / 100) * (totalRent + securityDeposite);
                                                                              finalAmount = (totalRent + securityDeposite + tax);
                                                                            });
                                                                          } else {
                                                                            setState(() {
                                                                              totalRent = quantity * listPrice * double.parse(value.toString());
                                                                              tax = (convPer / 100) * (totalRent + securityDeposite);
                                                                              finalAmount = (totalRent + securityDeposite + tax);
                                                                            });
                                                                          }
                                                                        },
                                                                        decoration: InputDecoration(
                                                                            label:
                                                                                Text("Enter " + type.toString()),
                                                                            border: OutlineInputBorder()),
                                                                      ),
                                                                      SizedBox(
                                                                        height:
                                                                            10,
                                                                      ),
                                                                      Text("Total Rent : " +
                                                                          totalRent
                                                                              .toStringAsFixed(2)),
                                                                      SizedBox(
                                                                        height:
                                                                            10,
                                                                      ),
                                                                      Text("Total Security : " +
                                                                          securityDeposite
                                                                              .toStringAsFixed(2)),
                                                                      SizedBox(
                                                                        height:
                                                                            10,
                                                                      ),
                                                                      Text("Convenience Charge (" +
                                                                          convPer.toStringAsFixed(
                                                                              2) +
                                                                          "%) : " +
                                                                          tax.toStringAsFixed(
                                                                              2)),
                                                                      SizedBox(
                                                                        height:
                                                                            10,
                                                                      ),
                                                                      Text("Final Amount : " +
                                                                          finalAmount
                                                                              .toStringAsFixed(2)),
                                                                      SizedBox(
                                                                        height:
                                                                            20,
                                                                      ),
                                                                      SizedBox(
                                                                        width: MediaQuery.of(context)
                                                                            .size
                                                                            .width,
                                                                        child: ElevatedButton(
                                                                            onPressed: () async {
                                                                              SharedPreferences pref = await SharedPreferences.getInstance();
                                                                              map = {};
                                                                              setState(() {
                                                                                map["user_id"] = prefs.getString('userid');
                                                                                map["orderid"] = myactiveorderslist[index]['id'].toString();
                                                                                map["razorpay_payment_id"] = "";
                                                                                map["amount"] = finalAmount.toString();
                                                                                map["rent_type"] = rentType.toString();
                                                                                map["period"] = enterValue.text.toString();
                                                                              });
                                                                              Navigator.of(context).pop();
                                                                              openCheckout(finalAmount);
                                                                            },
                                                                            child: Text("Renew & Pay")),
                                                                      )
                                                                    ],
                                                                  ),
                                                                ),
                                                              );
                                                            })));
                                                  }
                                                  setState(() {
                                                    _progress = false;
                                                  });
                                                },
                                                child: Text("Renew")),
                                            ElevatedButton(
                                                onPressed: () {
                                                  showDialog(
                                                      context: context,
                                                      builder:
                                                          (context) =>
                                                              AlertDialog(
                                                                title: Text(
                                                                    "Confirmation"),
                                                                content: Text(
                                                                    "Do you want to return this item"),
                                                                actions: [
                                                                  TextButton(
                                                                      onPressed:
                                                                          () {
                                                                        Navigator.of(context)
                                                                            .pop();
                                                                      },
                                                                      child: Text(
                                                                          "Cancel")),
                                                                  TextButton(
                                                                      onPressed:
                                                                          () async {
                                                                        setState(
                                                                            () {
                                                                          _progress =
                                                                              true;
                                                                        });
                                                                        var response = await http.post(
                                                                            Uri.parse(BASE_URL +
                                                                                "renter-orders/status"),
                                                                            body: jsonEncode({"order_id": myactiveorderslist[index]['id'].toString(), "status": "returned"}),
                                                                            headers: {
                                                                              "Accept": "application/json",
                                                                              'Content-Type': 'application/json'
                                                                            });

                                                                        if (jsonDecode(response.body)['ErrorCode'] ==
                                                                            0) {
                                                                          showToast(
                                                                              "Returned Succesfull");
                                                                          Navigator.of(context)
                                                                              .pop();
                                                                        }
                                                                      },
                                                                      child: Text(
                                                                          "OK"))
                                                                ],
                                                              ));
                                                },
                                                child: Text("Return"))
                                          ],
                                        ),
                                      )
                                    : SizedBox()
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
    if (statusvalue == "3") {
      return Container(
        padding: EdgeInsets.all(4.0),
        decoration: BoxDecoration(
            borderRadius: BorderRadius.all(Radius.circular(4.0)),
            border: Border.all(color: Colors.blue)),
        child: const Text("Edit", style: TextStyle(color: Colors.blue)),
      );
    } else if (statusvalue == "13") {
      return const Text("NA", style: TextStyle(color: Colors.grey));
    } else {
      return const Text("NA", style: TextStyle(color: Colors.grey));
    }
  }

  Future<void> _myactiveorderslist() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      myactiveorderslist.clear();
      _progress = true;
    });
    final body = {
      "id": prefs.getString('userid'),
    };
    var response = await http.post(Uri.parse(BASE_URL + activeorders),
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

  Future<void> _myactiveorderslistByDate() async {
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
    var response = await http.post(Uri.parse(BASE_URL + activeorders),
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

  Future<void> _myactiveorderslistBySearch() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      myactiveorderslist.clear();
      _progress = true;
    });
    final body = {
      "id": prefs.getString('userid'),
      "search": searchvalue,
    };
    var response = await http.post(Uri.parse(BASE_URL + activeorders),
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
}
