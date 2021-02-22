import 'package:descart/discover.dart';
import 'package:descart/history.dart';
import 'package:descart/settings.dart';
import 'package:flutter/material.dart';

class NavScaffold extends StatefulWidget {
  @override
  _NavScaffoldState createState() => _NavScaffoldState();
}

class _NavScaffoldState extends State<NavScaffold> {
  PageController _pageController;
  int _page = 0;

  void _createPurchase() {
    debugPrint("creating a purchase");
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
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
      // appBar: AppBar(
      //   // Here we take the value from the MyHomePage object that was created by
      //   // the App.build method, and use it to set our appbar title.
      //   title: Text(widget.title),
      // ),
      body: PageView(
        children: [
          Discover(),
          PurchaseHistory(),
          Settings(),
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
            icon: Icon(Icons.shopping_cart),
            label: 'Purchases',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'Settings',
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
