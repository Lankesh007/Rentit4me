// ignore_for_file: prefer_const_constructors, prefer_interpolation_to_compose_strings, must_be_immutable, no_logic_in_create_state, unused_field, use_build_context_synchronously, missing_return, deprecated_member_use

import 'dart:convert';
import 'dart:developer';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:date_time_picker/date_time_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:html/parser.dart';
import 'package:http/http.dart' as http;
import 'package:rentit4me_new/helper/loader.dart';
import 'package:rentit4me_new/models/people_also_like_model.dart';
import 'package:rentit4me_new/network/api.dart';
import 'package:rentit4me_new/themes/constant.dart';
import 'package:rentit4me_new/views/advertiser_profile_screen.dart';
import 'package:rentit4me_new/views/conversation.dart';
import 'package:rentit4me_new/views/home_screen.dart';
import 'package:rentit4me_new/views/login_screen.dart';
import 'package:rentit4me_new/views/make_edit_offer.dart';
import 'package:rentit4me_new/widgets/api_helper.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProductDetailScreen extends StatefulWidget {
  String productid;
  ProductDetailScreen({Key key, this.productid}) : super(key: key);

  @override
  State<ProductDetailScreen> createState() =>
      _ProductDetailScreenState(productid);
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  String productid;

  _ProductDetailScreenState(this.productid);

  String productname;
  String productprice;
  String description;
  String securitydeposit;
  String addedbyid;
  String addedby;
  String boostpack;
  String renttype;
  String renttypeid;
  String useramount;
  bool apiLoading = false;
  String queryId;
  String address;
  String price;
  String email;
  bool _checkData = false;
  bool _checkuser = false;
  String renttypename;
  String renteramount;
  String productamount;
  String securityamount;
  String negotiable;
  double totalrent = 0;
  double totalsecurity = 0;
  double finalamount = 0;
  double conviencechargeper = 0;
  double conviencevalue = 0;
  String days;
  List<dynamic> rentpricelist = [];
  List<String> renttypelist = [];
  Map<String, dynamic> likedadproductlist = {};
  String productQty;
  String startDate = "From Date";
  String actionbtn;
  String capitalize(str) {
    return "${str[0].toUpperCase()}${str.substring(1).toLowerCase()}";
  }

  String productimage = "";

  String userid;
  int usertype;
  int trustedbadge;
  String trustedbadgeapproval;
  int kyc = 0;
  String trustedBadge = '';

  String appId = "96417";
  String authKey = "BmYxKrbn3HDthbc";
  String authSecret = "XRfs7bw3Y9H4yMc";
  String accountKey = "hr2cuVsMyCZXsZMEE32H";

  List productimages = [];
  List<dynamic> location = [];
  List<dynamic> category = [];
  List<dynamic> categorylistData = [];

  final TextEditingController useramountController = TextEditingController();
  final TextEditingController durationController = TextEditingController();
  final TextEditingController quantityContoller = TextEditingController();

  GoogleMapController googleMapController;

  static const CameraPosition initialCameraPosition = CameraPosition(
      target: LatLng(37.42796133580664, -122.085749655962), zoom: 14);

  Set<Marker> markers = {};

  @override
  void initState() {
    _getData();
    getPeopleAlsoLike();

    super.initState();
    _getPrefData();
    initializeDateFormatting();
    _getproductDetail(productid);
    _getcheckapproveData();
    _getmakeoffer(productid);

    // _getgooglelocation();
  }

  int loggedUserId = 0;

  _getPrefData() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    String userid = preferences.getString("userid");

    loggedUserId = int.parse(userid);
    log("userid-==-->$loggedUserId");
  }

  _getgooglelocation() async {
    Position position = await _determinePosition();

    googleMapController.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(
          target: LatLng(position.latitude, position.longitude),
          zoom: 14,
        ),
      ),
    );
    markers.clear();
    markers.add(
      Marker(
        markerId: const MarkerId('currentLocation'),
        position: LatLng(position.latitude, position.longitude),
      ),
    );
    setState(() {});
  }

  // void init() async {
  //   //print(appId);
  //   //print(authKey);
  //   //print(authSecret);
  //   ////print(accountKey);
  //   try {
  //     await QB.settings.init(appId, authKey, authSecret, accountKey);
  //     mylogin();
  //   } on PlatformException catch (e) {
  //     // print(e);
  //     Fluttertoast.showToast(msg: e.toString());
  //   }
  // }

  // void mylogin() async {
  //   SharedPreferences prefs = await SharedPreferences.getInstance();
  //   ////print(prefs.getString('quicklogin'));
  //   ////print(prefs.getString('quickpassword'));
  //   try {
  //     QBLoginResult result = await QB.auth.login(
  //         prefs.getString('quicklogin'), prefs.getString('quickpassword'));
  //     //_connectnow();
  //   } on PlatformException catch (e) {
  //     // Some error occurred, look at the exception message for more details
  //   }
  // }
  double height = 0;
  double width = 0;

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;

    height = MediaQuery.of(context).size.height;
    width = MediaQuery.of(context).size.width;

    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: kContentColorDarkTheme,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 2.0,
        leading: InkWell(
            onTap: () {
              Navigator.of(context).pop();
            },
            child: Icon(
              Icons.arrow_back,
              color: kPrimaryColor,
            )),
        title: Text("Details", style: TextStyle(color: kPrimaryColor)),
        centerTitle: true,
      ),
      body: apiLoading == true
          ? Center(
              child: CircularProgressIndicator(),
            )
          : productimages.isEmpty
              ? Center(
                  child: Text(
                    "No data found !!",
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                  ),
                )
              : SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(
                          height: 300,
                          width: double.infinity,
                          child: CachedNetworkImage(
                            imageUrl: productimage,
                            fit: BoxFit.fill,
                            errorWidget: (context, url, error) =>
                                Image.asset('assets/images/no_image.jpg'),
                          ),
                        ),
                        Container(
                          height: 80,
                          padding: EdgeInsets.only(top: 5),
                          width: size.width,
                          child: ListView.separated(
                              shrinkWrap: true,
                              separatorBuilder:
                                  (BuildContext context, int index) =>
                                      const SizedBox(width: 10),
                              itemCount: productimages.length,
                              scrollDirection: Axis.horizontal,
                              itemBuilder: (context, index) {
                                return InkWell(
                                  onTap: () {
                                    setState(() {
                                      productimage = devImage +
                                          productimages[index]
                                                  ['upload_base_path']
                                              .toString() +
                                          productimages[index]['file_name']
                                              .toString();
                                    });
                                  },
                                  child: SizedBox(
                                    height: 55,
                                    width: size.width * 0.30,
                                    child: CachedNetworkImage(
                                      imageUrl: devImage +
                                          productimages[index]
                                              ['upload_base_path'] +
                                          productimages[index]['file_name'],
                                      fit: BoxFit.fill,
                                    ),
                                  ),
                                );
                              }),
                        ),
                        SizedBox(
                          height: 20,
                        ),
                        Text(
                          "Ad Id : $adId",
                          style: TextStyle(
                              fontSize: 15, fontWeight: FontWeight.w600),
                        ),
                        SizedBox(
                          height: 5,
                        ),
                        Divider(
                          thickness: 0.9,
                          height: 30,
                        ),

                        Text(
                          productname,
                          style: TextStyle(
                              color: Colors.black,
                              fontSize: 22,
                              fontWeight: FontWeight.bold),
                        ),

                        SizedBox(height: 10.0),
                        Align(
                            alignment: Alignment.topLeft,
                            child: renttype == null ||
                                    renttype == "" ||
                                    renttype == "null"
                                ? Text(productprice,
                                    style: TextStyle(
                                        color: Colors.black,
                                        fontSize: 16,
                                        fontWeight: FontWeight.w500))
                                : Text(productprice,
                                    style: TextStyle(
                                        color: Colors.black,
                                        fontSize: 16,
                                        fontWeight: FontWeight.w500))),
                        SizedBox(height: 15.0),
                        Align(
                            alignment: Alignment.topLeft,
                            child: Row(
                              children: [
                                Text("Security Deposit :",
                                    style: TextStyle(
                                        color: Colors.deepOrange,
                                        fontSize: 16,
                                        fontWeight: FontWeight.w500)),
                                Text(" INR $securitydeposit",
                                    style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w500)),
                              ],
                            )),
                        SizedBox(height: 10.0),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Align(
                                alignment: Alignment.topLeft,
                                child: InkWell(
                                  onTap: () {
                                    Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                AdvertiserProfileScreen(
                                                    advertiserid: addedbyid)));
                                  },
                                  child: Row(
                                    children: [
                                      Text("Listed By ",
                                          style: TextStyle(
                                              color: Colors.deepOrange,
                                              fontSize: 16,
                                              fontWeight: FontWeight.w500)),
                                      Text(" : $addedby",
                                          style: TextStyle(
                                              color: Colors.black,
                                              fontSize: 16,
                                              fontWeight: FontWeight.w500)),
                                    ],
                                  ),
                                )),
                                     kyc == 1
                            ? SizedBox(
                                height: 30,
                                width: 100,
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    kyc == 1
                                        ? Expanded(
                                            child: Container(
                                            decoration: BoxDecoration(
                                                color: Colors.green.shade100,
                                                borderRadius:
                                                    BorderRadius.circular(20)),
                                            child: Padding(
                                              padding:
                                                  const EdgeInsets.all(8.0),
                                              child: Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                children: [
                                                  Text(
                                                    "kyc",
                                                    style: TextStyle(
                                                        color: Colors.black,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        fontSize: 15),
                                                  ),
                                                  Image.asset(
                                                    "assets/images/check-mark.png",
                                                    scale: 16,
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ))
                                        : SizedBox(),
                                    SizedBox(
                                      width: 30,
                                    ),
                                    trustedbadgeapproval == "approved" ?? ""
                                        ? Expanded(
                                            child: Container(
                                            decoration: BoxDecoration(
                                                color: Colors.green.shade100,
                                                borderRadius:
                                                    BorderRadius.circular(40)),
                                            child: Padding(
                                              padding:
                                                  const EdgeInsets.all(8.0),
                                              child: Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                children: [
                                                  Text(
                                                    "Trusted Badge",
                                                    style: TextStyle(
                                                        color: Colors.black,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        fontSize: 18),
                                                  ),
                                                  Image.asset(
                                                    "assets/images/check-mark.png",
                                                    scale: 16,
                                                  )
                                                ],
                                              ),
                                            ),
                                          ))
                                        : SizedBox(),
                                  ],
                                ),
                              )
                            : SizedBox(),
                          ],
                        ),
                        SizedBox(height: 10.0),
                        RatingBar.builder(
                          itemSize: 20,
                          initialRating: 3,
                          minRating: 1,
                          direction: Axis.horizontal,
                          allowHalfRating: false,
                          itemCount: 5,
                          itemPadding: EdgeInsets.symmetric(horizontal: 4.0),
                          itemBuilder: (context, _) => Icon(
                            Icons.star,
                            color: Colors.yellow,
                          ),
                          onRatingUpdate: (rating) {
                            print(rating);
                          },
                        ),
                        SizedBox(height: 10.0),

                        Divider(
                          thickness: 0.9,
                          height: 30,
                        ),
                        // SizedBox(height: 2.0),
                        Container(
                          alignment: Alignment.centerLeft,
                          height: 50,
                          width: width,
                          color: Colors.grey[300],
                          child: Padding(
                            padding: const EdgeInsets.only(left: 8.0),
                            child: Text(
                              "Description",
                              style: TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.w600),
                            ),
                          ),
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        Align(
                            alignment: Alignment.topLeft,
                            child: boostpack == "null" ||
                                    boostpack == "" ||
                                    boostpack == null
                                ? SizedBox()
                                : Container(
                                    height: 25,
                                    width: 100,
                                    alignment: Alignment.center,
                                    decoration: BoxDecoration(
                                        color: Colors.grey.shade300,
                                        borderRadius:
                                            BorderRadius.circular(4.0)),
                                    child: Text("Sponsored",
                                        style: TextStyle(
                                            color: Colors.black,
                                            fontSize: 16)))),
                        SizedBox(height: 15.0),
                        Padding(
                          padding: const EdgeInsets.only(left: 8.0),
                          child: Align(
                              alignment: Alignment.topLeft,
                              child: description == "" ||
                                      description == "null" ||
                                      description == null
                                  ? SizedBox()
                                  : Text(description,
                                      style: TextStyle(
                                          color: Colors.black, fontSize: 14))),
                        ),
                        Divider(
                          thickness: 0.9,
                          height: 30,
                        ),
                   
                        SizedBox(
                          height: 10,
                        ),

                        userid == null || userid == ""
                            ? SizedBox(
                                height: 60,
                                width: double.infinity,
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    InkWell(
                                      onTap: () {
                                        Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                                builder: (context) =>
                                                    LoginScreen()));
                                      },
                                      child: Container(
                                        height: 45,
                                        width: size.width * 0.45,
                                        alignment: Alignment.center,
                                        decoration: const BoxDecoration(
                                            color: kPrimaryColor,
                                            borderRadius: BorderRadius.all(
                                                Radius.circular(22.0))),
                                        child: Text("LOGIN TO START DISCUSSION",
                                            textAlign: TextAlign.center,
                                            style: TextStyle(
                                                color: Colors.white,
                                                fontWeight: FontWeight.w700)),
                                      ),
                                    ),
                                    InkWell(
                                      onTap: () {
                                        Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                                builder: (context) =>
                                                    LoginScreen()));
                                      },
                                      child: Container(
                                        height: 45,
                                        width: size.width * 0.45,
                                        alignment: Alignment.center,
                                        decoration: const BoxDecoration(
                                            color: Colors.deepOrangeAccent,
                                            borderRadius: BorderRadius.all(
                                                Radius.circular(22.0))),
                                        child: Text("RENT NOW",
                                            style: TextStyle(
                                                color: Colors.white,
                                                fontWeight: FontWeight.w700)),
                                      ),
                                    ),
                                  ],
                                ),
                              )
                            : userid != ""
                                ? usrid != loggedUserId
                                    ? SizedBox(
                                        height: 60,
                                        width: double.infinity,
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            InkWell(
                                              onTap: () {
                                                log(queryId);
                                                // Navigator.push(
                                                //     context,
                                                //     MaterialPageRoute(
                                                //         builder: (context) =>
                                                //             Conversation(
                                                //                 queryId: queryId)));
                                              },
                                              child: Container(
                                                height: 45,
                                                width: size.width * 0.45,
                                                alignment: Alignment.center,
                                                decoration: const BoxDecoration(
                                                    color: kPrimaryColor,
                                                    borderRadius:
                                                        BorderRadius.all(
                                                            Radius.circular(
                                                                22.0))),
                                                child: Text("START DISCUSSION",
                                                    style: TextStyle(
                                                        color: Colors.white,
                                                        fontWeight:
                                                            FontWeight.w700)),
                                              ),
                                            ),
                                            InkWell(
                                              onTap: () {
                                                if (actionbtn ==
                                                    "Make An Offer") {
                                                  Navigator.push(
                                                      context,
                                                      MaterialPageRoute(
                                                          builder: (context) =>
                                                              MakeEditOfferScreen(
                                                                pageFor:
                                                                    "Make an offer",
                                                                productid:
                                                                    productid,
                                                                nego: int.parse(
                                                                    negotiable),
                                                                editable: false,
                                                              )));
                                                } else {
                                                  Navigator.push(
                                                      context,
                                                      MaterialPageRoute(
                                                          builder: (context) =>
                                                              MakeEditOfferScreen(
                                                                pageFor:
                                                                    "Edit Offer",
                                                                productid:
                                                                    productid,
                                                                nego: int.parse(
                                                                    negotiable),
                                                                editable: true,
                                                              )));
                                                }
                                              },
                                              child: Container(
                                                height: 45,
                                                width: size.width * 0.45,
                                                alignment: Alignment.center,
                                                decoration: const BoxDecoration(
                                                    color:
                                                        Colors.deepOrangeAccent,
                                                    borderRadius:
                                                        BorderRadius.all(
                                                            Radius.circular(
                                                                22.0))),
                                                child: Text(
                                                    actionbtn
                                                        .toString()
                                                        .toUpperCase(),
                                                    style: TextStyle(
                                                        color: Colors.white,
                                                        fontWeight:
                                                            FontWeight.w700)),
                                              ),
                                            ),
                                          ],
                                        ),
                                      )
                                    : SizedBox()
                                : SizedBox(),

                        Divider(
                          thickness: 0.9,
                          height: 30,
                        ),
                        SizedBox(height: 20),
                        Container(
                          height: height * 0.2,
                          width: width * 0.98,
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SizedBox(
                                height: 10,
                              ),
                              Row(
                                children: [
                                  Container(
                                    margin: const EdgeInsets.only(left: 10),
                                    height: 40,
                                    width: 3,
                                    color: Colors.deepOrange,
                                  ),
                                  SizedBox(
                                    width: 10,
                                  ),
                                  Text(
                                    "Post Comments",
                                    style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.w500),
                                  )
                                ],
                              ),
                              SizedBox(
                                height: 30,
                              ),
                              Container(
                                alignment: Alignment.center,
                                width: width * 0.98,
                                child: Text("No Comments...",
                                    style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.w500,
                                        color: Colors.grey)),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: 20),

                        // Row(
                        //   crossAxisAlignment: CrossAxisAlignment.start,
                        //   children: [
                        //     Text("Address : ",
                        //         style: TextStyle(
                        //             color: kPrimaryColor,
                        //             fontSize: 18,
                        //             fontWeight: FontWeight.bold)),
                        //     SizedBox(
                        //       width: size.width * 0.70,
                        //       child: address == null
                        //           ? SizedBox()
                        //           : Text(address,
                        //               maxLines: 2,
                        //               style: TextStyle(
                        //                   color: kPrimaryColor, fontSize: 18)),
                        //     )
                        //   ],
                        // ),
                        Divider(),
                        pageLodaing == true
                            ? Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: const [
                                  CircularProgressIndicator(),
                                  SizedBox(
                                    height: 20,
                                  ),
                                  SizedBox(
                                    child: Text(
                                      "Loading...",
                                      style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                ],
                              )
                            : peopleAlsoLikeList.isEmpty
                                ? SizedBox()
                                : Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Container(
                                        margin: const EdgeInsets.symmetric(
                                            horizontal: 5),
                                        child: Text(
                                          "You May Also Like",
                                          style: TextStyle(
                                              color: Colors.blue[900],
                                              fontSize: 22,
                                              fontWeight: FontWeight.bold),
                                        ),
                                      ),
                                      Divider(),
                                      SizedBox(height: 10),
                                      SizedBox(
                                        height: height * 0.32,
                                        width: width,
                                        child: ListView.builder(
                                            scrollDirection: Axis.horizontal,
                                            physics: BouncingScrollPhysics(),
                                            itemCount:
                                                peopleAlsoLikeList.length,
                                            itemBuilder: ((context, index) =>
                                                youMayAlsoLikeWidget(
                                                    peopleAlsoLikeList[
                                                        index]))),
                                      ),
                                      SizedBox(height: 0),
                                    ],
                                  ),
                        // Row(
                        //   crossAxisAlignment: CrossAxisAlignment.start,
                        //   children: [
                        //     Text("Price : ",
                        //         style: TextStyle(
                        //             color: kPrimaryColor,
                        //             fontSize: 18,
                        //             fontWeight: FontWeight.bold)),
                        //     SizedBox(
                        //       width: size.width * 0.70,
                        //       child: negotiable == "0" ? Text("Fixed",
                        //           maxLines: 2,
                        //           style: TextStyle(
                        //               color: kPrimaryColor, fontSize: 18)) : Text(
                        //           "Negotiable",
                        //           maxLines: 2,
                        //           style: TextStyle(
                        //               color: kPrimaryColor, fontSize: 18)),
                        //     )
                        //   ],
                        //   ],
                        // ),
                        // SizedBox(height: 20),
                        // Row(
                        //   crossAxisAlignment: CrossAxisAlignment.start,
                        //   children: [
                        //     Text("Email : ",
                        //         style: TextStyle(
                        //             color: kPrimaryColor,
                        //             fontSize: 18,
                        //             fontWeight: FontWeight.bold)),
                        //     SizedBox(
                        //       width: size.width * 0.70,
                        //       child: email == null
                        //           ? SizedBox()
                        //           : Text(email,
                        //               maxLines: 1,
                        //               style: TextStyle(
                        //                   color: kPrimaryColor, fontSize: 18)),
                        //     )
                        //   ],
                        // ),
                        // // Padding(
                        //     padding: EdgeInsets.symmetric(vertical: 10.0),
                        //     child: Container(
                        //       height: 550,
                        //       width: double.infinity,
                        //       child: GoogleMap(
                        //         initialCameraPosition: initialCameraPosition,
                        //         markers: markers,
                        //         zoomControlsEnabled: false,
                        //         mapType: MapType.normal,
                        //         onMapCreated: (GoogleMapController controller) {
                        //           googleMapController = controller;
                        //         },
                        //       ),
                        //     ),
                        // ),
                        // likedadproductlist.isEmpty
                        //     ? SizedBox()
                        //     : SizedBox(height: 30),
                        // likedadproductlist.isEmpty
                        //     ? SizedBox(height: 0)
                        //     : const Text("You May Also Like",
                        //         style: TextStyle(
                        //             color: Colors.deepOrangeAccent,
                        //             fontWeight: FontWeight.w700,
                        //             fontSize: 21)),
                        // likedadproductlist.isEmpty
                        //     ? SizedBox(height: 0)
                        //     : SizedBox(height: 10),
                        // likedadproductlist.isEmpty
                        //     ? SizedBox(height: 0)
                        //     : GridView.builder(
                        //         shrinkWrap: true,
                        //         itemCount: likedadproductlist.length,
                        //         physics: ClampingScrollPhysics(),
                        //         gridDelegate:
                        //             const SliverGridDelegateWithFixedCrossAxisCount(
                        //                 crossAxisCount: 2,
                        //                 crossAxisSpacing: 4.0,
                        //                 mainAxisSpacing: 4.0,
                        //                 childAspectRatio: 1.0),
                        //         itemBuilder: (context, index) {
                        //           return InkWell(
                        //             onTap: () {
                        //               Navigator.push(
                        //                   context,
                        //                   MaterialPageRoute(
                        //                       builder: (context) =>
                        //                           ProductDetailScreen(
                        //                               productid:
                        //                                   likedadproductlist[index]
                        //                                           ['id']
                        //                                       .toString())));
                        //             },
                        //             child: Card(
                        //               shape: RoundedRectangleBorder(
                        //                 borderRadius: BorderRadius.circular(4.0),
                        //               ),
                        //               child: Column(
                        //                 children: [
                        //                   CachedNetworkImage(
                        //                     height: 80,
                        //                     width: double.infinity,
                        //                     placeholder: (context, url) =>
                        //                         Image.asset(
                        //                             'assets/images/no_image.jpg',
                        //                             fit: BoxFit.fill),
                        //                     errorWidget: (context, url, error) =>
                        //                         Image.asset(
                        //                             'assets/images/no_image.jpg',
                        //                             fit: BoxFit.fill),
                        //                     fit: BoxFit.fill,
                        //                     imageUrl: likedadproductlist[index]
                        //                                     ['images']
                        //                                 .length >
                        //                             0
                        //                         ? devImage +
                        //                             "assets/frontend/images/listings/" +
                        //                             likedadproductlist[index]
                        //                                         ['images'][0]
                        //                                     ['file_name']
                        //                                 .toString()
                        //                         : "http://themedemo.wpeka.com/wp-content/themes/apppress/images/icons/included/color.png",
                        //                   ),
                        //                   SizedBox(height: 5.0),
                        //                   Padding(
                        //                     padding: EdgeInsets.only(
                        //                         left: 5.0, right: 15.0),
                        //                     child: Align(
                        //                       alignment: Alignment.topLeft,
                        //                       child: Text(
                        //                           likedadproductlist[index]['title']
                        //                               .toString(),
                        //                           maxLines: 1,
                        //                           style: TextStyle(
                        //                               color: Colors.black,
                        //                               fontWeight: FontWeight.w700,
                        //                               fontSize: 16)),
                        //                     ),
                        //                   ),
                        //                   SizedBox(height: 5.0),
                        //                   Padding(
                        //                     padding: const EdgeInsets.only(
                        //                         left: 4.0, right: 4.0),
                        //                     child: Row(
                        //                       mainAxisAlignment:
                        //                           MainAxisAlignment.spaceBetween,
                        //                       children: [
                        //                         SizedBox(
                        //                             width: size.width * 0.4,
                        //                             child: Text(
                        //                                 "Starting from ${likedadproductlist[index]['currency'].toString()} ${likedadproductlist[index]['prices'][0]['price'].toString()}",
                        //                                 style: TextStyle(
                        //                                     color: kPrimaryColor,
                        //                                     fontSize: 12))),
                        //                         // IconButton(
                        //                         //     iconSize: 28,
                        //                         //     onPressed: () {
                        //                         //       Navigator.push(
                        //                         //           context,
                        //                         //           MaterialPageRoute(
                        //                         //               builder: (context) =>
                        //                         //                   ProductDetailScreen(
                        //                         //                       productid: likedadproductlist[
                        //                         //                                   index]
                        //                         //                               ['id']
                        //                         //                           .toString())));
                        //                         //     },
                        //                         //     icon: Icon(
                        //                         //         Icons.add_box_rounded,
                        //                         //         color: kPrimaryColor))
                        //                       ],
                        //                     ),
                        //                   )
                        //                 ],
                        //               ),
                        //             ),
                        //           );
                        //         }),

                        SizedBox(
                          height: 0,
                        ),
                        Divider(),

                        Container(
                          margin: const EdgeInsets.symmetric(horizontal: 5),
                          alignment: Alignment.centerLeft,
                          child: Text(
                            "Today's Special Deals",
                            style: TextStyle(
                                color: Colors.blue[900],
                                fontWeight: FontWeight.bold,
                                fontSize: 22),
                          ),
                        ),

                        Divider(),
                        SizedBox(
                          height: 10,
                        ),
                        SizedBox(
                          width: double.infinity,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SizedBox(
                                height:
                                    MediaQuery.of(context).size.height * 0.40,
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
                                height:
                                    MediaQuery.of(context).size.height * 0.23,
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
                                height:
                                    MediaQuery.of(context).size.height * 0.23,
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
                                      height:
                                          MediaQuery.of(context).size.height *
                                              0.21,
                                      width: MediaQuery.of(context).size.width *
                                          0.43,
                                      child: CachedNetworkImage(
                                        imageUrl: bottomimage3,
                                        fit: BoxFit.fill,
                                      ),
                                    ),
                                    SizedBox(
                                      height:
                                          MediaQuery.of(context).size.height *
                                              0.21,
                                      width: MediaQuery.of(context).size.width *
                                          0.43,
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

                        // Container(
                        //   margin: const EdgeInsets.symmetric(horizontal: 5),
                        //   child: Row(
                        //     mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        //     children: [
                        //       Image.network(
                        //         bottomimage3.toString(),
                        //         scale: 1.55,
                        //       ),
                        //       Image.network(
                        //         bottomimage3.toString(),
                        //         scale: 1.55,
                        //       ),
                        //     ],
                        //   ),
                        // ),

                        // Container(
                        //   padding: const EdgeInsets.only(bottom: 5),
                        //   width: double.infinity,
                        //   child: Column(
                        //     children: [
                        //       const SizedBox(height: 5),
                        //       Container(
                        //         width: double.infinity,
                        //         child: Column(
                        //           crossAxisAlignment: CrossAxisAlignment.start,
                        //           children: [
                        //             Container(
                        //               height:
                        //                   MediaQuery.of(context).size.height * 0.40,
                        //               width: MediaQuery.of(context).size.width,
                        //               child: Padding(
                        //                 padding: const EdgeInsets.only(
                        //                     left: 10.0,
                        //                     top: 10.0,
                        //                     right: 10.0,
                        //                     bottom: 0.0),
                        //                 child: ClipRRect(
                        //                   borderRadius: const BorderRadius.all(
                        //                       Radius.circular(0.0)),
                        //                   child: CachedNetworkImage(
                        //                     imageUrl: bottomimage1.toString(),
                        //                     fit: BoxFit.fill,
                        //                   ),
                        //                 ),
                        //               ),
                        //             ),
                        //             Container(
                        //               height:
                        //                   MediaQuery.of(context).size.height * 0.23,
                        //               width: MediaQuery.of(context).size.width,
                        //               child: Padding(
                        //                 padding: const EdgeInsets.only(
                        //                     left: 10.0,
                        //                     top: 10.0,
                        //                     right: 10.0,
                        //                     bottom: 5.0),
                        //                 child: ClipRRect(
                        //                   borderRadius: const BorderRadius.all(
                        //                       Radius.circular(0.0)),
                        //                   child: CachedNetworkImage(
                        //                     imageUrl: bottomimage2.toString() ?? "https://upload.wikimedia.org/wikipedia/commons/thumb/b/b6/Image_created_with_a_mobile_phone.png/1200px-Image_created_with_a_mobile_phone.png",
                        //                     fit: BoxFit.fill,
                        //                   ),
                        //                 ),
                        //               ),
                        //             ),

                        //             Container(
                        //               height:
                        //                   MediaQuery.of(context).size.height * 0.23,
                        //               width: MediaQuery.of(context).size.width,
                        //               padding: const EdgeInsets.only(
                        //                   left: 10.0,
                        //                   top: 5.0,
                        //                   right: 10.0,
                        //                   bottom: 10.0),
                        //               child: Row(
                        //                 mainAxisAlignment:
                        //                     MainAxisAlignment.spaceBetween,
                        //                 children: [
                        //                   Container(
                        //                     height:
                        //                         MediaQuery.of(context).size.height *
                        //                             0.21,
                        //                     width:
                        //                         MediaQuery.of(context).size.width *
                        //                             0.45,
                        //                     child: CachedNetworkImage(
                        //                       imageUrl: bottomimage3,
                        //                       fit: BoxFit.fill,
                        //                     ),
                        //                   ),
                        //                   Container(
                        //                     height:
                        //                         MediaQuery.of(context).size.height *
                        //                             0.21,
                        //                     width:
                        //                         MediaQuery.of(context).size.width *
                        //                             0.43,
                        //                     child: CachedNetworkImage(
                        //                       imageUrl: bottomimage4,
                        //                       fit: BoxFit.fill,
                        //                     ),
                        //                   ),
                        //                 ],
                        //               ),
                        //             )
                        //           ],
                        //         ),
                        //       ),
                        //     ],
                        //   ),
                        // ),
                      ],
                    ),
                  ),
                ),
    );
  }

  Widget youMayAlsoLikeWidget(PeopleAlsoMayLikeModel item) {
    return InkWell(
      onTap: () {
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => ProductDetailScreen(
                      productid: item.id.toString(),
                    )));
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              height: height * 0.2,
              width: width * 0.43,
              child: ListView.builder(
                  physics: NeverScrollableScrollPhysics(),
                  itemCount: item.images.length,
                  itemBuilder: ((context, index) {
                    var i = item.images[index];
                    return Container(
                      height: height * 0.18,
                      width: width * 0.43,
                      decoration: BoxDecoration(
                          image: DecorationImage(
                              image: NetworkImage(
                                  devImage + i.uploadBasePath + i.fileName),
                              fit: BoxFit.cover)),
                    );
                  })),
            ),
            SizedBox(
              height: 10,
            ),
            Container(
              alignment: Alignment.centerLeft,
              width: width * 0.43,
              child: Text(
                item.title,
                style: TextStyle(
                    color: Colors.black,
                    fontSize: 16,
                    fontWeight: FontWeight.w600),
              ),
            ),
            SizedBox(
              height: 10,
            ),
            Container(
              alignment: Alignment.centerLeft,
              width: width * 0.43,
              child: Text(
                "Starting From INR ${item.startingPrice}",
                style: TextStyle(
                    color: Colors.grey,
                    fontSize: 15,
                    fontWeight: FontWeight.w600),
              ),
            ),
            SizedBox(
              height: 20,
            ),
            Divider(),
          ],
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
          'Authorization': 'Bearer ' + prefs.getString("token").toString(),
        });
    if (response.statusCode == 200) {
      var data = json.decode(response.body)['Response'];
      if (data != null) {
        setState(() {
          usertype = data['user_type'];
          trustedbadge = data['trusted_badge'];
          trustedbadgeapproval = data['trusted_badge_approval'].toString();
        });
      }
    } else {
      throw Exception('Failed to get data due to ${response.body}');
    }
  }

  String _getrenttypeamounthint(String renttype) {
    if (renttype == "Hourly" || renttype == "hourly") {
      return "Enter Amount Per Hour";
    } else if (renttype == "Weekly" || renttype == "weekly") {
      return "Enter Amount Per Week";
    } else if (renttype == "Monthly" || renttype == "monthly") {
      return "Enter Amount Per Month";
    } else if (renttype == "Yearly" || renttype == "yearly") {
      return "Enter Amount Per Year";
    } else if (renttype == "Days" || renttype == "days") {
      return "Enter Amount Per Day";
    } else {
      return "Enter Amount Per Period";
    }
  }

  String _getrenttypehint(String renttype) {
    if (renttype == "Hourly" || renttype == "hourly") {
      return "Enter Hours";
    } else if (renttype == "Weekly" || renttype == "weekly") {
      return "Enter Weeks";
    } else if (renttype == "Monthly" || renttype == "monthly") {
      return "Enter Months";
    } else if (renttype == "Yearly" || renttype == "yearly") {
      return "Enter Years";
    } else if (renttype == "Days" || renttype == "days") {
      return "Enter Days";
    } else {
      return "Enter Period";
    }
  }

  String adId = '';
  Future _getproductDetail(String productid) async {
    setState(() {
      apiLoading = true;
    });
    SharedPreferences prefs = await SharedPreferences.getInstance();

    String userId = prefs.getString('userid');
    log("userid---->$userId");
    final body = {"id": widget.productid, "user_id": userId};
    log("test----" + body.toString());

    var response = await http.post(Uri.parse(BASE_URL + productdetail),
        body: jsonEncode(body),
        headers: {
          "Accept": "application/json",
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ' + prefs.getString("token").toString(),
        });
    if (response.statusCode == 200) {
      var data = json.decode(response.body)['Response'];
      apiLoading = false;
      setState(() {
        userid = prefs.getString('userid');
        adId = data['posted_ad']['ad_id'];

        if (data['Images'].length > 0) {
          productimage = devImage +
              data['Images'][0]['upload_base_path'].toString() +
              data['Images'][0]['file_name'].toString();

          productimages.addAll(data['Images']);
          apiLoading = false;

          productname = data['posted_ad']['title'].toString();
          final document = parse(data['posted_ad']['description'].toString());
          description =
              parse(document.body.text).documentElement.text.toString();
          boostpack = data['posted_ad']['boost_package_status'].toString();
          renttype = data['posted_ad']['rent_type'].toString();
          negotiable = data['posted_ad']['negotiate'].toString();

          queryId = data['additional']['added-by']['quickblox_id'].toString();
          List temp = [];
          data['posted_ad']['prices'].forEach((element) {
            if (element['price'] != null) {
              temp.add("INR " +
                  element['price'].toString() +
                  " (" +
                  element['rent_type_name'].toString() +
                  ")");
            }
          });
          productprice = temp.join("/").toString();
          securitydeposit = data['posted_ad']['security'].toString();
          addedbyid = data['additional']['added-by']['id'].toString();
          addedby = data['additional']['added-by']['name'].toString();
          email = data['additional']['added-by']['email'].toString();
          address = data['additional']['added-by']['address'].toString();
          trustedBadge = data['additional']['added-by']
                  ['trusted_badge_approval']
              .toString();
          kyc = data['additional']['added-by']['kyc'];

          log("kyc---->" + kyc.toString());
          log("kyc---->" + trustedBadge.toString());

          actionbtn = data['offer'].toString();
          log(data['liked_ads'].toString());
          // likedadproductlist = data['liked_ads'];
          log("tttt----" + likedadproductlist.toString());

          if (data['posted_ad']['user_id'].toString() ==
              prefs.getString('userid')) {
            _checkuser = true;
          } else {
            _checkuser = false;
          }

          _checkData = true;
        } else {
          setState(() {
            apiLoading = false;
          });
          productname = data['posted_ad']['title'].toString();
          final document = parse(data['posted_ad']['description'].toString());
          description =
              parse(document.body.text).documentElement.text.toString();
          boostpack = data['posted_ad']['boost_package_status'].toString();
          renttype = data['posted_ad']['rent_type'].toString();
          negotiable = data['posted_ad']['negotiate'].toString();

          queryId = data['additional']['added-by']['quickblox_id'].toString();
          //print("query id here $queryId");

          List temp = [];
          data['posted_ad']['prices'].forEach((element) {
            if (element['price'] != null) {
              temp.add("INR " +
                  element['price'].toString() +
                  " (" +
                  element['rent_type_name'].toString() +
                  ")");
            }
          });
          productprice = temp.join("/").toString();
          securitydeposit = data['posted_ad']['security'].toString();
          addedbyid = data['additional']['added-by']['id'].toString();
          addedby = data['additional']['added-by']['name'].toString();
          email = data['additional']['added-by']['email'].toString();
          address = data['additional']['added-by']['address'].toString();
          actionbtn = data['offer'].toString();

          likedadproductlist.addAll(data['liked_ads']);

          if (data['posted_ad']['user_id'].toString() ==
              prefs.getString('userid')) {
            _checkuser = true;
          } else {
            _checkuser = false;
          }

          _checkData = true;
        }
      });
      setState(() {
        apiLoading = false;
      });
    } else {
      throw Exception('Failed to get data due to ${response.body}');
    }
  }

  Map getOfferData = {};
  Future _getmakeoffer(String productid) async {
    print("called");
    //print("product id $productid");
    SharedPreferences prefs = await SharedPreferences.getInstance();
    //print(jsonEncode(
    // {"user_id": prefs.getString('userid'), "post_ad_id": productid}));
    final body = {
      "user_id": prefs.getString('userid'),
      "post_ad_id": productid
    };
    var response = await http.post(Uri.parse(BASE_URL + createoffer),
        body: jsonEncode(body),
        headers: {
          "Accept": "application/json",
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ' + prefs.getString("token").toString(),
        });

    if (response.statusCode == 200) {
      var data = json.decode(response.body)['Response'];

      // data.forEach((e) {
      //   print(e.key + "-" + e.value);
      // });
      try {
        setState(() {
          if (data['data'] != "null" || data['data'] != null) {
            getOfferData = data['data'];
          }
          securitydeposit = data['posted_ad']['security'].toString();
          rentpricelist.addAll(data['posted_ad']['prices']);
          for (var element in rentpricelist) {
            if (element['price'] != null) {
              renttypelist.add(element['rent_type_name'].toString());
            }
          }
          conviencechargeper =
              double.parse(data['convenience_charges']['charge'].toString());
          conviencevalue = 0;
        });
      } catch (e) {}
    } else {
      throw Exception('Failed to get data due to ${response.body}');
    }
  }

  Future _setmakeoffer() async {
    showLaoding(context);
    SharedPreferences prefs = await SharedPreferences.getInstance();
    ////print(jsonEncode({
    //   "post_ad_id": productid,
    //   "period": days,
    //   "rent_type": renttypeid,
    //   "quantity": productQty,
    //   "start_date": startDate,
    //   "renter_amount": useramount,
    //   "user_id": prefs.getString('userid'),
    // }));
    final body = {
      "post_ad_id": productid,
      "period": days,
      "rent_type": renttypeid,
      "quantity": productQty,
      "start_date": startDate,
      "renter_amount": useramount,
      "user_id": prefs.getString('userid'),
    };
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
      Navigator.pushReplacement(context,
          MaterialPageRoute(builder: (BuildContext context) => HomeScreen()));
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
        startDate = DateFormat('yyyy/MM/dd').format(picked);
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
      use24HourFormat: false,
      locale: Locale('en', 'US'),
      icon: Icon(Icons.calendar_today_sharp, size: 20),
      validator: (val) {
        setState(() {
          startDate = val;
        });
      },
      onSaved: (val) {
        setState(() {
          startDate = val;
        });
      },
      onChanged: (val) {
        setState(() {
          startDate = val;
        });
      },
      onFieldSubmitted: (v) {
        setState(() {
          startDate = v;
        });
      },
    );
  }

  Future<Position> _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();

    if (!serviceEnabled) {
      return Future.error('Location services are disabled');
    }
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error("Location permission denied");
      }
    }
    if (permission == LocationPermission.deniedForever) {
      return Future.error('Location permissions are permanently denied');
    }
    Position position = await Geolocator.getCurrentPosition();
    return position;
  }

  String bottomimage1;
  String bottomimage2;
  String bottomimage3;
  String bottomimage4;
  String bottomsingleimage;
  bool _check = false;
  bool sharedpref = false;
  List<dynamic> images = [];
  final List<dynamic> myProducts = [];

  List mytopcategorieslistData = [];

  final List<dynamic> mytopcategories = [];
  final List<dynamic> mytopcategoriesname = [];
  String todaydealsimage1;
  String todaydealsimage2;
  String todaydealsimage3;
  String todaydealsimage4;

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
    final body = {
      "country": prefs.getInt('countryId'),
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
      setState(() {
        images.clear();
        location.clear();
        category.clear();
        myProducts.clear();
        mytopcategories.clear();

        jsonDecode(response.body)['Response']['slider'].forEach((element) {
          images.add(sliderpath + element['value'].toString());
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

        mytopcategorieslistData.addAll(
            jsonDecode(response.body)['Response']['top_selling_categories']);
        jsonDecode(response.body)['Response']['top_selling_categories']
            .forEach((element) {
          mytopcategoriesname.add(element['title'].toString());
          mytopcategories.add(imagepath + element['image'].toString());
        });

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

        print(jsonDecode(response.body)['Response']['today_special_deals']);
        todaydealsimage1 = sliderpath +
            jsonDecode(response.body)['Response']['today_special_deals']
                    ['mid_banner_1']['value']
                .toString();
        todaydealsimage2 = sliderpath +
            jsonDecode(response.body)['Response']['today_special_deals']
                    ['mid_banner_2']['value']
                .toString();
        todaydealsimage3 = sliderpath +
            jsonDecode(response.body)['Response']['today_special_deals']
                    ['mid_banner_3']['value']
                .toString();
        todaydealsimage4 = sliderpath +
            jsonDecode(response.body)['Response']['today_special_deals']
                    ['mid_banner_4']['value']
                .toString();

        bottomimage1 = sliderpath +
            jsonDecode(response.body)['Response']['today_special_deals']
                    ['bottom_banner_1']['value']
                .toString();
        bottomimage2 = sliderpath +
            jsonDecode(response.body)['Response']['today_special_deals']
                    ['bottom_banner_2']['value']
                .toString();
        bottomimage3 = sliderpath +
            jsonDecode(response.body)['Response']['today_special_deals']
                    ['bottom_banner_3']['value']
                .toString();
        bottomimage4 = sliderpath +
            jsonDecode(response.body)['Response']['today_special_deals']
                    ['bottom_banner_4']['value']
                .toString();

        bottomsingleimage = sliderpath +
            jsonDecode(response.body)['Response']['today_special_deals']
                    ['bottom_banner_single']['value']
                .toString();

        _check = true;
      });
    }
  }

  List<PeopleAlsoMayLikeModel> peopleAlsoLikeList = [];
  bool pageLodaing = false;

  int usrid = 0;

  Future getPeopleAlsoLike() async {
    setState(() {
      pageLodaing = true;
    });

    SharedPreferences prefs = await SharedPreferences.getInstance();

    int countryID = 0;
    String cityId = '';
    String userId = '';

    setState(() {
      countryID = prefs.getInt('countryId');
      cityId = prefs.getString('cityId');
      userId = prefs.getString('userid');
    });

    var url = Apis.adViewApi;
    var body = {
      "id": widget.productid,

      "country": countryID.toString(),
      // "city": "",cityId.toString(),
      "city": cityId.toString(),
    };
    log(body.toString());
    var response = await APIHelper.apiPostRequest(url, body);
    log(response);
    var result = jsonDecode(response);
    if (result['ErrorCode'] == 0) {
      var list = result['Response']['liked_ads'] as List;

      setState(() {
        usrid = result['Response']['posted_ad']['user_id'];
        log("userID---=>" + usrid.toString());

        peopleAlsoLikeList.clear();
        var listdata =
            list.map((e) => PeopleAlsoMayLikeModel.fromJson(e)).toList();
        peopleAlsoLikeList.addAll(listdata);
      });
      setState(() {
        pageLodaing = false;
      });
    }
    setState(() {
      pageLodaing = false;
    });
  }
}
