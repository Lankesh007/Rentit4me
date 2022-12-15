import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';

import 'package:rentit4me_new/network/api.dart';
import 'package:rentit4me_new/themes/constant.dart';
import 'package:rentit4me_new/utils/dialog_utils.dart';
import 'package:rentit4me_new/views/order_renew_payment_screen.dart';
import 'package:rentit4me_new/widgets/api_helper.dart';

class OrderRenewScreen extends StatefulWidget {
  final String orderId;
  const OrderRenewScreen({this.orderId, Key key}) : super(key: key);

  @override
  State<OrderRenewScreen> createState() => _OrderRenewScreenState();
}

class _OrderRenewScreenState extends State<OrderRenewScreen> {
  double height;
  double width;
  String rentTypeName;
  String listedPrice;
  String securityDeposit;
  int quantity;
  double totalh;
  String totalRent;
  String totalSecurity;
  String convinenceCharge;
  String finalAmount;
  String dropdownvalue ;
  int hours;
  int days;
  double totalR;
  double totalP;
  double finalPrices;
  String productName;
  final enterHoursController = TextEditingController();
  List orderPriceList = [];
  int rentTypeId;
  var items = [
    'hourly',
    'Days',
  ];
  int dropdownId;
  int dropdownPrice;
  @override
  void initState() {
    createRenewOrderData();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    width = MediaQuery.of(context).size.width;
    height = MediaQuery.of(context).size.height;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Order Renew ",
          style: TextStyle(
              color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
        ),
      ),
      body: ListView(
        children: [
          Column(
            children: [
              renewWidget(),
            ],
          )
        ],
      ),
    );
  }

  Widget renewWidget() {
    return SizedBox(
      height: height * 0.9,
      width: width * 0.99,
      child: Card(
        elevation: 5,
        child: Column(
          children: [
            SizedBox(
              height: 10,
            ),
            Container(
                margin: const EdgeInsets.symmetric(horizontal: 10),
                alignment: Alignment.centerLeft,
                child: Text(
                  "Renew",
                  style: TextStyle(color: Colors.deepOrange, fontSize: 18),
                )),
            Divider(),
            SizedBox(
              height: 10,
            ),
            Container(
              height: 45,
              alignment: Alignment.centerLeft,
              margin: const EdgeInsets.symmetric(horizontal: 10),
              child: InputDecorator(
                decoration: InputDecoration(
                    fillColor: Colors.white,
                    enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.deepOrange),
                        borderRadius: BorderRadius.circular(15)),
                    filled: true,
                    // labelText: "Select",
                    isDense: true,
                    contentPadding: EdgeInsets.all(10),
                    border: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.deepOrange),
                    )),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton(
                    underline: const SizedBox(),
                    // Initial Value
                    value: dropdownvalue,
                    // Down Arrow Icon
                    // Array list of items

                    items: orderPriceList.map((items) {
                      setState(() {});
                      return DropdownMenuItem(
                        onTap: () {
                          setState(() {
                            dropdownId = items['id'];
                            dropdownPrice = items['price'];
                            rentTypeId=items['rent_type_id'];
                            log("price--->$dropdownPrice+$dropdownId");
                            totalRent = "";
                            totalR = 0;
                            totalP = 0;
                            finalPrices = 0;
                            finalAmount = "";
                            enterHoursController.clear();
                          });
                        },
                        value: items['rent_type_name'],
                        child: SizedBox(
                            height: height * 0.09,
                            width: width * 0.72,
                            child: Container(
                                margin:
                                    const EdgeInsets.symmetric(horizontal: 10),
                                alignment: Alignment.centerLeft,
                                child: Text(items['rent_type_name'].toString()))),
                      );
                    }).toList(),
                    // After selecting the desired option,it will
                    // change button value to selected value
                    onChanged: (newValue) {
                      setState(() {
                        dropdownvalue = newValue.toString();
                        log("dropdown--->$dropdownvalue");
                      });
                    },
                  ),
                ),
              ),
            ),
            Container(),
            SizedBox(
              height: 10,
            ),
            Container(
                height: 45,
                width: width * 0.92,
                decoration: BoxDecoration(
                    border:
                        Border.all(width: 1, color: Colors.deepOrangeAccent),
                    borderRadius: BorderRadius.all(Radius.circular(12))),
                child: Padding(
                  padding: const EdgeInsets.only(left: 10.0),
                  child: TextFormField(
                    readOnly: true,
                    decoration: InputDecoration(
                        border: InputBorder.none,
                        hintText: dropdownPrice == null || dropdownPrice == 0
                            ? "Listed Price: $listedPrice"
                            : "Listed Price: $dropdownPrice"),
                  ),
                )),
            SizedBox(
              height: 10,
            ),
            Container(
                height: 45,
                width: width * 0.92,
                decoration: BoxDecoration(
                    border:
                        Border.all(width: 1, color: Colors.deepOrangeAccent),
                    borderRadius: BorderRadius.all(Radius.circular(12))),
                child: Padding(
                  padding: const EdgeInsets.only(left: 10.0),
                  child: TextFormField(
                    readOnly: true,
                    decoration: InputDecoration(
                        border: InputBorder.none,
                        hintText: "Security Deposit: $securityDeposit"),
                  ),
                )),
            SizedBox(
              height: 10,
            ),
            Container(
                height: 45,
                width: width * 0.92,
                decoration: BoxDecoration(
                    border:
                        Border.all(width: 1, color: Colors.deepOrangeAccent),
                    borderRadius: BorderRadius.all(Radius.circular(12))),
                child: Padding(
                  padding: const EdgeInsets.only(left: 10.0),
                  child: TextFormField(
                    readOnly: true,
                    decoration: InputDecoration(
                        border: InputBorder.none,
                        hintText: "Quantity: $quantity"),
                  ),
                )),
            SizedBox(
              height: 10,
            ),
            Container(
                height: 45,
                width: width * 0.92,
                decoration: BoxDecoration(
                    border:
                        Border.all(width: 1, color: Colors.deepOrangeAccent),
                    borderRadius: BorderRadius.all(Radius.circular(12))),
                child: Padding(
                  padding: const EdgeInsets.only(left: 10.0),
                  child: TextFormField(
                    keyboardType: TextInputType.number,
                    controller: enterHoursController,
                    onChanged: (value) async {
                      setState(() {
                        totalh = double.parse(quantity.toString()) *
                            double.parse(enterHoursController.text);
                        totalRent == "" || totalRent == null
                            ? totalR =
                                totalh * double.parse(dropdownPrice.toString())
                            : totalR = totalh * double.parse(listedPrice);
                        totalP = totalR * 10 / 100;
                        finalPrices = totalR + totalP;
                      });
                    },
                    decoration: InputDecoration(
                        border: InputBorder.none,
                        hintText: dropdownvalue == "Days"
                            ? "Enter Days :"
                            : finalAmount == ""
                                ? "Enter Hours: "
                                : "Enter Hours: $hours"),
                  ),
                )),
            SizedBox(
              height: 10,
            ),
            Container(
                height: 45,
                width: width * 0.92,
                decoration: BoxDecoration(
                    border:
                        Border.all(width: 1, color: Colors.deepOrangeAccent),
                    borderRadius: BorderRadius.all(Radius.circular(12))),
                child: Padding(
                  padding: const EdgeInsets.only(left: 10.0),
                  child: TextFormField(
                    readOnly: true,
                    decoration: InputDecoration(
                        border: InputBorder.none,
                        hintText: totalR == null || totalR == 0
                            ? "Total Rent: $totalRent"
                            : "Total Rent: $totalR"),
                  ),
                )),
            SizedBox(
              height: 10,
            ),
            Container(
                height: 45,
                width: width * 0.92,
                decoration: BoxDecoration(
                    border:
                        Border.all(width: 1, color: Colors.deepOrangeAccent),
                    borderRadius: BorderRadius.all(Radius.circular(12))),
                child: Padding(
                  padding: const EdgeInsets.only(left: 10.0),
                  child: TextFormField(
                    readOnly: true,
                    decoration: InputDecoration(
                        border: InputBorder.none,
                        hintText: "Total Security: $totalSecurity"),
                  ),
                )),
            SizedBox(
              height: 10,
            ),
            Container(
                height: 45,
                width: width * 0.92,
                decoration: BoxDecoration(
                    border:
                        Border.all(width: 1, color: Colors.deepOrangeAccent),
                    borderRadius: BorderRadius.all(Radius.circular(12))),
                child: Padding(
                  padding: const EdgeInsets.only(left: 10.0),
                  child: TextFormField(
                    readOnly: true,
                    decoration: InputDecoration(
                        border: InputBorder.none,
                        hintText: totalP == null || totalP == 0
                            ? "Convenience Charge (10%): $convinenceCharge"
                            : "Convenience Charge (10%): $totalP"),
                  ),
                )),
            SizedBox(
              height: 10,
            ),
            Container(
                height: 45,
                width: width * 0.92,
                decoration: BoxDecoration(
                    border:
                        Border.all(width: 1, color: Colors.deepOrangeAccent),
                    borderRadius: BorderRadius.all(Radius.circular(12))),
                child: Padding(
                  padding: const EdgeInsets.only(left: 10.0),
                  child: TextFormField(
                    readOnly: true,
                    decoration: InputDecoration(
                        border: InputBorder.none,
                        hintText: finalPrices == 0 || finalPrices == null
                            ? "Final Amount: $finalAmount"
                            : "Final Amount: $finalPrices"),
                  ),
                )),
            SizedBox(
              height: 30,
            ),
            renewButtonWidget(),
          ],
        ),
      ),
    );
  }

  Widget renewButtonWidget() {
    return InkWell(
      onTap: () {
        if (enterHoursController.text.isEmpty && finalAmount == "") {
          showToast("Hours And Days is Required !!");
        } else {
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => OrderRenewPaymentScreen(
                        convinenceCharge: totalP == 0 || totalP == null
                            ? convinenceCharge.toString()
                            : totalP.toString(),
                        duration: enterHoursController.text,
                        productName: productName.toString(),
                        productPrice: listedPrice.toString(),
                        quantity: quantity.toString(),
                        subTotal: totalR == 0 || totalR == null
                            ? totalRent.toString()
                            : totalR.toString(),
                        totalAmount: finalPrices == 0 || finalPrices == null
                            ? finalAmount.toString()
                            : finalPrices.toString(),
                        orderId: widget.orderId.toString(),
                        rentType: rentTypeId.toString(),
                      )));
        }
      },
      child: Container(
        alignment: Alignment.center,
        height: 50,
        width: width * 0.8,
        decoration: BoxDecoration(
            color: Appcolors.primaryColor, borderRadius: BorderRadius.circular(100)),
        child: Text(
          "RENEW",
          style: TextStyle(
              color: Colors.white, fontSize: 18, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }

  Future createRenewOrderData() async {
    var url = "${BASE_URL}post-ad/renew/create";
    var body = {
      "orderid": widget.orderId,
    };
    log("body--->$body");
    var response = await APIHelper.apiPostRequest(url, body);
    var result = jsonDecode(response);
    if (result['ErrorCode'] == 0) {
      setState(() {
        orderPriceList.addAll(result["Response"]["data"]['prices']);
        rentTypeName = result["Response"]["data"]['rent_type_name'];
        rentTypeId = result["Response"]["data"]['rent_type_id'];
        dropdownvalue=rentTypeName;
        log("dropdown value--->$dropdownvalue");
        listedPrice = result["Response"]["data"]['product_price'];
        securityDeposit = result["Response"]["data"]['product_security'];
        totalSecurity = result["Response"]["data"]['total_security'];
        totalRent = result["Response"]["data"]['total_rent'];
        quantity = result["Response"]["data"]['quantity'];
        convinenceCharge = result["Response"]["data"]['convenience_charge'];
        finalAmount = result["Response"]["data"]['amount'];
        hours = result["Response"]["data"]['period'];
        // days= result["Response"]["data"]['amount'];
        totalR = double.parse(totalRent);
        productName = result["Response"]['posted_ad']['title'];
      });
    }
  }
}
