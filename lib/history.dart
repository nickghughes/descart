import 'package:descart/network.dart';
import 'package:descart/purchase.dart';
import 'package:descart/util.dart';
import 'package:flutter/material.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';

class PurchaseHistory extends StatefulWidget {
  @override
  _PurchaseHistoryState createState() => _PurchaseHistoryState();
}

class _PurchaseHistoryState extends State<PurchaseHistory> {
  String _search = "";
  bool _favorite = false;
  int _sortIdx = 0;

  void updateFilter(String search, bool favorite, int sortIdx) async {
    _search = search;
    _favorite = favorite;
    _sortIdx = sortIdx;
    setState(() {});
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
            Expanded(
              child: PurchaseHistoryBody(_search, _favorite, _sortIdx),
            ),
          ],
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

class PurchaseHistoryBody extends StatefulWidget {
  final String _search;
  final bool _favorite;
  final int _sortIdx;
  PurchaseHistoryBody(this._search, this._favorite, this._sortIdx);

  @override
  _PurchaseHistoryBodyState createState() =>
      _PurchaseHistoryBodyState(_search, _favorite, _sortIdx);
}

class _PurchaseHistoryBodyState extends State<PurchaseHistoryBody> {
  final int _pageSize = 10;
  String _search;
  bool _favorite;
  int _sortIdx;

  _PurchaseHistoryBodyState(this._search, this._favorite, this._sortIdx);

  final PagingController<int, dynamic> _pagingController =
      PagingController(firstPageKey: 0);

  @override
  void initState() {
    _pagingController.addPageRequestListener((pageKey) {
      _fetchPage(pageKey);
    });
    super.initState();
  }

  @override
  void dispose() {
    _pagingController.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(PurchaseHistoryBody oldWidget) {
    if (oldWidget._search != widget._search ||
        oldWidget._favorite != widget._favorite ||
        oldWidget._sortIdx != widget._sortIdx) {
      setState(() {
        _search = widget._search;
        _favorite = widget._favorite;
        _sortIdx = widget._sortIdx;
      });
      _pagingController.refresh();
    }
    super.didUpdateWidget(oldWidget);
  }

  Future<void> _fetchPage(int pageKey) async {
    try {
      final newItems = await getPurchaseHistory(
          _pageSize, pageKey, _search, _favorite, _sortIdx);
      final isLastPage = newItems.length < _pageSize;
      if (isLastPage) {
        _pagingController.appendLastPage(newItems);
      } else {
        final nextPageKey = pageKey + 1;
        _pagingController.appendPage(newItems, nextPageKey);
      }
    } catch (error) {
      _pagingController.error = error;
    }
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () => Future.sync(
        () => _pagingController.refresh(),
      ),
      child: PagedListView.separated(
        key: Key(
            "${_pagingController.itemList?.length ?? 0}${_pagingController.nextPageKey}$_search$_favorite$_sortIdx"),
        pagingController: _pagingController,
        separatorBuilder: (context, index) => SizedBox(height: 2),
        builderDelegate: PagedChildBuilderDelegate(
          itemBuilder: (context, item, index) => PurchaseHistoryBlock(
            item["purchase_id"],
            item["storeName"],
            item["purchaseDate"],
            item["imageUrl"],
            item["price"],
            item["favorite"] == "1",
            item["items"],
            () {
              _pagingController.itemList.removeAt(index);
              setState(() {});
            },
          ),
          noItemsFoundIndicatorBuilder: (context) => Center(
            child: Text(
              "No purchases found",
              style: TextStyle(fontSize: 16),
            ),
          ),
        ),
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
