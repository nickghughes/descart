import 'package:flutter/material.dart';
import 'package:descart/network.dart';
import 'package:descart/product.dart';
import 'package:descart/util.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:filter_list/filter_list.dart';

class Discover extends StatefulWidget {
  Discover();

  @override
  _DiscoverState createState() => _DiscoverState();
}

class _DiscoverState extends State<Discover> {
  String _search = "";
  bool _favorite = false;
  List<String> _categories;

  _DiscoverState();

  void updateFilter(String search, bool favorite, List<String> categories) {
    _search = search;
    _favorite = favorite;
    _categories = categories;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: Colors.green[100],
        child: Column(
          children: [
            RecsFilter(updateFilter),
            Expanded(
              child: DiscoverBody(_search, _favorite, _categories),
            ),
          ],
        ),
      ),
    );
  }
}

class RecsFilter extends StatefulWidget {
  final Function(String, bool, List<String>) onUpdate;
  RecsFilter(this.onUpdate);

  @override
  _RecsFilterState createState() => _RecsFilterState(onUpdate);
}

class _RecsFilterState extends State<RecsFilter> {
  bool _favorite = false;
  final searchController = TextEditingController();
  bool _useCategory = false;
  List<String> _categories;

  Function(String, bool, List<String>) onUpdate;
  _RecsFilterState(this.onUpdate);

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
                          onUpdate(query, _favorite, ["TODO_CATEGORY"]),
                      maxLength: 35,
                      maxLines: 1,
                      decoration: InputDecoration(
                        hintText: "Search products...",
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
                debugPrint("tapped filter config pane");
                openCategoryPane(context);
                if (_categories.isNotEmpty) {
                  _useCategory = true;
                }
                onUpdate(searchController.text, _favorite, ["TODO_CATEGORY"]);
                setState(() {});
              },
              child: Icon(Icons.filter_list_outlined)),
          SizedBox(width: 5),
          InkWell(
            onTap: () {
              debugPrint("tapped filter");
              _useCategory = !_useCategory;
              onUpdate(searchController.text, _favorite, ["TODO_CATEGORY"]);
              setState(() {});
            },
            child: _useCategory
                ? Icon(Icons.filter_alt, color: Colors.orange)
                : Icon(Icons.filter_alt_outlined),
          ),
          SizedBox(width: 5),
          InkWell(
            onTap: () {
              _favorite = !_favorite;
              onUpdate(searchController.text, _favorite, ["TODO_CATEGORY"]);
              setState(() {});
            },
            child: _favorite
                ? Icon(Icons.star, color: Colors.yellow)
                : Icon(Icons.star_outline),
          ),
        ],
      ),
    );
  }

  void openCategoryPane(BuildContext context) async {
    List<String> countList = [
      "Appliances",
      "Computers",
      "Electronics",
      "Home and Kitchen",
      "Luggage & Travel Gear",
      "Toys & Games",
    ];
    double containerHeight = MediaQuery.of(context).size.height * 2 / 3;
    await FilterListDialog.display(
      context,
      height: containerHeight,
      listData: countList,
      selectedListData: _categories,
      hideheaderText: true,
      hidecloseIcon: true,
      onApplyButtonClick: (list) {
        if (list != null) {
          print("Selected items count: ${list.length}");
          setState(() {
            _categories = List.from(list);
            Navigator.pop(context);
          });
        }
      },
      label: (item) {
        /// Used to print text on chip
        return item.toString();
      },
      validateSelectedItem: (list, val) {
        ///  identify if item is selected or not
        return list.contains(val);
      },
      onItemSearch: (list, text) {
        /// When text change in search text field then return list containing that text value
        ///
        ///Check if list has value which matchs to text
        if (list.any((element) =>
            element.toString().toLowerCase().contains(text.toLowerCase()))) {
          /// return list which contains matches
          return list
              .where((element) =>
                  element.toString().toLowerCase().contains(text.toLowerCase()))
              .toList();
        }
      },
    );
  }
}

class DiscoverBody extends StatefulWidget {
  final String _search;
  final bool _favorite;
  final List<String> _categories;
  DiscoverBody(this._search, this._favorite, this._categories);

  @override
  _DiscoverBodyState createState() =>
      _DiscoverBodyState(_search, _favorite, _categories);
}

