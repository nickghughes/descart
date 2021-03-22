import 'dart:ui';

import 'package:descart/network.dart';
import 'package:descart/product.dart';
import 'package:descart/purchase_form.dart';
import 'package:descart/util.dart';
import 'package:flutter/material.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';

class ShoppingList extends StatefulWidget {
  ShoppingList();

  _ShoppingListState createState() => _ShoppingListState();
}

class _ShoppingListState extends State<ShoppingList> {
  Future<List<dynamic>> _stores;
  List<dynamic> stores;

  _ShoppingListState();

  @override
  void initState() {
    _stores = getShoppingList();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: Colors.green[100],
        child: FutureBuilder(
            future: _stores,
            builder: (context, data) {
              if (data.hasData) {
                stores = data.data;
                return shoppingList(context);
              } else {
                return Center(child: CircularProgressIndicator());
              }
            }),
      ),
    );
  }

  Widget shoppingList(BuildContext context) {
    return stores.length > 0
        ? ListView.separated(
            key: Key("${stores.length}"),
            separatorBuilder: (context, idx) => SizedBox(height: 5),
            itemCount: stores.length,
            itemBuilder: (context, index) =>
                ShoppingListBlock(stores[index], () {
              stores.removeAt(index);
              setState(() {});
            }),
          )
        : Center(
            child: Text("Your shopping list is empty."),
          );
  }
}

class ShoppingListBlock extends StatefulWidget {
  final Map<String, dynamic> store;
  final Function onClear;

  ShoppingListBlock(this.store, this.onClear);

  _ShoppingListBlockState createState() =>
      _ShoppingListBlockState(store, onClear);
}

class _ShoppingListBlockState extends State<ShoppingListBlock> {
  Map<String, dynamic> store;
  Function onClear;

  _ShoppingListBlockState(this.store, this.onClear);

  void openProductPreview(BuildContext context, int index) {
    Map<String, dynamic> product = store["items"][index];
    product.addAll({
      "productName": store['items'][index]["name"],
      "productId": store['items'][index]["id"]
    });
    showCupertinoModalBottomSheet<void>(
      context: context,
      expand: false,
      isDismissible: true,
      builder: (context) => SingleChildScrollView(
        controller: ModalScrollController.of(context),
        child: ProductPreview(product, (bool f) {
          store['items'][index]["favorite"] = f;
        }, (b) {}),
      ),
    );
  }

  void createPurchase() {
    showDialog(
        context: context,
        builder: (context) {
          return PurchaseForm.fromShoppingList(store, (clear) {
            if (clear) onClear();
          });
        });
  }

  void confirmClear(BuildContext context, Function onClear) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Clear ${store["name"]} Shopping List"),
          content: Text(
              "Are you sure you want to clear your ${store["name"]} shopping list?"),
          actions: [
            TextButton(
              child: Text("Clear"),
              onPressed: () async {
                for (int i = 0; i < store["items"].length; i++) {
                  await addRemoveShoppingCart(
                      store["items"][i]["sp_id"], false);
                }
                onClear();
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text("Cancel"),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ],
        );
      },
    );
  }

  void onRemove(int index) async {
    await addRemoveShoppingCart(store["items"][index]["sp_id"], false);
    if (store["items"].length <= 1) {
      onClear();
    } else {
      store["items"].removeAt(index);
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    String itemsText = store["numItems"] == "1" ? "item" : "items";
    return Container(
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.all(Radius.circular(20))),
      child: Container(
        padding: EdgeInsets.all(15),
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  width: 70,
                  child: Center(
                    child: store["imageUrl"] == null
                        ? Icon(Icons.shopping_bag)
                        : ImageWithUrl(store["imageUrl"]),
                  ),
                ),
                Container(
                  padding: EdgeInsets.fromLTRB(15, 0, 0, 0),
                  child: Align(
                    alignment: Alignment.topLeft,
                    child: Text(
                      store["name"],
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: Align(
                    alignment: Alignment.topRight,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          "${store["numItems"]} $itemsText",
                          style: TextStyle(
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 30),
            ListView.separated(
              key: Key("${store["items"].length}"),
              shrinkWrap: true,
              separatorBuilder: (context, index) =>
                  Divider(color: Colors.black),
              itemCount: store["items"].length,
              physics: NeverScrollableScrollPhysics(),
              itemBuilder: (context, index) => InkWell(
                onTap: () {
                  debugPrint(store["items"][index].toString());
                  store["items"][index].containsKey("id")
                      ? openProductPreview(context, index)
                      : debugPrint("cannot open custom item");
                },
                child: Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: Container(
                          padding: EdgeInsets.fromLTRB(0, 0, 5, 0),
                          child: store["items"][index]["imageUrl"] == null
                              ? SizedBox()
                              : ImageWithUrl(
                                  store["items"][index]["imageUrl"])),
                    ),
                    Expanded(
                      flex: 9,
                      child: Text(
                        store["items"][index]["name"],
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Expanded(
                      flex: 1,
                      child: InkWell(
                        onTap: () => onRemove(index),
                        child: Align(
                          alignment: Alignment.center,
                          child: Container(
                            width: 30,
                            height: 30,
                            decoration: BoxDecoration(
                              color: Colors.red,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Icon(
                              Icons.remove,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 30),
            Row(
              children: [
                Expanded(
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: TextButton(
                      onPressed: () => confirmClear(context, onClear),
                      child: Text("Clear"),
                      style: ButtonStyle(
                        foregroundColor:
                            MaterialStateProperty.all<Color>(Colors.red),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: Align(
                    alignment: Alignment.centerRight,
                    child: ElevatedButton(
                      onPressed: () => createPurchase(),
                      child: Text("Create Purchase"),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
