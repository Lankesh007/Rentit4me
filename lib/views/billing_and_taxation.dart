// ignore_for_file: use_build_context_synchronously

import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
import 'package:rentit4me_new/views/select_membership_screen.dart';
import 'package:rentit4me_new/widgets/api_helper.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import '../network/api.dart';
import '../themes/constant.dart';

class BillingAndTaxation extends StatefulWidget {
  const BillingAndTaxation({Key key}) : super(key: key);

  @override
  State<BillingAndTaxation> createState() => _BillingAndTaxationState();
}

class _BillingAndTaxationState extends State<BillingAndTaxation> {
  final bankName = TextEditingController();
  final branchName = TextEditingController();
  final accountNo = TextEditingController();
  final iFSCCode = TextEditingController();
  final gstNumber = TextEditingController();
  final panNumber = TextEditingController();
  final aadharNumber = TextEditingController();
  final businessNames=TextEditingController();
  String dropdownvalue = 'Select';
  String gstDocumnet = '';
  String panCardDocumnet = '';
  String aadharCardDocument = '';
  int userType = 0;
  bool isLoading = false;
  File _pickedImage;
  File panImage;
  File aadharImage;
  var singleImage, singleImageDecoded;
  File singleImageFile;
  var emailExpression = RegExp(
      r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+");
  var phonepatttern = RegExp(r'(^(?:[+0]9)?[0-9]{10,12}$)');

  bool buttonLoading = false;
  void _remove() {
    setState(() {
      _pickedImage == null;
      panImage == null;
      aadharImage == null;
    });
    Navigator.pop(context);
  }

  // List of items in our dropdown menu
  var items = [
    'Select',
    'Current',
    'Saving',
  ];
  void pickImageCamera() async {
    final picker = ImagePicker();
    final pickedImage = await picker.getImage(source: ImageSource.camera);
    final pickedImageFile = File(pickedImage.path);

    setState(() {
      _pickedImage = pickedImageFile;
      final path = _pickedImage.readAsBytesSync();
      this.singleImageDecoded = base64Encode(path);
    });
    Navigator.pop(context);
  }

  void pickImageGallery() async {
    final picker = ImagePicker();
    final pickedImage = await picker.getImage(source: ImageSource.gallery);
    final pickedImageFile = File(pickedImage.path);
    setState(() {
      _pickedImage = pickedImageFile;
      final path = pickedImageFile.readAsBytesSync();
      this.singleImageDecoded = base64Encode(path);
    });
    Navigator.pop(context);
  }

  void pickAadharImageCamera() async {
    final picker = ImagePicker();
    final pickedImage = await picker.getImage(source: ImageSource.camera);
    final pickedImageFile = File(pickedImage.path);

    setState(() {
      aadharImage = pickedImageFile;
      final path = aadharImage.readAsBytesSync();
      this.singleImageDecoded = base64Encode(path);
    });
    Navigator.pop(context);
  }

  void pickAdharImageGallery() async {
    final picker = ImagePicker();
    final pickedImage = await picker.getImage(source: ImageSource.gallery);
    final pickedImageFile = File(pickedImage.path);
    setState(() {
      aadharImage = pickedImageFile;
      final path = pickedImageFile.readAsBytesSync();
      this.singleImageDecoded = base64Encode(path);
    });
    Navigator.pop(context);
  }

  void getPanImageCamera() async {
    final picker = ImagePicker();
    final pickedImage = await picker.getImage(source: ImageSource.camera);
    final pickedImageFile = File(pickedImage.path);

    setState(() {
      panImage = pickedImageFile;
      final path = panImage.readAsBytesSync();
      this.singleImageDecoded = base64Encode(path);
    });
    Navigator.pop(context);
  }

  void getPanImageGallery() async {
    final picker = ImagePicker();
    final pickedImage = await picker.getImage(source: ImageSource.gallery);
    final pickedImageFile = File(pickedImage.path);
    setState(() {
      panImage = pickedImageFile;
      final path = pickedImageFile.readAsBytesSync();
      this.singleImageDecoded = base64Encode(path);
    });
    Navigator.pop(context);
  }

  double height = 0;
  double width = 0;
  String businessName;

  getPrefencesData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(()  {
    businessName = prefs.getString('businessName');
    log("----->$businessName");
    });
  }

