// ignore_for_file: prefer_const_constructors, must_be_immutable, library_private_types_in_public_api

import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:quickblox_sdk/auth/module.dart';
import 'package:quickblox_sdk/models/qb_attachment.dart';
import 'package:quickblox_sdk/models/qb_file.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:quickblox_sdk/models/qb_message.dart';
import 'package:quickblox_sdk/quickblox_sdk.dart';
import 'package:rentit4me_new/network/api.dart';
import 'package:rentit4me_new/themes/constant.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class Conversation extends StatefulWidget {
  String queryId;
  Conversation({Key key, this.queryId}) : super(key: key);
  @override
  _ConversationState createState() => _ConversationState(queryId);
}

class _ConversationState extends State<Conversation> {
  Map chat = {};
  List conversion = [];

  String queryId;
  _ConversationState(this.queryId);

  TextEditingController message = TextEditingController();

  bool attachment = false;
  bool showCamera = false;
  String filePath = "";
  final ImagePicker _picker = ImagePicker();

  bool saveToHistory = true;
  String userquickid;

  bool _loading = false;

  //List<int> occupantsIds = [134415468, 134383968];
  String url = "https://picutres.com/9384erw343.jpg";
  bool public = false;

  String _dialogId;

  String appId = "96417";
  String authKey = "BmYxKrbn3HDthbc";
  String authSecret = "XRfs7bw3Y9H4yMc";
  String accountKey = "hr2cuVsMyCZXsZMEE32H";

  void init() async {
    setState(() {
      _loading = true;
    });

    try {
      await QB.settings.init(appId, authKey, authSecret, accountKey);
      mylogin();
    } on PlatformException catch (e) {
      // Some error occurred, look at the exception message for more details
    }
  }

