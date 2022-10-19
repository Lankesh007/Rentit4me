// ignore_for_file: prefer_const_literals_to_create_immutables, prefer_const_constructors, library_private_types_in_public_api, no_logic_in_create_state, must_be_immutable, use_build_context_synchronously

import 'dart:convert';
import 'dart:developer';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:group_radio_button/group_radio_button.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:rentit4me_new/models/search_product_model.dart';
import 'package:rentit4me_new/network/api.dart';
import 'package:rentit4me_new/themes/constant.dart';
import 'package:http/http.dart' as http;
import 'package:rentit4me_new/views/product_detail_screen.dart';
import 'package:rentit4me_new/widgets/api_helper.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UserfinderDataScreen extends StatefulWidget {
  String getlocation;
  String getcategory;
  String getcategoryslug;
  String cityId;
  String finalLocation;

  List data = [];
  UserfinderDataScreen(
      {Key key,
      this.getlocation,
      this.getcategory,
      this.getcategoryslug,
      this.cityId,
      this.finalLocation,
      this.data})
      : super(key: key);

  @override
  _UserfinderDataScreenState createState() =>
      _UserfinderDataScreenState(getlocation, getcategory, getcategoryslug);
}

class _UserfinderDataScreenState extends State<UserfinderDataScreen> {
  String getlocation;
  String getcategory;
  String getcategoryslug;
  _UserfinderDataScreenState(
      this.getlocation, this.getcategory, this.getcategoryslug);

  GlobalKey scrollKey = GlobalKey();

  List<SearchProductModel> searchProductList = [];

  int skipvalue = 0;
  int pricesorting;
  int renttyping;

  String locationvalue;
  String categoryvalue;

  List location = [];
  List category = [];
  List categorylistData = [];
  String categoryslugname;

  List<dynamic> _searchlist = [];
  List<dynamic> productData = [];
  bool isLoading = false;

  bool isListing = true;
  final controller = ScrollController();
  final TextEditingController typeAheadController = TextEditingController();
  final searchController = TextEditingController();

  bool isSearching = false;

  String _priceGroupValue;
  String _rentGroupValue;

  String usercity;
  String userstate;
  String usercountry;
  String cityId = '';
  bool selectCity = false;
  String currentCity = "";
  bool findCity = false;
  String countryName = '';
  String userId = '';

  _getCountryName() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    countryName = preferences.getString('country');
    currentCity = preferences.getString('city');
    userId = preferences.getString('userid');

