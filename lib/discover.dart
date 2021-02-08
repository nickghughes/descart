import 'package:flutter/material.dart';
import 'package:descart/network.dart';

class Discover extends StatefulWidget {
  @override
  _DiscoverState createState() => _DiscoverState();
}

class _DiscoverState extends State<Discover> {
  List<Map<String, dynamic>> __recs = getRecommendations();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Discover"),
      ),
      body: Container(
        color: Colors.green[100],
        child: Column(
          children: [
            RecsFilter(),
            Expanded(
              child: ListView.separated(
                separatorBuilder: (context, index) => SizedBox(height: 2),
                itemCount: __recs.length,
                itemBuilder: (context, index) => RecommendationBlock(
                  __recs[index]["productName"],
                  __recs[index]["manufacturerName"],
                  __recs[index]["imageUrl"],
                  __recs[index]["numberOfStores"],
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
  @override
  _RecsFilterState createState() => _RecsFilterState();
}

class _RecsFilterState extends State<RecsFilter> {
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
          Icon(Icons.star_border),
          SizedBox(width: 5),
          Icon(Icons.sort)
        ],
      ),
    );
  }
}

class RecommendationBlock extends StatelessWidget {
  final String productName;
  final String manufacturerName;
  final String imageUrl;
  final int numberOfStores;
  final String numberOfStoresText;

  RecommendationBlock(this.productName, this.manufacturerName, this.imageUrl,
      this.numberOfStores)
      : this.numberOfStoresText = numberOfStores == 1 ? "store" : "stores";

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 100,
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.all(Radius.circular(20))),
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
                  Expanded(
                    child: Container(
                      padding: EdgeInsets.fromLTRB(15, 15, 0, 0),
                      child: Align(
                        alignment: Alignment.topLeft,
                        child: Text(
                          productName,
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
                    manufacturerName,
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
    );
  }
}
