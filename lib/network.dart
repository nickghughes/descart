List<Map<String, dynamic>> getPurchaseHistory() {
  return [
    {
      "storeName": "Target",
      "purchaseDate": "2/3/2021",
      "imageUrl":
          "http://abullseyeview.s3.amazonaws.com/wp-content/uploads/2014/04/targetlogo-6.jpeg",
      "price": "105.28",
      "items": 12
    },
    {
      "storeName": "Walmart",
      "purchaseDate": "1/07/2021",
      "imageUrl":
          "https://www.largecoupons.com/wp-content/uploads/2020/01/Walmart_Logo_SaveMoney-1.jpg",
      "price": "89.24",
      "items": 7
    },
    {
      "storeName": "Nike",
      "purchaseDate": "11/17/2020",
      "imageUrl":
          "https://www.pittwatergolfcentre.com.au/wp-content/uploads/2014/11/nike-logo-square.png",
      "price": "89.99",
      "items": 1
    },
    {
      "storeName": "Walmart",
      "purchaseDate": "11/10/2020",
      "imageUrl":
          "https://www.largecoupons.com/wp-content/uploads/2020/01/Walmart_Logo_SaveMoney-1.jpg",
      "price": "102.90",
      "items": 8
    },
    {
      "storeName": "Target",
      "purchaseDate": "11/1/2020",
      "imageUrl":
          "http://abullseyeview.s3.amazonaws.com/wp-content/uploads/2014/04/targetlogo-6.jpeg",
      "price": "100.08",
      "items": 10
    },
    {
      "storeName": "Amazon",
      "purchaseDate": "10/17/2020",
      "imageUrl":
          "https://www.netsville.com/wp-content/uploads/2018/11/amazon-logo-square.jpg",
      "price": "198.84",
      "items": 6
    },
    {
      "storeName": "Target",
      "purchaseDate": "10/12/2020",
      "imageUrl":
          "http://abullseyeview.s3.amazonaws.com/wp-content/uploads/2014/04/targetlogo-6.jpeg",
      "price": "78.14",
      "items": 11
    },
    {
      "storeName": "Amazon",
      "purchaseDate": "9/2/2020",
      "imageUrl":
          "https://www.netsville.com/wp-content/uploads/2018/11/amazon-logo-square.jpg",
      "price": "45.12",
      "items": 2
    },
    {
      "storeName": "Target",
      "purchaseDate": "8/19/2020",
      "imageUrl":
          "http://abullseyeview.s3.amazonaws.com/wp-content/uploads/2014/04/targetlogo-6.jpeg",
      "price": "212.94",
      "items": 15
    },
    {
      "storeName": "Amazon",
      "purchaseDate": "7/29/2020",
      "imageUrl":
          "https://www.netsville.com/wp-content/uploads/2018/11/amazon-logo-square.jpg",
      "price": "119.20",
      "items": 4
    },
  ];
}

List<Map<String, dynamic>> getRecommendations() {
  return [
    {
      "productName": "Roomba® i3 (3150)",
      "manufacturerName": "iRobot",
      "imageUrl":
          "https://pisces.bbystatic.com/image2/BestBuy_US/images/products/6422/6422931_rd.jpg;maxHeight=120;maxWidth=120",
      "numberOfStores": 3
    },
    {
      "productName": "Evolution Game Basketball",
      "manufacturerName": "Wilson",
      "imageUrl":
          "https://shop.wilson.com/media/catalog/product/cache/38/image/9df78eab33525d08d6e5fb8d27136e95/c/7/c7dd204a5c8de77cfa036eb232a5e64659c7b2e1_WTB0516_Evolution_v2.jpg",
      "numberOfStores": 1
    },
    {
      "productName": "Super Bowl LV Mini Autograph Football",
      "manufacturerName": "Wilson",
      "imageUrl":
          "https://shop.wilson.com/media/catalog/product/cache/38/image/9df78eab33525d08d6e5fb8d27136e95/a/b/ab0da88ea30ebb878e08ee33aac4f4c6f037e5c2_WTF1691ID55_0_MI_NFL_Super_Bowl_55_Autograph_WH_BU.jpg",
      "numberOfStores": 10
    },
    {
      "productName": "Airpods Pro",
      "manufacturerName": "Apple",
      "imageUrl":
          "https://cdn.shopify.com/s/files/1/0350/2843/4989/products/MWP22_AV2_compact.jpg?v=1596820799",
      "numberOfStores": 2
    },
    {
      "productName": "Gear Active2 Watch",
      "manufacturerName": "Samsung",
      "imageUrl":
          "https://images-na.ssl-images-amazon.com/images/I/51wdZYpKEbL._AC_UL160_SR160,160_.jpg",
      "numberOfStores": 6
    },
    {
      "productName": "Falcon 9 Rocket",
      "manufacturerName": "SpaceX",
      "imageUrl":
          "https://spacecoastdaily.com/wp-content/uploads/2018/01/SpaceX-Falcon-180-5.jpg",
      "numberOfStores": 0
    },
  ];
}

