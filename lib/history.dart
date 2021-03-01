import 'package:descart/network.dart';
import 'package:descart/purchase.dart';
import 'package:flutter/material.dart';

class PurchaseHistory extends StatefulWidget {
  @override
  _PurchaseHistoryState createState() => _PurchaseHistoryState();
}

class _PurchaseHistoryState extends State<PurchaseHistory> {
  List<Map<String, dynamic>> _purchases = getPurchaseHistory();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: Colors.green[100],
        child: Column(
          children: [
            PurchaseFilter(),
            Expanded(
              child: ListView.separated(
                separatorBuilder: (context, index) => SizedBox(height: 2),
                itemCount: _purchases.length,
                itemBuilder: (context, index) => PurchaseHistoryBlock(
                  _purchases[index]["storeName"],
                  _purchases[index]["purchaseDate"],
                  _purchases[index]["imageUrl"],
                  _purchases[index]["price"],
                  _purchases[index]["items"],
                ),
              ),
            ),
          ],
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
  final String storeName;
  final String date;
  final String imageUrl;
  final String price;
  final int items;
  final String itemsText;

  PurchaseHistoryBlock(
      this.storeName, this.date, this.imageUrl, this.price, this.items)
      : this.itemsText = items == 1 ? "item" : "items";

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 100,
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.all(Radius.circular(20))),
      child: InkWell(
        onTap: () => openPurchasePreview(context),
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
                      child: Center(child: Image.network(imageUrl)),
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

  void openPurchasePreview(BuildContext context) {
    showDialog(
        context: context,
        builder: (context) {
          return PurchasePreview();
        });
  }
}
