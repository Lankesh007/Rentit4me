// ignore_for_file: use_build_context_synchronously, deprecated_member_use, unused_catch_clause, unrelated_type_equality_checks

import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:rentit4me_new/network/api.dart';
import 'package:rentit4me_new/themes/constant.dart';
import 'package:http/http.dart' as http;
import 'package:rentit4me_new/views/home_screen.dart';
import 'package:rentit4me_new/views/product_detail_screen.dart';
import 'package:rentit4me_new/widgets/api_helper.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../utils/dialog_utils.dart';

class UserDetailScreen extends StatefulWidget {
  const UserDetailScreen({Key key}) : super(key: key);

  @override
  State<UserDetailScreen> createState() => _UserDetailScreenState();
}

class _UserDetailScreenState extends State<UserDetailScreen> {
  double height = 0;
  double width = 0;
  GlobalKey<FormState> form = GlobalKey<FormState>();
  bool _loading = false;
  List<dynamic> countrylistData = [];
  String initialcountryname;
  String countryId;
  List<dynamic> statelistData = [];
  String initialstatename;
  String stateId;
  List<dynamic> citylistData = [];
  String initialcityname;
  String cityId;
  int userType = 0;
  var singleImage, singleImageDecoded;
  String bankDName = "";
  String bankDbranchName = '';
  String accountDNumebr = '';
  String accountType = '';
  String iFSCCODE = '';
  bool gstfile = false;
  bool panFile = false;
  String resubmitValue = "";

  var items = [
    'select',
    'current',
    'saving',
  ];

  String profileimage = '';
  TextEditingController name = TextEditingController();
  TextEditingController email = TextEditingController();
  TextEditingController mobile = TextEditingController();
  String myads;
  TextEditingController location = TextEditingController();
  TextEditingController pincode = TextEditingController();
  String membership;

  TextEditingController fburl = TextEditingController();
  TextEditingController twitterurl = TextEditingController();
  TextEditingController youtubeurl = TextEditingController();
  TextEditingController googleplusurl = TextEditingController();
  TextEditingController instragramurl = TextEditingController();
  TextEditingController linkdinurl = TextEditingController();
  TextEditingController passportController = TextEditingController();
  TextEditingController dlController = TextEditingController();

  final bankName = TextEditingController();
  final branchName = TextEditingController();
  final accountNo = TextEditingController();
  final iFSCCode = TextEditingController();
  final gstNumber = TextEditingController();
  final panNumber = TextEditingController();
  final aadharNumber = TextEditingController();
  final businessName = TextEditingController();
  String dropdownvalue;
  String aadharDocument = '';
  bool aadhardocBool = false;
  String gstDocumnet = '';
  String panCardDocumnet = '';
  String aadharCardDocument = '';
  bool isLoading = false;
  File _pickedImage;
  File panImage;
  bool checkKycResubmit = false;

  File aadharImage;

  bool _emailcheck = false;
  bool _smscheck = false;
  bool _hidemob = false;

  bool _checknotifi = false;
  bool panDocumentBool = false;

  List<int> commprefs = [];

  String selectedCountry = "Select Country";
  String selectedState = "Select State";
  String selectedCity = "Select City";
  bool buttonLoading = false;

  bool profilepicbool = false;
  bool gstDocumentBool = false;
  int stackindex = 0;
  List adviseradslist = [];
  String gstNo = '';
  String panNo = '';
  bool backbutton = false;
  String kycDocumentType;
  String passportNumber;
  String passPortDoc;
  String drivingLNumber;
  String drivinglDoc;