    log("currentCity---->$currentCity");
  }

  Future<void> showMyDialog() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: true,
      // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          content: SizedBox(
            height: MediaQuery.of(context).size.height * 0.4,
            child: SingleChildScrollView(
              child: Column(
                children: [
                  SizedBox(
                    width: MediaQuery.of(context).size.width,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text("Provide Location",
                            style: TextStyle(
                                color: Colors.black,
                                fontWeight: FontWeight.bold)),
                        IconButton(
                            onPressed: () async {
                              Navigator.pop(context);
                            },
                            icon: const Icon(Icons.close, color: Colors.grey))
                      ],
                    ),
                  ),
                  const Divider(
                    color: Colors.grey,
                  ),
                  SizedBox(
                    width: MediaQuery.of(context).size.width,
                    child: Row(
                      children: [
                        IconButton(
                            onPressed: () async {
                              Navigator.pop(context);
                            },
                            icon: const Icon(Icons.location_on_outlined,
                                color: Colors.grey)),
                        SizedBox(
                            width: MediaQuery.of(context).size.width * 0.55,
                            // height: MediaQuery.of(context).size.height*0.03,

                            child: const Text(
                              "Please provide your delivery location to see products at nearby store",
                              maxLines: 3,
                            )),
                      ],
                    ),
                  ),
                  const Divider(
                    color: Colors.grey,
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  Column(
                    children: [
                      InkWell(
                        onTap: () {
                          setState(() {
                            findCity = true;
                            log('=---->$currentCity');
                            searchProductList.clear();
                            _searchlist.clear();
                            searchController.clear();
                          });
                          // _determinePosition();
                          var snackBar = const SnackBar(
                              content: Text('City Auto Detected !!'));
                          ScaffoldMessenger.of(context).showSnackBar(snackBar);

                          Navigator.pop(context);
                        },
                        child: Container(
                          alignment: Alignment.center,
                          height: 40,
                          width: 230,
                          decoration: BoxDecoration(
                              color: Colors.deepOrangeAccent,
                              borderRadius: BorderRadius.circular(40)),
                          child: const Text("Detect My City",
                              style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold)),
                        ),
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      const Text("or"),
                      const SizedBox(
                        height: 10,
                      ),
                    ],
                  ),
                  Container(
                    height: 40,
                    width: MediaQuery.of(context).size.width * 0.6,
                    decoration:
                        BoxDecoration(borderRadius: BorderRadius.circular(100)),
                    alignment: Alignment.center,
                    child: TypeAheadField(
                      //hideOnLoading: false,
                      textFieldConfiguration: TextFieldConfiguration(
                        onChanged: _getAllCity,
                        onTap: () {
                          Scrollable.ensureVisible(scrollKey.currentContext,
                              duration: const Duration(milliseconds: 1300));
                        },

                        //autofocus: false,
                        controller: typeAheadController,

                        decoration: InputDecoration(
                            contentPadding:
                                const EdgeInsets.only(left: 5.0, top: 5.0),
                            hintText: widget.finalLocation == ""
                                ? locationvalue
                                : widget.finalLocation,
                            border: const OutlineInputBorder()),
                      ),
                      suggestionsCallback: (pattern) async {
                        return await _getAllCity(pattern);
                      },
                      itemBuilder: (context, suggestion) {
                        return ListTile(
                          title: Text(suggestion['name'].toString()),
                          onTap: () async {
                            SharedPreferences preferences =
                                await SharedPreferences.getInstance();
                            preferences.setString(
                                'cityName', suggestion['name'].toString());
                            preferences.setString(
                                'cityId', suggestion['id'].toString());
                            cityId = preferences.getString('cityId');
                            log("cityId--->$cityId");
                            setState(() {
                              searchProductList.clear();
                              _searchlist.clear();
                              searchController.clear();
                              locationvalue = suggestion['name'].toString();
                              selectCity = true;
                              findCity = false;
                            });
                            Navigator.pop(context);
                          },
                        );
                      },
                      onSuggestionSelected: (suggestion) {
                        typeAheadController.text = suggestion;
                        setState(() {
                          locationvalue = suggestion['name'];
                        });
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  void initState() {
    _getCountryName();
    super.initState();
    _getlocationandcategoryData();
    if (widget.data.isNotEmpty) {
      setState(() {
        productData.clear();
        _searchlist.clear();
        productData.addAll(widget.data);
        _searchlist.addAll(widget.data);
        isLoading = false;
        listEnd = true;
      });
    } else {
      _getData(getlocation, getcategoryslug);
      controller.addListener(() {
        if (controller.position.pixels == controller.position.maxScrollExtent &&
            isListing) {
          _getData(getlocation, getcategoryslug);
        }
      });
    }

    _getuserlocation();
  }

  _getuserlocation() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    usercity = prefs.getString('city');
    userstate = prefs.getString('state');
    usercountry = prefs.getString('country');
  }

  Future<void> _setlocationorcategory(String lc, String cat) async {
    setState(() {
      locationvalue = lc != null || lc != "" ? lc : "";
      categoryvalue = cat != null || cat != "" ? cat : "";
    });
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
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
        title: !isSearching
            ? widget.getcategory == null
                ? Row(
                    children: [
                      Image.asset('assets/images/logo.png', scale: 25),
                      const SizedBox(
                        width: 10,
                      ),
                      Container(
                        alignment: Alignment.center,
                        height: 40,
                        width: size.width * 0.4,
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(50),
                            border: Border.all(color: Colors.grey)),
                        child: TextFormField(
                          readOnly: true,
                          onTap: () {
                            showMyDialog();
                          },
                          decoration: InputDecoration(
                              border: InputBorder.none,
                              hintText: widget.finalLocation != ""
                                  ? findCity == true
                                      ? "   $currentCity"
                                      : selectCity == true
                                          ? "   $locationvalue"
                                          : "   $countryName"
                                  : widget.finalLocation,
                              suffixIcon: const Icon(
                                Icons.location_searching_sharp,
                                color: kContentColorLightTheme,
                              )),
                        ),
                      ),
                    ],
                  )
                : Text(widget.getcategory.toString(),
                    style: TextStyle(color: kPrimaryColor))
            : Container(
                margin: const EdgeInsets.only(top: 5.0, bottom: 5.0),
                padding:
                    const EdgeInsets.symmetric(vertical: 0, horizontal: 16),
                decoration: BoxDecoration(
                  color: Colors.indigo.shade50,
                  borderRadius: BorderRadius.all(Radius.circular(5)),
                ),
                child: Row(
                  children: <Widget>[
                    Expanded(
                      child: TextField(
                        decoration: const InputDecoration(
                          hintText: "Search Rentit4me",
                          hintStyle: TextStyle(
                              color: kPrimaryColor,
                              fontWeight: FontWeight.w500,
                              fontSize: 14),
                          border: InputBorder.none,
                        ),
                        onChanged: (String text) {
                          setState(() {
                            _searchlist = productData.where((post) {
                              var title = post['title'].toLowerCase();
                              if (title
                                  .toLowerCase()
                                  .trim()
                                  .contains(text.toLowerCase().trim())) {
                                return title.contains(text);
                              } else {
                                return title.contains(text);
                              }
                            }).toList();
                          });
                        },
                      ),
                    ),
                    InkWell(
                      onTap: () {
                        FocusScope.of(context).unfocus();
                        setState(() {
                          searchController.text = "";
                          _searchlist.clear();
                          _searchlist.addAll(productData);
                          isSearching = !isSearching;
                        });
                      },
                      child: const Icon(Icons.clear, color: kPrimaryColor),
                    )
                  ],
                )),
        centerTitle: true,
        actions: [
          InkWell(
            onTap: () async {
              // showFilter();
              await showModalBottomSheet(
                  shape: RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.vertical(top: Radius.circular(20.0))),
                  backgroundColor: Colors.white,
                  context: context,
                  isScrollControlled: true,
                  builder: (context) => StatefulBuilder(builder:
                          (BuildContext context, StateSetter setState) {
                        return SizedBox(
                            height: MediaQuery.of(context).size.height / 2,
                            child: Padding(
                                padding: const EdgeInsets.all(20),
                                child: SingleChildScrollView(
                                    child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            "Filter",
                                            style: TextStyle(
                                                fontSize: 18,
                                                fontWeight: FontWeight.bold),
                                          ),
                                          InkWell(
                                            onTap: () {
                                              Navigator.of(context).pop();
                                            },
                                            child: Icon(
                                              Icons.close,
                                              color: Colors.red[900],
                                            ),
                                          )
                                        ],
                                      ),
                                      SizedBox(
                                        height: 20,
                                      ),
                                      Padding(
                                          padding:
                                              const EdgeInsets.only(left: 8.0),
                                          child: Row(
                                            children: const [
                                              Text("SORT BY",
                                                  style: TextStyle(
                                                      color: Colors
                                                          .deepOrangeAccent,
                                                      fontWeight:
                                                          FontWeight.w700)),
                                              Text("(Price)",
                                                  style: TextStyle(
                                                      color: Colors.black,
                                                      fontWeight:
                                                          FontWeight.w700))
                                            ],
                                          )),
                                      RadioGroup<String>.builder(
                                        horizontalAlignment:
                                            MainAxisAlignment.start,
                                        groupValue: _priceGroupValue,
                                        direction: Axis.vertical,
                                        onChanged: (value) {
                                          setState(() {
                                            _priceGroupValue = value;
                                            if (value.toString() ==
                                                "Lowest To Highest") {
                                              productData.sort((a, b) =>
                                                  a['price']
                                                      .compareTo(b['price']));
                                              _searchlist.clear();
                                              _searchlist.addAll(productData);

                                              // print("......"+productData.toString());
                                              //_getfilterData(category, location, sortby, search, country, state, city, pattern, renttype)
                                              // _getfilterData(
                                              //     categoryslugname,
                                              //     locationvalue,
                                              //     "0",
                                              //     "",
                                              //     usercountry,
                                              //     userstate,
                                              //     usercity,
                                              //     searchController.text,
                                              //     _rentGroupValue);
                                            } else {
                                              productData.sort((a, b) =>
                                                  b['price']
                                                      .compareTo(a['price']));
                                              _searchlist.clear();
                                              _searchlist.addAll(productData);

                                              // _getfilterData(locationvalue, categoryvalue, "1");
                                              // _getfilterData(
                                              //     categoryslugname,
                                              //     locationvalue,
                                              //     "1",
                                              //     "",
                                              //     usercountry,
                                              //     userstate,
                                              //     usercity,
                                              //     searchController.text,
                                              //     _rentGroupValue);
                                            }
                                          });
                                        },
                                        textStyle:
                                            const TextStyle(fontSize: 16),
                                        items: const [
                                          "Lowest To Highest",
                                          "Highest To Lowest"
                                        ],
                                        itemBuilder: (item) =>
                                            RadioButtonBuilder(item,
                                                textPosition:
                                                    RadioButtonTextPosition
                                                        .right),
                                        activeColor: Colors.red,
                                      ),
                                      SizedBox(
                                        height: 20,
                                      ),
                                      Padding(
                                          padding:
                                              const EdgeInsets.only(left: 8.0),
                                          child: Row(
                                            children: const [
                                              Text("SORT BY",
                                                  style: TextStyle(
                                                      color: Colors
                                                          .deepOrangeAccent,
                                                      fontWeight:
                                                          FontWeight.w700)),
                                              Text(" (Rent type)",
                                                  style: TextStyle(
                                                      color: Colors.black,
                                                      fontWeight:
                                                          FontWeight.w700))
                                            ],
                                          )),
                                      Column(
                                        children: [
                                          Padding(
                                            padding: EdgeInsets.only(
                                                right: MediaQuery.of(context)
                                                        .size
                                                        .width *
                                                    0.31),
                                            child: RadioGroup<String>.builder(
                                              groupValue: _rentGroupValue,
                                              direction: Axis.vertical,
                                              onChanged: (value) =>
                                                  setState(() {
                                                _rentGroupValue = value;
                                                _getfilterData(
                                                    categoryslugname,
                                                    locationvalue,
                                                    "0",
                                                    "",
                                                    usercountry,
                                                    userstate,
                                                    usercity,
                                                    searchController.text,
                                                    _rentGroupValue);
                                              }),
                                              textStyle:
                                                  const TextStyle(fontSize: 16),
                                              items: const [
                                                "Hourly",
                                                "Days",
                                                "Monthly",
                                                "Yearly"
                                              ],
                                              itemBuilder: (item) =>
                                                  RadioButtonBuilder(item),
                                              activeColor: Colors.red,
                                            ),
                                          ),
                                        ],
                                      ),
                                      SizedBox(
                                        height: 20,
                                      ),
                                      // SizedBox(
                                      //   width:
                                      //       MediaQuery.of(context).size.width,
                                      //   child: ElevatedButton.icon(
                                      //       icon: Icon(Icons.clear),
                                      //       onPressed: () {
                                      //         Navigator.of(context).pop();
                                      //         if (widget.data.length > 0) {
                                      //           setState(() {
                                      //             productData.clear();
                                      //             _searchlist.clear();
                                      //             productData
                                      //                 .addAll(widget.data);
                                      //             _searchlist
                                      //                 .addAll(widget.data);
                                      //             isLoading = false;
                                      //             listEnd = true;
                                      //           });
                                      //         } else {
                                      //           _getData(getlocation,
                                      //               getcategoryslug);
                                      //         }
                                      //         // _getData(
                                      //         //     getlocation, getcategoryslug);
                                      //       },
                                      //       label: Text("Clear Filter")),
                                      // )
                                    ]))));
                      }));
            },
            child: Image.asset(
              "assets/images/filter.png",
              scale: 1.5,
              color: kPrimaryColor,
            ),
          ),
          // isSearching == true
          //     ? SizedBox()
          //     : IconButton(
          //         onPressed: () {
          //           setState(() {
          //             isSearching = !isSearching;
          //           });
          //         },
          //         icon: const Icon(
          //           Icons.search,
          //           color: kPrimaryColor,
          //           size: 30,
          //         ))
        ],
      ),
      body: ModalProgressHUD(
        inAsyncCall: isLoading,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(7.0),
              child: Container(
                  margin: const EdgeInsets.only(top: 5),
                  padding:
                      const EdgeInsets.symmetric(vertical: 0, horizontal: 16),
                  decoration: BoxDecoration(
                    color: Colors.indigo.shade50,
                    borderRadius: const BorderRadius.all(Radius.circular(5)),
                  ),
                  child: Row(
                    children: <Widget>[
                      Expanded(
                        child: TextFormField(
                          controller: searchController,
                          decoration: const InputDecoration(
                            hintText: "Search Rentit4me",
                            hintStyle: TextStyle(
                                color: Colors.grey,
                                fontWeight: FontWeight.w500,
                                fontSize: 14),
                            border: InputBorder.none,
                          ),
                        ),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          if (searchController.text.isEmpty) {
                            var snackBar = const SnackBar(
                                content: Text('Please Enter Value !!'));
                            ScaffoldMessenger.of(context)
                                .showSnackBar(snackBar);
                          } else {
                            getDataBySearching();
                          }
                        },
                        style: ButtonStyle(
                            shape: MaterialStateProperty.all(
                                RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20.0),
                        ))),
                        child: Text("Search"),
                      )
                    ],
                  )),
            ),

            // Padding(
            //   padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
            //   child: Row(
            //     mainAxisAlignment: MainAxisAlignment.spaceBetween,
            //     children: [
            //       // Container(
            //       //   height: 35,
            //       //   width: size.width * 0.32,
            //       //   decoration: BoxDecoration(
            //       //       color: Colors.indigo.shade100,
            //       //       borderRadius: BorderRadius.all(Radius.circular(8))),
            //       //   alignment: Alignment.center,
            //       //   child: Padding(
            //       //     padding: EdgeInsets.symmetric(horizontal: 8.0),
            //       //     child: DropdownButton(
            //       //       value: locationvalue,
            //       //       hint: const Text("Location", style: TextStyle(color: kPrimaryColor, fontSize: 12)),
            //       //       isExpanded: true,
            //       //       underline: Container(
            //       //         height: 0,
            //       //         color: Colors.deepPurpleAccent,
            //       //       ),
            //       //       icon: const Visibility(visible: true, child: Icon(Icons.arrow_drop_down_sharp, size: 20, color: kPrimaryColor)),
            //       //       items: location.map((items) {
            //       //         return DropdownMenuItem(
            //       //           value: items,
            //       //           child: Text(items, style: TextStyle(color: kPrimaryColor, fontSize: 12)),
            //       //         );
            //       //       }).toList(),
            //       //       // After selecting the desired option,it will
            //       //       // change button value to selected value
            //       //       onChanged: (newValue) {
            //       //         setState(() {
            //       //           locationvalue = newValue;
            //       //         });
            //       //       },
            //       //     ),
            //       //   ),
            //       // ),
            //       Container(
            //         height: 35,
            //         width: size.width * 0.38,
            //         alignment: Alignment.center,
            //         child: TypeAheadField(
            //           //hideOnLoading: false,
            //           textFieldConfiguration: TextFieldConfiguration(
            //             controller: typeAheadController,
            //             decoration: InputDecoration(
            //                 contentPadding:
            //                     const EdgeInsets.only(left: 5.0, top: 5.0),
            //                 hintText: locationvalue == null
            //                     ? "Search City"
            //                     : locationvalue,
            //                 border: const OutlineInputBorder()),
            //           ),
            //           suggestionsCallback: (pattern) async {
            //             return await _getAllCity(pattern);
            //           },
            //           itemBuilder: (context, suggestion) {
            //             return ListTile(
            //               title: Text(suggestion),
            //             );
            //           },
            //           onSuggestionSelected: (suggestion) {
            //             typeAheadController.text = suggestion;
            //             setState(() {
            //               locationvalue = suggestion;
            //             });
            //           },
            //         ),
            //       ),
            //       Container(
            //         height: 35,
            //         width: size.width * 0.32,
            //         alignment: Alignment.center,
            //         decoration: BoxDecoration(
            //             color: Colors.indigo.shade100,
            //             borderRadius:
            //                 const BorderRadius.all(Radius.circular(8))),
            //         child: Padding(
            //           padding: const EdgeInsets.symmetric(horizontal: 8.0),
            //           child: DropdownButton(
            //             hint: const Text("Category",
            //                 style:
            //                     TextStyle(color: kPrimaryColor, fontSize: 12)),
            //             value: categoryvalue,
            //             isExpanded: true,
            //             underline: Container(
            //               height: 0,
            //               color: Colors.deepPurpleAccent,
            //             ),
            //             icon: const Visibility(
            //                 visible: true,
            //                 child: Icon(Icons.arrow_drop_down_sharp,
            //                     size: 20, color: kPrimaryColor)),
            //             items: category.map((items) {
            //               return DropdownMenuItem(
            //                 value: items,
            //                 child: Text(items,
            //                     maxLines: 2,
            //                     style: const TextStyle(
            //                         color: kPrimaryColor, fontSize: 12)),
            //               );
            //             }).toList(),
            //             onChanged: (newValue) {
            //               setState(() {
            //                 categoryvalue = newValue;
            //               });
            //             },
            //           ),
            //         ),
            //       ),
            //       InkWell(
            //         onTap: () {
            //           categorylistData.forEach((element) {
            //             if (element['title'].toString() == categoryvalue) {
            //               setState(() {
            //                 categoryslugname = element['slug'].toString();
            //               });
            //             }
            //           });
            //           setState(() {
            //             skipvalue = 0;
            //             _searchlist.clear();
            //             productData.clear();
            //           });
            //           _getData(locationvalue, categoryslugname);
            //         },
            //         child: Container(
            //           height: 35,
            //           width: size.width * 0.20,
            //           alignment: Alignment.center,
            //           decoration: const BoxDecoration(
            //               color: Colors.deepOrangeAccent,
            //               borderRadius: BorderRadius.all(Radius.circular(8))),
            //           child: const Text("Let's Start!",
            //               style: TextStyle(
            //                   color: Colors.white,
            //                   fontWeight: FontWeight.w500,
            //                   fontSize: 12)),
            //         ),
            //       )
            //     ],
            //   ),
            // ),
            // // Padding(
            //   padding: const EdgeInsets.all(7.0),
            //   child: Column(
            //     crossAxisAlignment: CrossAxisAlignment.start,
            //     children: [
            //       const Padding(
            //         padding: EdgeInsets.only(left: 8.0),
            //         child: Text("FILTER",
            //             style: TextStyle(
            //                 color: Colors.deepOrangeAccent,
            //                 fontWeight: FontWeight.w700)),
            //       ),
            //       const SizedBox(height: 6.0),
            //       ],
            //   ),
            // ),
            /*Padding(
              padding: EdgeInsets.all(7.0),
              child: Container(
                  margin: EdgeInsets.only(top: 5),
                  padding:
                      const EdgeInsets.symmetric(vertical: 0, horizontal: 16),
                  decoration: BoxDecoration(
                    color: Colors.indigo.shade50,
                    borderRadius: BorderRadius.all(Radius.circular(5)),
                  ),
                  child: Row(
                    children: <Widget>[
                      Expanded(
                        child: TextField(
                          decoration: const InputDecoration(
                            hintText: "Search Rentit4me",
                            hintStyle: TextStyle(
                                color: kPrimaryColor,
                                fontWeight: FontWeight.w500,
                                fontSize: 14),
                            border: InputBorder.none,
                          ),
                          onChanged: (String text) {
                            setState(() {
                              _searchlist = productData.where((post) {
                                var title = post['title'].toLowerCase();
                                if (title
                                    .toLowerCase()
                                    .trim()
                                    .contains(text.toLowerCase().trim())) {
                                  return title.contains(text);
                                } else {
                                  return title.contains(text);
                                }
                              }).toList();
                            });
                          },
                        ),
                      ),
                      const Icon(Icons.search, color: kPrimaryColor)
                    ],
                  )),
            ),*/
       
            Expanded(
                child: isLoading
                    ? const Center(child: SizedBox())
                    : productData.isEmpty
                        ? const Center(
                            child: Text("No data found at selected location"))
                        : searchProductList.isEmpty
                            ? Padding(
                                padding: EdgeInsets.all(7.0),
                                child: SingleChildScrollView(
                                  controller: controller,
                                  child: Column(
                                    children: [
                                      GridView.builder(
                                          shrinkWrap: true,
                                          itemCount: _searchlist.length + 1,
                                          physics: ClampingScrollPhysics(),
                                          gridDelegate:
                                              const SliverGridDelegateWithFixedCrossAxisCount(
                                                  crossAxisCount: 2,
                                                  crossAxisSpacing: 4.0,
                                                  mainAxisSpacing: 4.0,
                                                  childAspectRatio: 1.0),
                                          itemBuilder: (context, index) {
                                            if (index == _searchlist.length) {
                                              return SizedBox(
                                                  height: 32,
                                                  width: double.infinity,
                                                  child: SizedBox());
                                            } else {
                                              return InkWell(
                                                onTap: () {
                                                  userId == "" || userId == null
                                                      ? showToast(
                                                          "Please Login First!!")
                                                      : Navigator.push(
                                                          context,
                                                          MaterialPageRoute(
                                                              builder: (context) =>
                                                                  ProductDetailScreen(
                                                                      productid:
                                                                          _searchlist[index]['id']
                                                                              .toString())));
                                                },
                                                child: Card(
                                                  shape: RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            4.0),
                                                  ),
                                                  child: Column(
                                                    children: [
                                                      CachedNetworkImage(
                                                        height: 80,
                                                        width: double.infinity,
                                                        errorWidget: (context,
                                                                url, error) =>
                                                            Image.asset(
                                                                'assets/images/no_image.jpg'),
                                                        fit: BoxFit.cover,
                                                        imageUrl: sliderpath +
                                                            _searchlist[index][
                                                                    'upload_base_path']
                                                                .toString() +
                                                            _searchlist[index][
                                                                    'file_name']
                                                                .toString(),
                                                      ),
                                                      const SizedBox(
                                                          height: 5.0),
                                                      Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                    .only(
                                                                left: 5.0,
                                                                right: 15.0),
                                                        child: Align(
                                                          alignment:
                                                              Alignment.topLeft,
                                                          child: Text(
                                                              _searchlist[index]
                                                                      ['title']
                                                                  .toString(),
                                                              maxLines: 2,
                                                              style: const TextStyle(
                                                                  color: Colors
                                                                      .black,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w700,
                                                                  fontSize:
                                                                      16)),
                                                        ),
                                                      ),
                                                      const SizedBox(
                                                          height: 5.0),
                                                      Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                    .only(
                                                                left: 4.0,
                                                                right: 4.0),
                                                        child: Row(
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .spaceBetween,
                                                          children: [
                                                            SizedBox(
                                                              width:
                                                                  size.width *
                                                                      0.40,
                                                              child: Text(
                                                                  "Starting from ${_searchlist[index]['currency'].toString()} ${_searchlist[index]['price'].toString()}",
                                                                  style: const TextStyle(
                                                                      color:
                                                                          kPrimaryColor,
                                                                      fontSize:
                                                                          12)),
                                                            ),
                                                            // const Icon(
                                                            //     Icons
                                                            //         .add_box_rounded,
                                                            //     color:
                                                            //         kPrimaryColor)
                                                          ],
                                                        ),
                                                      )
                                                    ],
                                                  ),
                                                ),
                                              );
                                            }
                                          }),
                                      const SizedBox(height: 20),
                                      //listEnd ? const SizedBox() : const Center(child: CircularProgressIndicator()),
                                    ],
                                  ),
                                ),
                              )
                            : isLoading == true
                                ? SizedBox(
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        CircularProgressIndicator(),
                                      ],
                                    ),
                                  )
                                : Padding(
                                    padding: EdgeInsets.all(7.0),
                                    child: SingleChildScrollView(
                                      controller: controller,
                                      child: Column(
                                        children: [
                                          searchProductList.isEmpty
                                              ? SizedBox(
                                                  child: Column(
                                                    children: [
                                                      Text("No data found!!"),
                                                    ],
                                                  ),
                                                )
                                              : GridView.builder(
                                                  shrinkWrap: true,
                                                  itemCount:
                                                      searchProductList.length,
                                                  physics:
                                                      ClampingScrollPhysics(),
                                                  gridDelegate:
                                                      const SliverGridDelegateWithFixedCrossAxisCount(
                                                          crossAxisCount: 2,
                                                          crossAxisSpacing: 4.0,
                                                          mainAxisSpacing: 4.0,
                                                          childAspectRatio:
                                                              1.0),
                                                  itemBuilder:
                                                      (context, index) {
                                                    var item =
                                                        searchProductList[
                                                            index];
                                                    if (index ==
                                                        searchProductList
                                                            .length) {
                                                      return SizedBox(
                                                          height: 32,
                                                          width:
                                                              double.infinity,
                                                          child: SizedBox());
                                                    } else {
                                                      return InkWell(
                                                        onTap: () {
                                                          Navigator.push(
                                                              context,
                                                              MaterialPageRoute(
                                                                  builder: (context) =>
                                                                      ProductDetailScreen(
                                                                          productid: item
                                                                              .id
                                                                              .toString())));
                                                        },
                                                        child: Card(
                                                          shape:
                                                              RoundedRectangleBorder(
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        4.0),
                                                          ),
                                                          child: Column(
                                                            children: [
                                                              CachedNetworkImage(
                                                                  height: 80,
                                                                  width: double
                                                                      .infinity,
                                                                  errorWidget: (context,
                                                                          url,
                                                                          error) =>
                                                                      Image.asset(
                                                                          'assets/images/no_image.jpg'),
                                                                  fit: BoxFit
                                                                      .cover,
                                                                  imageUrl: sliderpath +
                                                                      item.uploadBasePath
                                                                          .toString() +
                                                                      item.fileName),
                                                              const SizedBox(
                                                                  height: 5.0),
                                                              Padding(
                                                                padding:
                                                                    const EdgeInsets
                                                                            .only(
                                                                        left:
                                                                            5.0,
                                                                        right:
                                                                            15.0),
                                                                child: Align(
                                                                  alignment:
                                                                      Alignment
                                                                          .topLeft,
                                                                  child: Text(
                                                                      item
                                                                          .title,
                                                                      maxLines:
                                                                          2,
                                                                      style: const TextStyle(
                                                                          color: Colors
                                                                              .black,
                                                                          fontWeight: FontWeight
                                                                              .w700,
                                                                          fontSize:
                                                                              16)),
                                                                ),
                                                              ),
                                                              const SizedBox(
                                                                  height: 5.0),
                                                              Padding(
                                                                padding:
                                                                    const EdgeInsets
                                                                            .only(
                                                                        left:
                                                                            4.0,
                                                                        right:
                                                                            4.0),
                                                                child: Row(
                                                                  mainAxisAlignment:
                                                                      MainAxisAlignment
                                                                          .spaceBetween,
                                                                  children: [
                                                                    SizedBox(
                                                                      width: size
                                                                              .width *
                                                                          0.40,
                                                                      child: Text(
                                                                          "Starting from ${item.currency.toString()} ${item.price.toString()}",
                                                                          style: const TextStyle(
                                                                              color: kPrimaryColor,
                                                                              fontSize: 12)),
                                                                    ),
                                                                    // const Icon(
                                                                    //     Icons
                                                                    //         .add_box_rounded,
                                                                    //     color:
                                                                    //         kPrimaryColor)
                                                                  ],
                                                                ),
                                                              )
                                                            ],
                                                          ),
                                                        ),
                                                      );
                                                    }
                                                  }),
                                          const SizedBox(height: 20),
                                          //listEnd ? const SizedBox() : const Center(child: CircularProgressIndicator()),
                                        ],
                                      ),
                                    ),
                                  ))
          ],
        ),
      ),
    );
  }

  bool listEnd = false;
  Future _getData(String location, String category) async {
    setState(() {
      isLoading = true;
    });
    log(jsonEncode({
      "city_name": location,
      "category": category,
      "limit": "10",
      "skip": skipvalue
    }));
    final body = {
      "city_name": location,
      "category": category,
      "limit": "10",
      "skip": skipvalue
    };
    var response = await http.post(Uri.parse(BASE_URL + searchingdata),
        body: jsonEncode(body),
        headers: {
          "Accept": "application/json",
          'Content-Type': 'application/json'
        });
    log("new data ${response.body}");
    setState(() {
      isLoading = false;
    });
    if (response.statusCode == 200) {
      var data = json.decode(response.body)['Response'];
      if (data.length > 0) {
        setState(() {
          skipvalue = skipvalue + 10;
        });
      } else {
        setState(() {
          listEnd = true;
        });
      }
      setState(() {
        productData.addAll(data);
        _searchlist.addAll(data);
      });
    } else {
      throw Exception('Failed to get data due to ${response.body}');
    }
  }

  Future _getlocationandcategoryData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      isLoading = true;
    });
    final body = {
      "country": prefs.getString('country'),
      "state": prefs.getString('state'),
      "city": prefs.getString('city'),
    };
    var response = await http.post(Uri.parse(BASE_URL + homeUrl),
        body: jsonEncode(body),
        headers: {
          "Accept": "application/json",
          'Content-Type': 'application/json'
        });
    if (response.statusCode == 200) {
      setState(() {
        isLoading = false;
        location.clear();
        category.clear();
        jsonDecode(response.body)['Response']['cities'].forEach((element) {
          location.add(element['name'].toString());
        });
        categorylistData
            .addAll(jsonDecode(response.body)['Response']['categories']);
        jsonDecode(response.body)['Response']['categories'].forEach((element) {
          category.add(element['title'].toString());
        });
      });
      _setlocationorcategory(getlocation, getcategory);
    }
  }

  Future<List> _getAllCity(String pattern) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final body = {
      "country_name": prefs.getString('country'),
      "city_name": pattern
    };
    log("get city--->$body");
    var response = await http.post(Uri.parse(BASE_URL + citiesUrl),
        body: jsonEncode(body),
        headers: {
          "Accept": "application/json",
          'Content-Type': 'application/json'
        });

    List temp = jsonDecode(response.body)['Response'];

    // List temp2 = [];
    // temp.forEach((element) {
    //   temp2.add(element['name']);
    //   // temp2.add(element['id'].toString());
    // });
    return temp;
  }

  Future<void> _getfilterData(
      String category,
      String location,
      String sortby,
      String search,
      String country,
      String state,
      String city,
      String pattern,
      String renttype) async {
    productData.clear();
    _searchlist.clear();
    setState(() {
      isLoading = true;
    });
    log(jsonEncode({
      "category": category,
      "city_name": location,
      "sortby": sortby,
      "search": search,
      "country": country,
      "state": state,
      "city": city,
      "q": pattern,
      "tenure": renttype
    }));
    final body = {
      "category": category,
      "city_name": location,
      "sortby": sortby,
      "search": search,
      "country": country,
      "state": state,
      "city": city,
      "q": pattern,
      "tenure": renttype
    };
    var response = await http.post(Uri.parse(BASE_URL + filterUrl),
        body: jsonEncode(body),
        headers: {
          "Accept": "application/json",
          'Content-Type': 'application/json'
        });
    setState(() {
      isLoading = false;
    });
    log("response data ${response.body}");
    if (response.statusCode == 200) {
      var data = json.decode(response.body)['Response']['leads'];
      setState(() {
        productData.addAll(data);
        _searchlist.addAll(data);
      });
    } else {
      throw Exception('Failed to get data due to ${response.body}');
    }
  }

  Future getDataBySearching() async {
    setState(() {
      isLoading = true;
    });
    SharedPreferences prefs = await SharedPreferences.getInstance();
    int countryId = prefs.getInt('countryId');
    String cityId = prefs.getString('cityId');
    var url = "https://rentit4me.com/api/browse-ads";
    var body = cityId != ""
        ? {
            "city_id": cityId,
            "search": searchController.text,
            "country_id": countryId.toString(),
          }
        : {
            "search": searchController.text,
            "country_id": countryId.toString(),
          };

    log("body--->$body");
    var response = await APIHelper.apiPostRequest(url, body);
    var result = jsonDecode(response);
    log(result.toString());

    if (result['ErrorMessage'] == "success") {
      setState(() {
        var list = result['Response']['leads'] as List;
        searchProductList.clear();
        var listdata = list.map((e) => SearchProductModel.fromJson(e)).toList();
        searchProductList.addAll(listdata);
      });
    }
    setState(() {
      isLoading = false;
    });
  }
}
