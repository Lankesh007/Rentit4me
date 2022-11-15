// ignore_for_file: use_build_context_synchronously

import 'dart:convert';
import 'dart:developer';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:rentit4me_new/helper/dialog_helper.dart';
import 'package:rentit4me_new/network/api.dart';
import 'package:rentit4me_new/themes/constant.dart';
import 'package:rentit4me_new/views/account.dart';
import 'package:rentit4me_new/views/alllisting_screen.dart';
import 'package:rentit4me_new/views/add_list_screen.dart';
import 'package:rentit4me_new/views/change_password.dart';
import 'package:rentit4me_new/views/chat_screen.dart';
import 'package:rentit4me_new/views/generate_ticket_screen.dart';
import 'package:rentit4me_new/views/login_screen.dart';
import 'package:rentit4me_new/views/message_screen.dart';
import 'package:rentit4me_new/views/myticket_screen.dart';
import 'package:rentit4me_new/views/payment_screen.dart';
import 'package:rentit4me_new/views/pending_status_screen.dart';
import 'package:rentit4me_new/views/profile_screen.dart';
import 'package:rentit4me_new/views/select_membership_screen.dart';
import 'package:rentit4me_new/views/user_detail_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

import '../views/change_password_screen.dart';
import '../views/offers_view.dart';
import '../views/order_view.dart';
import '../views/upgrade_membership_screen.dart';

class NavigationDrawerWidget extends StatefulWidget {
  final int isSignedUp;
  const NavigationDrawerWidget({this.isSignedUp, Key key}) : super(key: key);

  @override
  State<NavigationDrawerWidget> createState() => _NavigationDrawerWidgetState();
}

class _NavigationDrawerWidgetState extends State<NavigationDrawerWidget> {
  final padding = const EdgeInsets.symmetric(horizontal: 20);

  String name;
  String email;
  String urlImage;
  String mobile;
  bool profilebackButton = false;

  //Check Approval
  String usertype;
  String trustedbadge;
  String trustedbadgeapproval;

  @override
  void initState() {
    super.initState();
    _getuserdetail();
    _getcheckapproveData();
    _getprofileData();
  }

  String userId = '';

