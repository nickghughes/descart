import 'package:flutter/material.dart';

class PurchaseHistory extends StatefulWidget {
  @override
  _PurchaseHistoryState createState() => _PurchaseHistoryState();
}

class _PurchaseHistoryState extends State<PurchaseHistory> {
  List<Map<String, dynamic>> _purchases = [
    {
      "name": "fdsafds",
    }
  ];
  
  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.green[100],
      child: Container(
          color: Colors.green[100],
          child: ListView.separated(
            separatorBuilder: (context, index) =>
              SizedBox(height: 2),
            itemCount: 20,
            itemBuilder: (context, index) =>
              PurchaseHistoryBlock(
                "Target",
                "11/07/2019", 
                "http://abullseyeview.s3.amazonaws.com/wp-content/uploads/2014/04/targetlogo-6.jpeg",
                "105.28",
                12
              ),
            ),
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
  
  PurchaseHistoryBlock(this.storeName, this.date, this.imageUrl, this.price, this.items);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 100,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.all(Radius.circular(20))
      ),
      child: Container(
        padding: EdgeInsets.all(15),
        child: Expanded(child: Stack(
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
                    "$items items",
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
}