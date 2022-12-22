import 'dart:convert';
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:rentit4me_new/network/api.dart';
import 'package:rentit4me_new/themes/constant.dart';
import 'package:rentit4me_new/utils/dialog_utils.dart';
import 'package:rentit4me_new/views/product_detail_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/view_all_latest_addtion.dart';
import '../widgets/api_helper.dart';

class ViewAllLatestAddition extends StatefulWidget {
  final String cityId;
  final String searchText;
  const ViewAllLatestAddition({this.cityId, this.searchText, Key key})
      : super(key: key);

  @override
  State<ViewAllLatestAddition> createState() => _ViewAllLatestAdditionState();
}

class _ViewAllLatestAdditionState extends State<ViewAllLatestAddition> {
  List<ViewAllLatestAdditiionModel> latestAdditionList = [];
  // List<ViewAllLatestAdditiionModel> latestAdditionList = [];

  ScrollController scrollController = ScrollController();

  final searchController = TextEditingController();
  double height = 0;
  double width = 0;
  bool loader = false;
  bool hasNext = true;
  bool isLoadMore = false;
  bool filterlowToHigh = false;
  var items = [
    'Sort by',
    'Low to High',
    'High to Low',
  ];
  String sortByValue = "Sort by";

  var tenureItems = [
    'Select Tenure',
    'Hourly',
    'Days',
    'Monthly',
    'Yearly ',
  ];
  String tenureValue = "Select Tenure";
  String sortFilterValue;
  int page = 1;

  @override
  void initState() {
    getLatestAddition();
    scrollController.addListener(() {
      if (scrollController.position.pixels ==
          scrollController.position.maxScrollExtent) {
        setState(() {
          page++;
          hasNext = true;
          isLoadMore = true;
          log("Page--->$page");
        });

        if (page > getLastPage) {
        } else {
          getScrollingDetails(page.toString());
        }
      }
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    height = MediaQuery.of(context).size.height;
    width = MediaQuery.of(context).size.width;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Appcolors.whiteColor,
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
            Divider(),
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  SizedBox(
                    height: 30,
                    width: 130,
                    child: FormField(
                      builder: (FormFieldState state) {
                        return InputDecorator(
                          decoration: InputDecoration(
                            fillColor: Colors.white,
                            filled: true,
                            // labelText: "Select",
                            border: InputBorder.none,
                            isDense: true,
                            contentPadding: EdgeInsets.all(5),
                          ),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton(
                              onTap: () {},
                              value: tenureValue == "Select Tenure"
                                  ? "Sort by"
                                  : sortByValue,
                              icon: const Icon(Icons.keyboard_arrow_down),
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
                                  sortByValue = newValue;
                                  if (sortByValue == "Sort by") {
                                    setState(() {
                                      latestAdditionList.clear();
                                    });
                                  } else {
                                    if (tenureValue == "Select Tenure") {
                                      sortByValue = "Sort by";
                                      showToast(
                                          "Please Select Tenure First!! ");
                                    } else {
                                      if (sortByValue == "Low to High") {
                                        setState(() {
                                          sortFilterValue = "0";
                                          page = 1;
                                        });
                                        getDataByFilters();
                                      } else if (sortByValue == "High to Low") {
                                        setState(() {
                                          sortFilterValue = "1";
                                          page = 1;
                                        });
                                        getDataByFilters();
                                      } else {
                                        latestAdditionList.clear();
                                      }
                                    }
                                  }
                                });
                              },
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  SizedBox(
                    height: 30,
                    width: 130,
                    child: FormField(
                      builder: (FormFieldState state) {
                        return InputDecorator(
                          decoration: InputDecoration(
                            fillColor: Colors.white,
                            filled: true,
                            // labelText: "Select",
                            border: InputBorder.none,
                            isDense: true,
                            contentPadding: EdgeInsets.all(5),
                          ),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton(
                              onTap: () {},
                              value: tenureValue,
                              icon: const Icon(Icons.keyboard_arrow_down),
                              items: tenureItems.map((String tenureItems) {
                                return DropdownMenuItem(
                                  value: tenureItems,
                                  child: Text(tenureItems),
                                );
                              }).toList(),
                              // After selecting the desired option,it will
                              // change button value to selected value
                              onChanged: (String newValue) {
                                setState(() {
                                  tenureValue = newValue;
                                  log("====>$tenureValue");
                                  if (tenureValue != "Select Tenure") {
                                    if (tenureValue == "Hourly") {
                                      tenureValue = "Hourly";
                                      sortByValue = "Sort by";
                                      setState(() {
                                        page = 1;
                                      });
                                      getDataByFilters();
                                    } else if (tenureValue == "Days") {
                                      tenureValue = "Days";
                                      sortByValue = "Sort by";
                                      setState(() {
                                        page = 1;
                                      });
                                      getDataByFilters();
                                    } else if (tenureValue == "Monthly") {
                                      tenureValue = "Monthly";
                                      sortByValue = "Sort by";
                                      setState(() {
                                        page = 1;
                                      });
                                      getDataByFilters();
                                    } else if (tenureValue == "Yearly") {
                                      tenureValue = "Yearly";
                                      sortByValue = "Sort by";
                                      setState(() {
                                        page = 1;
                                      });
                                      getDataByFilters();
                                    }
                                  } else {}
                                });
                              },
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(
              height: 5,
            ),
            Divider(),
            getSearchData == true
                ? latestAdditionList.isEmpty
                    ? Center(
                        child: Text("No Record Found !!"),
                      )
                    : searchLoader == true
                        ? Center(
                            child: CircularProgressIndicator(),
                          )
                        : SizedBox(
                            height: height * 0.7,
                            width: width,
                            child: Column(
                              children: [
                                GridView.builder(
                                    controller: scrollController,
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
                              ],
                            ),
                          )
                : latestAdditionList.isEmpty
                    ? Center(
                        child: Text("No Record Found !!"),
                      )
                    : loader == true
                        ? Center(
                            child: CircularProgressIndicator(),
                          )
                        : scrollLoader == true
                            ? Container(
                                height: height * 0.6,
                                alignment: Alignment.center,
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    CircularProgressIndicator(),
                                    SizedBox(
                                      height: 10,
                                    ),
                                    Container(
                                        alignment: Alignment.bottomCenter,
                                        child: Text(
                                          "Loading Products...",
                                          style: TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold),
                                        )),
                                  ],
                                ),
                              )
                            : SizedBox(
                                height: height * 0.7,
                                width: width,
                                child: GridView.builder(
                                    controller: scrollController,
                                    physics: BouncingScrollPhysics(),
                                    shrinkWrap: true,
                                    itemCount: latestAdditionList.length,
                                    itemBuilder:
                                        (BuildContext context, int index) =>
                                            Column(
                                              children: [
                                                latestAdditionWidget(
                                                  latestAdditionList[index],
                                                ),
                                              ],
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
                  getLatestAddition();
                },
                style: ButtonStyle(
                    backgroundColor:
                        MaterialStateProperty.all(Appcolors.secondaryColor),
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
                  height: height * 0.14,
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
                      maxLines: 2,
                    )),
                SizedBox(
                  height: 2,
                ),
                Container(
                    width: width * 0.5,
                    alignment: Alignment.centerLeft,
                    child: Text(
                      "Starting From : ${item.currency} ${item.price}",
                      style: TextStyle(
                          fontWeight: FontWeight.w600, color: Colors.grey),
                    )),
              ],
            ),
          ),
        ),
      ],
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

  int currentPage;

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
    var body = widget.searchText == null ||
            widget.searchText == "" ||
            widget.searchText == "null"
        ? {
            "country": country.toString(),
            "city": city == null || city == "" ? "" : city,
            "state": state == null || state == "" ? "" : state,
            "search": "",
            "q": searchController.text.toString(),
            "page": page.toString(),
          }
        : {
            "country": country.toString(),
            "city": city == null || city == "" ? "" : city,
            "state": state == null || state == "" ? "" : state,
            "search": "",
            "q": widget.searchText.toString(),
            "page": page.toString(),
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
        currentPage = result['Response']['leads']['current_page'];

        log("last page--->$getLastPage");
        loader = false;
      });
    }
    setState(() {
      loader = false;
    });
  }

  bool scrollLoader = false;
  Future getScrollingDetails(page) async {
    setState(() {
      scrollLoader = true;
    });
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
      "page": page.toString(),
    };
    var res = await APIHelper.apiPostRequest(url, body);
    var result = jsonDecode(res);

    var list = result['Response']['leads']['data'] as List;
    if (result['ErrorCode'] == 0) {
      setState(() {
        // latestAdditionList.clear();
        var listdata =
            list.map((e) => ViewAllLatestAdditiionModel.fromJson(e)).toList();
        latestAdditionList.addAll(listdata);
        scrollLoader = false;
      });
    } else {
      setState(() {
        scrollLoader = false;
      });
    }
  }

