import 'package:descart/network.dart';
import 'package:descart/util.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class ProductPreview extends StatefulWidget {
  @override
  _ProductPreviewState createState() => _ProductPreviewState();
}

class _ProductPreviewState extends State<ProductPreview> {
  Map<String, dynamic> _product = getProductPreview();

  @override
  Widget build(BuildContext context) {
    int numStores = _product["numberOfStores"];
    String numStoresText = numStores == 1 ? "store" : "stores";
    List<Map<String, dynamic>> stores = _product["stores"];

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
                          child: Container(
                            width: 150,
                            child: Image.network(_product["imageUrl"]),
                          ),
                        ),
                        Column(
                          children: [
                            Bold.withSize(_product["productName"], 24),
                            // Bold.withSize(_product["manufacturerName"], 16)
                            Text(
                              _product["manufacturerName"],
                              style: TextStyle(
                                  fontStyle: FontStyle.italic, fontSize: 16),
                            )
                          ],
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
                                itemCount: _product["stores"].length,
                                itemBuilder: (context, index) => InkWell(
                                  onTap: () => debugPrint("click store: " +
                                      _product["stores"][index]["storeName"]),
                                  child: Row(
                                    children: [
                                      Expanded(
                                        flex: 1,
                                        child: Container(
                                          padding:
                                              EdgeInsets.fromLTRB(0, 0, 5, 0),
                                          child: Image.network(
                                              _product["stores"][index]
                                                  ["imageUrl"]),
                                        ),
                                      ),
                                      Expanded(
                                        flex: 4,
                                        child: Bold.withSize(
                                            _product["stores"][index]
                                                ["storeName"],
                                            16),
                                      ),
                                      Expanded(
                                        flex: 2,
                                        child: Text("\$ " +
                                            _product["stores"][index]["price"]),
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
