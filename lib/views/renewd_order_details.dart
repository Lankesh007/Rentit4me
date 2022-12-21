import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:rentit4me_new/network/api.dart';
import 'package:rentit4me_new/themes/constant.dart';
import 'package:rentit4me_new/utils/dialog_utils.dart';
import 'package:rentit4me_new/widgets/api_helper.dart';

class OrderRenewdDetailsScreen extends StatefulWidget {
  final String renewalOrderId;
  const OrderRenewdDetailsScreen({this.renewalOrderId, Key key})
      : super(key: key);

  @override
  State<OrderRenewdDetailsScreen> createState() =>
      _OrderRenewdDetailsScreenState();
}

class _OrderRenewdDetailsScreenState extends State<OrderRenewdDetailsScreen> {
  double height;
  double width;
  String image;
  String adId;
  String productName;
  String description;
  String rentType;
  String securityDeposite;
  String rentStartDate;
  String rentEndDate;
  String currentSatus;
  int quantity;
  int duration;
  String price;
  String conviencevalue;
  String subTotal;
  String discount;
  String totalAmount;
  String rentee;
  String businessName;
  String orderId;
  String rentyoeName;
  String paymentType;
  String startDate;
  String endDate;
  String additionalName;
  String additionalBusinessName;
  String uploadBasePath;
  String currency;
  @override
  void initState() {
    getRenewalProductsDetails(widget.renewalOrderId);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    height = MediaQuery.of(context).size.height;
    width = MediaQuery.of(context).size.width;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Appcolors.primaryColor,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: Text(
          "Renewd Product Details",
          style: TextStyle(
              color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: ListView(
        children: [
          topWidget(),
          rentTypeWidget(),
          orderDetailsWidget(),
          renteeInformation(),
        ],
      ),
    );
  }

  Widget topWidget() {
    return Column(
      children: [
        Container(
          height: height * 0.4,
          width: width,
          decoration: BoxDecoration(
            image: DecorationImage(
                image: NetworkImage(devImage.toString() +
                    uploadBasePath.toString() +
                    image.toString()),
                fit: BoxFit.fill),
          ),
        ),
        SizedBox(
          height: 10,
        ),
        Container(
          alignment: Alignment.centerLeft,
          margin: const EdgeInsets.symmetric(horizontal: 5),
          child: Text(
            "Ad Id : $adId",
            style: TextStyle(
                color: Appcolors.secondaryColor,
                fontSize: 16,
                fontWeight: FontWeight.w600),
          ),
        ),
        SizedBox(
          height: 10,
        ),
        Container(
          alignment: Alignment.centerLeft,
          margin: const EdgeInsets.symmetric(horizontal: 5),
          child: Text(
            productName.toString(),
            style: TextStyle(
                color: Appcolors.secondaryColor,
                fontSize: 16,
                fontWeight: FontWeight.w600),
          ),
        ),
        SizedBox(height: 3),
        Html(data: description.toString()),
        SizedBox(height: 3),
        // Container(
        //   alignment: Alignment.centerLeft,
        //   margin: const EdgeInsets.symmetric(horizontal: 5),
        //   child: Text(
        //     "INR 2000 (Hourly) / INR 6000 (Days) / INR 8000 (Monthly) / INR 50000 (Yearly)",
        //     style: TextStyle(
        //         color: Colors.grey, fontSize: 16, fontWeight: FontWeight.w500),
        //   ),
        // ),
        Divider(
          thickness: 0.9,
        ),
      ],
    );
  }

  Widget rentTypeWidget() {
    return Column(
      children: [
        SizedBox(height: 3),
        SizedBox(
          height: height * 0.22,
          width: width * 0.99,
          child: Card(
            elevation: 5,
            child: Column(
              children: [
                SizedBox(height: 10),
                SizedBox(
                  height: 30,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                          margin: const EdgeInsets.symmetric(horizontal: 10),
                          child: Text(
                            "Rent Type",
                            // style: TextStyle(color: Colors.white),
                          )),
                      Container(
                          margin: const EdgeInsets.symmetric(horizontal: 10),
                          child: Text(
                            "$rentType",
                            // style: TextStyle(color: Colors.white),
                          )),
                    ],
                  ),
                ),
                Container(
                  height: 30,
                  color: Colors.grey[400],
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                          margin: const EdgeInsets.symmetric(horizontal: 10),
                          child: Text(
                            "Security Deposit",
                            style: TextStyle(fontSize: 16),
                          )),
                      Container(
                          margin: const EdgeInsets.symmetric(horizontal: 10),
                          child: Text(
                            "$currency $securityDeposite",
                            style: TextStyle(),
                          )),
                    ],
                  ),
                ),
                SizedBox(
                  height: 30,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                          margin: const EdgeInsets.symmetric(horizontal: 10),
                          child: Text(
                            "Rent Start Date",
                          )),
                      Container(
                          margin: const EdgeInsets.symmetric(horizontal: 10),
                          child: Text(
                            startDate.toString(),
                          )),
                    ],
                  ),
                ),
                Container(
                  height: 30,
                  color: Colors.grey[400],
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                          margin: const EdgeInsets.symmetric(horizontal: 10),
                          child: Text(
                            "Rent End Date",
                            style: TextStyle(fontSize: 16),
                          )),
                      Container(
                          margin: const EdgeInsets.symmetric(horizontal: 10),
                          child: Text(
                            endDate.toString(),
                            style: TextStyle(),
                          )),
                    ],
                  ),
                ),
                SizedBox(
                  height: 30,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                          margin: const EdgeInsets.symmetric(horizontal: 10),
                          child: Text(
                            "Current Status",
                          )),
                      Container(
                          margin: const EdgeInsets.symmetric(horizontal: 10),
                          child: Text(
                            "",
                          )),
                    ],
                  ),
                ),
             
             
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget orderDetailsWidget() {
    return Column(
      children: [
        SizedBox(
          height: 10,
        ),
        Divider(
          thickness: 0.9,
        ),
        Container(
          alignment: Alignment.centerLeft,
          margin: const EdgeInsets.symmetric(horizontal: 10),
          child: Text(
            "Order Details",
            style: TextStyle(
                color: Appcolors.secondaryColor,
                fontSize: 22,
                fontWeight: FontWeight.bold),
          ),
        ),
        Divider(
          thickness: 0.9,
        ),
        SizedBox(
          height: height * 0.33,
          child: Column(
            children: [
              SizedBox(
                height: 30,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                        margin: const EdgeInsets.symmetric(horizontal: 10),
                        child: Text(
                          "Product Name",
                        )),
                    Container(
                        margin: const EdgeInsets.symmetric(horizontal: 10),
                        child: Text(
                          productName.toString(),
                        )),
                  ],
                ),
              ),
              Container(
                height: 30,
                color: Appcolors.secondaryColor,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                        margin: const EdgeInsets.symmetric(horizontal: 10),
                        child: Text(
                          "Quantity",
                          style: TextStyle(color: Colors.white),
                        )),
                    Container(
                        margin: const EdgeInsets.symmetric(horizontal: 10),
                        child: Text(
                          quantity.toString(),
                          style: TextStyle(color: Colors.white),
                        )),
                  ],
                ),
              ),
              SizedBox(
                height: 30,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                        margin: const EdgeInsets.symmetric(horizontal: 10),
                        child: Text(
                          "Duration",
                          // style: TextStyle(color: Colors.white),
                        )),
                    Container(
                        margin: const EdgeInsets.symmetric(horizontal: 10),
                        child: Text(
                          duration.toString(),
                          // style: TextStyle(color: Colors.white),
                        )),
                  ],
                ),
              ),
              Container(
                height: 30,
                color: Appcolors.secondaryColor,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                        margin: const EdgeInsets.symmetric(horizontal: 10),
                        child: Text(
                          "Security",
                          style: TextStyle(color: Colors.white),
                        )),
                    Container(
                        margin: const EdgeInsets.symmetric(horizontal: 10),
                        child: Text(
                          securityDeposite.toString(),
                          style: TextStyle(color: Colors.white),
                        )),
                  ],
                ),
              ),
              SizedBox(
                height: 30,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                        margin: const EdgeInsets.symmetric(horizontal: 10),
                        child: Text(
                          "Price",
                          // style: TextStyle(color: Colors.white),
                        )),
                    Container(
                        margin: const EdgeInsets.symmetric(horizontal: 10),
                        child: Text(
                          "$currency "+price.toString(),
                          // style: TextStyle(color: Colors.white),
                        )),
                  ],
                ),
              ),
              Container(
                height: 30,
                color: Appcolors.secondaryColor,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                        margin: const EdgeInsets.symmetric(horizontal: 10),
                        child: Text(
                          "Convenience (10%)",
                          style: TextStyle(color: Colors.white),
                        )),
                    Container(
                        margin: const EdgeInsets.symmetric(horizontal: 10),
                        child: Text(
                          conviencevalue.toString(),
                          style: TextStyle(color: Colors.white),
                        )),
                  ],
                ),
              ),
              SizedBox(
                height: 30,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                        margin: const EdgeInsets.symmetric(horizontal: 10),
                        child: Text(
                          "Sub Total",
                          // style: TextStyle(color: Colors.white),
                        )),
                    Container(
                        margin: const EdgeInsets.symmetric(horizontal: 10),
                        child: Text(
                          "$currency $subTotal",
                          // style: TextStyle(color: Colors.white),
                        )),
                  ],
                ),
              ),
              Container(
                height: 30,
                color: Appcolors.secondaryColor,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                        margin: const EdgeInsets.symmetric(horizontal: 10),
                        child: Text(
                          "Discount",
                          style: TextStyle(color: Colors.white),
                        )),
                    Container(
                        margin: const EdgeInsets.symmetric(horizontal: 10),
                        child: Text(
                          "$currency $discount",
                          style: TextStyle(color: Colors.white),
                        )),
                  ],
                ),
              ),
              SizedBox(
                height: 30,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                        margin: const EdgeInsets.symmetric(horizontal: 10),
                        child: Text(
                          "Total Amount",
                          // style: TextStyle(color: Colors.white),
                        )),
                    Container(
                        margin: const EdgeInsets.symmetric(horizontal: 10),
                        child: Text(
                          "$currency $totalAmount",
                          // style: TextStyle(color: Colors.white),
                        )),
                  ],
                ),
              ),
            ],
          ),
        )
      ],
    );
  }

  Widget renteeInformation() {
    return Column(
      children: [
        SizedBox(
          height: 10,
        ),
        Divider(
          thickness: 0.9,
        ),
        Container(
          alignment: Alignment.centerLeft,
          margin: const EdgeInsets.symmetric(horizontal: 10),
          child: Text(
            "Rentee Information",
            style: TextStyle(
                color: Appcolors.secondaryColor,
                fontSize: 22,
                fontWeight: FontWeight.bold),
          ),
        ),
        Divider(
          thickness: 0.9,
        ),
        SizedBox(
          height: height * 0.1,
          child: Column(
            children: [
              SizedBox(
                height: 30,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                        margin: const EdgeInsets.symmetric(horizontal: 10),
                        child: Text(
                          "Rentee",
                        )),
                    Container(
                        margin: const EdgeInsets.symmetric(horizontal: 10),
                        child: Text(
                          "$additionalName",
                        )),
                  ],
                ),
              ),
              Container(
                height: 30,
                color: Appcolors.secondaryColor,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                        margin: const EdgeInsets.symmetric(horizontal: 10),
                        child: Text(
                          "Business Name",
                          style: TextStyle(color: Colors.white),
                        )),
                    Container(
                        margin: const EdgeInsets.symmetric(horizontal: 10),
                        child: Text(
                          "$additionalBusinessName",
                          style: TextStyle(color: Colors.white),
                        )),
                  ],
                ),
              ),
            ],
          ),
        )
      ],
    );
  }

