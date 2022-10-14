// ignore_for_file: library_private_types_in_public_api

import 'package:contained_tab_bar_view/contained_tab_bar_view.dart';
import 'package:flutter/material.dart';
import 'package:rentit4me_new/views/OfferRecievedScreen.dart';
import 'package:rentit4me_new/views/offer_made_screen.dart';

class OffersViewScreen extends StatefulWidget {
  const OffersViewScreen({Key key}) : super(key: key);

  @override
  _OffersViewScreenState createState() => _OffersViewScreenState();
}

class _OffersViewScreenState extends State<OffersViewScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Offer Made"),
      ),
      body: ContainedTabBarView(
        tabs: const [
          Text('Offers Made ', style: TextStyle(color: Colors.black)),
          Text('Offers Recived', style: TextStyle(color: Colors.black))
        ],
        views:const [
         OfferMadeScreen(),
         OfferRecievedScreen(),
        ],
        onChange: (index) => print(index),
      ),
    );
  }
}
