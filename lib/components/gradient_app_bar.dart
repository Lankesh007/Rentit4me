// ignore_for_file: sort_child_properties_last

import 'package:flutter/material.dart';
import 'package:rentit4me_new/themes/constant.dart';

class GradientAppBar extends StatefulWidget {
  final String title;

  const GradientAppBar(this.title, {Key key}) : super(key: key);

  @override
  State<GradientAppBar> createState() => _GradientAppBarState();
}

class _GradientAppBarState extends State<GradientAppBar> {
  final double barHeight = 50.0;

  @override
  Widget build(BuildContext context) {
    final double statusbarHeight = MediaQuery.of(context).padding.top;

    return Container(
      padding: EdgeInsets.only(top: statusbarHeight),
      height: statusbarHeight + barHeight,
      child: Center(
        child: Text(
          widget.title,
          style: TextStyle(
              fontSize: 20.0, color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
      decoration: BoxDecoration(
        gradient: LinearGradient(
            colors: const [kPrimaryColor, ksecondaryColor],
            begin: const FractionalOffset(0.0, 0.0),
            end: const FractionalOffset(0.5, 0.0),
            stops: const [0.0, 1.0],
            tileMode: TileMode.clamp),
      ),
    );
  }
}
