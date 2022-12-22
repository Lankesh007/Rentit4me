// ignore_for_file: use_build_context_synchronously

import 'dart:developer';

import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:html/parser.dart';
import 'package:http/http.dart' as http;
import 'package:rentit4me_new/themes/constant.dart';
import 'package:rentit4me_new/network/api.dart';
import 'package:rentit4me_new/views/advertiser_profile_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'add_list_screen.dart';
import 'login_screen.dart';

class PreviewProductScreen extends StatefulWidget {
  String productid;
  PreviewProductScreen({this.productid});

  @override
  State<PreviewProductScreen> createState() =>
      _PreviewProductScreenState(productid);
}

class _PreviewProductScreenState extends State<PreviewProductScreen> {
  String productid;
  _PreviewProductScreenState(this.productid);

  bool _checkData = false;

  String productname;
  String productimage;
  String boostpack;
  String description;
  String renttype;
  String negotiate;
  String productprice;
  String securitydeposit;
  String addedbyid;
  String addedby;
  String address;
  String email;

  String mobile;
  String mobile_hidden;

  List productimages = [];

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _getpreproductDetail(productid);
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 2.0,
        title: Row(children: [
          Image.asset('assets/images/logo.png', scale: 25),
          const SizedBox(
            width: 10,
          ),
          SizedBox(
            width: 30,
          ),
          InkWell(
            onTap: () async {
              SharedPreferences prefs = await SharedPreferences.getInstance();
              String userID = prefs.getString("userid");
              log("userId--->$userID");

              if (userID == null || userID == "") {
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => LoginScreen()));
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
                  color: Colors.orange[600],
                  borderRadius: BorderRadius.circular(100),
                ),
                child: Text("Post An Ad", style: TextStyle(fontSize: 15))),
          ),
          const SizedBox(
            width: 10,
          ),
        ]),
        centerTitle: true,
        leading: Row(
          children: [
            IconButton(
                onPressed: () async {
                  Navigator.pop(context);
                },
                icon: const Icon(Icons.arrow_back_ios, color: kPrimaryColor)),
            //SizedBox(width: 2),
            //Image.asset('assets/images/logo.png', scale: 45),
          ],
        ),
      ),
      body: _checkData == false
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : SingleChildScrollView(
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(vertical: 5.0, horizontal: 5.0),
                child: Column(
                  children: [
                    productimage == null
                        ? SizedBox(
                            height: 150,
                            width: double.infinity,
                            child: Image.asset('assets/images/no_image.jpg'),
                          )
                        : SizedBox(
                            height: 300,
                            width: double.infinity,
                            child: CachedNetworkImage(
                              imageUrl: productimage,
                              fit: BoxFit.fill,
                              errorWidget: (context, url, error) => Image.asset(
                                  'assets/images/no_image.jpg',
                                  fit: BoxFit.fill),
                            ),
                          ),
                    const SizedBox(height: 10.0),
                    Padding(
                      padding: EdgeInsets.zero,
                      child: SizedBox(
                        height: 80,
                        width: size.width,
                        child: GridView.count(
                            crossAxisCount: 1,
                            crossAxisSpacing: 0.0,
                            mainAxisSpacing: 8.0,
                            shrinkWrap: true,
                            padding: EdgeInsets.zero,
                            scrollDirection: Axis.horizontal,
                            children:
                                List.generate(productimages.length, (index) {
                              return InkWell(
                                onTap: () {
                                  setState(() {
                                    productimage = devImage +
                                        productimages[index]['upload_base_path']
                                            .toString() +
                                        productimages[index]['file_name']
                                            .toString();
                                  });
                                },
                                child: Container(
                                  height: 80,
                                  width: 80,
                                  decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(8.0)),
                                  child: Image.network(devImage +
                                      productimages[index]['upload_base_path']
                                          .toString() +
                                      productimages[index]['file_name']
                                          .toString()),
                                ),
                              );
                            })),
                      ),
                    ),
                    const SizedBox(height: 10.0),
                    Divider(
                      thickness: 0.9,
                    ),
                    Container(
                      alignment: Alignment.centerLeft,
                      margin: const EdgeInsets.symmetric(horizontal: 10),
                      child: Text("Ad Id : $adId",
                          style: const TextStyle(
                              color: Colors.black, fontSize: 20)),
                    ),
                    Divider(
                      thickness: 0.9,
                    ),
                    const SizedBox(height: 10.0),

                    Align(
                        alignment: Alignment.topLeft,
                        child: productname == "null" || productname == null
                            ? const SizedBox()
                            : Container(
                                margin:
                                    const EdgeInsets.symmetric(horizontal: 10),
                                child: Text(productname,
                                    style: const TextStyle(
                                        color: Colors.black,
                                        fontSize: 30,
                                        fontWeight: FontWeight.bold)),
                              )),
                    Divider(
                      thickness: 0.9,
                    ),
                    const SizedBox(height: 4.0),
                    Align(
                        alignment: Alignment.topLeft,
                        child: boostpack == "null" || boostpack == null
                            ? const SizedBox()
                            : Container(
                                height: 25,
                                width: 100,
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                    color: Colors.grey.shade300,
                                    borderRadius: BorderRadius.circular(4.0)),
                                child: const Text("Sponsored",
                                    style: TextStyle(
                                        color: Colors.black, fontSize: 16)))),
                    const SizedBox(height: 15.0),

                    Container(
                      margin: const EdgeInsets.symmetric(horizontal: 10),
                      child: Align(
                          alignment: Alignment.topLeft,
                          child: renttype == null || renttype == "null"
                              ? Text(productprice,
                                  style: TextStyle(
                                      color: Colors.blue[900],
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600))
                              : Text("INR $productprice $renttype",
                                  style: const TextStyle(
                                      color: kPrimaryColor,
                                      fontSize: 16,
                                      fontWeight: FontWeight.w500))),
                    ),
                    const SizedBox(height: 15.0),
                    Container(
                      margin: const EdgeInsets.symmetric(horizontal: 10),
                      child: Align(
                          alignment: Alignment.topLeft,
                          child: Row(
                            children: [
                              Text("Security Deposit : ",
                                  style: TextStyle(
                                      color: Colors.deepOrange,
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600)),
                              Text(" INR $securitydeposit",
                                  style: TextStyle(
                                      color: Colors.blue[900],
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600)),
                            ],
                          )),
                    ),
                    const SizedBox(height: 15.0),
                    // Container(
                    //   margin: const EdgeInsets.symmetric(horizontal: 10),
                    //   child: InkWell(
                    //     onTap: () {
                    //       Navigator.push(
                    //           context,
                    //           MaterialPageRoute(
                    //               builder: (context) => AdvertiserProfileScreen(
                    //                   advertiserid: addedbyid)));
                    //     },
                    //     child: Align(
                    //         alignment: Alignment.topLeft,
                    //         child: Row(
                    //           children: [
                    //             Text("Listed By :",
                    //                 style: TextStyle(
                    //                     color: Colors.deepOrange,
                    //                     fontSize: 16,
                    //                     fontWeight: FontWeight.w600)),
                    //             Text(" $addedby",
                    //                 style: TextStyle(
                    //                     color: Colors.blue[900],
                    //                     fontSize: 16,
                    //                     fontWeight: FontWeight.w600)),
                    //           ],
                    //         )),
                    //   ),
                    // ),
                    const SizedBox(height: 35.0),
                    Container(
                      height: 40,
                      color: Colors.grey[200],
                      alignment: Alignment.centerLeft,
                      child: Text(
                        "  Description",
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.w600),
                      ),
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    Container(
                      margin: const EdgeInsets.symmetric(horizontal: 10),
                      child: Align(
                          alignment: Alignment.topLeft,
                          child: description == "null" || description == null
                              ? const SizedBox()
                              : Text(description,
                                  style: const TextStyle(
                                      color: Colors.black, fontSize: 14))),
                    ),
                    const SizedBox(height: 10),

                    // Divider(thickness: 0.9),
                    // const SizedBox(height: 20.0),
                    // Row(
                    //   crossAxisAlignment: CrossAxisAlignment.start,
                    //   children: [
                    //     const Text("Address : ",
                    //         style: TextStyle(
                    //             color: Colors.deepOrange,
                    //             fontSize: 18,
                    //             fontWeight: FontWeight.bold)),
                    //     SizedBox(
                    //       width: size.width * 0.70,
                    //       child: address == null || address == "null"
                    //           ? const SizedBox()
                    //           : Text(address,
                    //               maxLines: 3,
                    //               style:  TextStyle(
                    //                   color: Colors.blue[900], fontSize: 18)),
                    //     )
                    //   ],
                    // ),
                    // Divider(thickness: 0.9),

                    // // const SizedBox(height: 20),
                    // // Row(
                    // //   crossAxisAlignment: CrossAxisAlignment.start,
                    // //   children: [
                    // //     const Text("Price : ",
                    // //         style: TextStyle(
                    // //             color: kPrimaryColor,
                    // //             fontSize: 18,
                    // //             fontWeight: FontWeight.bold)),
                    // //     SizedBox(
                    // //       width: size.width * 0.70,
                    // //       child: negotiate == "0" ? const Text("Fixed", maxLines: 2, style: TextStyle(color: kPrimaryColor, fontSize: 18)) : const Text("Negotiable", maxLines: 2, style: TextStyle(color: kPrimaryColor, fontSize: 18)),
                    // //     )
                    // //   ],
                    // // ),
                    // mobile_hidden == "1"
                    //     ? const SizedBox()
                    //     : const SizedBox(height: 20),
                    // mobile_hidden == "1"
                    //     ? const SizedBox()
                    //     : Row(
                    //         crossAxisAlignment: CrossAxisAlignment.start,
                    //         children: [
                    //           const Text("Mobile : ",
                    //               style: TextStyle(
                    //                   color: Colors.deepOrange,
                    //                   fontSize: 18,
                    //                   fontWeight: FontWeight.bold)),
                    //           SizedBox(
                    //             width: size.width * 0.70,
                    //             child: mobile == null || mobile == "null"
                    //                 ? const SizedBox()
                    //                 : Text(mobile,
                    //                     maxLines: 1,
                    //                     style:  TextStyle(
                    //                         color: Colors.blue[900],
                    //                         fontSize: 18)),
                    //           )
                    //         ],
                    //       ),
                    // Divider(thickness: 0.9),

                    // const SizedBox(height: 20),
                    // Row(
                    //   crossAxisAlignment: CrossAxisAlignment.start,
                    //   children: [
                    //     const Text("Email : ",
                    //         style: TextStyle(
                    //             color: Colors.deepOrange,
                    //             fontSize: 18,
                    //             fontWeight: FontWeight.bold)),
                    //     SizedBox(
                    //       width: size.width * 0.75,
                    //       child: email == null || email == "null"
                    //           ? const SizedBox()
                    //           : Text(email,
                    //               maxLines: 1,
                    //               style:  TextStyle(
                    //                   color: Colors.blue[900], fontSize: 18)),
                    //     )
                    //   ],
                    // ),
                    // const SizedBox(height: 20),
                    Divider(thickness: 0.9),
                  ],
                ),
              ),
            ),
    );
  }

  String adId = "";

  Future _getpreproductDetail(String productid) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    print("User ID ${prefs.getString('userid')}");
    print("Preview ID $productid");
    final body = {
      "id": productid,
    };
    var response = await http.post(Uri.parse(BASE_URL + previewpost),
        body: jsonEncode(body),
        headers: {
          "Accept": "application/json",
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${prefs.getString("token")}',
        });
    if (response.statusCode == 200) {
      var data = json.decode(response.body)['Response'];
      setState(() {
        productimage = devImage +
            data['Images'][0]['upload_base_path'] +
            data['Images'][0]['file_name'].toString();
        productimages.addAll(data['Images']);

        productname = data['posted_ad']['title'].toString();
        final document = parse(data['posted_ad']['description'].toString());
        description = parse(document.body.text).documentElement.text.toString();
        boostpack = data['posted_ad']['boost_package_status'].toString();
        renttype = data['posted_ad']['rent_type'].toString();
        adId = data['posted_ad']['ad_id'].toString();

        List temp = [];
        data['Pricing'].forEach((element) {
          if (element['status'] == 1) {
            temp.add(element['status'] == 1
                ? "INR ${element['price']} (${element['rent_type_name']})"
                : "");
          }
        });

        productprice = temp.join("/").toString();
        negotiate = data['posted_ad']['negotiate'].toString();

        securitydeposit = data['posted_ad']['security'].toString();

        email = data['posted_ad']['email'].toString();
        mobile = data['posted_ad']['mobile'].toString();
        mobile_hidden = data['posted_ad']['mobile_hidden'].toString();

        _checkData = true;
        // addedbyid = data['Additional']['added-by']['id'].toString();
        // addedby = data['Additional']['added-by']['name'].toString();
        //   address =
        //     "${data['Additional']['added-by']['address']}, ${data['Additional']['added-by']['city_name']}, ${data['Additional']['added-by']['state_name']}, ${data['Additional']['added-by']['pincode']}, ${data['Additional']['added-by']['country_name']}";
      });
    } else {
      throw Exception('Failed to get data due to ${response.body}');
    }
  }
}