Map<String, dynamic> getPurchasePreview() {
  return {
    "numItems": 6,
    "items": [
      {
        "productName": "Men's Straight Fit Jeans",
        "manufacturerName": "Goodfellow & Co",
        "imageUrl":
            "https://target.scene7.com/is/image/Target/GUEST_49a48060-1ffa-4ba9-8c20-d0446a2577ec?wid=325&hei=325&qlt=80&fmt=webp",
        "quantity": 2,
        "price": "19.99",
      },
      {
        "productName": "Gear Active2 Watch",
        "manufacturerName": "Samsung",
        "imageUrl":
            "https://images-na.ssl-images-amazon.com/images/I/51wdZYpKEbL._AC_UL160_SR160,160_.jpg",
        "quantity": 1,
        "price": "199.99",
      },
      {
        "productName": "ICU Health Non Medical Face Mask 20ct",
        "manufacturerName": "ICU Eyewear",
        "imageUrl":
            "https://target.scene7.com/is/image/Target/GUEST_efdf88d2-daee-42d9-8f18-8977dbc94127?wid=325&hei=325&qlt=80&fmt=webp",
        "quantity": 3,
        "price": "13.49",
      },
    ],
    "storeName": "Target",
    "imageUrl":
        "http://abullseyeview.s3.amazonaws.com/wp-content/uploads/2014/04/targetlogo-6.jpeg",
    "price": "100.08",
    "purchaseDate": "11/1/2020"
  };
}

Map<String, dynamic> getProductPreview() {
  return {
    "productName": "Roomba® i3 (3150)",
    "manufacturerName": "iRobot",
    "imageUrl":
        "https://pisces.bbystatic.com/image2/BestBuy_US/images/products/6422/6422931_rd.jpg;maxHeight=120;maxWidth=120",
    "numberOfStores": 3,
    "stores": [
      {
        "storeName": "Target",
        "imageUrl":
            "http://abullseyeview.s3.amazonaws.com/wp-content/uploads/2014/04/targetlogo-6.jpeg",
        "websiteUrl": "https://www.target.com",
        "price": "222.99",
      },
      {
        "storeName": "Best Buy",
        "imageUrl":
            "https://static-s.aa-cdn.net/img/ios/386960831/0ee8db7cd06c907f1476162860bf2b38",
        "websiteUrl": "https://www.bestbuy.com",
        "price": "99.99",
      },
      {
        "storeName": "Target",
        "imageUrl":
            "http://abullseyeview.s3.amazonaws.com/wp-content/uploads/2014/04/targetlogo-6.jpeg",
        "websiteUrl": "https://www.target.com",
        "price": "222.22",
      },
      {
        "storeName": "Best Buy",
        "imageUrl":
            "https://static-s.aa-cdn.net/img/ios/386960831/0ee8db7cd06c907f1476162860bf2b38",
        "websiteUrl": "https://www.bestbuy.com",
        "price": "199.99",
      },
    ],
  };
}
