import 'package:descart/network.dart';
import 'package:descart/product.dart';
import 'package:descart/util.dart';
import 'package:flutter/material.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';

class PurchasePreview extends StatefulWidget {
  Map<String, dynamic> purchase;

  PurchasePreview(this.purchase);

  @override
  _PurchasePreviewState createState() => _PurchasePreviewState(purchase);
}

class _PurchasePreviewState extends State<PurchasePreview> {
  Map<String, dynamic> _purchase;
  Future<List<dynamic>> _items;

  _PurchasePreviewState(this._purchase);

  @override
  void initState() {
    _items = getPurchaseItems(_purchase["purchaseId"]);
    super.initState();
  }

  void openProductPreview(BuildContext context, dynamic product) {
    showCupertinoModalBottomSheet<void>(
      context: context,
      expand: false,
      isDismissible: true,
      builder: (context) => SingleChildScrollView(
          controller: ModalScrollController.of(context),
          child: ProductPreview(product)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: _items,
        builder: (context, data) {
          if (data.hasData) {
            _purchase["items"] = data.data;
            return preview(context, _purchase);
          } else {
            return Center(child: CircularProgressIndicator());
          }
        });
  }

  Widget preview(BuildContext context, Map<String, dynamic> purchase) {
    int numItems = purchase["numItems"];
    String numItemsText = numItems == 1 ? "1 item" : "$numItems items";
    List<dynamic> items = purchase["items"];
    String subtotal = items
        .map((el) => double.parse(el["price"]) * el["quantity"])
        .reduce((curr, next) => curr + next)
        .toStringAsFixed(2);
    String lambda = (double.parse(purchase["price"]) - double.parse(subtotal))
        .toStringAsFixed(2);

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
                  child: Row(
                    children: [
                      Expanded(flex: 8, child: SizedBox()),
                      Expanded(
                        flex: 1,
                        child: InkWell(
                          onTap: () => debugPrint("toggle favorite"),
                          child: true
                              ? Icon(Icons.star, color: Colors.yellow)
                              : Icon(Icons.star_outline),
                        ),
                      ),
                      Expanded(
                        flex: 1,
                        child: GestureDetector(
                          onTap: () => Navigator.of(context).pop(),
                          child: Icon(Icons.close),
                        ),
                      ),
                    ],
                  ),
                ),
                Column(
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 100,
                          child: purchase["imageUrl"] == null
                              ? Icon(Icons.shopping_bag)
                              : ImageWithUrl(purchase["imageUrl"]),
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
                                    purchase["storeName"],
                                    style: TextStyle(
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Text(
                                    purchase["purchaseDate"],
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
                                itemCount: purchase["items"].length,
                                itemBuilder: (context, index) => InkWell(
                                  onTap: () => purchase["items"][index]
                                          .containsKey("productId")
                                      ? openProductPreview(
                                          context, purchase["items"][index])
                                      : debugPrint("cannot open custom item"),
                                  child: Row(
                                    children: [
                                      Expanded(
                                        flex: 1,
                                        child: Text(purchase["items"][index]
                                                ["quantity"]
                                            .toString()),
                                      ),
                                      Expanded(
                                        flex: 1,
                                        child: Container(
                                            padding:
                                                EdgeInsets.fromLTRB(0, 0, 5, 0),
                                            child: purchase["items"][index]
                                                        ["imageUrl"] ==
                                                    null
                                                ? SizedBox()
                                                : ImageWithUrl(purchase["items"]
                                                    [index]["imageUrl"])),
                                      ),
                                      Expanded(
                                        flex: 4,
                                        child: Text(purchase["items"][index]
                                            ["productName"]),
                                      ),
                                      Expanded(
                                        flex: 2,
                                        child: Text(
                                            purchase["items"][index]["price"]),
                                      ),
                                      Expanded(
                                        flex: 2,
                                        child: Text((double.parse(
                                                    purchase["items"][index]
                                                        ["price"]) *
                                                purchase["items"][index]
                                                    ["quantity"])
                                            .toString()),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(height: 30),
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
                                  child: Text(purchase["price"]),
                                ),
                              ],
                            ),
                            SizedBox(height: 100),
                            GestureDetector(
                              onTap: () => debugPrint("delete purchase"),
                              child: Text(
                                "Delete Purchase",
                                style: TextStyle(color: Colors.red),
                              ),
                            ),
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
