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
    _purchases = getPurchaseHistory(1, "", false, 0);
    super.initState();
  }

  void updateFilter(String search, bool favorite, int sortIdx) {
    setState(() {
      _purchases = getPurchaseHistory(1, search, favorite, sortIdx);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: Colors.green[100],
        child: Column(
          children: [
            PurchaseFilter(
              (String search, bool favorite, int sortIdx) =>
                  updateFilter(search, favorite, sortIdx),
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
        key: Key(purchases.length.toString()),
        separatorBuilder: (context, index) => SizedBox(height: 2),
        itemCount: purchases.length,
        itemBuilder: (context, index) => PurchaseHistoryBlock(
          purchases[index]["purchase_id"],
          purchases[index]["storeName"],
          purchases[index]["purchaseDate"],
          purchases[index]["imageUrl"],
          purchases[index]["price"],
          purchases[index]["favorite"] == "1",
          purchases[index]["items"],
          () {
            purchases.removeAt(index);
            setState(() {});
          },
        ),
      ),
    );
  }
}

class PurchaseFilter extends StatefulWidget {
  final Function(String, bool, int) onUpdate;
  PurchaseFilter(this.onUpdate);

  @override
  _PurchaseFilterState createState() => _PurchaseFilterState(onUpdate);
}

class _PurchaseFilterState extends State<PurchaseFilter> {
  bool _favorite = false;
  int _sortIdx = 0;
  final searchController = TextEditingController();

  static const List<String> sortOptions = [
    "Date ↓",
    "Date ↑",
    "Price ↓",
    "Price ↑"
  ];

  Function(String, bool, int) onUpdate;
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
                      onChanged: (String query) =>
                          onUpdate(query, _favorite, _sortIdx),
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
          SizedBox(width: 10),
          InkWell(
            onTap: () {
              _favorite = !_favorite;
              onUpdate(searchController.text, _favorite, _sortIdx);
              setState(() {});
            },
            child: _favorite
                ? Icon(Icons.star, color: Colors.yellow)
                : Icon(Icons.star_outline),
          ),
          SizedBox(width: 10),
          Container(
            width: 48,
            child: DropdownButton(
                selectedItemBuilder: (BuildContext context) =>
                    List(sortOptions.length)
                        .map((dynamic) => Icon(Icons.sort))
                        .toList(),
                value: _sortIdx,
                items: sortOptions
                    .asMap()
                    .map(
                      (i, opt) => MapEntry(
                        i,
                        DropdownMenuItem(
                            child: Text(opt, style: TextStyle(fontSize: 14)),
                            value: i),
                      ),
                    )
                    .values
                    .toList(),
                onChanged: (value) {
                  _sortIdx = value;
                  onUpdate(searchController.text, _favorite, _sortIdx);
                  setState(() {});
                }),
          ),
        ],
      ),
    );
  }
}

class PurchaseHistoryBlock extends StatefulWidget {
  final int purchaseId;
  final String storeName;
  final String date;
  final String imageUrl;
  final String price;
  final bool favorite;
  final int items;
  final Function onDelete;

  PurchaseHistoryBlock(this.purchaseId, this.storeName, this.date,
      this.imageUrl, this.price, this.favorite, this.items, this.onDelete);

  @override
  _PurchaseHistoryBlockState createState() => _PurchaseHistoryBlockState(
      purchaseId, storeName, date, imageUrl, price, favorite, items, onDelete);
}

class _PurchaseHistoryBlockState extends State<PurchaseHistoryBlock> {
  final int purchaseId;
  final String storeName;
  final String date;
  final String imageUrl;
  final String price;
  bool favorite;
  final int items;
  final String itemsText;

  final Function onDelete;

  _PurchaseHistoryBlockState(this.purchaseId, this.storeName, this.date,
      this.imageUrl, this.price, this.favorite, this.items, this.onDelete)
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
          "favorite": favorite,
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
          return PurchasePreview(purchase, (bool _favorite) {
            this.favorite = _favorite;
            setState(() {});
          }, onDelete);
        });
  }
}
