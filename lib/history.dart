import 'package:descart/network.dart';
import 'package:descart/purchase.dart';
import 'package:descart/util.dart';
import 'package:flutter/material.dart';

class PurchaseHistory extends StatefulWidget {
  @override
  _PurchaseHistoryState createState() => _PurchaseHistoryState();
}

class _PurchaseHistoryState extends State<PurchaseHistory> {
  Future<List<dynamic>> _purchases;

  @override
  void initState() {
    _purchases = getPurchaseHistory(1, "", false);
    super.initState();
  }

  void updateFilter(String search, bool favorite) {
    debugPrint("update $search $favorite");
    setState(() {
      _purchases = getPurchaseHistory(1, search, favorite);
    });
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
            PurchaseFilter(
              (String search, bool favorite) => updateFilter(search, favorite),
            ),
            FutureBuilder(
              future: _purchases,
              builder: (context, data) {
                if (data.connectionState != ConnectionState.done) {
                  return Center(child: CircularProgressIndicator());
                }
                if (data.hasError) {
                  return SizedBox();
                }
                return PurchaseHistoryBody(data.data);
              },
            ),
          ],
        ),
      ),
    );
  }
}

class PurchaseHistoryBody extends StatefulWidget {
  final List<dynamic> purchases;
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
  final Function(String, bool) onUpdate;
  PurchaseFilter(this.onUpdate);

  @override
  _PurchaseFilterState createState() => _PurchaseFilterState(onUpdate);
}

class _PurchaseFilterState extends State<PurchaseFilter> {
  bool _favorite = false;
  final searchController = TextEditingController();

  Function(String, bool) onUpdate;
  _PurchaseFilterState(this.onUpdate);

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
                      controller: searchController,
                      onChanged: (String query) => onUpdate(query, _favorite),
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
          InkWell(
            onTap: () {
              _favorite = !_favorite;
              onUpdate(searchController.text, _favorite);
              setState(() {});
            },
            child: _favorite
                ? Icon(Icons.star, color: Colors.yellow)
                : Icon(Icons.star_outline),
          ),
          SizedBox(width: 5),
          InkWell(
            onTap: () => debugPrint("sort"),
            child: Icon(Icons.sort),
          ),
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
                            : ImageWithUrl(imageUrl),
                      ),
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
