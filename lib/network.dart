import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

Future<List<dynamic>> getPurchaseHistory(int userId) async {
  List<dynamic> purchases = await query("purchases/$userId");
  debugPrint(purchases.toString());
  return purchases;
}

Future<List<dynamic>> getRecommendations(int userId) {
  return query("discover/$userId").then((items) {
    debugPrint(items.toString());
    return items;
  });
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
  return http
      .get(Uri.http('localhost:3333', 'api/descart/$path', params))
      .then((res) {
    return JsonDecoder().convert(res.body);
  });
}
