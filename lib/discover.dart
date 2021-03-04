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
    setState(() {
      __recs = getRecommendations(1, search, favorite);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: Colors.green[100],
        child: Column(
          children: [
            RecsFilter(updateFilter),
            FutureBuilder(
              future: __recs,
              builder: (context, data) {
                if (data.connectionState != ConnectionState.done) {
                  return Center(child: CircularProgressIndicator());
                }
                if (data.hasError) {
                  return SizedBox();
                }
                return discover(context, data.data);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget discover(BuildContext context, List<dynamic> recs) {
    return Expanded(
      child: GridView.extent(
        maxCrossAxisExtent: 150,
        mainAxisSpacing: 2,
        crossAxisSpacing: 2,
        children: recs
            .map(
              (rec) => RecommendationBlock(
                rec["id"],
                rec["productName"],
                rec["manufacturerName"],
                rec["imageUrl"],
                rec["favorite"] == "1",
                int.parse(rec["numStores"]),
              ),
            )
            .toList(),
      ),
      // child: ListView.separated(
      //   separatorBuilder: (context, index) => SizedBox(height: 2),
      //   itemCount: recs.length,
      //   itemBuilder: (context, index) => RecommendationBlock(
      //     recs[index]["id"],
      //     recs[index]["productName"],
      //     recs[index]["manufacturerName"],
      //     recs[index]["imageUrl"],
      //     recs[index]["favorite"] == "1",
      //     int.parse(recs[index]["numStores"]),
      //   ),
      // ),
    );
  }
}

class RecsFilter extends StatefulWidget {
  final Function(String, bool) onUpdate;
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
