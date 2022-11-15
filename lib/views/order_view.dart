import 'dart:developer';

import 'package:contained_tab_bar_view/contained_tab_bar_view.dart';
import 'package:flutter/material.dart';

import 'activeorders_screen.dart';
import 'completed_order_screen.dart';
import 'myorders_screen.dart';
import 'order_recieved_screen.dart';

class OrderViewScreen extends StatefulWidget {
  const OrderViewScreen({Key key}) : super(key: key);

  @override
  // ignore: library_private_types_in_public_api
  _OrderViewScreenState createState() => _OrderViewScreenState();
}

class _OrderViewScreenState extends State<OrderViewScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Orders"),
      ),
      body: ContainedTabBarView(
        tabBarProperties: const TabBarProperties(),
        tabs: const [
          Text('Orders Made',
              style: TextStyle(color: Colors.black, fontSize: 12)),
          Text('Orders Recived',
              style: TextStyle(color: Colors.black, fontSize: 12)),
        ],
        views: const [
          MyOrdersScreen(),
          OrderRecievedScreen(),
        ],
        onChange: (index) => log(index.toString()),
      ),
    );
  }
}
