import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

Future<List<dynamic>> getPurchaseHistory(
    int userId, String search, bool favorite) async {
  List<dynamic> purchases = await http
      .get(
          "http://localhost:3333/api/descart/purchases/$userId?search=$search&favorite=$favorite")
      .then((res) => JsonDecoder().convert(res.body));
  debugPrint(purchases.toString());
  return purchases;
}

Future<List<dynamic>> getRecommendations(
    int userId, String search, bool favorite) async {
  return await http
      .get(
          "http://localhost:3333/api/descart/discover/$userId?search=$search&favorite=$favorite")
      .then((res) => JsonDecoder().convert(res.body));
}

Future<List<dynamic>> getPurchaseItems(int purchaseId) async {
  List<dynamic> items = await query("purchasepreview/$purchaseId");
  debugPrint(items.toString());
  return items;
}

Future<List<dynamic>> getProductStores(int productId) {
  return query("productpreview/$productId").then((stores) {
    debugPrint(stores.toString());
    return stores;
  });
}

Future<List<dynamic>> getProductSuggestions(String q) async {
  dynamic res = await http.get(Uri.http(
      'localhost:3333', 'api/descart/autocomplete/product', {"query": q}));
  dynamic result = JsonDecoder().convert(res.body);
  if (q.length > 0) result.add({"name": q});
  return result;
}

Future<List<dynamic>> getStoreSuggestions(String q) async {
  dynamic res = await http.get(Uri.http(
      'localhost:3333', 'api/descart/autocomplete/store', {"query": q}));
  return JsonDecoder().convert(res.body);
}

Future<void> postPurchase(Map<String, dynamic> purchase) async {
  debugPrint(purchase.toString());
  String body = json.encode(purchase);
  dynamic res =
      await http.post(Uri.http('localhost:3333', 'api/descart/purchase'),
          headers: <String, String>{
            'Content-Type': 'application/json; charset=UTF-8',
          },
          body: body);
  debugPrint(res.toString());
}

Future<dynamic> query(String path, [Map<String, dynamic> params]) {
  Uri uri = Uri.http('localhost:3333', 'api/descart/$path', params);
  return http.get(uri).then((res) {
    return JsonDecoder().convert(res.body);
  }).catchError((err) => {debugPrint(err)});
}
