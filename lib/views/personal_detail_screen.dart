// ignore_for_file: prefer_const_literals_to_create_immutables, prefer_const_constructors, prefer_interpolation_to_compose_strings, use_build_context_synchronously

import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:dropdown_search/dropdown_search.dart';
import 'package:image_picker/image_picker.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:rentit4me_new/network/api.dart';
import 'package:rentit4me_new/themes/constant.dart';
import 'package:rentit4me_new/views/billing_and_taxation.dart';
import 'package:rentit4me_new/views/dashboard.dart';
import 'package:rentit4me_new/views/make_payment_screen.dart';
import 'package:rentit4me_new/views/select_membership_screen.dart';
import 'package:rentit4me_new/widgets/api_helper.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PersonalDetailScreen extends StatefulWidget {
  const PersonalDetailScreen({Key key}) : super(key: key);

  @override
  State<PersonalDetailScreen> createState() => _PersonalDetailScreenState();
}

class _PersonalDetailScreenState extends State<PersonalDetailScreen> {
  bool _loading = false;

  // String usertype;

  List countrylistData = [];
  int country_id;

  List statelistData = [];
  int state_id;
  String stateId = '';
  String countryId = '';

  List citylistData = [];
  int city_id;
  final bankName = TextEditingController();
  final branchName = TextEditingController();
  final accountNo = TextEditingController();
  final iFSCCode = TextEditingController();

  // String initialkyc;
  // List<String> _kycdata = ["Yes", "No"];
  bool kyc = false;
  String businessName = '';
  String initialtrustedbadge = "Select";
  String initialIdProof = "Select";
  final List _badgedata = ["Select", "Yes", "No"];

  String adharcarddoc = "";
  TextEditingController address = TextEditingController();
  TextEditingController pincode = TextEditingController();
  TextEditingController adharnum = TextEditingController();

  String passportDoc = "";
  String dlDoc = "";

  TextEditingController drivingLicenseNumber = TextEditingController();
  TextEditingController pasportNumber = TextEditingController();

  bool _emailcheck = false;
  bool _smscheck = false;
  bool buttonLoading = false;
  var decodeImages;

  String checkEmail = "";
  String checkSms = "";
  // int _hidemobile = 0;
  // bool _hidemob = false;

  // int emailvalue;
  // int smsvalue;

  // String kyc, trustbadge;

  List<int> commprefs = [];

  List<String> _accounttypelist = ["Select", "Saving", "Current"];

  String dropdownvalue = 'Select';

  // List of items in our dropdown menu
  var items = [
    'Select',
    'Current',
    'Saving',
  ];
  bool tb = false;
  int userType = 0;

  String selectedCountry;
  String selectedState;
  String selectedCity;

  //Bank detail
  TextEditingController bankname = TextEditingController();
  TextEditingController branchname = TextEditingController();
  TextEditingController ifsccode = TextEditingController();
  TextEditingController accounttype = TextEditingController(text: "Select");
  TextEditingController accountno = TextEditingController();
  final aadharNumber = TextEditingController();

  GlobalKey<FormState> key = GlobalKey();

  String country;
  String state;
  String city;
  String pinCode;
  String userId;