  Future getDataByFilters() async {
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
      "tenure": tenureValue.toString(),
      "sortby": sortFilterValue.toString(),
      "page": currentPage.toString(),
    };
    var res = await APIHelper.apiPostRequest(url, body);
    var result = jsonDecode(res);
    var list = result['Response']['leads']['data'] as List;
    if (result['ErrorCode'] == 0) {
      setState(() {
        latestAdditionList.clear();
        var listdata =
            list.map((e) => ViewAllLatestAdditiionModel.fromJson(e)).toList();
        latestAdditionList.addAll(listdata);
      });
    } else {
      showToast(result['ErrorMessage']);
    }
  }

  bool searchLoader = false;
  bool getSearchData = false;
  Future getLate() async {
    setState(() {
      searchLoader = true;
      scrollLoader = true;
    });

    SharedPreferences preferences = await SharedPreferences.getInstance();

    // int countryId = preferences.getInt('countryId');
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
      // "search": "",
      "q": searchController.text.toString(),
      "page": page.toString(),
    };
    log("body-->$body");
    var response = await APIHelper.apiPostRequest(url, body);
    var result = jsonDecode(response);
    if (result['ErrorCode'] == 0) {
      var list = result['Response']['leads']['data'] as List;
      setState(() {
        latestAdditionList.clear();
        latestAdditionList.clear();
        var listdata =
            list.map((e) => ViewAllLatestAdditiionModel.fromJson(e)).toList();
        latestAdditionList.addAll(listdata);
        getSearchData = true;
        scrollLoader = false;
      });
      setState(() {
        searchLoader = false;
        scrollLoader = false;
      });
    }
    setState(() {
      searchLoader = false;
      scrollLoader = false;
    });
  }

  @override
  void dispose() {
    scrollController.dispose();
    super.dispose();
  }
}
