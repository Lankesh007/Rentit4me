import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:rentit4me_new/models/browse_all_category.dart';
import 'package:rentit4me_new/network/api.dart';
import 'package:rentit4me_new/views/product_detail_screen.dart';
import 'package:rentit4me_new/views/top_selling_categories.dart';
import 'package:rentit4me_new/widgets/api_helper.dart';

class TopSellingCategoriesScreen extends StatefulWidget {
  final String country;
  final String state;
  final String city;
  const TopSellingCategoriesScreen(
      {this.country, this.state, this.city, Key key})
      : super(key: key);

  @override
  State<TopSellingCategoriesScreen> createState() =>
      _TopSellingCategoriesScreenState();
}

class _TopSellingCategoriesScreenState
    extends State<TopSellingCategoriesScreen> {
  List<BrowseAllCategories> browseAllCategoryList = [];
  final searchController = TextEditingController();
  double height = 0;
  double width = 0;
  bool pageLodaing = false;
  List searchList = [];

  @override
  void initState() {
    getCategoriesDetails();
    searchList.addAll(browseAllCategoryList);
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
      body: ListView(
        children: [
          searchWidget(),
          Divider(),
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 10),
            child: Text(
              "Browse All Categories",
              style: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.w600,
                  fontSize: 22),
            ),
          ),
          Divider(),
          SizedBox(
            height: 10,
          ),
          pageLodaing == true
              ? Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    CircularProgressIndicator(),
                    SizedBox(
                      height: 20,
                    ),
                    SizedBox(
                      child: Text(
                        "Loading...",
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                )
              : browseAllCategoryList.isEmpty
                  ? Container(
                      height: height * 0.68,
                      alignment: Alignment.center,
                      child: Text("No data found !!"),
                    )
                  : SizedBox(
                      height: height * 0.68,
                      width: width,
                      child: ListView.builder(
                        physics: BouncingScrollPhysics(),
                        itemCount: browseAllCategoryList.length,
                        itemBuilder: ((context, index) => categoriesWidget(
                              browseAllCategoryList[index],
                            )),
                        // child: GridView.builder(
                        //   physics: BouncingScrollPhysics(),
                        //   itemCount: browseAllCategoryList.length,
                        //   gridDelegate:
                        //       const SliverGridDelegateWithFixedCrossAxisCount(
                        //           crossAxisCount: 2,
                        //           crossAxisSpacing: 4.0,
                        //           mainAxisSpacing: 4.0,
                        //           childAspectRatio: 1.0),
                        //   itemBuilder: (context, index) => categoriesWidget(
                        //     browseAllCategoryList[index],
                        //   ),
                        // ),
                      ),
                    ),
        ],
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
                onPressed: () {},
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

  Widget categoriesWidget(BrowseAllCategories item) {
    return Column(
      children: [
        Container(
          height: height * 0.30,
          width: width,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
          ),
          child: Column(
            children: [
              SizedBox(
                height: 3,
              ),
              Container(
                alignment: Alignment.centerLeft,
                margin: const EdgeInsets.symmetric(horizontal: 10),
                child: Text(
                  item.title,
                  style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
                  maxLines: 1,
                ),
              ),
              SizedBox(
                height: 10,
              ),
              item.subcategories.isEmpty
                  ? Container(
                      height: height * 0.22,
                      width: width * 0.5,
                      alignment: Alignment.center,
                      margin: const EdgeInsets.symmetric(horizontal: 10),
                      child: Text(
                        "No Records Found...",
                        style: TextStyle(
                            fontWeight: FontWeight.w400, fontSize: 15),
                        maxLines: 1,
                      ),
                    )
                  : SizedBox(
                      height: height * 0.23,
                      width: width,
                      child: ListView.builder(
                          physics: BouncingScrollPhysics(),
                          scrollDirection: Axis.horizontal,
                          itemCount: item.subcategories.length,
                          itemBuilder: (context, index) {
                            var i = item.subcategories[index];
                            return SizedBox(
                              child: Column(
                                children: [
                                  InkWell(
                                    onTap: () {
                                      Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: ((context) =>
                                                  TopSellingCategories(
                                                    category: i.slug.toString(),
                                                  ))));
                                    },
                                    child: Container(
                                      margin: const EdgeInsets.symmetric(
                                          horizontal: 10),
                                      decoration: BoxDecoration(
                                          borderRadius: BorderRadius.only(
                                              topLeft: Radius.circular(0),
                                              topRight: Radius.circular(0)),
                                          image: DecorationImage(
                                              image: NetworkImage(
                                                imagepath + i.image,
                                              ),
                                              fit: BoxFit.cover)),
                                      height: height * 0.18,
                                      width: width * 0.5,
                                    ),
                                  ),
                                  SizedBox(
                                    height: 10,
                                  ),
                                  Container(
                                    height: height * 0.02,
                                    width: width * 0.5,
                                    alignment: Alignment.centerLeft,
                                    margin: const EdgeInsets.symmetric(
                                        horizontal: 10),
                                    child: Text(
                                      i.title,
                                      style: TextStyle(
                                          fontWeight: FontWeight.w400,
                                          fontSize: 15),
                                      maxLines: 1,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }),
                    ),
              Divider()
            ],
          ),
        ),
      ],
    );
  }

//---------------Api call------------------//

  Future getCategoriesDetails() async {
    setState(() {
      pageLodaing = true;
    });

    var url = Apis.browseAllCategoriesApi;

    var response = await APIHelper.apiGetRequest(url);
    var result = jsonDecode(response);
    log("response---->$result");
    if (result['ErrorMessage'] == "success") {
      var list = result['Response'] as List;
      setState(() {
        browseAllCategoryList.clear();
        var listdata =
            list.map((e) => BrowseAllCategories.fromJson(e)).toList();
        browseAllCategoryList.addAll(listdata);
      });
    }
    setState(() {
      pageLodaing = false;
    });
  }
}
