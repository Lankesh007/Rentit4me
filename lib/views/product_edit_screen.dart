// ignore_for_file: non_constant_identifier_names, use_build_context_synchronously

import 'dart:developer';
import 'dart:io';

import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:html/parser.dart';
import 'package:path/path.dart' as p;
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:rentit4me_new/models/cities_moidel.dart';
import 'package:rentit4me_new/themes/constant.dart';
import 'package:rentit4me_new/network/api.dart';
import 'package:shared_preferences/shared_preferences.dart';

// ignore: must_be_immutable
class ProductEditScreen extends StatefulWidget {
  String productid;
  ProductEditScreen({Key key, this.productid}) : super(key: key);

  @override
  // ignore: no_logic_in_create_state
  State<ProductEditScreen> createState() => _ProductEditScreenState(productid);
}

class _ProductEditScreenState extends State<ProductEditScreen> {
  List<CitiesModel> citiesList = [];
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

  bool changeLocation = false;

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

  bool hourlyRent = false;
  bool monthlyRent = false;
  bool dailyRent = false;
  bool yearlyRent = false;

  bool addlocation = false;
  String categoryid;
  String subcategoryid;
  String dropdownvalue = 'Select Location';

  // List of items in our dropdown menu
  var items = ['Select Location', 'Same As Profile', 'manually'];
  String locations = '';

  String productid;
  _ProductEditScreenState(this.productid);

  bool changeCategory = false;
  bool checkData = false;
  bool _loading = false;

  bool _sms = false;
  bool _email = false;

  int mobilehiddenvalue = 1;
  // int negotiableValue = 1;

  int phonemaxLength = 10;

  bool _checkstock = false;

  List<int> communicationprefs = [];

  String mainimage = "Main Image (Minimum Aspect Ration - 600px X 600px)*";
  TextEditingController productname = TextEditingController();
  String productimage;
  String boostpack;
  TextEditingController description = TextEditingController();
  String productprice;
  TextEditingController mobile = TextEditingController();
  TextEditingController email = TextEditingController();
  final quantityController = TextEditingController();

  String categoryhint = "Select Category";
  String subcategoryhint = "Select Subcategory";

  List additionalimage = [];
  final List<dynamic> _categorieslist = [];
  final List<dynamic> _subcategorieslist = [];

  String negotiablevalue = "Select";
  String hidemobilevalue = "Yes";

  List<String> Negotiablelist = ['Select', 'Yes', 'No'];
  List<String> hidemobilelist = ['Yes', 'No'];

  GlobalKey<FormState> form = GlobalKey<FormState>();
  bool _checkhour = false;
  bool _checkday = false;
  bool _checkmonth = false;
  bool _checkyear = false;

  String selectedCountry = "Select Country";
  String selectedState = "Select State";
  String selectedCity = "Select City";
  bool _termcondition = false;

  int statusvalue = 6;
  TextEditingController hourlyprice = TextEditingController();
  TextEditingController daysprice = TextEditingController();
  TextEditingController monthprice = TextEditingController();
  TextEditingController yearprice = TextEditingController();

  String initiacatlvalue;
  String initialsubcatvalue;

  TextEditingController securityamount = TextEditingController();

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
  List locationAddList = [];

