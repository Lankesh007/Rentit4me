// ignore_for_file: prefer_const_constructors, prefer_interpolation_to_compose_strings, use_build_context_synchronously

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:rentit4me_new/helper/loader.dart';
import 'package:rentit4me_new/network/api.dart';
import 'package:rentit4me_new/themes/constant.dart';
import 'package:rentit4me_new/views/home_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class AddPickUpAddress extends StatefulWidget {
  @override
  _AddPickUpAddressState createState() => _AddPickUpAddressState();
}

class _AddPickUpAddressState extends State<AddPickUpAddress> {
  Map countryValue;
  List countryList = [];
  String token = "";
  Map stateValue = {};
  List stateList = [];
  bool loading = true;
  GlobalKey<FormState> form = GlobalKey();
  TextEditingController nickname = TextEditingController();
  TextEditingController contactName = TextEditingController();
  TextEditingController phoneNo = TextEditingController();
  TextEditingController emailId = TextEditingController();
  TextEditingController addLine1 = TextEditingController();
  TextEditingController addLine2 = TextEditingController();
  TextEditingController country = TextEditingController();
  TextEditingController state = TextEditingController();
  TextEditingController pincode = TextEditingController();
  TextEditingController city = TextEditingController();
  bool pincodeInavlid = false;
  Future<void> getCountryList() async {
    var response = await http.get(Uri.parse(BASE_URL + "add-pickup-address"),
        headers: {
          "Accept": "application/json",
          'Content-Type': 'application/json'
        });
    if (jsonDecode(response.body)['ErrorCode'] == 0) {
      setState(() {
        countryList.addAll(jsonDecode(response.body)['Response']['countries']);
        countryValue = countryList[0];
        token = jsonDecode(response.body)['Response']['token'].toString();
        country.text = countryList[0]['name'];
      });
      getCountryStateList(countryList[0]['id'].toString());
    }
    setState(() {
      loading = false;
    });
    return [];
  }

