import 'dart:developer';

import 'package:contained_tab_bar_view/contained_tab_bar_view.dart';
import 'package:flutter/material.dart';
import 'package:rentit4me_new/views/change_password_screen.dart';
import 'package:rentit4me_new/views/user_detail_screen.dart';

class AccountViewScreen extends StatefulWidget {
  const AccountViewScreen({Key key}) : super(key: key);

  @override
  State<AccountViewScreen> createState() => _AccountViewScreenState();
}

class _AccountViewScreenState extends State<AccountViewScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Text(
          "Account Details",
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: ContainedTabBarView(
        tabs: const [
          Text('Profile Details ', style: TextStyle(color: Colors.black)),
          Text('Change Password', style: TextStyle(color: Colors.black))
        ],
        views: const [
          UserDetailScreen(),
          ChangePasswordScreen(),
        ],
        onChange: (index) => log(index.toString()),
      ),
    );
  }
}