  @override
  void initState() {
    getUserDetails();
    getPrefencesData();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    height = MediaQuery.of(context).size.height;
    width = MediaQuery.of(context).size.width;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Text(
          "Billing And Taxation",
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
       
      ),
      body: ListView(
        children: [
          Column(
            children: [
              userType == 3
                  ? bankDetailsWidget()
                  : Column(
                      children: [
                        bankDetailsWidget(),
                        businessDetailsWidget(),
                      ],
                    ),
              SizedBox(
                height: 20,
              ),
              userType == 3
                  ? submitButtonWidgetConsumer()
                  : submitButtonWidgetBusiness(),
              SizedBox(
                height: 20,
              ),
            ],
          )
        ],
      ),
    );
  }

  Widget bankDetailsWidget() {
    return Card(
        elevation: 4.0,
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 10, horizontal: 15),
          child: Column(
            children: [
              const Text("Bank Detail (Optional)",
                  style: TextStyle(
                      color: kPrimaryColor,
                      fontSize: 18,
                      fontWeight: FontWeight.w700)),
              const SizedBox(height: 10),
              const Align(
                alignment: Alignment.topLeft,
                child: Text("Bank Name*",
                    style: TextStyle(
                        color: kPrimaryColor, fontWeight: FontWeight.w500)),
              ),
              const SizedBox(height: 8),
              Container(
                  decoration: BoxDecoration(
                      border:
                          Border.all(width: 1, color: Colors.deepOrangeAccent),
                      borderRadius: BorderRadius.all(Radius.circular(12))),
                  child: Padding(
                    padding: const EdgeInsets.only(left: 10.0),
                    child: TextFormField(
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Required Field';
                        }
                        return null;
                      },
                      decoration: InputDecoration(
                        border: InputBorder.none,
                      ),
                      controller: bankName,
                    ),
                  )),
              const SizedBox(height: 10),
              const Align(
                alignment: Alignment.topLeft,
                child: Text("Branch Name*",
                    style: TextStyle(
                        color: kPrimaryColor, fontWeight: FontWeight.w500)),
              ),
              const SizedBox(height: 8),
              Container(
                  decoration: BoxDecoration(
                      border:
                          Border.all(width: 1, color: Colors.deepOrangeAccent),
                      borderRadius: BorderRadius.all(Radius.circular(12))),
                  child: Padding(
                    padding: const EdgeInsets.only(left: 10.0),
                    child: TextFormField(
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Required Field';
                        }
                        return null;
                      },
                      decoration: InputDecoration(
                        border: InputBorder.none,
                      ),
                      controller: branchName,
                    ),
                  )),
              const SizedBox(height: 10),
              const Align(
                alignment: Alignment.topLeft,
                child: Text("Account Number*",
                    style: TextStyle(
                        color: kPrimaryColor, fontWeight: FontWeight.w500)),
              ),
              const SizedBox(height: 8),
              Container(
                  decoration: BoxDecoration(
                      border:
                          Border.all(width: 1, color: Colors.deepOrangeAccent),
                      borderRadius: BorderRadius.all(Radius.circular(12))),
                  child: Padding(
                    padding: const EdgeInsets.only(left: 10.0),
                    child: TextFormField(
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Required Field';
                        }
                        return null;
                      },
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      decoration: InputDecoration(
                        border: InputBorder.none,
                      ),
                      controller: accountNo,
                    ),
                  )),
              const SizedBox(height: 10),
              const Align(
                alignment: Alignment.topLeft,
                child: Text("Account Type*",
                    style: TextStyle(
                        color: kPrimaryColor, fontWeight: FontWeight.w500)),
              ),
              const SizedBox(height: 8),
              Container(
                height: 55,
                decoration:
                    BoxDecoration(borderRadius: BorderRadius.circular(15)),
                child: FormField(
                  builder: (FormFieldState state) {
                    return InputDecorator(
                      decoration: InputDecoration(
                          fillColor: Colors.white,
                          enabledBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.deepOrange),
                              borderRadius: BorderRadius.circular(15)),
                          filled: true,
                          // labelText: "Select",
                          isDense: true,
                          contentPadding: EdgeInsets.all(10),
                          border: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.deepOrange),
                          )),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton(
                          // Initial Value

                          value: dropdownvalue,

                          // Down Arrow Icon
                          icon: const Icon(Icons.keyboard_arrow_down),

                          // Array list of items
                          items: items.map((String items) {
                            return DropdownMenuItem(
                              value: items,
                              child: Text(items),
                            );
                          }).toList(),
                          // After selecting the desired option,it will
                          // change button value to selected value
                          onChanged: (String newValue) {
                            setState(() {
                              dropdownvalue = newValue;
                              log("====>$dropdownvalue");
                            });
                          },
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 10),
              const Align(
                alignment: Alignment.topLeft,
                child: Text("IFSC Code*",
                    style: TextStyle(
                        color: kPrimaryColor, fontWeight: FontWeight.w500)),
              ),
              const SizedBox(height: 8),
              Container(
                  decoration: BoxDecoration(
                      border:
                          Border.all(width: 1, color: Colors.deepOrangeAccent),
                      borderRadius: BorderRadius.all(Radius.circular(12))),
                  child: Padding(
                    padding: const EdgeInsets.only(left: 10.0),
                    child: TextFormField(
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Required Field';
                        }
                        return null;
                      },
                      decoration: InputDecoration(
                        border: InputBorder.none,
                      ),
                      controller: iFSCCode,
                    ),
                  )),
            ],
          ),
        ));
  }

  Widget businessDetailsWidget() {
    return Card(
      elevation: 4.0,
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 10, horizontal: 15),
        child: Column(
          children: [
            const Text("Business Details",
                style: TextStyle(
                    color: kPrimaryColor,
                    fontSize: 18,
                    fontWeight: FontWeight.w700)),
            const SizedBox(height: 20),
            const Align(
              alignment: Alignment.topLeft,
              child: Text("Business Name*",
                  style: TextStyle(
                      color: kPrimaryColor, fontWeight: FontWeight.w500)),
            ),
            const SizedBox(height: 8),
            Container(
                decoration: BoxDecoration(
                    border:
                        Border.all(width: 1, color: Colors.deepOrangeAccent),
                    borderRadius: BorderRadius.all(Radius.circular(12))),
                child: Padding(
                  padding: const EdgeInsets.only(left: 10.0),
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: businessName,
                      border: InputBorder.none,
                    ),
                    readOnly: true,
                    onChanged: (value) {
                      setState(() {});
                    },
                  ),
                )),
            const SizedBox(height: 10),
            const Align(
              alignment: Alignment.topLeft,
              child: Text("GST Number*",
                  style: TextStyle(
                      color: kPrimaryColor, fontWeight: FontWeight.w500)),
            ),
            const SizedBox(height: 8),
            Container(
                decoration: BoxDecoration(
                    border:
                        Border.all(width: 1, color: Colors.deepOrangeAccent),
                    borderRadius: BorderRadius.all(Radius.circular(12))),
                child: Padding(
                  padding: const EdgeInsets.only(left: 10.0),
                  child: TextField(
                    decoration: InputDecoration(
                        hintText: "GST No.(must be 15 digit)",
                        border: InputBorder.none,
                        counterText: ""),
                    maxLength: 15,
                    onChanged: (value) {
                      setState(() {
                        // adharno = value;
                      });
                    },
                    controller: gstNumber,
                  ),
                )),
            const SizedBox(height: 10),
            const SizedBox(height: 10),
            const Align(
              alignment: Alignment.topLeft,
              child: Text("PAN Number*",
                  style: TextStyle(
                      color: kPrimaryColor, fontWeight: FontWeight.w500)),
            ),
            const SizedBox(height: 8),
            Container(
                decoration: BoxDecoration(
                    border:
                        Border.all(width: 1, color: Colors.deepOrangeAccent),
                    borderRadius: BorderRadius.all(Radius.circular(12))),
                child: Padding(
                  padding: const EdgeInsets.only(left: 10.0),
                  child: TextField(
                    decoration: InputDecoration(
                        hintText: "PAN No.(must be 10 digit)",
                        border: InputBorder.none,
                        counterText: ""),
                    maxLength: 10,
                    onChanged: (value) {
                      setState(() {
                        // adharno = value;
                      });
                    },
                    controller: panNumber,
                  ),
                )),
            const SizedBox(height: 10),
            const SizedBox(height: 10),
            const Align(
              alignment: Alignment.topLeft,
              child: Text("Aadhar Number*",
                  style: TextStyle(
                      color: kPrimaryColor, fontWeight: FontWeight.w500)),
            ),
            const SizedBox(height: 8),
            Container(
                decoration: BoxDecoration(
                    border:
                        Border.all(width: 1, color: Colors.deepOrangeAccent),
                    borderRadius: BorderRadius.all(Radius.circular(12))),
                child: Padding(
                  padding: const EdgeInsets.only(left: 10.0),
                  child: TextField(
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                        hintText: "Aadhar No.(must be 12 digit)",
                        border: InputBorder.none,
                        counterText: ""),
                    maxLength: 12,
                    onChanged: (value) {
                      setState(() {
                        // adharno = value;
                      });
                    },
                    controller: aadharNumber,
                  ),
                )),
            const SizedBox(height: 10),
            const Align(
              alignment: Alignment.topLeft,
              child: Text("GST*",
                  style: TextStyle(
                      color: kPrimaryColor, fontWeight: FontWeight.w500)),
            ),
            const SizedBox(height: 8),
            Container(
              margin: EdgeInsets.symmetric(vertical: 5, horizontal: 0),
              child: _pickedImage != null
                  ? InkWell(
                      onTap: getImageofGST,
                      child: Image.file(
                        (_pickedImage),
                        width: width,
                        height: 200.0,
                        fit: BoxFit.cover,
                      ),
                    )
                  : Container(
                      height: height * 0.065,
                      width: width * 0.99,
                      decoration: BoxDecoration(
                          color: Colors.white,
                          border: Border.all(
                              width: 1, color: Colors.deepOrangeAccent),
                          borderRadius: BorderRadius.all(Radius.circular(15))),
                      child: Padding(
                        padding: EdgeInsets.symmetric(
                            vertical: 5.0, horizontal: 8.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            InkWell(
                              onTap: () {
                                getImageofGST();
                              },
                              child: Container(
                                height: 45,
                                width: 120,
                                alignment: Alignment.center,
                                decoration: const BoxDecoration(
                                    color: Colors.deepOrangeAccent,
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(8.0))),
                                child: Text("Choose file",
                                    style: TextStyle(
                                        color: Colors.white, fontSize: 16)),
                              ),
                            )
                          ],
                        ),
                      )),
            ),
            const SizedBox(height: 10),
            const Align(
              alignment: Alignment.topLeft,
              child: Text("PAN *",
                  style: TextStyle(
                      color: kPrimaryColor, fontWeight: FontWeight.w500)),
            ),
            const SizedBox(height: 8),
            Container(
              margin: EdgeInsets.symmetric(vertical: 5, horizontal: 0),
              child: panImage != null
                  ? InkWell(
                      onTap: getImageofPan,
                      child: Image.file(
                        (panImage),
                        width: width,
                        height: 200.0,
                        fit: BoxFit.cover,
                      ),
                    )
                  : Container(
                      decoration: BoxDecoration(
                          color: Colors.white,
                          border: Border.all(
                              width: 1, color: Colors.deepOrangeAccent),
                          borderRadius: BorderRadius.all(Radius.circular(12))),
                      child: Padding(
                        padding: EdgeInsets.symmetric(
                            vertical: 5.0, horizontal: 8.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            InkWell(
                              onTap: () {
                                getImageofPan();
                              },
                              child: Container(
                                height: 45,
                                width: 120,
                                alignment: Alignment.center,
                                decoration: const BoxDecoration(
                                    color: Colors.deepOrangeAccent,
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(8.0))),
                                child: Text("Choose file",
                                    style: TextStyle(
                                        color: Colors.white, fontSize: 16)),
                              ),
                            )
                          ],
                        ),
                      )),
            ),
            const SizedBox(height: 10),
            const Align(
              alignment: Alignment.topLeft,
              child: Text("Aadhar *",
                  style: TextStyle(
                      color: kPrimaryColor, fontWeight: FontWeight.w500)),
            ),
            const SizedBox(height: 8),
            Container(
              margin: EdgeInsets.symmetric(vertical: 5, horizontal: 0),
              child: aadharImage != null
                  ? InkWell(
                      onTap: getImageofAadhar,
                      child: Image.file(
                        (aadharImage),
                        width: width,
                        height: 200.0,
                        fit: BoxFit.cover,
                      ),
                    )
                  : Container(
                      decoration: BoxDecoration(
                          color: Colors.white,
                          border: Border.all(
                              width: 1, color: Colors.deepOrangeAccent),
                          borderRadius: BorderRadius.all(Radius.circular(12))),
                      child: Padding(
                        padding: EdgeInsets.symmetric(
                            vertical: 5.0, horizontal: 8.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            InkWell(
                              onTap: () {
                                getImageofAadhar();
                              },
                              child: Container(
                                height: 45,
                                width: 120,
                                alignment: Alignment.center,
                                decoration: const BoxDecoration(
                                    color: Colors.deepOrangeAccent,
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(8.0))),
                                child: Text("Choose file",
                                    style: TextStyle(
                                        color: Colors.white, fontSize: 16)),
                              ),
                            )
                          ],
                        ),
                      )),
            ),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }

  Widget submitButtonWidgetBusiness() {
    return InkWell(
      onTap: () {
        if (gstNumber.text.isEmpty && gstNumber.text.length < 15) {
          showToast("Please fill Gst Number");
        } else if (panNumber.text.isEmpty && panNumber.text.length < 10) {
          showToast("Please fill Pan Number");
        } else if (aadharNumber.text.isEmpty && aadharNumber.text.length < 12) {
          showToast("Please fill Aadhar number");
        } else if (_pickedImage == null) {
          showToast("Please choose GST document");
        } else if (panImage == null) {
          showToast("Please choose PAN Card ");
        } else if (aadharImage == null) {
          showToast("Please choose Aadhar Card ");
        } else if (bankName.text.isEmpty &&
            branchName.text.isEmpty &&
            accountNo.text.isEmpty &&
            dropdownvalue == "Select" &&
            iFSCCode.text.isEmpty) {
          submitBillingAndTaxation();
        } else {
          if (bankName.text.isNotEmpty &&
                  branchName.text.isNotEmpty &&
                  accountNo.text.isNotEmpty &&
                  dropdownvalue == "Current" ||
              dropdownvalue == "Saving" && iFSCCode.text.isNotEmpty) {
            submitBillingAndTaxation();
          } else {
            showToast("please fill all bank Details !!");
          }
        }
      },
      child: Container(
        alignment: Alignment.center,
        height: height * 0.07,
        width: width * 0.9,
        decoration: BoxDecoration(
          color: Colors.deepOrangeAccent,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Text(
          buttonLoading == true ? "Please Wait..." : "Submit",
          style: TextStyle(
              color: Colors.white, fontWeight: FontWeight.bold, fontSize: 22),
        ),
      ),
    );
  }

  Widget submitButtonWidgetConsumer() {
    return InkWell(
      child: Container(
        alignment: Alignment.center,
        height: height * 0.07,
        width: width * 0.9,
        decoration: BoxDecoration(
          color: Colors.deepOrangeAccent,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Text(
          buttonLoading == true ? "Please Wait..." : "Submit",
          style: TextStyle(
              color: Colors.white, fontWeight: FontWeight.bold, fontSize: 22),
        ),
      ),
    );
  }

  getImageofGST() {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text(
              'Choose option',
              style: TextStyle(
                  fontWeight: FontWeight.w600, color: Colors.lightBlueAccent),
            ),
            content: SingleChildScrollView(
              child: ListBody(
                children: [
                  InkWell(
                    onTap: pickImageCamera,
                    splashColor: Colors.purpleAccent,
                    child: Row(
                      children: const [
                        Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Icon(
                            Icons.camera,
                            color: Colors.purpleAccent,
                          ),
                        ),
                        Text(
                          'Camera',
                          style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w500,
                              color: Colors.lightBlueAccent),
                        )
                      ],
                    ),
                  ),
                  InkWell(
                    onTap: pickImageGallery,
                    splashColor: Colors.purpleAccent,
                    child: Row(
                      children: const [
                        Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Icon(
                            Icons.image,
                            color: Colors.purpleAccent,
                          ),
                        ),
                        Text(
                          'Gallery',
                          style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w500,
                              color: Colors.blue),
                        )
                      ],
                    ),
                  ),
                  InkWell(
                    onTap: _remove,
                    splashColor: Colors.purpleAccent,
                    child: Row(
                      children: const [
                        Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Icon(
                            Icons.remove_circle,
                            color: Colors.red,
                          ),
                        ),
                        Text(
                          'Remove',
                          style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w500,
                              color: Colors.red),
                        )
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        });
  }

  getImageofAadhar() {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text(
              'Choose option',
              style: TextStyle(
                  fontWeight: FontWeight.w600, color: Colors.lightBlueAccent),
            ),
            content: SingleChildScrollView(
              child: ListBody(
                children: [
                  InkWell(
                    onTap: pickAadharImageCamera,
                    splashColor: Colors.purpleAccent,
                    child: Row(
                      children: const [
                        Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Icon(
                            Icons.camera,
                            color: Colors.purpleAccent,
                          ),
                        ),
                        Text(
                          'Camera',
                          style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w500,
                              color: Colors.lightBlueAccent),
                        )
                      ],
                    ),
                  ),
                  InkWell(
                    onTap: pickAdharImageGallery,
                    splashColor: Colors.purpleAccent,
                    child: Row(
                      children: const [
                        Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Icon(
                            Icons.image,
                            color: Colors.purpleAccent,
                          ),
                        ),
                        Text(
                          'Gallery',
                          style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w500,
                              color: Colors.blue),
                        )
                      ],
                    ),
                  ),
                  InkWell(
                    onTap: _remove,
                    splashColor: Colors.purpleAccent,
                    child: Row(
                      children: const [
                        Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Icon(
                            Icons.remove_circle,
                            color: Colors.red,
                          ),
                        ),
                        Text(
                          'Remove',
                          style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w500,
                              color: Colors.red),
                        )
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        });
  }

  getImageofPan() {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text(
              'Choose option',
              style: TextStyle(
                  fontWeight: FontWeight.w600, color: Colors.lightBlueAccent),
            ),
            content: SingleChildScrollView(
              child: ListBody(
                children: [
                  InkWell(
                    onTap: getPanImageCamera,
                    splashColor: Colors.purpleAccent,
                    child: Row(
                      children: const [
                        Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Icon(
                            Icons.camera,
                            color: Colors.purpleAccent,
                          ),
                        ),
                        Text(
                          'Camera',
                          style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w500,
                              color: Colors.lightBlueAccent),
                        )
                      ],
                    ),
                  ),
                  InkWell(
                    onTap: getPanImageGallery,
                    splashColor: Colors.purpleAccent,
                    child: Row(
                      children: const [
                        Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Icon(
                            Icons.image,
                            color: Colors.purpleAccent,
                          ),
                        ),
                        Text(
                          'Gallery',
                          style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w500,
                              color: Colors.blue),
                        )
                      ],
                    ),
                  ),
                  InkWell(
                    onTap: _remove,
                    splashColor: Colors.purpleAccent,
                    child: Row(
                      children: const [
                        Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Icon(
                            Icons.remove_circle,
                            color: Colors.red,
                          ),
                        ),
                        Text(
                          'Remove',
                          style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w500,
                              color: Colors.red),
                        )
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        });
  }

