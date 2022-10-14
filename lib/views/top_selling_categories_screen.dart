import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:rentit4me_new/models/top_selling_categories_model.dart';
import 'package:rentit4me_new/network/api.dart';
import 'package:rentit4me_new/widgets/api_helper.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
  List<TopSellingCatgoriesModel> topCategoriesList = [];
  final searchController = TextEditingController();
  double height = 0;
  double width = 0;
  bool pageLodaing = false;
  List searchList = [];

  @override
  void initState() {
    getCategoriesDetails();
    searchList.addAll(topCategoriesList);
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
              "Categories",
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
              : topCategoriesList.isEmpty
                  ? Container(
                      height: height * 0.68,
                      alignment: Alignment.center,
                      child: Text("No data found !!"),
                    )
                  : SizedBox(
                      height: height * 0.68,
                      width: width,
                      child: GridView.builder(
                        physics: BouncingScrollPhysics(),
                        itemCount: topCategoriesList.length,
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 2,
                                crossAxisSpacing: 4.0,
                                mainAxisSpacing: 4.0,
                                childAspectRatio: 1.0),
                        itemBuilder: (context, index) => categoriesWidget(
                          topCategoriesList[index],
                        ),
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

  Widget categoriesWidget(TopSellingCatgoriesModel item) {
    return Column(
      children: [
        Container(
          height: height * 0.22,
          width: width * 0.5,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
          ),
          child: Card(
            elevation: 5,
            child: Column(
              children: [
                Container(
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(5),
                          topRight: Radius.circular(5)),
                      image: DecorationImage(
                          image: NetworkImage(
                            imagepath + item.image,
                          ),
                          fit: BoxFit.cover)),
                  height: height * 0.18,
                  width: width,
                ),
                SizedBox(
                  height: 3,
                ),
                Text(
                  item.title,
                  style: TextStyle(fontWeight: FontWeight.w600),
                  maxLines: 1,
                )
              ],
            ),
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
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String country = prefs.getString('country');
    String state = prefs.getString('state');
    String city = prefs.getString('city');

    var url = "https://rentit4me.com/api/home";
    var body = {
      "country": country,
      "state": state,
      "city": city,
    };
    var response = await APIHelper.apiPostRequest(url, body);
    var result = jsonDecode(response);
    if (result['ErrorMessage'] == "success") {
      var list = result['Response']['top_selling_categories'] as List;
      setState(() {
        topCategoriesList.clear();
        var listdata=list.map((e) => TopSellingCatgoriesModel.fromJson(e)).toList();
        topCategoriesList.addAll(listdata);
      });
    }
    setState(() {
      pageLodaing = false;
    });
  }


}
