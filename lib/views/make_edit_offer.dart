// ignore_for_file: prefer_const_constructors, prefer_interpolation_to_compose_strings, use_build_context_synchronously, deprecated_member_use

import 'dart:convert';

import 'package:date_time_picker/date_time_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:rentit4me_new/helper/loader.dart';
import 'package:rentit4me_new/network/api.dart';
import 'package:rentit4me_new/themes/constant.dart';
import 'package:rentit4me_new/views/offers_view.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;


class MakeEditOfferScreen extends StatefulWidget {
  String pageFor;
  String productid;
  int nego;
  bool editable;
  MakeEditOfferScreen({this.productid, this.pageFor, this.nego, this.editable});
  @override
  _MakeEditOfferScreenState createState() => _MakeEditOfferScreenState();
}

class _MakeEditOfferScreenState extends State<MakeEditOfferScreen> {
  Map getOfferData = {};
  GlobalKey<FormState> form = GlobalKey<FormState>();
  TextEditingController startDate = TextEditingController(text: "From Date");
  TextEditingController securitydeposit = TextEditingController();
  TextEditingController productQuantity = TextEditingController();
  TextEditingController productAmount = TextEditingController();
  TextEditingController productDuration = TextEditingController();
  TextEditingController totalRent = TextEditingController(text: "0.0");
  TextEditingController totalSecurity = TextEditingController(text: "0.0");
  TextEditingController convenienceCharge = TextEditingController(text: "0.0");
  TextEditingController finalAmount = TextEditingController(text: "0.0");
  List rentpricelist = [];
  Map rentpricelistValue;
  double conviencePercntage = 0;
  bool isLoading = true;
  int rentTypeId = 0;
  Future _getmakeoffer(String productid) async {



    SharedPreferences prefs = await SharedPreferences.getInstance();

    final body = {"post_ad_id": productid};
    var response = await http.post(Uri.parse(BASE_URL + createoffer),
        body: jsonEncode(body),
        headers: {
          "Accept": "application/json",
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ' + prefs.getString("token").toString(),
        });
    setState(() {
      isLoading = false;
    });
    print(" -----" + response.body.toString());
    if (jsonDecode(response.body)["ErrorCode"] == 0) {
      var data = json.decode(response.body)['Response'];
      setState(() {
        if (data['data'] != "null" || data['data'] != null) {
          getOfferData = data['data'];
        }
        securitydeposit.text = data['posted_ad']['security'].toString();
        rentpricelist.addAll(data['posted_ad']['prices']);

        if (widget.editable) {
          print("edit");
          if (widget.nego == 1) {
            productQuantity.text = getOfferData['quantity'].toString();
            productDuration.text = getOfferData['period'].toString();
            productAmount.text = getOfferData['renter_amount'].toString();
            for (var element in rentpricelist) {
              if (getOfferData['rent_type_id'].toString() ==
                  element['rent_type_id'].toString()) {
                rentpricelistValue =
                    rentpricelist[rentpricelist.indexOf(element)];
                listedPrice.text = rentpricelist[rentpricelist.indexOf(element)]
                            ['price']
                        .toString() +
                    "/" +
                    rentpricelist[rentpricelist.indexOf(element)]
                            ['rent_type_alias']
                        .toString();
                rentTypeId = int.parse(element['rent_type_id'].toString());
              }
            }

            totalRent.text =
                (double.parse(getOfferData['quantity'].toString()) *
                        double.parse(getOfferData['period'].toString()) *
                        double.parse(productAmount.text.toString()))
                    .toString();
            totalSecurity.text =
                (double.parse(data['posted_ad']['security'].toString()) *
                        double.parse(getOfferData['quantity'].toString()))
                    .toString();

            conviencePercntage =
                double.parse(data['convenience_charges']['charge'].toString());
            convenienceCharge.text = ((conviencePercntage / 100) *
                    (double.parse(totalRent.text.toString()) +
                        double.parse(totalSecurity.text.toString())))
                .toString();
            finalAmount.text = (double.parse(totalRent.text.toString()) +
                    double.parse(totalSecurity.text.toString()) +
                    double.parse(convenienceCharge.text.toString()))
                .toString();
          } else {
            print("no edit");
            productQuantity.text = getOfferData['quantity'].toString();
            productDuration.text = getOfferData['period'].toString();

            rentpricelist.forEach((element) {
              if (getOfferData['rent_type_id'].toString() ==
                  element['rent_type_id'].toString()) {
                rentpricelistValue =
                    rentpricelist[rentpricelist.indexOf(element)];
                listedPrice.text = rentpricelist[rentpricelist.indexOf(element)]
                            ['price']
                        .toString() +
                    "/" +
                    rentpricelist[rentpricelist.indexOf(element)]
                            ['rent_type_alias']
                        .toString();
                rentTypeId = int.parse(element['rent_type_id'].toString());
              }
            });
            totalRent.text =
                (double.parse(getOfferData['quantity'].toString()) *
                        double.parse(getOfferData['period'].toString()) *
                        double.parse(listedPrice.text.toString().split("/")[0]))
                    .toString();
            totalSecurity.text =
                (double.parse(data['posted_ad']['security'].toString()) *
                        double.parse(getOfferData['period'].toString()))
                    .toString();

            conviencePercntage =
                double.parse(data['convenience_charges']['charge'].toString());
            convenienceCharge.text = ((conviencePercntage / 100) *
                    (double.parse(totalRent.text.toString()) +
                        double.parse(totalSecurity.text.toString())))
                .toString();
            finalAmount.text = (double.parse(totalRent.text.toString()) +
                    double.parse(totalSecurity.text.toString()) +
                    double.parse(convenienceCharge.text.toString()))
                .toString();
          }
        } else {
          print(rentpricelist);
          rentpricelistValue = rentpricelist[0];
          rentTypeId = rentpricelist[0]['rent_type_id'];
          listedPrice.text = rentpricelist[0]['price'].toString() +
              "/" +
              rentpricelist[0]['rent_type_alias'].toString();
          conviencePercntage =
              double.parse(data['convenience_charges']['charge'].toString());
        }
        startDate.text = getOfferData['start_date'] == null
            ? ""
            : getOfferData['start_date'].toString();
      });
    }
  }

