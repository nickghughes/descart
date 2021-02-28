import 'package:descart/network.dart';
import 'package:descart/purchase.dart';
import 'package:flutter/material.dart';

class PurchaseHistory extends StatefulWidget {
  @override
  _PurchaseHistoryState createState() => _PurchaseHistoryState();
}

class _PurchaseHistoryState extends State<PurchaseHistory> {
  Future<List<dynamic>> _purchases;

  @override
  void initState() {
    _purchases = getPurchaseHistory(1);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Purchase History"),
      ),
      body: Container(
        color: Colors.green[100],
        child: Column(
          children: [
            PurchaseFilter(),
            FutureBuilder(
              future: _purchases,
              builder: (context, data) {
                if (data.hasData) {
                  return PurchaseHistoryBody(data.data);
                } else {
                  debugPrint("printing data");
                  debugPrint(data.toString());
                  return Center(child: CircularProgressIndicator());
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}

class PurchaseHistoryBody extends StatefulWidget {
  List<dynamic> purchases;
  PurchaseHistoryBody(this.purchases);

  @override
  _PurchaseHistoryBodyState createState() =>
      _PurchaseHistoryBodyState(purchases);
}

class _PurchaseHistoryBodyState extends State<PurchaseHistoryBody> {
  List<dynamic> purchases;

  _PurchaseHistoryBodyState(this.purchases);

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: ListView.separated(
        separatorBuilder: (context, index) => SizedBox(height: 2),
        itemCount: purchases.length,
        itemBuilder: (context, index) => PurchaseHistoryBlock(
          purchases[index]["purchase_id"],
          purchases[index]["storeName"],
          purchases[index]["purchaseDate"],
          purchases[index]["imageUrl"],
          purchases[index]["price"],
          purchases[index]["items"],
        ),
      ),
    );
  }
}

class PurchaseFilter extends StatefulWidget {
  @override
  _PurchaseFilterState createState() => _PurchaseFilterState();
}

class _PurchaseFilterState extends State<PurchaseFilter> {
  String _query = "";

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(5),
      height: 50,
      child: Row(
        children: [
          Expanded(
            child: Container(
              padding: EdgeInsets.fromLTRB(25, 0, 10, 2),
              decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.all(Radius.circular(20))),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      maxLength: 35,
                      maxLines: 1,
                      decoration: InputDecoration(
                        hintText: "Search stores...",
                        border: InputBorder.none,
                        counterText: "",
                      ),
                    ),
                  ),
                  SizedBox(width: 5),
                  Icon(Icons.search)
                ],
              ),
            ),
          ),
          SizedBox(width: 5),
          Icon(Icons.star_border),
          SizedBox(width: 5),
          Icon(Icons.sort)
        ],
      ),
    );
  }
}

class PurchaseHistoryBlock extends StatelessWidget {
  final int purchaseId;
  final String storeName;
  final String date;
  final String imageUrl;
  final String price;
  final int items;
  final String itemsText;

  PurchaseHistoryBlock(this.purchaseId, this.storeName, this.date,
      this.imageUrl, this.price, this.items)
      : this.itemsText = items == 1 ? "item" : "items";

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 100,
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.all(Radius.circular(20))),
      child: InkWell(
        onTap: () => openPurchasePreview(context, {
          "purchaseId": purchaseId,
          "storeName": storeName,
          "purchaseDate": date,
          "imageUrl": imageUrl,
          "price": price,
          "numItems": items
        }),
        child: Container(
          padding: EdgeInsets.all(15),
          child: Stack(
            children: [
              Align(
                alignment: Alignment.centerLeft,
                child: Row(
                  children: [
                    Container(
                      width: 70,
                      child: Center(
                          child: imageUrl == null
                              ? Icon(Icons.shopping_bag)
                              : Image.network(imageUrl)),
                    ),
                    Container(
                      padding: EdgeInsets.fromLTRB(15, 0, 0, 0),
                      child: Align(
                        alignment: Alignment.topLeft,
                        child: Text(
                          storeName,
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Align(
                alignment: Alignment.bottomCenter,
                child: Text(
                  "\$$price",
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Align(
                alignment: Alignment.topRight,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      date,
                      style: TextStyle(
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
              Align(
                alignment: Alignment.bottomRight,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      "$items $itemsText",
                      style: TextStyle(
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void openPurchasePreview(
      BuildContext context, Map<String, dynamic> purchase) {
    showDialog(
        context: context,
        builder: (context) {
          debugPrint(purchase.toString());
          return PurchasePreview(purchase);
        });
  }
}