  _setData() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    backbutton = preferences.getBool('profileBackButton');
    log("backButton---->$backbutton");
  }

  @override
  void initState() {
    super.initState();

    _setData();
    _getprofileData();
    _getcountryData();
    _getAdviserAdProducts();
  }

  @override
  Widget build(BuildContext context) {
    height = MediaQuery.of(context).size.height;
    width = MediaQuery.of(context).size.width;
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 2.0,
        leading: backbutton == true
            ? InkWell(
                onTap: () {
                  Navigator.push(context,
                      MaterialPageRoute(builder: (context) => HomeScreen()));
                },
                child: const Icon(
                  Icons.arrow_back,
                  color: kPrimaryColor,
                ))
            : SizedBox(),
        title: const Text("Profile", style: TextStyle(color: kPrimaryColor)),
        centerTitle: true,
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          _setData();
          _getprofileData();
          _getcountryData();
          _getAdviserAdProducts();
        },
        child: Form(
          key: form,
          child: IndexedStack(
            index: stackindex,
            children: [
              ModalProgressHUD(
                inAsyncCall: _loading,
                color: kPrimaryColor,
                child: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      children: [
                        Card(
                          elevation: 2.0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(25.0),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                                vertical: 15.0, horizontal: 8.0),
                            child: Row(
                              children: [
                                profileimage == null || profileimage == ""
                                    ? ClipRRect(
                                        borderRadius: BorderRadius.circular(20),
                                        child: Container(
                                            height: 45,
                                            width: 45,
                                            decoration: BoxDecoration(
                                                borderRadius:
                                                    BorderRadius.circular(20)),
                                            child: CircleAvatar(
                                                child: Image.asset(
                                                    'assets/images/no_image.jpg'))),
                                      )
                                    : ClipRRect(
                                        borderRadius: BorderRadius.circular(22),
                                        child: Container(
                                          height: 45,
                                          width: 45,
                                          decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(22)),
                                          child: CachedNetworkImage(
                                            imageUrl: profileimage.toString(),
                                            placeholder: (context, url) =>
                                                const CircularProgressIndicator(),
                                            errorWidget: (context, url,
                                                    error) =>
                                                Image.asset(
                                                    'assets/images/no_image.jpg'),
                                          ),
                                        )),
                                const SizedBox(width: 10),
                                Expanded(
                                    child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    name == null || name == ''
                                        ? const Text("Hi! Guest",
                                            style: TextStyle(
                                                color: Appcolors.primaryColor,
                                                fontSize: 16,
                                                fontWeight: FontWeight.w500))
                                        : Text(name.text,
                                            style: const TextStyle(
                                                color: Appcolors.primaryColor,
                                                fontSize: 16,
                                                fontWeight: FontWeight.w500)),
                                    membership == "" ||
                                            membership == null ||
                                            membership == "null"
                                        ? const SizedBox()
                                        : membership == "1"
                                            ? const Text("Membership: Free",
                                                style: TextStyle(
                                                    color: kPrimaryColor,
                                                    fontSize: 16))
                                            : const Text("Membership: Paid",
                                                style: TextStyle(
                                                    color: kPrimaryColor,
                                                    fontSize: 16))
                                  ],
                                )),
                                Row(
                                  children: [
                                    InkWell(
                                      onTap: () {
                                        setState(() {
                                          stackindex = 1;
                                        });
                                      },
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          myads == null || myads == ""
                                              ? SizedBox()
                                              : Text(myads,
                                                  style: TextStyle(
                                                      color: kPrimaryColor,
                                                      fontSize: 16,
                                                      fontWeight:
                                                          FontWeight.w500)),
                                          const Text("My Ads",
                                              style: TextStyle(
                                                  color: Appcolors.primaryColor,
                                                  fontSize: 16))
                                        ],
                                      ),
                                    )
                                  ],
                                )
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        // Card(
                        //   elevation: 4.0,
                        //   child:
                        // ),
                        const SizedBox(height: 20),
                        Card(
                          elevation: 4.0,
                          child: Padding(
                            padding: EdgeInsets.symmetric(
                                vertical: 10, horizontal: 8.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Align(
                                  alignment: Alignment.center,
                                  child: Text("Basic Detail",
                                      style: TextStyle(
                                          color: kPrimaryColor,
                                          fontSize: 21,
                                          fontWeight: FontWeight.w700)),
                                ),
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 10, horizontal: 0.0),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const Text("Email*",
                                          style: TextStyle(
                                              color: kPrimaryColor,
                                              fontSize: 16,
                                              fontWeight: FontWeight.w500)),
                                      const SizedBox(height: 8.0),
                                      Container(
                                          decoration: BoxDecoration(
                                              border: Border.all(
                                                  width: 1,
                                                  color:
                                                      Appcolors.primaryColor),
                                              borderRadius:
                                                  const BorderRadius.all(
                                                      Radius.circular(12))),
                                          child: Padding(
                                            padding: const EdgeInsets.only(
                                                left: 8.0),
                                            child: TextFormField(
                                              controller: email,
                                              readOnly: true,
                                              decoration: InputDecoration(
                                                border: InputBorder.none,
                                              ),
                                            ),
                                          )),
                                      const SizedBox(height: 20),
                                      const Text("Phone Number*",
                                          style: TextStyle(
                                              color: kPrimaryColor,
                                              fontSize: 16,
                                              fontWeight: FontWeight.w500)),
                                      const SizedBox(height: 8.0),
                                      Container(
                                          decoration: BoxDecoration(
                                              border: Border.all(
                                                  width: 1,
                                                  color:
                                                      Appcolors.primaryColor),
                                              borderRadius: BorderRadius.all(
                                                  Radius.circular(12))),
                                          child: Padding(
                                            padding: EdgeInsets.only(left: 8.0),
                                            child: TextFormField(
                                              controller: mobile,
                                              readOnly: true,
                                              decoration: InputDecoration(
                                                border: InputBorder.none,
                                              ),
                                            ),
                                          )),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: const [
                                          // Container(
                                          //   width: size.width * 0.40,
                                          //   child: Row(
                                          //     children: [
                                          //       const Text("Hide Mobile",
                                          //           style: TextStyle(
                                          //               color: kPrimaryColor,
                                          //               fontWeight: FontWeight.bold)),
                                          //       const SizedBox(width: 5),
                                          //       Checkbox(
                                          //           value: _hidemob,
                                          //           onChanged: (value) {
                                          //             if (value) {
                                          //               setState(() {
                                          //                 _hidemob = value;
                                          //               });
                                          //             } else {
                                          //               setState(() {
                                          //                 _hidemob = value;
                                          //               });
                                          //             }
                                          //           })
                                          //     ],
                                          //   ),
                                          // ),
                                        ],
                                      )
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 10),
                                const Text("Full Name",
                                    style: TextStyle(
                                        color: kPrimaryColor,
                                        fontSize: 16,
                                        fontWeight: FontWeight.w500)),
                                const SizedBox(height: 8.0),
                                Container(
                                    decoration: BoxDecoration(
                                        border: Border.all(
                                            width: 1,
                                            color: Appcolors.primaryColor),
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(12))),
                                    child: Padding(
                                      padding: EdgeInsets.only(left: 8.0),
                                      child: TextFormField(
                                        validator: (value) {
                                          if (value == null || value.isEmpty) {
                                            return 'Required Field';
                                          }
                                          return null;
                                        },
                                        controller: name,
                                        decoration: InputDecoration(
                                          border: InputBorder.none,
                                        ),
                                      ),
                                    )),
                                const SizedBox(height: 10),
                                const Text("Picture",
                                    style: TextStyle(
                                        color: kPrimaryColor,
                                        fontSize: 16,
                                        fontWeight: FontWeight.w500)),
                                const SizedBox(height: 8.0),
                                Container(
                                    decoration: BoxDecoration(
                                        border: Border.all(
                                            width: 1,
                                            color: Appcolors.primaryColor),
                                        borderRadius: const BorderRadius.all(
                                            Radius.circular(12))),
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 5.0, horizontal: 8.0),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          profileimage.toString() == "" ||
                                                  profileimage.toString() ==
                                                      "null"
                                              ? SizedBox()
                                              : profileimage.startsWith("http")
                                                  ? CircleAvatar(
                                                      radius: 25,
                                                      backgroundImage:
                                                          NetworkImage(
                                                              profileimage),
                                                    )
                                                  : CircleAvatar(
                                                      radius: 25,
                                                      backgroundImage:
                                                          FileImage(File(
                                                              profileimage)),
                                                    ),
                                          InkWell(
                                            onTap: () {
                                              showPhotoCaptureOptions();
                                              setState(() {});
                                            },
                                            child: Container(
                                              height: 45,
                                              width: 120,
                                              alignment: Alignment.center,
                                              decoration: const BoxDecoration(
                                                  color: Colors
                                                      .deepOrangeAccent,
                                                  borderRadius:
                                                      BorderRadius.all(
                                                          Radius.circular(
                                                              8.0))),
                                              child: const Text("Choose file",
                                                  style: TextStyle(
                                                      color: Colors.white,
                                                      fontSize: 16)),
                                            ),
                                          )
                                        ],
                                      ),
                                    )),
                                Padding(
                                  padding: EdgeInsets.symmetric(
                                      vertical: 10, horizontal: 0),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const SizedBox(height: 10),
                                      // const Text("Country*",
                                      //     style: TextStyle(
                                      //         color: kPrimaryColor,
                                      //         fontSize: 16,
                                      //         fontWeight: FontWeight.w500)),
                                      // const SizedBox(height: 8.0),
                                      // Container(
                                      //     decoration: BoxDecoration(
                                      //         border: Border.all(
                                      //             width: 1,
                                      //             color:
                                      //                 Appcolors.primaryColor),
                                      //         borderRadius: BorderRadius.all(
                                      //             Radius.circular(12))),
                                      //     child: Padding(
                                      //       padding: const EdgeInsets.only(
                                      //           left: 10.0),
                                      //       child: TextField(
                                      //         readOnly: true,
                                      //         decoration: InputDecoration(
                                      //           hintText:
                                      //               selectedCountry.toString(),
                                      //           border: InputBorder.none,
                                      //         ),
                                      //         onChanged: (value) {
                                      //           setState(() {});
                                      //         },
                                      //       ),
                                      //     )),

                                      // // Padding(
                                      // //   padding:
                                      // //       const EdgeInsets.fromLTRB(0, 2, 0, 2),
                                      // //   child: DropdownSearch(
                                      // //     selectedItem: "Select Country",
                                      // //     mode: Mode.DIALOG,
                                      // //     showSelectedItem: true,
                                      // //     autoFocusSearchBox: true,
                                      // //     showSearchBox: true,
                                      // //     showFavoriteItems: true,
                                      // //     favoriteItems: (val) {
                                      // //       return [selectedCountry];
                                      // //     },
                                      // //     hint: 'Select Country',
                                      // //     dropdownSearchDecoration: InputDecoration(
                                      // //         enabledBorder: OutlineInputBorder(
                                      // //             borderRadius:
                                      // //                 BorderRadius.circular(12),
                                      // //             borderSide: BorderSide(
                                      // //                 color:
                                      // //                     Appcolors.primaryColor,
                                      // //                 width: 1)),
                                      // //         contentPadding:
                                      // //             EdgeInsets.only(left: 10)),
                                      // //     items: countrylistData.map((e) {
                                      // //       return e['name'].toString();
                                      // //     }).toList(),
                                      // //     onChanged: (value) {
                                      // //       if (value != "Select Country") {
                                      // //         for (var element
                                      // //             in countrylistData) {
                                      // //           if (element['name'].toString() ==
                                      // //               value) {
                                      // //             setState(() {
                                      // //               initialcountryname =
                                      // //                   value.toString();
                                      // //               initialstatename = null;
                                      // //               initialcityname = null;
                                      // //               countryId =
                                      // //                   element['id'].toString();
                                      // //               _getStateData(
                                      // //                   element['id'].toString());
                                      // //             });
                                      // //           }
                                      // //         }
                                      // //       } else {
                                      // //         showToast("Select Country");
                                      // //       }
                                      // //     },
                                      // //   ),
                                      // // ),

                                      // const SizedBox(height: 10),
                                      // const Text("State*",
                                      //     style: TextStyle(
                                      //         color: kPrimaryColor,
                                      //         fontSize: 16,
                                      //         fontWeight: FontWeight.w500)),
                                      // const SizedBox(height: 8.0),
                                      // Container(
                                      //     decoration: BoxDecoration(
                                      //         border: Border.all(
                                      //             width: 1,
                                      //             color:
                                      //                 Appcolors.primaryColor),
                                      //         borderRadius: BorderRadius.all(
                                      //             Radius.circular(12))),
                                      //     child: Padding(
                                      //       padding: const EdgeInsets.only(
                                      //           left: 10.0),
                                      //       child: TextField(
                                      //         readOnly: true,
                                      //         decoration: InputDecoration(
                                      //           hintText:
                                      //               selectedState.toString(),
                                      //           border: InputBorder.none,
                                      //         ),
                                      //         onChanged: (value) {
                                      //           setState(() {});
                                      //         },
                                      //       ),
                                      //     )),

                                      // DropdownSearch(
                                      //   selectedItem: "Select State",
                                      //   mode: Mode.DIALOG,
                                      //   showSelectedItem: true,
                                      //   autoFocusSearchBox: true,
                                      //   showSearchBox: true,
                                      //   hint: 'Select State',
                                      //   dropdownSearchDecoration: InputDecoration(
                                      //       enabledBorder: OutlineInputBorder(
                                      //           borderRadius:
                                      //               BorderRadius.circular(12),
                                      //           borderSide: BorderSide(
                                      //               color:
                                      //                   Appcolors.primaryColor,
                                      //               width: 1)),
                                      //       contentPadding:
                                      //           EdgeInsets.only(left: 10)),
                                      //   items: statelistData.map((e) {
                                      //     return e['name'].toString();
                                      //   }).toList(),
                                      //   onChanged: (value) {
                                      //     if (value != "Select State") {
                                      //       for (var element in statelistData) {
                                      //         if (element['name'].toString() ==
                                      //             value) {
                                      //           setState(() {
                                      //             initialstatename =
                                      //                 value.toString();
                                      //             initialstatename = null;
                                      //             initialcityname = null;
                                      //             stateId =
                                      //                 element['id'].toString();
                                      //             _getCityData(
                                      //                 element['id'].toString());
                                      //           });
                                      //         }
                                      //       }
                                      //     } else {
                                      //       showToast("Select State");
                                      //     }
                                      //   },
                                      // ),

                                      // const SizedBox(height: 10),
                                      // const Text("City*",
                                      //     style: TextStyle(
                                      //         color: kPrimaryColor,
                                      //         fontSize: 16,
                                      //         fontWeight: FontWeight.w500)),
                                      // const SizedBox(height: 8.0),
                                      // DropdownSearch(
                                      //   selectedItem: "Select City",
                                      //   mode: Mode.DIALOG,
                                      //   showSelectedItem: true,
                                      //   autoFocusSearchBox: true,
                                      //   showSearchBox: true,
                                      //   hint: 'Select City',
                                      //   dropdownSearchDecoration: InputDecoration(
                                      //       enabledBorder: OutlineInputBorder(
                                      //           borderRadius:
                                      //               BorderRadius.circular(12),
                                      //           borderSide: BorderSide(
                                      //               color:
                                      //                   Appcolors.primaryColor,
                                      //               width: 1)),
                                      //       contentPadding:
                                      //           EdgeInsets.only(left: 10)),
                                      //   items: citylistData.map((e) {
                                      //     return e['name'].toString();
                                      //   }).toList(),
                                      //   onChanged: (value) {
                                      //     if (value != "Select City") {
                                      //       for (var element in citylistData) {
                                      //         if (element['name'].toString() ==
                                      //             value) {
                                      //           setState(() {
                                      //             initialcityname =
                                      //                 value.toString();
                                      //             //initialstatename = null;
                                      //             //initialcityname = null;
                                      //             cityId =
                                      //                 element['id'].toString();
                                      //             //_getStateData(element['id'].toString());
                                      //           });
                                      //         }
                                      //       }
                                      //     } else {
                                      //       showToast("Select City");
                                      //     }
                                      //   },
                                      // ),
                                      // Container(
                                      //     decoration: BoxDecoration(
                                      //         border: Border.all(
                                      //             width: 1,
                                      //             color:
                                      //                 Appcolors.primaryColor),
                                      //         borderRadius: BorderRadius.all(
                                      //             Radius.circular(12))),
                                      //     child: Padding(
                                      //       padding: const EdgeInsets.only(
                                      //           left: 10.0),
                                      //       child: TextField(
                                      //         readOnly: true,
                                      //         decoration: InputDecoration(
                                      //           hintText:
                                      //               selectedCity.toString(),
                                      //           border: InputBorder.none,
                                      //         ),
                                      //         onChanged: (value) {
                                      //           setState(() {});
                                      //         },
                                      //       ),
                                      //     )),

                                      const SizedBox(height: 10),
                                      const Text("Location",
                                          style: TextStyle(
                                              color: kPrimaryColor,
                                              fontSize: 16,
                                              fontWeight: FontWeight.w500)),
                                      const SizedBox(height: 8.0),
                                      Container(
                                          decoration: BoxDecoration(
                                              border: Border.all(
                                                  width: 1,
                                                  color:
                                                      Appcolors.primaryColor),
                                              borderRadius: BorderRadius.all(
                                                  Radius.circular(12))),
                                          child: Padding(
                                            padding: const EdgeInsets.only(
                                                left: 10.0),
                                            child: TextFormField(
                                              readOnly: true,
                                              controller: location,
                                              decoration: InputDecoration(
                                                border: InputBorder.none,
                                              ),
                                            ),
                                          )),
                                      const SizedBox(height: 10),
                                      const Text("Pincode",
                                          style: TextStyle(
                                              color: kPrimaryColor,
                                              fontSize: 16,
                                              fontWeight: FontWeight.w500)),
                                      const SizedBox(height: 8.0),
                                      Container(
                                          decoration: BoxDecoration(
                                              border: Border.all(
                                                  width: 1,
                                                  color:
                                                      Appcolors.primaryColor),
                                              borderRadius: BorderRadius.all(
                                                  Radius.circular(12))),
                                          child: Padding(
                                            padding: const EdgeInsets.only(
                                                left: 10.0),
                                            child: TextFormField(
                                              validator: (value) {
                                                if (value == null ||
                                                    value.isEmpty) {
                                                  return 'Required Field';
                                                }
                                                return null;
                                              },
                                              controller: pincode,
                                              decoration: InputDecoration(
                                                border: InputBorder.none,
                                              ),
                                            ),
                                          )),
                                      const SizedBox(height: 10),
                                      const Text("Communication Preferences*",
                                          style: TextStyle(
                                              color: kPrimaryColor,
                                              fontSize: 16,
                                              fontWeight: FontWeight.w500)),
                                      const SizedBox(height: 8.0),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        children: [
                                          Row(
                                            children: [
                                              Checkbox(
                                                  value: _emailcheck,
                                                  onChanged: (value) {
                                                    setState(() {
                                                      _emailcheck = value;
                                                      if (_emailcheck) {
                                                        commprefs.add(1);
                                                      } else {
                                                        for (var element
                                                            in commprefs) {
                                                          if (element == 1) {
                                                            commprefs.removeWhere(
                                                                (element) =>
                                                                    element ==
                                                                    1);
                                                          }
                                                        }
                                                      }
                                                    });
                                                  }),
                                              const Text("Email",
                                                  style: TextStyle(
                                                      color: kPrimaryColor,
                                                      fontWeight:
                                                          FontWeight.w700))
                                            ],
                                          ),
                                          const SizedBox(width: 20),
                                          Row(
                                            children: [
                                              Checkbox(
                                                  value: _smscheck,
                                                  onChanged: (value) {
                                                    setState(() {
                                                      _smscheck = value;
                                                      if (_smscheck) {
                                                        commprefs.add(2);
                                                      } else {
                                                        for (var element
                                                            in commprefs) {
                                                          if (element == 2) {
                                                            commprefs.removeWhere(
                                                                (element) =>
                                                                    element ==
                                                                    2);
                                                          }
                                                        }
                                                      }
                                                    });
                                                  }),
                                              const Text("SMS",
                                                  style: TextStyle(
                                                      color: kPrimaryColor,
                                                      fontWeight:
                                                          FontWeight.w700))
                                            ],
                                          ),
                                        ],
                                      ),
                                      SizedBox(
                                        height: 10,
                                      ),

                                      kyc == 1 &&
                                              kycApproval != "approved" &&
                                              countryName == "India"
                                          ? Column(
                                              children: [
                                                Divider(),
                                                Row(children: [
                                                  Text("Kyc Resubmit",
                                                      style: TextStyle(
                                                          color: kPrimaryColor,
                                                          fontWeight:
                                                              FontWeight.bold)),
                                                  Checkbox(
                                                      value: checkKycResubmit,
                                                      onChanged: (value) {
                                                        setState(() {
                                                          checkKycResubmit =
                                                              value;
                                                          // renttype[0]['enable'] = _checkhour;
                                                          if (checkKycResubmit ==
                                                              true) {
                                                            resubmitValue = "1";
                                                          } else {
                                                            resubmitValue = "0";
                                                          }
                                                        });
                                                      }),
                                                ]),
                                                Container(
                                                  alignment:
                                                      Alignment.centerLeft,
                                                  child: const Text(
                                                      "Aadhar Number",
                                                      style: TextStyle(
                                                        color: kPrimaryColor,
                                                      )),
                                                ),
                                                SizedBox(height: 5),
                                                Container(
                                                    decoration: BoxDecoration(
                                                        border: Border.all(
                                                            width: 1,
                                                            color: Colors
                                                                .deepOrangeAccent),
                                                        borderRadius:
                                                            BorderRadius.all(
                                                                Radius.circular(
                                                                    12))),
                                                    child: Padding(
                                                      padding:
                                                          const EdgeInsets.only(
                                                              left: 10.0),
                                                      child: TextFormField(
                                                        keyboardType:
                                                            TextInputType
                                                                .number,
                                                        inputFormatters: [
                                                          FilteringTextInputFormatter
                                                              .digitsOnly
                                                        ],
                                                        controller:
                                                            aadharNumber,
                                                        decoration:
                                                            InputDecoration(
                                                          border:
                                                              InputBorder.none,
                                                          hintText: aadharNumberApi ==
                                                                  ""
                                                              ? "Must be 12 digits"
                                                              : aadharNumberApi,
                                                          counterText: "",
                                                        ),
                                                        maxLength: 12,
                                                      ),
                                                    )),
                                                SizedBox(
                                                  height: 10,
                                                ),
                                                Container(
                                                  alignment:
                                                      Alignment.centerLeft,
                                                  child: const Text(
                                                      "Aadhar Doc",
                                                      style: TextStyle(
                                                        color: kPrimaryColor,
                                                      )),
                                                ),
                                                const SizedBox(height: 8.0),
                                                Container(
                                                    decoration: BoxDecoration(
                                                        border: Border.all(
                                                            width: 1,
                                                            color: Colors
                                                                .deepOrangeAccent),
                                                        borderRadius:
                                                            const BorderRadius
                                                                    .all(
                                                                Radius.circular(
                                                                    12))),
                                                    child: Padding(
                                                      padding: const EdgeInsets
                                                              .symmetric(
                                                          vertical: 5.0,
                                                          horizontal: 8.0),
                                                      child: Row(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .spaceBetween,
                                                        children: [
                                                          aadharDocument.toString() ==
                                                                      "" ||
                                                                  aadharDocument
                                                                          .toString() ==
                                                                      "null"
                                                              ? SizedBox()
                                                              : aadharDocument
                                                                      .startsWith(
                                                                          "http")
                                                                  ? CircleAvatar(
                                                                      radius:
                                                                          25,
                                                                      backgroundImage:
                                                                          NetworkImage(
                                                                              aadharDocument),
                                                                    )
                                                                  : CircleAvatar(
                                                                      radius:
                                                                          25,
                                                                      backgroundImage:
                                                                          FileImage(
                                                                              File(aadharDocument)),
                                                                    ),
                                                          InkWell(
                                                            onTap: () {
                                                              aadharDoc();
                                                              setState(() {});
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
                                                                          Radius.circular(
                                                                              8.0))),
                                                              child: const Text(
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
                                                    )),
                                                SizedBox(
                                                  height: 10,
                                                ),
                                              ],
                                            )
                                          : SizedBox(),
                                      kyc == 1 &&
                                              kycApproval != "approved" &&
                                              countryName != "India"
                                          ? Column(
                                              children: [
                                                Divider(),
                                                Row(children: [
                                                  Text("Kyc Resubmit",
                                                      style: TextStyle(
                                                          color: kPrimaryColor,
                                                          fontWeight:
                                                              FontWeight.bold)),
                                                  Checkbox(
                                                      value: checkKycResubmit,
                                                      onChanged: (value) {
                                                        setState(() {
                                                          checkKycResubmit =
                                                              value;
                                                          // renttype[0]['enable'] = _checkhour;
                                                          if (checkKycResubmit ==
                                                              true) {
                                                            resubmitValue = "1";
                                                          } else {
                                                            resubmitValue = "0";
                                                          }
                                                        });
                                                      }),
                                                ]),
                                                Container(
                                                  alignment:
                                                      Alignment.centerLeft,
                                                  child: Text(
                                                      kycDocumentType ==
                                                              "passport"
                                                          ? "Passport Number"
                                                          : "Driving Licence Number",
                                                      style: TextStyle(
                                                        color: kPrimaryColor,
                                                      )),
                                                ),
                                                SizedBox(height: 5),
                                                Container(
                                                    decoration: BoxDecoration(
                                                        border: Border.all(
                                                            width: 1,
                                                            color: Colors
                                                                .deepOrangeAccent),
                                                        borderRadius:
                                                            BorderRadius.all(
                                                                Radius.circular(
                                                                    12))),
                                                    child: Padding(
                                                      padding:
                                                          const EdgeInsets.only(
                                                              left: 10.0),
                                                      child: TextFormField(
                                                        keyboardType:
                                                            TextInputType
                                                                .number,
                                                        controller:
                                                            kycDocumentType ==
                                                                    "passport"
                                                                ? passportController
                                                                : dlController,
                                                        decoration:
                                                            InputDecoration(
                                                          border:
                                                              InputBorder.none,
                                                          hintText:
                                                              kycDocumentType ==
                                                                      "passport"
                                                                  ? passportNumber
                                                                  : drivingLNumber,
                                                          counterText: "",
                                                        ),
                                                        maxLength: 12,
                                                      ),
                                                    )),
                                                SizedBox(
                                                  height: 10,
                                                ),
                                                Container(
                                                  alignment:
                                                      Alignment.centerLeft,
                                                  child: Text(
                                                      kycDocumentType ==
                                                              "passport"
                                                          ? "Passport Doc"
                                                          : "Driving Licence Doc",
                                                      style: TextStyle(
                                                        color: kPrimaryColor,
                                                      )),
                                                ),
                                                const SizedBox(height: 8.0),
                                                Container(
                                                    decoration: BoxDecoration(
                                                        border: Border.all(
                                                            width: 1,
                                                            color: Colors
                                                                .deepOrangeAccent),
                                                        borderRadius:
                                                            const BorderRadius
                                                                    .all(
                                                                Radius.circular(
                                                                    12))),
                                                    child: Padding(
                                                      padding: const EdgeInsets
                                                              .symmetric(
                                                          vertical: 5.0,
                                                          horizontal: 8.0),
                                                      child: Row(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .spaceBetween,
                                                        children: [
                                                          kycDocumentType ==
                                                                  "passport"
                                                              ? kycDocumentType.toString() ==
                                                                          "" ||
                                                                      kycDocumentType
                                                                              .toString() ==
                                                                          "null"
                                                                  ? SizedBox()
                                                                  : passportSelectDoc == "" ||
                                                                          passportSelectDoc ==
                                                                              "null" ||
                                                                          passportSelectDoc ==
                                                                              null
                                                                      ? Image
                                                                          .network(
                                                                          devImage +
                                                                              basePath +
                                                                              passPortDoc,
                                                                          height:
                                                                              40,
                                                                          width:
                                                                              40,
                                                                        )
                                                                      : CircleAvatar(
                                                                          radius:
                                                                              25,
                                                                          backgroundImage:
                                                                              FileImage(File(passportSelectDoc)),
                                                                        )
                                                              : dlSelectDoc ==
                                                                          "" ||
                                                                      dlSelectDoc ==
                                                                          "null" ||
                                                                      dlSelectDoc ==
                                                                          null
                                                                  ? Image.network(
                                                                      devImage +
                                                                          basePath +
                                                                          drivinglDoc,
                                                                      height:
                                                                          40,
                                                                      width: 40)
                                                                  : CircleAvatar(
                                                                      radius:
                                                                          25,
                                                                      backgroundImage:
                                                                          FileImage(
                                                                              File(dlSelectDoc)),
                                                                    ),
                                                          InkWell(
                                                            onTap: () {
                                                              passportDoc();
                                                              setState(() {});
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
                                                                          Radius.circular(
                                                                              8.0))),
                                                              child: const Text(
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
                                                    )),
                                                SizedBox(
                                                  height: 10,
                                                ),
                                              ],
                                            )
                                          : SizedBox(),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),

                        userType == 3
                            ? bankDetailsWidget()
                            : Column(children: [
                                businessDetailsWidget(),
                                bankDetailsWidget(),
                              ]),
                        const SizedBox(height: 20),
                        Card(
                          elevation: 4.0,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                                vertical: 10.0, horizontal: 8.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Align(
                                  alignment: Alignment.center,
                                  child: Text("Social Network",
                                      style: TextStyle(
                                          color: kPrimaryColor,
                                          fontSize: 21,
                                          fontWeight: FontWeight.w700)),
                                ),
                                const SizedBox(height: 10),
                                const Text("Facebook",
                                    style: TextStyle(
                                        color: kPrimaryColor,
                                        fontSize: 16,
                                        fontWeight: FontWeight.w500)),
                                const SizedBox(height: 8.0),
                                Container(
                                    decoration: BoxDecoration(
                                        border: Border.all(
                                            width: 1,
                                            color: Appcolors.primaryColor),
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(12))),
                                    child: Padding(
                                      padding: EdgeInsets.only(left: 8.0),
                                      child: TextFormField(
                                        decoration: InputDecoration(
                                          border: InputBorder.none,
                                        ),
                                        controller: fburl,
                                      ),
                                    )),
                                const SizedBox(height: 10),
                                const Text("Twitter",
                                    style: TextStyle(
                                        color: kPrimaryColor,
                                        fontSize: 16,
                                        fontWeight: FontWeight.w500)),
                                const SizedBox(height: 8.0),
                                Container(
                                    decoration: BoxDecoration(
                                        border: Border.all(
                                            width: 1,
                                            color: Appcolors.primaryColor),
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(12))),
                                    child: Padding(
                                      padding: EdgeInsets.only(left: 8.0),
                                      child: TextFormField(
                                        decoration: InputDecoration(
                                          border: InputBorder.none,
                                        ),
                                        controller: twitterurl,
                                      ),
                                    )),
                                const SizedBox(height: 10),
                                const Text("Google+",
                                    style: TextStyle(
                                        color: kPrimaryColor,
                                        fontSize: 16,
                                        fontWeight: FontWeight.w500)),
                                const SizedBox(height: 8.0),
                                Container(
                                    decoration: BoxDecoration(
                                        border: Border.all(
                                            width: 1,
                                            color: Appcolors.primaryColor),
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(12))),
                                    child: Padding(
                                      padding: EdgeInsets.only(left: 8.0),
                                      child: TextFormField(
                                        decoration: InputDecoration(
                                          border: InputBorder.none,
                                        ),
                                        controller: googleplusurl,
                                      ),
                                    )),
                                const SizedBox(height: 10),
                                const Text("Instagram",
                                    style: TextStyle(
                                        color: kPrimaryColor,
                                        fontSize: 16,
                                        fontWeight: FontWeight.w500)),
                                const SizedBox(height: 8.0),
                                Container(
                                    decoration: BoxDecoration(
                                        border: Border.all(
                                            width: 1,
                                            color: Appcolors.primaryColor),
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(12))),
                                    child: Padding(
                                      padding: EdgeInsets.only(left: 8.0),
                                      child: TextFormField(
                                        decoration: InputDecoration(
                                          border: InputBorder.none,
                                        ),
                                        controller: instragramurl,
                                      ),
                                    )),
                                const SizedBox(height: 10),
                                const Text("Linkedin",
                                    style: TextStyle(
                                        color: kPrimaryColor,
                                        fontSize: 16,
                                        fontWeight: FontWeight.w500)),
                                const SizedBox(height: 8.0),
                                Container(
                                    decoration: BoxDecoration(
                                        border: Border.all(
                                            width: 1,
                                            color: Appcolors.primaryColor),
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(12))),
                                    child: Padding(
                                      padding: EdgeInsets.only(left: 8.0),
                                      child: TextFormField(
                                        controller: linkdinurl,
                                        decoration: InputDecoration(
                                          border: InputBorder.none,
                                        ),
                                      ),
                                    )),
                                const SizedBox(height: 10),
                                const Text("Youtube",
                                    style: TextStyle(
                                        color: kPrimaryColor,
                                        fontSize: 16,
                                        fontWeight: FontWeight.w500)),
                                const SizedBox(height: 8.0),
                                Container(
                                    decoration: BoxDecoration(
                                        border: Border.all(
                                            width: 1,
                                            color: Appcolors.primaryColor),
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(12))),
                                    child: Padding(
                                      padding: EdgeInsets.only(left: 8.0),
                                      child: TextFormField(
                                        decoration: InputDecoration(
                                          border: InputBorder.none,
                                        ),
                                        controller: youtubeurl,
                                      ),
                                    )),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        // Card(
                        //   elevation: 4.0,
                        //   child:
                        // ),

                        const SizedBox(height: 10),
                        InkWell(
                          onTap: () {
                            // if (name.text.isEmpty) {
                            //   showToast("Please Enter Your Name");
                            // } else if (commprefs.isEmpty) {
                            //   showToast("Please Select Atleast One Prefs");
                            // } else if (profileimage.isEmpty) {
                            //   showToast("Please Select Profile Picture");
                            // } else if (location.text.isEmpty) {
                            //   showToast("Please Enter Your Address");
                            // } else if (initialstatename.isEmpty) {
                            //   showToast("Please Select State name");
                            // } else if (initialcityname.isEmpty) {
                            //   showToast("Please Select City name");
                            // } else if (initialcountryname.isEmpty) {
                            //   showToast("Please Select Country name");
                            // }
                            //  else if (pincode.text.isEmpty) {
                            //   showToast("Please Enter PinCode ");
                            // } else if (bankName.text.isEmpty) {
                            //   showToast("Please Enter Bank name");
                            // } else if (branchName.text.isEmpty) {
                            //   showToast("Please Enter Branch Name");
                            // } else if (accountNo.text.isEmpty) {
                            //   showToast("Please Enter Bank Account Number");
                            // } else if (dropdownvalue == "Select") {
                            //   showToast("Please Select Account Type");
                            // } else if (iFSCCode.text.isEmpty) {
                            //   showToast("Please Enter IFSC Code Number");
                            // }
                            // } else {
                            //   if (userType == 4) {
                            //     if (businessName.text.isEmpty) {
                            //       showToast("Please Enter Your BusinessName");
                            //     } else if (gstNumber.text.isEmpty) {
                            //       showToast("Please Enter Gst Number");
                            //     } else if (panNumber.text.isEmpty) {
                            //       showToast("Please Enter PAN Number");
                            //     } else if (panCardDocumnet.isEmpty) {
                            //       showToast("Please Choode pan doc");
                            //     } else if (gstDocumnet.isEmpty) {
                            //       showToast("Please Choose GST doc");
                            //     } else if (bankName.text.isEmpty) {
                            //       showToast("Please Enter Bank name");
                            //     } else if (branchName.text.isEmpty) {
                            //       showToast("Please Enter Branch Name");
                            //     } else if (accountNo.text.isEmpty) {
                            //       showToast("Please Enter Bank Account Number");
                            //     } else if (dropdownvalue == "Select") {
                            //       showToast("Please Select Account Type");
                            //     } else if (iFSCCode.text.isEmpty) {
                            //       showToast("Please Enter IFSC Code Number");
                            //     } else {
                            //       uploadBasicDetails();
                            //     }
                            // }
                            // else {
                            // }
                            if (countryName != "India") {
                              uploadBasicDetailsofAnotherCountry();
                            } else if (kyc == 0 &&
                                aadharNumber.text.isNotEmpty &&
                                aadharNumber.text.length == 12 &&
                                aadhardocBool == true) {
                              uploadBasicDetailsWithAAdharImage();
                            } else if (kyc == 0 && aadhardocBool == true) {
                              uploadBasicDetailsWithAAdharImage();
                            } else if (aadhardocBool == true) {
                              uploadBasicDetailsWithAAdharImage();
                            } else if (profilepicbool == true &&
                                gstDocumentBool == true &&
                                panDocumentBool == true &&
                                aadhardocBool == true &&
                                kyc == 0) {
                              uploadBasicDetailsWithKyc();
                            } else if (profilepicbool == true &&
                                gstDocumentBool == true &&
                                panDocumentBool == true &&
                                aadhardocBool == true &&
                                kyc == 1) {
                              uploadBasicDetails();
                            } else if (profilepicbool == true) {
                              uploadBasicDetailsWithProfileImage();
                            } else if (gstDocumentBool == true) {
                              uploadBasicDetailsWithGstImage();
                            } else if (panDocumentBool == true) {
                              uploadBasicDetailsWithPanImage();
                            } else {
                              uploadBasicDetailsWitoutImage();
                            }

                            // if (userType == 4) {
                            //   if (profileimage.isEmpty ||
                            //       profileimage == "" ||
                            //       profileimage == null) {
                            //     showToast("Please Select Your Profile Image");
                            //   } else {
                            //     uploadBasicDetails();
                            //   }
                            // } else {
                            //   if (profileimage.isEmpty ||
                            //       profileimage == "" ||
                            //       profileimage == null) {
                            //     showToast("Please Select Your Profile Image");
                            //   } else {
                            //     uploadBasicDetails();
                            //   }
                            // }
                          },
                          child: SizedBox(
                            width: double.infinity,
                            child: Card(
                              elevation: 12.0,
                              color: Appcolors.primaryColor,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(24.0),
                              ),
                              child: Padding(
                                padding: EdgeInsets.symmetric(
                                    vertical: 15, horizontal: 10),
                                child: Text(
                                    buttonLoading == true
                                        ? "Please Wait..."
                                        : "UPDATE",
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                        fontSize: 16)),
                              ),
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                ),
              ),
              Column(
                children: [
                  const SizedBox(height: 10),
                  Expanded(
                      child: SingleChildScrollView(
                    child: Column(
                      children: <Widget>[
                        Card(
                          elevation: 2.0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(25.0),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(15.0),
                            child: Row(
                              children: [
                                profileimage == null || profileimage == ""
                                    ? ClipRRect(
                                        borderRadius: BorderRadius.circular(20),
                                        child: Container(
                                            height: 45,
                                            width: 45,
                                            decoration: BoxDecoration(
                                                borderRadius:
                                                    BorderRadius.circular(20)),
                                            child: CircleAvatar(
                                                child: Image.asset(
                                                    'assets/images/no_image.jpg'))),
                                      )
                                    : ClipRRect(
                                        borderRadius: BorderRadius.circular(22),
                                        child: Container(
                                          height: 45,
                                          width: 45,
                                          decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(22)),
                                          child: CachedNetworkImage(
                                            imageUrl: profileimage,
                                            placeholder: (context, url) =>
                                                const CircularProgressIndicator(),
                                            errorWidget: (context, url,
                                                    error) =>
                                                Image.asset(
                                                    'assets/images/no_image.jpg'),
                                          ),
                                        )),
                                const SizedBox(width: 10),
                                Expanded(
                                    child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    name == null
                                        ? const SizedBox()
                                        : Text(name.text,
                                            style: const TextStyle(
                                                color: Appcolors.primaryColor,
                                                fontSize: 16,
                                                fontWeight: FontWeight.w500)),
                                    membership == "" ||
                                            membership == null ||
                                            membership == "null"
                                        ? const SizedBox()
                                        : membership == "1"
                                            ? const Text("Membership: Free",
                                                style: TextStyle(
                                                    color: kPrimaryColor,
                                                    fontSize: 16))
                                            : const Text("Membership: Paid",
                                                style: TextStyle(
                                                    color: kPrimaryColor,
                                                    fontSize: 16))
                                  ],
                                )),
                                Row(
                                  children: [
                                    InkWell(
                                      onTap: () {
                                        setState(() {
                                          stackindex = 0;
                                        });
                                      },
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          myads == null
                                              ? SizedBox()
                                              : Text(myads,
                                                  style: const TextStyle(
                                                      color: kPrimaryColor,
                                                      fontSize: 16,
                                                      fontWeight:
                                                          FontWeight.w500)),
                                          const Text("My Ads",
                                              style: TextStyle(
                                                  color: Appcolors.primaryColor,
                                                  fontSize: 16))
                                        ],
                                      ),
                                    )
                                  ],
                                )
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 5),
                        adviseradslist.isEmpty || adviseradslist.isEmpty
                            ? SizedBox()
                            : Padding(
                                padding: EdgeInsets.only(
                                    left: 15, top: 10, right: 15),
                                child: adviseradslist.isEmpty
                                    ? SizedBox(height: 0)
                                    : GridView.builder(
                                        shrinkWrap: true,
                                        itemCount: adviseradslist.length,
                                        padding: EdgeInsets.zero,
                                        physics: ClampingScrollPhysics(),
                                        gridDelegate:
                                            const SliverGridDelegateWithFixedCrossAxisCount(
                                                crossAxisCount: 2,
                                                crossAxisSpacing: 4.0,
                                                mainAxisSpacing: 4.0,
                                                childAspectRatio: 1.0),
                                        itemBuilder: (context, index) {
                                          return InkWell(
                                            onTap: () {
                                              Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                      builder: (context) =>
                                                          ProductDetailScreen(
                                                              productid: adviseradslist[
                                                                          index]
                                                                      ['id']
                                                                  .toString())));
                                            },
                                            child: Card(
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(4.0),
                                              ),
                                              child: Column(
                                                children: [
                                                  CachedNetworkImage(
                                                    height: 80,
                                                    width: double.infinity,
                                                    placeholder: (context,
                                                            url) =>
                                                        Image.asset(
                                                            'assets/images/no_image.jpg'),
                                                    errorWidget: (context, url,
                                                            error) =>
                                                        Image.asset(
                                                            'assets/images/no_image.jpg'),
                                                    fit: BoxFit.cover,
                                                    imageUrl: devImage +
                                                        adviseradslist[index][
                                                                'upload_base_path']
                                                            .toString() +
                                                        adviseradslist[index]
                                                                ['file_name']
                                                            .toString(),
                                                  ),
                                                  const SizedBox(height: 5.0),
                                                  Padding(
                                                    padding: EdgeInsets.only(
                                                        left: 5.0, right: 15.0),
                                                    child: Align(
                                                      alignment:
                                                          Alignment.topLeft,
                                                      child: Text(
                                                          adviseradslist[index]
                                                                  ['title']
                                                              .toString(),
                                                          maxLines: 2,
                                                          style:
                                                              const TextStyle(
                                                                  color: Colors
                                                                      .black,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w700,
                                                                  fontSize:
                                                                      14)),
                                                    ),
                                                  ),
                                                  const SizedBox(height: 5.0),
                                                  Padding(
                                                    padding:
                                                        const EdgeInsets.only(
                                                            left: 4.0,
                                                            right: 4.0),
                                                    child: Row(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .spaceBetween,
                                                      children: [
                                                        SizedBox(
                                                          width:
                                                              size.width * 0.23,
                                                          child: Text(
                                                              "Starting from ${adviseradslist[index]['currency'].toString()} ${adviseradslist[index]['prices'][0]['price'].toString()}",
                                                              style: const TextStyle(
                                                                  color:
                                                                      kPrimaryColor,
                                                                  fontSize:
                                                                      12)),
                                                        ),
                                                        const Icon(
                                                            Icons
                                                                .add_box_rounded,
                                                            color:
                                                                kPrimaryColor)
                                                      ],
                                                    ),
                                                  )
                                                ],
                                              ),
                                            ),
                                          );
                                        })),
                      ],
                    ),
                  )),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget bankDetailsWidget() {
    return Card(
        elevation: 4.0,
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 10, horizontal: 15),
          child: Column(
            children: [
              const Text("Bank Details ",
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
                  decoration: BoxDecoration(
                      border:
                          Border.all(width: 1, color: Appcolors.primaryColor),
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
                          border: InputBorder.none, hintText: bankDName),
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
                  decoration: BoxDecoration(
                      border:
                          Border.all(width: 1, color: Appcolors.primaryColor),
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
                          border: InputBorder.none, hintText: bankDbranchName),
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
                  decoration: BoxDecoration(
                      border:
                          Border.all(width: 1, color: Appcolors.primaryColor),
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
                        hintText: accountDNumebr,
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
                  decoration: BoxDecoration(
                      border:
                          Border.all(width: 1, color: Appcolors.primaryColor),
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
                          border: InputBorder.none, hintText: iFSCCODE),
                      controller: iFSCCode,
                    ),
                  )),
            ],
          ),
        ));
  }

  Widget businessDetailsWidget() {
    return Card(
      elevation: 4.0,
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 10, horizontal: 15),
        child: Column(
          children: [
            const Text("Business Detail",
                style: TextStyle(
                    color: kPrimaryColor,
                    fontSize: 18,
                    fontWeight: FontWeight.w700)),
            const SizedBox(height: 20),
            const Align(
              alignment: Alignment.topLeft,
              child: Text("Business Name",
                  style: TextStyle(
                      color: kPrimaryColor, fontWeight: FontWeight.w500)),
            ),
            const SizedBox(height: 8),
            Container(
                decoration: BoxDecoration(
                    border: Border.all(width: 1, color: Appcolors.primaryColor),
                    borderRadius: BorderRadius.all(Radius.circular(12))),
                child: Padding(
                  padding: const EdgeInsets.only(left: 10.0),
                  child: TextField(
                    controller: businessName,
                    decoration: InputDecoration(
                      hintText: businessNameOfUser,
                      border: InputBorder.none,
                    ),
                    onChanged: (value) {
                      setState(() {});
                    },
                  ),
                )),
            const SizedBox(height: 10),
            const Align(
              alignment: Alignment.topLeft,
              child: Text("GST Number",
                  style: TextStyle(
                      color: kPrimaryColor, fontWeight: FontWeight.w500)),
            ),
            const SizedBox(height: 8),
            Container(
                decoration: BoxDecoration(
                    border: Border.all(width: 1, color: Appcolors.primaryColor),
                    borderRadius: BorderRadius.all(Radius.circular(12))),
                child: Padding(
                  padding: const EdgeInsets.only(left: 10.0),
                  child: TextField(
                    decoration: InputDecoration(
                        hintText: gstNo,
                        border: InputBorder.none,
                        counterText: ""),
                    maxLength: 15,
                    onChanged: (value) {
                      setState(() {
                        // adharno = value;
                      });
                    },
                    controller: gstNumber,
                  ),
                )),
            const SizedBox(height: 10),
            const SizedBox(height: 10),
            countryName != "India"
                ? SizedBox()
                : Column(
                    children: [
                      const Align(
                        alignment: Alignment.topLeft,
                        child: Text("PAN Number",
                            style: TextStyle(
                                color: kPrimaryColor,
                                fontWeight: FontWeight.w500)),
                      ),
                      const SizedBox(height: 8),
                      Container(
                          decoration: BoxDecoration(
                              border: Border.all(
                                  width: 1, color: Appcolors.primaryColor),
                              borderRadius:
                                  BorderRadius.all(Radius.circular(12))),
                          child: Padding(
                            padding: const EdgeInsets.only(left: 10.0),
                            child: TextField(
                              decoration: InputDecoration(
                                  hintText: panNo,
                                  border: InputBorder.none,
                                  counterText: ""),
                              maxLength: 10,
                              onChanged: (value) {
                                setState(() {
                                  // adharno = value;
                                });
                              },
                              controller: panNumber,
                            ),
                          )),
                      const SizedBox(height: 10),
                      const SizedBox(height: 10),
                      const SizedBox(height: 10),
                    ],
                  ),
            Container(
              alignment: Alignment.centerLeft,
              child: const Text("GST Doc",
                  style: TextStyle(
                    color: kPrimaryColor,
                  )),
            ),
            const SizedBox(height: 8.0),
            Container(
                decoration: BoxDecoration(
                    border: Border.all(width: 1, color: Appcolors.primaryColor),
                    borderRadius: const BorderRadius.all(Radius.circular(12))),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                      vertical: 5.0, horizontal: 8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      gstDocumnet.toString() == "" ||
                              gstDocumnet.toString() == "null"
                          ? SizedBox()
                          : gstDocumnet.startsWith("http")
                              ? CircleAvatar(
                                  radius: 25,
                                  backgroundImage: NetworkImage(gstDocumnet),
                                )
                              : CircleAvatar(
                                  radius: 25,
                                  backgroundImage: FileImage(File(gstDocumnet)),
                                ),
                      InkWell(
                        onTap: () {
                          gstDoc();
                          setState(() {});
                        },
                        child: Container(
                          height: 45,
                          width: 120,
                          alignment: Alignment.center,
                          decoration: const BoxDecoration(
                              color: Appcolors.primaryColor,
                              borderRadius:
                                  BorderRadius.all(Radius.circular(8.0))),
                          child: const Text("Choose file",
                              style:
                                  TextStyle(color: Colors.white, fontSize: 16)),
                        ),
                      )
                    ],
                  ),
                )),
            countryName != "India"
                ? SizedBox()
                : Column(children: [
                    const SizedBox(height: 10),
                    Container(
                      alignment: Alignment.centerLeft,
                      child: const Text("PAN Doc",
                          style: TextStyle(
                              color: kPrimaryColor,
                              fontWeight: FontWeight.w500)),
                    ),
                    const SizedBox(height: 8.0),
                    Container(
                        decoration: BoxDecoration(
                            border: Border.all(
                                width: 1, color: Appcolors.primaryColor),
                            borderRadius:
                                const BorderRadius.all(Radius.circular(12))),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                              vertical: 5.0, horizontal: 8.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              panCardDocumnet.toString() == "" ||
                                      panCardDocumnet.toString() == "null"
                                  ? SizedBox()
                                  : panCardDocumnet.startsWith("http")
                                      ? CircleAvatar(
                                          radius: 25,
                                          backgroundImage:
                                              NetworkImage(panCardDocumnet),
                                        )
                                      : CircleAvatar(
                                          radius: 25,
                                          backgroundImage:
                                              FileImage(File(panCardDocumnet)),
                                        ),
                              InkWell(
                                onTap: () {
                                  panDocument();
                                },
                                child: Container(
                                  height: 45,
                                  width: 120,
                                  alignment: Alignment.center,
                                  decoration: const BoxDecoration(
                                      color: Appcolors.primaryColor,
                                      borderRadius: BorderRadius.all(
                                          Radius.circular(8.0))),
                                  child: const Text("Choose file",
                                      style: TextStyle(
                                          color: Colors.white, fontSize: 16)),
                                ),
                              )
                            ],
                          ),
                        )),
                  ])
          ],
        ),
      ),
    );
  }

  String basePath = "";
  String kycApproval = "";
  int kyc = 0;
  Widget textField(TextEditingController controller) => Column(
        children: [
          TextFormField(
            validator: (value) {
              if (value.isEmpty) {
                return "Required Field";
              } else {
                return null;
              }
            },
            maxLines: 3,
            controller: controller,
            textCapitalization: TextCapitalization.words,
            decoration: const InputDecoration(
                contentPadding: EdgeInsets.all(12),
                border: OutlineInputBorder(
                    borderSide: BorderSide(color: Color(0xffD0D5DD))),
                fillColor: Colors.white,
                isDense: true,
                filled: true),
          ),
          const SizedBox(height: 10)
        ],
      );
  String businessNameOfUser = '';
  String aacountType = '';
  String aadharNumberApi = '';
  String countryName;
  String stateName;
  String cityName;
  Future _getprofileData() async {
    setState(() {
      _loading = true;
    });
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
      setState(() {
        _loading = false;
        userType = data['User']['user_type'];
        profileimage = devImage + data['User']['avatar_path'].toString();
        myads = data['My Ads'].toString();
        mobile.text = data['User']['mobile'].toString();
        name.text = data['User']['name'].toString();
        email.text = data['User']['email'].toString();
        countryName = data['User']['country'].toString();
        stateName = data['User']['state'].toString();
        cityName = data['User']['city'].toString();

        location.text = "$cityName,$stateName,$countryName";
        log("===>${location.text}");

        fburl.text = data['User']['facebook_url'] == null
            ? ""
            : data['User']['facebook_url'].toString();
        twitterurl.text = data['User']['twitter_url'] == null
            ? ""
            : data['User']['twitter_url'].toString();
        googleplusurl.text = data['User']['google_plus_url'] == null
            ? ""
            : data['User']['google_plus_url'].toString();
        instragramurl.text = data['User']['instagram_url'] == null
            ? ""
            : data['User']['instagram_url'].toString();
        linkdinurl.text = data['User']['linkedin_url'] == null
            ? ""
            : data['User']['linkedin_url'].toString();
        youtubeurl.text = data['User']['youtube_url'] == null
            ? ""
            : data['User']['youtube_url'].toString();
        pincode.text = data['User']['pincode'].toString();
        _checknotifi =
            data['User']['notifications_allowed'] == 1 ? true : false;
        countryId = data['User']['country'].toString();
        stateId = data['User']['state'].toString();
        cityId = data['User']['city'].toString();
        selectedCountry = data['User']['country_name'].toString();
        selectedState = data['User']['state_name'].toString();
        selectedCity = data['User']['city_name'].toString();
        membership = data['User']['package_id'].toString();
        bankDName = data['User']['bank_name'].toString();
        bankDbranchName = data['User']['branch_name'].toString();
        accountDNumebr = data['User']['account_no'].toString();
        // accountType = data['User']['account_type'].toString();
        iFSCCODE = data['User']['ifsc'].toString();
        businessNameOfUser = data['User']['business_name'].toString();
        gstNo = data['User']['gst_no'].toString();
        panNo = data['User']['pan_no'].toString();
        accountType = data['User']['account_type'].toString();
        log("accountType--->$accountType");
        businessName.text = businessNameOfUser;
        aadharNumberApi = data['User']['adhaar_no'].toString();
        log(aadharNumberApi);

        log("businnes name--->${businessName.text}");
        kycApproval = data['User']['kyc_approval'].toString();
        if (aadharNumberApi == null ||
            aadharNumberApi == "" ||
            aadharNumberApi == "null") {
          aadharNumber.text = "";
          aadharNumberApi = "";
        } else {
          aadharNumber.text = aadharNumberApi;
        }

        kyc = data['User']['kyc'];
        log("kyc--->$kyc");
        if (gstNo == null || gstNo == "" || gstNo == "null") {
          gstNumber.text = "";
          gstNo = "";
        } else {
          gstNumber.text = gstNo;
        }
        if (panNo == null || panNo == "" || panNo == "null") {
          panNumber.text = "";
          panNo = "";
        } else {
          panNumber.text = panNo;
        }
        if (accountType == null || accountType == "" || accountType == "null") {
          dropdownvalue = "select";
        } else {
          dropdownvalue = accountType;
        }
        if (bankDName == null || bankDName == "" || bankDName == "null") {
          bankName.text = "";
          bankDName = "";
        } else {
          bankName.text = bankDName;
        }
        if (bankDbranchName == null ||
            bankDbranchName == "" ||
            bankDbranchName == "null") {
          branchName.text = "";
          bankDbranchName = "";
        } else {
          branchName.text = bankDbranchName;
        }
        if (accountDNumebr == null ||
            accountDNumebr == "" ||
            accountDNumebr == "null") {
          accountDNumebr = "";
        } else {
          accountNo.text = accountDNumebr;
        }
        if (iFSCCODE == null || iFSCCODE == "" || iFSCCODE == "null") {
          iFSCCode.text = "";
          iFSCCODE = "";
        } else {
          iFSCCode.text = iFSCCODE;
        }
        log("d val--->$dropdownvalue");
        basePath = data['User']['base_path'];
        aadharDocument =
            devImage + basePath + data['User']['adhaar_doc'].toString();
        panCardDocumnet =
            devImage + basePath + data['User']['pan_doc'].toString();
        gstDocumnet = devImage + basePath + data['User']['gst_doc'].toString();

        kycDocumentType = data['User']['kyc_document_type'];
        passportNumber = data['User']['passport_no'];
        passPortDoc = data['User']['passport_doc'];
        drivingLNumber = data['User']['driving_license_no'];
        drivinglDoc = data['User']['driving_license_doc'];

        List selectedList = data['User']['preferences'].toString().split(",");
        for (var element in selectedList) {
          commprefs.add(int.parse(element));
        }
        if (selectedList.contains("1")) {
          _emailcheck = true;
        }
        if (selectedList.contains("2")) {
          _smscheck = true;
        }
      });
    } else {
      setState(() {
        _loading = false;
      });
      throw Exception('Failed to get data due to ${response.body}');
    }
  }

  Future _getcountryData() async {
    var response = await http.get(Uri.parse(BASE_URL + getCountries), headers: {
      "Accept": "application/json",
      'Content-Type': 'application/json'
    });
    if (response.statusCode == 200) {
      Iterable list = json.decode(response.body)['Response']['countries'];
      setState(() {
        countrylistData.addAll(list);
      });
    } else {
      print(response.body);
      throw Exception('Failed to get data due to ${response.body}');
    }
  }

  // Future _getStateData(String id) async {
  //   setState(() {
  //     statelistData.clear();
  //     _loading = true;
  //   });
  //   final body = {
  //     "id": int.parse(id),
  //   };
  //   var response = await http
  //       .post(Uri.parse(BASE_URL + getState), body: jsonEncode(body), headers: {
  //     "Accept": "application/json",
  //     'Content-Type': 'application/json',
  //   });
  //   if (response.statusCode == 200) {
  //     Iterable list = json.decode(response.body)['Response']['states'];
  //     setState(() {
  //       _loading = false;
  //       statelistData.addAll(list);
  //     });
  //   } else {
  //     setState(() {
  //       _loading = false;
  //     });
  //     throw Exception('Failed to get data due to ${response.body}');
  //   }
  // }

  // Future _getCityData(String id) async {
  //   setState(() {
  //     citylistData.clear();
  //     _loading = true;
  //   });
  //   final body = {
  //     "id": int.parse(id),
  //   };
  //   var response = await http.post(Uri.parse(BASE_URL + getCity),
  //       body: jsonEncode(body),
  //       headers: {
  //         "Accept": "application/json",
  //         'Content-Type': 'application/json'
  //       });
  //   //print(response.body);
  //   if (response.statusCode == 200) {
  //     Iterable list = json.decode(response.body)['Response']['cities'];
  //     setState(() {
  //       _loading = false;
  //       citylistData.addAll(list);
  //     });
  //   } else {
  //     setState(() {
  //       _loading = false;
  //     });
  //     throw Exception('Failed to get data due to ${response.body}');
  //   }
  // }

  Future<void> showPhotoCaptureOptions() async {
    final ImagePicker picker = ImagePicker();
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
                            final XFile result = await picker.pickImage(
                              source: ImageSource.camera,
                              imageQuality: 80,
                              maxHeight: 480,
                              maxWidth: 640,
                            );
                            if (result != null) {
                              setState(() {
                                profileimage = result.path.toString();
                                profilepicbool = true;
                                log("pro====>$profilepicbool");
                              });
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
                            final XFile result = await picker.pickImage(
                              source: ImageSource.gallery,
                              imageQuality: 80,
                              maxHeight: 480,
                              maxWidth: 640,
                            );
                            if (result != null) {
                              setState(() {
                                profileimage = result.path.toString();
                                profilepicbool = true;
                                log("pro====>$profilepicbool");
                              });
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

  Future<void> panDocument() async {
    final ImagePicker picker = ImagePicker();
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
                            final XFile result = await picker.pickImage(
                              source: ImageSource.camera,
                              imageQuality: 80,
                              maxHeight: 480,
                              maxWidth: 640,
                            );
                            if (result != null) {
                              setState(() {
                                panCardDocumnet = result.path.toString();
                                panDocumentBool = true;
                              });
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
                            final XFile result = await picker.pickImage(
                              source: ImageSource.gallery,
                              imageQuality: 80,
                              maxHeight: 480,
                              maxWidth: 640,
                            );
                            if (result != null) {
                              setState(() {
                                panCardDocumnet = result.path.toString();
                                panDocumentBool = true;
                              });
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

  Future<void> gstDoc() async {
    final ImagePicker picker = ImagePicker();
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
                            final XFile result = await picker.pickImage(
                              source: ImageSource.camera,
                              imageQuality: 80,
                              maxHeight: 480,
                              maxWidth: 640,
                            );
                            if (result != null) {
                              setState(() {
                                gstDocumnet = result.path.toString();
                                gstDocumentBool = true;
                              });
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
                            final XFile result = await picker.pickImage(
                              source: ImageSource.gallery,
                              imageQuality: 80,
                              maxHeight: 480,
                              maxWidth: 640,
                            );
                            if (result != null) {
                              setState(() {
                                gstDocumnet = result.path.toString();
                                gstDocumentBool = true;
                              });
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

  Future<void> aadharDoc() async {
    final ImagePicker picker = ImagePicker();
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
                            final XFile result = await picker.pickImage(
                              source: ImageSource.camera,
                              imageQuality: 80,
                              maxHeight: 480,
                              maxWidth: 640,
                            );
                            if (result != null) {
                              setState(() {
                                aadharDocument = result.path.toString();
                                aadhardocBool = true;
                              });
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
                            final XFile result = await picker.pickImage(
                              source: ImageSource.gallery,
                              imageQuality: 80,
                              maxHeight: 480,
                              maxWidth: 640,
                            );
                            if (result != null) {
                              setState(() {
                                aadharDocument = result.path.toString();
                                aadhardocBool = true;
                              });
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

  String passportSelectDoc = "";
  bool passportBool;
  String dlSelectDoc = "";
  bool dlBool;

  Future<void> passportDoc() async {
    final ImagePicker picker = ImagePicker();
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
                            final XFile result = await picker.pickImage(
                              source: ImageSource.camera,
                              imageQuality: 80,
                              maxHeight: 480,
                              maxWidth: 640,
                            );
                            if (result != null) {
                              setState(() {
                                if (kycDocumentType == "passport") {
                                  passportSelectDoc = result.path.toString();
                                  log("passport doc--->$passportSelectDoc");
                                  passportBool = true;
                                } else {
                                  dlSelectDoc = result.path.toString();
                                  dlBool = true;
                                }
                              });
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
                            final XFile result = await picker.pickImage(
                              source: ImageSource.gallery,
                              imageQuality: 80,
                              maxHeight: 480,
                              maxWidth: 640,
                            );
                            if (result != null) {
                              setState(() {
                                if (kycDocumentType == "passport") {
                                  passportSelectDoc = result.path.toString();
                                  log("passport doc--->$passportSelectDoc");

                                  passportBool = true;
                                } else {
                                  dlSelectDoc = result.path.toString();
                                  dlBool = true;
                                }
                              });
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

  Future uploadBasicDetailsWithAAdharImage() async {
    setState(() {
      buttonLoading = true;
    });
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String userId = prefs.getString('userid');
    var url = Apis.basicProfileUpdateApi;

    var bodyMap = {
      "id": userId.toString(),
      "address": location.text.toString(),
      "country": selectedCountry.toString(),
      "state": selectedState.toString(),
      "city": selectedCity.toString(),
      "pincode": pincode.text.toString(),
      "com_prefs": commprefs.join(","),
      "instagram_url": instragramurl.text.toString(),
      "google_plus_url": googleplusurl.text.toString(),
      "facebook_url": fburl.text.toString(),
      "name": name.text.toString(),
      "twitter_url": twitterurl.text.toString(),
      "linkedin_url": linkdinurl.text.toString(),
      "youtube_url": youtubeurl.text.toString(),
      "account_no": accountNo.text.toString(),
      "ifsc": iFSCCode.text.toString(),
      "bank_name": bankName.text.toString(),
      "branch_name": branchName.text.toString(),
      "account_type": dropdownvalue == "select" ? "" : dropdownvalue,
      "adhaar_no": aadharNumber.text.toString(),
      "business_name": businessName.text.toString(),
      "gst_no": gstNumber.text.toString(),
      "kyc_resubmit": resubmitValue,
      "pan_no": panNumber.text.toString(),
    };

    log(bodyMap.toString());

    try {
      final request = http.MultipartRequest(
        'POST',
        Uri.parse(url),
      );

      request.headers.addAll({
        'Authorization': 'Bearer ${prefs.getString("token")}',
      });
      // if (gstDocumnet.isNotEmpty) {
      //   var pic = await http.MultipartFile.fromPath(
      //     'gst_doc',
      //     gstDocumnet,
      //   );
      //   request.files.add(pic);
      //   log("Done====>  $pic");
      // } else {
      //   log("ENTETED====> aa $gstDocumnet");
      // }
      // if (panCardDocumnet.isNotEmpty) {
      //   var pic = await http.MultipartFile.fromPath('pan_doc', panCardDocumnet);
      //   request.files.add(pic);
      //   log("Done====>  $pic");
      // } else {
      //   // bodyMap = {"pan_doc": ""};
      //   log("ENTETED====>ss$panCardDocumnet");
      // }
      if (aadharDocument.toString().isNotEmpty) {
        var pic = await http.MultipartFile.fromPath(
            'adhaar_doc', aadharDocument.toString());
        request.files.add(pic);
        log("aadhar Imgae====>aa  $pic");
      } else {
        log("aadhar Image====>dd  $aadharDocument");
      }

      request.fields.addAll(bodyMap);
      var response = await request.send();

      log("body=====>$bodyMap");

      var responseData = await response.stream.toBytes();
      var responseString = String.fromCharCodes(responseData);

      var result = jsonDecode(responseData.toString());

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
              MaterialPageRoute(builder: (context) => UserDetailScreen()));
          Fluttertoast.showToast(
            msg: result['ErrorMessage'],
            toastLength: Toast.LENGTH_LONG,
            gravity: ToastGravity.CENTER,
            timeInSecForIosWeb: 1,
            backgroundColor: Colors.green.shade700,
            textColor: Colors.white,
            fontSize: 16.0,
          );
          setState(() {
            buttonLoading = false;
          });
        } else {
          Fluttertoast.showToast(
            msg: result['ErrorMessage'],
            toastLength: Toast.LENGTH_LONG,
            gravity: ToastGravity.CENTER,
            timeInSecForIosWeb: 1,
            backgroundColor: Colors.green.shade700,
            textColor: Colors.white,
            fontSize: 16.0,
          );
          setState(() {
            buttonLoading = false;
          });
        }
      }
    } on Exception catch (e) {
      Fluttertoast.showToast(msg: "Profile pic required ");
      setState(() {
        buttonLoading = false;
      });
      return NullThrownError();
    }
    setState(() {
      buttonLoading = false;
    });
  }

  Future uploadBasicDetailsWithProfileImage() async {
    setState(() {
      buttonLoading = true;
    });
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String userId = prefs.getString('userid');
    var url = Apis.basicProfileUpdateApi;

    var bodyMap = {
      "id": userId.toString(),
      "address": location.text.toString(),
      "country": selectedCountry.toString(),
      "state": selectedState.toString(),
      "city": selectedCity.toString(),
      "pincode": pincode.text.toString(),
      "com_prefs": commprefs.join(","),
      "instagram_url": instragramurl.text.toString(),
      "google_plus_url": googleplusurl.text.toString(),
      "facebook_url": fburl.text.toString(),
      "name": name.text.toString(),
      "twitter_url": twitterurl.text.toString(),
      "linkedin_url": linkdinurl.text.toString(),
      "youtube_url": youtubeurl.text.toString(),
      "account_no": accountNo.text.toString(),
      "ifsc": iFSCCode.text.toString(),
      "bank_name": bankName.text.toString(),
      "branch_name": branchName.text.toString(),
      "account_type": dropdownvalue == "select" ? "" : dropdownvalue,
      "adhaar_no": aadharNumber.text.toString(),
      "business_name": businessName.text.toString(),
      "gst_no": gstNumber.text.toString(),
      "pan_no": panNumber.text.toString(),
      "kyc_resubmit": resubmitValue,
    };

    log(bodyMap.toString());

    try {
      final request = http.MultipartRequest(
        'POST',
        Uri.parse(url),
      );

      request.headers.addAll({
        'Authorization': 'Bearer ${prefs.getString("token")}',
      });
      // if (gstDocumnet.isNotEmpty) {
      //   var pic = await http.MultipartFile.fromPath(
      //     'gst_doc',
      //     gstDocumnet,
      //   );
      //   request.files.add(pic);
      //   log("Done====>  $pic");
      // } else {
      //   log("ENTETED====> aa $gstDocumnet");
      // }
      // if (panCardDocumnet.isNotEmpty) {
      //   var pic = await http.MultipartFile.fromPath('pan_doc', panCardDocumnet);
      //   request.files.add(pic);
      //   log("Done====>  $pic");
      // } else {
      //   // bodyMap = {"pan_doc": ""};
      //   log("ENTETED====>ss$panCardDocumnet");
      // }
      if (profileimage.toString().isNotEmpty) {
        var pic = await http.MultipartFile.fromPath(
            'avatar', profileimage.toString());
        request.files.add(pic);
        log("Done====>aa  $pic");
      } else {
        log("ENTETED====>dd  $profileimage");
      }

      request.fields.addAll(bodyMap);
      var response = await request.send();

      log("body=====>$bodyMap");

      var responseData = await response.stream.toBytes();
      var responseString = String.fromCharCodes(responseData);

      var result = jsonDecode(responseData.toString());

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
              MaterialPageRoute(builder: (context) => UserDetailScreen()));
          Fluttertoast.showToast(
            msg: result['ErrorMessage'],
            toastLength: Toast.LENGTH_LONG,
            gravity: ToastGravity.CENTER,
            timeInSecForIosWeb: 1,
            backgroundColor: Colors.green.shade700,
            textColor: Colors.white,
            fontSize: 16.0,
          );
          setState(() {
            buttonLoading = false;
          });
        } else {
          Fluttertoast.showToast(
            msg: result['ErrorMessage'],
            toastLength: Toast.LENGTH_LONG,
            gravity: ToastGravity.CENTER,
            timeInSecForIosWeb: 1,
            backgroundColor: Colors.green.shade700,
            textColor: Colors.white,
            fontSize: 16.0,
          );
          setState(() {
            buttonLoading = false;
          });
        }
      }
    } on Exception catch (e) {
      Fluttertoast.showToast(msg: "Profile pic required ");
      setState(() {
        buttonLoading = false;
      });
      return NullThrownError();
    }
    setState(() {
      buttonLoading = false;
    });
  }

  Future uploadBasicDetailsWithGstImage() async {
    setState(() {
      buttonLoading = true;
    });
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String userId = prefs.getString('userid');
    var url = Apis.basicProfileUpdateApi;

    var bodyMap = {
      "id": userId.toString(),
      "address": location.text.toString(),
      "country": selectedCountry.toString(),
      "state": selectedState.toString(),
      "city": selectedCity.toString(),
      "pincode": pincode.text.toString(),
      "com_prefs": commprefs.join(","),
      "instagram_url": instragramurl.text.toString(),
      "google_plus_url": googleplusurl.text.toString(),
      "facebook_url": fburl.text.toString(),
      "name": name.text.toString(),
      "twitter_url": twitterurl.text.toString(),
      "linkedin_url": linkdinurl.text.toString(),
      "youtube_url": youtubeurl.text.toString(),
      "account_no": accountNo.text.toString(),
      "ifsc": iFSCCode.text.toString(),
      "bank_name": bankName.text.toString(),
      "branch_name": branchName.text.toString(),
      "account_type": dropdownvalue == "select" ? "" : dropdownvalue,
      "adhaar_no": aadharNumber.text.toString(),
      "business_name": businessName.text.toString(),
      "gst_no": gstNumber.text.toString(),
      "pan_no": panNumber.text.toString(),
      "kyc_resubmit": resubmitValue,
    };

    try {
      final request = http.MultipartRequest(
        'POST',
        Uri.parse(url),
      );

      request.headers.addAll({
        'Authorization': 'Bearer ${prefs.getString("token")}',
      });
      if (gstDocumnet.isNotEmpty) {
        var pic = await http.MultipartFile.fromPath(
          'gst_doc',
          gstDocumnet,
        );
        request.files.add(pic);
        log("Done====>  $pic");
      } else {
        log("ENTETED====> aa $gstDocumnet");
      }

      request.fields.addAll(bodyMap);
      var response = await request.send();

      log("body=====>$bodyMap");

      var responseData = await response.stream.toBytes();
      var responseString = String.fromCharCodes(responseData);

      var result = jsonDecode(responseData.toString());

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
              MaterialPageRoute(builder: (context) => UserDetailScreen()));
          Fluttertoast.showToast(
            msg: result['ErrorMessage'],
            toastLength: Toast.LENGTH_LONG,
            gravity: ToastGravity.CENTER,
            timeInSecForIosWeb: 1,
            backgroundColor: Colors.green.shade700,
            textColor: Colors.white,
            fontSize: 16.0,
          );
          setState(() {
            buttonLoading = false;
          });
        } else {
          Fluttertoast.showToast(
            msg: result['ErrorMessage'],
            toastLength: Toast.LENGTH_LONG,
            gravity: ToastGravity.CENTER,
            timeInSecForIosWeb: 1,
            backgroundColor: Colors.green.shade700,
            textColor: Colors.white,
            fontSize: 16.0,
          );
          setState(() {
            buttonLoading = false;
          });
        }
      }
    } on Exception catch (e) {
      Fluttertoast.showToast(msg: "Profile pic required ");
      setState(() {
        buttonLoading = false;
      });
      return NullThrownError();
    }
    setState(() {
      buttonLoading = false;
    });
  }

  Future uploadBasicDetailsWithPanImage() async {
    setState(() {
      buttonLoading = true;
    });
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String userId = prefs.getString('userid');
    var url = Apis.basicProfileUpdateApi;

    var bodyMap = {
      "id": userId.toString(),
      "address": location.text.toString(),
      "country": selectedCountry.toString(),
      "state": selectedState.toString(),
      "city": selectedCity.toString(),
      "pincode": pincode.text.toString(),
      "com_prefs": commprefs.join(","),
      "instagram_url": instragramurl.text.toString(),
      "google_plus_url": googleplusurl.text.toString(),
      "facebook_url": fburl.text.toString(),
      "name": name.text.toString(),
      "twitter_url": twitterurl.text.toString(),
      "linkedin_url": linkdinurl.text.toString(),
      "youtube_url": youtubeurl.text.toString(),
      "account_no": accountNo.text.toString(),
      "ifsc": iFSCCode.text.toString(),
      "bank_name": bankName.text.toString(),
      "branch_name": branchName.text.toString(),
      "account_type": dropdownvalue == "select" ? "" : dropdownvalue,
      "adhaar_no": aadharNumber.text.toString(),
      "business_name": businessName.text.toString(),
      "gst_no": gstNumber.text.toString(),
      "pan_no": panNumber.text.toString(),
      "kyc_resubmit": resubmitValue,
    };

    try {
      final request = http.MultipartRequest(
        'POST',
        Uri.parse(url),
      );

      request.headers.addAll({
        'Authorization': 'Bearer ${prefs.getString("token")}',
      });
      if (panCardDocumnet.isNotEmpty) {
        var pic = await http.MultipartFile.fromPath('pan_doc', panCardDocumnet);
        request.files.add(pic);
        log("Done====>  $pic");
      } else {
        // bodyMap = {"pan_doc": ""};
        log("ENTETED====>ss$panCardDocumnet");
      }
      request.fields.addAll(bodyMap);
      var response = await request.send();

      log("body=====>$bodyMap");

      var responseData = await response.stream.toBytes();
      var responseString = String.fromCharCodes(responseData);

      var result = jsonDecode(responseData.toString());

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
              MaterialPageRoute(builder: (context) => UserDetailScreen()));
          Fluttertoast.showToast(
            msg: result['ErrorMessage'],
            toastLength: Toast.LENGTH_LONG,
            gravity: ToastGravity.CENTER,
            timeInSecForIosWeb: 1,
            backgroundColor: Colors.green.shade700,
            textColor: Colors.white,
            fontSize: 16.0,
          );
          setState(() {
            buttonLoading = false;
          });
        } else {
          Fluttertoast.showToast(
            msg: result['ErrorMessage'],
            toastLength: Toast.LENGTH_LONG,
            gravity: ToastGravity.CENTER,
            timeInSecForIosWeb: 1,
            backgroundColor: Colors.green.shade700,
            textColor: Colors.white,
            fontSize: 16.0,
          );
          setState(() {
            buttonLoading = false;
          });
        }
      }
    } on Exception catch (e) {
      Fluttertoast.showToast(msg: "Profile pic required ");
      setState(() {
        buttonLoading = false;
      });
      return NullThrownError();
    }
    setState(() {
      buttonLoading = false;
    });
  }

  Future uploadBasicDetailsWitoutImage() async {
    setState(() {
      buttonLoading = true;
    });
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String userId = prefs.getString('userid');
    var url = Apis.basicProfileUpdateApi;

    var bodyMap = {
      "id": userId.toString(),
      "address": location.text.toString(),
      "country": selectedCountry.toString(),
      "state": selectedState.toString(),
      "city": selectedCity.toString(),
      "pincode": pincode.text.toString(),
      "com_prefs": commprefs.join(","),
      "instagram_url": instragramurl.text.toString(),
      "google_plus_url": googleplusurl.text.toString(),
      "facebook_url": fburl.text.toString(),
      "name": name.text.toString(),
      "twitter_url": twitterurl.text.toString(),
      "linkedin_url": linkdinurl.text.toString(),
      "youtube_url": youtubeurl.text.toString(),
      "account_no": accountNo.text.toString(),
      "ifsc": iFSCCode.text.toString(),
      "bank_name": bankName.text.toString(),
      "branch_name": branchName.text.toString(),
      "account_type": dropdownvalue == "select" ? "" : dropdownvalue,

      "adhaar_no": aadharNumber.text.toString(),
      "business_name": businessName.text.toString(),
      "gst_no": gstNumber.text.toString(),
      "pan_no": panNumber.text.toString(),
      "kyc_resubmit": resubmitValue,
      "adhaar_doc": aadharDocument
      // "pan_doc": "",
      // "gst_doc": "",
      // "avatar": ""
    };
    log("body=====>$bodyMap");

    var response = await APIHelper.apiPostRequest(url, bodyMap);
    var result = jsonDecode(response);

    if (result['ErrorCode'] == 0) {
      Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (context) => UserDetailScreen()));
      Fluttertoast.showToast(
        msg: result['ErrorMessage'],
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.CENTER,
        timeInSecForIosWeb: 1,
        backgroundColor: Colors.green.shade700,
        textColor: Colors.white,
        fontSize: 16.0,
      );
      setState(() {
        buttonLoading = false;
      });
    } else {
      Fluttertoast.showToast(
        msg: result['ErrorMessage'],
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.CENTER,
        timeInSecForIosWeb: 1,
        backgroundColor: Colors.green.shade700,
        textColor: Colors.white,
        fontSize: 16.0,
      );
      setState(() {
        buttonLoading = false;
      });
    }

    setState(() {
      buttonLoading = false;
    });
  }

  Future uploadBasicDetailsWithKyc() async {
    setState(() {
      buttonLoading = true;
    });
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String userId = prefs.getString('userid');
    var url = Apis.basicProfileUpdateApi;

    var bodyMap = {
      "id": userId.toString(),
      "address": location.text.toString(),
      "country": selectedCountry.toString(),
      "state": selectedState.toString(),
      "city": selectedCity.toString(),
      "pincode": pincode.text.toString(),
      "com_prefs": commprefs.join(","),
      "instagram_url": instragramurl.text.toString(),
      "google_plus_url": googleplusurl.text.toString(),
      "facebook_url": fburl.text.toString(),
      "name": name.text.toString(),
      "twitter_url": twitterurl.text.toString(),
      "linkedin_url": linkdinurl.text.toString(),
      "youtube_url": youtubeurl.text.toString(),
      "account_no": accountNo.text.toString(),
      "ifsc": iFSCCode.text.toString(),
      "bank_name": bankName.text.toString(),
      "branch_name": branchName.text.toString(),
      "account_type": dropdownvalue == "select" ? "" : dropdownvalue,
      "adhaar_no": aadharNumber.text.toString(),
      "business_name": businessName.text.toString(),
      "gst_no": gstNumber.text.toString(),
      "pan_no": panNumber.text.toString(),
      "kyc_resubmit": resubmitValue,
    };
    log("body-->$bodyMap");

    try {
      final request = http.MultipartRequest(
        'POST',
        Uri.parse(url),
      );

      request.headers.addAll({
        'Authorization': 'Bearer ${prefs.getString("token")}',
      });
      if (gstDocumnet.isNotEmpty) {
        var pic = await http.MultipartFile.fromPath(
          'gst_doc',
          gstDocumnet,
        );
        request.files.add(pic);
        log("Done====>  $pic");
      } else {
        log("ENTETED====> aa $gstDocumnet");
      }
      if (panCardDocumnet.isNotEmpty) {
        var pic = await http.MultipartFile.fromPath('pan_doc', panCardDocumnet);
        request.files.add(pic);
        log("Done====>  $pic");
      } else {
        // bodyMap = {"pan_doc": ""};
        log("ENTETED====>ss$panCardDocumnet");
      }
      if (profileimage.toString().isNotEmpty) {
        var pic = await http.MultipartFile.fromPath(
            'avatar', profileimage.toString());
        request.files.add(pic);
        log("Done====>aa  $pic");
      } else {
        log("ENTETED====>dd  $profileimage");
      }
      if (aadharDocument.toString().isNotEmpty) {
        var pic = await http.MultipartFile.fromPath(
            'adhaar_doc', aadharDocument.toString());
        request.files.add(pic);
        log("Done====>aa  $pic");
      } else {
        log("ENTETED====>dd  $aadharDocument");
      }

      request.fields.addAll(bodyMap);
      var response = await request.send();

      log("body=====>$bodyMap");

      var responseData = await response.stream.toBytes();
      var responseString = String.fromCharCodes(responseData);

      var result = jsonDecode(responseData.toString());

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
              MaterialPageRoute(builder: (context) => UserDetailScreen()));
          Fluttertoast.showToast(
            msg: result['ErrorMessage'],
            toastLength: Toast.LENGTH_LONG,
            gravity: ToastGravity.CENTER,
            timeInSecForIosWeb: 1,
            backgroundColor: Colors.green.shade700,
            textColor: Colors.white,
            fontSize: 16.0,
          );
          setState(() {
            buttonLoading = false;
          });
        } else {
          Fluttertoast.showToast(
            msg: result['ErrorMessage'],
            toastLength: Toast.LENGTH_LONG,
            gravity: ToastGravity.CENTER,
            timeInSecForIosWeb: 1,
            backgroundColor: Colors.green.shade700,
            textColor: Colors.white,
            fontSize: 16.0,
          );
          setState(() {
            buttonLoading = false;
          });
        }
      }
    } on Exception catch (e) {
      Fluttertoast.showToast(msg: "Profile pic required ");
      setState(() {
        buttonLoading = false;
      });
      return NullThrownError();
    }
    setState(() {
      buttonLoading = false;
    });
  }

  Future uploadBasicDetails() async {
    setState(() {
      buttonLoading = true;
    });
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String userId = prefs.getString('userid');
    var url = Apis.basicProfileUpdateApi;

    var bodyMap = {
      "id": userId.toString(),
      "address": location.text.toString(),
      "country": selectedCountry.toString(),
      "state": selectedState.toString(),
      "city": selectedCity.toString(),
      "pincode": pincode.text.toString(),
      "com_prefs": commprefs.join(","),
      "instagram_url": instragramurl.text.toString(),
      "google_plus_url": googleplusurl.text.toString(),
      "facebook_url": fburl.text.toString(),
      "name": name.text.toString(),
      "twitter_url": twitterurl.text.toString(),
      "linkedin_url": linkdinurl.text.toString(),
      "youtube_url": youtubeurl.text.toString(),
      "account_no": accountNo.text.toString(),
      "ifsc": iFSCCode.text.toString(),
      "bank_name": bankName.text.toString(),
      "branch_name": branchName.text.toString(),
      "account_type": dropdownvalue == "select" ? "" : dropdownvalue,
      "adhaar_no": aadharNumber.text.toString(),
      "business_name": businessName.text.toString(),
      "gst_no": gstNumber.text.toString(),
      "pan_no": panNumber.text.toString(),
      "kyc_resubmit": resubmitValue
    };
    log("body-->$bodyMap");

    try {
      final request = http.MultipartRequest(
        'POST',
        Uri.parse(url),
      );

      request.headers.addAll({
        'Authorization': 'Bearer ${prefs.getString("token")}',
      });
      if (gstDocumnet.isNotEmpty) {
        var pic = await http.MultipartFile.fromPath(
          'gst_doc',
          gstDocumnet,
        );
        request.files.add(pic);
        log("Done====>  $pic");
      } else {
        log("ENTETED====> aa $gstDocumnet");
      }
      if (panCardDocumnet.isNotEmpty) {
        var pic = await http.MultipartFile.fromPath('pan_doc', panCardDocumnet);
        request.files.add(pic);
        log("Done====>  $pic");
      } else {
        // bodyMap = {"pan_doc": ""};
        log("ENTETED====>ss$panCardDocumnet");
      }
      if (profileimage.toString().isNotEmpty) {
        var pic = await http.MultipartFile.fromPath(
            'avatar', profileimage.toString());
        request.files.add(pic);
        log("Done====>aa  $pic");
      } else {
        log("ENTETED====>dd  $profileimage");
      }

      request.fields.addAll(bodyMap);
      var response = await request.send();

      log("body=====>$bodyMap");

      var responseData = await response.stream.toBytes();
      var responseString = String.fromCharCodes(responseData);

      var result = jsonDecode(responseData.toString());

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
              MaterialPageRoute(builder: (context) => UserDetailScreen()));
          Fluttertoast.showToast(
            msg: result['ErrorMessage'],
            toastLength: Toast.LENGTH_LONG,
            gravity: ToastGravity.CENTER,
            timeInSecForIosWeb: 1,
            backgroundColor: Colors.green.shade700,
            textColor: Colors.white,
            fontSize: 16.0,
          );
          setState(() {
            buttonLoading = false;
          });
        } else {
          Fluttertoast.showToast(
            msg: result['ErrorMessage'],
            toastLength: Toast.LENGTH_LONG,
            gravity: ToastGravity.CENTER,
            timeInSecForIosWeb: 1,
            backgroundColor: Colors.green.shade700,
            textColor: Colors.white,
            fontSize: 16.0,
          );
          setState(() {
            buttonLoading = false;
          });
        }
      }
    } on Exception catch (e) {
      Fluttertoast.showToast(msg: "Profile pic required ");
      setState(() {
        buttonLoading = false;
      });
      return NullThrownError();
    }
    setState(() {
      buttonLoading = false;
    });
  }

  Future uploadBasicDetailsofAnotherCountry() async {
    setState(() {
      buttonLoading = true;
    });
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String userId = prefs.getString('userid');
    var url = Apis.basicProfileUpdateApi;

    var bodyMap = {
      "id": userId.toString(),
      "address": location.text.toString(),
      "country": selectedCountry.toString(),
      "state": selectedState.toString(),
      "city": selectedCity.toString(),
      "pincode": pincode.text.toString(),
      "com_prefs": commprefs.join(","),
      "instagram_url": instragramurl.text.toString(),
      "google_plus_url": googleplusurl.text.toString(),
      "facebook_url": fburl.text.toString(),
      "name": name.text.toString(),
      "twitter_url": twitterurl.text.toString(),
      "linkedin_url": linkdinurl.text.toString(),
      "youtube_url": youtubeurl.text.toString(),
      "account_no": accountNo.text.toString(),
      "ifsc": iFSCCode.text.toString(),
      "bank_name": bankName.text.toString(),
      "branch_name": branchName.text.toString(),
      "account_type": dropdownvalue == "select" ? "" : dropdownvalue,
      "business_name": businessName.text.toString(),
      "gst_no": gstNumber.text.toString(),
      "kyc_resubmit": resubmitValue,
      "passport_no": passportController.text.isEmpty
          ? passportNumber ?? ""
          : passportController.text.toString(),
      "driving_license_no": dlController.text.isEmpty
          ? drivingLNumber ?? ""
          : dlController.text.toString(),
    };
    log("body-->$bodyMap");

    final request = http.MultipartRequest(
      'POST',
      Uri.parse(url),
    );

    request.headers.addAll({
      'Authorization': 'Bearer ${prefs.getString("token")}',
    });

    if (kycDocumentType == "passport") {
      if (passportSelectDoc.toString() != "") {
        if (passportSelectDoc.toString().isNotEmpty) {
          var pic = await http.MultipartFile.fromPath(
            'passport_doc',
            passportSelectDoc,
          );
          request.files.add(pic);
          log("Done====>  $pic");
        } else {
          log("ENTETED====> aa $passportSelectDoc");
        }
      } else {
        // if (passPortDoc.toString().isNotEmpty) {
        //   var pic = await http.MultipartFile.fromPath(
        //     'passport_doc',
        //     passPortDoc,
        //   );
        //   request.files.add(pic);
        //   log("Done====>  $pic");
        // } else {
        //   log("ENTETED====> aa $passportSelectDoc");
        // }
      }
    } else {
      if (dlSelectDoc == "" || dlSelectDoc.isEmpty) {
        if (dlSelectDoc.isNotEmpty) {
          var pic = await http.MultipartFile.fromPath(
            'driving_license_doc',
            dlSelectDoc,
          );
          request.files.add(pic);
          log("Done====>  $pic");
        } else {
          log("ENTETED====> aa $dlSelectDoc");
        }
      }
      // } else {
      //   // if (drivinglDoc.isNotEmpty) {
      //   //   var pic = await http.MultipartFile.fromPath(
      //   //     'driving_license_doc',
      //   //     drivinglDoc,
      //   //   );
      //   //   request.files.add(pic);
      //   //   log("Done====>  $pic");
      //   // } else {
      //   //   log("ENTETED====> aa $drivinglDoc");
      //   // }
      // }
    }

    if (profileimage.toString().isNotEmpty && profilepicbool == true) {
      var pic =
          await http.MultipartFile.fromPath('avatar', profileimage.toString());
      request.files.add(pic);
      log("Done====>aa  $pic");
    }
    if (gstDocumnet.toString().isNotEmpty && gstDocumentBool == true) {
      var pic =
          await http.MultipartFile.fromPath('gst_doc', gstDocumnet.toString());
      request.files.add(pic);
      log("Done====>aa  $pic");
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
            MaterialPageRoute(builder: (context) => UserDetailScreen()));
        Fluttertoast.showToast(
          msg: result['ErrorMessage'],
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.CENTER,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.green.shade700,
          textColor: Colors.white,
          fontSize: 16.0,
        );
        setState(() {
          buttonLoading = false;
        });
      } else {
        Fluttertoast.showToast(
          msg: result['ErrorMessage'],
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.CENTER,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.green.shade700,
          textColor: Colors.white,
          fontSize: 16.0,
        );
        setState(() {
          buttonLoading = false;
        });
      }
      setState(() {
        buttonLoading = false;
      });
    }

    setState(() {
      buttonLoading = false;
    });
  }

  Future uploadBasicDetailsofAnotherCountryWithGst() async {
    setState(() {
      buttonLoading = true;
    });
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String userId = prefs.getString('userid');
    var url = Apis.basicProfileUpdateApi;

    var bodyMap = {
      "id": userId.toString(),
      "address": location.text.toString(),
      "country": selectedCountry.toString(),
      "state": selectedState.toString(),
      "city": selectedCity.toString(),
      "pincode": pincode.text.toString(),
      "com_prefs": commprefs.join(","),
      "instagram_url": instragramurl.text.toString(),
      "google_plus_url": googleplusurl.text.toString(),
      "facebook_url": fburl.text.toString(),
      "name": name.text.toString(),
      "twitter_url": twitterurl.text.toString(),
      "linkedin_url": linkdinurl.text.toString(),
      "youtube_url": youtubeurl.text.toString(),
      "account_no": accountNo.text.toString(),
      "ifsc": iFSCCode.text.toString(),
      "bank_name": bankName.text.toString(),
      "branch_name": branchName.text.toString(),
      "account_type": dropdownvalue == "select" ? "" : dropdownvalue,
      "business_name": businessName.text.toString(),
      "gst_no": gstNumber.text.toString(),
      "kyc_resubmit": resubmitValue,
      "passport_no": passportController.text.isEmpty
          ? passportNumber ?? ""
          : passportController.text.toString(),
      "driving_license_no": dlController.text.isEmpty
          ? drivingLNumber ?? ""
          : dlController.text.toString(),
    };
    log("body-->$bodyMap");

    final request = http.MultipartRequest(
      'POST',
      Uri.parse(url),
    );

    request.headers.addAll({
      'Authorization': 'Bearer ${prefs.getString("token")}',
    });

    if (profileimage.toString().isNotEmpty) {
      var pic =
          await http.MultipartFile.fromPath('avatar', profileimage.toString());
      request.files.add(pic);
      log("Done====>aa  $pic");
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
            MaterialPageRoute(builder: (context) => UserDetailScreen()));
        Fluttertoast.showToast(
          msg: result['ErrorMessage'],
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.CENTER,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.green.shade700,
          textColor: Colors.white,
          fontSize: 16.0,
        );
        setState(() {
          buttonLoading = false;
        });
      } else {
        Fluttertoast.showToast(
          msg: result['ErrorMessage'],
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.CENTER,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.green.shade700,
          textColor: Colors.white,
          fontSize: 16.0,
        );
        setState(() {
          buttonLoading = false;
        });
      }
      setState(() {
        buttonLoading = false;
      });
    }

    setState(() {
      buttonLoading = false;
    });
  }

  Future _getAdviserAdProducts() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final body = {
      "id": prefs.getString('userid'),
    };
    var response = await http.post(Uri.parse(BASE_URL + advertiseradsurl),
        body: jsonEncode(body),
        headers: {
          "Accept": "application/json",
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${prefs.getString("token")}',
        });
    if (response.statusCode == 200) {
      var data = json.decode(response.body)['Response'];
      setState(() {
        adviseradslist.addAll(data);
      });
    }
  }
}
