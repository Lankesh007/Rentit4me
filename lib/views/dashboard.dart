// ignore_for_file: non_constant_identifier_names

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:rentit4me_new/network/api.dart';
import 'package:http/http.dart' as http;
import 'package:rentit4me_new/views/account.dart';
import 'package:rentit4me_new/views/add_list_screen.dart';
import 'package:rentit4me_new/views/bottomNavigation.dart';
import 'package:rentit4me_new/views/home_screen.dart';
import 'package:rentit4me_new/views/offer_made_screen.dart';
import 'package:rentit4me_new/views/offers_view.dart';
import 'package:rentit4me_new/views/order_view.dart';
import 'package:rentit4me_new/views/tab_item.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Dashboard extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => DashboardState();
}

class DashboardState extends State<Dashboard> {
  // this is static property so other widget throughout the app
  // can access it simply by AppState.currentTab
  static int currentTab = 0;
  // list tabs here
  final List<TabItem> tabs = [
    TabItem(
      tabName: "Home",
      icon: "home.png",
      page: HomeScreen(),
    ),
    TabItem(tabName: "Offer", icon: "offer.png", page: OffersViewScreen()),
    TabItem(tabName: "Orders", icon: "order.png", page: OrderViewScreen()),
    TabItem(tabName: "Listing", icon: "ads.png", page: AddlistingScreen()),
    TabItem(tabName: "Account", icon: "account.png", page: AccountViewScreen()),
  ];

  DashboardState() {
    // indexing is necessary for proper funcationality
    // of determining which tab is active
    tabs.asMap().forEach((index, details) {
      details.setIndex(index);
    });
  }

  // sets current tab index
  // and update state
  void _selectTab(int index) {
    if (index == currentTab) {
      tabs[index].key.currentState?.popUntil((route) => route.isFirst);
    } else {
      // update the state
      // in order to repaint
      setState(() => currentTab = index);
    }
  }

  @override
  void initState() {
    super.initState();
    _getuserdetail();
  }

  @override
  Widget build(BuildContext context) {
    // WillPopScope handle android back btn
    return WillPopScope(
      onWillPop: () async {
        final isFirstRouteInCurrentTab =
            !await tabs[currentTab].key.currentState.maybePop();
        if (isFirstRouteInCurrentTab) {
          // if not on the 'main' tab
          if (currentTab != 0) {
            // select 'main' tab
            _selectTab(0);
            // back button handled by app
            return false;
          }
        }
        // let system handle back button if we're on the first route
        return isFirstRouteInCurrentTab;
      },
      // this is the base scaffold
      // don't put appbar in here otherwise you might end up
      // with multiple appbars on one screen
      // eventually breaking the app
      child: Scaffold(
          // indexed stack shows only one child
          body: IndexedStack(
            index: currentTab,
            children: tabs.map((e) => e.page).toList(),
          ),
          // Bottom navigation

          bottomNavigationBar: BottomNavigation(
            onSelectTab: _selectTab,
            tabs: tabs,
          )),
    );
  }

  Future _getuserdetail() async {
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
      if (json.decode(response.body)['Response'] != null) {
        prefs.setString(
            'quickid',
            json
                .decode(response.body)['Response']['User']['quickblox_id']
                .toString());
        prefs.setString(
            'quicklogin',
            json
                .decode(response.body)['Response']['User']['quickblox_email']
                .toString());
        prefs.setString(
            'quickpassword',
            json
                .decode(response.body)['Response']['User']['quickblox_password']
                .toString());
      }
    } else {
      throw Exception('Failed to get data due to ${response.body}');
    }
  }
}
