// ignore_for_file: use_build_context_synchronously, unused_local_variable

import 'dart:convert';
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:rentit4me_new/themes/constant.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:http/http.dart' as http;
import 'package:rentit4me_new/widgets/api_helper.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:rentit4me_new/network/api.dart';
import 'package:rentit4me_new/views/conversation.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({Key key}) : super(key: key);

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  bool _loading = false;
  String queryId;

  var userlist = [];

  @override
  void initState() {
    super.initState();
    getProfile().then((value) => _getchatUsers());

    //getUsers();
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      key: _scaffoldKey,
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
        title: Text("Chat", style: TextStyle(color: kPrimaryColor)),
        centerTitle: true,
      ),
      body: ModalProgressHUD(
        inAsyncCall: _loading,
        color: kPrimaryColor,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              Expanded(
                  child: RefreshIndicator(
                onRefresh: _getchatUsers,
                child: userlist.isEmpty
                    ? Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Container(
                              height: MediaQuery.of(context).size.height * 0.8,
                              alignment: Alignment.center,
                              child: Text("No data Found !!")),
                        ],
                      )
                    : ListView.separated(
                        itemCount: userlist.length,
                        padding: EdgeInsets.zero,
                        shrinkWrap: true,
                        separatorBuilder: (BuildContext context, int index) =>
                            const Divider(),
                        itemBuilder: (BuildContext context, int index) {
                          return InkWell(
                            onTap: () async {
                              SharedPreferences prefs =
                                  await SharedPreferences.getInstance();
                              userlist[index]['occupants_ids']
                                  .forEach((element) {
                                if (element.toString() !=
                                    prefs.getString('quickid')) {
                                  setState(() {
                                    queryId = element.toString();
                                  });
                                }
                              });
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) =>
                                          Conversation(queryId: queryId)));
                            },
                            child: SizedBox(
                              width: double.infinity,
                              child: Padding(
                                padding: EdgeInsets.all(8.0),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Container(
                                      height: 45,
                                      width: 45,
                                      alignment: Alignment.center,
                                      decoration: const BoxDecoration(
                                          borderRadius: BorderRadius.all(
                                              Radius.circular(22.0)),
                                          color: kPrimaryColor
                                          //color: Colors.primaries[_random.nextInt(Colors.primaries.length)][_random.nextInt(9) * 100] == Colors.white ? Colors.red: Colors.primaries[_random.nextInt(Colors.primaries.length)][_random.nextInt(9) * 100],
                                          ),
                                      child: Text(
                                          userlist[index]['name']
                                              .toString()[0]
                                              .toUpperCase(),
                                          style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 18)),
                                    ),
                                    SizedBox(width: 8.0),
                                    Expanded(
                                        child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(userlist[index]['name'].toString(),
                                            style: TextStyle(
                                                color: Colors.black,
                                                fontWeight: FontWeight.w500)),
                                        SizedBox(height: 5.0),
                                        userlist[index]['last_message'] == null
                                            ? SizedBox()
                                            : Text(
                                                userlist[index]['last_message']
                                                    .toString(),
                                                style: TextStyle(
                                                    color: Colors.black))
                                      ],
                                    )),
                                    SizedBox(width: 3.0),
                                    userlist[index]['created_at'] == null
                                        ? SizedBox()
                                        : Text(
                                            userlist[index]['created_at']
                                                .toString()
                                                .split('T')[0]
                                                .toString(),
                                            style:
                                                TextStyle(color: Colors.black))
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      ),
              ))
            ],
          ),
        ),
      ),
    );
  }

  String quickBoxId;
  Future getProfile() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    var url = BASE_URL + profileUrl;
    var body = {
      "id": prefs.getString("userid"),
    };
    var response = await APIHelper.apiPostRequest(url, body);
    var result = jsonDecode(response);
    if (result['ErrorCode'] == 0) {
      quickBoxId = result['Response']['User']['quickblox_id'];
      log("quickboxid--->$quickBoxId");
    }
  }

  Future _getchatUsers() async {
    setState(() {
      _loading = true;
    });
    var url = BASE_URL + chatuserlist;
    var body = {
      "chat_user_id": quickBoxId.toString(),
    };
    var response = await APIHelper.apiPostRequest(url, body);
    var result = jsonDecode(response);
    if (result['ErrorCode'] == 0) {
      userlist.clear();
      userlist.addAll(result['Response']['items']);
    }
    setState(() {
      _loading = false;
    });
  }
}
