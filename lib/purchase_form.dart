import 'dart:async';

import 'package:descart/util.dart';
import 'package:descart/network.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:flutter_masked_text/flutter_masked_text.dart';

class PurchaseStoreForm extends StatefulWidget {
  final Function() onSave;

  PurchaseStoreForm(this.onSave);

  @override
  _PurchaseStoreFormState createState() => _PurchaseStoreFormState(onSave);
}

class _PurchaseStoreFormState extends State<PurchaseStoreForm> {
  final Function() onSave;

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
                    debugPrint(suggestions.toString());
                    return suggestions;
                  },
                  itemBuilder: (context, suggestion) {
                    return ListTile(
                      leading: suggestion["imageUrl"] == null
                          ? SizedBox()
                          : Image.network(suggestion["imageUrl"]),
                      title: Text(suggestion['name']),
                    );
                  },
                  onSuggestionSelected: (suggestion) {
                    debugPrint("opening $suggestion");
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
                              child: Image.network(suggestion["imageUrl"]),
                            ),
                      title: Text(suggestion['name']),
                      subtitle: suggestion["manufacturerName"] == null
                          ? null
                          : Text(suggestion['manufacturerName']),
                    );
                  },
                  onSuggestionSelected: (suggestion) {
                    debugPrint("opening $suggestion");
                    Navigator.of(context).pop();
                    showDialog(
                        context: context,
                        builder: (context) {
                          return ProductInfoForm(suggestion, callback);
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

class ProductInfoForm extends StatefulWidget {
  final Map<String, dynamic> suggestion;
  final void Function(Map<String, dynamic>) callback;
  ProductInfoForm(this.suggestion, this.callback);
  @override
  _ProductInfoFormState createState() =>
      _ProductInfoFormState(this.suggestion, this.callback);
}

class _ProductInfoFormState extends State<ProductInfoForm> {
  final Map<String, dynamic> suggestion;
  final void Function(Map<String, dynamic>) callback;
  _ProductInfoFormState(this.suggestion, this.callback);

  final priceController = MoneyMaskedTextController(
      decimalSeparator: '.', thousandSeparator: '', leftSymbol: '\$');
  final quantityController = TextEditingController();

  @override
  void dispose() {
    super.dispose();
    priceController.dispose();
    quantityController.dispose();
  }

  void useCallback(BuildContext context) {
    int quantity = int.parse(quantityController.text);
    String price =
        priceController.text.substring(1, priceController.text.length);
    Map<String, dynamic> item = {"quantity": quantity, "price": price};
    item.addAll(suggestion);
    callback(item);
    Navigator.of(context).pop();
  }

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
                Bold.withSize("Please enter more information for item:", 16),
                Text(suggestion['name']),
                Row(
                  children: [
                    Expanded(
                        child: Align(
                            alignment: Alignment.centerRight,
                            child: Bold("Quantity")),
                        flex: 2),
                    SizedBox(width: 20),
                    Expanded(
                      child: TextField(
                        controller: quantityController,
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly
                        ],
                      ),
                      flex: 1,
                    ),
                    Expanded(
                        child: Align(
                            alignment: Alignment.centerRight,
                            child: Bold("Price")),
                        flex: 2),
                    SizedBox(width: 20),
                    Expanded(
                        child: TextField(controller: priceController), flex: 3),
                    Expanded(child: SizedBox(), flex: 1),
                  ],
                ),
                SizedBox(height: 30),
                GestureDetector(
                  onTap: () {
                    quantityController.text.length > 0
                        ? useCallback(context)
                        : debugPrint("not ready");
                  },
                  child: Text(
                    "Done",
                    style: TextStyle(color: Theme.of(context).primaryColor),
                  ),
                )
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
  final Function() onSave;
  PurchaseForm(this.store, this.onSave);

  @override
  _PurchaseFormState createState() => _PurchaseFormState(store, onSave);
}

class _PurchaseFormState extends State<PurchaseForm> {
  final Map<String, dynamic> store;
  final Function() onSave;
  _PurchaseFormState(this.store, this.onSave);
  final _scrollController = ScrollController();

  @override
  void dispose() {
    super.dispose();
    _scrollController.dispose();
  }

  List<Map<String, dynamic>> items = [];
  final priceController = MoneyMaskedTextController(
      decimalSeparator: '.', thousandSeparator: '', leftSymbol: '\$');

  void savePurchase(BuildContext context) async {
    Map<String, dynamic> purchase = {
      "user_id": 1,
      "store_id": store['id'],
      "price": priceController.text.substring(1, priceController.text.length),
      "products": items
          .map((item) => item.containsKey("id")
              ? {
                  "id": item["id"],
                  "price": item["price"],
                  "quantity": item["quantity"]
                }
              : {
                  "name": item["name"],
                  "price": item["price"],
                  "quantity": item["quantity"]
                })
          .toList()
    };
    debugPrint("Saving purchase with the following structure: $purchase");
    await postPurchase(purchase);
    Navigator.of(context).pop();
    onSave();
  }

  @override
  Widget build(BuildContext context) {
    String subtotal = items.length > 0
        ? items
            .map((el) => double.parse(el["price"]) * el["quantity"])
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
                              : Image.network(store["imageUrl"]),
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
                                controller: _scrollController,
                                separatorBuilder: (context, index) =>
                                    Divider(color: Colors.black),
                                itemCount: items.length + 1,
                                itemBuilder: (context, index) => index !=
                                        items.length
                                    ? InkWell(
                                        onTap: () => debugPrint("clicked item"),
                                        child: Row(
                                          children: [
                                            Expanded(
                                              flex: 1,
                                              child: Text(items[index]
                                                      ["quantity"]
                                                  .toString()),
                                            ),
                                            Expanded(
                                              flex: 1,
                                              child: Container(
                                                padding: EdgeInsets.fromLTRB(
                                                    0, 0, 5, 0),
                                                child: items[index]
                                                            ["imageUrl"] ==
                                                        null
                                                    ? SizedBox()
                                                    : Image.network(items[index]
                                                        ["imageUrl"]),
                                              ),
                                            ),
                                            Expanded(
                                              flex: 3,
                                              child: Text(items[index]["name"]),
                                            ),
                                            Expanded(
                                              flex: 2,
                                              child:
                                                  Text(items[index]["price"]),
                                            ),
                                            Expanded(
                                              flex: 2,
                                              child: Text((double.parse(
                                                          items[index]
                                                              ["price"]) *
                                                      items[index]["quantity"])
                                                  .toStringAsFixed(2)),
                                            ),
                                            Expanded(
                                              flex: 1,
                                              child: _addRemoveButton(index),
                                            ),
                                          ],
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
                                                  debugPrint("$product");
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
                                items.length > 0
                                    ? savePurchase(context)
                                    : debugPrint("do nothing");
                              },
                              child: Text(
                                "Save Purchase",
                                style: TextStyle(
                                    color: items.length > 0
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

  Widget _addRemoveButton(int index) {
    return InkWell(
      onTap: () {
        items.removeAt(index);
        setState(() {});
      },
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
    );
  }
}