// ------------------ API CALL---------------------//

  Future getUserDetails() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String userId = prefs.getString("userid");
    var url = BASE_URL + profileUrl;
    var body = {
      "id": userId.toString(),
    };
    var data=jsonEncode(body);
    var response = await APIHelper.apiPostRequest(url, data);

    var result = jsonDecode(response);
    if (result['ErrorMessage'] == "success") {
      userType = result['Response']['User']['user_type'];
      log("userType----->${userType.toString()}");
    }
  }

  Future submitBillingAndTaxation() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    String userId = prefs.getString('userid');
    setState(() {
      buttonLoading = true;
    });
    var url = Apis.billingAndTaxationApi;
    var bodyMap = {
      "id": userId.toString(),
      "business_name":prefs.getString('businessName').toString(),
      "account_type": dropdownvalue.toString(),
      "bank_name": bankName.text.toString(),
      "branch_name": branchName.text.toString(),
      "ifsc": iFSCCode.text.toString(),
      "account_no": accountNo.text.toString(),
      "adhaar_no": aadharNumber.text.toString(),
      "pan_no": panNumber.text.toString(),
      "gst_no": gstNumber.text.toString(),
    };
    try {
      final request = http.MultipartRequest('POST', Uri.parse(url));

      request.headers.addAll({
        'Authorization': 'Bearer ${prefs.getString("token")}',
      });
      if (_pickedImage.path.isNotEmpty) {
        var pic =
            await http.MultipartFile.fromPath('gst_doc', _pickedImage.path);
        request.files.add(pic);
        log("ENTETED====>  $pic");
      } else {
        log("ENTETED====>  $_pickedImage");
      }
      if (panImage.path.isNotEmpty) {
        var pic = await http.MultipartFile.fromPath('pan_doc', panImage.path);
        request.files.add(pic);
        log("ENTETED====>  $pic");
      } else {
        log("ENTETED====>  $panImage");
      }
      if (aadharImage.path.isNotEmpty) {
        var pic =
            await http.MultipartFile.fromPath('adhaar_doc', aadharImage.path);
        request.files.add(pic);
        log("ENTETED====>  $pic");
      } else {
        log("ENTETED====>  $aadharImage");
      }

      request.fields.addAll(bodyMap);
      var response = await request.send();

      log("body=====>$bodyMap");

      var responseData = await response.stream.toBytes();
      var responseString = String.fromCharCodes(responseData);

      log("Requests--->$request");
      log("PostResponse----> $responseString");
      log("StatusCodePost---->${response.statusCode}");
      log("response---->$response");
      log("responseData---->$responseData");

      if (response.statusCode >= 200 && response.statusCode <= 299) {
        log("StatusCodePost11---->${response.statusCode}");

        Navigator.pushReplacement(context,
            MaterialPageRoute(builder: (context) => SelectMemberShipScreen()));
        Fluttertoast.showToast(
          msg: "Taxation Submitted Successfully !!:",
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.CENTER,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.green.shade700,
          textColor: Colors.white,
          fontSize: 16.0,
        );
      } else {
        Fluttertoast.showToast(
          msg: "Something Went Wrong !!:",
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.CENTER,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.green.shade700,
          textColor: Colors.white,
          fontSize: 16.0,
        );
      }
    } on Exception catch (e) {}
    setState(() {
      buttonLoading = false;
    });
  }
}
