import 'dart:async';

import 'package:descart/util.dart';
import 'package:descart/network.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:flutter_masked_text/flutter_masked_text.dart';

class PurchaseStoreForm extends StatefulWidget {
  final Function(bool) onSave;

  PurchaseStoreForm(this.onSave);

  @override
  _PurchaseStoreFormState createState() => _PurchaseStoreFormState(onSave);
}

class _PurchaseStoreFormState extends State<PurchaseStoreForm> {
  final Function(bool) onSave;

  _PurchaseStoreFormState(this.onSave);

  @override
  Widget build(BuildContext context) {
    return Material(
      type: MaterialType.transparency,
      child: Center(
        child: Container(
          padding: EdgeInsets.fromLTRB(20, 0, 20, 0),
          child: Container(
            padding: EdgeInsets.fromLTRB(30, 20, 30, 20),
            decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.all(Radius.circular(20))),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Bold.withSize("Choose a store:", 24),
                SizedBox(height: 20),
                TypeAheadField(
                  textFieldConfiguration: TextFieldConfiguration(
                    autofocus: true,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(),
                    ),
                  ),
                  suggestionsCallback: (pattern) async {
                    List<dynamic> suggestions =
                        await getStoreSuggestions(pattern);
                    return suggestions;
                  },
                  itemBuilder: (context, suggestion) {
                    return ListTile(
                      leading: suggestion["imageUrl"] == null
                          ? SizedBox()
                          : ImageWithUrl(suggestion["imageUrl"]),
                      title: Text(suggestion['name']),
                    );
                  },
                  onSuggestionSelected: (suggestion) {
                    Navigator.of(context).pop();
                    showDialog(
                        context: context,
                        builder: (context) {
                          return PurchaseForm(suggestion, onSave);
                        });
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class PurchaseProductForm extends StatefulWidget {
  final void Function(Map<String, dynamic>) callback;
  PurchaseProductForm(this.callback);
  @override
  _PurchaseProductFormState createState() =>
      _PurchaseProductFormState(this.callback);
}

class _PurchaseProductFormState extends State<PurchaseProductForm> {
  final void Function(Map<String, dynamic>) callback;
  _PurchaseProductFormState(this.callback);

  @override
  Widget build(BuildContext context) {
    return Material(
      type: MaterialType.transparency,
      child: Center(
        child: Container(
          padding: EdgeInsets.fromLTRB(20, 0, 20, 0),
          child: Container(
            padding: EdgeInsets.fromLTRB(30, 20, 30, 20),
            decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.all(Radius.circular(20))),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Bold.withSize("Choose a product:", 24),
                SizedBox(height: 20),
                TypeAheadField(
                  textFieldConfiguration: TextFieldConfiguration(
                      autofocus: true,
                      decoration:
                          InputDecoration(border: OutlineInputBorder())),
                  suggestionsCallback: (pattern) async {
                    return await getProductSuggestions(pattern);
                  },
                  itemBuilder: (context, suggestion) {
                    return ListTile(
                      leading: suggestion["imageUrl"] == null
                          ? SizedBox()
                          : Container(
                              width: 50,
                              child: ImageWithUrl(suggestion["imageUrl"]),
                            ),
                      title: Text(suggestion['name']),
                      subtitle: suggestion["manufacturerName"] == null
                          ? null
                          : Text(suggestion['manufacturerName']),
                    );
                  },
                  onSuggestionSelected: (suggestion) {
                    Navigator.of(context).pop();
                    callback(suggestion);
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class PurchaseForm extends StatefulWidget {
  final Map<String, dynamic> store;
  final Function(bool) onSave;
  final bool fromShoppingList;
  PurchaseForm(this.store, this.onSave) : this.fromShoppingList = false;
  PurchaseForm.fromShoppingList(this.store, this.onSave)
      : this.fromShoppingList = true;

  @override
  _PurchaseFormState createState() =>
      _PurchaseFormState(store, onSave, fromShoppingList);
}

class _PurchaseFormState extends State<PurchaseForm> {
  final Map<String, dynamic> store;
  final Function(bool) onSave;
  final bool fromShoppingList;
  List<dynamic> items;
  _PurchaseFormState(this.store, this.onSave, this.fromShoppingList)
      : items = store["items"] as List<dynamic> ?? [];
  final _scrollController = ScrollController();

  @override
  void dispose() {
    super.dispose();
    _scrollController.dispose();
  }

  final priceController = MoneyMaskedTextController(
      decimalSeparator: '.', thousandSeparator: '', leftSymbol: '\$');

  void savePurchase(BuildContext context) async {
    bool clearCart = false;
    if (fromShoppingList) {
      await showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text("Clear ${store["name"]} Shopping List"),
            content: Text(
                "Do you want to clear your ${store["name"]} shopping list?"),
            actions: [
              TextButton(
                child: Text("Yes"),
                onPressed: () {
                  clearCart = true;
                  Navigator.of(context).pop();
                },
              ),
              TextButton(
                child: Text("No"),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ],
          );
        },
      );
    }
    Map<String, dynamic> purchase = {
      "user_id": 1,
      "store_id": store['id'],
      "price": priceController.text.substring(1, priceController.text.length),
      "clear_cart": clearCart,
      "products": items
          .map((item) => item.containsKey("id")
              ? {
                  "id": item["id"],
                  "price": item["price"],
                  "quantity": int.parse(item["quantity"])
                }
              : {
                  "name": item["name"],
                  "price": item["price"],
                  "quantity": int.parse(item["quantity"])
                })
          .toList()
    };
    await postPurchase(purchase);
    Navigator.of(context).pop();
    onSave(clearCart);
  }

  @override
  Widget build(BuildContext context) {
    String subtotal = items.length > 0
        ? items
            .map((el) =>
                double.parse(el["price"] ?? "0.00") *
                double.parse(el["quantity"] ?? "0.00"))
            .reduce((curr, next) => curr + next)
            .toStringAsFixed(2)
        : "0.00";
    String lambda = (double.parse(priceController.text
                .substring(1, priceController.text.length)) -
            double.parse(subtotal))
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
                          child: store["imageUrl"] == null
                              ? SizedBox()
                              : ImageWithUrl(store["imageUrl"]),
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
                                    store["name"],
                                    style: TextStyle(
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold,
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
                                Expanded(flex: 3, child: Bold("Item")),
                                Expanded(flex: 2, child: Bold("Price")),
                                Expanded(flex: 2, child: Bold("Total")),
                                Expanded(flex: 1, child: SizedBox()),
                              ],
                            ),
                            SizedBox(height: 30),
                            Expanded(
                              child: ListView.separated(
                                key: Key("${items.length}"),
                                controller: _scrollController,
                                separatorBuilder: (context, index) =>
                                    Divider(color: Colors.black),
                                itemCount: items.length + 1,
                                itemBuilder: (context, index) => index !=
                                        items.length
                                    ? InkWell(
                                        onTap: () => debugPrint("clicked item"),
                                        child: Container(
                                          height: 80,
                                          child: ItemForm(
                                            items[index],
                                            (quantity) {
                                              items[index]["quantity"] =
                                                  quantity;
                                              setState(() {});
                                            },
                                            (price) {
                                              items[index]["price"] = price;
                                              setState(() {});
                                            },
                                            () {
                                              items.removeAt(index);
                                              setState(() {});
                                            },
                                          ),
                                        ),
                                      )
                                    : Align(
                                        alignment: Alignment.topCenter,
                                        child: GestureDetector(
                                          onTap: () => {
                                            showDialog(
                                              context: context,
                                              builder: (context) {
                                                return PurchaseProductForm(
                                                    (product) {
                                                  items.add(product);
                                                  setState(() => {});
                                                  Timer(
                                                    Duration(milliseconds: 10),
                                                    () => _scrollController
                                                        .jumpTo(_scrollController
                                                            .position
                                                            .maxScrollExtent),
                                                  );
                                                });
                                              },
                                            ),
                                          },
                                          child: Text(
                                            "+ Add Item",
                                            style: TextStyle(
                                                color: Theme.of(context)
                                                    .primaryColor),
                                          ),
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
                                  child: TextField(
                                    controller: priceController,
                                    onChanged: (text) => setState(() => {}),
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 100),
                            GestureDetector(
                              onTap: () {
                                items.length > 0 &&
                                        items.every((item) =>
                                            item.containsKey("quantity") &&
                                            item["quantity"] != "0")
                                    ? savePurchase(context)
                                    : debugPrint("do nothing");
                              },
                              child: Text(
                                "Save Purchase",
                                style: TextStyle(
                                    color: items.length > 0 &&
                                            items.every((item) =>
                                                item.containsKey("quantity") &&
                                                item["quantity"] != "0")
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
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class ItemForm extends StatefulWidget {
  final Map<String, dynamic> item;
  final Function(String) onQuantityUpdate;
  final Function(String) onPriceUpdate;
  final Function onDelete;

  ItemForm(this.item, this.onQuantityUpdate, this.onPriceUpdate, this.onDelete);

  _ItemFormState createState() =>
      _ItemFormState(item, onQuantityUpdate, onPriceUpdate, onDelete);
}

class _ItemFormState extends State<ItemForm> {
  Map<String, dynamic> item;
  Function(String) onQuantityUpdate;
  Function(String) onPriceUpdate;
  Function onDelete;

  _ItemFormState(
      this.item, this.onQuantityUpdate, this.onPriceUpdate, this.onDelete);

  final priceController = MoneyMaskedTextController(
      decimalSeparator: '.',
      thousandSeparator: '',
      leftSymbol: '\$',
      precision: 2);
  final quantityController = TextEditingController();

  @override
  void dispose() {
    super.dispose();
    priceController.dispose();
    quantityController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          flex: 1,
          child: TextField(
            controller: quantityController,
            onChanged: (text) {
              onQuantityUpdate(text.length > 0 ? text : "0");
            },
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          ),
        ),
        Expanded(
          flex: 1,
          child: item["imageUrl"] == null
              ? SizedBox()
              : ImageWithUrl(item["imageUrl"]),
        ),
        Expanded(
          flex: 3,
          child: SingleChildScrollView(child: Text(item["name"])),
        ),
        Expanded(
          flex: 2,
          child: TextField(
            controller: priceController,
            onChanged: (text) {
              onPriceUpdate(priceController.text
                  .substring(1, priceController.text.length));
            },
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          ),
        ),
        Expanded(
          flex: 2,
          child: Text(
            (double.parse(item["price"] ?? "0") *
                    double.parse(item["quantity"] ?? "0"))
                .toStringAsFixed(2),
          ),
        ),
        Expanded(
          flex: 1,
          child: InkWell(
            onTap: () => onDelete(),
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
    );
  }
}
