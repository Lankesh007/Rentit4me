// ignore_for_file: prefer_const_constructors, use_build_context_synchronously, prefer_const_literals_to_create_immutables

import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:rentit4me_new/network/api.dart';
import 'package:rentit4me_new/themes/constant.dart';
import 'package:rentit4me_new/views/add_pickup_address.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class ShipRocketPlaceOrder extends StatefulWidget {
  String id;
  ShipRocketPlaceOrder({this.id});
  @override
  _ShipRocketPlaceOrderState createState() => _ShipRocketPlaceOrderState();
}

class _ShipRocketPlaceOrderState extends State<ShipRocketPlaceOrder> {
  TextEditingController pickupLocation = TextEditingController();
  TextEditingController shippingAddress = TextEditingController();
  TextEditingController subTotal = TextEditingController();
  TextEditingController length = TextEditingController();
  TextEditingController breadth = TextEditingController();
  TextEditingController height = TextEditingController();
  TextEditingController weight = TextEditingController();

  GlobalKey<FormState> form = GlobalKey<FormState>();

  int pickupLocationValue;
  String pickupLocationName;
  List pickupLocationList = [];
  bool isLoading = true;
  Future<List> getPickupLocation() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    final body = {
      "id": widget.id.toString(),
      "userid": prefs.getString('userid').toString()
    };
    var response = await http.post(
        Uri.parse(BASE_URL + "shiprocket-create-order"),
        body: jsonEncode(body),
        headers: {
          "Accept": "application/json",
          'Content-Type': 'application/json'
        });
    print(jsonDecode(response.body)['Response']['locations']);
    if (jsonDecode(response.body)['ErrorCode'] == 0) {
      setState(() {
        shippingAddress.text = jsonDecode(response.body)['Response']
                ['Shipping Address']
            .toString();

        subTotal.text =
            jsonDecode(response.body)['Response']['order']['amount'].toString();
      });
      return jsonDecode(response.body)['Response']['locations'];
    }
    return [];
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getPickupLocation().then((value) {
      if (value.length > 0) {
        setState(() {
          pickupLocationList.clear();
          pickupLocationList.addAll(value);
          pickupLocationValue =
              int.parse(pickupLocationList[0]['id'].toString());
          pickupLocationName =
              pickupLocationList[0]['pickup_location'].toString();
        });
      }
      setState(() {
        isLoading = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 2.0,
        leading: InkWell(
            onTap: () {
              Navigator.of(context).pop();
            },
            child: const Icon(Icons.arrow_back, color: kPrimaryColor)),
        title: Text("Place Shiprocket Order",
            style: TextStyle(color: kPrimaryColor)),
        centerTitle: true,
      ),
      body: ModalProgressHUD(
        inAsyncCall: isLoading,
        child: Padding(
          padding: const EdgeInsets.all(15),
          child: SingleChildScrollView(
            child: Form(
              key: form,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                          child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: ElevatedButton(
                            onPressed: () async {
                              setState(() {
                                isLoading = true;
                              });
                              SharedPreferences prefs =
                                  await SharedPreferences.getInstance();

                              var response = await http.post(
                                  Uri.parse(
                                      BASE_URL + "get-shiprocket-addresses"),
                                  headers: {
                                    "Accept": "application/json",
                                    'Content-Type': 'application/json'
                                  },
                                  body: jsonEncode({
                                    "userid":
                                        prefs.getString('userid').toString()
                                  }));

                              setState(() {
                                isLoading = false;
                              });
                              if (jsonDecode(response.body)['ErrorCode'] == 0) {
                                List add =
                                    jsonDecode(response.body)['Response'];
                                await showModalBottomSheet(
                                    shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.vertical(
                                            top: Radius.circular(20.0))),
                                    backgroundColor: Colors.white,
                                    context: context,
                                    isScrollControlled: true,
                                    builder: (context) => SizedBox(
                                        height:
                                            MediaQuery.of(context).size.height /
                                                1.5,
                                        child: Padding(
                                            padding: const EdgeInsets.all(20),
                                            child: SingleChildScrollView(
                                                child: Column(children: [
                                              Text(
                                                "Select pickup location",
                                                style: TextStyle(
                                                    fontSize: 18,
                                                    fontWeight:
                                                        FontWeight.bold),
                                              ),
                                              SizedBox(
                                                height: 20,
                                              ),
                                              Column(
                                                children: add
                                                    .map((e) => ListTile(
                                                          onTap: () {
                                                            setState(() {
                                                              pickupLocationValue =
                                                                  int.parse(e[
                                                                          'id']
                                                                      .toString());
                                                            });
                                                            Navigator.of(
                                                                    context)
                                                                .pop();
                                                          },
                                                          title: Text(
                                                            e['pickup_location']
                                                                .toString(),
                                                            style: TextStyle(
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold),
                                                          ),
                                                          subtitle: Text(
                                                              "${e['address']}, ${e['address_2']}, ${e['city']}, ${e['state']}, ${e['pin_code']}, ${e['country']}"),
                                                        ))
                                                    .toList(),
                                              )
                                            ])))));
                              } else {
                                showToast("No pickup location found");
                              }
                            },
                            child: Text(
                              "View Pickup Address",
                              textAlign: TextAlign.center,
                            )),
                      )),
                      Expanded(
                          child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: ElevatedButton(
                            onPressed: () {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) =>
                                          AddPickUpAddress())).then((value) {
                                setState(() {
                                  isLoading = true;
                                });
                                getPickupLocation().then((value) {
                                  setState(() {
                                    pickupLocationList.clear();
                                    pickupLocationList.addAll(value);
                                    pickupLocationValue = int.parse(
                                        pickupLocationList[0]['id'].toString());
                                    pickupLocationName = pickupLocationList[0]
                                            ['pickup_location']
                                        .toString();
                                    isLoading = false;
                                  });
                                });
                              });
                            },
                            child: Text(
                              "Add Pickup Address",
                              textAlign: TextAlign.center,
                            )),
                      ))
                    ],
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  pickupLocationList.length == 0
                      ? Center(
                          child: Text("Please add pickup location"),
                        )
                      : Column(
                          children: [
                            Text(
                              "Enter details for shipping address",
                              style: TextStyle(
                                  fontSize: 20, fontWeight: FontWeight.bold),
                            ),
                            SizedBox(
                              height: 15,
                            ),
                            FormField(
                              builder: (FormFieldState state) {
                                return InputDecorator(
                                  decoration: InputDecoration(
                                      fillColor: Colors.white,
                                      filled: true,
                                      isDense: true,
                                      contentPadding: EdgeInsets.all(10),
                                      border: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(5.0))),
                                  child: DropdownButtonHideUnderline(
                                    child: DropdownButton(
                                      isExpanded: true,
                                      value: pickupLocationValue,
                                      isDense: true,
                                      onChanged: (newValue) {
                                        setState(() {
                                          pickupLocationValue = newValue;
                                          pickupLocationList.forEach((element) {
                                            if (newValue ==
                                                int.parse(
                                                    element['id'].toString())) {
                                              pickupLocationName =
                                                  element['pickup_location']
                                                      .toString();
                                            }
                                          });
                                        });
                                      },
                                      items: pickupLocationList.map((value) {
                                        return DropdownMenuItem(
                                            value: value['id'],
                                            child: Text(value['pickup_location']
                                                .toString()));
                                      }).toList(),
                                    ),
                                  ),
                                );
                              },
                            ),
                            SizedBox(
                              height: 15,
                            ),
                            TextFormField(
                              // validator: (value) {
                              //   if (value.isEmpty)
                              //     return "Required Field";
                              //   else
                              //     return null;
                              // },
                              // readOnly: true,
                              controller: shippingAddress,
                              textCapitalization: TextCapitalization.words,
                              style: TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.w500),
                              decoration: InputDecoration(
                                border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10)),
                                contentPadding: EdgeInsets.all(10),
                                focusedBorder: OutlineInputBorder(
                                    borderSide: BorderSide(color: Colors.black),
                                    borderRadius: BorderRadius.circular(10)),
                                labelText: "Shipping Address",
                                labelStyle: TextStyle(
                                    color: Colors.black,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w300),
                              ),
                            ),
                            SizedBox(
                              height: 30,
                            ),
                            Text("Enter details for Item",
                                style: TextStyle(
                                    fontSize: 20, fontWeight: FontWeight.bold)),
                            SizedBox(
                              height: 15,
                            ),
                            TextFormField(
                              // validator: (value) {
                              //   if (value.isEmpty)
                              //     return "Required Field";
                              //   else
                              //     return null;
                              // },
                              readOnly: true,
                              controller: subTotal,
                              textCapitalization: TextCapitalization.words,
                              style: TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.w500),
                              decoration: InputDecoration(
                                border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10)),
                                contentPadding: EdgeInsets.all(10),
                                focusedBorder: OutlineInputBorder(
                                    borderSide: BorderSide(color: Colors.black),
                                    borderRadius: BorderRadius.circular(10)),
                                labelText: "Sub Total",
                                labelStyle: TextStyle(
                                    color: Colors.black,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w300),
                              ),
                            ),
                            SizedBox(
                              height: 15,
                            ),
                            TextFormField(
                              validator: (value) {
                                if (value.isEmpty)
                                  return "Required Field";
                                else
                                  return null;
                              },
                              controller: length,
                              inputFormatters: [
                                FilteringTextInputFormatter.allow(
                                    RegExp(r"[0-9.]")),
                                TextInputFormatter.withFunction(
                                    (oldValue, newValue) {
                                  try {
                                    final text = newValue.text;
                                    if (text.isNotEmpty) double.parse(text);
                                    return newValue;
                                  } catch (e) {}
                                  return oldValue;
                                }),
                              ],
                              keyboardType: TextInputType.numberWithOptions(
                                  decimal: true),
                              textCapitalization: TextCapitalization.words,
                              style: TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.w500),
                              decoration: InputDecoration(
                                border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10)),
                                contentPadding: EdgeInsets.all(10),
                                focusedBorder: OutlineInputBorder(
                                    borderSide: BorderSide(color: Colors.black),
                                    borderRadius: BorderRadius.circular(10)),
                                labelText:
                                    "Length (in cm. Must be more than 0.5)",
                                labelStyle: TextStyle(
                                    color: Colors.black,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w300),
                              ),
                            ),
                            SizedBox(
                              height: 15,
                            ),
                            TextFormField(
                              validator: (value) {
                                if (value.isEmpty)
                                  return "Required Field";
                                else
                                  return null;
                              },
                              controller: breadth,
                              inputFormatters: [
                                FilteringTextInputFormatter.allow(
                                    RegExp(r"[0-9.]")),
                                TextInputFormatter.withFunction(
                                    (oldValue, newValue) {
                                  try {
                                    final text = newValue.text;
                                    if (text.isNotEmpty) double.parse(text);
                                    return newValue;
                                  } catch (e) {}
                                  return oldValue;
                                }),
                              ],
                              keyboardType: TextInputType.numberWithOptions(
                                  decimal: true),
                              textCapitalization: TextCapitalization.words,
                              style: TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.w500),
                              decoration: InputDecoration(
                                border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10)),
                                contentPadding: EdgeInsets.all(10),
                                focusedBorder: OutlineInputBorder(
                                    borderSide: BorderSide(color: Colors.black),
                                    borderRadius: BorderRadius.circular(10)),
                                labelText:
                                    "Breadth (in cm. Must be more than 0.5)",
                                labelStyle: TextStyle(
                                    color: Colors.black,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w300),
                              ),
                            ),
                            SizedBox(
                              height: 15,
                            ),
                            TextFormField(
                              validator: (value) {
                                if (value.isEmpty)
                                  return "Required Field";
                                else
                                  return null;
                              },
                              controller: height,
                              inputFormatters: [
                                FilteringTextInputFormatter.allow(
                                    RegExp(r"[0-9.]")),
                                TextInputFormatter.withFunction(
                                    (oldValue, newValue) {
                                  try {
                                    final text = newValue.text;
                                    if (text.isNotEmpty) double.parse(text);
                                    return newValue;
                                  } catch (e) {}
                                  return oldValue;
                                }),
                              ],
                              keyboardType: TextInputType.numberWithOptions(
                                  decimal: true),
                              textCapitalization: TextCapitalization.words,
                              style: TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.w500),
                              decoration: InputDecoration(
                                border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10)),
                                contentPadding: EdgeInsets.all(10),
                                focusedBorder: OutlineInputBorder(
                                    borderSide: BorderSide(color: Colors.black),
                                    borderRadius: BorderRadius.circular(10)),
                                labelText:
                                    "Height (in cm. Must be more than 0.5)",
                                labelStyle: TextStyle(
                                    color: Colors.black,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w300),
                              ),
                            ),
                            SizedBox(
                              height: 15,
                            ),
                            TextFormField(
                              validator: (value) {
                                if (value.isEmpty)
                                  return "Required Field";
                                else
                                  return null;
                              },
                              controller: weight,
                              inputFormatters: [
                                FilteringTextInputFormatter.allow(
                                    RegExp(r"[0-9.]")),
                                TextInputFormatter.withFunction(
                                    (oldValue, newValue) {
                                  try {
                                    final text = newValue.text;
                                    if (text.isNotEmpty) double.parse(text);
                                    return newValue;
                                  } catch (e) {}
                                  return oldValue;
                                }),
                              ],
                              keyboardType: TextInputType.numberWithOptions(
                                  decimal: true),
                              textCapitalization: TextCapitalization.words,
                              style: TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.w500),
                              decoration: InputDecoration(
                                border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10)),
                                contentPadding: EdgeInsets.all(10),
                                focusedBorder: OutlineInputBorder(
                                    borderSide: BorderSide(color: Colors.black),
                                    borderRadius: BorderRadius.circular(10)),
                                labelText: "Weight (in Kg)",
                                labelStyle: TextStyle(
                                    color: Colors.black,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w300),
                              ),
                            ),
                            SizedBox(
                              height: 30,
                            ),
                            SizedBox(
                                width: MediaQuery.of(context).size.width,
                                height: 45,
                                child: ElevatedButton(
                                    child: Text("Submit",
                                        style: TextStyle(
                                            fontWeight: FontWeight.w400,
                                            fontSize: 16)),
                                    style: ButtonStyle(
                                        backgroundColor:
                                            MaterialStateProperty.all(
                                                Colors.green[700])),
                                    onPressed: () async {
                                      if (form.currentState.validate()) {
                                        setState(() {
                                          isLoading = true;
                                        });
                                        SharedPreferences prefs =
                                            await SharedPreferences
                                                .getInstance();

                                        final body = {
                                          "orderid": widget.id.toString(),
                                          "pickup_location":
                                              pickupLocationName.toString(),
                                          "length": length.text.toString(),
                                          "breadth": breadth.text.toString(),
                                          "height": height.text.toString(),
                                          "weight": weight.text.toString(),
                                          "billing_address":
                                              shippingAddress.text.toString(),
                                          "sub_total": subTotal.text.toString(),
                                          "userid": prefs
                                              .getString('userid')
                                              .toString()
                                        };
                                        print(jsonEncode(body));
                                        var response = await http.post(
                                            Uri.parse(BASE_URL +
                                                "shiprocket/place-order"),
                                            body: jsonEncode(body),
                                            headers: {
                                              "Accept": "application/json",
                                              'Content-Type': 'application/json'
                                            });
                                        setState(() {
                                          isLoading = false;
                                        });
                                        print(response.body);
                                        if (jsonDecode(
                                                response.body)['ErrorCode'] ==
                                            0) {
                                          showToast(jsonDecode(
                                              response.body)['ErrorMessage']);
                                          Navigator.of(context).pop();
                                        }
                                      }
                                    }))
                          ],
                        ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