class _DiscoverBodyState extends State<DiscoverBody> {
  final int _pageSize = 24;
  String _search;
  bool _favorite;
  List<String> _categories;

  _DiscoverBodyState(this._search, this._favorite, this._categories);

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
  void didUpdateWidget(DiscoverBody oldWidget) {
    if (oldWidget._search != widget._search ||
        oldWidget._favorite != widget._favorite) {
      setState(() {
        _search = widget._search;
        _favorite = widget._favorite;
      });
      _pagingController.refresh();
    }
    super.didUpdateWidget(oldWidget);
  }

  Future<void> _fetchPage(int pageKey) async {
    try {
      final newItems =
          await getRecommendations(_pageSize, pageKey, _search, _favorite);
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
      child: PagedGridView(
        key: Key(
            "${_pagingController.itemList?.length ?? 0}${_pagingController.nextPageKey}$_search$_favorite"),
        gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
          maxCrossAxisExtent: 150,
          mainAxisSpacing: 2,
          crossAxisSpacing: 2,
        ),
        pagingController: _pagingController,
        builderDelegate: PagedChildBuilderDelegate(
          itemBuilder: (context, rec, index) => RecommendationBlock(
            rec["id"],
            rec["productName"],
            rec["manufacturerName"],
            rec["imageUrl"],
            rec["favorite"] != "0",
            int.parse(rec["numStores"]),
          ),
          noItemsFoundIndicatorBuilder: (context) => Center(
            child: Text(
              "No products found",
              style: TextStyle(fontSize: 16),
            ),
          ),
        ),
      ),
    );
  }
}

class RecommendationBlock extends StatefulWidget {
  final int productId;
  final String productName;
  final String manufacturerName;
  final String imageUrl;
  final bool favorite;
  final int numberOfStores;

  RecommendationBlock(this.productId, this.productName, this.manufacturerName,
      this.imageUrl, this.favorite, this.numberOfStores);

  @override
  _RecommendationBlockState createState() => _RecommendationBlockState(
      productId,
      productName,
      manufacturerName,
      imageUrl,
      favorite,
      numberOfStores);
}

class _RecommendationBlockState extends State<RecommendationBlock> {
  final int productId;
  final String productName;
  final String manufacturerName;
  final String imageUrl;
  bool favorite;
  final int numberOfStores;
  final String numberOfStoresText;

  _RecommendationBlockState(this.productId, this.productName,
      this.manufacturerName, this.imageUrl, this.favorite, this.numberOfStores)
      : this.numberOfStoresText = numberOfStores == 1 ? "store" : "stores";

  @override
  Widget build(BuildContext context) {
    return Container(
        decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.all(Radius.circular(5))),
        child: InkWell(
          onTap: () => openProductPreview(context, {
            "productId": productId,
            "productName": productName,
            "manufacturerName": manufacturerName,
            "imageUrl": imageUrl,
            "favorite": favorite,
            "numberOfStores": numberOfStores
          }),
          child: Container(
            padding: EdgeInsets.all(5),
            child: Column(
              children: [
                Expanded(
                  child: imageUrl == null
                      ? SizedBox()
                      : Center(
                          child: ImageWithUrl(imageUrl),
                        ),
                ),
                Text(
                  productName,
                  overflow: TextOverflow.ellipsis,
                  softWrap: true,
                  maxLines: 2,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 2),
                Row(
                  children: [
                    Expanded(
                      child: Align(
                        alignment: Alignment.bottomLeft,
                        child: Text(
                          manufacturerName ?? "",
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                          style: TextStyle(
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ),
                    Align(
                      alignment: Alignment.bottomRight,
                      child: Text(
                        "$numberOfStores $numberOfStoresText",
                        style: TextStyle(
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ));
  }

  void openProductPreview(BuildContext context, Map<String, dynamic> product) {
    showCupertinoModalBottomSheet<void>(
      context: context,
      expand: false,
      isDismissible: true,
      builder: (context) => SingleChildScrollView(
        controller: ModalScrollController.of(context),
        child: ProductPreview(product, (bool _favorite) {
          this.favorite = _favorite;
          setState(() {});
        }),
      ),
    );
  }
}

class Item {
  String _name;
  Item(String name) {
    this._name = name;
  }
  @override
  String toString() {
    return this._name;
  }
}