  Future<void> getCountryStateList(String countryId) async {
    setState(() {
      loading = true;
    });
    var response = await http.get(
        Uri.parse(BASE_URL + "get-shiprocket-states/" + countryId),
        headers: {
          "Accept": "application/json",
          'Content-Type': 'application/json'
        });
    if (jsonDecode(response.body)['ErrorCode'] == 0) {
      setState(() {
        stateList.clear();
        stateList.addAll(jsonDecode(response.body)['Response']);
        stateValue = stateList[0];
        state.text = stateList[0]['name'];
      });
    }
    setState(() {
      loading = false;
    });
    return [];
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getCountryList();
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
        title:
            Text("Add Pickup Address", style: TextStyle(color: kPrimaryColor)),
        centerTitle: true,
      ),
      body: ModalProgressHUD(
        inAsyncCall: loading,
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(15),
            child: Form(
              key: form,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Contact Information",
                      style:
                          TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  SizedBox(
                    height: 20,
                  ),
                  TextFormField(
                    controller: nickname,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Required';
                      }
                      return null;
                    },
                    textCapitalization: TextCapitalization.words,
                    decoration: InputDecoration(
                        contentPadding: EdgeInsets.all(10),
                        isCollapsed: true,
                        isDense: true,
                        border: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.black)),
                        label: Text("Enter Address Nickname")),
                  ),
                  SizedBox(
                    height: 15,
                  ),
                  TextFormField(
                    controller: contactName,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Required';
                      }
                      return null;
                    },
                    textCapitalization: TextCapitalization.words,
                    decoration: InputDecoration(
                        contentPadding: EdgeInsets.all(10),
                        isCollapsed: true,
                        isDense: true,
                        border: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.black)),
                        label: Text("Contact Name")),
                  ),
                  SizedBox(
                    height: 15,
                  ),
                  TextFormField(
                    controller: phoneNo,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Required';
                      }
                      return null;
                    },
                    keyboardType: TextInputType.phone,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    decoration: InputDecoration(
                        contentPadding: EdgeInsets.all(10),
                        isCollapsed: true,
                        isDense: true,
                        border: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.black)),
                        label: Text("Phone Number")),
                  ),
                  SizedBox(
                    height: 15,
                  ),
                  TextFormField(
                    controller: emailId,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Required';
                      }
                      return null;
                    },
                    keyboardType: TextInputType.emailAddress,
                    decoration: InputDecoration(
                        contentPadding: EdgeInsets.all(10),
                        isCollapsed: true,
                        isDense: true,
                        border: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.black)),
                        label: Text("Email ID")),
                  ),
                  SizedBox(
                    height: 15,
                  ),
                  Text("Address Details",
                      style:
                          TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  SizedBox(
                    height: 20,
                  ),
                  TextFormField(
                    controller: addLine1,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Required';
                      }
                      return null;
                    },
                    textCapitalization: TextCapitalization.words,
                    decoration: InputDecoration(
                        contentPadding: EdgeInsets.all(10),
                        isCollapsed: true,
                        isDense: true,
                        border: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.black)),
                        label: Text("Address Line 1")),
                  ),
                  SizedBox(
                    height: 15,
                  ),
                  TextFormField(
                    controller: addLine2,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Required';
                      }
                      return null;
                    },
                    textCapitalization: TextCapitalization.words,
                    decoration: InputDecoration(
                        contentPadding: EdgeInsets.all(10),
                        isCollapsed: true,
                        isDense: true,
                        border: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.black)),
                        label: Text("Address Line 2")),
                  ),
                  SizedBox(
                    height: 15,
                  ),
                  FormField(
                    builder: (FormFieldState state) {
                      return InputDecorator(
                        decoration: InputDecoration(
                            labelText: "Country",
                            fillColor: Colors.white,
                            filled: true,
                            isDense: true,
                            contentPadding: EdgeInsets.all(10),
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(5.0))),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton(
                            isExpanded: true,
                            hint: Text("Select"),
                            value: countryValue,
                            isDense: true,
                            onChanged: (newValue) {
                              setState(() {
                                countryValue = newValue;
                                country.text = newValue['name'].toString();
                              });
                              getCountryStateList(newValue['id'].toString());
                            },
                            items: countryList.map((value) {
                              return DropdownMenuItem(
                                  value: value,
                                  child: Text(value['name'].toString()));
                            }).toList(),
                          ),
                        ),
                      );
                    },
                  ),
                  SizedBox(
                    height: 15,
                  ),
                  FormField(
                    builder: (FormFieldState state1) {
                      return InputDecorator(
                        decoration: InputDecoration(
                            labelText: "State",
                            fillColor: Colors.white,
                            filled: true,
                            isDense: true,
                            contentPadding: EdgeInsets.all(10),
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(5.0))),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton(
                            isExpanded: true,
                            value: stateValue,
                            isDense: true,
                            onChanged: (newValue) {
                              setState(() {
                                stateValue = newValue;
                                state.text = newValue['name'].toString();
                              });
                            },
                            items: stateList.map((value) {
                              return DropdownMenuItem(
                                  value: value,
                                  child: Text(value['name'].toString()));
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
                    controller: pincode,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Required';
                      }
                      return null;
                    },
                    maxLength: 6,
                    onChanged: (val) async {
                      if (val.length == 6) {
                        setState(() {
                          loading = true;
                        });
                        var response = await http.get(
                          Uri.parse(
                              "https://apiv2.shiprocket.in/v1/external/open/postcode/details?postcode=" +
                                  val),
                          headers: {
                            "Accept": "application/json",
                            "Content-Type": "application/json",
                            'Authorization': 'Bearer ' + token,
                          },
                        );
                        setState(() {
                          loading = false;
                        });
                        print(response.body);
                        if (jsonDecode(response.body)['success'].toString() ==
                            "true") {
                          setState(() {
                            pincodeInavlid = false;
                          });
                        } else {
                          setState(() {
                            pincodeInavlid = true;
                          });
                        }
                      }
                    },
                    keyboardType: TextInputType.phone,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    decoration: InputDecoration(
                        contentPadding: EdgeInsets.all(10),
                        isCollapsed: true,
                        isDense: true,
                        counterText: "",
                        suffix: pincodeInavlid
                            ? Text(
                                "Invalid",
                                style: TextStyle(color: Colors.red),
                              )
                            : SizedBox(),
                        border: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.black)),
                        label: Text("Pincode")),
                  ),
                  SizedBox(
                    height: 15,
                  ),
                  TextFormField(
                    controller: city,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Required';
                      }
                      return null;
                    },
                    textCapitalization: TextCapitalization.words,
                    decoration: InputDecoration(
                        contentPadding: EdgeInsets.all(10),
                        isCollapsed: true,
                        isDense: true,
                        border: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.black)),
                        label: Text("City")),
                  ),
                  SizedBox(
                    height: 15,
                  ),
                  SizedBox(
                    width: MediaQuery.of(context).size.width,
                    child: ElevatedButton(
                        onPressed: () async {
                          FocusScope.of(context).unfocus();
                          SharedPreferences prefs =
                              await SharedPreferences.getInstance();
                          if (form.currentState.validate()) {
                            // showLaoding(context);
                            setState(() {
                              loading = true;
                            });
                            final body = {
                              "pickup_location": nickname.text.toString(),
                              "name": contactName.text.toString(),
                              "email": emailId.text.toString(),
                              "phone": phoneNo.text.toString(),
                              "address": addLine1.text.toString(),
                              "address_2": addLine2.text.toString(),
                              "city": city.text.toString(),
                              "state": state.text.toString(),
                              "country": country.text.toString(),
                              "pin_code": pincode.text.toString(),
                              "userid": prefs.getString('userid').toString()
                            };

                            print(jsonEncode(body));
                            var response = await http.post(
                                Uri.parse(BASE_URL + "store-pickup-address"),
                                body: jsonEncode(body),
                                headers: {
                                  "Accept": "application/json",
                                  'Content-Type': 'application/json'
                                });
                            setState(() {
                              loading = false;
                            });
                            print(response.body);
                            if (jsonDecode(response.body)['ErrorCode'] == 1) {
                              showProdcutDetails(
                                  context, jsonDecode(response.body));
                              // showDialog(
                              //     context: context,
                              //     builder: (context1) => AlertDialog(
                              //           title: Text("Warning"),
                              //           content: jsonDecode(response.body)[
                              //                       'Response']['errors'] ==
                              //                   null
                              //               ? Text(jsonDecode(response.body)[
                              //                       'ErrorMessage'][0]
                              //                   .toString())
                              //               : Text(jsonDecode(response.body)[
                              //                           'Response']['errors']
                              //                       ['address']
                              //                   .toString()),
                              //           actions: [
                              //             TextButton(
                              //                 onPressed: () {
                              //                   Navigator.of(context1).pop();
                              //                 },
                              //                 child: Text("Cancel"))
                              //           ],
                              //         ));
                            } else if (jsonDecode(response.body)['ErrorCode'] ==
                                0) {
                              showToast(
                                  jsonDecode(response.body)['ErrorMessage']
                                      .toString());
                              Navigator.of(context).pop();
                            } else {
                              throw Exception(
                                  'Failed to get data due to ${response.body}');
                            }
                          }
                        },
                        child: Text("Submit")),
                  ),
                  SizedBox(
                    height: 20,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> showProdcutDetails(BuildContext context, Map m) async {
    if (m['Response']['errors'] == null) {
      await showModalBottomSheet(
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.vertical(top: Radius.circular(20.0))),
          backgroundColor: Colors.white,
          context: context,
          isScrollControlled: true,
          builder: (context) => StatefulBuilder(
                  builder: (BuildContext context, StateSetter setState) {
                return SizedBox(
                    height: MediaQuery.of(context).size.height / 2,
                    child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: SingleChildScrollView(
                            child: Column(
                          children: [
                            Text(
                              "Warning",
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.red,
                                  fontSize: 18),
                            ),
                            SizedBox(
                              height: 20,
                            ),
                            Text(m['ErrorMessage'].toString(),
                                style: TextStyle(
                                    fontSize: 14, fontWeight: FontWeight.w500)),
                          ],
                        ))));
              }));
    } else {
      List temp = [];
      Map map = m['Response']['errors'];

      map.forEach((key, value) {
        temp.add({"title": key.toString(), "value": value});
      });

      await showModalBottomSheet(
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.vertical(top: Radius.circular(20.0))),
          backgroundColor: Colors.white,
          context: context,
          isScrollControlled: true,
          builder: (context) => StatefulBuilder(
                  builder: (BuildContext context, StateSetter setState) {
                return SizedBox(
                    height: MediaQuery.of(context).size.height / 2,
                    child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: SingleChildScrollView(
                            child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Warning",
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.red,
                                  fontSize: 18),
                            ),
                            SizedBox(
                              height: 20,
                            ),
                            Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: temp.map((e) {
                                  List subValue = e['value'];
                                  return Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        e['title'].toString().toUpperCase(),
                                        style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold),
                                      ),
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: subValue.map((e1) {
                                          return Text(e1.toString(),
                                              style: TextStyle(
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.w500));
                                        }).toList(),
                                      ),
                                      SizedBox(
                                        height: 20,
                                      )
                                    ],
                                  );
                                }).toList()),
                          ],
                        ))));
              }));
    }
  }
}