  String senderId = "";
  void mylogin() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    try {
      QBLoginResult result = await QB.auth.login(
          prefs.getString('quicklogin'), prefs.getString('quickpassword'));
      setState(() {
        senderId = prefs.getString('userquickid').toString();
      });
      connect(int.parse(prefs.getString('userquickid')),
          prefs.getString('quickpassword'));
    } on PlatformException catch (e) {
      // Some error occurred, look at the exception message for more details
    }
  }

  void connect(userId, password) async {
    try {
      await QB.chat.connect(userId, password);
      QB.chat.isConnected().then((value) {
        print("$value ----tes");
      });
      createDialog();
    } on PlatformException catch (e) {
      // Some error occurred, look at the exception message for more details
    }
  }

  // List<int> occupantsIds = [98987887, 76894569];
  // String dialogName = "test dialog";
  // int dialogType = QBChatDialogTypes.CHAT;

  // void createDialog() async {
  //   try {
  //     QBDialog createdDialog =
  //         await QB.chat.createDialog(occupantsIds, dialogType: dialogType);
  //     print(createdDialog.id.toString() + "____");
  //     if (createdDialog != null) {
  //       String _dialogId = createdDialog.id;
  //     }
  //   } on PlatformException catch (e) {
  //     // Some error occurred, look at the exception message for more details
  //   }
  // }

  @override
  void initState() {
    super.initState();
    init();
    // _getchatData(queryId);
    // createDialog();
    // _connectnow();
  }

  // void dispose() {
  //   message.clear();
  //   super.dispose();
  // }

  // void _connectnow() async {
  //   SharedPreferences prefs = await SharedPreferences.getInstance();
  //   print(prefs.getString('quicklogin'));
  //   print(queryId);
  //   setState(() {
  //     userquickid = prefs.getString('userquickid');
  //     _loading = true;
  //   });
  //   try {
  //     await QB.chat.connect(int.parse(prefs.getString('userquickid')),
  //         prefs.getString('quickpassword'));
  //     createDialog();
  //   } on PlatformException catch (e) {
  //     // Some error occurred, look at the exception message for more details
  //   }
  // }

  Future createDialog() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _loading = true;
    });
    final body = {
      "recipient_id": queryId,
      "sender_id": prefs.getString('userquickid')
    };
    log(jsonEncode(body));
    var response = await http.post(Uri.parse(BASE_URL + createdialogid),
        body: jsonEncode(body),
        headers: {
          "Accept": "application/json",
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${prefs.getString("token")}',
        });
    if (response.statusCode == 200) {
      var data = json.decode(response.body)['Response'];
      setState(() {
        _dialogId = data['_id'].toString();
      });
      print(queryId);
      _getchatData(data['_id'].toString());
    } else {
      throw Exception('Failed to get data due to ${response.body}');
    }
  }

  // String eventName = QBChatEvents.RECEIVED_NEW_MESSAGE;

  // void subscribeNewMessage() async {
  //   try {
  //     await QB.chat.subscribeChatEvent(eventName, (data) {
  //       Map<dynamic, dynamic> map = Map<dynamic, dynamic>.from(data);
  //       Map<dynamic, dynamic> payload =
  //           Map<dynamic, dynamic>.from(map["payload"]);
  //       String messageId = payload["id"] as String;
  //     }, onErrorMethod: (error) {
  //       // Some error occurred, look at the exception message for more details
  //     });
  //   } on PlatformException catch (e) {
  //     // Some error occurred, look at the exception message for more details
  //   }
  // }
  @override
  void dispose() {
    //...
    super.dispose();
    //...
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        Navigator.of(context).pop();
        dispose();
        return true;
      },
      child: Scaffold(
        extendBodyBehindAppBar: false,
        resizeToAvoidBottomInset: false,
        backgroundColor: Colors.teal[50],
        appBar: AppBar(
          title: Text("Chat"),
          backgroundColor: kPrimaryColor,
          leading: IconButton(
              onPressed: () {
                dispose();
                Navigator.of(context).pop();
              },
              icon: Icon(Icons.arrow_back)),
        ),
        body: ModalProgressHUD(
          inAsyncCall: _loading,
          child: SafeArea(
            child: Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
              ),
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    SizedBox(
                      height: MediaQuery.of(context).size.height / 1.45,
                      child: ListView(
                        reverse: true,
                        scrollDirection: Axis.vertical,
                        children: conversion.map((e) {
                          return Align(
                            alignment:
                                e['sender_id'].toString() == senderId.toString()
                                    ? Alignment.centerRight
                                    : Alignment.centerLeft,
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Container(
                                decoration: BoxDecoration(
                                    color: e['sender_id'].toString() ==
                                            senderId.toString()
                                        ? Colors.green[100]
                                        : Colors.white,
                                    borderRadius: e['sender_id'].toString() ==
                                            senderId.toString()
                                        ? BorderRadius.only(
                                            topLeft: Radius.circular(10),
                                            topRight: Radius.circular(10),
                                            bottomLeft: Radius.circular(10),
                                            bottomRight: Radius.circular(0))
                                        : BorderRadius.only(
                                            topLeft: Radius.circular(10),
                                            topRight: Radius.circular(10),
                                            bottomLeft: Radius.circular(0),
                                            bottomRight: Radius.circular(10))),
                                width: MediaQuery.of(context).size.width / 1.5,
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      e['comment_image'] == null
                                          ? SizedBox()
                                          : InkWell(
                                              onTap: () {
                                                showDialog(
                                                    context: context,
                                                    builder: (context) =>
                                                        AlertDialog(
                                                          content: Image.network(
                                                              e['comment_image']),
                                                        ));
                                              },
                                              child: Image.network(
                                                e['comment_image'],
                                                loadingBuilder:
                                                    (BuildContext context,
                                                        Widget child,
                                                        ImageChunkEvent
                                                            loadingProgress) {
                                                  if (loadingProgress == null) {
                                                    return child;
                                                  }
                                                  return Center(
                                                    child:
                                                        CircularProgressIndicator(
                                                      value: loadingProgress
                                                                  .expectedTotalBytes !=
                                                              null
                                                          ? loadingProgress
                                                                  .cumulativeBytesLoaded /
                                                              loadingProgress
                                                                  .expectedTotalBytes
                                                          : null,
                                                    ),
                                                  );
                                                },
                                              ),
                                            ),
                                      Text(
                                        e['message'],
                                        style: TextStyle(color: Colors.black),
                                      ),
                                      Align(
                                          alignment:
                                              e['sender_id'].toString() ==
                                                      senderId.toString()
                                                  ? Alignment.centerRight
                                                  : Alignment.centerLeft,
                                          child: Text(
                                              e['created_at']
                                                  .toString()
                                                  .split('T')[0]
                                                  .toString(),
                                              style: TextStyle(
                                                  color: Colors.black,
                                                  fontWeight: FontWeight.w300,
                                                  fontSize: 10))),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                    ClipRRect(
                      borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(20),
                          topRight: Radius.circular(20)),
                      child: SizedBox(
                        height: showCamera || attachment ? 160 : 80,
                        child: Column(
                          children: [
                            showCamera
                                ? BackdropFilter(
                                    filter: ImageFilter.blur(
                                        sigmaX: 100.0, sigmaY: 100.0),
                                    child: SizedBox(
                                      height: 80,
                                      width: MediaQuery.of(context).size.width,
                                      child: Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              TextButton.icon(
                                                  icon: Icon(
                                                    Icons.camera,
                                                    color: Colors.black,
                                                  ),
                                                  onPressed: () async {
                                                    final XFile result =
                                                        await _picker.pickImage(
                                                      source:
                                                          ImageSource.camera,
                                                      imageQuality: 80,
                                                      maxHeight: 480,
                                                      maxWidth: 640,
                                                    );
                                                    if (result != null) {
                                                      setState(() {
                                                        showCamera = false;
                                                        attachment = true;
                                                        filePath = result.path
                                                            .toString();
                                                      });
                                                    }
                                                  },
                                                  label: Text(
                                                    "Camera",
                                                    style: TextStyle(
                                                        color: Colors.black),
                                                  )),
                                              TextButton.icon(
                                                  icon: Icon(
                                                    Icons.photo,
                                                    color: Colors.black,
                                                  ),
                                                  onPressed: () async {
                                                    final XFile result =
                                                        await _picker.pickImage(
                                                      source:
                                                          ImageSource.gallery,
                                                      imageQuality: 80,
                                                      maxHeight: 480,
                                                      maxWidth: 640,
                                                    );
                                                    if (result != null) {
                                                      setState(() {
                                                        showCamera = false;
                                                        attachment = true;
                                                        filePath = result.path
                                                            .toString();
                                                      });
                                                    }
                                                  },
                                                  label: Text(
                                                    "Gallary",
                                                    style: TextStyle(
                                                        color: Colors.black),
                                                  )),
                                              IconButton(
                                                  onPressed: () {
                                                    setState(() {
                                                      showCamera = false;
                                                    });
                                                  },
                                                  icon: Icon(
                                                    Icons.clear,
                                                    color: Colors.red,
                                                  ))
                                            ],
                                          )),
                                    ),
                                  )
                                : SizedBox(),
                            attachment
                                ? BackdropFilter(
                                    filter: ImageFilter.blur(
                                        sigmaX: 100.0, sigmaY: 100.0),
                                    child: SizedBox(
                                      height: 80,
                                      width: MediaQuery.of(context).size.width,
                                      child: Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            SizedBox(
                                                width: 50,
                                                child:
                                                    Image.file(File(filePath))),
                                            InkWell(
                                              onTap: () {
                                                setState(() {
                                                  attachment = false;
                                                  filePath = "";
                                                });
                                              },
                                              child: Icon(
                                                Icons.close,
                                                color: Colors.red,
                                              ),
                                            )
                                          ],
                                        ),
                                      ),
                                    ),
                                  )
                                : SizedBox(),
                            Container(
                              color: Colors.grey[300],
                              height: 80,
                              child: Padding(
                                padding: const EdgeInsets.all(10),
                                child: TextFormField(
                                    controller: message,
                                    scrollPadding: EdgeInsets.only(bottom: 40),
                                    decoration: InputDecoration(
                                        prefixIcon: InkWell(
                                          onTap: () {
                                            setState(() {
                                              showCamera = !showCamera;
                                              if (attachment) {
                                                setState(() {
                                                  attachment = false;
                                                });
                                              }
                                            });
                                          },
                                          child: Icon(
                                            Icons.attachment,
                                            color: Colors.black,
                                          ),
                                        ),
                                        suffixIcon: TextButton(
                                          child: Text("SEND"),
                                          style: ButtonStyle(),
                                          onPressed: () async {
                                            print("object");
                                            print(_dialogId);
                                            print(message.text);
                                            _sendData(_dialogId, message.text);
                                          },
                                        ),
                                        fillColor: Colors.white,
                                        filled: true,
                                        border: OutlineInputBorder(
                                            borderRadius:
                                                BorderRadius.circular(20)))),
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // String appId = "96417";
  // String authKey = "BmYxKrbn3HDthbc";
  // String authSecret = "XRfs7bw3Y9H4yMc";
  // String accountKey = "hr2cuVsMyCZXsZMEE32H";
  Future<void> _sendData(String dialogId, String msg) async {
    print("inside");
    try {
      await QB.chat
          .sendMessage(dialogId, body: msg, saveToHistory: saveToHistory);

      setState(() {
        message.text = "";
      });
      _getchatData(dialogId);
    } on PlatformException catch (e) {
      print(e);
      // Some error occurred, look at the exception message for more details
    }
  }

  Future<void> _sendDataWithAttachment(String url, bool public) async {
    try {
      QBFile file = await QB.content.upload(url, public: public);

      if (file != null) {
        int id = file.id;
        String contentType = file.contentType;

        QBAttachment attachment = QBAttachment();
        attachment.id = id.toString();
        attachment.contentType = contentType;

        //Required parameter
        attachment.type = "PHOTO";

        List<QBAttachment> attachmentsList = [];
        attachmentsList.add(attachment);

        QBMessage message = QBMessage();
        message.attachments = attachmentsList;

        // Send a message logic
      }
    } on PlatformException catch (e) {
      // Some error occurred, look at the exception message for more details
    }
  }

  Future<void> _getchatData(String dialogid) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final body = {
      "dialogid": dialogid,
      "chat_user_id": prefs.getString('userquickid')
    };
    var response = await http.post(Uri.parse(BASE_URL + chathistory),
        body: jsonEncode(body),
        headers: {
          "Accept": "application/json",
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${prefs.getString("token")}',
        });
    setState(() {
      _loading = false;
    });
    if (response.statusCode == 200) {
      List data = json.decode(response.body)['Response']['items'];
      setState(() {
        conversion.clear();
        conversion.addAll(data.reversed);
      });
    } else {
      throw Exception('Failed to get data due to ${response.body}');
    }
  }
}
