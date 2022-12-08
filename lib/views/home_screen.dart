// ignore_for_file: sort_child_properties_last, use_build_context_synchronously, prefer_interpolation_to_compose_strings, library_private_types_in_public_api

import 'dart:convert';
import 'dart:developer';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_pro/carousel_pro.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:rentit4me_new/helper/dialog_helper.dart';
import 'package:rentit4me_new/helper/loader.dart';
import 'package:rentit4me_new/models/latest_addition_model.dart';
import 'package:rentit4me_new/network/api.dart';
import 'package:rentit4me_new/themes/constant.dart';
import 'package:rentit4me_new/utils/dialog_utils.dart';
import 'package:rentit4me_new/views/login_screen.dart';
import 'package:rentit4me_new/views/product_detail_screen.dart';
import 'package:rentit4me_new/views/top_selling_categories.dart';
import 'package:rentit4me_new/views/top_selling_categories_screen.dart';
import 'package:rentit4me_new/views/user_finder_data_screen.dart';
import 'package:rentit4me_new/views/view_all_latest_edition.dart';
import 'package:rentit4me_new/widgets/api_helper.dart';
import 'package:rentit4me_new/widgets/navigation_drawer_widget.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/top_selling_categories_model.dart';
import 'add_list_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // Initial Selected Value

  final TextEditingController typeAheadController = TextEditingController();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  GlobalKey scrollKey = GlobalKey();
  String locationvalue;
  String categoryvalue;
  int packageId = 0;

  String selectedCity = "Location";
  int isSignedUp = 0;

  int trustedBadge = 0;
  String trustedBadgeApproval;

  final List<dynamic> myProducts = [];
  final List<dynamic> mytopcategories = [];
  final List<dynamic> mytopcategorieslug = [];
  List mytopcategorieslistData = [];
  final List<dynamic> featuredname = [];
  final List<dynamic> mytopcategoriesname = [];
  final List<dynamic> myfeaturedcategories = [];
  final List<dynamic> mysubfeaturedcategories = [];
  List<TopSellingCatgegoriesModel> topsellingCategoreslist = [];
  bool loggedIn = false;
  bool autoDetectCity = false;

  bool searchHeader = false;

  List<dynamic> location = [];
  String cityName = '';
  String cityId = '';
  double height = 0;
  double width = 0;
  List<LatestAdditionsModel> latestAdditionList = [];

  bool findCity = false;
  List<dynamic> category = [];
  List<dynamic> categorylistData = [];
  List<dynamic> categoryslug = [];
  String categoryslugname;
  List<dynamic> images = [];
  String destinationLattitude = "";
  String destinationLongitude = "";
  bool loader = false;

  List<dynamic> likedadproductlist = [];

  String todaydealsimage1;
  String todaydealsimage2;
  String todaydealsimage3;
  String todaydealsimage4;
  String destilocality = "";
  getAddressFromLatLongDesti(String latitude, longitude) async {
    List<Placemark> placemarks = await placemarkFromCoordinates(
        double.parse(latitude), double.parse(longitude));
    // log("placemark==> $placemarks");
    Placemark place = placemarks[0];

    destilocality = place.locality.toString();
    log("=--->" + destilocality);
  }

  String bottomimage1;
  String bottomimage2;
  String bottomimage3;
  String bottomimage4;
  String bottomsingleimage;
  String defaultAddress = "";
  String addressType = "";
  bool selectCity = false;
  String currentCity = "";
  bool _loading = false;
  TextEditingController address = TextEditingController();

  Future<Position> _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Test if location services are enabled.
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      // Location services are not enabled don't continue
      // accessing the position and request users of the
      // App to enable the location services.
      return Future.error('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        // Permissions are denied, next time you could try
        // requesting permissions again (this is also where
        // Android's shouldShowRequestPermissionRationale
        // returned true. According to Android guidelines
        // your App should show an explanatory UI now.
        return Future.error('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      // Permissions are denied forever, handle appropriately.
      return Future.error(
          'Location permissions are permanently denied, we cannot request permissions.');
    }

    // When we reach here, permissions are granted and we can
    // continue accessing the position of the device.
    return await Geolocator.getCurrentPosition();
  }

  String locations = '';

  Future<void> _getAddress(value) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<Placemark> placemarks =
        await placemarkFromCoordinates(value.latitude, value.longitude);
    // print(placemarks);
    Placemark place = placemarks[0];

    setState(() {
      prefs.setString('state', place.administrativeArea);
      prefs.setString('city', place.locality);
      prefs.setString('country', place.country);

      log("city-->${prefs.getString("city")}");
      log("city-->${prefs.getString("state")}");
      log("country-->${prefs.getString("country")}");

      _loading = false;
      selectCity = true;
      address.text = place.locality.toString();
      log("===>address" + address.text);
      locationvalue = place.locality;

      getLatestAdditionByUserLocation(
          place.country, place.administrativeArea, place.locality);

      var snackBar =
          const SnackBar(content: Text('City Detected Successfully !!'));
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    });
  }

  Future<void> _getAddressFromManual(lati, long) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<Placemark> placemarks = await placemarkFromCoordinates(lati, long);
    // print(placemarks);
    Placemark place = placemarks[0];

    setState(() {
      prefs.setString('state', place.administrativeArea);
      prefs.setString('city', place.locality);
      prefs.setString('country', place.country);

      log("city-->${prefs.getString("city")}");
      log("city-->${prefs.getString("state")}");
      log("country-->${prefs.getString("country")}");

      _loading = false;
      selectCity = true;
      address.text = place.locality.toString();
      log("===>address" + address.text);
      locationvalue = place.locality;

      getLatestAdditionByUserLocation(
          place.country, place.administrativeArea, place.locality);

      var snackBar =
          const SnackBar(content: Text('City Detected Successfully !!'));
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    });
  }

  TextEditingController currentPoint = TextEditingController();
  String locationUser;

  String lati = '';
  String land = '';
  String locality;
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

  TextEditingController destinationPoint = TextEditingController();

  bool _check = false;
  Future<void> showDilogBoxForLocation(BuildContext context) async {
    return showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(content: StatefulBuilder(
              builder: (BuildContext context, StateSetter setState) {
            return SizedBox(
              height: MediaQuery.of(context).size.height * 0.6,
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
                          Expanded(
                              // width: MediaQuery.of(context).size.width * 0.55,
                              // height: MediaQuery.of(context).size.height*0.03,

                              child: const Text(
                            "Please provide your delivery location to see products at nearby store",
                            maxLines: 3,
                            textAlign: TextAlign.left,
                          )),
                        ],
                      ),
                    ),
                    const Divider(
                      color: Colors.grey,
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    Column(
                      children: [
                        InkWell(
                          onTap: () {
                            setState(() {
                              autoDetectCity = true;
                              findCity = true;
                              log('=---->$currentCity');
                              _determinePosition()
                                  .then((value) => _getAddress(value));
                            });
                            // _determinePosition();

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
                      alignment: Alignment.center,
                      height: 50,
                      width: MediaQuery.of(context).size.width * 0.9,
                      decoration: BoxDecoration(
                          border: Border.all(color: Colors.deepOrange),
                          borderRadius: BorderRadius.circular(10)),
                      child: Container(
                        margin: const EdgeInsets.symmetric(horizontal: 10),
                        child: TextFormField(
                          controller: destinationPoint,
                          autofocus: true,
                          keyboardType: TextInputType.text,
                          showCursor: true,
                          onChanged: (val) async {
                            var kGoogleApiKey = Apis.mapKey.toString();
                            var url = Uri.tryParse(
                                "https://maps.googleapis.com/maps/api/place/findplacefromtext/json?input=" +
                                    val.toString() +
                                    "&inputtype=textquery&fields=formatted_address,geometry&location=20.7711857,73.729974&radius=10000&key=" +
                                    kGoogleApiKey);

                            http.Response res = await http.get(url);
                            setState(() {
                              showData = true;
                              places = json.decode(res.body)['candidates'];
                              placecounts = places.length;
                            });
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
                            height: MediaQuery.of(context).size.height * 0.3,
                            width: MediaQuery.of(context).size.width * 0.9,
                            child: ListView.builder(
                              itemCount: placecounts,
                              itemBuilder: (context, int index) {
                                return SizedBox(
                                  height: 50,
                                  child: ListTile(
                                    onTap: () {
                                      locations =
                                          places[index]['formatted_address'];
                                      log("------>" + places.toString());
                                      var lattitude = places[index]['geometry']
                                          ['location']['lat'];
                                      var longitude = places[index]['geometry']
                                          ['location']['lng'];
                                      log("Destination Point Address : ${locations.toString()}");
                                      log("Destination Point Lattitude : ${lattitude.toString()}");
                                      log("Destination Point Longitude : ${longitude.toString()}");
                                      getAddressFromLatLongDesti(
                                          lattitude.toString(),
                                          longitude.toString());
                                      setState(() {
                                        showData = false;
                                        destinationLattitude =
                                            lattitude.toString();
                                        destinationLongitude =
                                            longitude.toString();
                                        destinationPoint.text =
                                            locations.toString();
                                        locationUser =
                                            places[index]['formatted_address'];
                                        log("location user ---> $locationUser");
                                        places.clear();
                                        FocusScope.of(context)
                                            .requestFocus(FocusNode());

                                        Navigator.pop(context);
                                        _determinePosition().then((value) =>
                                            _getAddressFromManual(
                                                lattitude, longitude));
                                      });

                                      // getLatestAddition();
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
                                      padding: const EdgeInsets.only(left: 8.0),
                                      child: Text(
                                        places[index]['formatted_address'],
                                        style: TextStyle(color: Colors.black),
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
                    //   height: 40,
                    //   width: MediaQuery.of(context).size.width * 0.6,
                    //   decoration:
                    //       BoxDecoration(borderRadius: BorderRadius.circular(100)),
                    //   alignment: Alignment.center,
                    //   child: TypeAheadField(
                    //     //hideOnLoading: false,
                    //     textFieldConfiguration: TextFieldConfiguration(
                    //       onChanged: (value) {
                    //         getLocations(value);
                    //       },
                    //       onTap: () {
                    //         Scrollable.ensureVisible(scrollKey.currentContext,
                    //             duration: const Duration(milliseconds: 1300));
                    //       },

                    //       //autofocus: false,
                    //       controller: typeAheadController,

                    //       decoration: InputDecoration(
                    //           contentPadding:
                    //               const EdgeInsets.only(left: 5.0, top: 5.0),
                    //           hintText: locationvalue ?? countryName,
                    //           border: const OutlineInputBorder()),
                    //     ),
                    //     suggestionsCallback: (pattern) async {
                    //       return await getLocations(pattern);
                    //     },
                    //     itemBuilder: (context, suggestion) {
                    //       return ListTile(
                    //         title: Text(places[suggestion]['formatted_address'].toString(),style: TextStyle(color: Colors.black),),
                    //         onTap: () async {
                    //           autoDetectCity = false;
                    //           SharedPreferences preferences =
                    //               await SharedPreferences.getInstance();
                    //           preferences.setString(
                    //               'cityName', suggestion['name'].toString());
                    //           preferences.setString(
                    //               'cityId', suggestion['id'].toString());
                    //           cityId = preferences.getString('cityId');
                    //           log("cityId--->$cityId");

                    //           setState(() {
                    //             locationvalue = suggestion['name'].toString();
                    //             selectCity = true;
                    //             findCity = false;
                    //           });
                    //           Navigator.pop(context);
                    //           getLatestAddition();
                    //         },
                    //       );
                    //     },
                    //     onSuggestionSelected: (suggestion) {
                    //       typeAheadController.text = suggestion;
                    //       setState(() {
                    //         locationvalue = suggestion['name'];
                    //       });
                    //     },
                    //   ),
                    // ),
                  ],
                ),
              ),
            );
          }));
        });
  }

  Future getLatestAdditionByUserLocation(
      String country, String state, String city) async {
    var url = BASE_URL + homeUrl;
    var body = {
      "country": country.toString(),
      "state": state,
      "city": city,
      // autoDetectCity == true ? getCityId.toString()??"" : cityIDd.toString()??"",
    };
    log('body---->$body');
    var response = await APIHelper.apiPostRequest(url, body);
    var result = jsonDecode(response);
    log("=====>q" + result.toString());

    if (result['ErrorCode'] == 0) {
      var list = result['Response']['latest_ads'] as List;
      setState(() {
        latestAdditionList.clear();
        var listdata =
            list.map((e) => LatestAdditionsModel.fromJson(e)).toList();
        latestAdditionList.addAll(listdata);
        loader = false;
      });
    }
    setState(() {
      loader = false;
    });
  }

  TextEditingController searchController = TextEditingController();
  List searchResult = [];

  bool sharedpref = false;

  int countryId = 0;
  String countryName = '';
  String userId = '';
  @override
  void initState() {
    super.initState();
    _getinitPref();
    getCounrtyId();
    searchController.clear();
  }

  _getinitPref() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    userId = preferences.getString("userid");
    print("userId---==->$userId");
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    height = MediaQuery.of(context).size.height;
    width = MediaQuery.of(context).size.width;
    return WillPopScope(
      onWillPop: () {
        return showDialog(
            context: context,
            builder: (context) => AlertDialog(
                  backgroundColor: Colors.white,
                  title: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text("Close this app?",
                          style: TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.bold)),
                      Image.asset(
                        "assets/images/logo.png",
                        scale: 25,
                      )
                    ],
                  ),
                  content: const Text("Are you sure you want to exit.",
                      style: TextStyle(
                          color: Colors.black, fontWeight: FontWeight.w500)),
                  actionsAlignment: MainAxisAlignment.spaceAround,
                  actions: [
                    ElevatedButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        child: const Text("Cancel")),
                    ElevatedButton(
                        onPressed: () {
                          SystemNavigator.pop();
                        },
                        child: const Text("Confirm"))
                  ],
                ));
      },
      child: Scaffold(
        key: _scaffoldKey,
        drawer: const NavigationDrawerWidget(),
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 2.0,
          title: Row(
            children: [
              Expanded(
                child: Image.asset('assets/images/logo.png', scale: 25),
              ),
              SizedBox(
                width: 10,
              ),
              Expanded(
                flex: 2,
                child: searchHeader != true
                    ? InkWell(
                        onTap: () async {
                          SharedPreferences prefs =
                              await SharedPreferences.getInstance();
                          String userID = prefs.getString("userid");
                          log("userId--->$userID");

                          if (userID == null || userID == "") {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => LoginScreen()));
                          } else {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => AddlistingScreen()));
                          }
                        },
                        child: Container(
                            alignment: Alignment.center,
                            height: 40,
                            width: 100,
                            decoration: BoxDecoration(
                              color: Appcolors.primaryColor,
                              borderRadius: BorderRadius.circular(100),
                            ),
                            child: Text("Post An Ad",
                                style: TextStyle(fontSize: 15))),
                      )
                    : Container(
                        alignment: Alignment.center,
                        height: 40,
                        width: size.width * 0.4,
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(50),
                            border: Border.all(color: Colors.grey)),
                        child: TextFormField(
                          readOnly: true,
                          onTap: () {
                            showDilogBoxForLocation(context);
                          },
                          decoration: InputDecoration(
                              border: InputBorder.none,
                              hintText: findCity == true
                                  ? "   ${address.text.toString()}"
                                  : selectCity == true
                                      ? "   $locationvalue"
                                      : "   $countryName",
                              suffixIcon: const Icon(
                                Icons.location_searching_sharp,
                                color: kContentColorLightTheme,
                              )),
                        ),
                      ),
              ),
              SizedBox(
                width: 5,
              ),
              Expanded(
                child: searchHeader == true
                    ? SizedBox()
                    : InkWell(
                        onTap: () {
                          searchHeader = true;
                          log(searchHeader.toString());
                        },
                        child: Container(
                          alignment: Alignment.topCenter,
                          height: 40,
                          width: 60,
                          decoration: BoxDecoration(
                              color: Appcolors.primaryColor,
                        
                            borderRadius: BorderRadius.circular(100),
                          ),
                          child: IconButton(
                            onPressed: () {
                              setState(() {
                                searchHeader = !searchHeader;
                                log(searchHeader.toString());
                              });
                            },
                            icon: Icon(
                              Icons.location_on_outlined,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
              )
            ],
          ),
          leading: Row(
            children: [
              IconButton(
                  onPressed: () async {
                    _scaffoldKey.currentState.openDrawer();
                  },
                  icon: const Icon(Icons.menu, color: kPrimaryColor)),
              //SizedBox(width: 2),
              //Image.asset('assets/images/logo.png', scale: 45),
            ],
          ),
          actions: [
            IconButton(
                onPressed: () async {
                  if (!sharedpref) {
                    Navigator.push(context,
                        MaterialPageRoute(builder: (context) => LoginScreen()));
                  } else {
                    DialogHelper.logout(context);
                  }
                },
                icon: !sharedpref
                    ? Image.asset('assets/images/user.png',
                        color: kPrimaryColor, scale: 1.2)
                        :SizedBox())
                    // : Image.asset('assets/images/power.png',
                    //     color: kPrimaryColor, scale: 1.2)),
          ],
       
        ),
        body: RefreshIndicator(
          onRefresh: () async {
            await Future.delayed(Duration(milliseconds: 1000));
            searchHeader = false;
            searchController.clear();
            // _getinitPref();
            getCounrtyId();
          },
          child: SingleChildScrollView(
            child: _check == false
                ? SizedBox(
                    height: size.height,
                    width: size.width,
                    child: const Center(child: CircularProgressIndicator()))
                : Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(7.0),
                        child: Container(
                            margin: const EdgeInsets.only(top: 5),
                            padding: const EdgeInsets.symmetric(
                                vertical: 0, horizontal: 16),
                            decoration: BoxDecoration(
                              color: Colors.indigo.shade50,
                              borderRadius:
                                  const BorderRadius.all(Radius.circular(5)),
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
                                   
                                  onPressed: () async {
                                    SharedPreferences prefs =
                                        await SharedPreferences.getInstance();
                                    String country = prefs.getString('country');
                                    String state = prefs.getString('state');
                                    String city = prefs.getString('city');
                                    if (searchController.text.isEmpty) {
                                      showToast("Please enter your search");
                                    } else {
                                      showLaoding(context);
                                      FocusScope.of(context).unfocus();
                                      var response = await http.post(
                                          Uri.parse(BASE_URL+"browse-ads"),
                                          body: jsonEncode({
                                            "country": country.toString(),
                                            "city": city == null || city == ""
                                                ? ""
                                                : city,
                                            "state":
                                                state == null || state == ""
                                                    ? ""
                                                    : state,
                                            // "search": "",
                                            "q": searchController.text
                                                .toString(),
                                          }),
                                          headers: {
                                            "Accept": "application/json",
                                            'Content-Type': 'application/json',
                                            'Authorization':
                                                'Bearer ${prefs.getString("token")}',
                                          });

                                      Navigator.of(context, rootNavigator: true)
                                          .pop();
                                      if (jsonDecode(
                                              response.body)['ErrorCode'] ==
                                          0) {
                                        if (jsonDecode(response.body)[
                                                    'ErrorMessage']
                                                .toString() ==
                                            "success") {
                                          List temp = [];
                                          temp.clear();
                                          temp.addAll(jsonDecode(response.body)[
                                              'Response']['leads']['data']);
                                          setState(() {});
                                          log(jsonDecode(response.body)[
                                                  'Response']['leads']['data']
                                              .toString());
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) =>
                                                  UserfinderDataScreen(
                                                cityId: cityId.toString(),
                                                getlocation: locationvalue,
                                                getcategory: categoryvalue,
                                                getcategoryslug:
                                                    categoryslugname,
                                                data: temp,
                                                finalLocation:
                                                    countryName.toString(),
                                                search: searchController.text
                                                    .toString(),
                                              ),
                                            ),
                                          );
                                        } else {
                                          setState(() {
                                            searchController.text = "";
                                          });
                                          // showToast(jsonDecode(
                                          //         response.body)['ErrorMessage']
                                          //     .toString());

                                          log("error1--->${jsonDecode(response.body)['ErrorMessage']}");
                                        }
                                      } else {
                                        setState(() {
                                          searchController.text = "";
                                        });
                                        // showToast(jsonDecode(
                                        //         response.body)['ErrorMessage']
                                        //     .toString());

                                        log("error2--->${jsonDecode(response.body)['ErrorMessage']}");
                                      }
                                    }
                                  },
                                  child: const Text("Search"),
                                  style: ButtonStyle(
                                    backgroundColor: MaterialStateProperty.all(Appcolors.secondaryColor),
                                    
                                      shape: MaterialStateProperty.all(
                                          RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(20.0),
                                  ))),
                                )
                              ],
                            )),
                      ),

                      SizedBox(
                        height: MediaQuery.of(context).size.height * 0.22,
                        width: double.infinity,
                        child: images.isEmpty || images.isEmpty
                            ? const Center(child: CircularProgressIndicator())
                            : Carousel(
                                dotSpacing: 15.0,
                                dotSize: 6.0,
                                dotIncreasedColor: kPrimaryColor,
                                dotBgColor: Colors.transparent,
                                indicatorBgPadding: 10.0,
                                dotPosition: DotPosition.bottomCenter,
                                images: images
                                    .map((item) => SizedBox(
                                        child: CachedNetworkImage(
                                            imageUrl: item, fit: BoxFit.fill)))
                                    .toList(),
                              ),
                      ),
                      SizedBox(
                        height: 20,
                      ),
                      Container(
                        margin: const EdgeInsets.symmetric(
                          horizontal: 10,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "Latest Additions",
                              style: TextStyle(
                                  color: kPrimaryColor,
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600),
                            ),
                            InkWell(
                              onTap: () {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) =>
                                            ViewAllLatestAddition(
                                              cityId: cityId.toString(),
                                            )));
                              },
                              child: Container(
                                alignment: Alignment.center,
                                height: 40,
                                width: 80,
                                decoration: BoxDecoration(
                              color: Appcolors.primaryColor,
                               
                                  borderRadius: BorderRadius.circular(
                                    20,
                                  ),
                                ),
                                child: Text(
                                  "View All",
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w600),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      latestAdditionList.isEmpty
                          ? Center(
                              child: Text("No Record Found !!"),
                            )
                          : loader == true
                              ? Center(
                                  child: CircularProgressIndicator(),
                                )
                              : SizedBox(
                                  height: latestAdditionList.length <= 2
                                      ? height * 0.22
                                      : height * 0.48,
                                  width: width,
                                  child: GridView.builder(
                                      physics: NeverScrollableScrollPhysics(),
                                      shrinkWrap: true,
                                      itemCount: latestAdditionList.length,
                                      itemBuilder:
                                          (BuildContext context, int index) =>
                                              latestAdditionWidget(
                                                  latestAdditionList[index]),
                                      gridDelegate:
                                          SliverGridDelegateWithFixedCrossAxisCount(
                                              crossAxisCount: 2,
                                              crossAxisSpacing: 1.0,
                                              mainAxisSpacing: 1.0)),
                                ),

                      SizedBox(
                        height: 10,
                      ),

                      // Padding(
                      //   key: scrollKey,
                      //   padding: const EdgeInsets.symmetric(
                      //       horizontal: 10, vertical: 20),
                      //   child: Row(
                      //     mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      //     children: [
                      //       Container(
                      //         height: 35,
                      //         width: size.width * 0.38,
                      //         alignment: Alignment.center,
                      //         child: TypeAheadField(
                      //           //hideOnLoading: false,
                      //           textFieldConfiguration: TextFieldConfiguration(
                      //             onTap: () {
                      //               Scrollable.ensureVisible(
                      //                   scrollKey.currentContext,
                      //                   duration: Duration(milliseconds: 1300));
                      //             },

                      //             //autofocus: false,
                      //             controller: typeAheadController,
                      //             decoration: InputDecoration(
                      //                 contentPadding: const EdgeInsets.only(
                      //                     left: 5.0, top: 5.0),
                      //                 hintText: locationvalue ?? "Search City",
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
                      //                 BorderRadius.all(Radius.circular(8))),
                      //         child: Padding(
                      //           padding: EdgeInsets.symmetric(horizontal: 8.0),
                      //           child: DropdownButton(
                      //             hint: const Text("Category",
                      //                 style: TextStyle(
                      //                     color: kPrimaryColor, fontSize: 12)),
                      //             value: categoryvalue,
                      //             isExpanded: true,
                      //             underline: Container(
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
                      //                         color: kPrimaryColor,
                      //                         fontSize: 12)),
                      //               );
                      //             }).toList(),
                      //             // After selecting the desired option,it will
                      //             // change button value to selected value
                      //             onChanged: (newValue) {
                      //               setState(() {
                      //                 categoryvalue = newValue;
                      //                 categorylistData.forEach((element) {
                      //                   if (element['title'].toString() ==
                      //                       categoryvalue) {
                      //                     categoryslugname =
                      //                         element['slug'].toString();
                      //                   }
                      //                 });
                      //               });
                      //             },
                      //           ),
                      //         ),
                      //       ),
                      //       InkWell(
                      //         onTap: () {
                      //           if (locationvalue != null) {
                      //             Navigator.push(
                      //                 context,
                      //                 MaterialPageRoute(
                      //                     builder: (context) =>
                      //                         UserfinderDataScreen(
                      //                             getlocation: locationvalue,
                      //                             getcategory: categoryvalue,
                      //                             getcategoryslug:
                      //                                 categoryslugname,
                      //                             data: []))).then((value) {
                      //               setState(() {
                      //                 typeAheadController.clear();
                      //               });
                      //               _getlocationbyUserlocation();
                      //             });
                      //           } else {
                      //             showToast("Please select location");
                      //           }
                      //         },
                      //         child: Container(
                      //           height: 35,
                      //           width: size.width * 0.20,
                      //           alignment: Alignment.center,
                      //           decoration: const BoxDecoration(
                      //               color: Colors.deepOrangeAccent,
                      //               borderRadius:
                      //                   BorderRadius.all(Radius.circular(8))),
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

                      // const Padding(
                      //   padding:
                      //       EdgeInsets.symmetric(vertical: 0, horizontal: 10),
                      //   child: Align(
                      //     alignment: Alignment.topLeft,
                      //     child: Text("Rent From Our Wide Range Of Categories",
                      //         style: TextStyle(
                      //             color: Colors.deepOrangeAccent, fontSize: 14)),
                      //   ),
                      // ),
                      // Padding(
                      //   padding:
                      //       EdgeInsets.symmetric(vertical: 10, horizontal: 10),
                      //   child: myProducts.length == 0 || myProducts.isEmpty
                      //       ? Center(child: CircularProgressIndicator())
                      //       : GridView.builder(
                      //           shrinkWrap: true,
                      //           physics: ClampingScrollPhysics(),
                      //           gridDelegate:
                      //               const SliverGridDelegateWithFixedCrossAxisCount(
                      //                   crossAxisCount: 3,
                      //                   crossAxisSpacing: 8.0,
                      //                   mainAxisSpacing: 8.0),
                      //           itemCount: 6,
                      //           itemBuilder: (BuildContext ctx, index) {
                      //             return InkWell(
                      //               onTap: () async {
                      //                 showLaoding(context);
                      //                 categorylistData.forEach((element) {
                      //                   if (element['title'].toString() ==
                      //                       category[index].toString()) {
                      //                     setState(() {
                      //                       categoryslugname =
                      //                           element['slug'].toString();
                      //                     });
                      //                   }
                      //                 });
                      //                 print(jsonEncode({
                      //                   "city_name": locationvalue,
                      //                   "category": categoryslugname,
                      //                   "exclude": "1",
                      //                   "search": ""
                      //                 }));
                      //                 var response = await http.post(
                      //                     Uri.parse(BASE_URL + filterUrl),
                      //                     body: jsonEncode({
                      //                       "city_name": locationvalue,
                      //                       "category": categoryslugname,
                      //                       "exclude": "1",
                      //                       "search": ""
                      //                     }),
                      //                     headers: {
                      //                       "Accept": "application/json",
                      //                       'Content-Type': 'application/json'
                      //                     });
                      //                 Navigator.of(context, rootNavigator: true)
                      //                     .pop();
                      //                 if (jsonDecode(
                      //                         response.body)['ErrorCode'] ==
                      //                     0) {
                      //                   Navigator.push(
                      //                       context,
                      //                       MaterialPageRoute(
                      //                           builder: (context) =>
                      //                               UserfinderDataScreen(
                      //                                   getlocation:
                      //                                       locationvalue,
                      //                                   getcategory:
                      //                                       category[index]
                      //                                           .toString(),
                      //                                   getcategoryslug:
                      //                                       categoryslugname,
                      //                                   data: jsonDecode(response
                      //                                           .body)['Response']
                      //                                       ['leads'])));
                      //                 } else {
                      //                   Fluttertoast.showToast(
                      //                       msg: "No result found",
                      //                       gravity: ToastGravity.CENTER);
                      //                 }
                      //               },
                      //               child: Card(
                      //                 elevation: 8.0,
                      //                 shape: RoundedRectangleBorder(
                      //                     borderRadius:
                      //                         BorderRadius.circular(12.0)),
                      //                 child: GridTile(
                      //                   footer: Container(
                      //                     decoration: const BoxDecoration(
                      //                         color: Color(0xFFFCFBFD),
                      //                         borderRadius: BorderRadius.only(
                      //                             bottomLeft: Radius.circular(12),
                      //                             bottomRight:
                      //                                 Radius.circular(12))),
                      //                     child: Padding(
                      //                       padding: const EdgeInsets.all(2.0),
                      //                       child: Text(category[index],
                      //                           textAlign: TextAlign.center,
                      //                           style: const TextStyle(
                      //                               color: Colors.black,
                      //                               fontSize: 12)),
                      //                     ),
                      //                   ),
                      //                   child: ClipRRect(
                      //                     borderRadius: const BorderRadius.all(
                      //                         Radius.circular(12)),
                      //                     child: Container(
                      //                       decoration: BoxDecoration(
                      //                           color: kPrimaryColor,
                      //                           borderRadius:
                      //                               BorderRadius.circular(15)),
                      //                       child: CachedNetworkImage(
                      //                         fit: BoxFit.cover,
                      //                         imageUrl: myProducts[index],
                      //                       ),
                      //                     ),
                      //                   ),
                      //                 ),
                      //               ),
                      //             );
                      //           }),
                      // ),
                      // Padding(
                      //   padding: const EdgeInsets.symmetric(vertical: 10),
                      //   child: Align(
                      //     alignment: Alignment.center,
                      //     child: InkWell(
                      //       onTap: () {
                      //         Navigator.of(context).push(MaterialPageRoute(
                      //             builder: (context) => AllCategoryScreen()));
                      //       },
                      //       child: Container(
                      //         width: size.width * 0.18,
                      //         height: 30,
                      //         alignment: Alignment.center,
                      //         decoration: const BoxDecoration(
                      //             color: Colors.deepOrangeAccent,
                      //             borderRadius:
                      //                 BorderRadius.all(Radius.circular(4.0))),
                      //         child: const Text("See All",
                      //             style: TextStyle(
                      //                 color: Colors.white, fontSize: 10)),
                      //       ),
                      //     ),
                      //   ),
                      // ),
                      SizedBox(
                        height: 10,
                      ),
                      // isSignedUp == 1 &&
                      //         trustedBadge == 1 &&
                      //         trustedBadgeApproval != "approved" &&
                      //         packageId != null
                      //     ? SizedBox(
                      //         height: size.height * 0.2,
                      //         width: size.width * 0.98,
                      //         child: Card(
                      //           elevation: 5,
                      //           child: Column(
                      //             children: const [
                      //               SizedBox(
                      //                 height: 10,
                      //               ),
                      //               Text(
                      //                 "Hi, User",
                      //                 style: TextStyle(
                      //                     fontSize: 20,
                      //                     fontWeight: FontWeight.bold),
                      //               ),
                      //               SizedBox(
                      //                 height: 10,
                      //               ),
                      //               Text(
                      //                 "Your Verification is Under process \nOur technical team contact you soon\n                    Happy Renting !!",
                      //                 style: TextStyle(
                      //                     fontSize: 20,
                      //                     fontWeight: FontWeight.bold),
                      //               ),
                      //             ],
                      //           ),
                      //         ),
                      //       )
                      //     : SizedBox(
                      //         height: 10,
                      //       ),
                      SizedBox(
                        height: 10,
                      ),
                      Container(
                        width: double.infinity,
                        color: kContainerColor,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(
                              height: MediaQuery.of(context).size.height * 0.40,
                              width: MediaQuery.of(context).size.width,
                              child: Padding(
                                padding: const EdgeInsets.only(
                                    left: 10.0,
                                    top: 10.0,
                                    right: 10.0,
                                    bottom: 0.0),
                                child: ClipRRect(
                                  borderRadius: const BorderRadius.all(
                                      Radius.circular(0.0)),
                                  child: CachedNetworkImage(
                                    imageUrl: todaydealsimage1,
                                    fit: BoxFit.fill,
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(
                              height: MediaQuery.of(context).size.height * 0.23,
                              width: MediaQuery.of(context).size.width,
                              child: Padding(
                                padding: const EdgeInsets.only(
                                    left: 10.0,
                                    top: 10.0,
                                    right: 10.0,
                                    bottom: 5.0),
                                child: ClipRRect(
                                  borderRadius: const BorderRadius.all(
                                      Radius.circular(0.0)),
                                  child: CachedNetworkImage(
                                    imageUrl: todaydealsimage2,
                                    fit: BoxFit.fill,
                                  ),
                                ),
                              ),
                            ),
                            Container(
                              height: MediaQuery.of(context).size.height * 0.23,
                              width: MediaQuery.of(context).size.width,
                              padding: const EdgeInsets.only(
                                  left: 10.0,
                                  top: 5.0,
                                  right: 10.0,
                                  bottom: 10.0),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  SizedBox(
                                    height: MediaQuery.of(context).size.height *
                                        0.21,
                                    width: MediaQuery.of(context).size.width *
                                        0.45,
                                    child: CachedNetworkImage(
                                      imageUrl: todaydealsimage3,
                                      fit: BoxFit.fill,
                                    ),
                                  ),
                                  SizedBox(
                                    height: MediaQuery.of(context).size.height *
                                        0.21,
                                    width: MediaQuery.of(context).size.width *
                                        0.45,
                                    child: CachedNetworkImage(
                                      imageUrl: todaydealsimage4,
                                      fit: BoxFit.fill,
                                    ),
                                  ),
                                ],
                              ),
                            )
                          ],
                        ),
                      ),
                      likedadproductlist.isEmpty || likedadproductlist.isEmpty
                          ? const SizedBox()
                          : const Padding(
                              padding: EdgeInsets.only(left: 15, top: 10),
                              child: Align(
                                alignment: Alignment.topLeft,
                                child: Text("You May Also Like",
                                    style: TextStyle(
                                        color: Colors.deepOrangeAccent,
                                        fontSize: 14,
                                        fontWeight: FontWeight.w700)),
                              ),
                            ),
                      likedadproductlist.isEmpty || likedadproductlist.isEmpty
                          ? const SizedBox()
                          : Padding(
                              padding:
                                  EdgeInsets.only(left: 15, top: 10, right: 15),
                              child: likedadproductlist.isEmpty
                                  ? SizedBox(height: 0)
                                  : GridView.builder(
                                      shrinkWrap: true,
                                      itemCount: likedadproductlist.length,
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
                                                            productid:
                                                                likedadproductlist[
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
                                                  placeholder: (context, url) =>
                                                      Image.asset(
                                                          'assets/images/no_image.jpg'),
                                                  errorWidget: (context, url,
                                                          error) =>
                                                      Image.asset(
                                                          'assets/images/no_image.jpg'),
                                                  fit: BoxFit.cover,
                                                  imageUrl: devImage +
                                                      likedadproductlist[index][
                                                              'upload_base_path']
                                                          .toString() +
                                                      likedadproductlist[index]
                                                              ['file_name']
                                                          .toString(),
                                                ),
                                                const SizedBox(height: 5.0),
                                                Padding(
                                                  padding:
                                                      const EdgeInsets.only(
                                                          left: 5.0,
                                                          right: 15.0),
                                                  child: Align(
                                                    alignment:
                                                        Alignment.topLeft,
                                                    child: Text(
                                                        likedadproductlist[
                                                                index]['title']
                                                            .toString(),
                                                        maxLines: 2,
                                                        style: const TextStyle(
                                                            color: Colors.black,
                                                            fontWeight:
                                                                FontWeight.w700,
                                                            fontSize: 14)),
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
                                                            "Starting from ${likedadproductlist[index]['currency'].toString()} ${likedadproductlist[index]['prices'][0]['price'].toString()}",
                                                            style: const TextStyle(
                                                                color:
                                                                    kPrimaryColor,
                                                                fontSize: 12)),
                                                      ),
                                                      const Icon(
                                                          Icons.add_box_rounded,
                                                          color: kPrimaryColor)
                                                    ],
                                                  ),
                                                )
                                              ],
                                            ),
                                          ),
                                        );
                                      })),
                      Container(
                        height: MediaQuery.of(context).size.height * 0.25,
                        width: MediaQuery.of(context).size.width,
                        decoration: const BoxDecoration(
                          color: Color(0xFF00008B),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              width: width * 0.89,
                              alignment: Alignment.center,
                              // margin:
                              //     const EdgeInsets.symmetric(horizontal: 20),
                              child: const Text("Join 1000+ Users And Start",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 20,
                                  )),
                            ),
                            Container(
                              width: width * 0.89,
                              alignment: Alignment.center,
                              // margin:
                              //     const EdgeInsets.symmetric(horizontal: 20),
                              child:
                                  const Text("Uploading Your Products For Free",
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 20,
                                      )),
                            ),
                            const SizedBox(
                              height: 10,
                            ),
                            userId == null || userId == ""
                                ? InkWell(
                                    onTap: () {
                                      Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) =>
                                                  LoginScreen()));
                                    },
                                    child: Container(
                                      alignment: Alignment.center,
                                      height:
                                          MediaQuery.of(context).size.height *
                                              0.05,
                                      width: MediaQuery.of(context).size.width *
                                          0.45,
                                      decoration: BoxDecoration(
                                          color: Colors.deepOrangeAccent,
                                          borderRadius:
                                              BorderRadius.circular(50)),
                                      child: const Text("Login",
                                          style: TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 18)),
                                    ),
                                  )
                                : InkWell(
                                    onTap: () {
                                      Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) =>
                                                  const AddlistingScreen()));
                                      // if (isSignedUp == 1 &&
                                      //     trustedBadge == 0 &&
                                      //     trustedBadgeApproval == "approved" &&
                                      //     packageId != null) {
                                      //   showToast("Verification Under Process");
                                      // } else {

                                      // }
                                    },
                                    child: Container(
                                      alignment: Alignment.center,
                                      height:
                                          MediaQuery.of(context).size.height *
                                              0.05,
                                      width: MediaQuery.of(context).size.width *
                                          0.45,
                                      decoration: BoxDecoration(
                              color: Appcolors.primaryColor,
                                  
                                          borderRadius:
                                              BorderRadius.circular(50)),
                                      child: const Text("Upload",
                                          style: TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 18)),
                                    ),
                                  ),
                            const SizedBox(
                              height: 10,
                            ),
                          ],
                        ),
                      ),
                      topsellingCategoreslist.isEmpty ||
                              topsellingCategoreslist.isEmpty
                          ? SizedBox()
                          : Container(
                              margin:
                                  const EdgeInsets.symmetric(horizontal: 10),
                              child: InkWell(
                                onTap: () {
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) =>
                                              TopSellingCategoriesScreen()));
                                },
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Padding(
                                      padding: EdgeInsets.only(left: 5, top: 5),
                                      child: Align(
                                        alignment: Alignment.topLeft,
                                        child: Text("Top Selling Categories",
                                            style: TextStyle(
                                                color: Colors.blue[900],
                                                fontSize: 18,
                                                fontWeight: FontWeight.w700)),
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.only(top: 8.0),
                                      child: Container(
                                        alignment: Alignment.center,
                                        height: 40,
                                        width: 80,
                                        decoration: BoxDecoration(
                              color: Appcolors.primaryColor,
                                         
                                          borderRadius: BorderRadius.circular(
                                            20,
                                          ),
                                        ),
                                        child: Text(
                                          "View All",
                                          style: TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.w600),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                      topsellingCategoreslist.isEmpty ||
                              topsellingCategoreslist.isEmpty
                          ? SizedBox()
                          : Padding(
                              padding:
                                  EdgeInsets.only(left: 15, top: 10, right: 15),
                              child: topsellingCategoreslist.isEmpty ||
                                      topsellingCategoreslist.isEmpty
                                  ? Center(child: CircularProgressIndicator())
                                  : GridView.builder(
                                      shrinkWrap: true,
                                      physics:
                                          const NeverScrollableScrollPhysics(),
                                      gridDelegate:
                                          const SliverGridDelegateWithFixedCrossAxisCount(
                                              crossAxisCount: 2,
                                              crossAxisSpacing: 8.0,
                                              mainAxisSpacing: 8.0),
                                      itemCount: topsellingCategoreslist.length,
                                      itemBuilder: (BuildContext ctx, index) =>
                                          topSellingCategoriesWidget(
                                              topsellingCategoreslist[index]))),

                      const SizedBox(height: 10),
                      Container(
                        padding: const EdgeInsets.only(bottom: 5),
                        width: double.infinity,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 10),
                            Padding(
                              padding: EdgeInsets.symmetric(horizontal: 10),
                              child: Text("Today's Special Deals",
                                  style: TextStyle(
                              color: Appcolors.secondaryColor,
                                      
                                      fontSize: 18,
                                      fontWeight: FontWeight.w600)),
                            ),
                            const SizedBox(height: 5),
                            Container(
                              width: double.infinity,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  SizedBox(
                                    height: MediaQuery.of(context).size.height *
                                        0.40,
                                    width: MediaQuery.of(context).size.width,
                                    child: Padding(
                                      padding: const EdgeInsets.only(
                                          left: 10.0,
                                          top: 10.0,
                                          right: 10.0,
                                          bottom: 0.0),
                                      child: ClipRRect(
                                        borderRadius: const BorderRadius.all(
                                            Radius.circular(0.0)),
                                        child: CachedNetworkImage(
                                          imageUrl: bottomimage1,
                                          fit: BoxFit.fill,
                                        ),
                                      ),
                                    ),
                                  ),
                                  SizedBox(
                                    height: MediaQuery.of(context).size.height *
                                        0.23,
                                    width: MediaQuery.of(context).size.width,
                                    child: Padding(
                                      padding: const EdgeInsets.only(
                                          left: 10.0,
                                          top: 10.0,
                                          right: 10.0,
                                          bottom: 5.0),
                                      child: ClipRRect(
                                        borderRadius: const BorderRadius.all(
                                            Radius.circular(0.0)),
                                        child: CachedNetworkImage(
                                          imageUrl: bottomimage2,
                                          fit: BoxFit.fill,
                                        ),
                                      ),
                                    ),
                                  ),
                                  Container(
                                    height: MediaQuery.of(context).size.height *
                                        0.23,
                                    width: MediaQuery.of(context).size.width,
                                    padding: const EdgeInsets.only(
                                        left: 10.0,
                                        top: 5.0,
                                        right: 10.0,
                                        bottom: 10.0),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        SizedBox(
                                          height: MediaQuery.of(context)
                                                  .size
                                                  .height *
                                              0.21,
                                          width: MediaQuery.of(context)
                                                  .size
                                                  .width *
                                              0.45,
                                          child: CachedNetworkImage(
                                            imageUrl: bottomimage3,
                                            fit: BoxFit.fill,
                                          ),
                                        ),
                                        SizedBox(
                                          height: MediaQuery.of(context)
                                                  .size
                                                  .height *
                                              0.21,
                                          width: MediaQuery.of(context)
                                                  .size
                                                  .width *
                                              0.45,
                                          child: CachedNetworkImage(
                                            imageUrl: bottomimage4,
                                            fit: BoxFit.fill,
                                          ),
                                        ),
                                      ],
                                    ),
                                  )
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 10),
                      Column(
                        children: myfeaturedcategories
                            .map((e) => e['ads'].length != 0
                                ? Column(
                                    children: [
                                      Padding(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 8.0, vertical: 5.0),
                                        child: Align(
                                            alignment: Alignment.topLeft,
                                            child: Text(e['title'].toString(),
                                                style: const TextStyle(
                                                    color: Colors.black,
                                                    fontSize: 16,
                                                    fontWeight:
                                                        FontWeight.w500))),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 8.0, vertical: 5.0),
                                        child: GridView.builder(
                                            shrinkWrap: true,
                                            physics: ClampingScrollPhysics(),
                                            itemCount: e['ads'].length,
                                            gridDelegate:
                                                const SliverGridDelegateWithFixedCrossAxisCount(
                                                    crossAxisCount: 2,
                                                    crossAxisSpacing: 4.0,
                                                    mainAxisSpacing: 4.0,
                                                    childAspectRatio: 1.0,),
                                            itemBuilder: (context, gridindex) {
                                              return InkWell(
                                                onTap: () {
                                                  Navigator.push(
                                                      context,
                                                      MaterialPageRoute(
                                                          builder: (context) =>
                                                              ProductDetailScreen(
                                                                  productid: e['ads']
                                                                              [
                                                                              gridindex]
                                                                          ['id']
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
                                                        imageUrl: devImage +
                                                            e['ads'][gridindex][
                                                                        'images'][0]
                                                                    [
                                                                    'upload_base_path']
                                                                .toString() +
                                                            e['ads'][gridindex][
                                                                        'images'][0]
                                                                    [
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
                                                              e['ads'][gridindex]
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
                                                      e['ads'].length != 0
                                                          ? const SizedBox(
                                                              height: 5.0)
                                                          : SizedBox(),
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
                                                                      0.28,
                                                              child: Text(
                                                                  "Starting from ${e['ads'][gridindex]['currency'].toString()} ${e['ads'][gridindex]['prices'][0]['price'].toString()}",
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
                                            }),
                                      )
                                    ],
                                  )
                                : const SizedBox())
                            .toList(),
                      ),
                      Column(
                        children: mysubfeaturedcategories
                            .map((e) => e['ads'].length != 0
                                ? Column(
                                    children: [
                                      Padding(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 8.0, vertical: 5.0),
                                        child: Align(
                                            alignment: Alignment.topLeft,
                                            child: Text(e['title'].toString(),
                                                style: const TextStyle(
                                                    color: Colors.black,
                                                    fontSize: 16,
                                                    fontWeight:
                                                        FontWeight.w500))),
                                      ),
                                      Padding(
                                        padding: EdgeInsets.symmetric(
                                            horizontal: 8.0, vertical: 5.0),
                                        child: GridView.builder(
                                            shrinkWrap: true,
                                            itemCount: e['ads'].length,
                                            physics: ClampingScrollPhysics(),
                                            gridDelegate:
                                                const SliverGridDelegateWithFixedCrossAxisCount(
                                                    crossAxisCount: 2,
                                                    crossAxisSpacing: 4.0,
                                                    mainAxisSpacing: 4.0,
                                                    childAspectRatio: 1.0),
                                            itemBuilder: (context, gindex) {
                                              return InkWell(
                                                onTap: () {
                                                  // print(e);
                                                  Navigator.push(
                                                      context,
                                                      MaterialPageRoute(
                                                          builder: (context) =>
                                                              ProductDetailScreen(
                                                                  productid: e['ads']
                                                                              [
                                                                              gindex]
                                                                          ['id']
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
                                                        placeholder: (context,
                                                                url) =>
                                                            Image.asset(
                                                                'assets/images/no_image.jpg'),
                                                        errorWidget: (context,
                                                                url, error) =>
                                                            Image.asset(
                                                                'assets/images/no_image.jpg'),
                                                        fit: BoxFit.cover,
                                                        imageUrl: devImage +
                                                            e['ads'][gindex][
                                                                        'images'][0]
                                                                    [
                                                                    'upload_base_path']
                                                                .toString() +
                                                            e['ads'][gindex][
                                                                        'images'][0]
                                                                    [
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
                                                              e['ads'][gindex]
                                                                      ['title']
                                                                  .toString(),
                                                              maxLines: 1,
                                                              style: const TextStyle(
                                                                  color: Colors
                                                                      .black,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w700,
                                                                  fontSize:
                                                                      14)),
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
                                                                      0.23,
                                                              child: Text(
                                                                  "Starting from ${e['ads'][gindex]['currency'].toString()} ${e['ads'][gindex]['prices'][0]['price'].toString()}",
                                                                  style: const TextStyle(
                                                                      color:
                                                                          kPrimaryColor,
                                                                      fontSize:
                                                                          12)),
                                                            ),
                                                            IconButton(
                                                                iconSize: 28,
                                                                onPressed:
                                                                    () {},
                                                                icon: const Icon(
                                                                    Icons
                                                                        .add_box_rounded,
                                                                    color:
                                                                        kPrimaryColor))
                                                          ],
                                                        ),
                                                      )
                                                    ],
                                                  ),
                                                ),
                                              );
                                            }),
                                      )
                                    ],
                                  )
                                : SizedBox())
                            .toList(),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(
                            left: 10.0, top: 5.0, bottom: 5.0, right: 10.0),
                        child: SizedBox(
                          height: 200,
                          width: double.infinity,
                          child: Container(
                            child: CachedNetworkImage(
                                fit: BoxFit.cover, imageUrl: bottomsingleimage),
                            decoration: BoxDecoration(
                                color: Colors.amber,
                                borderRadius: BorderRadius.circular(15)),
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

  Widget topSellingCategoriesWidget(TopSellingCatgegoriesModel item) {
    return InkWell(
      onTap: () async {
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => TopSellingCategories(
                      category: item.slug.toString(),
                    )));
      },
      child: Card(
        elevation: 8.0,
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
        child: GridTile(
          footer: Container(
            decoration: const BoxDecoration(
                color: Color(0xFFFCFBFD),
                borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(12),
                    bottomRight: Radius.circular(12))),
            child: Padding(
              padding: const EdgeInsets.all(4.0),
              child: Text(item.title,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.black, fontSize: 12)),
            ),
          ),
          child: ClipRRect(
            borderRadius: const BorderRadius.all(Radius.circular(12)),
            child: Container(
              decoration: BoxDecoration(
                  color: kPrimaryColor,
                  borderRadius: BorderRadius.circular(15)),
              child: CachedNetworkImage(
                  fit: BoxFit.cover, imageUrl: imagepath + item.image),
            ),
          ),
        ),
      ),
    );
  }

  Widget latestAdditionWidget(LatestAdditionsModel item) {
    return InkWell(
      onTap: () {
        Navigator.push(
            context,
            MaterialPageRoute(
              builder: ((context) =>
                  ProductDetailScreen(productid: item.id.toString())),
            ));
      },
      child: Container(
        alignment: Alignment.centerLeft,
        margin: const EdgeInsets.symmetric(horizontal: 10),
        child: Column(
          children: [
            SizedBox(
              height: 10,
            ),
            Container(
              height: height * 0.16,
              width: width * 0.5,
              decoration: BoxDecoration(
                  image: DecorationImage(
                image: NetworkImage(devImage +
                    item.uploadBasePath.toString() +
                    item.fileName.toString()),
                fit: BoxFit.cover,
              )),
            ),
            SizedBox(
              height: 10,
            ),
            Container(
                width: width * 0.5,
                alignment: Alignment.centerLeft,
                child: Text(
                  item.title,
                  style: TextStyle(fontWeight: FontWeight.w600),
                  maxLines: 1,
                )),
            SizedBox(
              height: 20,
              width: width * 0.5,
              child: GridView.builder(
                  physics: NeverScrollableScrollPhysics(),
                  itemCount: item.prices.length,
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 1,
                  ),
                  itemBuilder: (BuildContext context, int index) {
                    var i = item.prices[index];
                    return Column(
                      children: [
                        Container(
                            height: 20,
                            width: width * 0.5,
                            alignment: Alignment.centerLeft,
                            child: Text(
                              "Starting From INR " + i.price.toString(),
                              style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 13,
                                  color: Colors.grey),
                            )),
                      ],
                    );
                  }),
            ),
          ],
        ),
      ),
    );
  }

  Future getLatestAddition() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    String country;
    String city;
    String state;

    setState(() {
      country = preferences.getString('country');
      city = preferences.getString('city');
      state = preferences.getString('state');

      print('cityId--->$city');

      loader = true;
    });

    var url = BASE_URL + homeUrl;
    var body = {
      "country": country.toString(),
      "city": city == null || city == "" ? "" : city,
      "state": state == null || state == "" ? "" : state,
      // autoDetectCity == true ? getCityId.toString()??"" : cityIDd.toString()??"",
    };
    print('body---->$body');
    var response = await APIHelper.apiPostRequest(url, body);
    var result = jsonDecode(response);
    print("=====>q" + result.toString());

    if (result['ErrorCode'] == 0) {
      var list = result['Response']['latest_ads'] as List;
      print("\n\n");
      setState(() {
        latestAdditionList.clear();
        var listdata =
            list.map((e) => LatestAdditionsModel.fromJson(e)).toList();
        latestAdditionList.addAll(listdata);
        print(latestAdditionList);
        loader = false;
      });
    }
    setState(() {
      loader = false;
    });
  }

  Future _getData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (prefs.getString('userid') == null || prefs.getString('userid') == "") {
      setState(() {
        sharedpref = false;
      });
    } else {
      setState(() {
        sharedpref = true;
      });
    }
    int cId = prefs.getInt('countryId');
    log('--->$cId');
    final body = {
      "country": cId.toString(),
      // "state": prefs.getString('state'),
      "city": prefs.getString('city'),
    };
    log("body--->$body");
    var response = await http
        .post(Uri.parse(BASE_URL + homeUrl), body: jsonEncode(body), headers: {
      "Accept": "application/json",
      'Content-Type': 'application/json',
      'Authorization': 'Bearer ${prefs.getString("token")}',
    });
    if (response.statusCode == 200) {
      var list = jsonDecode(response.body)['Response']['top_selling_categories']
          as List;
      setState(() {
        topsellingCategoreslist.clear();
        var listdata =
            list.map((e) => TopSellingCatgegoriesModel.fromJson(e)).toList();
        topsellingCategoreslist.addAll(listdata);
        loader = false;
      });
      setState(() {
        images.clear();
        location.clear();
        category.clear();
        myProducts.clear();
        mytopcategories.clear();

        jsonDecode(response.body)['Response']['slider'].forEach((element) {
          images.add(devImage + element['value'].toString());
        });

        // jsonDecode(response.body)['Response']['cities'].forEach((element) {
        //   location.add(element['name'].toString());
        // });

        // categorylistData
        //     .addAll(jsonDecode(response.body)['Response']['categories']);

        // jsonDecode(response.body)['Response']['categories'].forEach((element) {
        //   categoryslug.add(element['slug'].toString());
        //   category.add(element['title'].toString());
        //   myProducts.add(imagepath + element['image'].toString());
        // });

        // mytopcategorieslistData.addAll(
        //     jsonDecode(response.body)['Response']['top_selling_categories']);
        // jsonDecode(response.body)['Response']['top_selling_categories']
        //     .forEach((element) {
        //   mytopcategoriesname.add(element['title'].toString());
        //   mytopcategories.add(imagepath + element['image'].toString());
        //   mytopcategorieslug.add(element['slug'].toString());

        // });

        // myfeaturedcategories.addAll(
        //     jsonDecode(response.body)['Response']['featured_categories']);
        // mysubfeaturedcategories.addAll(
        //     jsonDecode(response.body)['Response']['featured_subcategories']);
        // jsonDecode(response.body)['Response']['featured_categories'].forEach((element){
        //     featuredname.add(element['title'].toString());
        //     myfeaturedcategories.add(imagepath + element['image'].toString());
        // });

        // likedadproductlist
        //     .addAll(jsonDecode(response.body)['Response']['You_may_also_like']);

        // print(jsonDecode(response.body)['Response']['today_special_deals']);
        todaydealsimage1 = devImage +
            jsonDecode(response.body)['Response']['today_special_deals']
                    ['mid_banner_1']['value']
                .toString();
        todaydealsimage2 = devImage +
            jsonDecode(response.body)['Response']['today_special_deals']
                    ['mid_banner_2']['value']
                .toString();
        todaydealsimage3 = devImage +
            jsonDecode(response.body)['Response']['today_special_deals']
                    ['mid_banner_3']['value']
                .toString();
        todaydealsimage4 = devImage +
            jsonDecode(response.body)['Response']['today_special_deals']
                    ['mid_banner_4']['value']
                .toString();

        bottomimage1 = devImage +
            jsonDecode(response.body)['Response']['today_special_deals']
                    ['bottom_banner_1']['value']
                .toString();
        bottomimage2 = devImage +
            jsonDecode(response.body)['Response']['today_special_deals']
                    ['bottom_banner_2']['value']
                .toString();
        bottomimage3 = devImage +
            jsonDecode(response.body)['Response']['today_special_deals']
                    ['bottom_banner_3']['value']
                .toString();
        bottomimage4 = devImage +
            jsonDecode(response.body)['Response']['today_special_deals']
                    ['bottom_banner_4']['value']
                .toString();

        bottomsingleimage = devImage +
            jsonDecode(response.body)['Response']['today_special_deals']
                    ['bottom_banner_single']['value']
                .toString();

        _check = true;
      });
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
      if (json.decode(response.body)['Response'] != null) {
        prefs.setString(
            'profile', devImage + data['User']['avatar_path'].toString());
        prefs.setString('name', data['User']['name'].toString());
        prefs.setString('email', data['User']['email'].toString());
        prefs.setString('mobile', data['User']['mobile'].toString());
        prefs.setString('userquickid', data['User']['quickblox_id'].toString());
        prefs.setString(
            'quicklogin', data['User']['quickblox_email'].toString());
        prefs.setString(
            'quickpassword', data['User']['quickblox_password'].toString());

        loggedIn = prefs.getBool('logged_in');
        isSignedUp = data['User']['is_signup_complete'];
        trustedBadge = data['User']['trusted_badge'];
        trustedBadgeApproval = data['User']['trusted_badge_approval'];
        packageId = data['User']['package_id'];

        log("---->${data['User']['quickblox_email']}");

        log("login or not---->$loggedIn");
      }
    } else {
      throw Exception('Failed to get data due to ${response.body}');
    }
  }

  _getlocationbyUserlocation() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (prefs.getString('city') != null || prefs.getString('city') != "") {
      setState(() {
        locationvalue = prefs.getString('city');
        log("Location Value" + locationvalue.toString());
        currentCity = locationvalue;
      });
    }
  }

  bool showData = false;
  bool getCurrentLocation = false;
  List places = [];
  var placecounts = 0;
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

  Future getCounrtyId() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      countryName = prefs.getString('country');
    });
    print("countryName--->$countryName");
    var url = Apis.countryByNameApi;
    var body = {
      "country_name": countryName.toString(),
    };

    var response = await APIHelper.apiPostRequest(url, body);
    var result = jsonDecode(response);

    if (result['ErrorMessage'] == "success") {
      countryId = result['Response']['country']['id'];
      print("GetCountryId---->${countryId.toString()}");
      prefs.setInt('countryId', countryId);
      print("get cId---->" + prefs.getInt('countryId').toString());
      _getData();
      getLatestAddition();
      // _getprofileData();

      // _getlocationbyUserlocation();
    }
  }

  int getCityId = 0;
  Future getUpdtaeSearchLocation() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    int countryID;
    setState(() {
      countryID = prefs.getInt('countryId');
      log("---->$countryID");
    });

    var url = Apis.updtaeSearchLocationApi;
    var body = {
      "country": countryID.toString(),
      "city": address.text.toString(),
    };
    var response = await APIHelper.apiPostRequest(url, body);
    var result = jsonDecode(response);

    if (result['ErrorCode'] == 0) {
      getCityId = result['Response']['id'];
      prefs.setString('cityId', getCityId.toString());
      log(prefs.getString('cityId'));
      log("cityI--->${getCityId.toString()}");
      getLatestAddition();
    }
  }
}
