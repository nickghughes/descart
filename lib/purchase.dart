import 'package:descart/network.dart';
import 'package:descart/util.dart';
import 'package:flutter/material.dart';

class PurchasePreview extends StatefulWidget {
  @override
  _PurchasePreviewState createState() => _PurchasePreviewState();
}

class _PurchasePreviewState extends State<PurchasePreview> {
  Map<String, dynamic> _purchase = getPurchasePreview();

  @override
  Widget build(BuildContext context) {
    int numItems = _purchase["numItems"];
    String numItemsText = numItems == 1 ? "1 item" : "$numItems items";
    List<Map<String, dynamic>> items = _purchase["items"];
    String subtotal = items
        .map((el) => double.parse(el["price"]) * el["quantity"])
        .reduce((curr, next) => curr + next)
        .toString();
    String lambda =
        (double.parse(_purchase["price"]) - double.parse(subtotal)).toString();

    return Material(
      type: MaterialType.transparency,
      child: SafeArea(
        child: Container(
          padding: EdgeInsets.fromLTRB(10, 20, 10, 20),
          child: Container(
            padding: EdgeInsets.fromLTRB(15, 15, 15, 25),
            decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.all(Radius.circular(20))),
            child: Stack(
              children: [
                Align(
                  alignment: Alignment.topRight,
                  child: GestureDetector(
                    onTap: () => Navigator.of(context).pop(),
                    child: Icon(Icons.close),
                  ),
                ),
                Column(
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 100,
                          child: Image.network(_purchase["imageUrl"]),
                        ),
                        Expanded(
                          child: Container(
                            padding: EdgeInsets.fromLTRB(10, 0, 0, 0),
                            child: Align(
                              alignment: Alignment.topLeft,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    _purchase["storeName"],
                                    style: TextStyle(
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Text(
                                    _purchase["purchaseDate"],
                                    style: TextStyle(
                                      fontSize: 18,
                                    ),
                                  ),
                                  Text(
                                    numItemsText,
                                    style: TextStyle(
                                      fontSize: 18,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        SizedBox(width: 20),
                      ],
                    ),
                    SizedBox(height: 30),
                    Expanded(
                      child: Container(
                        padding: EdgeInsets.fromLTRB(5, 0, 5, 0),
                        child: Column(
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  flex: 1,
                                  child: Bold("#"),
                                ),
                                Expanded(
                                  flex: 1,
                                  child: Container(),
                                ),
                                Expanded(flex: 4, child: Bold("Item")),
                                Expanded(flex: 2, child: Bold("Price")),
                                Expanded(flex: 2, child: Bold("Total")),
                              ],
                            ),
                            SizedBox(height: 30),
                            Expanded(
                              child: ListView.separated(
                                separatorBuilder: (context, index) =>
                                    Divider(color: Colors.black),
                                itemCount: _purchase["items"].length,
                                itemBuilder: (context, index) => InkWell(
                                  onTap: () => debugPrint(
                                      "clicked purchase item: " +
                                          _purchase["items"][index]
                                              ["productName"]),
                                  child: Row(
                                    children: [
                                      Expanded(
                                        flex: 1,
                                        child: Text(_purchase["items"][index]
                                                ["quantity"]
                                            .toString()),
                                      ),
                                      Expanded(
                                        flex: 1,
                                        child: Container(
                                            padding:
                                                EdgeInsets.fromLTRB(0, 0, 5, 0),
                                            child: Image.network(
                                                _purchase["items"][index]
                                                    ["imageUrl"])),
                                      ),
                                      Expanded(
                                        flex: 4,
                                        child: Text(_purchase["items"][index]
                                            ["productName"]),
                                      ),
                                      Expanded(
                                        flex: 2,
                                        child: Text(
                                            _purchase["items"][index]["price"]),
                                      ),
                                      Expanded(
                                        flex: 2,
                                        child: Text((double.parse(
                                                    _purchase["items"][index]
                                                        ["price"]) *
                                                _purchase["items"][index]
                                                    ["quantity"])
                                            .toString()),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  flex: 2,
                                  child: Container(),
                                ),
                                Expanded(
                                  flex: 6,
                                  child: Bold("Subtotal"),
                                ),
                                Expanded(flex: 2, child: Text(subtotal)),
                              ],
                            ),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  flex: 2,
                                  child: Container(),
                                ),
                                Expanded(
                                  flex: 6,
                                  child: Bold("Discounts, Taxes, and Fees"),
                                ),
                                Expanded(
                                  flex: 2,
                                  child: Text(lambda),
                                ),
                              ],
                            ),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  flex: 2,
                                  child: Container(),
                                ),
                                Expanded(
                                  flex: 6,
                                  child: Bold("Total"),
                                ),
                                Expanded(
                                  flex: 2,
                                  child: Text(_purchase["price"]),
                                ),
                              ],
                            ),
                            SizedBox(height: 100),
                            GestureDetector(
                                onTap: () => debugPrint("delete purchase"),
                                child: Text("Delete Purchase",
                                    style: TextStyle(color: Colors.red)))
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
