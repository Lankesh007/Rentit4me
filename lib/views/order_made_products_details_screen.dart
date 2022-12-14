// ignore_for_file: use_build_context_synchronously

import 'dart:developer';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:html/parser.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:rentit4me_new/network/api.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:rentit4me_new/themes/constant.dart';
import 'package:rentit4me_new/widgets/api_helper.dart';
import 'package:shared_preferences/shared_preferences.dart';

class OrderMadeProductsDetailsScreen extends StatefulWidget {
  final String orderId;
  final String orderIdForFeedback;
  const OrderMadeProductsDetailsScreen(
      {this.orderId, this.orderIdForFeedback, Key key})
      : super(key: key);

  @override
  State<OrderMadeProductsDetailsScreen> createState() =>
      _OrderMadeProductsDetailsScreenState();
}

class _OrderMadeProductsDetailsScreenState
    extends State<OrderMadeProductsDetailsScreen> {
  @override
  String offerid;
  String postadid;

  bool _loading = false;
  bool buttonLoader = false;

  //Detail Information
  String productimage;
  String productname;
  String productqty;
  String description;
  String boostpack;
  String currency;
  String productprice;
  String name;
  String businessname;
  String address;
  String negotiable;
  String securitydeposit;

  //Offer Detail
  String quantity;
  String period;
  String renttype;
  String productpeice;
  String productsecurity;
  String offerammount;
  String totalrent;
  String totalsecurity;
  String finalamount;
  String startdate;
  String enddate;
  String status;
  String createdAt;
  String renttypeid;
  double userRating = 0;

  String commprefs;
  bool showConversionCharges = false;
  String convenience_charge;
  String convenience_chargeValue;

  @override
  void initState() {
    super.initState();
    _getinitdata();

    _getofferdetailproduct();
  }

  String userId;
  _getinitdata() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();

    userId = preferences.getString('userid');
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
        title: Text("Order Details", style: TextStyle(color: kPrimaryColor)),
        centerTitle: true,
      ),
      body: ModalProgressHUD(
          inAsyncCall: _loading,
          color: kPrimaryColor,
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: _loading == true
                  ? SizedBox()
                  : Column(
                      children: [
                        // Text(widget.offerid),
                        // Text(widget.postadid),

                        Card(
                          elevation: 4.0,
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const SizedBox(height: 5),
                                const Text("Product Details",
                                    style: TextStyle(
                                        color: kPrimaryColor,
                                        fontSize: 20,
                                        fontWeight: FontWeight.w700)),
                                const SizedBox(height: 10),
                                productimage == null
                                    ? SizedBox(
                                        height:
                                            MediaQuery.of(context).size.height *
                                                0.4,
                                        width: double.infinity,
                                        child: Image.asset(
                                            'assets/images/no_image.jpg'),
                                      )
                                    : SizedBox(
                                        height:
                                            MediaQuery.of(context).size.height *
                                                0.4,
                                        width: double.infinity,
                                        child: CachedNetworkImage(
                                          imageUrl: devImage + productimage,
                                          fit: BoxFit.fill,
                                          errorWidget: (context, url, error) =>
                                              Image.asset(
                                                  'assets/images/no_image.jpg',
                                                  fit: BoxFit.none),
                                        ),
                                      ),
                                const SizedBox(height: 10),
                                Divider(),
                                productname == null
                                    ? const SizedBox()
                                    : Text(productname,
                                        style: const TextStyle(
                                            color: kPrimaryColor,
                                            fontSize: 16,
                                            fontWeight: FontWeight.w700)),
                                // boostpack == null
                                //     ? const SizedBox(height: 0)
                                //     : const SizedBox(height: 10),
                                // boostpack == null
                                //     ? const SizedBox(height: 0)
                                //     : Container(
                                //         height: 30,
                                //         width: 80,
                                //         alignment: Alignment.center,
                                //         decoration: BoxDecoration(
                                //             borderRadius:
                                //                 BorderRadius.circular(8.0),
                                //             color: Colors.green),
                                //         child: const Text("Sponsored",
                                //             style:
                                //                 TextStyle(color: Colors.white)),
                                //       ),
                                const SizedBox(height: 10),
                                description == null
                                    ? SizedBox()
                                    : Text(description,
                                        style: const TextStyle(
                                            color: Colors.black,
                                            fontSize: 14,
                                            fontWeight: FontWeight.w400)),
                                const SizedBox(height: 10),
                                productprice == null
                                    ? SizedBox()
                                    : Text(productprice,
                                        style: const TextStyle(
                                            color: Colors.black,
                                            fontSize: 14,
                                            fontWeight: FontWeight.w400)),
                                const SizedBox(height: 10),
                                Text("Security Deposit: INR $securitydeposit",
                                    style: const TextStyle(
                                        color: Colors.black,
                                        fontSize: 14,
                                        fontWeight: FontWeight.w400)),
                                const SizedBox(height: 10),
                                Divider(),
                                Text("Product Rating",
                                    style: const TextStyle(
                                        color: kPrimaryColor,
                                        fontSize: 18,
                                        fontWeight: FontWeight.w700)),
                                const SizedBox(height: 5),

                                SizedBox(
                                  child: RatingBar.builder(
                                    initialRating: prating,
                                    minRating: 1,
                                    direction: Axis.horizontal,
                                    allowHalfRating: true,
                                    itemCount: 5,
                                    itemSize: 20.0,
                                    itemPadding:
                                        EdgeInsets.symmetric(horizontal: 4.0),
                                    itemBuilder: (context, _) => Icon(
                                      Icons.star,
                                      color: Colors.amber,
                                    ),
                                    onRatingUpdate: (double value) {
                                      prating = value;
                                      log("p rating ---> $prating");
                                    },
                                  ),
                                ),
                                Divider(),
                                advertiserId.toString() != userId
                                    ? Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text("User Rating",
                                              style: const TextStyle(
                                                  color: kPrimaryColor,
                                                  fontSize: 18,
                                                  fontWeight: FontWeight.w700)),
                                          SizedBox(
                                            height: 5,
                                          ),
                                          SizedBox(
                                            child: RatingBar.builder(
                                              initialRating:
                                                  userRating.toDouble(),
                                              minRating: 1,
                                              direction: Axis.horizontal,
                                              allowHalfRating: true,
                                              itemCount: 5,
                                              itemSize: 20.0,
                                              itemPadding: EdgeInsets.symmetric(
                                                  horizontal: 4.0),
                                              itemBuilder: (context, _) => Icon(
                                                Icons.star,
                                                color: Colors.amber,
                                              ),
                                              onRatingUpdate: (rating) {
                                                userRating = rating;
                                                print(userRating);
                                              },
                                            ),
                                          ),
                                          SizedBox(
                                            height: 10,
                                          ),
                                          Container(
                                            alignment: Alignment.center,
                                            height: 40,
                                            width: size.width * 0.9,
                                            decoration: BoxDecoration(
                                              border: Border.all(
                                                  color: Colors.grey),
                                            ),
                                            child: TextField(
                                              controller: feedbackController,
                                              textAlign: TextAlign.center,
                                              decoration: InputDecoration(
                                                  border: InputBorder.none,
                                                  hintText:
                                                      "Give Your Feedback (Optional)"),
                                            ),
                                          ),
                                          SizedBox(
                                            height: 10,
                                          ),
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              InkWell(
                                                onTap: () {
                                                  if (userRating == 0) {
                                                    showToast(
                                                        "Please Give Rating !!");
                                                  } else {
                                                    giveRatingOrder();
                                                  }
                                                },
                                                child: Container(
                                                  alignment: Alignment.center,
                                                  height: 40,
                                                  width: size.width * 0.4,
                                                  decoration: BoxDecoration(
                                                      color: ksecondaryColor,
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              50)),
                                                  child: Text(
                                                    buttonLoader == true
                                                        ? "Please wait..."
                                                        : "Submit",
                                                    style: TextStyle(
                                                        color: Colors.white,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        fontSize: 16),
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      )
                                    : SizedBox()
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),
                        Card(
                          elevation: 4.0,
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  color: Color(0xFF012060),
                                  padding: EdgeInsets.all(8),
                                  child: Row(
                                    children: const [
                                      Text("Order Details",
                                          style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 16,
                                              fontWeight: FontWeight.w500)),
                                    ],
                                  ),
                                ),
                                // const Divider(
                                //     height: 5,
                                //     color: kPrimaryColor,
                                //     thickness: 2),
                                const SizedBox(height: 10),
                                Container(
                                  color: Colors.grey[200],
                                  padding: EdgeInsets.all(8),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      const Text("Quantity",
                                          style: TextStyle(
                                              color: Colors.black,
                                              fontSize: 14)),
                                      quantity == null || quantity == ""
                                          ? const SizedBox()
                                          : Text(quantity,
                                              style: TextStyle(
                                                  color: Colors.black,
                                                  fontSize: 14))
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 10),
                                Container(
                                  color: Colors.white,
                                  padding: EdgeInsets.only(left: 8, right: 8),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      const Text("Duration",
                                          style: TextStyle(
                                              color: Colors.black,
                                              fontSize: 14)),
                                      period == "" || period == null
                                          ? const SizedBox()
                                          : Text(
                                              "$period ${_getrenttype(period.toString(), renttype.toString())}",
                                              style: TextStyle(
                                                  color: Colors.black,
                                                  fontSize: 14)),
                                      //Text(period+" "+_getrenttype(renttypeid), style: TextStyle(color: Colors.black, fontSize: 14))
                                    ],
                                  ),
                                ),
                                // const SizedBox(height: 10),
                                // Row(
                                //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                //   children: [
                                //     const Text("Rent Type", style: TextStyle(color: Colors.black, fontSize: 14)),
                                //     negotiable.toString() == "1" ? Container(
                                //         height: 20,
                                //         width: 80,
                                //         alignment: Alignment.center,
                                //         decoration: BoxDecoration(
                                //           borderRadius: BorderRadius.circular(8.0),
                                //           color: Colors.green
                                //         ),
                                //       child: Text("Negotiable", style: TextStyle(color: Colors.white)),
                                //     ) : Container(
                                //       height: 20,
                                //       width: 65,
                                //       alignment: Alignment.center,
                                //       decoration: BoxDecoration(
                                //           borderRadius: BorderRadius.circular(8.0),
                                //           color: Colors.green
                                //       ),
                                //       child: const Text("Fixed", style: TextStyle(color: Colors.white)),
                                //     )
                                //   ],
                                // ),
                                const SizedBox(height: 10),
                                Container(
                                  color: Colors.grey[200],
                                  padding: EdgeInsets.all(8),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      const Text("Product Price",
                                          style: TextStyle(
                                              color: Colors.black,
                                              fontSize: 14)),
                                      productpeice == null
                                          ? const SizedBox()
                                          : Text(productpeice,
                                              style: TextStyle(
                                                  color: Colors.black,
                                                  fontSize: 14))
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 10),
                                Container(
                                  color: Colors.white,
                                  padding: EdgeInsets.only(left: 8, right: 8),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      const Text("Product Security",
                                          style: TextStyle(
                                              color: Colors.black,
                                              fontSize: 14)),
                                      productsecurity == null
                                          ? const SizedBox()
                                          : Text(productsecurity,
                                              style: TextStyle(
                                                  color: Colors.black,
                                                  fontSize: 14))
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 10),
                                Container(
                                  color: Colors.grey[200],
                                  padding: EdgeInsets.all(8),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      const Text("Order Amount",
                                          style: TextStyle(
                                              color: Colors.black,
                                              fontSize: 14)),
                                      offerammount == null
                                          ? const SizedBox()
                                          : Text(offerammount,
                                              style: const TextStyle(
                                                  color: Colors.black,
                                                  fontSize: 14))
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 10),
                                Container(
                                  color: Colors.white,
                                  padding: EdgeInsets.only(left: 8, right: 8),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      const Text("Total Rent",
                                          style: TextStyle(
                                              color: Colors.black,
                                              fontSize: 14)),
                                      totalrent == null
                                          ? const SizedBox()
                                          : Text(totalrent,
                                              style: const TextStyle(
                                                  color: Colors.black,
                                                  fontSize: 14))
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 10),
                                Container(
                                  color: Colors.grey[200],
                                  padding: EdgeInsets.all(8),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      const Text("Total Security",
                                          style: TextStyle(
                                              color: Colors.black,
                                              fontSize: 14)),
                                      totalsecurity == null
                                          ? const SizedBox()
                                          : Text(totalsecurity,
                                              style: const TextStyle(
                                                  color: Colors.black,
                                                  fontSize: 14))
                                    ],
                                  ),
                                ),
                                showConversionCharges
                                    ? Column(
                                        children: [
                                          SizedBox(
                                            height: 10,
                                          ),
                                          Container(
                                            color: Colors.white,
                                            padding: EdgeInsets.only(
                                                left: 8, right: 8),
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: [
                                                Text(
                                                    "Convenience Charge ($convenience_charge%)",
                                                    style: TextStyle(
                                                        color: Colors.black,
                                                        fontSize: 14)),
                                                Text(convenience_chargeValue,
                                                    style: TextStyle(
                                                        color: Colors.black,
                                                        fontSize: 14))
                                              ],
                                            ),
                                          ),
                                          SizedBox(
                                            height: 10,
                                          ),
                                        ],
                                      )
                                    : SizedBox(height: 10),
                                Container(
                                  color: Colors.grey[200],
                                  padding: EdgeInsets.all(8),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      const Text("Final Amount",
                                          style: TextStyle(
                                              color: Colors.black,
                                              fontSize: 14)),
                                      finalamount == null
                                          ? const SizedBox()
                                          : Text(finalamount,
                                              style: const TextStyle(
                                                  color: Colors.black,
                                                  fontSize: 14))
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 10),
                                Container(
                                  color: Colors.white,
                                  padding: EdgeInsets.only(left: 8, right: 8),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      const Text("Start Date",
                                          style: TextStyle(
                                              color: Colors.black,
                                              fontSize: 14)),
                                      startdate != null
                                          ? Text(
                                              // DateFormat("d/MMM/yy")
                                              //     .add_jm()
                                              //     .format(DateTime.parse(startdate
                                              //         .toString()
                                              //         .replaceAll("/", "-"))),
                                              startdate,
                                              style: const TextStyle(
                                                  color: Colors.black,
                                                  fontSize: 14))
                                          : const SizedBox(),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 10),
                                Container(
                                  color: Colors.grey[200],
                                  padding: EdgeInsets.all(8),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      const Text("End Date",
                                          style: TextStyle(
                                              color: Colors.black,
                                              fontSize: 14)),
                                      enddate == null
                                          ? const SizedBox()
                                          : Text(
                                              // DateFormat("d/MMM/yy")
                                              //     .add_jm()
                                              //     .format(DateTime.parse(
                                              //         enddate.toString())),
                                              enddate,
                                              style: const TextStyle(
                                                  color: Colors.black,
                                                  fontSize: 14))
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 10),
                                Container(
                                  color: Colors.white,
                                  padding: EdgeInsets.only(left: 8, right: 8),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      const Text("Status",
                                          style: TextStyle(
                                              color: Colors.black,
                                              fontSize: 14)),
                                      status == null
                                          ? const SizedBox()
                                          : Text((status),
                                              style: const TextStyle(
                                                  color: Colors.black,
                                                  fontSize: 14))
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 10),
                                Container(
                                  color: Colors.grey[200],
                                  padding: EdgeInsets.all(8),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      const Text("Created At",
                                          style: TextStyle(
                                              color: Colors.black,
                                              fontSize: 14)),
                                      createdAt == null
                                          ? const SizedBox()
                                          : Text(
                                              DateFormat("d/MMM/yy")
                                                  // .add_jm()
                                                  .format(DateTime.parse(
                                                      createdAt.toString())),
                                              style: const TextStyle(
                                                  color: Colors.black,
                                                  fontSize: 14))
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 10),
                                // const Divider(
                                //     height: 5,
                                //     color: kPrimaryColor,
                                //     thickness: 2),
                                // Container(
                                //   color: Color(0xFF012060),
                                //   padding: EdgeInsets.all(8),
                                //   child: Row(
                                //     children: [
                                //       Text("Product Info",
                                //           style: TextStyle(
                                //               color: Colors.white,
                                //               fontSize: 16,
                                //               fontWeight: FontWeight.w500)),
                                //     ],
                                //   ),
                                // ),
                                // const Divider(
                                //     height: 5,
                                //     color: kPrimaryColor,
                                //     thickness: 2),
                                // const SizedBox(height: 10),
                                // Container(
                                //   color: Colors.grey[200],
                                //   padding: EdgeInsets.all(8),
                                //   child: Row(
                                //     mainAxisAlignment:
                                //         MainAxisAlignment.spaceBetween,
                                //     children: [
                                //       const Text("Security (INR)",
                                //           style: TextStyle(
                                //               color: Colors.black,
                                //               fontSize: 14)),
                                //       securitydeposit == null
                                //           ? const SizedBox()
                                //           : Text(securitydeposit,
                                //               style: TextStyle(
                                //                   color: Colors.black,
                                //                   fontSize: 14))
                                //     ],
                                //   ),
                                // ),
                                // const SizedBox(height: 10),
                                // Container(
                                //   color: Colors.white,
                                //   padding: EdgeInsets.only(left: 8, right: 8),
                                //   child: Row(
                                //     mainAxisAlignment:
                                //         MainAxisAlignment.spaceBetween,
                                //     children: [
                                //       const Text("Quantity",
                                //           style: TextStyle(
                                //               color: Colors.black,
                                //               fontSize: 14)),
                                //       productqty == null || productqty == "null"
                                //           ? const Text("N/A",
                                //               style: TextStyle(
                                //                   color: Colors.black,
                                //                   fontSize: 14))
                                //           : Text(productqty.toString(),
                                //               style: TextStyle(
                                //                   color: Colors.black,
                                //                   fontSize: 14))
                                //     ],
                                //   ),
                                // ),
                                // const SizedBox(height: 10),
                                // Container(
                                //   color: Colors.grey[200],
                                //   padding: EdgeInsets.all(8),
                                //   child: Row(
                                //     mainAxisAlignment:
                                //         MainAxisAlignment.spaceBetween,
                                //     children: [
                                //       const Text("Currency",
                                //           style: TextStyle(
                                //               color: Colors.black,
                                //               fontSize: 14)),
                                //       currency == null
                                //           ? const SizedBox()
                                //           : Text(currency,
                                //               style: TextStyle(
                                //                   color: Colors.black,
                                //                   fontSize: 14))
                                //     ],
                                //   ),
                                // ),
                                // const SizedBox(height: 10),
                                // Container(
                                //   color: Colors.white,
                                //   padding: EdgeInsets.only(left: 8, right: 8),
                                //   child: Row(
                                //     mainAxisAlignment:
                                //         MainAxisAlignment.spaceBetween,
                                //     children: [
                                //       Expanded(
                                //         child: const Text("Rent\nPrices",
                                //             style: TextStyle(
                                //                 color: Colors.black,
                                //                 fontSize: 14)),
                                //       ),
                                //       Expanded(
                                //         flex: 2,
                                //         child: productprice == null
                                //             ? SizedBox()
                                //             : Text(productprice,
                                //                 maxLines: 2,
                                //                 textAlign: TextAlign.right,
                                //                 style: TextStyle(
                                //                     color: Colors.black,
                                //                     fontSize: 14)),
                                //       )
                                //     ],
                                //   ),
                                // ),
                                // const SizedBox(height: 10),
                                // Row(
                                //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                //   children: [
                                //     const Text("Rent Type", style: TextStyle(color: Colors.black, fontSize: 14)),
                                //       negotiable.toString() == "1" ? Container(
                                //       height: 20,
                                //       width: 80,
                                //       alignment: Alignment.center,
                                //       decoration: BoxDecoration(
                                //           borderRadius: BorderRadius.circular(8.0),
                                //           color: Colors.green
                                //       ),
                                //       child: Text("Negotiable", style: TextStyle(color: Colors.white)),
                                //     ) : Container(
                                //       height: 20,
                                //       width: 65,
                                //       alignment: Alignment.center,
                                //       decoration: BoxDecoration(
                                //           borderRadius: BorderRadius.circular(8.0),
                                //           color: Colors.green
                                //       ),
                                //       child: Text("Fixed", style: TextStyle(color: Colors.white)),
                                //     )
                                //   ],
                                // ),
                                const SizedBox(height: 10),
                                // const Divider(
                                //     height: 5,
                                //     color: kPrimaryColor,
                                //     thickness: 2),
                                Container(
                                  color: Color(0xFF012060),
                                  padding: EdgeInsets.all(8),
                                  child: Row(
                                    children: const [
                                      Text("Renter Details",
                                          style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 16,
                                              fontWeight: FontWeight.w500)),
                                    ],
                                  ),
                                ),
                                // const Divider(
                                //     height: 5,
                                //     color: kPrimaryColor,
                                //     thickness: 2),
                                const SizedBox(height: 10),
                                Container(
                                  color: Colors.grey[200],
                                  padding: EdgeInsets.all(8),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      const Text("Rentee",
                                          style: TextStyle(
                                              color: Colors.black,
                                              fontSize: 14)),
                                      name == null
                                          ? const SizedBox()
                                          : Text(name,
                                              style: TextStyle(
                                                  color: Colors.black,
                                                  fontSize: 14))
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 10),
                                Container(
                                  color: Colors.white,
                                  padding: EdgeInsets.only(left: 8, right: 8),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      const Text("Business Name",
                                          style: TextStyle(
                                              color: Colors.black,
                                              fontSize: 14)),
                                      businessname == null
                                          ? const SizedBox()
                                          : Text(businessname,
                                              style: const TextStyle(
                                                  color: Colors.black,
                                                  fontSize: 14))
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 10),
                                // Row(
                                //   mainAxisAlignment:
                                //       MainAxisAlignment.spaceBetween,
                                //   children: [
                                //     const Text("Address",
                                //         style: TextStyle(
                                //             color: Colors.black, fontSize: 14)),
                                //     SizedBox(
                                //         width: size.width * 0.60,
                                //         child: address == null
                                //             ? SizedBox()
                                //             : Text(address,
                                //                 textAlign: TextAlign.end,
                                //                 maxLines: 2,
                                //                 style: TextStyle(
                                //                     color: Colors.black,
                                //                     fontSize: 14)))
                                //   ],
                                // ),
                                const SizedBox(height: 5),
                              ],
                            ),
                          ),
                        )
                      ],
                    ),
            ),
          )),
    );
  }

  int productRating;
  double prating;
  int advertiserId;

  final feedbackController = TextEditingController();
  int orderIdForFeedback = 0;
  Future<void> _getofferdetailproduct() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _loading = true;
    });
    log("orderID--->${widget.orderId}");

    final body = {"order_id": widget.orderId};
    var response = await http.post(
        Uri.parse("${BASE_URL}order-details-by-orderid"),
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
      // print(data['Order Details']);
      setState(() {
        advertiserId = data['Order Details']['advertiser_id'];
        productimage = data['Image']['upload_base_path'] +
            data['Image']['file_name'].toString();
        productname = data['Product Details']['title'].toString();
        final document =
            parse(data['Product Details']['description'].toString());
        description = parse(document.body.text).documentElement.text.toString();
        boostpack = data['Product Details']['boost_package_status'].toString();
        securitydeposit = data['Product Details']['security'].toString();
        negotiable = data['Product Details']['negotiate'].toString();
        productqty = data['Product Details']['quantity'].toString();
        currency = data['Product Details']['currency'].toString();
        productRating = data['Product Details']['review'];
        log("Product Rating--->$productRating");
        prating = double.parse(productRating.toString());
        log("Product Rating--->$prating");
        orderIdForFeedback = data['Product Details']['id'];

        List temp = [];
        data['Product Details']['prices'].forEach((element) {
          if (element['price'] != null) {
            temp.add("INR ${element['price']} (${element['rent_type_name']})");
          }
        });

        productprice = temp.join("/").toString();

        //offer detail
        quantity = data['Order Details']['quantity'].toString();
        period = data['Order Details']['period'].toString();
        renttype = data['Order Details']['rent_type_name'].toString();
        productpeice = data['Order Details']['product_price'].toString();
        productsecurity = data['Order Details']['product_security'].toString();
        offerammount =
            data['Order Details']['final_product_selling_amount'].toString();
        totalrent = data['Order Details']['total_rent'].toString();
        totalsecurity = data['Order Details']['total_security'].toString();
        finalamount = data['order']['amount'].toString();
        startdate = data['Order Details']['start_date'].toString();
        enddate = data['Order Details']['end_date'].toString();
        status = data['order']['status'].toString();
        renttypeid = data['Order Details']['rent_type_id'].toString();
        //createdAt = data['Order Details']['created_at'].toString().split("T")[0].toString();
        createdAt = data['Order Details']['created_at'].toString();

        //Rentee Detail
        name = data['Additional Information']['name'].toString();
        businessname =
            data['Additional Information']['business_name'].toString();
        address =
            "${data['Additional Information']['address']}, ${data['Additional Information']['city_name']}, ${data['Additional Information']['state_name']}, ${data['Additional Information']['pincode']}";

        convenience_charge =
            data['Order Details']['convenience_charge'].toString();
        if (data['Order Details']['advertiser_id'].toString() ==
            prefs.getString('userid')) {
          showConversionCharges = false;
          var temp = (double.parse(convenience_charge) / 100) *
              (double.parse(totalrent) + double.parse(totalsecurity));
          finalamount = (double.parse(finalamount) - temp).toString();

          log("${finalamount}finalamount");
        } else {
          showConversionCharges = true;
          var temp = (double.parse(convenience_charge) / 100) *
              (double.parse(totalrent) + double.parse(totalsecurity));
          convenience_chargeValue = temp.toString();
        }
        print("showConversionCharges---$showConversionCharges");
      });
    } else {
      throw Exception('Failed to get data due to ${response.body}');
    }
  }

  Future giveRatingOrder() async {
    setState(() {
      buttonLoader = true;
    });
    var url = "${BASE_URL}order-rating";
    var body = {
      "product_rating": prating.toString(),
      "user_rating": userRating.toString(),
      "orderid": widget.orderIdForFeedback.toString(),
      "feedback": feedbackController.text.toString()
    };

    var response = await APIHelper.apiPostRequest(url, body);
    var result = jsonDecode(response);
    if (result['ErrorCode'] == 0) {
      setState(() {
        Navigator.pop(context, true);
      });
      showToast(result['ErrorMessage']);
      setState(() {
        buttonLoader = false;
      });
    } else {
      showToast(result['ErrorMessage']);
      setState(() {
        buttonLoader = false;
      });
      setState(() {
        buttonLoader = false;
      });
    }
  }
  // String _getStatus(String statusvalue) {
  //   if (statusvalue == "13") {
  //     return "Complete";
  //   } else if (statusvalue == "1") {
  //     return "Accepted";
  //   } else if (statusvalue == "3") {
  //     return "Pending";
  //   } else if (statusvalue == "6") {
  //     return "Active";
  //   } else if (statusvalue == "4") {
  //     return "Inactive";
  //   } else if (statusvalue == "2") {
  //     return "Rejected";
  //   } else {
  //     return "Approved";
  //   }
  // }

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
