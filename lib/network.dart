import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

Future<List<dynamic>> getPurchaseHistory(
    int pageSize, int page, String search, bool favorite, int sortIdx) async {
  String token = await FlutterSecureStorage().read(key: "token");
  List<dynamic> purchases = await http.get(
      "http://descart.grumdog.com/api/descart/purchases?page_size=$pageSize&page=$page&search=$search&favorite=$favorite&sort=$sortIdx",
      headers: {
        "Authorization": "Bearer $token"
      }).then((res) => JsonDecoder().convert(res.body));
  return purchases;
}

Future<List<dynamic>> getRecommendations(int pageSize, int page, String search,
    bool favorite, List<int> categoryIds) async {
  String token = await FlutterSecureStorage().read(key: "token");
  String categoryFilters = categoryIds.map((id) => "&cat_id=$id").join("");
  return await http.get(
      "http://descart.grumdog.com/api/descart/discover?page_size=$pageSize&page=$page&search=$search&favorite=$favorite$categoryFilters",
      headers: {"Authorization": "Bearer $token"}).then((res) {
    return JsonDecoder().convert(res.body);
  });
}

Future<List<dynamic>> getCategories() async {
  String token = await FlutterSecureStorage().read(key: "token");
  return await http.get("http://descart.grumdog.com/api/descart/categories",
      headers: {"Authorization": "Bearer $token"}).then((res) {
    return JsonDecoder().convert(res.body);
  });
}

Future<List<dynamic>> getPurchaseItems(int purchaseId) async {
  List<dynamic> items = await query("purchasepreview/$purchaseId");
  return items;
}

Future<List<dynamic>> getProductStores(int productId) async {
  return query("productpreview/$productId").then((stores) {
    return stores;
  });
}

Future<List<dynamic>> getProductSuggestions(String q) async {
  dynamic res = await http.get(Uri.http(
      'descart.grumdog.com', 'api/descart/autocomplete/product', {"query": q}));
  dynamic result = JsonDecoder().convert(res.body);
  if (q.length > 0) result.add({"name": q});
  return result;
}

Future<List<dynamic>> getStoreSuggestions(String q) async {
  dynamic res = await http.get(Uri.http(
      'descart.grumdog.com', 'api/descart/autocomplete/store', {"query": q}));
  return JsonDecoder().convert(res.body);
}

Future<dynamic> postPurchase(Map<String, dynamic> purchase) async {
  String token = await FlutterSecureStorage().read(key: "token");
  String body = json.encode(purchase);
  dynamic p =
      await http.post(Uri.http('descart.grumdog.com', 'api/descart/purchase'),
          headers: <String, String>{
            'Content-Type': 'application/json; charset=UTF-8',
            "Authorization": "Bearer $token"
          },
          body: body);
  return p.body;
}

Future<void> favoriteProduct(int productId, bool favorite) async {
  String token = await FlutterSecureStorage().read(key: "token");
  String body =
      json.encode({"product_id": productId, "favorite": favorite.toString()});
  await http.post(
      Uri.http('descart.grumdog.com', 'api/descart/favoriteproduct'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        "Authorization": "Bearer $token"
      },
      body: body);
}

Future<void> favoritePurchase(int purchaseId, bool favorite) async {
  String token = await FlutterSecureStorage().read(key: "token");
  String body =
      json.encode({"purchase_id": purchaseId, "favorite": favorite.toString()});
  await http.post(
      Uri.http('descart.grumdog.com', 'api/descart/favoritepurchase'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        "Authorization": "Bearer $token"
      },
      body: body);
}

Future<void> addRemoveShoppingCart(int spId, bool added) async {
  String token = await FlutterSecureStorage().read(key: "token");
  String body =
      json.encode({"storeproduct_id": spId, "add_item": added.toString()});
  await http.post(Uri.http('descart.grumdog.com', 'api/descart/shoppingcart'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        "Authorization": "Bearer $token"
      },
      body: body);
}

Future<List<dynamic>> getShoppingList() async {
  String token = await FlutterSecureStorage().read(key: "token");
  List<dynamic> stores = await http
      .get("http://descart.grumdog.com/api/descart/shoppingcart", headers: {
    "Authorization": "Bearer $token"
  }).then((res) => JsonDecoder().convert(res.body));
  return stores;
}

Future<void> deletePurchase(int purchaseId) async {
  String token = await FlutterSecureStorage().read(key: "token");
  await http.delete(
    'http://descart.grumdog.com/api/descart/purchase/$purchaseId',
    headers: {"Authorization": "Bearer $token"},
  );
}

Future<dynamic> query(String path, [Map<String, dynamic> params]) async {
  String token = await FlutterSecureStorage().read(key: "token");
  Uri uri = Uri.http('descart.grumdog.com', 'api/descart/$path', params);
  return http.get(uri, headers: {"Authorization": "Bearer $token"}).then((res) {
    return JsonDecoder().convert(res.body);
  });
}
