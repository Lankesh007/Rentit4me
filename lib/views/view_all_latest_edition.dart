import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:group_radio_button/group_radio_button.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:rentit4me_new/network/api.dart';
import 'package:rentit4me_new/views/product_detail_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/view_all_latest_addtion.dart';
import '../widgets/api_helper.dart';

class ViewAllLatestAddition extends StatefulWidget {
  final String cityId;
  const ViewAllLatestAddition({this.cityId, Key key}) : super(key: key);

  @override
  State<ViewAllLatestAddition> createState() => _ViewAllLatestAdditionState();
}

class _ViewAllLatestAdditionState extends State<ViewAllLatestAddition> {
  List<ViewAllLatestAdditiionModel> latestAdditionList = [];
  List<ViewAllLatestAdditiionModel> latestAdditionListBySearch = [];

  ScrollController _scrollController = ScrollController();

  final searchController = TextEditingController();

  double height = 0;
  double width = 0;
  bool loader = false;
  bool _hasNext = true;
  bool isLoadMore = false;
  bool filterlowToHigh = false;

  int page = 1;

  @override
  void initState() {
    getLatestAddition();
    _scrollController.addListener(() {
      if (_scrollController.position.pixels ==
          _scrollController.position.maxScrollExtent) {
        setState(() {
          page++;
          _hasNext = true;
          isLoadMore = true;
        });
        getScrollingDetails(page.toString());
      }
      /*  else if (_scrollController.position.pixels ==
          _scrollController.position.minScrollExtent) {
        setState(() {
          if (page > 0) {
            page--;
            isLoadfirst = true;
            getScrollingDetails(page.toString());
          }
        });
      } */
      // log('=================>>>' + page.toString());
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    height = MediaQuery.of(context).size.height;
    width = MediaQuery.of(context).size.width;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.orange.shade400,
        title: Image.asset(
          'assets/images/logo.png',
          scale: 22,
        ),
        leading: InkWell(
            onTap: () {
              Navigator.pop(context);
            },
            child: Icon(
              Icons.arrow_back_ios,
              color: Colors.black,
            )),
        centerTitle: true,
        actions: [
          // IconButton(
          //     onPressed: () {
          //       filterModelSheet();
          //     },
          //     icon: Icon(
          //       Icons.filter_alt,
          //       color: Colors.black,
          //     )),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          getLatestAddition();
        },
        child: ListView(
          children: [
            searchWidget(),
            Divider(),
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 10),
              child: Text(
                "Latest Additions",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
              ),
            ),
            const SizedBox(
              height: 10,
            ),
            Divider(),
            getSearchData == true
                ? latestAdditionListBySearch.isEmpty
                    ? Center(
                        child: Text("No Record Found !!"),
                      )
                    : searchLoader == true
                        ? Center(
                            child: CircularProgressIndicator(),
                          )
                        : SizedBox(
                            height: height * 0.68,
                            width: width,
                            child: GridView.builder(
                                controller: _scrollController,
                                physics: BouncingScrollPhysics(),
                                shrinkWrap: true,
                                itemCount: latestAdditionListBySearch.length,
                                itemBuilder:
                                    (BuildContext context, int index) =>
                                        latestAdditionWidget(
                                          latestAdditionListBySearch[index],
                                        ),
                                gridDelegate:
                                    SliverGridDelegateWithFixedCrossAxisCount(
                                        crossAxisCount: 2,
                                        crossAxisSpacing: 1.0,
                                        mainAxisSpacing: 1.0)),
                          )
                : latestAdditionList.isEmpty
                    ? Center(
                        child: Text("No Record Found !!"),
                      )
                    : loader == true
                        ? Center(
                            child: CircularProgressIndicator(),
                          )
                        : SizedBox(
                            height: height * 0.68,
                            width: width,
                            child: GridView.builder(
                                controller: _scrollController,
                                physics: BouncingScrollPhysics(),
                                shrinkWrap: true,
                                itemCount: latestAdditionList.length,
                                itemBuilder:
                                    (BuildContext context, int index) =>
                                        latestAdditionWidget(
                                          latestAdditionList[index],
                                        ),
                                gridDelegate:
                                    SliverGridDelegateWithFixedCrossAxisCount(
                                        crossAxisCount: 2,
                                        crossAxisSpacing: 1.0,
                                        mainAxisSpacing: 1.0)),
                          ),
          ],
        ),
      ),
    );
  }

  Widget searchWidget() {
    return Padding(
      padding: const EdgeInsets.all(7.0),
      child: Container(
          margin: const EdgeInsets.only(top: 5),
          padding: const EdgeInsets.symmetric(vertical: 0, horizontal: 16),
          decoration: BoxDecoration(
            color: Colors.indigo.shade50,
            borderRadius: const BorderRadius.all(Radius.circular(5)),
          ),
          child: Row(
            children: <Widget>[
              Expanded(
                child: TextFormField(
                  onChanged: (value) {
                    if (searchController.text.isEmpty) {
                      setState(() {
                        getLatestAddition();
                      });
                    }
                  },
                  controller: searchController,
                  decoration: const InputDecoration(
                    hintText: "Search Rentit4me",
                    hintStyle: TextStyle(
                        color: Colors.grey,
                        fontWeight: FontWeight.w500,
                        fontSize: 14),
                    border: InputBorder.none,
                  ),
                ),
              ),
              ElevatedButton(
                onPressed: () {
                  getDataBySearching();
                },
                style: ButtonStyle(
                    shape: MaterialStateProperty.all(RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20.0),
                ))),
                child: Text("Search"),
              )
            ],
          )),
    );
  }

  Widget latestAdditionWidget(ViewAllLatestAdditiionModel item) {
    return Column(
      children: [
        InkWell(
          onTap: () {
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: ((context) => ProductDetailScreen(
                          productid: item.id.toString(),
                        ))));
          },
          child: Container(
            alignment: Alignment.centerLeft,
            margin: const EdgeInsets.symmetric(horizontal: 10),
            child: Column(
              children: [
                SizedBox(
                  height: 10,
                ),
                Container(
                  height: height * 0.16,
                  width: width * 0.5,
                  decoration: BoxDecoration(
                      image: DecorationImage(
                    image: NetworkImage(devImage +
                        item.uploadBasePath.toString() +
                        item.fileName.toString()),
                    fit: BoxFit.cover,
                  )),
                ),
                SizedBox(
                  height: 10,
                ),
                Container(
                    width: width * 0.5,
                    alignment: Alignment.centerLeft,
                    child: Text(
                      item.title,
                      style: TextStyle(fontWeight: FontWeight.w600),
                    )),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Future filterModelSheet() {
    return showMaterialModalBottomSheet(
      context: context,
      builder: (context) => SizedBox(
        height: height * 0.5,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 40,
              width: width,
              color: Colors.grey[300],
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(left: 8.0),
                    child: Text(
                      "Filter Your Search",
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ),
                  IconButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      icon: Icon(
                        Icons.close,
                        color: Colors.deepOrange,
                      ))
                ],
              ),
            ),
            SizedBox(
              height: 20,
            ),
            Container(
                margin: const EdgeInsets.symmetric(horizontal: 5),
                child: Text(
                  "Sort By",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                )),
            Divider(
              thickness: 0.9,
            ),
            SizedBox(
              height: 10,
            ),
            InkWell(
              onTap: () {
                setState(() {
                  filterlowToHigh = true;
                  log(filterlowToHigh.toString());
                });
              },
              child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 10),
                  child: Row(
                    children: [
                      Text(
                        "Low To High",
                        style: TextStyle(fontSize: 14),
                      ),
                      SizedBox(
                        width: 10,
                      ),
                      Container(
                        alignment: Alignment.topCenter,
                        height: 20,
                        width: 20,
                        decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey)),
                        child: filterlowToHigh == true
                            ? Icon(
                                Icons.check,
                                size: 20,
                                color: Colors.deepOrange,
                              )
                            : SizedBox(),
                      ),
                    ],
                  )),
            ),
            SizedBox(
              height: 15,
            ),
            InkWell(
              onTap: () {
                setState(() {
                  filterlowToHigh = true;
                  log(filterlowToHigh.toString());
                });
              },
              child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 10),
                  child: Row(
                    children: [
                      Text(
                        "High To Low",
                        style: TextStyle(fontSize: 14),
                      ),
                      SizedBox(
                        width: 10,
                      ),
                      Container(
                        alignment: Alignment.topCenter,
                        height: 20,
                        width: 20,
                        decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey)),
                        child: filterlowToHigh == true
                            ? Icon(
                                Icons.check,
                                size: 20,
                                color: Colors.deepOrange,
                              )
                            : SizedBox(),
                      ),
                    ],
                  )),
            ),
            SizedBox(
              height: 20,
            ),
            Divider(
              thickness: 0.9,
            ),
            Container(
                margin: const EdgeInsets.symmetric(horizontal: 5),
                child: Text(
                  "Select Tenure",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                )),
            Divider(
              thickness: 0.9,
            ),
            SizedBox(
              height: 10,
            ),
            InkWell(
              onTap: () {
                setState(() {
                  filterlowToHigh = true;
                  log(filterlowToHigh.toString());
                });
              },
              child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 10),
                  child: Row(
                    children: [
                      Text(
                        "Hourly",
                        style: TextStyle(fontSize: 14),
                      ),
                      SizedBox(
                        width: 10,
                      ),
                      Container(
                        alignment: Alignment.topCenter,
                        height: 20,
                        width: 20,
                        decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey)),
                        child: filterlowToHigh == true
                            ? Icon(
                                Icons.check,
                                size: 20,
                                color: Colors.deepOrange,
                              )
                            : SizedBox(),
                      ),
                    ],
                  )),
            ),
            SizedBox(
              height: 15,
            ),
            InkWell(
              onTap: () {
                setState(() {
                  filterlowToHigh = true;
                  log(filterlowToHigh.toString());
                });
              },
              child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 10),
                  child: Row(
                    children: [
                      Text(
                        "Day's",
                        style: TextStyle(fontSize: 14),
                      ),
                      SizedBox(
                        width: 10,
                      ),
                      Container(
                        alignment: Alignment.topCenter,
                        height: 20,
                        width: 20,
                        decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey)),
                        child: filterlowToHigh == true
                            ? Icon(
                                Icons.check,
                                size: 20,
                                color: Colors.deepOrange,
                              )
                            : SizedBox(),
                      ),
                    ],
                  )),
            ),
            SizedBox(
              height: 15,
            ),
            InkWell(
              onTap: () {
                setState(() {
                  filterlowToHigh = true;
                  log(filterlowToHigh.toString());
                });
              },
              child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 10),
                  child: Row(
                    children: [
                      Text(
                        "Monthly",
                        style: TextStyle(fontSize: 14),
                      ),
                      SizedBox(
                        width: 10,
                      ),
                      Container(
                        alignment: Alignment.topCenter,
                        height: 20,
                        width: 20,
                        decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey)),
                        child: filterlowToHigh == true
                            ? Icon(
                                Icons.check,
                                size: 20,
                                color: Colors.deepOrange,
                              )
                            : SizedBox(),
                      ),
                    ],
                  )),
            ),
            SizedBox(
              height: 15,
            ),
            InkWell(
              onTap: () {
                setState(() {
                  filterlowToHigh = true;
                  log(filterlowToHigh.toString());
                });
              },
              child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 10),
                  child: Row(
                    children: [
                      Text(
                        "Yearly",
                        style: TextStyle(fontSize: 14),
                      ),
                      SizedBox(
                        width: 10,
                      ),
                      Container(
                        alignment: Alignment.topCenter,
                        height: 20,
                        width: 20,
                        decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey)),
                        child: filterlowToHigh == true
                            ? Icon(
                                Icons.check,
                                size: 20,
                                color: Colors.deepOrange,
                              )
                            : SizedBox(),
                      ),
                    ],
                  )),
            ),
          ],
        ),
      ),
    );
  }