  Future _getuserdetail() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    userId = prefs.getString('userid');
    if (prefs.getString('name') == null ||
        prefs.getString('name') == "" ||
        prefs.getString('name') == "null") {
      Future temp = _getprofileData();
      temp.then((value) {
        if (value != null) {
          setState(() {
            urlImage = devImage + value['User']['avatar_path'].toString();
            name = value['User']['name'].toString() == null
                ? "Hi Guest"
                : prefs.getString('name');
            email = value['User']['email'].toString();
            mobile = value['User']['mobile'].toString();
          });
        }
      });

      _setUserdetail(urlImage, name, email, mobile);
    } else {
      setState(() {
        urlImage = prefs.getString('profile');
        name = prefs.getString('name') ?? "Hi Guest";
        email = prefs.getString('email');
        mobile = prefs.getString('mobile');
      });
    }
  }

  getdata() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();

    preferences.setBool("profileBackButton", profilebackButton);
  }

  void _setUserdetail(
      String profilepicurl, String name, String email, String mobile) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    try {
      prefs.setString('profile', devImage + profilepicurl);
      prefs.setString('name', name);
      prefs.setString('email', email);
      prefs.setString('mobile', mobile);
    } catch (e) {
      setState(() {
        name = "Hi Guest";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Material(
        color: kPrimaryColor,
        child: ListView(
          children: <Widget>[
            buildHeader(
                urlImage: urlImage,
                name: name,
                email: email,
                onClicked: () => Navigator.of(context).pop()),
            Container(
              width: MediaQuery.of(context).size.width * 0.9,
              child: Column(
                children: [
                  const SizedBox(height: 20),
                  InkWell(
                    // onTap: (){
                    //   if(widget.isSignedUp==1){

                    //   }else{}
                    // },
                    child: ExpansionTile(
                      iconColor: Colors.white,
                      collapsedIconColor: const Color(0xFFFFFFFF),
                      title: const Text("MY ACCOUNT",
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w700)),
                      children: <Widget>[
                        InkWell(
                          onTap: () async {
                            SharedPreferences prefs =
                                await SharedPreferences.getInstance();
                            if (prefs.getString('userid') == null ||
                                prefs.getString('userid') == "") {
                              Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) =>
                                              const LoginScreen()))
                                  .then((value) => Navigator.of(context).pop());
                            } else {
                              if (profilebackButton == false) {
                                setState(() {
                                  profilebackButton = true;
                                });
                                getdata();
                              }

                              Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) =>
                                              const UserDetailScreen()))
                                  .then((value) => Navigator.of(context).pop());
                            }
                          },
                          child: const Align(
                              alignment: Alignment.topLeft,
                              child: Padding(
                                padding: EdgeInsets.symmetric(
                                    horizontal: 20, vertical: 3),
                                child: Text("My Profile",
                                    style: TextStyle(
                                        color: Colors.white, fontSize: 16)),
                              )),
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        InkWell(
                          onTap: () async {
                            SharedPreferences prefs =
                                await SharedPreferences.getInstance();
                            if (prefs.getString('userid') == null ||
                                prefs.getString('userid') == "") {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) =>
                                          const LoginScreen()));
                            } else {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => UpgradeMemberShip(
                                          pageswitch: "Home")));
                            }
                          },
                          child: const Align(
                              alignment: Alignment.topLeft,
                              child: Padding(
                                padding: EdgeInsets.symmetric(
                                    horizontal: 20, vertical: 3),
                                child: Text("My Subscriptions",
                                    style: TextStyle(
                                        color: Colors.white, fontSize: 16)),
                              )),
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        InkWell(
                          onTap: () async {
                            SharedPreferences prefs =
                                await SharedPreferences.getInstance();
                            if (prefs.getString('userid') == null ||
                                prefs.getString('userid') == "") {
                              Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) =>
                                              const LoginScreen()))
                                  .then((value) => Navigator.of(context).pop());
                            } else {
                              Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) =>
                                              const PaymentScreen()))
                                  .then((value) => Navigator.of(context).pop());
                            }
                          },
                          child: const Align(
                              alignment: Alignment.topLeft,
                              child: Padding(
                                padding: EdgeInsets.symmetric(
                                    horizontal: 20, vertical: 3),
                                child: Text("My Transactions",
                                    style: TextStyle(
                                        color: Colors.white, fontSize: 16)),
                              )),
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        InkWell(
                          onTap: () async {
                            SharedPreferences prefs =
                                await SharedPreferences.getInstance();
                            if (prefs.getString('userid') == null ||
                                prefs.getString('userid') == "") {
                              Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) =>
                                              const LoginScreen()))
                                  .then((value) => Navigator.of(context).pop());
                            } else {
                              Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) =>
                                              const ChangePasswordScreens()))
                                  .then((value) => Navigator.of(context).pop());
                            }
                          },
                          child: const Align(
                              alignment: Alignment.topLeft,
                              child: Padding(
                                padding: EdgeInsets.symmetric(
                                    horizontal: 20, vertical: 3),
                                child: Text("Change Password",
                                    style: TextStyle(
                                        color: Colors.white, fontSize: 16)),
                              )),
                        ),
                      ],
                    ),
                  ),
                  const Divider(color: Colors.white70),
                  ExpansionTile(
                    iconColor: Colors.white,
                    collapsedIconColor: Colors.white,
                    title: const Text("MY LISTING",
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w700)),
                    children: <Widget>[
                      InkWell(
                        onTap: () async {
                          SharedPreferences prefs =
                              await SharedPreferences.getInstance();
                          if (prefs.getString('userid') == null ||
                              prefs.getString('userid') == "") {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => LoginScreen()));
                          } else {
                            Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) =>
                                            AddlistingScreen()))
                                .then((value) => Navigator.of(context).pop());
                          }
                        },
                        child: const Align(
                          alignment: Alignment.topLeft,
                          child: Padding(
                            padding: EdgeInsets.symmetric(
                                horizontal: 20, vertical: 3),
                            child: Text("Create New Listing",
                                style: TextStyle(
                                    color: Colors.white, fontSize: 16)),
                          ),
                        ),
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      InkWell(
                        onTap: () async {
                          SharedPreferences prefs =
                              await SharedPreferences.getInstance();
                          if (prefs.getString('userid') == null ||
                              prefs.getString('userid') == "") {
                            Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => LoginScreen()))
                                .then((value) => Navigator.of(context).pop());
                          } else {
                            Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) =>
                                            AlllistingScreen()))
                                .then((value) => Navigator.of(context).pop());
                          }
                        },
                        child: const Align(
                          alignment: Alignment.topLeft,
                          child: Padding(
                            padding: EdgeInsets.symmetric(
                                horizontal: 20, vertical: 3),
                            child: Text("All Listing",
                                style: TextStyle(
                                    color: Colors.white, fontSize: 16)),
                          ),
                        ),
                      ),
                      // InkWell(
                      //   onTap: () async {
                      //     SharedPreferences prefs =
                      //         await SharedPreferences.getInstance();
                      //     if (prefs.getString('userid') == null ||
                      //         prefs.getString('userid') == "") {
                      //       Navigator.push(
                      //               context,
                      //               MaterialPageRoute(
                      //                   builder: (context) => LoginScreen()))
                      //           .then((value) => Navigator.of(context).pop());
                      //     } else {
                      //       if (trustedbadge == "1") {
                      //         if (trustedbadgeapproval == "Pending" ||
                      //             trustedbadgeapproval == "pending") {
                      //           Navigator.push(
                      //               context,
                      //               MaterialPageRoute(
                      //                   builder: (context) =>
                      //                       PendingStatusScreen())).then(
                      //               (value) => Navigator.of(context).pop());
                      //         } else {
                      //           Navigator.push(
                      //               context,
                      //               MaterialPageRoute(
                      //                   builder: (context) =>
                      //                       ActivelistingScreen())).then(
                      //               (value) => Navigator.of(context).pop());
                      //         }
                      //       } else {
                      //         Navigator.push(
                      //                 context,
                      //                 MaterialPageRoute(
                      //                     builder: (context) =>
                      //                         ActivelistingScreen()))
                      //             .then((value) => Navigator.of(context).pop());
                      //       }
                      //     }
                      //   },
                      //   child: const Align(
                      //     alignment: Alignment.topLeft,
                      //     child: Padding(
                      //                                      padding: EdgeInsets.symmetric(horizontal: 20,vertical: 3),

                      //       child: Text("Active Listing",
                      //           style: TextStyle(
                      //               color: Colors.white, fontSize: 16)),
                      //     ),
                      //   ),
                      // ),
                      // InkWell(
                      //   onTap: () async {
                      //     SharedPreferences prefs =
                      //         await SharedPreferences.getInstance();
                      //     if (prefs.getString('userid') == null ||
                      //         prefs.getString('userid') == "") {
                      //       Navigator.push(
                      //               context,
                      //               MaterialPageRoute(
                      //                   builder: (context) => LoginScreen()))
                      //           .then((value) => Navigator.of(context).pop());
                      //     } else {
                      //       if (trustedbadge == "1") {
                      //         if (trustedbadgeapproval == "Pending" ||
                      //             trustedbadgeapproval == "pending") {
                      //           Navigator.push(
                      //               context,
                      //               MaterialPageRoute(
                      //                   builder: (context) =>
                      //                       PendingStatusScreen())).then(
                      //               (value) => Navigator.of(context).pop());
                      //         } else {
                      //           Navigator.push(
                      //               context,
                      //               MaterialPageRoute(
                      //                   builder: (context) =>
                      //                       InactivelsitingScreen())).then(
                      //               (value) => Navigator.of(context).pop());
                      //         }
                      //       } else {
                      //         Navigator.push(
                      //                 context,
                      //                 MaterialPageRoute(
                      //                     builder: (context) =>
                      //                         InactivelsitingScreen()))
                      //             .then((value) => Navigator.of(context).pop());
                      //       }
                      //     }
                      //   },
                      //   child: const Align(
                      //     alignment: Alignment.topLeft,
                      //     child: Padding(
                      //                                      padding: EdgeInsets.symmetric(horizontal: 20,vertical: 3),

                      //       child: Text("Inactive Listing",
                      //           style: TextStyle(
                      //               color: Colors.white, fontSize: 16)),
                      //     ),
                      //   ),
                      // ),
                      // InkWell(
                      //   onTap: () async {
                      //     SharedPreferences prefs =
                      //         await SharedPreferences.getInstance();
                      //     if (prefs.getString('userid') == null ||
                      //         prefs.getString('userid') == "") {
                      //       Navigator.push(
                      //               context,
                      //               MaterialPageRoute(
                      //                   builder: (context) => LoginScreen()))
                      //           .then((value) => Navigator.of(context).pop());
                      //     } else {
                      //       if (trustedbadge == "1") {
                      //         if (trustedbadgeapproval == "Pending" ||
                      //             trustedbadgeapproval == "pending") {
                      //           Navigator.push(
                      //               context,
                      //               MaterialPageRoute(
                      //                   builder: (context) =>
                      //                       PendingStatusScreen())).then(
                      //               (value) => Navigator.of(context).pop());
                      //         } else {
                      //           Navigator.push(
                      //               context,
                      //               MaterialPageRoute(
                      //                   builder: (context) =>
                      //                       PromotedlistScreen())).then(
                      //               (value) => Navigator.of(context).pop());
                      //         }
                      //       } else {
                      //         Navigator.push(
                      //                 context,
                      //                 MaterialPageRoute(
                      //                     builder: (context) =>
                      //                         PromotedlistScreen()))
                      //             .then((value) => Navigator.of(context).pop());
                      //       }
                      //     }
                      //   },
                      //   child: const Align(
                      //     alignment: Alignment.topLeft,
                      //     child: Padding(
                      //                                      padding: EdgeInsets.symmetric(horizontal: 20,vertical: 3),

                      //       child: Text("Promoted Listing",
                      //           style: TextStyle(
                      //               color: Colors.white, fontSize: 16)),
                      //     ),
                      //   ),
                      // ),
                    ],
                  ),
                  const Divider(color: Colors.white70),
                  ExpansionTile(
                    collapsedIconColor: Colors.white,
                    iconColor: Colors.white,
                    title: const Text("MY INBOX",
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w700)),
                    children: <Widget>[
                      InkWell(
                        onTap: () async {
                          SharedPreferences prefs =
                              await SharedPreferences.getInstance();
                          if (prefs.getString('userid') == null ||
                              prefs.getString('userid') == "") {
                            Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => LoginScreen()))
                                .then((value) => Navigator.of(context).pop());
                          } else {
                            Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => ChatScreen()))
                                .then((value) => Navigator.of(context).pop());
                          }
                        },
                        child: const Align(
                          alignment: Alignment.topLeft,
                          child: Padding(
                            padding: EdgeInsets.symmetric(
                                horizontal: 20, vertical: 3),
                            child: Text("Chat",
                                style: TextStyle(
                                    color: Colors.white, fontSize: 16)),
                          ),
                        ),
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      InkWell(
                        onTap: () async {
                          SharedPreferences prefs =
                              await SharedPreferences.getInstance();
                          if (prefs.getString('userid') == null ||
                              prefs.getString('userid') == "") {
                            Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => LoginScreen()))
                                .then((value) => Navigator.of(context).pop());
                          } else {
                            Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => MessageScreen()))
                                .then((value) => Navigator.of(context).pop());
                          }
                        },
                        child: const Align(
                          alignment: Alignment.topLeft,
                          child: Padding(
                            padding: EdgeInsets.symmetric(
                                horizontal: 20, vertical: 3),
                            child: Text("Notifications",
                                style: TextStyle(
                                    color: Colors.white, fontSize: 16)),
                          ),
                        ),
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      // InkWell(
                      //   onTap: () async {
                      //     SharedPreferences prefs =
                      //         await SharedPreferences.getInstance();
                      //     if (prefs.getString('userid') == null ||
                      //         prefs.getString('userid') == "") {
                      //       Navigator.push(
                      //               context,
                      //               MaterialPageRoute(
                      //                   builder: (context) => LoginScreen()))
                      //           .then((value) => Navigator.of(context).pop());
                      //     } else {
                      //       if (trustedbadge == "1") {
                      //         if (trustedbadgeapproval == "Pending" ||
                      //             trustedbadgeapproval == "pending") {
                      //           Navigator.push(
                      //               context,
                      //               MaterialPageRoute(
                      //                   builder: (context) =>
                      //                       PendingStatusScreen())).then(
                      //               (value) => Navigator.of(context).pop());
                      //         } else {
                      //           Navigator.push(
                      //               context,
                      //               MaterialPageRoute(
                      //                   builder: (context) =>
                      //                       OfferMadeScreen())).then(
                      //               (value) => Navigator.of(context).pop());
                      //         }
                      //       } else {
                      //         Navigator.push(
                      //                 context,
                      //                 MaterialPageRoute(
                      //                     builder: (context) =>
                      //                         OfferMadeScreen()))
                      //             .then((value) => Navigator.of(context).pop());
                      //       }
                      //     }
                      //   },
                      //   child: const Align(
                      //     alignment: Alignment.topLeft,
                      //     child: Padding(
                      //       padding: EdgeInsets.symmetric(
                      //           horizontal: 20, vertical: 3),
                      //       child: Text("Offers Made",
                      //           style: TextStyle(
                      //               color: Colors.white, fontSize: 16)),
                      //     ),
                      //   ),
                      // ),
                      // SizedBox(
                      //   height: 10,
                      // ),
                      // InkWell(
                      //   onTap: () async {
                      //     SharedPreferences prefs =
                      //         await SharedPreferences.getInstance();
                      //     if (prefs.getString('userid') == null ||
                      //         prefs.getString('userid') == "") {
                      //       Navigator.push(
                      //               context,
                      //               MaterialPageRoute(
                      //                   builder: (context) => LoginScreen()))
                      //           .then((value) => Navigator.of(context).pop());
                      //     } else {
                      //       if (trustedbadge == "1") {
                      //         if (trustedbadgeapproval == "Pending" ||
                      //             trustedbadgeapproval == "pending") {
                      //           Navigator.push(
                      //               context,
                      //               MaterialPageRoute(
                      //                   builder: (context) =>
                      //                       PendingStatusScreen())).then(
                      //               (value) => Navigator.of(context).pop());
                      //         } else {
                      //           Navigator.push(
                      //               context,
                      //               MaterialPageRoute(
                      //                   builder: (context) =>
                      //                       OfferRecievedScreen())).then(
                      //               (value) => Navigator.of(context).pop());
                      //         }
                      //       } else {
                      //         Navigator.push(
                      //                 context,
                      //                 MaterialPageRoute(
                      //                     builder: (context) =>
                      //                         OfferRecievedScreen()))
                      //             .then((value) => Navigator.of(context).pop());
                      //       }
                      //     }
                      //   },
                      //   child: const Align(
                      //     alignment: Alignment.topLeft,
                      //     child: Padding(
                      //       padding: EdgeInsets.symmetric(
                      //           horizontal: 20, vertical: 3),
                      //       child: Text("Offers Received",
                      //           style: TextStyle(
                      //               color: Colors.white, fontSize: 16)),
                      //     ),
                      //   ),
                      // ),
                    ],
                  ),
                  const Divider(color: Colors.white70),
                  ExpansionTile(
                    collapsedIconColor: Colors.white,
                    iconColor: Colors.white,
                    title: const Text("ORDERS",
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w700)),
                    children: <Widget>[
                      InkWell(
                        onTap: () async {
                          SharedPreferences prefs =
                              await SharedPreferences.getInstance();
                          if (prefs.getString('userid') == null ||
                              prefs.getString('userid') == "") {
                            Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => LoginScreen()))
                                .then((value) => Navigator.of(context).pop());
                          } else {
                            Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) =>
                                            OffersViewScreen()))
                                .then((value) => Navigator.of(context).pop());
                          }
                        },
                        child: const Align(
                          alignment: Alignment.topLeft,
                          child: Padding(
                            padding: EdgeInsets.symmetric(
                                horizontal: 20, vertical: 3),
                            child: Text("Offers Made",
                                style: TextStyle(
                                    color: Colors.white, fontSize: 16)),
                          ),
                        ),
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      InkWell(
                        onTap: () async {
                          SharedPreferences prefs =
                              await SharedPreferences.getInstance();
                          if (prefs.getString('userid') == null ||
                              prefs.getString('userid') == "") {
                            Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => LoginScreen()))
                                .then((value) => Navigator.of(context).pop());
                          } else {
                            Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) =>
                                            OffersViewScreen()))
                                .then((value) => Navigator.of(context).pop());
                          }
                        },
                        child: const Align(
                          alignment: Alignment.topLeft,
                          child: Padding(
                              padding: EdgeInsets.symmetric(
                                  horizontal: 20, vertical: 3),
                              child: Text("Offers Received",
                                  style: TextStyle(
                                      color: Colors.white, fontSize: 16))),
                        ),
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      InkWell(
                        onTap: () async {
                          SharedPreferences prefs =
                              await SharedPreferences.getInstance();
                          if (prefs.getString('userid') == null ||
                              prefs.getString('userid') == "") {
                            Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => LoginScreen()))
                                .then((value) => Navigator.of(context).pop());
                          } else {
                            Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) =>
                                            OrderViewScreen()))
                                .then((value) => Navigator.of(context).pop());
                          }
                        },
                        child: const Align(
                          alignment: Alignment.topLeft,
                          child: Padding(
                            padding: EdgeInsets.symmetric(
                                horizontal: 20, vertical: 3),
                            child: Text("Orders Made",
                                style: TextStyle(
                                    color: Colors.white, fontSize: 16)),
                          ),
                        ),
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      InkWell(
                        onTap: () async {
                          SharedPreferences prefs =
                              await SharedPreferences.getInstance();
                          if (prefs.getString('userid') == null ||
                              prefs.getString('userid') == "") {
                            Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => LoginScreen()))
                                .then((value) => Navigator.of(context).pop());
                          } else {
                            Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) =>
                                            const OrderViewScreen()))
                                .then((value) => Navigator.of(context).pop());
                          }
                        },
                        child: const Align(
                          alignment: Alignment.topLeft,
                          child: Padding(
                            padding: EdgeInsets.symmetric(
                                horizontal: 20, vertical: 3),
                            child: Text("Orders Received",
                                style: TextStyle(
                                    color: Colors.white, fontSize: 16)),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const Divider(color: Colors.white70),
                  // ExpansionTile(
                  //   iconColor: Colors.white,
                  //   collapsedIconColor: Colors.white,
                  //   title: const Text("MANAGE PROFILE",
                  //       style: TextStyle(
                  //           color: Colors.white,
                  //           fontSize: 16,
                  //           fontWeight: FontWeight.w700)),
                  //   children: <Widget>[
                  //     InkWell(
                  //       onTap: () async {
                  //         SharedPreferences prefs =
                  //             await SharedPreferences.getInstance();
                  //         if (prefs.getString('userid') == null ||
                  //             prefs.getString('userid') == "") {
                  //           Navigator.push(
                  //                   context,
                  //                   MaterialPageRoute(
                  //                       builder: (context) => LoginScreen()))
                  //               .then((value) => Navigator.of(context).pop());
                  //         } else {
                  //           if (trustedbadge == "1") {
                  //             if (trustedbadgeapproval == null ||
                  //                 trustedbadgeapproval == "null" ||
                  //                 trustedbadgeapproval == "" ||
                  //                 trustedbadgeapproval == "Pending" ||
                  //                 trustedbadgeapproval == "pending") {
                  //               Navigator.push(
                  //                   context,
                  //                   MaterialPageRoute(
                  //                       builder: (context) =>
                  //                           const PendingStatusScreen())).then(
                  //                   (value) => Navigator.of(context).pop());
                  //             } else {
                  //               Navigator.push(
                  //                   context,
                  //                   MaterialPageRoute(
                  //                       builder: (context) =>
                  //                           const UserDetailScreen())).then(
                  //                   (value) => Navigator.of(context).pop());
                  //             }
                  //           } else {
                  //             Navigator.push(
                  //                     context,
                  //                     MaterialPageRoute(
                  //                         builder: (context) =>
                  //                             const UserDetailScreen()))
                  //                 .then((value) => Navigator.of(context).pop());
                  //           }
                  //         }
                  //       },
                  //       child: const Align(
                  //         alignment: Alignment.topLeft,
                  //         child: Padding(
                  //           padding: EdgeInsets.symmetric(
                  //               horizontal: 20, vertical: 3),
                  //           child: Text("Basic Detail",
                  //               style: TextStyle(
                  //                   color: Colors.white, fontSize: 16)),
                  //         ),
                  //       ),
                  //     ),
                  //     SizedBox(
                  //       height: 10,
                  //     ),
                  //     InkWell(
                  //       onTap: () async {
                  //         SharedPreferences prefs =
                  //             await SharedPreferences.getInstance();
                  //         if (prefs.getString('userid') == null ||
                  //             prefs.getString('userid') == "") {
                  //           Navigator.push(
                  //                   context,
                  //                   MaterialPageRoute(
                  //                       builder: (context) =>
                  //                           const LoginScreen()))
                  //               .then((value) => Navigator.of(context).pop());
                  //         } else {
                  //           Navigator.push(
                  //                   context,
                  //                   MaterialPageRoute(
                  //                       builder: (context) =>
                  //                           const ChangePasswordScreen()))
                  //               .then((value) => Navigator.of(context).pop());
                  //         }
                  //       },
                  //       child: const Align(
                  //         alignment: Alignment.topLeft,
                  //         child: Padding(
                  //           padding: EdgeInsets.symmetric(
                  //               horizontal: 20, vertical: 3),
                  //           child: Text("Security",
                  //               style: TextStyle(
                  //                   color: Colors.white, fontSize: 16)),
                  //         ),
                  //       ),
                  //     ),
                  //   ],
                  // ),

                  ExpansionTile(
                    collapsedIconColor: Colors.white,
                    iconColor: Colors.white,
                    title: Text(
                      "SUPPORT",
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w700),
                    ),
                    children: [
                      InkWell(
                        onTap: () async {
                          SharedPreferences prefs =
                              await SharedPreferences.getInstance();
                          if (prefs.getString('userid') == null ||
                              prefs.getString('userid') == "") {
                            Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) =>
                                            const LoginScreen()))
                                .then((value) => Navigator.of(context).pop());
                          } else {
                            if (trustedbadge == "1") {
                              if (trustedbadgeapproval == "Pending" ||
                                  trustedbadgeapproval == "pending") {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) =>
                                            const PendingStatusScreen())).then(
                                    (value) => Navigator.of(context).pop());
                              } else {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) =>
                                            GenerateTicketScreen())).then(
                                    (value) => Navigator.of(context).pop());
                              }
                            } else {
                              Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) =>
                                              GenerateTicketScreen()))
                                  .then((value) => Navigator.of(context).pop());
                            }
                          }
                        },
                        child: const Align(
                            alignment: Alignment.topLeft,
                            child: Padding(
                              padding: EdgeInsets.symmetric(
                                  horizontal: 20, vertical: 3),
                              child: Text("Create New Ticket",
                                  style: TextStyle(
                                      color: Colors.white, fontSize: 16)),
                            )),
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      InkWell(
                        onTap: () async {
                          SharedPreferences prefs =
                              await SharedPreferences.getInstance();
                          if (prefs.getString('userid') == null ||
                              prefs.getString('userid') == "") {
                            Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => LoginScreen()))
                                .then((value) => Navigator.of(context).pop());
                          } else {
                            if (trustedbadge == "1") {
                              if (trustedbadgeapproval == "Pending" ||
                                  trustedbadgeapproval == "pending") {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) =>
                                            PendingStatusScreen())).then(
                                    (value) => Navigator.of(context).pop());
                              } else {
                                Navigator.of(context)
                                    .push(MaterialPageRoute(
                                        builder: (context) => MyticketScreen()))
                                    .then(
                                        (value) => Navigator.of(context).pop());
                              }
                            } else {
                              Navigator.of(context)
                                  .push(MaterialPageRoute(
                                      builder: (context) => MyticketScreen()))
                                  .then((value) => Navigator.of(context).pop());
                            }
                          }
                        },
                        child: const Align(
                            alignment: Alignment.topLeft,
                            child: Padding(
                              padding: EdgeInsets.symmetric(
                                  horizontal: 20, vertical: 3),
                              child: Text("My Ticket",
                                  style: TextStyle(
                                      color: Colors.white, fontSize: 16)),
                            )),
                      ),
                    ],
                  )
                ],
              ),
            ),
            Divider(
              thickness: 0.9,
              color: Colors.white,
            ),
            SizedBox(
              height: 15,
            ),
            userId == "" || userId == null || userId == "null"
                ? Text("")
                : Column(
                    children: [
                      InkWell(
                        onTap: () {
                          DialogHelper.logout(context);
                        },
                        child: Container(
                          alignment: Alignment.center,
                          child: Text(
                            "Logout",
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 20,
                                fontWeight: FontWeight.w600),
                          ),
                        ),
                      ),
                      SizedBox(
                        height: 15,
                      ),
                      Divider(
                        thickness: 0.9,
                        color: Colors.white,
                      ),
                    ],
                  ),
          ],
        ),
      ),
    );
  }

  Widget buildHeader(
      {String urlImage, String name, String email, VoidCallback onClicked}) {
    return Column(
      children: [
        InkWell(
          onTap: onClicked,
          child: Container(
            padding: padding.add(const EdgeInsets.symmetric(vertical: 15)),
            child: const Align(
              alignment: Alignment.topLeft,
              child: CircleAvatar(
                radius: 20,
                backgroundColor: Colors.grey,
                child: Icon(Icons.close, color: Colors.white),
              ),
            ),
          ),
        ),
        ClipRRect(
          borderRadius: BorderRadius.circular(40),
          child: urlImage == "" || urlImage == null || urlImage == "null"
              ? SizedBox(
                  height: 80,
                  width: 80,
                  child: Image.asset('assets/images/profile_placeholder.png',
                      fit: BoxFit.fill, color: Colors.white))
              : Container(
                  height: 80,
                  width: 80,
                  decoration: BoxDecoration(
                      border: Border.all(color: Colors.white, width: 1),
                      shape: BoxShape.circle),
                  child: CachedNetworkImage(
                    imageUrl: urlImage,
                    imageBuilder: (context, imageProvider) => Container(
                      decoration: BoxDecoration(
                        //border: Border.all(color: Colors.white, width: 2),
                        //borderRadius: BorderRadius.circular(8.0),
                        image: DecorationImage(
                            image: imageProvider,
                            fit: BoxFit.cover,
                            colorFilter: ColorFilter.mode(
                                Colors.white, BlendMode.colorBurn)),
                      ),
                    ),
                    errorWidget: (context, url, error) => Image.asset(
                        'assets/images/profile_placeholder.png',
                        color: Colors.white),
                  ),
                ),
        ),
        SizedBox(height: 15.0),
        name == "" || name == null
            ? Text("")
            : Text(name,
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 21,
                    fontWeight: FontWeight.w700)),
        SizedBox(height: 5.0),
        email == "" || email == null
            ? Text("")
            : Text(email, style: TextStyle(color: Colors.white, fontSize: 14))
      ],
    );
  }

  Widget buildMenuItem({
    String text,
    IconData icon,
    VoidCallback onClicked,
  }) {
    const color = Colors.white;
    const hoverColor = Colors.white70;

    return ListTile(
      leading: Icon(icon, color: color),
      title: Text(text, style: const TextStyle(color: color)),
      hoverColor: hoverColor,
      onTap: onClicked,
    );
  }

  void selectedItem(BuildContext context, int index) {
    Navigator.of(context).pop();
    switch (index) {
      case 0:
        Navigator.of(context).push(MaterialPageRoute(
          builder: (context) => ProfileScreen(),
        ));
        break;
      case 1:
        break;
      case 2:
        Navigator.of(context).push(MaterialPageRoute(
          builder: (context) => SelectMemberShipScreen(),
        ));
        break;
      case 3:
        DialogHelper.logout(context);
        break;
    }
  }

  Future _getprofileData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    log(prefs.getString('userid').toString());
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
        urlImage = devImage + data['User']['avatar_path'];
        log("image url----->$urlImage");
      });

      return data;
    } else {
      throw Exception('Failed to get data due to ${response.body}');
    }
  }

  Future _getcheckapproveData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final body = {
      //"user_id": "846",  //this is business user id
      "user_id": prefs.getString('userid'),
    };
    var response = await http.post(Uri.parse(BASE_URL + checkapprove),
        body: jsonEncode(body),
        headers: {
          "Accept": "application/json",
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${prefs.getString("token")}',
        });
    if (response.statusCode == 200) {
      var data = json.decode(response.body)['Response'];
      if (data != null) {
        if (mounted == true) {
          setState(() {
            usertype = data['user_type'].toString();
            trustedbadge = data['trusted_badge'].toString();
            trustedbadgeapproval = data['trusted_badge_approval'].toString();
          });
        }
      }
    } else {
      throw Exception('Failed to get data due to ${response.body}');
    }
  }
}