// -----------------API CALL--------------//

  Future getRenewalProductsDetails(renewOrderID) async {
    var url = "${BASE_URL}renewed-order-details";
    var body = {
      "renewed_order_id": renewOrderID,
    };
    var response = await APIHelper.apiPostRequest(url, body);
    var result = jsonDecode(response);

    log("response--->$result");

    if (result['ErrorCode'] == 0) {
      setState(() {
        currency = result['Response']['posted_ad']['currency'];

        adId = result['Response']['posted_ad']['ad_id'];
        orderId = result['Response']['renewed_order_details']['order_id'];
        rentyoeName =
            result['Response']['renewed_order_details']['rent_type_name'];
        duration = result['Response']['renewed_order_details']['period'];
        price = result['Response']['renewed_order_details']['product_price'];
        securityDeposite =
            result['Response']['renewed_order_details']['product_security'];
        quantity = result['Response']['renewed_order_details']['quantity'];
        conviencevalue =
            result['Response']['renewed_order_details']['convenience_fee'];
        discount = result['Response']['renewed_order_details']['discount'];
        if(discount==null){
          discount="";

        }else{
          discount;
        }
        subTotal = result['Response']['renewed_order_details']['sub_total'];
        totalAmount=result['Response']['renewed_order_details']['amount'];
        paymentType =
            result['Response']['renewed_order_details']['payment_type'];
        startDate = result['Response']['renewed_order_details']['start_date'];
        endDate = result['Response']['renewed_order_details']['end_date'];
        productName = result['Response']['posted_ad']['title'];
        description = result['Response']['posted_ad']['description'];
        additionalName = result['Response']['additional_details']['name'];
        additionalBusinessName =
            result['Response']['additional_details']['business_name'];

        image = result['Response']['image']['file_name'];
        uploadBasePath = result['Response']['image']['upload_base_path'];
        rentType = result['Response']['posted_ad']['negotiate'];
        if (rentType == "1") {
          rentType = "Negotiable";
        } else {
          rentType = "Non-Negiotiable";
        }
      });
    } else {
      showToast(result['ErrorMessage']);
    }
  }
}