  bool sameAddress = false;

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
          'Content-Type': 'application/json'
        });
    setState(() {
      _loading = false;
    });
    if (response.statusCode == 200) {
      var data = json.decode(response.body)['Response'];
      setState(() {
        selectedCountry = data['User']['country_name'].toString();
        selectedState = data['User']['state_name'].toString();
        selectedCity = data['User']['city_name'].toString();
        country_id = data['User']['country'].toString();
        state_id = data['User']['state'].toString();
        city_id = data['User']['city'].toString();
        address.text = data['User']['address'].toString();
        // pincode.text = data['User']['pincode'].toString();
      });
    } else {
      setState(() {
        _loading = false;
      });
      throw Exception('Failed to get data due to ${response.body}');
    }
  }

  String getLocation;

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

  String locationUser;

  @override
  void initState() {
    super.initState();
    print("............productid$productid");
    _getpreproductedit(productid);
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
        leading: InkWell(
            onTap: () {
              Navigator.of(context).pop();
            },
            child: const Icon(
              Icons.arrow_back,
              color: kPrimaryColor,
            )),
        title: Text("Edit Listing Ad", style: TextStyle(color: kPrimaryColor)),
        centerTitle: true,
      ),
      body: ModalProgressHUD(
        inAsyncCall: _loading,
        color: kPrimaryColor,
        child: Form(
          key: form,
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
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
                              border:
                                  Border.all(color: Colors.grey, width: 1.0),
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
                                    child: mainimage ==
                                            "Main Image (Minimum Aspect Ration - 600px X 600px)*"
                                        ? Text(mainimage,
                                            style: TextStyle(
                                                color: Colors.black,
                                                fontSize: 14))
                                        : mainimage.contains('http')
                                            ? Image.network(mainimage)
                                            : Image.file(File(mainimage)),
                                  ),
                                ),
                              ),
                              InkWell(
                                onTap: () {
                                  showmainimageCaptureOptions(1, 0);
                                },
                                child: Container(
                                  width: 120,
                                  height: 50,
                                  alignment: Alignment.center,
                                  decoration: const BoxDecoration(
                                      color: Colors.deepOrangeAccent,
                                      borderRadius: BorderRadius.all(
                                          Radius.circular(8.0))),
                                  child: const Text("Choose File",
                                      style: TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.w400)),
                                ),
                              )
                            ]),
                          ),
                          SizedBox(height: 10),
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
                                      primary: kPrimaryColor),
                                  onPressed: () {
                                    if (additionalimage.length > 3) {
                                      showToast(
                                          "Already added maximumn number of additional image");
                                    } else {
                                      showmainimageCaptureOptions(2, 0);
                                    }
                                  },
                                  child: Text("ADD"))
                            ],
                          ),
                          const SizedBox(height: 10),
                          const Text("You can add upto 4 images",
                              style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500)),
                          const SizedBox(height: 10),
                          Container(
                              height: 140,
                              width: double.infinity,
                              decoration: BoxDecoration(
                                  border: Border.all(
                                      color: Colors.grey, width: 1.0),
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(8.0))),
                              child: GridView.count(
                                  padding: EdgeInsets.zero,
                                  crossAxisCount: 3,
                                  physics: ClampingScrollPhysics(),
                                  children: additionalimage
                                      .map((e) => Padding(
                                            padding: const EdgeInsets.symmetric(
                                                vertical: 4.0, horizontal: 4.0),
                                            child: e['image']
                                                    .toString()
                                                    .contains('http')
                                                ? Stack(
                                                    alignment:
                                                        Alignment.topRight,
                                                    children: [
                                                      Image.network(e['image']),
                                                      InkWell(
                                                        onTap: () {
                                                          setState(() {
                                                            additionalimage
                                                                .removeAt(
                                                                    additionalimage
                                                                        .indexOf(
                                                                            e));
                                                          });
                                                        },
                                                        child: Icon(Icons.clear,
                                                            color: Colors.red),
                                                      )
                                                    ],
                                                  )
                                                : Stack(
                                                    alignment:
                                                        Alignment.topRight,
                                                    children: [
                                                      Image.file(
                                                          File(e['image']),
                                                          fit: BoxFit.fill),
                                                      InkWell(
                                                        onTap: () {
                                                          setState(() {
                                                            additionalimage
                                                                .removeAt(
                                                                    additionalimage
                                                                        .indexOf(
                                                                            e));
                                                          });
                                                        },
                                                        child: Icon(Icons.clear,
                                                            color: Colors.red),
                                                      )
                                                    ],
                                                  ),
                                            //const Icon(Icons.cancel, color: Colors.red)
                                          ))
                                      .toList())),
                          SizedBox(height: 10),
                          Align(
                            alignment: Alignment.topLeft,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  "Category",
                                  style: TextStyle(
                                      color: kPrimaryColor,
                                      fontWeight: FontWeight.bold),
                                ),
                                InkWell(
                                  onTap: () {
                                    setState(() {
                                      changeCategory = !changeCategory;
                                    });
                                  },
                                  child: Text(
                                    "Change",
                                    style: TextStyle(
                                        color: kPrimaryColor,
                                        fontWeight: FontWeight.bold),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(height: 10),
                          changeCategory != true
                              ? Container(
                                  alignment: Alignment.centerLeft,
                                  width: double.infinity,
                                  height: 50,
                                  decoration: BoxDecoration(
                                      border: Border.all(color: Colors.grey),
                                      borderRadius: BorderRadius.circular(10)),
                                  child: Container(
                                      margin: const EdgeInsets.symmetric(
                                          horizontal: 10),
                                      child: Text(categoryTitle,
                                          style: TextStyle(
                                            fontSize: 15,
                                          ))))
                              : Column(
                                  children: [
                                    Container(
                                        width: double.infinity,
                                        decoration: BoxDecoration(
                                            borderRadius: BorderRadius.all(
                                                Radius.circular(8.0)),
                                            border: Border.all(
                                                color: Colors.grey, width: 1)),
                                        child: DropdownButtonHideUnderline(
                                            child: Padding(
                                          padding: const EdgeInsets.only(
                                              left: 5.0, right: 5.0),
                                          child: DropdownButton(
                                            // onTap: (){
                                            //   _getCategories();
                                            // },
                                            value: initiacatlvalue,
                                            // value: "askld",
                                            icon: const Icon(
                                                Icons.arrow_drop_down_rounded),
                                            items: _categorieslist.map((items) {
                                              var id = items['id'];
                                              return DropdownMenuItem(
                                                value: items['id'].toString(),
                                                child: Text(items['title']),
                                              );
                                            }).toList(),
                                            onChanged: (data) {
                                              setState(() {
                                                _subcategorieslist.clear();
                                                initialsubcatvalue = null;
                                                initiacatlvalue =
                                                    data.toString();
                                                categoryid = data.toString();
                                                _getSubCategories(data);
                                              });
                                            },
                                          ),
                                        ))),
                                  ],
                                ),
                          SizedBox(height: 10),
                          Align(
                            alignment: Alignment.topLeft,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  "Subcategory",
                                  style: TextStyle(
                                      color: kPrimaryColor,
                                      fontWeight: FontWeight.bold),
                                ),
                                // InkWell(
                                //   onTap: () {
                                //     setState(() {
                                //       changeSubCategory= !changeSubCategory;
                                //     });
                                //   },
                                //   child: Text(
                                //     "Change",
                                //     style: TextStyle(
                                //         color: kPrimaryColor,
                                //         fontWeight: FontWeight.bold),
                                //   ),
                                // ),
                              ],
                            ),
                          ),
                          SizedBox(height: 10),
                          changeCategory == true
                              ? Container(
                                  width: double.infinity,
                                  decoration: BoxDecoration(
                                      borderRadius: BorderRadius.all(
                                          Radius.circular(8.0)),
                                      border: Border.all(
                                          color: Colors.grey, width: 1)),
                                  child: DropdownButtonHideUnderline(
                                      child: Padding(
                                    padding: const EdgeInsets.only(
                                        left: 5.0, right: 5.0),
                                    child: DropdownButton(
                                      value: initialsubcatvalue,
                                      icon: const Icon(
                                          Icons.arrow_drop_down_rounded),
                                      items: _subcategorieslist.map((items) {
                                        return DropdownMenuItem(
                                          value: items['id'].toString(),
                                          child: Text(items['title']),
                                        );
                                      }).toList(),
                                      onChanged: (data) {
                                        setState(() {
                                          initialsubcatvalue = data.toString();
                                          initialsubcatvalue = null;
                                          initialsubcatvalue = data.toString();
                                          subcategoryid = data.toString();
                                          _getSubCategories(data);
                                        });
                                      },
                                    ),
                                  )))
                              : Container(
                                  alignment: Alignment.centerLeft,
                                  width: double.infinity,
                                  height: 50,
                                  decoration: BoxDecoration(
                                      border: Border.all(color: Colors.grey),
                                      borderRadius: BorderRadius.circular(10)),
                                  child: Container(
                                      margin:
                                          EdgeInsets.symmetric(horizontal: 10),
                                      child: Text(
                                          subCategoryTitle.toString() == null ||
                                                  subCategoryTitle.toString() ==
                                                      "" ||
                                                  subCategoryTitle.toString() ==
                                                      "null"
                                              ? "No Subcategory"
                                              : subCategoryTitle.toString(),
                                          style: TextStyle(
                                            fontSize: 15,
                                          )))),
                          const SizedBox(height: 10),
                          const Align(
                            alignment: Alignment.topLeft,
                            child: Text(
                              "Title",
                              style: TextStyle(
                                  color: kPrimaryColor,
                                  fontWeight: FontWeight.bold),
                            ),
                          ),
                          const SizedBox(height: 10),
                          Container(
                            decoration: BoxDecoration(
                                border:
                                    Border.all(color: Colors.grey, width: 1),
                                borderRadius:
                                    BorderRadius.all(Radius.circular(8.0))),
                            child: Padding(
                              padding: const EdgeInsets.only(left: 5.0),
                              child: TextFormField(
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Required Field';
                                  }
                                  return null;
                                },
                                controller: productname,
                                decoration: InputDecoration(
                                  border: InputBorder.none,
                                ),
                              ),
                            ),
                          ),
                          SizedBox(height: 10),
                          const Align(
                            alignment: Alignment.topLeft,
                            child: Text(
                              "Description",
                              style: TextStyle(
                                  color: kPrimaryColor,
                                  fontWeight: FontWeight.bold),
                            ),
                          ),
                          SizedBox(height: 10),
                          Container(
                            decoration: BoxDecoration(
                                border:
                                    Border.all(color: Colors.grey, width: 1),
                                borderRadius:
                                    BorderRadius.all(Radius.circular(8.0))),
                            child: Padding(
                              padding: const EdgeInsets.only(left: 5.0),
                              child: TextField(
                                controller: description,
                                textAlign: TextAlign.start,
                                decoration: InputDecoration(
                                  border: InputBorder.none,
                                ),
                                maxLines: 4,
                              ),
                            ),
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                          Align(
                            alignment: Alignment.topLeft,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  "Location *",
                                  style: TextStyle(
                                      color: kPrimaryColor,
                                      fontWeight: FontWeight.bold),
                                ),
                                InkWell(
                                  onTap: () {
                                    setState(() {
                                      changeLocation = !changeLocation;
                                    });
                                  },
                                  child: Text(
                                    "Change",
                                    style: TextStyle(
                                        color: kPrimaryColor,
                                        fontWeight: FontWeight.bold),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(height: 10),

                          changeLocation == false
                              ? Container(
                                  alignment: Alignment.centerLeft,
                                  width: double.infinity,
                                  height: 50,
                                  decoration: BoxDecoration(
                                      border: Border.all(color: Colors.grey),
                                      borderRadius: BorderRadius.circular(10)),
                                  child: Container(
                                      margin: const EdgeInsets.symmetric(
                                          horizontal: 10),
                                      child: Container(
                                          alignment: Alignment.center,
                                          child: ListView.builder(
                                            scrollDirection: Axis.horizontal,
                                            itemCount: citiesList.length,
                                            itemBuilder: ((context, index) {
                                              var item = citiesList[index];
                                              return Container(
                                                alignment: Alignment.center,
                                                margin:
                                                    const EdgeInsets.symmetric(
                                                        horizontal: 3),
                                                child: Text(
                                                    "${item.name},${item.stateId},${item.countryId}"),
                                              );
                                            }),
                                          ))))
                              : Column(
                                  children: [
                                    Container(
                                      height: 50,
                                      decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(15)),
                                      child: FormField(
                                        builder: (FormFieldState state) {
                                          return InputDecorator(
                                            decoration: InputDecoration(
                                                fillColor: Colors.white,
                                                enabledBorder:
                                                    OutlineInputBorder(
                                                        borderSide: BorderSide(
                                                            color: Colors.grey),
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(10)),
                                                filled: true,
                                                // labelText: "Select",
                                                isDense: true,
                                                contentPadding:
                                                    EdgeInsets.all(10),
                                                border: OutlineInputBorder(
                                                  borderSide: BorderSide(
                                                      color: Colors.deepOrange),
                                                )),
                                            child: DropdownButtonHideUnderline(
                                              child: DropdownButton(
                                                // Initial Value

                                                value: dropdownvalue,

                                                // Down Arrow Icon
                                                icon: const Icon(
                                                    Icons.keyboard_arrow_down),

                                                // Array list of items
                                                items:
                                                    items.map((String items) {
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
                                                    if (dropdownvalue ==
                                                        "manually") {
                                                      sameAddress = false;
                                                      if (sameAddress ==
                                                          false) {
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
                                    dropdownvalue == "manually"
                                        ? Column(
                                            children: [
                                              SizedBox(
                                                height: 20,
                                              ),
                                              Container(
                                                alignment: Alignment.center,
                                                height: 50,
                                                width: MediaQuery.of(context)
                                                        .size
                                                        .width *
                                                    0.9,
                                                decoration: BoxDecoration(
                                                    border: Border.all(
                                                        color: Colors.grey),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            10)),
                                                child: Container(
                                                  margin: const EdgeInsets
                                                          .symmetric(
                                                      horizontal: 10),
                                                  child: TextFormField(
                                                    controller:
                                                        destinationPoint,
                                                    autofocus: true,
                                                    keyboardType:
                                                        TextInputType.text,
                                                    showCursor: true,
                                                    onChanged: (value) {
                                                      getLocations(value);
                                                    },
                                                    decoration: InputDecoration(
                                                      suffixIcon: IconButton(
                                                          onPressed: () {
                                                            setState(() {
                                                              if (destinationPoint
                                                                  .text
                                                                  .isEmpty) {
                                                                showToast(
                                                                    "Select Location !!");
                                                              } else {
                                                                locationAddList.add(
                                                                    locationUser);
                                                                log(locationAddList
                                                                    .toString());
                                                                showToast(
                                                                    "Added Sucessfully !!");

                                                                destinationPoint
                                                                    .clear();
                                                              }
                                                            });
                                                          },
                                                          icon: Icon(Icons.add,
                                                              color:
                                                                  Colors.blue)),
                                                      hintStyle: TextStyle(
                                                        color: Colors.black,
                                                        fontWeight:
                                                            FontWeight.normal,
                                                      ),
                                                      border: InputBorder.none,
                                                      hintText:
                                                          "Search Location",
                                                    ),
                                                    style: const TextStyle(
                                                      color: Colors.black,
                                                      fontWeight:
                                                          FontWeight.normal,
                                                    ),
                                                    maxLines: 1,
                                                  ),
                                                ),
                                              ),
                                              showData == false
                                                  ? SizedBox()
                                                  : SizedBox(
                                                      height:
                                                          MediaQuery.of(context)
                                                                  .size
                                                                  .height *
                                                              0.3,
                                                      width:
                                                          MediaQuery.of(context)
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
                                                                locations = places[
                                                                        index][
                                                                    'formatted_address'];
                                                                log("------>$places");
                                                                var lattitude =
                                                                    places[index]
                                                                            [
                                                                            'geometry']
                                                                        [
                                                                        'location']['lat'];
                                                                var longitude =
                                                                    places[index]
                                                                            [
                                                                            'geometry']
                                                                        [
                                                                        'location']['lng'];
                                                                log("Destination Point Address : ${locations.toString()}");
                                                                log("Destination Point Lattitude : ${lattitude.toString()}");
                                                                log("Destination Point Longitude : ${longitude.toString()}");
                                                                getAddressFromLatLongDesti(
                                                                    lattitude
                                                                        .toString(),
                                                                    longitude
                                                                        .toString());
                                                                showData =
                                                                    false;
                                                                destinationLattitude =
                                                                    lattitude
                                                                        .toString();
                                                                destinationLongitude =
                                                                    longitude
                                                                        .toString();
                                                                destinationPoint
                                                                        .text =
                                                                    locations
                                                                        .toString();
                                                                setState(() {
                                                                  locationUser =
                                                                      places[index]
                                                                          [
                                                                          'formatted_address'];
                                                                  log("location user ---> $locationUser");

                                                                  places
                                                                      .clear();
                                                                });
                                                                FocusScope.of(
                                                                        context)
                                                                    .requestFocus(
                                                                        FocusNode());
                                                                // _setLocation(locations, lattitude, longitude);
                                                              },
                                                              leading:
                                                                  Container(
                                                                padding:
                                                                    const EdgeInsets
                                                                        .all(5),
                                                                decoration:
                                                                    const BoxDecoration(
                                                                  borderRadius:
                                                                      BorderRadius
                                                                          .all(
                                                                    Radius
                                                                        .circular(
                                                                      100,
                                                                    ),
                                                                  ),
                                                                  color: Colors
                                                                      .grey,
                                                                ),
                                                                child:
                                                                    const Icon(
                                                                  Icons
                                                                      .location_on_outlined,
                                                                  color: Colors
                                                                      .black,
                                                                ),
                                                              ),
                                                              title: Padding(
                                                                padding:
                                                                    const EdgeInsets
                                                                            .only(
                                                                        left:
                                                                            8.0),
                                                                child: Text(
                                                                  places[index][
                                                                      'formatted_address'],
                                                                  style: TextStyle(
                                                                      color: Colors
                                                                          .black),
                                                                  maxLines: 1,
                                                                  overflow:
                                                                      TextOverflow
                                                                          .ellipsis,
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
                                                height: MediaQuery.of(context)
                                                        .size
                                                        .height *
                                                    0.2,
                                                child: ListView.builder(
                                                    itemCount:
                                                        locationAddList.length,
                                                    itemBuilder:
                                                        (context, index) {
                                                      getLocation =
                                                          locationAddList[
                                                              index];
                                                      return Container(
                                                        margin: const EdgeInsets
                                                                .symmetric(
                                                            horizontal: 10,
                                                            vertical: 0),
                                                        child: Row(
                                                          children: [
                                                            Text(
                                                              locationAddList[
                                                                  index],
                                                              style: TextStyle(
                                                                  color: Colors
                                                                      .black,
                                                                  fontSize: 16),
                                                            ),
                                                            IconButton(
                                                                onPressed: () {
                                                                  setState(() {
                                                                    locationAddList
                                                                        .remove(
                                                                            locationAddList[index]);
                                                                    showToast(
                                                                        "Removed Sucessfully !!");
                                                                  });
                                                                },
                                                                icon: Icon(
                                                                  Icons.close,
                                                                  size: 18,
                                                                  color: Colors
                                                                      .red,
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
                                  ],
                                ),
                          // SizedBox(height: 10),

                          // SizedBox(height: 10),
                          // const Align(
                          //   alignment: Alignment.topLeft,
                          //   child: Text(
                          //     "Location Availability *",
                          //     style: TextStyle(
                          //         color: kPrimaryColor,
                          //         fontWeight: FontWeight.bold),
                          //   ),
                          // ),
                          // SizedBox(height: 10),
                          // Container(
                          //   decoration: BoxDecoration(
                          //       border:
                          //           Border.all(color: Colors.grey, width: 1),
                          //       borderRadius:
                          //           BorderRadius.all(Radius.circular(8.0))),
                          //   child: Padding(
                          //     padding: const EdgeInsets.only(left: 5.0),
                          //     child: TextFormField(
                          //       // controller: securityamount,
                          //       readOnly: true,
                          //       keyboardType: TextInputType.number,
                          //       textAlign: TextAlign.start,
                          //       decoration: InputDecoration(
                          //           border: InputBorder.none,
                          //           hintText: locationAviablity),
                          //     ),
                          //   ),
                          // ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: 20),
                  Card(
                    elevation: 4.0,
                    child: Padding(
                      padding:
                          EdgeInsets.symmetric(vertical: 10, horizontal: 15),
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
                                padding: const EdgeInsets.only(
                                    left: 5.0, right: 5.0),
                                child: DropdownButton(
                                  value: negotiablevalue,
                                  icon:
                                      const Icon(Icons.arrow_drop_down_rounded),
                                  items: Negotiablelist.map((String items) {
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
                          SizedBox(
                            height: 10,
                          ),

                          // const Align(
                          //   alignment: Alignment.topLeft,
                          //   child: Text(
                          //     "Email*",
                          //     style: TextStyle(
                          //         color: kPrimaryColor,
                          //         fontWeight: FontWeight.bold),
                          //   ),
                          // ),
                          // SizedBox(height: 10),
                          // Container(
                          //     width: double.infinity,
                          //     decoration: BoxDecoration(
                          //         border: Border.all(
                          //             color: Colors.grey, width: 1.0),
                          //         borderRadius:
                          //             BorderRadius.all(Radius.circular(8.0))),
                          //     child: Padding(
                          //       padding: const EdgeInsets.only(left: 5.0),
                          //       child: TextFormField(
                          //         validator: (value) {
                          //           if (value == null || value.isEmpty) {
                          //             return 'Required Field';
                          //           }
                          //           return null;
                          //         },
                          //         controller: email,
                          //         keyboardType: TextInputType.emailAddress,
                          //         decoration: InputDecoration(
                          //           border: InputBorder.none,
                          //         ),
                          //       ),
                          //     )),
                          // Center(
                          //   child: TextButton.icon(
                          //       onPressed: () {
                          //         setState(() {
                          //           sameAddress = !sameAddress;
                          //         });
                          //         if (sameAddress) {
                          //           _getprofileData();
                          //         } else {
                          //           _getOldAddressDetails(productid);
                          //         }
                          //       },
                          //       icon: sameAddress
                          //           ? Icon(Icons.check_box_outlined)
                          //           : Icon(Icons.check_box_outline_blank),
                          //       label: Text("Same Address")),
                          // ),
                          // AbsorbPointer(
                          //   absorbing: sameAddress,
                          //   child: Column(
                          //     crossAxisAlignment: CrossAxisAlignment.start,
                          //     children: [
                          //       const Text("Country*",
                          //           style: TextStyle(
                          //               color: kPrimaryColor,
                          //               fontSize: 16,
                          //               fontWeight: FontWeight.w500)),
                          //       const SizedBox(height: 8.0),
                          //       Padding(
                          //         padding:
                          //             const EdgeInsets.fromLTRB(0, 2, 0, 2),
                          //         child: DropdownSearch(
                          //           selectedItem: selectedCountry,
                          //           mode: Mode.DIALOG,
                          //           showSelectedItem: true,
                          //           autoFocusSearchBox: true,
                          //           showSearchBox: true,
                          //           showFavoriteItems: true,
                          //           favoriteItems: (val) {
                          //             return ["India"];
                          //           },
                          //           hint: 'Select Country',
                          //           dropdownSearchDecoration: InputDecoration(
                          //               enabledBorder: OutlineInputBorder(
                          //                   borderRadius:
                          //                       BorderRadius.circular(8),
                          //                   borderSide: BorderSide(
                          //                       color: Colors.grey, width: 1)),
                          //               contentPadding:
                          //                   EdgeInsets.only(left: 10)),
                          //           items: countrylistData.map((e) {
                          //             return e['name'].toString();
                          //           }).toList(),
                          //           onChanged: (value) {
                          //             if (value != "Select Country") {
                          //               for (var element in countrylistData) {
                          //                 if (element['name'].toString() ==
                          //                     value) {
                          //                   setState(() {
                          //                     initialcountryname =
                          //                         value.toString();
                          //                     initialstatename = null;
                          //                     initialcityname = null;
                          //                     country_id =
                          //                         element['id'].toString();
                          //                     _getStateData(
                          //                         element['id'].toString());
                          //                   });
                          //                 }
                          //               }
                          //             } else {
                          //               showToast("Select Country");
                          //             }
                          //           },
                          //         ),
                          //       ),
                          //       const SizedBox(height: 10),
                          //       const Text("State*",
                          //           style: TextStyle(
                          //               color: kPrimaryColor,
                          //               fontSize: 16,
                          //               fontWeight: FontWeight.w500)),
                          //       const SizedBox(height: 8.0),
                          //       DropdownSearch(
                          //         selectedItem: selectedState,
                          //         mode: Mode.DIALOG,
                          //         showSelectedItem: true,
                          //         autoFocusSearchBox: true,
                          //         showSearchBox: true,
                          //         hint: 'Select State',
                          //         dropdownSearchDecoration: InputDecoration(
                          //             enabledBorder: OutlineInputBorder(
                          //                 borderRadius:
                          //                     BorderRadius.circular(8),
                          //                 borderSide: BorderSide(
                          //                     color: Colors.grey, width: 1)),
                          //             contentPadding:
                          //                 EdgeInsets.only(left: 10)),
                          //         items: statelistData.map((e) {
                          //           return e['name'].toString();
                          //         }).toList(),
                          //         onChanged: (value) {
                          //           if (value != "Select State") {
                          //             for (var element in statelistData) {
                          //               if (element['name'].toString() ==
                          //                   value) {
                          //                 setState(() {
                          //                   initialstatename = value.toString();
                          //                   initialstatename = null;
                          //                   initialcityname = null;
                          //                   state_id = element['id'].toString();
                          //                   _getCityData(
                          //                       element['id'].toString());
                          //                 });
                          //               }
                          //             }
                          //           } else {
                          //             showToast("Select State");
                          //           }
                          //         },
                          //       ),
                          //       const SizedBox(height: 10),
                          //       const Text("City*",
                          //           style: TextStyle(
                          //               color: kPrimaryColor,
                          //               fontSize: 16,
                          //               fontWeight: FontWeight.w500)),
                          //       const SizedBox(height: 8.0),
                          //       DropdownSearch(
                          //         selectedItem: selectedCity,
                          //         mode: Mode.DIALOG,
                          //         showSelectedItem: true,
                          //         autoFocusSearchBox: true,
                          //         showSearchBox: true,
                          //         hint: 'Select City',
                          //         dropdownSearchDecoration: InputDecoration(
                          //             enabledBorder: OutlineInputBorder(
                          //                 borderRadius:
                          //                     BorderRadius.circular(8),
                          //                 borderSide: BorderSide(
                          //                     color: Colors.grey, width: 1)),
                          //             contentPadding:
                          //                 EdgeInsets.only(left: 10)),
                          //         items: citylistData.map((e) {
                          //           return e['name'].toString();
                          //         }).toList(),
                          //         onChanged: (value) {
                          //           if (value != "Select City") {
                          //             for (var element in citylistData) {
                          //               if (element['name'].toString() ==
                          //                   value) {
                          //                 setState(() {
                          //                   initialcityname = value.toString();
                          //                   //initialstatename = null;
                          //                   //initialcityname = null;
                          //                   city_id = element['id'].toString();
                          //                   //_getStateData(element['id'].toString());
                          //                 });
                          //               }
                          //             }
                          //           } else {
                          //             showToast("Select City");
                          //           }
                          //         },
                          //       ),
                          //       const SizedBox(height: 10),
                          //       const Text("Address",
                          //           style: TextStyle(
                          //               color: kPrimaryColor,
                          //               fontSize: 16,
                          //               fontWeight: FontWeight.w500)),
                          //       const SizedBox(height: 8.0),
                          //       Container(
                          //           decoration: BoxDecoration(
                          //               border: Border.all(
                          //                   width: 1, color: Colors.grey),
                          //               borderRadius: BorderRadius.all(
                          //                   Radius.circular(8))),
                          //           child: Padding(
                          //             padding:
                          //                 const EdgeInsets.only(left: 10.0),
                          //             child: TextField(
                          //               controller: address,
                          //               decoration: InputDecoration(
                          //                 border: InputBorder.none,
                          //               ),
                          //             ),
                          //           )),
                          //       const SizedBox(height: 10),
                          //     ],
                          //   ),
                          // ),
                          // SizedBox(height: 10),
                          // const Align(
                          //   alignment: Alignment.topLeft,
                          //   child: Text(
                          //     "Hide Mobile Number",
                          //     style: TextStyle(
                          //         color: kPrimaryColor,
                          //         fontWeight: FontWeight.bold),
                          //   ),
                          // ),
                          // // SizedBox(height: 10),
                          // Container(
                          //     width: double.infinity,
                          //     decoration: BoxDecoration(
                          //         border: Border.all(
                          //             color: Colors.grey, width: 1.0),
                          //         borderRadius:
                          //             BorderRadius.all(Radius.circular(8.0))),
                          //     child: DropdownButtonHideUnderline(
                          //         child: Padding(
                          //       padding: const EdgeInsets.only(
                          //           left: 5.0, right: 5.0),
                          //       child: DropdownButton(
                          //         value: hidemobilevalue,
                          //         icon:
                          //             const Icon(Icons.arrow_drop_down_rounded),
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
                          // SizedBox(height: 10),
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
                                            hourlyRent = renttype[0]['enable'];
                                          });
                                        }),
                                    const Text("Hourly",
                                        style: TextStyle(
                                            color: kPrimaryColor,
                                            fontWeight: FontWeight.bold))
                                  ]),
                                  Row(children: [
                                    Checkbox(
                                        value: _checkday,
                                        onChanged: (value) {
                                          setState(() {
                                            _checkday = value;
                                            renttype[1]['enable'] = _checkday;
                                            dailyRent = renttype[1]['enable'];
                                          });
                                        }),
                                    const Text("Daily",
                                        style: TextStyle(
                                            color: kPrimaryColor,
                                            fontWeight: FontWeight.bold))
                                  ]),
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
                                            log(_checkmonth.toString());
                                            renttype[2]['enable'] = _checkmonth;
                                            monthlyRent = renttype[2]['enable'];
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
                                            yearlyRent = renttype[3]['enable'];
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
                          _checkhour == true
                              ? SizedBox(height: 10)
                              : SizedBox(),
                          _checkhour == true
                              ? const Align(
                                  alignment: Alignment.topLeft,
                                  child: Text(
                                    "Hourly Price*",
                                    style: TextStyle(
                                        color: kPrimaryColor,
                                        fontWeight: FontWeight.bold),
                                  ),
                                )
                              : SizedBox(),
                          _checkhour == true
                              ? SizedBox(height: 10)
                              : SizedBox(),
                          _checkhour == true
                              ? Container(
                                  decoration: BoxDecoration(
                                      border: Border.all(
                                          color: Colors.grey, width: 1),
                                      borderRadius: BorderRadius.all(
                                          Radius.circular(8.0))),
                                  child: Padding(
                                    padding: const EdgeInsets.only(left: 5.0),
                                    child: TextFormField(
                                      validator: (value) {
                                        if (value == null || value.isEmpty) {
                                          return 'Required Field';
                                        }
                                        return null;
                                      },
                                      keyboardType: TextInputType.number,
                                      decoration: InputDecoration(
                                        border: InputBorder.none,
                                      ),
                                      controller: hourlyprice,
                                      onChanged: (value) {
                                        if (value
                                            .toString()
                                            .trim()
                                            .isNotEmpty) {
                                          setState(() {
                                            renttype[0]
                                                ['amount'] = value..toString();
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
                                    "Days Price*",
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
                                      borderRadius: BorderRadius.all(
                                          Radius.circular(8.0))),
                                  child: Padding(
                                    padding: const EdgeInsets.only(left: 5.0),
                                    child: TextFormField(
                                      validator: (value) {
                                        if (value == null || value.isEmpty) {
                                          return 'Required Field';
                                        }
                                        return null;
                                      },
                                      keyboardType: TextInputType.number,
                                      controller: daysprice,
                                      decoration: InputDecoration(
                                        border: InputBorder.none,
                                      ),
                                      onChanged: (value) {
                                        if (value
                                            .toString()
                                            .trim()
                                            .isNotEmpty) {
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
                          _checkmonth == true
                              ? SizedBox(height: 10)
                              : SizedBox(),
                          _checkmonth == true
                              ? const Align(
                                  alignment: Alignment.topLeft,
                                  child: Text(
                                    "Monthly Price*",
                                    style: TextStyle(
                                        color: kPrimaryColor,
                                        fontWeight: FontWeight.bold),
                                  ),
                                )
                              : SizedBox(),
                          _checkmonth == true
                              ? SizedBox(height: 10)
                              : SizedBox(),
                          _checkmonth == true
                              ? Container(
                                  decoration: BoxDecoration(
                                      border: Border.all(
                                          color: Colors.grey, width: 1),
                                      borderRadius: BorderRadius.all(
                                          Radius.circular(8.0))),
                                  child: Padding(
                                    padding: const EdgeInsets.only(left: 5.0),
                                    child: TextFormField(
                                      validator: (value) {
                                        if (value == null || value.isEmpty) {
                                          return 'Required Field';
                                        }
                                        return null;
                                      },
                                      keyboardType: TextInputType.number,
                                      controller: monthprice,
                                      decoration: InputDecoration(
                                        border: InputBorder.none,
                                      ),
                                      onChanged: (value) {
                                        if (value
                                            .toString()
                                            .trim()
                                            .isNotEmpty) {
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
                          _checkyear == true
                              ? SizedBox(height: 10)
                              : SizedBox(),
                          _checkyear == true
                              ? const Align(
                                  alignment: Alignment.topLeft,
                                  child: Text(
                                    "Yearly Price*",
                                    style: TextStyle(
                                        color: kPrimaryColor,
                                        fontWeight: FontWeight.bold),
                                  ),
                                )
                              : SizedBox(),
                          _checkyear == true
                              ? SizedBox(height: 10)
                              : SizedBox(),
                          _checkyear == true
                              ? Container(
                                  decoration: BoxDecoration(
                                      border: Border.all(
                                          color: Colors.grey, width: 1),
                                      borderRadius: BorderRadius.all(
                                          Radius.circular(8.0))),
                                  child: Padding(
                                    padding: const EdgeInsets.only(left: 5.0),
                                    child: TextFormField(
                                      validator: (value) {
                                        if (value == null || value.isEmpty) {
                                          return 'Required Field';
                                        }
                                        return null;
                                      },
                                      keyboardType: TextInputType.number,
                                      controller: yearprice,
                                      decoration: InputDecoration(
                                        border: InputBorder.none,
                                      ),
                                      onChanged: (value) {
                                        if (value
                                            .toString()
                                            .trim()
                                            .isNotEmpty) {
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
                          SizedBox(
                            height: 10,
                          ),
                          Align(
                            alignment: Alignment.topLeft,
                            child: Text(
                              "Refundable Security Deposit*",
                              style: TextStyle(
                                  color: kPrimaryColor,
                                  fontWeight: FontWeight.bold),
                            ),
                          ),
                          SizedBox(
                            height: 10,
                          ),
                          Container(
                            decoration: BoxDecoration(
                                border:
                                    Border.all(color: Colors.grey, width: 1),
                                borderRadius:
                                    BorderRadius.all(Radius.circular(8.0))),
                            child: Padding(
                              padding: const EdgeInsets.only(left: 5.0),
                              child: TextFormField(
                                keyboardType: TextInputType.number,
                                controller: securityamount,
                                decoration: InputDecoration(
                                  border: InputBorder.none,
                                  hintText: securityamount.text,
                                ),
                                maxLines: 1,
                              ),
                            ),
                          ),
                          SizedBox(
                            height: 10,
                          ),
                          Align(
                            alignment: Alignment.topLeft,
                            child: Text(
                              "Quantity *",
                              style: TextStyle(
                                  color: kPrimaryColor,
                                  fontWeight: FontWeight.bold),
                            ),
                          ),
                          SizedBox(
                            height: 10,
                          ),
                          Container(
                            decoration: BoxDecoration(
                                border:
                                    Border.all(color: Colors.grey, width: 1),
                                borderRadius:
                                    BorderRadius.all(Radius.circular(8.0))),
                            child: Padding(
                              padding: const EdgeInsets.only(left: 5.0),
                              child: TextFormField(
                                controller: quantityController,
                                keyboardType: TextInputType.number,
                                // controller: yearprice,
                                decoration: InputDecoration(
                                  border: InputBorder.none,
                                  hintText: qunatity.toString(),
                                ),

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
                          SizedBox(height: 10),
                          // SizedBox(
                          //   width: size.width * 0.60,
                          //   child: Row(
                          //       mainAxisAlignment:
                          //           MainAxisAlignment.spaceBetween,
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
                          // SizedBox(height: 10),
                          // Row(
                          //   children: [
                          //     Text("Out Of Stock",
                          //         style: TextStyle(
                          //             color: kPrimaryColor,
                          //             fontWeight: FontWeight.bold)),
                          //     SizedBox(width: 10),
                          //     Checkbox(
                          //         value: _checkstock,
                          //         onChanged: (value) {
                          //           setState(() {
                          //             _checkstock = value;
                          //           });
                          //         })
                          //   ],
                          // ),
                          // SizedBox(height: 10),
                          Align(
                              alignment: Alignment.topLeft,
                              child: Row(
                                children: [
                                  const Text("Out Of Stock",
                                      style: TextStyle(
                                          color: kPrimaryColor,
                                          fontWeight: FontWeight.bold)),
                                  SizedBox(width: 4.0),
                                  Checkbox(
                                      value: _checkstock,
                                      onChanged: (value) {
                                        setState(() {
                                          _checkstock = value;
                                        });
                                      })
                                ],
                              )),
                          const Align(
                            alignment: Alignment.topLeft,
                            child: Text(
                              "Status",
                              style: TextStyle(
                                  color: kPrimaryColor,
                                  fontWeight: FontWeight.bold),
                            ),
                          ),
                          SizedBox(height: 10),
                          statusvalue == 3
                              ? Text(
                                  "Pending",
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                  ),
                                )
                              : statusvalue == 2
                                  ? Text(
                                      "Rejected",
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    )
                                  : statusvalue == 4
                                      ? Container(
                                          width: double.infinity,
                                          decoration: BoxDecoration(
                                              border: Border.all(
                                                  color: Colors.grey,
                                                  width: 1.0),
                                              borderRadius: BorderRadius.all(
                                                  Radius.circular(8.0))),
                                          child: DropdownButtonHideUnderline(
                                              child: Padding(
                                            padding: const EdgeInsets.only(
                                                left: 5.0, right: 5.0),
                                            child: DropdownButton(
                                              value: statusvalue,
                                              icon: const Icon(Icons
                                                  .arrow_drop_down_rounded),
                                              items: [
                                                {"title": "Active", "id": "6"},
                                                {"title": "Inctive", "id": "4"},
                                                // {"title": "Pending", "id": "3"},
                                                // {"title": "Rejected", "id": "2"}
                                              ].map((items) {
                                                return DropdownMenuItem(
                                                  value: int.parse(
                                                      items['id'].toString()),
                                                  child: Text(items['title']
                                                      .toString()),
                                                );
                                              }).toList(),
                                              isExpanded: true,
                                              onChanged: (value) {
                                                setState(() {
                                                  statusvalue = int.parse(
                                                      value.toString());
                                                });
                                              },
                                            ),
                                          )))
                                      : Text(
                                          "",
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                          statusvalue == 6
                              ? Container(
                                  width: double.infinity,
                                  decoration: BoxDecoration(
                                      border: Border.all(
                                          color: Colors.grey, width: 1.0),
                                      borderRadius: BorderRadius.all(
                                          Radius.circular(8.0))),
                                  child: DropdownButtonHideUnderline(
                                      child: Padding(
                                    padding: const EdgeInsets.only(
                                        left: 5.0, right: 5.0),
                                    child: DropdownButton(
                                      value: statusvalue,
                                      icon: const Icon(
                                          Icons.arrow_drop_down_rounded),
                                      items: [
                                        {"title": "Active", "id": "6"},
                                        {"title": "Inctive", "id": "4"},
                                        // {"title": "Pending", "id": "3"},
                                        // {"title": "Rejected", "id": "2"}
                                      ].map((items) {
                                        return DropdownMenuItem(
                                          value:
                                              int.parse(items['id'].toString()),
                                          child:
                                              Text(items['title'].toString()),
                                        );
                                      }).toList(),
                                      isExpanded: true,
                                      onChanged: (value) {
                                        setState(() {
                                          statusvalue =
                                              int.parse(value.toString());
                                        });
                                      },
                                    ),
                                  )))
                              : Text(
                                  "",
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),

                          SizedBox(height: 10),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: 20),
                  InkWell(
                    onTap: () {
                      if (changeCategory == true && initiacatlvalue == null ||
                          initiacatlvalue == "" ||
                          initiacatlvalue == "null") {
                        showToast("Please select  category");
                      } else if (changeLocation == true &&
                          locationAddList.isEmpty) {
                        showToast("Please choose Location");
                      } else if (daysprice.text.isEmpty &&
                          monthprice.text.isEmpty &&
                          yearprice.text.isEmpty &&
                          hourlyprice.text.isEmpty) {
                        showToast("Select Atleast one Rent type");
                      } else if (_checkday == false &&
                          _checkmonth == false &&
                          _checkhour == false &&
                          _checkyear == false) {
                        showToast("Select Atleast one Rent type");
                      } else if (_checkhour == true &&
                          hourlyprice.text.isEmpty) {
                        showToast("Please fill hourly price");
                      } else if (_checkday == true && daysprice.text.isEmpty) {
                        showToast("Please fill Days Price");
                      } else if (_checkmonth == true &&
                          monthprice.text.isEmpty) {
                        showToast("Please fill monthly price");
                      } else if (_checkyear == true && yearprice.text.isEmpty) {
                        showToast("Please fill yearly price");
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
                            borderRadius:
                                BorderRadius.all(Radius.circular(8.0))),
                        child: const Text("Update",
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.w600)),
                      ),
                    ),
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  String locationAviablity = "";
  String categoryTitle = '';
  String categoryId = '';
  String subCategoryId;
  String subCategoryTitle;
  String userAddress;

  int qunatity = 0;
  Future _getpreproductedit(String productid) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final body = {
      "id": productid,
    };
    log("id====>$body");
    var response = await http.post(Uri.parse(BASE_URL + editviewpost),
        body: jsonEncode(body),
        headers: {
          "Accept": "application/json",
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${prefs.getString("token")}',
        });

    if (response.statusCode == 200) {
      var data = json.decode(response.body)['Response'];

      var list = data['posted_ad']['cities'] as List;
      setState(() {
        productname.text = data['posted_ad']['title'].toString();
        locationAviablity =
            data['posted_ad']['location_availability'].toString();

        final document = parse(data['posted_ad']['description'].toString());
        description.text =
            parse(document.body.text).documentElement.text.toString();
        mobile.text = data['posted_ad']['mobile'].toString();
        email.text = data['posted_ad']['email'].toString();
        securityamount.text = data['posted_ad']['security'].toString();

        // categoryhint =
        //     data['posted_ad'][0]['categories'][0]['title'].toString();
        // subcategoryhint =
        //     data['posted_ad'][0]['categories'][1]['title'].toString();

        // initiacatlvalue =
        //     data['posted_ad'][0]['categories'][0]['id'].toString();

        categoryTitle = data['posted_ad']['category']['title'].toString();
        categoryId = data['posted_ad']['category']['id'].toString();
        userAddress = data['posted_ad']['address'].toString();

        // initiacatlvalue = categoryTitle;
        log("ini0----->$categoryTitle");

        // initiacatlvalue=categoryTitle;
        // log(initiacatlvalue);

        // _getSubCategories(initiacatlvalue).then((value) {
        //   initialsubcatvalue = data['posted_ad']['category']['id'].toString();
        // });

        // hidemobilevalue =
        //     data['posted_ad']['mobile_hidden'].toString() == "1"
        //         ? "Yes"
        //         : "No";

        _checkstock =
            data['posted_ad']['out_of_stock'].toString() == "0" ? false : true;
        qunatity = data['posted_ad']['quantity'];
        quantityController.text = qunatity.toString();
        statusvalue = data['posted_ad']['status'];
        // data['posted_ad'].forEach((element) {
        //   if (element['preferences'].toString() == "1") {
        //     communicationprefs.add(1);
        //     _email = true;
        //   } else if (element['preferences'].toString() == "2") {
        //     communicationprefs.add(2);
        //     _sms = true;
        //   } else {
        //     communicationprefs.add(1);
        //     communicationprefs.add(2);
        //     _sms = true;
        //     _email = true;
        //   }
        // });

        data['Images'].forEach((element) {
          if (element['is_main'] == 1) {
            mainimage =
                "$devImage${element['upload_base_path'].toString()}${element['file_name'].toString()}";
          } else {
            additionalimage.add({
              "update": false,
              "image":
                  "$devImage${element['upload_base_path'].toString()}${element['file_name'].toString()}",
              "id": element['id'].toString()
            });
          }
        });

        data['Pricing'].forEach((element) {
          if (element['rent_type_name'].toString() == "Hourly") {
            _checkhour = true;
            if (element['price'] == null ||
                element['price'] == "" ||
                element['price'] == "null") {
              _checkhour = false;
            } else {
              hourlyprice.text =
                  element['price'] == null ? "" : element['price'].toString();
              renttype[0]['amount'] =
                  element['price'] == null ? "" : element['price'].toString();
            }
          } else if (element['rent_type_name'].toString() == "Yearly") {
            _checkyear = true;
            if (element['price'] == null ||
                element['price'] == "" ||
                element['price'] == "null") {
              _checkyear = false;
            } else {
              yearprice.text =
                  element['price'] == null ? "" : element['price'].toString();
              renttype[1]['amount'] =
                  element['price'] == null ? "" : element['price'].toString();
            }
          } else if (element['rent_type_name'].toString() == "Monthly") {
            _checkmonth = true;
            if (element['price'] == null ||
                element['price'] == "" ||
                element['price'] == "null") {
              _checkmonth = false;
            } else {
              monthprice.text =
                  element['price'] == null ? "" : element['price'].toString();
              renttype[2]['amount'] =
                  element['price'] == null ? "" : element['price'].toString();
            }
          } else {
            _checkday = true;
            if (element['price'] == null ||
                element['price'] == "" ||
                element['price'] == "null") {
              _checkday = false;
            }
            {
              daysprice.text =
                  element['price'] == null ? "" : element['price'].toString();
              renttype[3]['amount'] =
                  element['price'] == null ? "" : element['price'].toString();
            }
          }
        });
        negotiablevalue =
            data['posted_ad']['negotiate'].toString() == "1" ? "Yes" : "No";

        // if (data['posted_ad'][0]['address_same_as_profile'] == "yes") {
        //   sameAddress = true;
        //   _getprofileData();
        // } else {
        //   sameAddress = false;
        //   selectedCountry =
        //       data['posted_ad'][0]['get_country']['name'].toString();
        //   selectedState = data['posted_ad'][0]['get_state']['name'].toString();
        //   selectedCity = data['posted_ad'][0]['get_city']['name'].toString();
        //   country_id = data['posted_ad'][0]['country'].toString();
        //   state_id = data['posted_ad'][0]['state'].toString();
        //   city_id = data['posted_ad'][0]['city'].toString();
        //   address.text = data['posted_ad'][0]['address'].toString();
        // }
        _getCategories();

        citiesList.clear();
        var listdata = list.map((e) => CitiesModel.fromJson(e)).toList();
        citiesList.addAll(listdata);

        checkData = true;
        categoryid = data['posted_ad']['categories'][0]['id'].toString();
        subcategoryid = data['posted_ad']['subcategory']['id'].toString();
        subCategoryId = data['posted_ad']['subcategory']['id'].toString();
        subCategoryTitle = data['posted_ad']['subcategory']['title'].toString();
        log("subcategory--->$subCategoryTitle");
      });
    } else {
      throw Exception('Failed to get data due to ${response.body}');
    }
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
        _categorieslist.addAll(jsonDecode(response.body)['Response']);
      });
    } else {}
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
      setState(() {
        _subcategorieslist
            .addAll(jsonDecode(response.body)['Response']['subcategories']);
      });
    }
  }

  Future<void> showmainimageCaptureOptions(int datafor, int index) async {
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
                              switch (datafor) {
                                case 1:
                                  setState(() {
                                    mainimage = result.path.toString();
                                  });
                                  break;

                                case 2:
                                  setState(() {
                                    additionalimage.add({
                                      "image": result.path.toString(),
                                      "id": "-",
                                      "update": true
                                    });
                                  });
                                  break;
                                // case 3:
                                //   setState(() {
                                //     additionalimage[index]["image"] =
                                //         result.path.toString();
                                //     additionalimage[index]["update"] = true;
                                //   });
                                //   break;
                              }
                            }
                            Navigator.of(context).pop();
                            print(
                                ".........................2${jsonEncode(additionalimage)}");
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
                              switch (datafor) {
                                case 1:
                                  setState(() {
                                    mainimage = result.path.toString();
                                  });
                                  break;

                                case 2:
                                  setState(() {
                                    additionalimage.add({
                                      "image": result.path.toString(),
                                      "id": "-",
                                      "update": true
                                    });
                                  });
                                  break;
                                // case 3:
                                //   setState(() {
                                //     additionalimage[index]["image"] =
                                //         result.path.toString();
                                //     additionalimage[index]["update"] = true;
                                //   });
                                //   break;
                              }
                            }
                            Navigator.of(context).pop();
                            print(
                                ".........................${jsonEncode(additionalimage)}");
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

  bool changeSubCategory = false;

  Future<Map> submitpostaddData(List files) async {
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

      List newImages = [];
      List oldImages = [];

      for (var element in files) {
        if (element['update'].toString() == "true") {
          newImages.add(element['image']);
        } else {
          oldImages.add(element['id']);
        }
      }

      var requestMulti =
          http.MultipartRequest('POST', Uri.parse(BASE_URL + updatepost));

      requestMulti.fields["userid"] = prefs.get('userid').toString();
      requestMulti.fields["post_id"] = productid;
      requestMulti.fields["quantity"] = qunatity.toString();

      requestMulti.fields["category[0]"] =
          changeCategory == true ? categoryid : categoryId.toString();
      requestMulti.fields["category[1]"] =
          changeSubCategory == true ? changeCategory : subcategoryid.toString();
      requestMulti.fields["title"] = productname.text.toString();
      requestMulti.fields["description"] = description.text.toString();
      requestMulti.fields["security"] = securityamount.text.toString();
      requestMulti.fields["negotiate"] =
          negotiablevalue.toString() == "Yes" ? "1" : "0";
      requestMulti.fields["mobile"] = mobile.text.toString();
      requestMulti.fields["email"] = email.text.toString();
      requestMulti.fields["mobile_hidden"] = mobilehiddenvalue.toString();
      requestMulti.fields["com_prefs"] = communicationprefs.toString();
      requestMulti.fields["status"] = statusvalue.toString();
      if (_checkhour == true && hourlyprice.text.isEmpty) {
        requestMulti.fields["price[1]"] = renttype[0]['amount'].toString();
      } else if (hourlyprice.text.isNotEmpty && _checkhour == true) {
        requestMulti.fields["price[1]"] = hourlyprice.text.toString();
      }
      if (_checkday == true && daysprice.text.isEmpty) {
        requestMulti.fields["price[2]"] = renttype[1]['amount'].toString();
      } else if (daysprice.text.isNotEmpty && _checkday == true) {
        requestMulti.fields["price[2]"] = daysprice.text.toString();
      }
      if (_checkmonth == true && monthprice.text.isEmpty) {
        requestMulti.fields["price[3]"] = renttype[2]['amount'].toString();
      } else if (monthprice.text.isNotEmpty && _checkmonth == true) {
        requestMulti.fields["price[3]"] = monthprice.text.toString();
      }

      if (_checkyear == true && yearprice.text.isEmpty) {
        requestMulti.fields["price[4]"] = renttype[3]['amount'].toString();
      } else if (yearprice.text.isNotEmpty && _checkyear == true) {
        requestMulti.fields["price[4]"] = yearprice.text.toString();
      }

      requestMulti.fields["rent_type[1]"] = renttype[0]['type'].toString();

      requestMulti.fields["rent_type[2]"] = renttype[1]['type'].toString();

      requestMulti.fields["rent_type[3]"] = renttype[2]['type'].toString();

      requestMulti.fields["rent_type[4]"] = renttype[3]['type'].toString();
      requestMulti.fields["files"] = renttype[3]['type'].toString();
      requestMulti.fields["address_type"] =
          changeLocation == false ? "same_as_profile" : "manually";
      requestMulti.fields["location_data[0]"] =
          changeLocation == false ? userAddress : locationAddList.toString();
      requestMulti.fields["quantity"] = quantityController.text.toString();

      _checkstock == true ? requestMulti.fields["out_of_stock"] = "1" : "";

      // requestMulti.fields["security"] = quantityController.text.toString();

      requestMulti.fields["old_images"] = oldImages.join(",").toString();
      print(jsonEncode(requestMulti.fields));

      requestMulti.headers.addAll({
        'Authorization': 'Bearer ${prefs.getString("token")}',
      });

      if (!mainimage.contains('http')) {
        requestMulti.files.add(http.MultipartFile("main_image",
            File(mainimage).openRead(), File(mainimage).lengthSync(),
            filename: "image${p.extension(mainimage.toString())}"));
      }

      List<http.MultipartFile> newList = [];
      if (newImages.isNotEmpty) {
        for (var i = 0; i < newImages.length; i++) {
          File imageFile = File(newImages[i].toString());
          var stream = http.ByteStream(imageFile.openRead());
          var length = await imageFile.length();
          var multipartFile = http.MultipartFile("images[]", stream, length,
              filename: "image${p.extension(newImages[i].toString())}");
          newList.add(multipartFile);
        }
      }

      requestMulti.files.addAll(newList);

      var response = await requestMulti.send();
      var respStr = await response.stream.bytesToString();
      setState(() {
        _loading = false;
      });
      print(respStr);
      if (jsonDecode(respStr)['ErrorCode'] == 0) {
        showToast(jsonDecode(respStr)['ErrorMessage'].toString());
        _getpreproductedit(productid);
        Navigator.of(context).pop();
      } else {
        showToast(jsonDecode(respStr)['ErrorMessage'].toString());
      }
    }
  }
}
