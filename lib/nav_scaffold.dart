import 'package:descart/discover.dart';
import 'package:descart/history.dart';
import 'package:descart/purchase_form.dart';
import 'package:flutter/material.dart';
import 'package:descart/sign_in.dart';
import 'package:descart/login_page.dart';
import 'package:descart/shopping_list.dart';

class NavScaffold extends StatefulWidget {
  @override
  _NavScaffoldState createState() => _NavScaffoldState();
}

class _NavScaffoldState extends State<NavScaffold> {
  PageController _pageController;
  int _page = 0;

  final pages = ["Discover", "Shopping List", "Purchases"];

  void _createPurchase() {
    showDialog(
        context: context,
        builder: (context) {
          return PurchaseStoreForm((_) => setState(() {}));
        });
  }

  void _navigationTapped(int page) {
    _pageController.animateToPage(
      page,
      duration: Duration(milliseconds: 200),
      curve: Curves.ease,
    );
  }

  void _onPageChanged(int page) {
    setState(() {
      _page = page;
    });
  }

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    super.dispose();
    _pageController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: new Container(),
        title: Text(pages[_page]),
        actions: [
          Container(
            child: InkWell(
              child: Column(
                children: [
                  Icon(Icons.exit_to_app),
                  Text(
                    "Sign Out",
                    style: TextStyle(
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
              onTap: () {
                signOutGoogle();
                Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(builder: (context) {
                  return LoginPage();
                }), ModalRoute.withName('/'));
              },
            ),
            padding: EdgeInsets.fromLTRB(0, 10, 10, 0),
          )
        ],
      ),
      body: PageView(
        children: [
          Discover(),
          ShoppingList(),
          PurchaseHistory(),
        ],
        controller: _pageController,
        onPageChanged: _onPageChanged,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _createPurchase,
        tooltip: 'New Purchase',
        child: Icon(Icons.add_shopping_cart),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.public),
            label: 'Discover',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.shopping_bag_outlined),
            label: 'Shopping List',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.shopping_cart),
            label: 'Purchases',
          ),
        ],
        onTap: _navigationTapped,
        currentIndex: _page,
        backgroundColor: Theme.of(context).primaryColor,
        fixedColor: Colors.white,
      ),
    );
  }
}
