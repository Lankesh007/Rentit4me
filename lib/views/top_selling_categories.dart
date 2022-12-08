import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:rentit4me_new/models/slug_data_model.dart';
import 'package:rentit4me_new/network/api.dart';
import 'package:rentit4me_new/views/product_detail_screen.dart';
import 'package:rentit4me_new/widgets/api_helper.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TopSellingCategories extends StatefulWidget {
  final String category;
  final String price;
  const TopSellingCategories({this.category, this.price, Key key})
      : super(key: key);

  @override
  State<TopSellingCategories> createState() => _TopSellingCategoriesState();
}

class _TopSellingCategoriesState extends State<TopSellingCategories> {
  final searchController = TextEditingController();
  bool loader = false;
  List<SlugDataModel> slugList = [];
  double height = 0;
  double width = 0;
  List<SlugDataModel> slugSearchList = [];

  bool searchLoader = false;
  bool getSearchData = false;

  @override
  void initState() {
    getSlugData();
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
         
        ),
        body: RefreshIndicator(
          onRefresh: () async {
            getSlugData();
          },
          child: ListView(
            children: [
              searchWidget(),
              Divider(),
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 10),
                child: Text(
                  "Category ",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
                ),
              ),
              const SizedBox(
                height: 10,
              ),
              Divider(),
              getSearchData == true
                  ? slugSearchList.isEmpty
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
                                  // controller: searchController,
                                  physics: BouncingScrollPhysics(),
                                  shrinkWrap: true,
                                  itemCount: slugSearchList.length,
                                  itemBuilder:
                                      (BuildContext context, int index) =>
                                          latestAdditionWidget(
                                            slugSearchList[index],
                                          ),
                                  gridDelegate:
                                      SliverGridDelegateWithFixedCrossAxisCount(
                                          crossAxisCount: 2,
                                          crossAxisSpacing: 1.0,
                                          mainAxisSpacing: 1.0)),
                            )
                  : slugList.isEmpty
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
                                  // controller: searchController,
                                  physics: BouncingScrollPhysics(),
                                  shrinkWrap: true,
                                  itemCount: slugList.length,
                                  itemBuilder:
                                      (BuildContext context, int index) =>
                                          latestAdditionWidget(
                                            slugList[index],
                                          ),
                                  gridDelegate:
                                      SliverGridDelegateWithFixedCrossAxisCount(
                                          crossAxisCount: 2,
                                          crossAxisSpacing: 1.0,
                                          mainAxisSpacing: 1.0)),
                            ),
            ],
          ),
        ));
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
                        // getUpdtaeSearchLocation();
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

  Widget latestAdditionWidget(SlugDataModel item) {
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
                SizedBox(
                  height: 3,
                ),
                Container(
                    width: width * 0.5,
                    alignment: Alignment.centerLeft,
                    child: Text(
                      "Starting From ${"${item.currency} ${item.price}"} ",
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

  Future getSlugData() async {
    setState(() {
      loader = true;
    });
    SharedPreferences preferences = await SharedPreferences.getInstance();
    int countryId = preferences.getInt('countryId');
    String cityId = preferences.getString('cityId');
    String country = preferences.getString('country');
    String state = preferences.getString('state');
    String city = preferences.getString('city');
    log("cityId---->$cityId");

    var url = Apis.browseAdsApi;
    // var body = cityId == null || cityId == ""
    //     ? {
    //         "country": countryId.toString(),
    //         "city": "",
    //         "search": "",
    //         "q": searchController.text.toString(),
    //         "category": widget.category,
    //       }
    //     : {
    //         "country": countryId.toString(),
    //         "city": cityId.toString() == null
    //             ? ""
    //             : cityId.toString() == ""
    //                 ? ""
    //                 : cityId.toString(),
    //         "search": "",
    //         "q": searchController.text.toString(),
    //         "category": widget.category,
    //       };
    var body = {
      "country": country.toString(),
      "city": city == null || city == "" ? "" : city,
      "state": state == null || state == "" ? "" : state,
      "search": "",
      "q": searchController.text.toString(),
      "category": widget.category.toString(),
    };
    var response = await APIHelper.apiPostRequest(url, body);
    var result = jsonDecode(response);
    log("=====>$result");

    if (result['ErrorMessage'] == 'success') {
      var list = result['Response']['leads']['data'] as List;
      setState(() {
        slugList.clear();
        var listdata = list.map((e) => SlugDataModel.fromJson(e)).toList();
        slugList.addAll(listdata);
        // getLastPage = result['Response']['leads']['last_page'];
        loader = false;
      });
    }
    setState(() {
      loader = false;
    });
  }

  Future getDataBySearching() async {
    setState(() {
      searchLoader = true;
    });

    SharedPreferences preferences = await SharedPreferences.getInstance();

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
      "q": searchController.text.toString(),
      "category": widget.category.toString(),
    };
    log("body-->$body");
    var response = await APIHelper.apiPostRequest(url, body);
    var result = jsonDecode(response);
    if (result['ErrorCode'] == 0) {
      var list = result['Response']['leads']['data'] as List;
      setState(() {
        slugList.clear();
        slugSearchList.clear();
        var listdata = list.map((e) => SlugDataModel.fromJson(e)).toList();
        slugSearchList.addAll(listdata);
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
}
