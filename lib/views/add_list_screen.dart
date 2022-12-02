// ignore_for_file: prefer_const_constructors, use_build_context_synchronously, missing_return, deprecated_member_use

import 'dart:developer';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'dart:convert';
import 'package:path/path.dart' as p;
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:rentit4me_new/network/api.dart';
import 'package:rentit4me_new/themes/constant.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AddlistingScreen extends StatefulWidget {
  const AddlistingScreen({Key key}) : super(key: key);

  @override
  State<AddlistingScreen> createState() => _AddlistingScreenState();
}

class _AddlistingScreenState extends State<AddlistingScreen> {
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
    log("------>$locality");
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
    List<Placemark> placemarks = await placemarkFromCoordinates(
        double.parse(latitude), double.parse(longitude));
    // log("placemark==> $placemarks");
    Placemark place = placemarks[0];

    destilocality = place.locality.toString();
    log("=--->$destilocality");
  }

  Future getLocations(String locationName) async {
    var kGoogleApiKey = Apis.mapKey.toString();
    var url = Uri.tryParse(
        "https://maps.googleapis.com/maps/api/place/findplacefromtext/json?input=$locationName&inputtype=textquery&fields=formatted_address,geometry&location=20.7711857,73.729974&radius=10000&key=$kGoogleApiKey");

    http.Response res = await http.get(url);
    setState(() {
      showData = true;
      places = json.decode(res.body)['candidates'];
      placecounts = places.length;
    });
  }

  String locations = '';

  bool _loading = false;

  String mainimage = "";

  TextEditingController phoneController = TextEditingController();
  String phoneNumber = "";
  int phonemaxLength = 10;

  List<dynamic> categorieslist = [];
  List<dynamic> subcategorieslist = [];

  String initiacatlvalue;
  String initialsubcatvalue;
  bool addlocation = false;
  String categoryid;
  String subcategoryid;
  String dropdownvalue = 'Select Location';

  // List of items in our dropdown menu
  var items = ['Select Location', 'Same As Profile', 'manually'];

  bool _termcondition = false;
  String category;
  String subcategory;
  String title;
  String description;
  String securityamount;
  String mobile;
  String email;
  String hourlyprice;
  String daysprice;
  String monthlyprice;
  String yearlyprice;
  String quantity;
  String availabledate = "MM/dd/yyyy";
  String locationUser;
  String negotiablevalue = "Select";
  String hidemobilevalue = "Yes";
  bool sameAddress = true;
  List<String> negotiablelist = ['Select', 'Yes', 'No'];
  List<String> hidemobilelist = ['Yes', 'No'];

  bool _checkhour = true;
  bool _checkday = true;
  bool _checkmonth = true;
  bool _checkyear = true;
  String selectedCountry = "Select Country";
  String selectedState = "Select State";
  String selectedCity = "Select City";
  List<int> communicationprefs = [];

  int mobilehiddenvalue = 1;
  // int negotiableValue = 1;

  List additionalimage = [];

  List renttype = [
    {
      "type": "1",
      "amount": "",
      "enable": true,
    },
    {
      "type": "2",
      "amount": "",
      "enable": true,
    },
    {
      "type": "3",
      "amount": "",
      "enable": true,
    },
    {
      "type": "4",
      "amount": "",
      "enable": true,
    },
  ];

  List prices = [];

  List locationAddList = [];

  @override
  void initState() {
    super.initState();
    _getCategories();
    _getprofileData();
    _getcountryData();
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 2.0,
        title: Text("Listings ADS", style: TextStyle(color: kPrimaryColor)),
        centerTitle: true,
      ),
      body: ModalProgressHUD(
        inAsyncCall: _loading,
        color: kPrimaryColor,
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: [
                Card(
                  elevation: 4.0,
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 10, horizontal: 15),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Align(
                            alignment: Alignment.topLeft,
                            child: Text("General",
                                style: TextStyle(
                                    color: kPrimaryColor,
                                    fontSize: 21,
                                    fontWeight: FontWeight.bold))),
                        const SizedBox(height: 15),
                        const Align(
                            alignment: Alignment.topLeft,
                            child: Text("Main Image",
                                style: TextStyle(
                                    color: kPrimaryColor,
                                    fontWeight: FontWeight.bold))),
                        const SizedBox(height: 10),
                        Container(
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey, width: 1.0),
                            borderRadius:
                                BorderRadius.all(Radius.circular(8.0)),
                          ),
                          child: Row(children: [
                            Expanded(
                              child: Padding(
                                padding: const EdgeInsets.all(4.0),
                                child: Container(
                                  height: 45,
                                  width: 45,
                                  alignment: Alignment.topLeft,
                                  child: mainimage == ""
                                      ? Text(mainimage,
                                          style: TextStyle(
                                              color: Colors.black,
                                              fontWeight: FontWeight.w600))
                                      : Image.file(File(mainimage)),
                                ),
                              ),
                            ),
                            InkWell(
                              onTap: () {
                                showmainimageCaptureOptions(1);
                              },
                              child: Container(
                                width: 120,
                                height: 50,
                                alignment: Alignment.center,
                                decoration: const BoxDecoration(
                                    color: Colors.deepOrangeAccent,
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(8.0))),
                                child: const Text("Choose File",
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w400)),
                              ),
                            )
                          ]),
                        ),
                        const SizedBox(height: 4),
                        const Align(
                          alignment: Alignment.topLeft,
                          child: Text(
                            "Main image dimension should be minimum 600px X 600px in size",
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 10,
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              "Additional Image",
                              style: TextStyle(
                                  color: kPrimaryColor,
                                  fontWeight: FontWeight.bold),
                            ),
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                primary: kPrimaryColor,
                              ),
                              onPressed: () {
                                if (additionalimage.length > 3) {
                                  showToast(
                                      "Already added maximumn number of additional image");
                                } else {
                                  showmainimageCaptureOptions(2);
                                }
                              },
                              child: Text("ADD"),
                            ),
                          ],
                        ),
                        Text("Please add upto 4 images",
                            style: TextStyle(
                                color: Colors.black,
                                fontSize: 16,
                                fontWeight: FontWeight.w500)),
                        SizedBox(height: 10),
                        Container(
                            height: 140,
                            width: double.infinity,
                            decoration: BoxDecoration(
                                border:
                                    Border.all(color: Colors.grey, width: 1.0),
                                borderRadius:
                                    BorderRadius.all(Radius.circular(8.0))),
                            child: GridView.count(
                                padding: EdgeInsets.zero,
                                crossAxisCount: 3,
                                physics: ClampingScrollPhysics(),
                                children: additionalimage
                                    .map((e) => InkWell(
                                          onTap: () {
                                            setState(() {
                                              additionalimage.removeAt(
                                                  additionalimage.indexOf(e));
                                            });
                                          },
                                          child: Padding(
                                            padding: const EdgeInsets.symmetric(
                                                vertical: 4.0, horizontal: 4.0),
                                            child: Stack(
                                              alignment: Alignment.topRight,
                                              children: [
                                                Image.file(File(e),
                                                    fit: BoxFit.fill),
                                                Icon(Icons.cancel,
                                                    color: Colors.red)
                                              ],
                                            ),
                                          ),
                                        ))
                                    .toList())),
                        SizedBox(height: 10),
                        const Align(
                          alignment: Alignment.topLeft,
                          child: Text(
                            "Category",
                            style: TextStyle(
                                color: kPrimaryColor,
                                fontWeight: FontWeight.bold),
                          ),
                        ),
                        SizedBox(height: 10),
                        Container(
                            width: double.infinity,
                            decoration: BoxDecoration(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(8.0)),
                                border:
                                    Border.all(color: Colors.grey, width: 1)),
                            child: DropdownButtonHideUnderline(
                                child: Padding(
                              padding:
                                  const EdgeInsets.only(left: 5.0, right: 5.0),
                              child: DropdownButton(
                                hint: const Text("Select Category",
                                    style: TextStyle(
                                        color: Colors.grey, fontSize: 14)),
                                value: initiacatlvalue,
                                icon: const Icon(Icons.arrow_drop_down_rounded),
                                items: categorieslist.map((items) {
                                  return DropdownMenuItem(
                                    value: items['id'].toString(),
                                    child: Text(items['title']),
                                  );
                                }).toList(),
                                onChanged: (data) {
                                  setState(() {
                                    subcategorieslist.clear();
                                    initialsubcatvalue = null;
                                    initiacatlvalue = data.toString();
                                    categoryid = data.toString();
                                    _getSubCategories(data);
                                  });
                                },
                              ),
                            ))),
                        SizedBox(height: 10),
                        const Align(
                          alignment: Alignment.topLeft,
                          child: Text(
                            "Subcategory",
                            style: TextStyle(
                                color: kPrimaryColor,
                                fontWeight: FontWeight.bold),
                          ),
                        ),
                        SizedBox(height: 10),
                        Container(
                            width: double.infinity,
                            decoration: BoxDecoration(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(8.0)),
                                border:
                                    Border.all(color: Colors.grey, width: 1)),
                            child: DropdownButtonHideUnderline(
                                child: Padding(
                              padding:
                                  const EdgeInsets.only(left: 5.0, right: 5.0),
                              child: DropdownButton(
                                hint: const Text("Select Subcategory",
                                    style: TextStyle(
                                        color: Colors.grey, fontSize: 14)),
                                value: initialsubcatvalue,
                                icon: const Icon(Icons.arrow_drop_down_rounded),
                                items: subcategorieslist.map((items) {
                                  return DropdownMenuItem(
                                    value: items['id'].toString(),
                                    child: Text(items['title']),
                                  );
                                }).toList(),
                                onChanged: (data) {
                                  setState(() {
                                    initialsubcatvalue = data.toString();
                                    subcategoryid = data.toString();
                                    //_getSubCategories(data);
                                  });
                                },
                              ),
                            ))),
                        SizedBox(height: 10),
                        const Align(
                          alignment: Alignment.topLeft,
                          child: Text(
                            "Title",
                            style: TextStyle(
                                color: kPrimaryColor,
                                fontWeight: FontWeight.bold),
                          ),
                        ),
                        SizedBox(height: 10),
                        Container(
                          decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey, width: 1),
                              borderRadius:
                                  BorderRadius.all(Radius.circular(8.0))),
                          child: Padding(
                            padding: const EdgeInsets.only(
                                left: 5.0, right: 5.0, bottom: 5.0),
                            child: TextField(
                              maxLength: 30,
                              decoration: const InputDecoration(
                                //labelText: 'Enter Name',
                                border: InputBorder.none,
                              ),
                              onChanged: (value) {
                                title = value;
                              },
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),
                        const Align(
                          alignment: Alignment.topLeft,
                          child: Text(
                            "Description",
                            style: TextStyle(
                                color: kPrimaryColor,
                                fontWeight: FontWeight.bold),
                          ),
                        ),
                        const SizedBox(height: 10),
                        Container(
                          decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey, width: 1),
                              borderRadius:
                                  const BorderRadius.all(Radius.circular(8.0))),
                          child: Padding(
                            padding: const EdgeInsets.only(
                                left: 5.0, right: 5.0, bottom: 5.0),
                            child: TextField(
                              textAlign: TextAlign.start,
                              maxLength: 75,
                              decoration: const InputDecoration(
                                  border: InputBorder.none),
                              onChanged: (value) {
                                description = value;
                              },
                              maxLines: 4,
                            ),
                          ),
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        const Align(
                          alignment: Alignment.topLeft,
                          child: Text(
                            "Location *",
                            style: TextStyle(
                                color: kPrimaryColor,
                                fontWeight: FontWeight.bold),
                          ),
                        ),
                        SizedBox(height: 10),

                        Container(
                          height: 50,
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(15)),
                          child: FormField(
                            builder: (FormFieldState state) {
                              return InputDecorator(
                                decoration: InputDecoration(
                                    fillColor: Colors.white,
                                    enabledBorder: OutlineInputBorder(
                                        borderSide:
                                            BorderSide(color: Colors.grey),
                                        borderRadius:
                                            BorderRadius.circular(10)),
                                    filled: true,
                                    // labelText: "Select",
                                    isDense: true,
                                    contentPadding: EdgeInsets.all(10),
                                    border: OutlineInputBorder(
                                      borderSide:
                                          BorderSide(color: Colors.deepOrange),
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
                                        if (dropdownvalue == "manually") {
                                          sameAddress = false;
                                          if (sameAddress == false) {
                                            _getprofileData();
                                          }
                                        }
                                      });
                                    },
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                        // SizedBox(height: 10),
                        dropdownvalue == "manually"
                            ? Column(
                                children: [
                                  SizedBox(
                                    height: 20,
                                  ),
                                  Container(
                                    alignment: Alignment.center,
                                    height: 50,
                                    width:
                                        MediaQuery.of(context).size.width * 0.9,
                                    decoration: BoxDecoration(
                                        border: Border.all(color: Colors.grey),
                                        borderRadius:
                                            BorderRadius.circular(10)),
                                    child: Container(
                                      margin: const EdgeInsets.symmetric(
                                          horizontal: 10),
                                      child: TextFormField(
                                        controller: destinationPoint,
                                        autofocus: true,
                                        keyboardType: TextInputType.text,
                                        showCursor: true,
                                        onChanged: (value) {
                                          getLocations(value);
                                        },
                                        decoration: InputDecoration(
                                          suffixIcon: IconButton(
                                              onPressed: () {
                                                setState(() {
                                                  if (destinationPoint
                                                      .text.isEmpty) {
                                                    showToast(
                                                        "Please Select Location !!");
                                                  } else {
                                                    locationAddList
                                                        .add(locationUser);
                                                    log(locationAddList
                                                        .toString());
                                                    showToast(
                                                        "Added Sucessfully !!");

                                                    destinationPoint.clear();
                                                  }
                                                });
                                              },
                                              icon: Icon(Icons.add,
                                                  color: Colors.blue)),
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
                                  showData == false
                                      ? SizedBox()
                                      : SizedBox(
                                          height: MediaQuery.of(context)
                                                  .size
                                                  .height *
                                              0.3,
                                          width: MediaQuery.of(context)
                                                  .size
                                                  .width *
                                              0.9,
                                          child: ListView.builder(
                                            itemCount: placecounts,
                                            itemBuilder: (
                                              BuildContext context,
                                              int index,
                                            ) {
                                              return SizedBox(
                                                height: 50,
                                                child: ListTile(
                                                  onTap: () {
                                                    locations = places[index]
                                                        ['formatted_address'];
                                                    log("------>$places");
                                                    var lattitude =
                                                        places[index]
                                                                ['geometry']
                                                            ['location']['lat'];
                                                    var longitude =
                                                        places[index]
                                                                ['geometry']
                                                            ['location']['lng'];
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
                                                      locationUser = places[
                                                              index]
                                                          ['formatted_address'];
                                                      log("location user ---> $locationUser");

                                                      places.clear();
                                                    });
                                                    FocusScope.of(context)
                                                        .requestFocus(
                                                            FocusNode());
                                                    // _setLocation(locations, lattitude, longitude);
                                                  },
                                                  leading: Container(
                                                    padding:
                                                        const EdgeInsets.all(5),
                                                    decoration:
                                                        const BoxDecoration(
                                                      borderRadius:
                                                          BorderRadius.all(
                                                        Radius.circular(
                                                          100,
                                                        ),
                                                      ),
                                                      color: Colors.grey,
                                                    ),
                                                    child: const Icon(
                                                      Icons
                                                          .location_on_outlined,
                                                      color: Colors.black,
                                                    ),
                                                  ),
                                                  title: Padding(
                                                    padding:
                                                        const EdgeInsets.only(
                                                            left: 8.0),
                                                    child: Text(
                                                      places[index]
                                                          ['formatted_address'],
                                                      style: TextStyle(
                                                          color: Colors.black),
                                                      maxLines: 1,
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                    ),
                                                  ),
                                                ),
                                              );
                                            },
                                          ),
                                        ),
                                  SizedBox(
                                    height: 10,
                                  ),
                                  SizedBox(
                                    height: MediaQuery.of(context).size.height *
                                        0.2,
                                    child: ListView.builder(
                                        itemCount: locationAddList.length,
                                        itemBuilder: (context, index) {
                                          return Container(
                                            margin: const EdgeInsets.symmetric(
                                                horizontal: 10, vertical: 0),
                                            child: Row(
                                              children: [
                                                Text(
                                                  locationAddList[index],
                                                  style: TextStyle(
                                                      color: Colors.black,
                                                      fontSize: 16),
                                                ),
                                                IconButton(
                                                    onPressed: () {
                                                      setState(() {
                                                        locationAddList.remove(
                                                            locationAddList[
                                                                index]);
                                                        showToast(
                                                            "Removed Sucessfully !!");
                                                      });
                                                    },
                                                    icon: Icon(
                                                      Icons.close,
                                                      size: 18,
                                                      color: Colors.red,
                                                    ))
                                              ],
                                            ),
                                          );
                                        }),
                                  ),
                                ],
                              )
                            : SizedBox(
                                height: 20,
                              ),

                        // ), AbsorbPointer(
                        //       absorbing: sameAddress,
                        //       child: Column(
                        //         crossAxisAlignment: CrossAxisAlignment.start,
                        //         children: [
                        //           const Text("Country*",
                        //               style: TextStyle(
                        //                   color: kPrimaryColor,
                        //                   fontSize: 16,
                        //                   fontWeight: FontWeight.w500)),
                        //           const SizedBox(height: 8.0),
                        //           Padding(
                        //             padding:
                        //                 const EdgeInsets.fromLTRB(0, 2, 0, 2),
                        //             child: DropdownSearch(
                        //               selectedItem: "Select Country",
                        //               mode: Mode.DIALOG,
                        //               showSelectedItem: true,
                        //               autoFocusSearchBox: true,
                        //               showSearchBox: true,
                        //               showFavoriteItems: true,
                        //               favoriteItems: (val) {
                        //                 return ["India"];
                        //               },
                        //               hint: 'Select Country',
                        //               dropdownSearchDecoration:
                        //                   InputDecoration(
                        //                       enabledBorder:
                        //                           OutlineInputBorder(
                        //                               borderRadius:
                        //                                   BorderRadius
                        //                                       .circular(8),
                        //                               borderSide: BorderSide(
                        //                                   color: Colors.grey,
                        //                                   width: 1)),
                        //                       contentPadding:
                        //                           EdgeInsets.only(left: 10)),
                        //               items: countrylistData.map((e) {
                        //                 return e['name'].toString();
                        //               }).toList(),
                        //               onChanged: (value) {
                        //                 if (value != "Select Country") {
                        //                   for (var element
                        //                       in countrylistData) {
                        //                     if (element['name'].toString() ==
                        //                         value) {
                        //                       setState(() {
                        //                         initialcountryname =
                        //                             value.toString();
                        //                         initialstatename = null;
                        //                         initialcityname = null;
                        //                         country_id =
                        //                             element['id'].toString();
                        //                         _getStateData(
                        //                             element['id'].toString());
                        //                       });
                        //                     }
                        //                   }
                        //                 } else {
                        //                   showToast("Select Country");
                        //                 }
                        //               },
                        //             ),
                        //           ),
                        //           const SizedBox(height: 10),
                        //           const Text("State*",
                        //               style: TextStyle(
                        //                   color: kPrimaryColor,
                        //                   fontSize: 16,
                        //                   fontWeight: FontWeight.w500)),
                        //           const SizedBox(height: 8.0),
                        //           DropdownSearch(
                        //             selectedItem: "Select State",
                        //             mode: Mode.DIALOG,
                        //             showSelectedItem: true,
                        //             autoFocusSearchBox: true,
                        //             showSearchBox: true,
                        //             hint: 'Select State',
                        //             dropdownSearchDecoration: InputDecoration(
                        //                 enabledBorder: OutlineInputBorder(
                        //                     borderRadius:
                        //                         BorderRadius.circular(8),
                        //                     borderSide: BorderSide(
                        //                         color: Colors.grey,
                        //                         width: 1)),
                        //                 contentPadding:
                        //                     EdgeInsets.only(left: 10)),
                        //             items: statelistData.map((e) {
                        //               return e['name'].toString();
                        //             }).toList(),
                        //             onChanged: (value) {
                        //               if (value != "Select State") {
                        //                 for (var element in statelistData) {
                        //                   if (element['name'].toString() ==
                        //                       value) {
                        //                     setState(() {
                        //                       initialstatename =
                        //                           value.toString();
                        //                       initialstatename = null;
                        //                       initialcityname = null;
                        //                       state_id =
                        //                           element['id'].toString();
                        //                       _getCityData(
                        //                           element['id'].toString());
                        //                     });
                        //                   }
                        //                 }
                        //               } else {
                        //                 showToast("Select State");
                        //               }
                        //             },
                        //           ),
                        //           const SizedBox(height: 10),
                        //           const Text(
                        //             "City*",
                        //             style: TextStyle(
                        //               color: kPrimaryColor,
                        //               fontSize: 16,
                        //               fontWeight: FontWeight.w500,
                        //             ),
                        //           ),
                        //           const SizedBox(height: 8.0),
                        //           DropdownSearch(
                        //             selectedItem: "Select City",
                        //             mode: Mode.DIALOG,
                        //             showSelectedItem: true,
                        //             autoFocusSearchBox: true,
                        //             showSearchBox: true,
                        //             hint: 'Select City',
                        //             dropdownSearchDecoration: InputDecoration(
                        //                 enabledBorder: OutlineInputBorder(
                        //                     borderRadius:
                        //                         BorderRadius.circular(8),
                        //                     borderSide: BorderSide(
                        //                         color: Colors.grey,
                        //                         width: 1)),
                        //                 contentPadding:
                        //                     EdgeInsets.only(left: 10)),
                        //             items: citylistData.map((e) {
                        //               return e['name'].toString();
                        //             }).toList(),
                        //             onChanged: (value) {
                        //               if (value != "Select City") {
                        //                 for (var element in citylistData) {
                        //                   if (element['name'].toString() ==
                        //                       value) {
                        //                     setState(() {
                        //                       initialcityname =
                        //                           value.toString();
                        //                       //initialstatename = null;
                        //                       //initialcityname = null;
                        //                       city_id =
                        //                           element['id'].toString();
                        //                       //_getStateData(element['id'].toString());
                        //                     });
                        //                   }
                        //                 }
                        //               } else {
                        //                 showToast("Select City");
                        //               }
                        //             },
                        //           ),
                        //           const SizedBox(height: 10),
                        //           const Text("Address",
                        //               style: TextStyle(
                        //                   color: kPrimaryColor,
                        //                   fontSize: 16,
                        //                   fontWeight: FontWeight.w500)),
                        //           const SizedBox(height: 8.0),
                        //           Container(
                        //               decoration: BoxDecoration(
                        //                   border: Border.all(
                        //                       width: 1, color: Colors.grey),
                        //                   borderRadius: BorderRadius.all(
                        //                       Radius.circular(8))),
                        //               child: Padding(
                        //                 padding:
                        //                     const EdgeInsets.only(left: 10.0),
                        //                 child: TextField(
                        //                   controller: address,
                        //                   decoration: InputDecoration(
                        //                     border: InputBorder.none,
                        //                   ),
                        //                 ),
                        //               )),
                        //           const SizedBox(height: 10),
                        //           // const Text("Pincode",
                        //           //     style: TextStyle(
                        //           //         color: kPrimaryColor,
                        //           //         fontSize: 16,
                        //           //         fontWeight: FontWeight.w500)),
                        //           // Container(
                        //           //     decoration: BoxDecoration(
                        //           //         border: Border.all(
                        //           //             width: 1,
                        //           //             color: Colors.deepOrangeAccent),
                        //           //         borderRadius: BorderRadius.all(
                        //           //             Radius.circular(12))),
                        //           //     child: Padding(
                        //           //       padding: const EdgeInsets.only(left: 10.0),
                        //           //       child: TextField(
                        //           //         keyboardType: TextInputType.number,
                        //           //         inputFormatters: [
                        //           //           FilteringTextInputFormatter.digitsOnly
                        //           //         ],
                        //           //         controller: pincode,
                        //           //         maxLength: 6,
                        //           //         decoration: InputDecoration(
                        //           //             border: InputBorder.none,
                        //           //             counterText: ""),
                        //           //       ),
                        //           //     )),
                        //         ],
                        //       ),
                        //     )
                        //   : const SizedBox(),
                        const SizedBox(height: 10),
                        // const Align(
                        //   alignment: Alignment.topLeft,
                        //   child: Text(
                        //     "Hide Mobile Number",
                        //     style: TextStyle(
                        //         color: kPrimaryColor,
                        //         fontWeight: FontWeight.bold),
                        //   ),
                        // ),
                        // SizedBox(height: 10),
                        // Container(
                        //     width: double.infinity,
                        //     decoration: BoxDecoration(
                        //         border:
                        //             Border.all(color: Colors.grey, width: 1.0),
                        //         borderRadius:
                        //             BorderRadius.all(Radius.circular(8.0))),
                        //     child: DropdownButtonHideUnderline(
                        //         child: Padding(
                        //       padding:
                        //           const EdgeInsets.only(left: 5.0, right: 5.0),
                        //       child: DropdownButton(
                        //         value: hidemobilevalue,
                        //         icon: const Icon(Icons.arrow_drop_down_rounded),
                        //         items: hidemobilelist.map((String items) {
                        //           return DropdownMenuItem(
                        //             value: items,
                        //             child: Text(items),
                        //           );
                        //         }).toList(),
                        //         isExpanded: true,
                        //         onChanged: (value) {
                        //           setState(() {
                        //             hidemobilevalue = value;
                        //             if (hidemobilevalue == "Yes") {
                        //               mobilehiddenvalue = 1;
                        //             } else {
                        //               mobilehiddenvalue = 0;
                        //             }
                        //           });
                        //         },
                        //       ),
                        //     ))),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 20),
                Card(
                  elevation: 4.0,
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 10, horizontal: 15),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Align(
                            alignment: Alignment.topLeft,
                            child: Text("Pricing Details",
                                style: TextStyle(
                                    color: kPrimaryColor,
                                    fontSize: 21,
                                    fontWeight: FontWeight.bold))),
                        SizedBox(height: 15),
                        const Align(
                            alignment: Alignment.topLeft,
                            child: Text("Negotiable",
                                style: TextStyle(
                                    color: kPrimaryColor,
                                    fontWeight: FontWeight.bold))),
                        SizedBox(height: 10),
                        Container(
                            decoration: BoxDecoration(
                              border:
                                  Border.all(color: Colors.grey, width: 1.0),
                              borderRadius:
                                  BorderRadius.all(Radius.circular(5)),
                            ),
                            child: DropdownButtonHideUnderline(
                                child: Padding(
                              padding:
                                  const EdgeInsets.only(left: 5.0, right: 5.0),
                              child: DropdownButton(
                                value: negotiablevalue,
                                icon: const Icon(Icons.arrow_drop_down_rounded),
                                items: negotiablelist.map((String items) {
                                  return DropdownMenuItem(
                                    value: items,
                                    child: Text(items),
                                  );
                                }).toList(),
                                isExpanded: true,
                                onChanged: (value) {
                                  if (value == "Select") {
                                    showToast("Please select Yes / No");
                                  } else {
                                    setState(() {
                                      negotiablevalue = value;
                                    });
                                  }
                                },
                              ),
                            ))),
                        SizedBox(height: 10),
                        const SizedBox(height: 10),
                        const Align(
                          alignment: Alignment.topLeft,
                          child: Text(
                            "Refundable Security Deposit (INR)",
                            style: TextStyle(
                                color: kPrimaryColor,
                                fontWeight: FontWeight.bold),
                          ),
                        ),
                        SizedBox(height: 10),
                        Container(
                          decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey, width: 1),
                              borderRadius:
                                  BorderRadius.all(Radius.circular(8.0))),
                          child: Padding(
                            padding: const EdgeInsets.only(left: 5.0),
                            child: TextField(
                              keyboardType: TextInputType.number,
                              textAlign: TextAlign.start,
                              decoration:
                                  InputDecoration(border: InputBorder.none),
                              onChanged: (value) {
                                securityamount = value.toString();
                              },
                            ),
                          ),
                        ),

                        // const Align(
                        //   alignment: Alignment.topLeft,
                        //   child: Text(
                        //     "Mobile*",
                        //     style: TextStyle(
                        //         color: kPrimaryColor,
                        //         fontWeight: FontWeight.bold),
                        //   ),
                        // ),
                        // SizedBox(height: 10),
                        // Container(
                        //     width: double.infinity,
                        //     decoration: BoxDecoration(
                        //         border:
                        //             Border.all(color: Colors.grey, width: 1.0),
                        //         borderRadius:
                        //             BorderRadius.all(Radius.circular(8.0))),
                        //     child: Padding(
                        //       padding: const EdgeInsets.only(left: 5.0),
                        //       child: TextField(
                        //         keyboardType: TextInputType.phone,
                        //         maxLength: 10,
                        //         decoration: InputDecoration(
                        //             border: InputBorder.none,
                        //             hintText:
                        //                 phoneNumber == null || phoneNumber == ""
                        //                     ? "Mobile"
                        //                     : phoneNumber,
                        //             counterText: ""),
                        //         onChanged: (value) {
                        //           if (value.length <= phonemaxLength) {
                        //             phoneNumber = value;
                        //           } else {
                        //             showToast(
                        //                 "Please enter valid mobile number");
                        //           }
                        //         },
                        //       ),
                        //     )),
                        // SizedBox(height: 10),
                        // const Align(
                        //   alignment: Alignment.topLeft,
                        //   child: Text(
                        //     "Email*",
                        //     style: TextStyle(
                        //         color: kPrimaryColor,
                        //         fontWeight: FontWeight.bold),
                        //   ),
                        // ),
                        // const SizedBox(height: 8.0),
                        // Container(
                        //     width: double.infinity,
                        //     decoration: BoxDecoration(
                        //         border:
                        //             Border.all(color: Colors.grey, width: 1.0),
                        //         borderRadius:
                        //             BorderRadius.all(Radius.circular(8.0))),
                        //     child: Padding(
                        //       padding: const EdgeInsets.only(left: 5.0),
                        //       child: TextField(
                        //         keyboardType: TextInputType.emailAddress,
                        //         decoration: InputDecoration(
                        //           hintText: email == null || email == ""
                        //               ? "Email"
                        //               : email,
                        //           border: InputBorder.none,
                        //         ),
                        //         onChanged: (value) {
                        //           email = value;
                        //         },
                        //       ),
                        //     )),
                        // SizedBox(height: 10),
                        // Center(
                        //   child: TextButton.icon(
                        //       onPressed: () {
                        //         setState(() {
                        //           sameAddress = !sameAddress;
                        //         });
                        //         if (sameAddress) {
                        //           _getprofileData();
                        //         } else {
                        //           setState(() {
                        //             selectedCountry = "";
                        //             selectedState = "";
                        //             selectedCity = "";
                        //             country_id = "";
                        //             state_id = "";
                        //             city_id = "";
                        //             address.text = "";
                        //             // pincode.text = "";
                        //           });
                        //         }
                        //       },
                        //       icon: sameAddress
                        //           ? Icon(Icons.check_box_outlined)
                        //           : Icon(Icons.check_box_outline_blank),
                        //       label: Text("Same Address")),
                        // ),

                        SizedBox(height: 10),
                        const Align(
                          alignment: Alignment.topLeft,
                          child: Text(
                            "Rent Type",
                            style: TextStyle(
                                color: kPrimaryColor,
                                fontWeight: FontWeight.bold),
                          ),
                        ),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(children: [
                                  Checkbox(
                                      value: _checkhour,
                                      onChanged: (value) {
                                        setState(() {
                                          _checkhour = value;
                                          renttype[0]['enable'] = _checkhour;
                                        });
                                      }),
                                  const Text("Hourly",
                                      style: TextStyle(
                                          color: kPrimaryColor,
                                          fontWeight: FontWeight.bold)),
                                ]),
                                Row(
                                  children: [
                                    Checkbox(
                                        value: _checkday,
                                        onChanged: (value) {
                                          setState(() {
                                            _checkday = value;
                                            renttype[1]['enable'] = _checkday;
                                          });
                                        }),
                                    const Text("Daily",
                                        style: TextStyle(
                                            color: kPrimaryColor,
                                            fontWeight: FontWeight.bold))
                                  ],
                                ),
                              ],
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(children: [
                                  Checkbox(
                                      value: _checkmonth,
                                      onChanged: (value) {
                                        setState(() {
                                          _checkmonth = value;
                                          renttype[2]['enable'] = _checkmonth;
                                        });
                                      }),
                                  const Text("Monthly",
                                      style: TextStyle(
                                          color: kPrimaryColor,
                                          fontWeight: FontWeight.bold))
                                ]),
                                Row(children: [
                                  Checkbox(
                                      value: _checkyear,
                                      onChanged: (value) {
                                        setState(() {
                                          _checkyear = value;
                                          renttype[3]['enable'] = _checkyear;
                                        });
                                      }),
                                  const Text("Yearly",
                                      style: TextStyle(
                                          color: kPrimaryColor,
                                          fontWeight: FontWeight.bold))
                                ]),
                              ],
                            )
                          ],
                        ),
                        _checkhour == true ? SizedBox(height: 10) : SizedBox(),
                        _checkhour == true
                            ? const Align(
                                alignment: Alignment.topLeft,
                                child: Text(
                                  "Hourly Price(INR)*",
                                  style: TextStyle(
                                      color: kPrimaryColor,
                                      fontWeight: FontWeight.bold),
                                ),
                              )
                            : SizedBox(),
                        _checkhour == true ? SizedBox(height: 10) : SizedBox(),
                        _checkhour == true
                            ? Container(
                                decoration: BoxDecoration(
                                    border: Border.all(
                                        color: Colors.grey, width: 1),
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(8.0))),
                                child: Padding(
                                  padding: const EdgeInsets.only(left: 5.0),
                                  child: TextField(
                                    keyboardType: TextInputType.number,
                                    decoration: const InputDecoration(
                                      border: InputBorder.none,
                                    ),
                                    onChanged: (value) {
                                      if (value.toString().trim().isNotEmpty) {
                                        setState(() {
                                          renttype[0]['amount'] =
                                              value.toString();
                                          renttype[0]['enable'] = true;
                                        });
                                      }
                                    },
                                    maxLines: 1,
                                  ),
                                ),
                              )
                            : SizedBox(),
                        _checkday == true ? SizedBox(height: 10) : SizedBox(),
                        _checkday == true
                            ? const Align(
                                alignment: Alignment.topLeft,
                                child: Text(
                                  "Days Price(INR)*",
                                  style: TextStyle(
                                      color: kPrimaryColor,
                                      fontWeight: FontWeight.bold),
                                ),
                              )
                            : SizedBox(),
                        _checkday == true ? SizedBox(height: 10) : SizedBox(),
                        _checkday == true
                            ? Container(
                                decoration: BoxDecoration(
                                    border: Border.all(
                                        color: Colors.grey, width: 1),
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(8.0))),
                                child: Padding(
                                  padding: const EdgeInsets.only(left: 5.0),
                                  child: TextField(
                                    keyboardType: TextInputType.number,
                                    decoration: const InputDecoration(
                                      //labelText: 'Enter your email address',
                                      border: InputBorder.none,
                                    ),
                                    onChanged: (value) {
                                      if (value.toString().trim().isNotEmpty) {
                                        setState(() {
                                          renttype[1]['amount'] =
                                              value.toString();
                                          renttype[1]['enable'] = true;
                                        });
                                      }
                                    },
                                    maxLines: 1,
                                  ),
                                ),
                              )
                            : SizedBox(),
                        _checkmonth == true ? SizedBox(height: 10) : SizedBox(),
                        _checkmonth == true
                            ? const Align(
                                alignment: Alignment.topLeft,
                                child: Text(
                                  "Monthly Price(INR)*",
                                  style: TextStyle(
                                      color: kPrimaryColor,
                                      fontWeight: FontWeight.bold),
                                ),
                              )
                            : SizedBox(),
                        _checkmonth == true ? SizedBox(height: 10) : SizedBox(),
                        _checkmonth == true
                            ? Container(
                                decoration: BoxDecoration(
                                    border: Border.all(
                                        color: Colors.grey, width: 1),
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(8.0))),
                                child: Padding(
                                  padding: const EdgeInsets.only(left: 5.0),
                                  child: TextField(
                                    keyboardType: TextInputType.number,
                                    decoration: const InputDecoration(
                                      //labelText: 'Enter your email address',
                                      border: InputBorder.none,
                                    ),
                                    onChanged: (value) {
                                      if (value.toString().trim().isNotEmpty) {
                                        setState(() {
                                          renttype[2]['amount'] =
                                              value.toString();
                                          renttype[2]['enable'] = true;
                                        });
                                      }
                                    },
                                    maxLines: 1,
                                  ),
                                ),
                              )
                            : SizedBox(),
                        _checkyear == true ? SizedBox(height: 10) : SizedBox(),
                        _checkyear == true
                            ? const Align(
                                alignment: Alignment.topLeft,
                                child: Text(
                                  "Yearly Price(INR)*",
                                  style: TextStyle(
                                      color: kPrimaryColor,
                                      fontWeight: FontWeight.bold),
                                ),
                              )
                            : SizedBox(),
                        _checkyear == true ? SizedBox(height: 10) : SizedBox(),
                        _checkyear == true
                            ? Container(
                                decoration: BoxDecoration(
                                    border: Border.all(
                                        color: Colors.grey, width: 1),
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(8.0))),
                                child: Padding(
                                  padding: const EdgeInsets.only(left: 5.0),
                                  child: TextField(
                                    keyboardType: TextInputType.number,
                                    decoration: const InputDecoration(
                                      //labelText: 'Enter your email address',
                                      border: InputBorder.none,
                                    ),
                                    onChanged: (value) {
                                      if (value.toString().trim().isNotEmpty) {
                                        setState(() {
                                          renttype[3]['amount'] =
                                              value.toString();
                                          renttype[3]['enable'] = true;
                                        });
                                      }
                                    },
                                    maxLines: 1,
                                  ),
                                ),
                              )
                            : SizedBox(),
                        SizedBox(height: 10),
                        const Align(
                          alignment: Alignment.topLeft,
                          child: Text(
                            "Quantity*",
                            style: TextStyle(
                                color: kPrimaryColor,
                                fontWeight: FontWeight.bold),
                          ),
                        ),
                        SizedBox(height: 10),
                        Container(
                          decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey, width: 1),
                              borderRadius:
                                  BorderRadius.all(Radius.circular(8.0))),
                          child: Padding(
                            padding: const EdgeInsets.only(left: 5.0),
                            child: TextField(
                              keyboardType: TextInputType.number,
                              decoration: const InputDecoration(
                                //labelText: 'Enter your email address',
                                border: InputBorder.none,
                              ),
                              onChanged: (value) {
                                quantity = value.toString();
                              },
                              maxLines: 1,
                            ),
                          ),
                        ),
                        SizedBox(height: 10),
                        // const Align(
                        //   alignment: Alignment.topLeft,
                        //   child: Text(
                        //     "Communication Preferences*",
                        //     style: TextStyle(
                        //         color: kPrimaryColor,
                        //         fontWeight: FontWeight.bold),
                        //   ),
                        // ),
                        // SizedBox(height: 10),
                        // Container(
                        //   width: size.width * 0.60,
                        //   child: Row(
                        //       mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        //       children: [
                        //         Checkbox(
                        //             value: _email,
                        //             onChanged: (value) {
                        //               if (value) {
                        //                 setState(() {
                        //                   _email = value;
                        //                   communicationprefs.add(1);
                        //                 });
                        //               } else {
                        //                 setState(() {
                        //                   _email = value;
                        //                   communicationprefs.removeWhere(
                        //                       (element) =>
                        //                           element.toString() == "1");
                        //                 });
                        //               }
                        //             }),
                        //         const Text("Email",
                        //             style: TextStyle(
                        //                 color: kPrimaryColor,
                        //                 fontWeight: FontWeight.bold)),
                        //         SizedBox(width: 8.0),
                        //         Checkbox(
                        //             value: _sms,
                        //             onChanged: (value) {
                        //               if (value) {
                        //                 setState(() {
                        //                   _sms = value;
                        //                   communicationprefs.add(2);
                        //                 });
                        //               } else {
                        //                 setState(() {
                        //                   _sms = value;
                        //                   communicationprefs.removeWhere(
                        //                       (element) =>
                        //                           element.toString() == "2");
                        //                 });
                        //               }
                        //             }),
                        //         const Text("Sms",
                        //             style: TextStyle(
                        //                 color: kPrimaryColor,
                        //                 fontWeight: FontWeight.bold)),
                        //       ]),
                        // ),

                        SizedBox(height: 10),
                        const Align(
                          alignment: Alignment.topLeft,
                          child: Text(
                            "Available From*",
                            style: TextStyle(
                                color: kPrimaryColor,
                                fontWeight: FontWeight.bold),
                          ),
                        ),
                        SizedBox(height: 10),
                        Container(
                          decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey, width: 1),
                              borderRadius:
                                  BorderRadius.all(Radius.circular(8.0))),
                          child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.only(left: 5.0),
                                  child: Text(availabledate,
                                      style: const TextStyle(
                                          color: Colors.black,
                                          fontWeight: FontWeight.w500)),
                                ),
                                IconButton(
                                    onPressed: () {
                                      _selectStartDate(context);
                                    },
                                    icon: const Icon(Icons.calendar_today,
                                        color: Colors.black))
                              ]),
                        ),
                        SizedBox(height: 10),
                        Align(
                            alignment: Alignment.topLeft,
                            child: Row(
                              children: [
                                const Text("Term and Condition*",
                                    style: TextStyle(
                                        color: kPrimaryColor,
                                        fontWeight: FontWeight.bold)),
                                SizedBox(width: 4.0),
                                Checkbox(
                                    value: _termcondition,
                                    onChanged: (value) {
                                      setState(() {
                                        _termcondition = value;
                                      });
                                    })
                              ],
                            )),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 5),
                InkWell(
                  onTap: () {
                    if (mainimage.isEmpty) {
                      showToast("Please choose main image");
                      return;
                    } else if (additionalimage.isEmpty) {
                      showToast("Please choose additional image");
                      return;
                    } else if (categoryid == null || categoryid == "") {
                      showToast("Please select category");
                      return;
                    } else if (title == null || title == "") {
                      showToast("Please enter your title");
                      return;
                    } else if (description == null || description == "") {
                      showToast("Please enter your description");
                      return;
                    } else if (securityamount == null || securityamount == "") {
                      showToast("Please enter security amount");
                      return;
                    } else if (phoneNumber == null || phoneNumber == "") {
                      showToast("Please enter mobile number");
                      return;
                    } else if (email == null || email == "") {
                      showToast("Please enter email address");
                      return;
                    } else if (quantity == null || quantity == "") {
                      showToast("Please enter quantity");
                      return;
                    } else if (availabledate == null ||
                        availabledate == "" ||
                        availabledate == "MM/dd/yyyy") {
                      showToast("Please select available date");
                      return;
                    } else if (_termcondition == false) {
                      showToast("Please check term & condition");
                      return;
                    } else if (!sameAddress && country_id.isEmpty) {
                      showToast("Please select country");
                    } else if (!sameAddress && state_id.isEmpty) {
                      showToast("Please select state");
                    } else if (!sameAddress && city_id.isEmpty) {
                      showToast("Please select city");
                    } else if (!sameAddress &&
                        address.text.toString().isEmpty) {
                      showToast("Please entere address");
                    } else if (dropdownvalue == "Select Location") {
                      showToast("Please Choose Location");
                    } else {
                      submitpostaddData(additionalimage);
                    }
                  },
                  child: Card(
                    elevation: 8.0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    child: Container(
                      height: 45,
                      width: size.width * 0.90,
                      alignment: Alignment.center,
                      decoration: const BoxDecoration(
                          color: Colors.deepOrangeAccent,
                          borderRadius: BorderRadius.all(Radius.circular(8.0))),
                      child: const Text("Post",
                          style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w500)),
                    ),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _getCategories() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    setState(() {
      _loading = true;
    });
    var response = await http.get(Uri.parse(BASE_URL + categoryUrl), headers: {
      "Accept": "application/json",
      'Content-Type': 'application/json',
      'Authorization': 'Bearer ${prefs.getString("token")}',
    });
    setState(() {
      _loading = false;
    });
    if (jsonDecode(response.body)['ErrorCode'] == 0) {
      setState(() {
        categorieslist.addAll(jsonDecode(response.body)['Response']);
      });
    } else {
      // .toString());
    }
  }

  Future<void> _getSubCategories(String id) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _loading = true;
    });
    var response = await http.post(Uri.parse(BASE_URL + subcategoryUrl),
        body: jsonEncode({"category_id": id}),
        headers: {
          "Accept": "application/json",
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${prefs.getString("token")}',
        });
    setState(() {
      _loading = false;
    });
    if (jsonDecode(response.body)['ErrorCode'] == 0) {
      if (jsonDecode(response.body)['Response']['subcategories'].length > 0) {
        setState(() {
          subcategorieslist
              .addAll(jsonDecode(response.body)['Response']['subcategories']);
        });
      } else {
        showToast("No Subcategory available");
      }
    }
  }

  Future<Map> submitpostaddData(List files) async {
    log(categoryid);
    log("--->$subcategoryid");
    log(description);
    log(title);
    log(phoneNumber);
    log(email);
    // print(negotiableValue.toString());
    log(quantity);
    log(securityamount);
    log(availabledate);
    log(mobilehiddenvalue.toString());
    log(communicationprefs.toString());

    SharedPreferences prefs = await SharedPreferences.getInstance();
    List temp = [];
    for (var element in renttype) {
      if (element['enable']) {
        temp.add(element);
      }
    }
    if (temp.isEmpty) {
      showToast("Please select atleast one rent type");
    } else {
      setState(() {
        _loading = true;
      });

      print("--->$locationAddList");
      var requestMulti =
          http.MultipartRequest('POST', Uri.parse(BASE_URL + postadstore));

      requestMulti.headers.addAll({
        'Authorization': 'Bearer ${prefs.getString("token")}',
      });

      requestMulti.fields["id"] = prefs.getString('userid');
      requestMulti.fields["category"] = categoryid;

      requestMulti.fields["sub_category"] = subcategoryid == null
          ? ""
          : subcategoryid == ""
              ? ""
              : subcategoryid == "null"
                  ? ""
                  : subcategoryid.toString();
      requestMulti.fields["title"] = title;
      requestMulti.fields["description"] = description;
      requestMulti.fields["negotiate"] =
          negotiablevalue.toString() == "Yes" ? "1" : "0";
      requestMulti.fields["mobile"] = phoneNumber;
      requestMulti.fields["email"] = email;
      requestMulti.fields["mobile_hidden"] = mobilehiddenvalue.toString();
      requestMulti.fields["quantity"] = quantity;
      requestMulti.fields["start_date"] = availabledate;
      // requestMulti.fields["com_prefs"] = communicationprefs.join(",");
      requestMulti.fields["security"] = securityamount;
      requestMulti.fields["price[1]"] = renttype[0]['amount'].toString();
      requestMulti.fields["rent_type[1]"] = renttype[0]['type'].toString();
      requestMulti.fields["price[2]"] = renttype[1]['amount'].toString();
      requestMulti.fields["rent_type[2]"] = renttype[1]['type'].toString();
      requestMulti.fields["price[3]"] = renttype[2]['amount'].toString();
      requestMulti.fields["rent_type[3]"] = renttype[2]['type'].toString();
      requestMulti.fields["price[4]"] = renttype[3]['amount'].toString();
      requestMulti.fields["rent_type[4]"] = renttype[3]['type'].toString();
      requestMulti.fields["address_type"] =
          dropdownvalue.toString() == "manually"
              ? dropdownvalue
              : "same_as_profile";
      requestMulti.fields["location_data[0]"] =
          locationAddList.isEmpty ? "" : locationAddList.toString();

      // if (sameAddress) {
      //   requestMulti.fields["address_type"] = "same_as_profile";
      // } else {
      //   requestMulti.fields["address_type"] = dropdownvalue == "manually"
      //       ? "manually"
      //       : dropdownvalue == "All Cities"
      //           ? "all_cities"
      //           : dropdownvalue == "Same As Profile"
      //               ? "same_as_profile"
      //               : "";
      //   requestMulti.fields["country"] = country_id.toString();
      //   requestMulti.fields["state"] = state_id.toString();
      //   requestMulti.fields["city"] = city_id.toString();
      //   requestMulti.fields["address"] = address.text.toString();
      // }

      requestMulti.files.add(http.MultipartFile("main_image",
          File(mainimage).openRead(), File(mainimage).lengthSync(),
          filename: "image${p.extension(mainimage.toString())}"));

      log("main Image----->$mainimage");

      List<http.MultipartFile> newList = [];

      if (files.isNotEmpty) {
        for (var i = 0; i < files.length; i++) {
          File imageFile = File(files[i].toString());
          var stream = http.ByteStream(imageFile.openRead());
          var length = await imageFile.length();
          var multipartFile = http.MultipartFile("images[]", stream, length,
              filename: "image${p.extension(files[i].toString())}");
          newList.add(multipartFile);
        }
      } else {
        requestMulti.fields['images[]'] = "";
      }

      requestMulti.files.addAll(newList);

      var response = await requestMulti.send();
      var respStr = await response.stream.bytesToString();
      setState(() {
        _loading = false;
      });
      log("add list response");
      log(respStr.toString());
      if (jsonDecode(respStr)['ErrorCode'] == 0) {
        showToast(jsonDecode(respStr)['ErrorMessage'].toString());
        _getCategories();
        _getprofileData();
        // mainimage = "";
        // newList.clear();
        // categorieslist.clear();
        // subcategorieslist.clear();
        // title.isEmpty;
        // description.isEmpty;
        // locationAddList.isEmpty;
        // negotiablelist.clear();
        // securityamount.isEmpty;
        // hourlyprice.isEmpty;
        // monthlyprice.isEmpty;
        // yearlyprice.isEmpty;
        // quantity.isEmpty;
        // availabledate.isEmpty;
        // _termcondition = false;

        Navigator.push(context,
            MaterialPageRoute(builder: (context) => AddlistingScreen()));
      } else {
        showToast(jsonDecode(respStr)['ErrorMessage'].toString());
      }
      log(requestMulti.fields.toString());
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
        availabledate = DateFormat('MM/dd/yyyy').format(picked);
      });
    }
  }

  Future<void> showmainimageCaptureOptions(int datafor) async {
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
                              imageQuality: 40,
                              maxHeight: 600,
                              maxWidth: 600,
                            );
                            if (result != null) {
                              switch (datafor) {
                                case 1:
                                  setState(() {
                                    mainimage = result.path.toString();
                                  });
                                  break;

                                case 2:
                                  setState(() {
                                    additionalimage.add(result.path.toString());
                                  });
                                  break;
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
                              maxHeight: 600,
                              maxWidth: 600,
                            );
                            if (result != null) {
                              switch (datafor) {
                                case 1:
                                  setState(() {
                                    mainimage = result.path.toString();
                                  });
                                  break;

                                case 2:
                                  setState(() {
                                    additionalimage.add(result.path.toString());
                                  });
                                  break;
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

  String userLocation;
  String country;
  String state;
  String city;

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
    setState(() {
      _loading = false;
    });
    print(response.body);
    if (response.statusCode == 200) {
      var data = json.decode(response.body)['Response'];
      setState(() {
        phoneNumber = data['User']['mobile'].toString();
        email = data['User']['email'].toString();
        selectedCountry = data['User']['country_name'].toString();
        selectedState = data['User']['state_name'].toString();
        selectedCity = data['User']['city_name'].toString();
        country_id = data['User']['country'].toString();
        state_id = data['User']['state'].toString();
        city_id = data['User']['city'].toString();
        address.text = data['User']['address'].toString();
        country = data['User']['country'].toString();
        state = data['User']['state'].toString();
        city = data['User']['city'].toString();

        userLocation = "$country,$state,$city";

        // pincode.text = data['User']['pincode'].toString();
      });
    } else {
      setState(() {
        _loading = false;
      });
      throw Exception('Failed to get data due to ${response.body}');
    }
  }

  List<dynamic> countrylistData = [];
  String initialcountryname;
  String country_id;

  List<dynamic> statelistData = [];
  String initialstatename;
  String state_id;

  List<dynamic> citylistData = [];
  String initialcityname;
  String city_id;
  TextEditingController address = TextEditingController();

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

  Future _getStateData(String id) async {
    setState(() {
      statelistData.clear();
      _loading = true;
    });
    final body = {
      "id": int.parse(id),
    };
    var response = await http.post(Uri.parse(BASE_URL + getState),
        body: jsonEncode(body),
        headers: {
          "Accept": "application/json",
          'Content-Type': 'application/json'
        });
    if (response.statusCode == 200) {
      Iterable list = json.decode(response.body)['Response']['states'];
      setState(() {
        _loading = false;
        statelistData.addAll(list);
      });
    } else {
      setState(() {
        _loading = false;
      });
      throw Exception('Failed to get data due to ${response.body}');
    }
  }

  Future _getCityData(String id) async {
    setState(() {
      citylistData.clear();
      _loading = true;
    });
    final body = {
      "id": int.parse(id),
    };
    var response = await http.post(Uri.parse(BASE_URL + getCity),
        body: jsonEncode(body),
        headers: {
          "Accept": "application/json",
          'Content-Type': 'application/json'
        });
    //print(response.body);
    if (response.statusCode == 200) {
      Iterable list = json.decode(response.body)['Response']['cities'];
      setState(() {
        _loading = false;
        citylistData.addAll(list);
      });
    } else {
      setState(() {
        _loading = false;
      });
      throw Exception('Failed to get data due to ${response.body}');
    }
  }
}
