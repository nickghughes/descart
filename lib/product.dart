import 'package:descart/network.dart';
import 'package:descart/util.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class ProductPreview extends StatefulWidget {
  final Map<String, dynamic> product;
  final Function(bool) onUpdateFavorite;
  final Function(bool) onUpdateList;

  ProductPreview(this.product, this.onUpdateFavorite, this.onUpdateList);

  @override
  _ProductPreviewState createState() =>
      _ProductPreviewState(product, onUpdateFavorite, onUpdateList);
}

class _ProductPreviewState extends State<ProductPreview> {
  Future<List<dynamic>> _stores;
  Map<String, dynamic> _product;
  Function(bool) onUpdateFavorite;
  Function(bool) onUpdateList;

  bool _favorite;

  _ProductPreviewState(this._product, this.onUpdateFavorite, this.onUpdateList)
      : _favorite = _product["favorite"];

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
            return preview(context);
          } else {
            return Center(child: CircularProgressIndicator());
          }
        });
  }

  Widget preview(BuildContext context) {
    // int numStores = product["numStores"];
    // String numStoresText = numStores == 1 ? "store" : "stores";
    List<dynamic> stores = _product["stores"];

    // sort by ascending price
    stores.sort(
        (x, y) => double.parse(x["price"]).compareTo(double.parse(y["price"])));

    double containerHeight = MediaQuery.of(context).size.height * 2 / 3;
    debugPrint(stores.toString());
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
                            child: _product["imageUrl"] == null
                                ? SizedBox()
                                : ImageWithUrl(_product["imageUrl"]),
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
                              Row(
                                children: [
                                  Align(
                                    alignment: Alignment.topLeft,
                                    child: Text(_product["categoryName"] ?? ""),
                                  ),
                                  Expanded(
                                    child: Align(
                                      alignment: Alignment.topRight,
                                      child: InkWell(
                                        onTap: () async {
                                          _favorite = !_favorite;
                                          await favoriteProduct(
                                              _product["productId"], _favorite);
                                          onUpdateFavorite(_favorite);
                                          setState(() {});
                                        },
                                        child: _favorite
                                            ? Icon(Icons.star,
                                                color: Colors.yellow)
                                            : Icon(Icons.star_outline),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              Bold.withSize(_product["productName"], 20),
                              Text(
                                _product["manufacturerName"] ?? "",
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
                                Expanded(flex: 2, child: SizedBox()),
                              ],
                            ),
                            SizedBox(height: 20),
                            Expanded(
                              flex: 1,
                              child: ListView.separated(
                                separatorBuilder: (context, index) =>
                                    Divider(color: Colors.black),
                                itemCount: _product["stores"].length,
                                itemBuilder: (context, index) => Row(
                                  children: [
                                    Expanded(
                                      flex: 1,
                                      child: Container(
                                        padding:
                                            EdgeInsets.fromLTRB(0, 0, 5, 0),
                                        child: _product["stores"][index]
                                                    ["imageUrl"] ==
                                                null
                                            ? SizedBox()
                                            : ImageWithUrl(_product["stores"]
                                                [index]["imageUrl"]),
                                      ),
                                    ),
                                    Expanded(
                                      flex: 4,
                                      child: InkWell(
                                        onTap: () => _launchURL(
                                            _product["stores"][index]["url"]),
                                        child: Text(
                                          _product["stores"][index]
                                                  ["store_name"] +
                                              (_product["stores"][index]
                                                          ["url"] !=
                                                      null
                                                  ? " >"
                                                  : ""),
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 16,
                                              color: _product["stores"][index]
                                                          ["url"] ==
                                                      null
                                                  ? Colors.black
                                                  : Theme.of(context)
                                                      .primaryColor),
                                        ),
                                      ),
                                    ),
                                    Expanded(
                                      flex: 2,
                                      child: Text("\$ " +
                                          _product["stores"][index]["price"]),
                                    ),
                                    Expanded(
                                      flex: 2,
                                      child: GestureDetector(
                                        onTap: () async {
                                          _product["stores"][index]["in_cart"] =
                                              !_product["stores"][index]
                                                  ["in_cart"];
                                          await addRemoveShoppingCart(
                                              _product["stores"][index]
                                                  ["sp_id"],
                                              _product["stores"][index]
                                                  ["in_cart"]);
                                          onUpdateList(_product["stores"][index]
                                              ["in_cart"]);
                                          setState(() {});
                                        },
                                        child: Icon(
                                            _product["stores"][index]["in_cart"]
                                                ? Icons.remove_shopping_cart
                                                : Icons.add_shopping_cart,
                                            color: _product["stores"][index]
                                                    ["in_cart"]
                                                ? Theme.of(context).primaryColor
                                                : Colors.grey),
                                      ),
                                    ),
                                  ],
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
