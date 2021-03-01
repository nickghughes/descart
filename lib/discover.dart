import 'package:flutter/material.dart';
import 'package:descart/network.dart';
import 'package:descart/product.dart';
import 'package:descart/util.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';

class Discover extends StatefulWidget {
  final int userId;

  Discover(this.userId);

  @override
  _DiscoverState createState() => _DiscoverState(userId);
}

class _DiscoverState extends State<Discover> {
  Future<List<dynamic>> __recs;
  int userId;

  _DiscoverState(this.userId);

  @override
  void initState() {
    __recs = getRecommendations(userId, "", false);
    super.initState();
  }

  void updateFilter(String search, bool favorite) {
    debugPrint("update $search $favorite");
    setState(() {
      __recs = getRecommendations(1, search, favorite);
    });
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: __recs,
        builder: (context, data) {
          if (data.hasData) {
            return discover(context, data.data);
          } else {
            debugPrint("printing data");
            debugPrint(data.toString());
            return Center(child: CircularProgressIndicator());
          }
        });
  }

  Widget discover(BuildContext context, List<dynamic> recs) {
    debugPrint(recs.toString());
    return Scaffold(
      body: Container(
        color: Colors.green[100],
        child: Column(
          children: [
            RecsFilter(updateFilter),
            Expanded(
              child: ListView.separated(
                separatorBuilder: (context, index) => SizedBox(height: 2),
                itemCount: recs.length,
                itemBuilder: (context, index) => RecommendationBlock(
                  recs[index]["id"],
                  recs[index]["productName"],
                  recs[index]["manufacturerName"],
                  recs[index]["imageUrl"],
                  int.parse(recs[index]["numStores"]),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class RecsFilter extends StatefulWidget {
  Function(String, bool) onUpdate;
  RecsFilter(this.onUpdate);

  @override
  _RecsFilterState createState() => _RecsFilterState(onUpdate);
}

class _RecsFilterState extends State<RecsFilter> {
  bool _favorite = false;
  final searchController = TextEditingController();

  Function(String, bool) onUpdate;
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
                      onChanged: (String query) => onUpdate(query, _favorite),
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
              _favorite = !_favorite;
              onUpdate(searchController.text, _favorite);
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
}

class RecommendationBlock extends StatelessWidget {
  final int productId;
  final String productName;
  final String manufacturerName;
  final String imageUrl;
  final int numberOfStores;
  final String numberOfStoresText;

  RecommendationBlock(this.productId, this.productName, this.manufacturerName,
      this.imageUrl, this.numberOfStores)
      : this.numberOfStoresText = numberOfStores == 1 ? "store" : "stores";

  @override
  Widget build(BuildContext context) {
    String name = productName.length > 50
        ? productName.substring(0, 50) + "..."
        : productName;
    return Container(
        height: 100,
        decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.all(Radius.circular(20))),
        child: InkWell(
          onTap: () => openProductPreview(context, {
            "productId": productId,
            "productName": productName,
            "manufacturerName": manufacturerName,
            "imageUrl": imageUrl,
            "numberOfStores": numberOfStores
          }),
          child: Container(
            padding: EdgeInsets.fromLTRB(15, 5, 15, 5),
            child: Stack(
              children: [
                Align(
                  alignment: Alignment.centerLeft,
                  child: Row(
                    children: [
                      Container(
                        width: 70,
                        child: imageUrl == null
                            ? SizedBox()
                            : Center(child: ImageWithUrl(imageUrl)),
                      ),
                      Expanded(
                        child: Container(
                          padding: EdgeInsets.fromLTRB(15, 20, 30, 0),
                          child: Align(
                            alignment: Alignment.topLeft,
                            child: Text(
                              name,
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      )
                    ],
                  ),
                ),
                Align(
                  alignment: Alignment.topRight,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        manufacturerName ?? "",
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
                        "$numberOfStores $numberOfStoresText",
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
        ));
  }

  void openProductPreview(BuildContext context, Map<String, dynamic> product) {
    showCupertinoModalBottomSheet<void>(
      context: context,
      expand: false,
      isDismissible: true,
      builder: (context) => SingleChildScrollView(
          controller: ModalScrollController.of(context),
          child: ProductPreview(product)),
    );
  }
}