  TextEditingController listedPrice = TextEditingController();

  void calculation(String qt, String amoun, String duratio) {
    double qty = qt.isEmpty ? 0 : double.parse(qt);
    double amount = amoun.isEmpty ? 0 : double.parse(amoun);
    double duration = duratio.isEmpty ? 0 : double.parse(duratio);

    double rent = qty * amount * duration;
    double secur = qty * double.parse(securitydeposit.text.toString());
    double convValue = (conviencePercntage / 100) * (rent + secur);
    double fAmount = rent + secur + convValue;

    setState(() {
      totalRent.text = rent.toStringAsFixed(2);
      totalSecurity.text = secur.toStringAsFixed(2);
      convenienceCharge.text = convValue.toStringAsFixed(2);
      finalAmount.text = fAmount.toStringAsFixed(2);
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _getmakeoffer(widget.productid.toString());
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
        title: Text(widget.pageFor.toString(),
            style: TextStyle(color: kPrimaryColor)),
        centerTitle: true,
      ),
      body: isLoading
          ? Center(
              child: CircularProgressIndicator(),
            )
          : Padding(
              padding: const EdgeInsets.all(10),
              child: SingleChildScrollView(
                child: Form(
                  key: form,
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Text(widget.productid),
                        Text("Rent Type",
                            style: TextStyle(
                                fontSize: 16, fontWeight: FontWeight.w600)),
                        SizedBox(
                          height: 5,
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
                                  value: rentpricelistValue,
                                  isDense: true,
                                  onChanged: (newValue) {
                                    print(newValue);
                                    setState(() {
                                      rentpricelistValue = newValue;
                                      rentTypeId = int.parse(
                                          newValue['rent_type_id'].toString());
                                      listedPrice.text =
                                          newValue['price'].toString() +
                                              "/" +
                                              newValue['rent_type_alias']
                                                  .toString();

                                      productAmount.clear();
                                      productDuration.clear();
                                      productQuantity.clear();
                                      totalRent.text = "0.0";
                                      totalSecurity.text = "0.0";
                                      convenienceCharge.text = "0.0";
                                      finalAmount.text = "0.0";
                                      startDate.clear();
                                    });
                                  },
                                  items: rentpricelist.map((value) {
                                    return DropdownMenuItem(
                                      value: value,
                                      child: Text(value['rent_type_name']),
                                    );
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
                          controller: listedPrice,
                          readOnly: true,
                          decoration: InputDecoration(
                              contentPadding: EdgeInsets.all(10),
                              isCollapsed: true,
                              isDense: true,
                              border: OutlineInputBorder(
                                  borderSide: BorderSide(color: Colors.black)),
                              label: Text("Listed Price")),
                        ),
                        SizedBox(
                          height: 15,
                        ),
                        TextFormField(
                          controller: securitydeposit,
                          readOnly: true,
                          decoration: InputDecoration(
                              contentPadding: EdgeInsets.all(10),
                              isCollapsed: true,
                              isDense: true,
                              border: OutlineInputBorder(
                                  borderSide: BorderSide(color: Colors.black)),
                              label: Text("Security Deposit")),
                        ),
                        SizedBox(
                          height: 15,
                        ),
                        TextFormField(
                          controller: productQuantity,
                          keyboardType: TextInputType.number,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly
                          ],
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Required';
                            }
                            return null;
                          },
                          onChanged: (val) {
                            if (widget.nego == 1) {
                              calculation(
                                productQuantity.text.toString(),
                                productAmount.text.toString(),
                                productDuration.text.toString(),
                              );
                            } else {
                              calculation(
                                productQuantity.text.toString(),
                                listedPrice.text.toString().split("/")[0],
                                productDuration.text.toString(),
                              );
                            }
                          },
                          decoration: InputDecoration(
                              contentPadding: EdgeInsets.all(10),
                              isCollapsed: true,
                              isDense: true,
                              border: OutlineInputBorder(
                                  borderSide: BorderSide(color: Colors.black)),
                              label: Text("Enter Product Quantity")),
                        ),
                        SizedBox(
                          height: 15,
                        ),
                        // Text(widget.nego.toString()),
                        widget.nego == 1
                            ? Column(
                                children: [
                                  TextFormField(
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return 'Required';
                                      }
                                      return null;
                                    },
                                    controller: productAmount,
                                    keyboardType:
                                        TextInputType.numberWithOptions(
                                            decimal: true),
                                    inputFormatters: [
                                      FilteringTextInputFormatter.allow(
                                          RegExp('[0-9.,]')),
                                      TextInputFormatter.withFunction(
                                          (oldValue, newValue) {
                                        try {
                                          final text = newValue.text;
                                          if (text.isNotEmpty)
                                            double.parse(text);
                                          return newValue;
                                        } catch (e) {}
                                        return oldValue;
                                      }),
                                    ],
                                    onChanged: (val) {
                                      calculation(
                                        productQuantity.text.toString(),
                                        productAmount.text.toString(),
                                        productDuration.text.toString(),
                                      );
                                    },
                                    decoration: InputDecoration(
                                        contentPadding: EdgeInsets.all(10),
                                        isCollapsed: true,
                                        isDense: true,
                                        border: OutlineInputBorder(
                                            borderSide: BorderSide(
                                                color: Colors.black)),
                                        label: Text("Enter Amount Per " +
                                            listedPrice.text
                                                .toString()
                                                .split("/")[1])),
                                  ),
                                  SizedBox(
                                    height: 15,
                                  ),
                                ],
                              )
                            : SizedBox(),
                        TextFormField(
                          controller: productDuration,
                          keyboardType: TextInputType.number,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly
                          ],
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Required';
                            }
                            return null;
                          },
                          onChanged: (val) {
                            if (widget.nego == 1) {
                              calculation(
                                productQuantity.text.toString(),
                                productAmount.text.toString(),
                                productDuration.text.toString(),
                              );
                            } else {
                              calculation(
                                productQuantity.text.toString(),
                                listedPrice.text.toString().split("/")[0],
                                productDuration.text.toString(),
                              );
                            }
                          },
                          decoration: InputDecoration(
                              contentPadding: EdgeInsets.all(10),
                              isCollapsed: true,
                              isDense: true,
                              border: OutlineInputBorder(
                                  borderSide: BorderSide(color: Colors.black)),
                              label: Text("Enter No Of " +
                                  listedPrice.text.toString().split("/")[1])),
                        ),
                        SizedBox(
                          height: 15,
                        ),
                        TextFormField(
                          readOnly: true,
                          controller: totalRent,
                          keyboardType: TextInputType.number,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly
                          ],
                          decoration: InputDecoration(
                              contentPadding: EdgeInsets.all(10),
                              isCollapsed: true,
                              isDense: true,
                              border: OutlineInputBorder(
                                  borderSide: BorderSide(color: Colors.black)),
                              label: Text("Total Rent")),
                        ),
                        SizedBox(
                          height: 15,
                        ),
                        TextFormField(
                          readOnly: true,
                          controller: totalSecurity,
                          keyboardType: TextInputType.number,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly
                          ],
                          decoration: InputDecoration(
                              contentPadding: EdgeInsets.all(10),
                              isCollapsed: true,
                              isDense: true,
                              border: OutlineInputBorder(
                                  borderSide: BorderSide(color: Colors.black)),
                              label: Text("Total Security")),
                        ),
                        SizedBox(
                          height: 15,
                        ),
                        TextFormField(
                          readOnly: true,
                          controller: convenienceCharge,
                          keyboardType: TextInputType.number,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly
                          ],
                          decoration: InputDecoration(
                              contentPadding: EdgeInsets.all(10),
                              isCollapsed: true,
                              isDense: true,
                              border: OutlineInputBorder(
                                  borderSide: BorderSide(color: Colors.black)),
                              label: Text("Convenience Charge (" +
                                  conviencePercntage.toString() +
                                  "%)")),
                        ),
                        SizedBox(
                          height: 15,
                        ),
                        TextFormField(
                          readOnly: true,
                          controller: finalAmount,
                          keyboardType: TextInputType.number,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly
                          ],
                          decoration: InputDecoration(
                              contentPadding: EdgeInsets.all(10),
                              isCollapsed: true,
                              isDense: true,
                              border: OutlineInputBorder(
                                  borderSide: BorderSide(color: Colors.black)),
                              label: Text("Final Amount")),
                        ),
                        SizedBox(
                          height: 15,
                        ),
                        listedPrice.text.toString().split("/")[1] == "Hour"
                            ? _datetimepickerwithhour()
                            : TextFormField(
                                controller: startDate,
                                readOnly: true,
                                onTap: () {
                                  _selectStartDate(context, setState);
                                },
                                decoration: InputDecoration(
                                    isDense: true,
                                    border: OutlineInputBorder(
                                        borderSide:
                                            BorderSide(color: Colors.black)),
                                    label: Text("Start Date")),
                              ),
                        SizedBox(
                          height: 20,
                        ),
                        SizedBox(
                          width: MediaQuery.of(context).size.width,
                          child: ElevatedButton(
                              onPressed: () async {
                                SharedPreferences pref =
                                    await SharedPreferences.getInstance();
                                if (form.currentState.validate() &&
                                    startDate.text.isNotEmpty) {
                                  if (widget.nego == 1) {
                                    Map m = {
                                      "post_ad_id": widget.productid.toString(),
                                      "period": productDuration.text.toString(),
                                      "rent_type": rentTypeId.toString(),
                                      "quantity":
                                          productQuantity.text.toString(),
                                      "start_date": startDate.text.toString(),
                                      "renter_amount": productAmount.text,
                                      "user_id": pref.getString('userid')
                                    };

                                    _setmakeoffer(m);
                                  } else {
                                    Map m = {
                                      "post_ad_id": widget.productid.toString(),
                                      "period": productDuration.text.toString(),
                                      "rent_type": rentTypeId.toString(),
                                      "quantity":
                                          productQuantity.text.toString(),
                                      "start_date": startDate.text.toString(),
                                      "user_id": pref.getString('userid')
                                    };
                                    _setmakeoffer(m);
                                  }
                                } else {
                                  showToast(
                                      "Please fill required fields & select date");
                                }
                              },
                              child: Text("Submit")),
                        ),
                        SizedBox(
                          height: 20,
                        ),
                      ]),
                ),
              ),
            ),
    );
  }

  Future _setmakeoffer(Map body) async {
    showLaoding(context);
    SharedPreferences prefs = await SharedPreferences.getInstance();
    print(jsonEncode(body));
    var response = await http.post(Uri.parse(BASE_URL + makeoffer),
        body: jsonEncode(body),
        headers: {
          "Accept": "application/json",
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ' + prefs.getString("token").toString(),
        });
    Navigator.of(context, rootNavigator: true).pop();
    if (response.statusCode == 200) {
      var data = json.decode(response.body);
      showToast(data['ErrorMessage'].toString());
      if(data['ErrorCode']==0){
      Navigator.pushReplacement(context,
          MaterialPageRoute(builder: (BuildContext context) => OffersViewScreen()));}
    } else {
      throw Exception('Failed to get data due to ${response.body}');
    }
  }

  Future<void> _selectStartDate(BuildContext context, setState) async {
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
        startDate.text = DateFormat('yyyy/MM/dd').format(picked);
      });
    }
  }

  Widget _datetimepickerwithhour() {
    return DateTimePicker(
      type: DateTimePickerType.dateTime,
      dateMask: 'yyyy/MMM/dd - hh:mm a',
      //initialValue: _initialValue,
      firstDate: DateTime(2000),
      lastDate: DateTime(2030),
      //icon: Icon(Icons.event),
      dateLabelText: 'Date Time',
      decoration: InputDecoration(
        isDense: true,
        label: Text("Start Date "),
        isCollapsed: true,
        contentPadding: EdgeInsets.all(10),
        border: OutlineInputBorder(borderSide: BorderSide(color: Colors.black)),
      ),
      use24HourFormat: false,
      locale: Locale('en', 'US'),
      icon: Icon(Icons.calendar_today_sharp, size: 20),
      // ignore: missing_return
      validator: (val) {
        setState(() {
          startDate.text = val;
        });
      },
      onSaved: (val) {
        setState(() {
          startDate.text = val;
        });
      },
      onChanged: (val) {
        setState(() {
          startDate.text = val;
        });
      },
      onFieldSubmitted: (v) {
        setState(() {
          startDate.text = v;
        });
      },
    );
  }
}