//----------------- Api call-----------------//
  int getCityId = 0;
  int getLastPage = 0;
  Future getUpdtaeSearchLocation() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    int countryID;
    String cityName = '';
    setState(() {
      countryID = prefs.getInt('countryId');
      cityName = prefs.getString('city');
      log("---->$countryID");
    });

    var url = Apis.updtaeSearchLocationApi;
    var body = {
      "country": countryID.toString(),
      "city": cityName.toString(),
    };
    var response = await APIHelper.apiPostRequest(url, body);
    var result = jsonDecode(response);

    if (result['ErrorCode'] == 0) {
      getCityId = result['Response']['id'];
      log("cityI--->${getCityId.toString()}");
      getLatestAddition();
    }
  }

  Future getLatestAddition() async {
    setState(() {
      loader = true;
    });
    SharedPreferences preferences = await SharedPreferences.getInstance();
    String country = preferences.getString('country');
    String city = preferences.getString('city');
    String state = preferences.getString('state');

    log("cityId---->$city");

    var url = Apis.browseAdsApi;
    var body = {
      "country": country.toString(),
      "city": city == null || city == "" ? "" : city,
      "state": state == null || state == "" ? "" : state,
      "search": "",
      "q": searchController.text.toString(),
      "page": getLastPage.toString(),
    };
    var response = await APIHelper.apiPostRequest(url, body);
    var result = jsonDecode(response);
    log("=====>$result");

    if (result['ErrorMessage'] == 'success') {
      var list = result['Response']['leads']['data'] as List;
      setState(() {
        latestAdditionList.clear();
        var listdata =
            list.map((e) => ViewAllLatestAdditiionModel.fromJson(e)).toList();
        latestAdditionList.addAll(listdata);
        getLastPage = result['Response']['leads']['last_page'];
        loader = false;
      });
    }
    setState(() {
      loader = false;
    });
  }

  Future getScrollingDetails(page) async {
    setState(() {});
    SharedPreferences preferences = await SharedPreferences.getInstance();
    String country = preferences.getString('country');
    String state = preferences.getString('state');
    String city = preferences.getString('city');

    var url = Apis.browseAdsApi;
    var body = {
      "country": country.toString(),
      "city": city == null || city == "" ? "" : city,
      "state": state == null || state == "" ? "" : state,
      "search": "",
      "q": searchController.text.toString(),
      "page": getLastPage.toString(),
    };
    var res = await APIHelper.apiPostRequest(url, body);
    var result = jsonDecode(res);

    var list = result['Response']['leads']['data'] as List;
    setState(() {
      // deshDetailsList.clear();
      var listdata =
          list.map((e) => ViewAllLatestAdditiionModel.fromJson(e)).toList();
      latestAdditionList.addAll(listdata);
    });
  }

  bool searchLoader = false;
  bool getSearchData = false;
  Future getDataBySearching() async {
    setState(() {
      searchLoader = true;
    });

    SharedPreferences preferences = await SharedPreferences.getInstance();

    int countryId = preferences.getInt('countryId');
    String cityId = preferences.getString('cityId');
    String country = preferences.getString('country');
    String state = preferences.getString('state');
    String city = preferences.getString('city');
    log("cityId---->$cityId");
    var url = Apis.browseAdsApi;
    var body = {
      "country": country.toString(),
      "city": city == null || city == "" ? "" : city,
      "state": state == null || state == "" ? "" : state,
      "search": "",
      "q": searchController.text.toString(),
      "page": getLastPage.toString(),
    };
    log("body-->$body");
    var response = await APIHelper.apiPostRequest(url, body);
    var result = jsonDecode(response);
    if (result['ErrorCode'] == 0) {
      var list = result['Response']['leads']['data'] as List;
      setState(() {
        latestAdditionList.clear();
        latestAdditionListBySearch.clear();
        var listdata =
            list.map((e) => ViewAllLatestAdditiionModel.fromJson(e)).toList();
        latestAdditionListBySearch.addAll(listdata);
        getSearchData = true;
      });
      setState(() {
        searchLoader = false;
      });
    }
    setState(() {
      searchLoader = false;
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }
}