  getPrefsData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    country = prefs.getString('country');
    log("country--->$country");
    state = prefs.getString('state');
    log("state--->$state");
    city = prefs.getString('city');
    log("city--->$city");
    pinCode = prefs.getString('pinCode');
    log("city--->$pinCode");
    pincode.text = pinCode;
    userId = prefs.getString('userid');
    log("userId--->$userId");
  }

  @override
  void initState() {
    super.initState();
    // _getcheckapproveData();
    _getcountryData();
    _getprofile().then((value) {});

    //_getprofile();
  }

  String locationUser;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 2.0,
        // leading: InkWell(
        //     onTap: () {
        //       Navigator.of(context).pop();
        //     },
        //     child: const Icon(
        //       Icons.arrow_back,
        //       color: kPrimaryColor,
        //     )),
        title: const Text("Personal Details",
            style: TextStyle(color: kPrimaryColor)),
        centerTitle: true,
      ),
      body: ModalProgressHUD(
        inAsyncCall: _loading,
        color: kPrimaryColor,
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Form(
              key: key,
              child: Column(
                children: [
                  Card(
                    elevation: 4.0,
                    child: Padding(
                      padding:
                          EdgeInsets.symmetric(vertical: 10, horizontal: 15),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Text("Country*",
                          //     style: TextStyle(
                          //         color: kPrimaryColor,
                          //         fontSize: 16,
                          //         fontWeight: FontWeight.w500)),
                          // SizedBox(height: 8.0),
                          // Padding(
                          //   padding: const EdgeInsets.fromLTRB(0, 2, 0, 2),
                          //   child: DropdownSearch(
                          //     selectedItem: "Select Country",
                          //     mode: Mode.DIALOG,
                          //     showSelectedItem: true,
                          //     autoFocusSearchBox: true,
                          //     showSearchBox: true,
                          //     hint: 'Select Country',
                          //     favoriteItems: (val) {
                          //       return ["India"];
                          //     },
                          //     showFavoriteItems: true,
                          //     dropdownSearchDecoration: InputDecoration(
                          //         enabledBorder: OutlineInputBorder(
                          //             borderRadius: BorderRadius.circular(12),
                          //             borderSide: BorderSide(
                          //                 color: Colors.deepOrangeAccent,
                          //                 width: 1)),
                          //         contentPadding: EdgeInsets.only(left: 10)),
                          //     items: countrylistData.map((e) {
                          //       return e['name'].toString();
                          //     }).toList(),
                          //     onChanged: (value) {
                          //       if (value != "Select Country") {
                          //         for (var element in countrylistData) {
                          //           if (element['name'].toString() == value) {
                          //             setState(() {
                          //               statelistData.clear();
                          //               citylistData.clear();
                          //               selectedCountry = value;
                          //               log("selected-->$selectedCountry");
                          //               country_id = element['id'];
                          //               selectedState = 'Select State';
                          //               selectedCity = 'Select City';
                          //               initialtrustedbadge = 'Select';
                          //               kyc = false;
                          //             });
                          //             _getStateData(element['id']);
                          //           }
                          //         }
                          //       } else {
                          //         showToast("Select Country");
                          //       }
                          //     },
                          //   ),
                          // ),
                          // SizedBox(height: 10),
                          // Text("State*",
                          //     style: TextStyle(
                          //         color: kPrimaryColor,
                          //         fontSize: 16,
                          //         fontWeight: FontWeight.w500)),
                          // SizedBox(height: 8.0),
                          // DropdownSearch(
                          //   selectedItem: selectedState == "null" ||
                          //           selectedState == null ||
                          //           selectedState == ""
                          //       ? "Slelect State"
                          //       : selectedState,
                          //   mode: Mode.DIALOG,
                          //   showSelectedItem: true,
                          //   autoFocusSearchBox: true,
                          //   showSearchBox: true,
                          //   hint: 'Select State',
                          //   dropdownSearchDecoration: InputDecoration(
                          //       enabledBorder: OutlineInputBorder(
                          //           borderRadius: BorderRadius.circular(12),
                          //           borderSide: BorderSide(
                          //               color: Colors.deepOrangeAccent,
                          //               width: 1)),
                          //       contentPadding: EdgeInsets.only(left: 10)),
                          //   items: statelistData.map((e) {
                          //     return e['name'].toString();
                          //   }).toList(),
                          //   onChanged: (value) {
                          //     if (value != "Select State") {
                          //       for (var element in statelistData) {
                          //         if (element['name'].toString() == value) {
                          //           setState(() {
                          //             selectedState = "";
                          //             selectedState = value;
                          //             state_id = element['id'];
                          //             log(state_id.toString());
                          //             log(state_id.toString());
                          //             selectedCity = 'Select City';
                          //           });
                          //           _getCityData(state_id);
                          //         }
                          //       }
                          //     } else {
                          //       showToast("Select State");
                          //     }
                          //   },
                          // ),
                          // SizedBox(height: 10),
                          // Text("City*",
                          //     style: TextStyle(
                          //         color: kPrimaryColor,
                          //         fontSize: 16,
                          //         fontWeight: FontWeight.w500)),
                          // SizedBox(height: 8.0),
                          // DropdownSearch(
                          //   selectedItem: selectedCity == "null" ||
                          //           selectedCity == null ||
                          //           selectedCity == ""
                          //       ? "Select City"
                          //       : selectedCity,
                          //   mode: Mode.DIALOG,
                          //   showSelectedItem: true,
                          //   autoFocusSearchBox: true,
                          //   showSearchBox: true,
                          //   hint: 'Select City',
                          //   dropdownSearchDecoration: InputDecoration(
                          //       enabledBorder: OutlineInputBorder(
                          //           borderRadius: BorderRadius.circular(12),
                          //           borderSide: BorderSide(
                          //               color: Colors.deepOrangeAccent,
                          //               width: 1)),
                          //       contentPadding: EdgeInsets.only(left: 10)),
                          //   items: citylistData.map((e) {
                          //     return e['name'].toString();
                          //   }).toList(),
                          //   onChanged: (value) {
                          //     if (value != "Select City") {
                          //       for (var element in citylistData) {
                          //         if (element['name'].toString() == value) {
                          //           setState(() {
                          //             selectedCity = '';
                          //             selectedCity = value;
                          //             city_id = element['id'];
                          //           });
                          //         }
                          //       }
                          //     } else {
                          //       showToast("Select City");
                          //     }
                          //   },
                          // ),
                          // SizedBox(height: 10),
                          Text("Location*",
                              style: TextStyle(
                                  color: kPrimaryColor,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500)),
                          SizedBox(height: 8.0),
                          Container(
                            alignment: Alignment.center,
                            height: 50,
                            width: MediaQuery.of(context).size.width * 0.9,
                            decoration: BoxDecoration(
                                border: Border.all(color: Colors.deepOrange),
                                borderRadius: BorderRadius.circular(10)),
                            child: Container(
                              margin:
                                  const EdgeInsets.symmetric(horizontal: 10),
                              child: TextFormField(
                                controller: destinationPoint,
                                autofocus: true,
                                keyboardType: TextInputType.text,
                                showCursor: true,
                                onChanged: (value) {
                                  getLocations(value);
                                },
                                decoration: const InputDecoration(
                                  hintStyle: TextStyle(
                                    color: Colors.black,
                                    fontWeight: FontWeight.normal,
                                  ),
                                  border: InputBorder.none,
                                  hintText: "Search Location",
                                ),
                                style: const TextStyle(
                                  color: Colors.black,
                                  fontWeight: FontWeight.normal,
                                ),
                                maxLines: 1,
                              ),
                            ),
                          ),
                          SizedBox(
                            height: 20,
                          ),
                          showData == false
                              ? SizedBox()
                              : SizedBox(
                                  height:
                                      MediaQuery.of(context).size.height * 0.3,
                                  width:
                                      MediaQuery.of(context).size.width * 0.9,
                                  child: ListView.builder(
                                    itemCount: placecounts,
                                    itemBuilder:
                                        (BuildContext context, int index) {
                                      return SizedBox(
                                        height: 50,
                                        child: ListTile(
                                          onTap: () {
                                            locations = places[index]
                                                ['formatted_address'];
                                            log("------>" + places.toString());
                                            var lattitude = places[index]
                                                ['geometry']['location']['lat'];
                                            var longitude = places[index]
                                                ['geometry']['location']['lng'];
                                            log("Destination Point Address : ${locations.toString()}");
                                            log("Destination Point Lattitude : ${lattitude.toString()}");
                                            log("Destination Point Longitude : ${longitude.toString()}");
                                            getAddressFromLatLongDesti(
                                                lattitude.toString(),
                                                longitude.toString());
                                            showData = false;
                                            destinationLattitude =
                                                lattitude.toString();
                                            destinationLongitude =
                                                longitude.toString();
                                            destinationPoint.text =
                                                locations.toString();
                                            setState(() {
                                              locationUser = places[index]
                                                  ['formatted_address'];
                                              log("location user ---> $locationUser");
                                              places.clear();
                                            });
                                            FocusScope.of(context)
                                                .requestFocus(FocusNode());
                                            // _setLocation(locations, lattitude, longitude);
                                          },
                                          leading: Container(
                                            padding: const EdgeInsets.all(5),
                                            decoration: const BoxDecoration(
                                              borderRadius: BorderRadius.all(
                                                Radius.circular(
                                                  100,
                                                ),
                                              ),
                                              color: Colors.grey,
                                            ),
                                            child: const Icon(
                                              Icons.location_on_outlined,
                                              color: Colors.black,
                                            ),
                                          ),
                                          title: Padding(
                                            padding: const EdgeInsets.only(
                                                left: 8.0),
                                            child: Text(
                                              places[index]
                                                  ['formatted_address'],
                                              style: TextStyle(
                                                  color: Colors.black),
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                ),

                          // Container(
                          //     alignment: Alignment.center,
                          //     height:
                          //         MediaQuery.of(context).size.height * 0.065,
                          //     decoration: BoxDecoration(
                          //         border: Border.all(
                          //             width: 1, color: Colors.deepOrangeAccent),
                          //         borderRadius:
                          //             BorderRadius.all(Radius.circular(12))),
                          //     child: Padding(
                          //       padding: const EdgeInsets.only(left: 10.0),
                          //       child: TextFormField(
                          //         validator: (value) {
                          //           if (value == null || value.isEmpty) {
                          //             return 'Required Field';
                          //           }
                          //           return null;
                          //         },
                          //         controller: address,
                          //         onChanged: (val) {
                          //           if (selectedCity == null) {
                          //             setState(() {
                          //               address.clear();
                          //             });
                          //             showToast("Please select city first");
                          //           }
                          //         },
                          //         decoration: InputDecoration(
                          //             border: InputBorder.none,
                          //             suffixIcon: IconButton(
                          //                 onPressed: () {
                          //                   if (address.text == "") {
                          //                     print("wo");
                          //                     _determinePosition().then(
                          //                         (value) =>
                          //                             _getAddress(value));
                          //                   }
                          //                 },
                          //                 icon: Icon(Icons.my_location,
                          //                     color: address.text == null
                          //                         ? Colors.deepOrangeAccent
                          //                         : Colors.grey))),
                          //       ),
                          //     )),
                          // SizedBox(height: 10),
                          Text("Pincode*",
                              style: TextStyle(
                                  color: kPrimaryColor,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500)),
                          SizedBox(height: 8.0),

                          Container(
                              decoration: BoxDecoration(
                                  border: Border.all(
                                      width: 1, color: Colors.deepOrangeAccent),
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(12))),
                              child: Padding(
                                  padding: const EdgeInsets.only(left: 10.0),
                                  child: TextField(
                                    controller: pincode,
                                    decoration: InputDecoration(
                                        hintText: pinCode ?? "PinCode",
                                        border: InputBorder.none),
                                  ))),

                          // Container(
                          //     decoration: BoxDecoration(
                          //         border: Border.all(
                          //             width: 1, color: Colors.deepOrangeAccent),
                          //         borderRadius:
                          //             BorderRadius.all(Radius.circular(12))),
                          //     child: Padding(
                          //       padding: const EdgeInsets.only(left: 10.0),
                          //       child: TextFormField(
                          //         keyboardType: TextInputType.number,
                          //         inputFormatters: [
                          //           FilteringTextInputFormatter.digitsOnly
                          //         ],
                          //         validator: (value) {
                          //           if (value == null || value.isEmpty) {
                          //             return 'Required Field';
                          //           }
                          //           return null;
                          //         },
                          //         controller: pincode,
                          //         decoration: InputDecoration(
                          //           hintText: "pincode",
                          //           border: InputBorder.none,
                          //         ),
                          //       ),
                          //     )),

                          SizedBox(height: 10),
                          Text("Communication Preferences*",
                              style: TextStyle(
                                  color: kPrimaryColor,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500)),
                          SizedBox(height: 8.0),
                          Row(
                            // mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  Checkbox(
                                      value: _emailcheck,
                                      onChanged: (value) {
                                        setState(() {
                                          _emailcheck = !_emailcheck;
                                          if (_emailcheck == true) {
                                            checkEmail = "1";
                                            log(checkEmail.toString());
                                          } else {
                                            checkEmail = "";
                                          }
                                        });
                                      }),
                                  Text("Email",
                                      style: TextStyle(
                                          color: kPrimaryColor,
                                          fontWeight: FontWeight.w700))
                                ],
                              ),
                              SizedBox(width: 20),
                              Row(
                                children: [
                                  Checkbox(
                                      value: _smscheck,
                                      onChanged: (value) {
                                        setState(() {
                                          _smscheck = !_smscheck;
                                          if (_smscheck == true) {
                                            checkSms = "2";
                                            log(checkSms.toString());
                                          } else {
                                            checkSms = "";
                                            log("--->" + checkSms.toString());
                                          }
                                        });
                                      }),
                                  Text("SMS",
                                      style: TextStyle(
                                          color: kPrimaryColor,
                                          fontWeight: FontWeight.w700))
                                ],
                              ),
                            ],
                          ),
                          SizedBox(height: 10.0),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text("Trusted Badge*",
                                  style: TextStyle(
                                      color: kPrimaryColor,
                                      fontSize: 16,
                                      fontWeight: FontWeight.w500)),
                              Text("Kyc*",
                                  style: TextStyle(
                                      color: kPrimaryColor,
                                      fontSize: 16,
                                      fontWeight: FontWeight.w500)),
                            ],
                          ),
                          SizedBox(height: 8.0),
                          FormField(
                            builder: (FormFieldState state) {
                              return InputDecorator(
                                decoration: InputDecoration(
                                    suffixIcon: Checkbox(
                                        value: kyc,
                                        onChanged: (val) {
                                          setState(() {
                                            if (tb == true) {
                                              kyc = true;
                                            } else {
                                              kyc = !kyc;
                                            }
                                          });
                                        }),
                                    fillColor: Colors.white,
                                    filled: true,
                                    // labelText: "Select",
                                    isDense: true,
                                    contentPadding: EdgeInsets.all(10),
                                    border: OutlineInputBorder(
                                        borderRadius:
                                            BorderRadius.circular(5.0))),
                                child: DropdownButtonHideUnderline(
                                  child: DropdownButton(
                                    isExpanded: true,
                                    value: initialtrustedbadge,
                                    isDense: true,
                                    onChanged: (newValue) {
                                      if (newValue == "Select") {
                                        showToast("Please select Yes/No");
                                      } else {
                                        setState(() {
                                          initialtrustedbadge = newValue;
                                          if (newValue == "Yes") {
                                            kyc = true;
                                            tb = true;
                                            initialIdProof = "Select";
                                          } else {
                                            // kyc = true;
                                            tb = false;
                                          }
                                        });
                                      }
                                    },
                                    items: _badgedata.map((value) {
                                      return DropdownMenuItem(
                                          value: value,
                                          child: Text(value.toString()));
                                    }).toList(),
                                  ),
                                ),
                              );
                            },
                          ),
                          SizedBox(
                            height: 10,
                          ),
                          kyc == true && country == "India"
                              ? Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text("Aadhar Number",
                                        style: TextStyle(
                                            color: kPrimaryColor,
                                            fontSize: 16,
                                            fontWeight: FontWeight.w500)),
                                    SizedBox(
                                      height: 8,
                                    ),
                                    Container(
                                        height:
                                            MediaQuery.of(context).size.height *
                                                0.065,
                                        decoration: BoxDecoration(
                                            border: Border.all(
                                                width: 1,
                                                color: Colors.deepOrangeAccent),
                                            borderRadius: BorderRadius.all(
                                                Radius.circular(12))),
                                        child: Padding(
                                          padding:
                                              const EdgeInsets.only(left: 10.0),
                                          child: TextFormField(
                                            maxLength: 12,
                                            keyboardType: TextInputType.number,
                                            inputFormatters: [
                                              FilteringTextInputFormatter
                                                  .digitsOnly
                                            ],
                                            validator: (value) {
                                              if (value == null ||
                                                  value.isEmpty) {
                                                return 'Required Field';
                                              }
                                              return null;
                                            },
                                            controller: adharnum,
                                            decoration: InputDecoration(
                                              hintText:
                                                  "Aadhar number (must be 12 digits)",
                                              counterText: "",
                                              border: InputBorder.none,
                                            ),
                                          ),
                                        )),
                                    SizedBox(
                                      height: 10,
                                    ),
                                    Text("Aadhar Card",
                                        style: TextStyle(
                                            color: kPrimaryColor,
                                            fontSize: 16,
                                            fontWeight: FontWeight.w500)),
                                    SizedBox(
                                      height: 8,
                                    ),
                                    Container(
                                        decoration: BoxDecoration(
                                            border: Border.all(
                                                width: 1,
                                                color: Colors.deepOrangeAccent),
                                            borderRadius: BorderRadius.all(
                                                Radius.circular(12))),
                                        child: Padding(
                                          padding: EdgeInsets.symmetric(
                                              vertical: 5.0, horizontal: 8.0),
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              adharcarddoc.toString() == "" ||
                                                      adharcarddoc.toString() ==
                                                          "null"
                                                  ? SizedBox()
                                                  : CircleAvatar(
                                                      radius: 25,
                                                      backgroundImage:
                                                          FileImage(File(
                                                              adharcarddoc)),
                                                    ),
                                              InkWell(
                                                onTap: () {
                                                  FocusScope.of(context)
                                                      .unfocus();
                                                  _captureadharcard(true);
                                                },
                                                child: Container(
                                                  height: 45,
                                                  width: 120,
                                                  alignment: Alignment.center,
                                                  decoration:
                                                      const BoxDecoration(
                                                          color: Colors
                                                              .deepOrangeAccent,
                                                          borderRadius:
                                                              BorderRadius.all(
                                                                  Radius
                                                                      .circular(
                                                                          8.0))),
                                                  child: Text("Choose file",
                                                      style: TextStyle(
                                                          color: Colors.white,
                                                          fontSize: 16)),
                                                ),
                                              )
                                            ],
                                          ),
                                        ))
                                  ],
                                )
                              : kyc == true && country != "India"
                                  ? Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text("Select Id Proof",
                                            style: TextStyle(
                                                color: kPrimaryColor,
                                                fontSize: 16,
                                                fontWeight: FontWeight.w500)),
                                        SizedBox(height: 8.0),
                                        FormField(
                                          builder: (FormFieldState state) {
                                            return InputDecorator(
                                              decoration: InputDecoration(
                                                  fillColor: Colors.white,
                                                  filled: true,
                                                  isDense: true,
                                                  contentPadding:
                                                      EdgeInsets.all(10),
                                                  border: OutlineInputBorder(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              5.0))),
                                              child:
                                                  DropdownButtonHideUnderline(
                                                child: DropdownButton(
                                                  isExpanded: true,
                                                  value: initialIdProof,
                                                  isDense: true,
                                                  onChanged: (newValue) {
                                                    if (newValue == "Select") {
                                                      showToast(
                                                          "Please select Id Proof");
                                                    } else {
                                                      setState(() {
                                                        initialIdProof =
                                                            newValue;
                                                        adharcarddoc = "";
                                                        adharnum.clear();
                                                        passportDoc = "";
                                                        dlDoc = "";
                                                        pasportNumber.clear();
                                                        drivingLicenseNumber
                                                            .clear();
                                                      });
                                                    }
                                                  },
                                                  items: [
                                                    "Select",
                                                    "Passport",
                                                    "Driving Licence"
                                                  ].map((value) {
                                                    return DropdownMenuItem(
                                                        value: value,
                                                        child: Text(
                                                            value.toString()));
                                                  }).toList(),
                                                ),
                                              ),
                                            );
                                          },
                                        ),
                                        SizedBox(
                                          height: 8,
                                        ),
                                        initialIdProof == "Select"
                                            ? SizedBox()
                                            : Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                      initialIdProof +
                                                          " Number",
                                                      style: TextStyle(
                                                          color: kPrimaryColor,
                                                          fontSize: 16,
                                                          fontWeight:
                                                              FontWeight.w500)),
                                                  SizedBox(
                                                    height: 8,
                                                  ),
                                                  Container(
                                                      decoration: BoxDecoration(
                                                          border: Border.all(
                                                              width: 1,
                                                              color: Colors
                                                                  .deepOrangeAccent),
                                                          borderRadius:
                                                              BorderRadius.all(
                                                                  Radius
                                                                      .circular(
                                                                          12))),
                                                      child: Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                    .only(
                                                                left: 10.0),
                                                        child: TextFormField(
                                                          controller: initialIdProof ==
                                                                  "Select"
                                                              ? ""
                                                              : initialIdProof ==
                                                                      "Driving Licence"
                                                                  ? drivingLicenseNumber
                                                                  : initialIdProof ==
                                                                          "Passport"
                                                                      ? pasportNumber
                                                                      : "",
                                                          decoration:
                                                              InputDecoration(
                                                            border: InputBorder
                                                                .none,
                                                          ),
                                                        ),
                                                      )),
                                                  SizedBox(
                                                    height: 10,
                                                  ),
                                                  Text(
                                                      "Upload " +
                                                          initialIdProof,
                                                      style: TextStyle(
                                                          color: kPrimaryColor,
                                                          fontSize: 16,
                                                          fontWeight:
                                                              FontWeight.w500)),
                                                  SizedBox(
                                                    height: 8,
                                                  ),
                                                  Container(
                                                      decoration: BoxDecoration(
                                                          border: Border.all(
                                                              width: 1,
                                                              color: Colors
                                                                  .deepOrangeAccent),
                                                          borderRadius:
                                                              BorderRadius.all(
                                                                  Radius
                                                                      .circular(
                                                                          12))),
                                                      child: Padding(
                                                        padding: EdgeInsets
                                                            .symmetric(
                                                                vertical: 5.0,
                                                                horizontal:
                                                                    8.0),
                                                        child: Row(
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .spaceBetween,
                                                          children: [
                                                            initialIdProof ==
                                                                    "Passport"
                                                                ? CircleAvatar(
                                                                    radius: 25,
                                                                    backgroundImage:
                                                                        FileImage(
                                                                            File(passportDoc)),
                                                                  )
                                                                : initialIdProof ==
                                                                        "Driving Licence"
                                                                    ? CircleAvatar(
                                                                        radius:
                                                                            25,
                                                                        backgroundImage:
                                                                            FileImage(File(dlDoc)),
                                                                      )
                                                                    : "",
                                                            InkWell(
                                                              onTap: () {
                                                                FocusScope.of(
                                                                        context)
                                                                    .unfocus();
                                                                _captureadharcard(
                                                                    false);
                                                              },
                                                              child: Container(
                                                                height: 45,
                                                                width: 120,
                                                                alignment:
                                                                    Alignment
                                                                        .center,
                                                                decoration: const BoxDecoration(
                                                                    color: Colors
                                                                        .deepOrangeAccent,
                                                                    borderRadius:
                                                                        BorderRadius.all(
                                                                            Radius.circular(8.0))),
                                                                child: Text(
                                                                    "Choose file",
                                                                    style: TextStyle(
                                                                        color: Colors
                                                                            .white,
                                                                        fontSize:
                                                                            16)),
                                                              ),
                                                            )
                                                          ],
                                                        ),
                                                      ))
                                                ],
                                              ),
                                      ],
                                    )
                                  : SizedBox()
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: 10),
                  SizedBox(height: 10),
                  userType == 3 ? bankDetailsWidget() : Container(),
                  SizedBox(height: 10),
                  SizedBox(height: 10),
                  userType == 3
                      ? InkWell(
                          onTap: () {
                            // if (kyc == "1") {

                            if (!_emailcheck && !_smscheck) {
                              showToast("Please check either email or sms");
                            } else if (initialtrustedbadge == "Select") {
                              showToast("Please select Trusted Badge");
                            } else if (tb == true &&
                                country == "India" &&
                                adharcarddoc == "") {
                              showToast("Please upload Aadhaar Card");
                            } else if (kyc == true &&
                                country != "India" &&
                                initialIdProof == "Select") {
                              showToast("Please select Id Proof");
                            } else if (kyc == true &&
                                country != "India" &&
                                passportDoc == "" &&
                                dlDoc == "") {
                              showToast("Please upload " +
                                  initialIdProof.toString() +
                                  " documents");
                            } else if (pincode == null ||
                                pincode == "null" ||
                                pincode.text.isEmpty) {
                              showToast("Please Enter Your Pincode");
                            } else if (destinationPoint.text.isEmpty) {
                              showToast("Please Select Your Location");
                            } else {
                              submitDetailsOfConsumer();
                            }
                          },
                          child: SizedBox(
                            width: double.infinity,
                            child: Card(
                              elevation: 12.0,
                              color: Colors.deepOrangeAccent,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(24.0),
                              ),
                              child: Padding(
                                padding: EdgeInsets.symmetric(
                                    vertical: 15, horizontal: 10),
                                child: Text(
                                  buttonLoading == true
                                      ? "Please Wait..."
                                      : "CONTINUE",
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                      color: Colors.white, fontSize: 16),
                                ),
                              ),
                            ),
                          ),
                        )
                      : InkWell(
                          onTap: () {
                            // if (kyc == "1") {

                            if (!_emailcheck && !_smscheck) {
                              showToast("Please check either email or sms");
                            } else if (initialtrustedbadge == "Select") {
                              showToast("Please select Trusted Badge");
                            } else if (tb == true &&
                                country == "India" &&
                                adharcarddoc == "") {
                              showToast("Please upload Aadhaar Card");
                            } else if (kyc == true &&
                                country != "India" &&
                                initialIdProof == "Select") {
                              showToast("Please select Id Proof");
                            } else if (kyc == true &&
                                country != "India" &&
                                passportDoc == "" &&
                                dlDoc == "") {
                              showToast("Please upload " +
                                  initialIdProof.toString() +
                                  " documents");
                            } else if (destinationPoint.text.isEmpty) {
                              showToast("Please Select Your Location");
                            } else if (pincode == null ||
                                pincode == "null" ||
                                pincode.text.isEmpty) {
                              showToast("Please Enter Your Pincode");
                            } else if (key.currentState.validate()) {
                              submitPersonalDetails();
                            }
                          },
                          child: SizedBox(
                            width: double.infinity,
                            child: Card(
                              elevation: 12.0,
                              color: Colors.deepOrangeAccent,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(24.0),
                              ),
                              child: Padding(
                                padding: EdgeInsets.symmetric(
                                    vertical: 15, horizontal: 10),
                                child: Text(
                                  buttonLoading == true
                                      ? "Please Wait..."
                                      : "CONTINUE",
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                      color: Colors.white, fontSize: 16),
                                ),
                              ),
                            ),
                          ),
                        ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future _getcheckapproveData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final body = {
      "user_id": prefs.getString('userid'),
    };
    var response = await http.post(Uri.parse(BASE_URL + checkapprove),
        body: jsonEncode(body),
        headers: {
          "Accept": "application/json",
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${prefs.getString("token")}',
        });
    print(response.body);
    print(prefs.getString('userid'));
    if (response.statusCode == 200) {
      var data = json.decode(response.body)['Response'];
      setState(() {
        // usertype = data['user_type'].toString();
        // usertype = "3";
      });
    } else {
      throw Exception('Failed to get data due to ${response.body}');
    }
  }

  Widget bankDetailsWidget() {
    return Card(
        elevation: 4.0,
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 10, horizontal: 15),
          child: Column(
            children: [
              const Text("Bank Detail ",
                  style: TextStyle(
                      color: kPrimaryColor,
                      fontSize: 18,
                      fontWeight: FontWeight.w700)),
              const SizedBox(height: 10),
              const Align(
                alignment: Alignment.topLeft,
                child: Text("Bank Name",
                    style: TextStyle(
                        color: kPrimaryColor, fontWeight: FontWeight.w500)),
              ),
              const SizedBox(height: 8),
              Container(
                  height: MediaQuery.of(context).size.height * 0.065,
                  decoration: BoxDecoration(
                      border:
                          Border.all(width: 1, color: Colors.deepOrangeAccent),
                      borderRadius: BorderRadius.all(Radius.circular(12))),
                  child: Padding(
                    padding: const EdgeInsets.only(left: 10.0),
                    child: TextFormField(
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Required Field';
                        }
                        return null;
                      },
                      decoration: InputDecoration(
                        border: InputBorder.none,
                      ),
                      controller: bankName,
                    ),
                  )),
              const SizedBox(height: 10),
              const Align(
                alignment: Alignment.topLeft,
                child: Text("Branch Name",
                    style: TextStyle(
                        color: kPrimaryColor, fontWeight: FontWeight.w500)),
              ),
              const SizedBox(height: 8),
              Container(
                  height: MediaQuery.of(context).size.height * 0.065,
                  decoration: BoxDecoration(
                      border:
                          Border.all(width: 1, color: Colors.deepOrangeAccent),
                      borderRadius: BorderRadius.all(Radius.circular(12))),
                  child: Padding(
                    padding: const EdgeInsets.only(left: 10.0),
                    child: TextFormField(
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Required Field';
                        }
                        return null;
                      },
                      decoration: InputDecoration(
                        border: InputBorder.none,
                      ),
                      controller: branchName,
                    ),
                  )),
              const SizedBox(height: 10),
              const Align(
                alignment: Alignment.topLeft,
                child: Text("Account Number",
                    style: TextStyle(
                        color: kPrimaryColor, fontWeight: FontWeight.w500)),
              ),
              const SizedBox(height: 8),
              Container(
                  height: MediaQuery.of(context).size.height * 0.065,
                  decoration: BoxDecoration(
                      border:
                          Border.all(width: 1, color: Colors.deepOrangeAccent),
                      borderRadius: BorderRadius.all(Radius.circular(12))),
                  child: Padding(
                    padding: const EdgeInsets.only(left: 10.0),
                    child: TextFormField(
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Required Field';
                        }
                        return null;
                      },
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      decoration: InputDecoration(
                        border: InputBorder.none,
                      ),
                      controller: accountNo,
                    ),
                  )),
              const SizedBox(height: 10),
              const Align(
                alignment: Alignment.topLeft,
                child: Text("Account Type",
                    style: TextStyle(
                        color: kPrimaryColor, fontWeight: FontWeight.w500)),
              ),
              const SizedBox(height: 8),
              Container(
                height: 55,
                decoration:
                    BoxDecoration(borderRadius: BorderRadius.circular(15)),
                child: FormField(
                  builder: (FormFieldState state) {
                    return InputDecorator(
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
                          // Initial Value

                          value: dropdownvalue,

                          // Down Arrow Icon
                          icon: const Icon(Icons.keyboard_arrow_down),

                          // Array list of items
                          items: items.map((String items) {
                            return DropdownMenuItem(
                              value: items,
                              child: Text(items),
                            );
                          }).toList(),
                          // After selecting the desired option,it will
                          // change button value to selected value
                          onChanged: (String newValue) {
                            setState(() {
                              dropdownvalue = newValue;
                              log("====>$dropdownvalue");
                            });
                          },
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 10),
              const Align(
                alignment: Alignment.topLeft,
                child: Text("IFSC Code",
                    style: TextStyle(
                        color: kPrimaryColor, fontWeight: FontWeight.w500)),
              ),
              const SizedBox(height: 8),
              Container(
                  height: MediaQuery.of(context).size.height * 0.065,
                  decoration: BoxDecoration(
                      border:
                          Border.all(width: 1, color: Colors.deepOrangeAccent),
                      borderRadius: BorderRadius.all(Radius.circular(12))),
                  child: Padding(
                    padding: const EdgeInsets.only(left: 10.0),
                    child: TextFormField(
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Required Field';
                        }
                        return null;
                      },
                      decoration: InputDecoration(
                        border: InputBorder.none,
                      ),
                      controller: iFSCCode,
                    ),
                  )),
            ],
          ),
        ));
  }

  String currentLattitude = "";
  String currentLongitude = "";
  TextEditingController currentPoint = TextEditingController();
  // Destination Loctaion Controller
  String destinationLattitude = "";
  String destinationLongitude = "";
  TextEditingController destinationPoint = TextEditingController();
  bool showData = false;
  bool getCurrentLocation = false;
  List places;
  var placecounts = 0;

  LatLng _center;
  Position currentLocation;
  String location = 'Null, Press Button';
  String lati = '';
  String land = '';
  LatLng pinPosition;

  Future<Position> locateUser() async {
    LocationPermission permission;
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    } else if (permission == LocationPermission.whileInUse) {
    } else if (permission == LocationPermission.always) {
    } else if (permission == LocationPermission.deniedForever) {
      permission = await Geolocator.requestPermission();
    } else {
      throw Exception('Error');
    }
    return Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
  }

  getUserLocation(BuildContext context) async {
    currentLocation = await locateUser();
    // onLoading(context);
    setState(() {
      _center = LatLng(currentLocation.latitude, currentLocation.longitude);
      lati = currentLocation.latitude.toString();
      land = currentLocation.longitude.toString();
      pinPosition = LatLng(currentLocation.latitude, currentLocation.longitude);
      currentLattitude = lati.toString();
      currentLongitude = land.toString();
      getAddressFromLatLong();
      getCurrentLocation = true;
    });
    // Navigator.pop(context);
    // print('latitude${currentLocation.latitude}');
    // print('longitude${currentLocation.longitude}');
  }

  getAddressFromLatLong() async {
    List<Placemark> placemarks =
        await placemarkFromCoordinates(double.parse(lati), double.parse(land));
    // log("placemark==> $placemarks");
    Placemark place = placemarks[0];
    String name = place.name.toString();
    String subLocality = place.subLocality.toString();
    locality = place.locality.toString();
    log("------>" + locality);
    String administrativeArea = place.administrativeArea.toString();
    String postalCode = place.postalCode.toString();
    String country = place.country.toString();
    String address =
        "$name, $subLocality, $locality, $administrativeArea $postalCode, $country";

    // log('Address ${Country.toString()}');
    //setState(() {
    currentPoint.text = address.toString();
    // });
  }

  String locality = '';
  String destilocality = "";
  getAddressFromLatLongDesti(String latitude, longitude) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<Placemark> placemarks = await placemarkFromCoordinates(
        double.parse(latitude), double.parse(longitude));
    // log("placemark==> $placemarks");
    Placemark place = placemarks[0];
    prefs.setString('country', place.country.toString());
    log(prefs.getString('country'));
    getPrefsData();

    destilocality = place.locality.toString();
    log("=--->" + destilocality);
  }

  Future getLocations(String locationName) async {
    var kGoogleApiKey = Apis.mapKey.toString();
    var url = Uri.tryParse(
        "https://maps.googleapis.com/maps/api/place/findplacefromtext/json?input=" +
            locationName +
            "&inputtype=textquery&fields=formatted_address,geometry&location=20.7711857,73.729974&radius=10000&key=" +
            kGoogleApiKey);

    http.Response res = await http.get(url);
    setState(() {
      showData = true;
      places = json.decode(res.body)['candidates'];
      placecounts = places.length;
    });
  }

  String locations = '';

  // Future _setLocation(locations, lattitude, longitude) async {
  //   var sp = await SharedPreferences.getInstance();
  //   sp.setString(SpKey.location, locations);
  //   sp.setString(SpKey.latitude, lattitude.toString());
  //   sp.setString(SpKey.longitude, longitude.toString());
  //   Navigator.pop(context);
  // }

  Future _getprofile() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final body = {
      "id": prefs.getString('userid'),
    };
    var response = await http.post(Uri.parse(BASE_URL + profileUrl),
        body: jsonEncode(body),
        headers: {
          "Accept": "application/json",
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${prefs.getString("token")}',
        });
    log(response.body);
    if (response.statusCode == 200) {
      var data = json.decode(response.body)['Response'];
      setState(() {
        // businessName = data['User']['business_name'].toString();
        // prefs.setString('businessName', businessName);
        // log("---->" + prefs.getString('businessName'));
        // country_id = data['User']['country'];
        // state_id = data['User']['state'];
        // city_id = data['User']['city'];

        // selectedCountry = data['User']['country_name'].toString();
        log("Select country---->$selectedCountry");
        selectedState = data['User']['state_name'].toString();
        selectedCity = data['User']['city_name'].toString();

        bankname.text = data['User']['bank_name'].toString();
        branchname.text = data['User']['branch_name'].toString();
        accountno.text = data['User']['account_no'].toString();
        accounttype.text = data['User']['account_type'].toString();
        userType = data['User']['user_type'];
        log("usertype-=-->$userType");
        ifsccode.text = data['User']['ifsc'].toString();
        // pincode.text = data['User']['pincode'].toString();
        // pincode.text??"pinCode"??"PinCode";

        initialtrustedbadge =
            data['User']['trusted_badge'].toString() == "1" ? "Yes" : "No";
        kyc = data['User']['kyc'].toString() == "1" ? true : false;
      });
    } else {
      throw Exception('Failed to get data due to ${response.body}');
    }
  }

  Future _getprofileData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final body = {
      "id": prefs.getString('userid'),
    };
    var response = await http.post(Uri.parse(BASE_URL + profileUrl),
        body: jsonEncode(body),
        headers: {
          "Accept": "application/json",
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${prefs.getString("token")}',
        });
    if (response.statusCode == 200) {
      var data = json.decode(response.body)['Response'];
      prefs.setString("selectedCountry", data['User']['country_name']);
      prefs.setString("selectedState", data['User']['state_name']);
      prefs.setString("selectedState", data['User']['city_name']);
      prefs.setString("selectedAddress", data['User']['address']);
      if (data['User']['package_id'] != null &&
          data['User']['package_id'] != 1) {
        if (data['User']['payment_status'].toString() == "1") {
          Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                  builder: (BuildContext context) => Dashboard()));
        } else {
          Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                  builder: (BuildContext context) => MakePaymentScreen()));
        }
      } else {
        Navigator.pushReplacement(context,
            MaterialPageRoute(builder: (BuildContext context) => Dashboard()));
      }
    } else {
      throw Exception('Failed to get data due to ${response.body}');
    }
  }

  Future _getcountryData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _loading = true;
    });
    var response = await http.get(Uri.parse(BASE_URL + getCountries), headers: {
      "Accept": "application/json",
      'Content-Type': 'application/json',
    });
    print("===>$response");
    if (response.statusCode == 200) {
      Iterable list = json.decode(response.body)['Response']['countries'];
      setState(() {
        // countrylistData.add({"name": "Select", "id": 0});
        countrylistData.addAll(list);
        _loading = false;

        // _getStateData(prefs.getInt('countryId'));
      });
    } else {
      print(response.body);
      throw Exception('Failed to get data due to ${response.body}');
    }
  }

  Future _getStateData(int id) async {
    setState(() {
      _loading = true;
      statelistData.clear();
    });
    final body = {
      "id": id,
    };
    var response = await http
        .post(Uri.parse(BASE_URL + getState), body: jsonEncode(body), headers: {
      "Accept": "application/json",
      'Content-Type': 'application/json',
    });
    //print(response.body);
    if (response.statusCode == 200) {
      Iterable list = json.decode(response.body)['Response']['states'];
      setState(() {
        _loading = false;
        statelistData.addAll(list);

        for (var element in statelistData) {
          setState(() {
            stateId = element['id'].toString();
            log("stateId---->$stateId");
          });
        }
      });
    } else {
      throw Exception('Failed to get data due to ${response.body}');
    }
  }

  Future _getCityData(int id) async {
    setState(() {
      _loading = true;
      citylistData.clear();
    });
    final body = {
      "id": id.toString(),
    };
    log(body.toString());
    var response = await http.post(Uri.parse(BASE_URL + getCity),
        body: jsonEncode(body),
        headers: {
          "Accept": "application/json",
          'Content-Type': 'application/json'
        });
    if (response.statusCode == 200) {
      Iterable list = json.decode(response.body)['Response']['cities'];
      setState(() {
        _loading = false;
        citylistData.addAll(list);
      });
    } else {
      print(response.body);
      throw Exception('Failed to get data due to ${response.body}');
    }
  }

  Future submitPersonalDetailsNew() async {
    List comPrefList = [];
    if (checkEmail == "1") {
      comPrefList.add("1");
    }
    if (checkSms == "2") {
      comPrefList.add('2');
    }
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String kycdone = '';
    String trustedBadge = '';
    if (initialtrustedbadge == "Yes") {
      setState(() {
        trustedBadge = "1";
      });
    } else {
      setState(() {
        trustedBadge = "0";
      });
    }
    if (kyc == true) {
      setState(() {
        kycdone = "1";
      });
    } else {
      setState(() {
        kycdone = "0";
      });
    }
    log('Bearer ${prefs.getString("token")}');

    String userId = prefs.getString('userid');
    setState(() {
      buttonLoading = true;
    });
    var bodyMap = country != "India" && initialIdProof == "Passport"
        ? {
            "pincode": pincode.text.toString(),
            "location": locationUser.toString(),
            "kyc": kycdone.toString(),
            "com_prefs": comPrefList.join(','),
            "kyc_document_type": initialIdProof == "Select"
                ? ""
                : initialIdProof == "Passport"
                    ? "passport"
                    : initialIdProof == "Driving Licence"
                        ? "driving_license"
                        : "",
            "trusted_badge": trustedBadge.toString(),
            "passport_no": pasportNumber.text.toString(),
            "passport_doc": passportDoc.toString()
          }
        : country != "India" && initialIdProof == "Driving Licence"
            ? {
                "pincode": pincode.text.toString(),
                "location": locationUser.toString(),
                "kyc": kycdone.toString(),
                "com_prefs": comPrefList.join(','),
                "kyc_document_type": initialIdProof == "Select"
                    ? ""
                    : initialIdProof == "Passport"
                        ? "passport"
                        : initialIdProof == "Driving Licence"
                            ? "driving_license"
                            : "",
                "trusted_badge": trustedBadge.toString(),
                "driving_license_no": drivingLicenseNumber.text.toString(),
                "driving_license_doc": dlDoc.toString(),
              }
            : {
                "pincode": pincode.text.toString(),
                "location": locationUser.toString(),
                "kyc": kycdone.toString(),
                "com_prefs": comPrefList.join(','),
                "trusted_badge": trustedBadge.toString(),
                "adhaar_no": adharnum.text.toString(),
                "adhaar_doc": adharcarddoc.toString(),
              };

    var url = BASE_URL + "personal-profile-update";

    var response = await APIHelper.apiPostRequest(url, bodyMap);

    log("body-->$bodyMap");
    log("response-->"+response.toString());

    var result = jsonDecode(response);
    if (result['ErrorCode'] == 0) {
      Navigator.pushReplacement(context,
          MaterialPageRoute(builder: (context) => BillingAndTaxation()));
      Fluttertoast.showToast(
        msg: showToast(result['ErrorMessage']),
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.CENTER,
        timeInSecForIosWeb: 1,
        backgroundColor: Colors.green.shade700,
        textColor: Colors.white,
        fontSize: 16.0,
      );
    } else {
      Fluttertoast.showToast(
        msg: showToast(result['ErrorMessage']),
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.CENTER,
        timeInSecForIosWeb: 1,
        backgroundColor: Colors.green.shade700,
        textColor: Colors.white,
        fontSize: 16.0,
      );
    }
  }

  Future submitPersonalDetails() async {
    List comPrefList = [];
    if (checkEmail == "1") {
      comPrefList.add("1");
    }
    if (checkSms == "2") {
      comPrefList.add('2');
    }
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String kycdone = '';
    String trustedBadge = '';
    if (initialtrustedbadge == "Yes") {
      setState(() {
        trustedBadge = "1";
      });
    } else {
      setState(() {
        trustedBadge = "0";
      });
    }
    if (kyc == true) {
      setState(() {
        kycdone = "1";
      });
    } else {
      setState(() {
        kycdone = "0";
      });
    }
    log('Bearer ${prefs.getString("token")}');

    String userId = prefs.getString('userid');
    setState(() {
      buttonLoading = true;
    });
    var url = BASE_URL + personalupdate;
    var bodyMap = country != "India" && initialIdProof == "Passport"
        ? {
            "pincode": pincode.text.toString(),
            "location": locationUser.toString(),
            "kyc": kycdone.toString(),
            "com_prefs": comPrefList.join(','),
            "kyc_document_type": initialIdProof == "Select"
                ? ""
                : initialIdProof == "Passport"
                    ? "passport"
                    : initialIdProof == "Driving Licence"
                        ? "driving_license"
                        : "",
            "trusted_badge": trustedBadge.toString(),
            "passport_no": pasportNumber.text.toString(),
            "passport_doc": passportDoc.toString()
          }
        : country != "India" && initialIdProof == "Driving Licence"
            ? {
                "pincode": pincode.text.toString(),
                "location": locationUser.toString(),
                "kyc": kycdone.toString(),
                "com_prefs": comPrefList.join(','),
                "kyc_document_type": initialIdProof == "Select"
                    ? ""
                    : initialIdProof == "Passport"
                        ? "passport"
                        : initialIdProof == "Driving Licence"
                            ? "driving_license"
                            : "",
                "trusted_badge": trustedBadge.toString(),
                "driving_license_no": drivingLicenseNumber.text.toString(),
                "driving_license_doc": dlDoc.toString(),
              }
            : {
                "pincode": pincode.text.toString(),
                "location": locationUser.toString(),
                "kyc": kycdone.toString(),
                "com_prefs": comPrefList.join(','),
                "trusted_badge": trustedBadge.toString(),
                "adhaar_no": adharnum.text.toString(),
              };

    try {
      final request = http.MultipartRequest('POST', Uri.parse(url));

      request.headers.addAll({
        'Authorization': 'Bearer ${prefs.getString("token")}',
      });
      if (kyc == true && country == "India") {
        var pic = await http.MultipartFile.fromPath(
            'adhaar_doc', adharcarddoc.toString());
        request.files.add(pic);
        log("ENTETED====>  $pic");
        } else if (initialIdProof == "Passport" && country != "India") {
          var passportPic = await http.MultipartFile.fromPath(
              'passport_doc', passportDoc.toString());
          request.files.add(passportPic);
          log("ENTETED====>  $passportPic");
        } else if (initialIdProof == "Driving Licence" && country != "India") {
          var dlPic = await http.MultipartFile.fromPath(
              'driving_license_doc', passportDoc.toString());
          request.files.add(dlPic);
          log("ENTETED====>  $dlPic");
        } else {
          log("no data");
        }
      
      request.fields.addAll(bodyMap);
      var response = await request.send();

      log("body=====>$bodyMap");

      var responseData = await response.stream.toBytes();
      var responseString = String.fromCharCodes(responseData);

      log("Requests--->$request");
      log("PostResponse----> $responseString");
      log("StatusCodePost---->${response.statusCode}");
      log("response---->$response");
      log("responseData---->$responseData");

      if (response.statusCode >= 200 && response.statusCode <= 299) {
        log("StatusCodePost11---->${response.statusCode}");
        var result = jsonDecode(responseString);
        if (result['ErrorCode'] == 0) {
          Navigator.pushReplacement(context,
              MaterialPageRoute(builder: (context) => BillingAndTaxation()));
          Fluttertoast.showToast(
            msg: showToast(result['ErrorMessage']),
            toastLength: Toast.LENGTH_LONG,
            gravity: ToastGravity.CENTER,
            timeInSecForIosWeb: 1,
            backgroundColor: Colors.green.shade700,
            textColor: Colors.white,
            fontSize: 16.0,
          );
        } else {
          Fluttertoast.showToast(
            msg: showToast(result['ErrorMessage']),
            toastLength: Toast.LENGTH_LONG,
            gravity: ToastGravity.CENTER,
            timeInSecForIosWeb: 1,
            backgroundColor: Colors.green.shade700,
            textColor: Colors.white,
            fontSize: 16.0,
          );
        }
      }
    } on Exception catch (e) {}
    setState(() {
      buttonLoading = false;
    });
  }

  Future<void> _captureadharcard(bool imageFor) async {
    final ImagePicker _picker = ImagePicker();
    await showModalBottomSheet(
        shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(20.0))),
        backgroundColor: Colors.white,
        context: context,
        isScrollControlled: true,
        builder: (context) => Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Padding(
                    padding: EdgeInsets.fromLTRB(12, 0, 7, 0),
                    child: Text(
                      'Select',
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ElevatedButton.icon(
                          onPressed: () async {
                            final XFile result = await _picker.pickImage(
                              source: ImageSource.camera,
                              imageQuality: 80,
                              maxHeight: 480,
                              maxWidth: 640,
                            );
                            if (result != null) {
                              if (country == "India") {
                                setState(() {
                                  adharcarddoc = result.path.toString();
                                });
                              } else {
                                setState(() {
                                  if (initialIdProof == "Select") {
                                  } else if (initialIdProof ==
                                      "Driving Licence") {
                                    dlDoc = result.path.toString();
                                    log("dl doc" + dlDoc.toString());
                                  } else if (initialIdProof == "Passport") {
                                    passportDoc = result.path.toString();
                                    log("passport doc" +
                                        passportDoc.toString());
                                  }
                                });
                              }
                            }
                            Navigator.of(context).pop();
                          },
                          style: ButtonStyle(
                              backgroundColor:
                                  MaterialStateProperty.all(Colors.white),
                              shape: MaterialStateProperty.all(
                                  RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(18.0),
                                      side: BorderSide(color: Colors.grey)))),
                          icon: const Icon(Icons.camera, color: Colors.black),
                          label: const Text("Camera",
                              style: TextStyle(color: Colors.black))),
                      const SizedBox(width: 30),
                      ElevatedButton.icon(
                          onPressed: () async {
                            final XFile result = await _picker.pickImage(
                              source: ImageSource.gallery,
                              imageQuality: 80,
                              maxHeight: 480,
                              maxWidth: 640,
                            );

                            if (result != null) {
                              if (country == "India") {
                                setState(() {
                                  adharcarddoc = result.path.toString();
                                });
                              } else {
                                setState(() {
                                  if (initialIdProof == "Select") {
                                  } else if (initialIdProof ==
                                      "Driving Licence") {
                                    dlDoc = result.path.toString();
                                    log("dl doc" + dlDoc.toString());
                                  } else if (initialIdProof == "Passport") {
                                    passportDoc = result.path.toString();
                                    log("passport doc" +
                                        passportDoc.toString());
                                  }
                                });
                              }
                            }
                            Navigator.of(context).pop();
                          },
                          style: ButtonStyle(
                              backgroundColor:
                                  MaterialStateProperty.all(Colors.white),
                              shape: MaterialStateProperty.all(
                                  RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(18.0),
                                      side: BorderSide(color: Colors.grey)))),
                          icon: const Icon(Icons.photo, color: Colors.black),
                          label: const Text("Gallery",
                              style: TextStyle(color: Colors.black))),
                    ],
                  )
                ])));
  }

  Future<Position> _determinePosition() async {
    setState(() {
      _loading = true;
    });
    bool serviceEnabled;
    LocationPermission permission;
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return Future.error('Location services are disabled.');
    }
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error('Location permissions are denied');
      }
    }
    if (permission == LocationPermission.deniedForever) {
      // Permissions are denied forever, handle appropriately.
      return Future.error(
          'Location permissions are permanently denied, we cannot request permissions.');
    }
    return await Geolocator.getCurrentPosition();
  }

  Future<void> _getAddress(value) async {
    List<Placemark> placemarks =
        await placemarkFromCoordinates(value.latitude, value.longitude);
    print(placemarks);
    Placemark place = placemarks[0];
    setState(() {
      _loading = false;
      address.text = place.subLocality.toString() +
          "," +
          place.locality.toString() +
          "," +
          place.postalCode.toString() +
          "," +
          place.administrativeArea.toString() +
          "," +
          place.country.toString();
    });
  }

  Future<void> _capturedoc(String type) async {
    final ImagePicker _picker = ImagePicker();
    await showModalBottomSheet(
        shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(20.0))),
        backgroundColor: Colors.white,
        context: context,
        isScrollControlled: true,
        builder: (context) => Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Padding(
                    padding: EdgeInsets.fromLTRB(12, 0, 7, 0),
                    child: Text(
                      'Select',
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ElevatedButton.icon(
                          onPressed: () async {
                            final XFile result = await _picker.pickImage(
                              source: ImageSource.camera,
                              imageQuality: 80,
                              maxHeight: 480,
                              maxWidth: 640,
                            );
                            if (result != null) {
                              if (type == "gst") {
                                setState(() {
                                  gstdoc = result.path.toString();
                                });
                              } else if (type == "adhar") {
                                setState(() {
                                  adharcarddoc = result.path.toString();
                                  decodeImages =
                                      base64Decode(adharcarddoc).toString();
                                });
                              } else {
                                setState(() {
                                  pancarddoc = result.path.toString();
                                  decodeImages =
                                      base64Decode(pancarddoc).toString();
                                });
                              }
                            }
                            Navigator.of(context).pop();
                          },
                          style: ButtonStyle(
                              backgroundColor:
                                  MaterialStateProperty.all(Colors.white),
                              shape: MaterialStateProperty.all(
                                  RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(18.0),
                                      side: BorderSide(color: Colors.grey)))),
                          icon: const Icon(Icons.camera, color: Colors.black),
                          label: const Text("Camera",
                              style: TextStyle(color: Colors.black))),
                      const SizedBox(width: 30),
                      ElevatedButton.icon(
                          onPressed: () async {
                            final XFile result = await _picker.pickImage(
                              source: ImageSource.gallery,
                              imageQuality: 80,
                              maxHeight: 480,
                              maxWidth: 640,
                            );
                            if (result != null) {
                              if (type == "gst") {
                                setState(() {
                                  gstdoc = result.path.toString();
                                });
                              } else if (type == "adhar") {
                                setState(() {
                                  adharcarddoc = result.path.toString();
                                  decodeImages =
                                      base64Decode(adharcarddoc).toString();
                                  log("images--->" + decodeImages);
                                });
                              } else {
                                setState(() {
                                  pancarddoc = result.path.toString();
                                  decodeImages =
                                      base64Decode(pancarddoc).toString();
                                });
                              }
                            }
                            Navigator.of(context).pop();
                          },
                          style: ButtonStyle(
                              backgroundColor:
                                  MaterialStateProperty.all(Colors.white),
                              shape: MaterialStateProperty.all(
                                  RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(18.0),
                                      side: BorderSide(color: Colors.grey)))),
                          icon: const Icon(Icons.photo, color: Colors.black),
                          label: const Text("Gallery",
                              style: TextStyle(color: Colors.black))),
                    ],
                  )
                ])));
  }

  String panno;
  String gstno;
  String adharno;
  String gstdoc;
  String pancarddoc;
  String businessname;

  Future submitDetailsOfConsumer() async {
    String kycdone = '';
    String trustedBadge = '';
    setState(() {
      buttonLoading = true;
    });
    SharedPreferences preferences = await SharedPreferences.getInstance();
    List comPrefList = [];
    if (checkEmail == "1") {
      comPrefList.add("1");
    }
    if (checkSms == "2") {
      comPrefList.add('2');
    }
    if (initialtrustedbadge == "Yes") {
      setState(() {
        trustedBadge = "1";
      });
    } else {
      setState(() {
        trustedBadge = "0";
      });
    }
    if (kyc == true) {
      setState(() {
        kycdone = "1";
      });
    } else {
      setState(() {
        kycdone = "0";
      });
    }
    String userId = preferences.getString("userid");
    log("userId--->" + userId);
    var url = Apis.personalDetailsApi;
    var body = {
      "id": userId.toString(),
      // "address": address.text.toString(),
      // "country": country_id.toString(),
      // "state": state_id.toString(),
      "pincode": pincode.text.toString(),
      // "city": city_id.toString(),
      "location": locationUser.toString(),
      "kyc": kycdone.toString(),
      "com_prefs": comPrefList.join(','),
      "trusted_badge": trustedBadge.toString(),
      "adhaar_no": adharnum.text.toString(),
      "adhaar_doc": adharcarddoc.toString(),
      "account_type":
          dropdownvalue.toString() == "Select" ? "" : dropdownvalue.toString(),
      "bank_name": bankName.text.toString(),
      "branch_name": branchName.text.toString(),
      "ifsc": iFSCCode.text.toString(),
      "account_no": accountNo.text.toString(),
      "passport_no ": pasportNumber.text.toString(),
      "driving_license_no ": drivingLicenseNumber.text.toString(),
      "passport_doc": passportDoc.toString(),
      "driving_license_doc": dlDoc.toString(),
    };
    // var data = jsonEncode(body);
    log("data---->$body");
    var response = await APIHelper.apiPostRequest(url, body);
    var result = jsonDecode(response);
    log("---->$result");

    if (result['ErrorCode'] == 0) {
      if (initialtrustedbadge == "No") {
        showToast(result['ErrorMessage']);
        // _getprofileData();
        Navigator.push(context,
            MaterialPageRoute(builder: (context) => SelectMemberShipScreen()));
        setState(() {
          buttonLoading = false;
        });
      } else {
        setState(() {
          buttonLoading = false;
        });
        Navigator.push(context,
            MaterialPageRoute(builder: (context) => SelectMemberShipScreen()));
        showToast(result['ErrorMessage']);
      }
    } else {
      showToast(result['ErrorMessage']);
      setState(() {
        buttonLoading = false;
      });
    }
    setState(() {
      buttonLoading = false;
    });
  }
}
