import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:rentit4me_new/network/api.dart';
import 'package:rentit4me_new/views/product_detail_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/latest_addition_model.dart';
import '../widgets/api_helper.dart';

class ViewAllLatestAddition extends StatefulWidget {
  const ViewAllLatestAddition({Key key}) : super(key: key);

  @override
  State<ViewAllLatestAddition> createState() => _ViewAllLatestAdditionState();
}

class _ViewAllLatestAdditionState extends State<ViewAllLatestAddition> {
  List<LatestAdditionsModel> latestAdditionList = [];

  double height = 0;
  double width = 0;
  bool loader = false;

  @override
  void initState() {
    getLatestAddition();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    height = MediaQuery.of(context).size.height;
    width = MediaQuery.of(context).size.width;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        leading: IconButton(
            onPressed: () {
              Navigator.pop(context);
            },
            icon: Icon(
              Icons.arrow_back_ios,
              color: Colors.black,
            )),
        title: Text(
          "Latest Additions",
          style: TextStyle(
              color: Colors.black, fontSize: 20, fontWeight: FontWeight.w600),
        ),
        centerTitle: true,
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          getLatestAddition();
        },
        child: ListView(
          children: [
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
            latestAdditionList.isEmpty
                ? Center(
                    child: Text("No Record Found !!"),
                  )
                : loader == true
                    ? Center(
                        child: CircularProgressIndicator(),
                      )
                    : SizedBox(
                        height: height * 0.9,
                        width: width,
                        child: GridView.builder(
                            physics: NeverScrollableScrollPhysics(),
                            shrinkWrap: true,
                            itemCount: latestAdditionList.length,
                            itemBuilder: (BuildContext context, int index) =>
                                latestAdditionWidget(
                                    latestAdditionList[index], index),
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

  Widget latestAdditionWidget(LatestAdditionsModel item, int i) {
    i = item.prices.length;
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
                  height: 20,
                  width: width * 0.5,
                  child: GridView.builder(
                      physics: NeverScrollableScrollPhysics(),
                      itemCount: i,
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 1,
                      ),
                      itemBuilder: (BuildContext context, int index) {
                        var i = item.prices[index];
                        return Column(
                          children: [
                            Container(
                                height: 20,
                                width: width * 0.5,
                                alignment: Alignment.centerLeft,
                                child: Text(
                                  "Starting From INR " + i.price.toString(),
                                  style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 13,
                                      color: Colors.grey),
                                )),
                          ],
                        );
                      }),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }


//----------------- Api call-----------------//

  Future getLatestAddition() async {
    setState(() {
      loader = true;
    });
    SharedPreferences preferences = await SharedPreferences.getInstance();
    int countryId = preferences.getInt('countryId');
    log("countryId---->$countryId");
    var url = BASE_URL + homeUrl;
    var body = {
      "country": countryId.toString(),
      "state": "",
      "city": "",
    };
    var response = await APIHelper.apiPostRequest(url, body);
    var result = jsonDecode(response);
    log("=====>$result");

    if (result['ErrorMessage'] == 'success') {
      var list = result['Response']['latest_ads'] as List;
      setState(() {
        latestAdditionList.clear();
        var listdata =
            list.map((e) => LatestAdditionsModel.fromJson(e)).toList();
        latestAdditionList.addAll(listdata);
        loader = false;
      });
    }
    setState(() {
      loader = false;
    });
  }
}
