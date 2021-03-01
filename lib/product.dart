import 'package:descart/network.dart';
import 'package:descart/util.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class ProductPreview extends StatefulWidget {
  final Map<String, dynamic> product;

  ProductPreview(this.product);

  @override
  _ProductPreviewState createState() => _ProductPreviewState(product);
}

class _ProductPreviewState extends State<ProductPreview> {
  Future<List<dynamic>> _stores;
  Map<String, dynamic> _product;

  _ProductPreviewState(this._product);

  void _launchURL(String url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      debugPrint("could not open url");
    }
  }

  @override
  void initState() {
    _stores = getProductStores(_product["productId"]);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: _stores,
        builder: (context, data) {
          if (data.hasData) {
            _product["stores"] = data.data;
            return preview(context, _product);
          } else {
            return Center(child: CircularProgressIndicator());
          }
        });
  }

  Widget preview(BuildContext context, Map<String, dynamic> product) {
    // int numStores = product["numStores"];
    // String numStoresText = numStores == 1 ? "store" : "stores";
    List<dynamic> stores = product["stores"];

    // sort by ascending price
    stores.sort(
        (x, y) => double.parse(x["price"]).compareTo(double.parse(y["price"])));

    double containerHeight = MediaQuery.of(context).size.height * 2 / 3;

    return Material(
      type: MaterialType.transparency,
      child: SafeArea(
          child: Container(
              height: containerHeight,
              decoration: BoxDecoration(
                color: Colors.green,
              ),
              padding: EdgeInsets.fromLTRB(10, 20, 10, 20),
              child: Container(
                padding: EdgeInsets.fromLTRB(15, 15, 15, 15),
                decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.all(Radius.circular(20))),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          flex: 3,
                          child: Container(
                            child: product["imageUrl"] == null
                                ? SizedBox()
                                : ImageWithUrl(product["imageUrl"]),
                          ),
                        ),
                        Expanded(
                          flex: 1,
                          child: SizedBox(),
                        ),
                        Expanded(
                          flex: 6,
                          child: Column(
                            children: [
                              Align(
                                alignment: Alignment.topRight,
                                child: true
                                    ? Icon(Icons.star, color: Colors.yellow)
                                    : Icon(Icons.star_outline),
                              ),
                              Bold.withSize(product["productName"], 20),
                              // Bold.withSize(product["manufacturerName"], 16)
                              Text(
                                product["manufacturerName"] ?? "",
                                style: TextStyle(
                                    fontStyle: FontStyle.italic, fontSize: 16),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 20),
                    Expanded(
                      child: Container(
                        padding: EdgeInsets.fromLTRB(5, 0, 5, 0),
                        child: Column(
                          children: [
                            Row(
                              children: [
                                Expanded(flex: 1, child: Container()),
                                Expanded(flex: 4, child: Bold("Store")),
                                Expanded(flex: 2, child: Bold("Price")),
                              ],
                            ),
                            SizedBox(height: 20),
                            Expanded(
                              flex: 1,
                              child: ListView.separated(
                                separatorBuilder: (context, index) =>
                                    Divider(color: Colors.black),
                                itemCount: product["stores"].length,
                                itemBuilder: (context, index) => InkWell(
                                  onTap: () => _launchURL(
                                      product["stores"][index]["url"]),
                                  child: Row(
                                    children: [
                                      Expanded(
                                        flex: 1,
                                        child: Container(
                                          padding:
                                              EdgeInsets.fromLTRB(0, 0, 5, 0),
                                          child: product["stores"][index]
                                                      ["imageUrl"] ==
                                                  null
                                              ? SizedBox()
                                              : ImageWithUrl(product["stores"]
                                                  [index]["imageUrl"]),
                                        ),
                                      ),
                                      Expanded(
                                        flex: 4,
                                        child: Bold.withSize(
                                            product["stores"][index]
                                                ["store_name"],
                                            16),
                                      ),
                                      Expanded(
                                        flex: 2,
                                        child: Text("\$ " +
                                            product["stores"][index]["price"]),
                                      )
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ))),
    );
  }
}
