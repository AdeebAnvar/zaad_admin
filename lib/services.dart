import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class Services {
  final String baseUrl = "http://localhost:20399/";
  // final String baseUrl = "https://zaad-pos-backend.onrender.com/";

  // URLs
  String get loginUrl => "${baseUrl}user/login";
  String get addUserUrl => "${baseUrl}user/add_user";
  String get getAllUsersUrl => "${baseUrl}user/get_all_users";
  String get addCategoryUrl => "${baseUrl}product/add_category";
  String get getAllCategoriesUrl => "${baseUrl}product/get_all_categories";
  String get deleteCategoryUrl => "${baseUrl}product/delete_category";
  String get saveProductUrl => "${baseUrl}product/save_product";
  String get deleteProductUrl => "${baseUrl}product/delete_product";
  String get getAllProductsUrl => "${baseUrl}product/get_all_products";
  String get getProductDetailUrl => "${baseUrl}product/get_product_detail";

  // Functions

  Future<http.Response> login(String username, String password) async {
    final response = await http.post(
      Uri.parse(loginUrl),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"username": username, "password": password}),
    );
    print("");
    return response;
  }

  Future<http.Response> addUser(Map<String, dynamic> userData) async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    String? token = pref.getString('token');

    final response = await http.post(
      Uri.parse(addUserUrl),
      headers: {
        "Authorization": "Bearer $token",
        "Content-Type": "application/json",
      },
      body: jsonEncode(userData),
    );
    return response;
  }

  Future<http.Response> getAllUsers() async {
    try {
      SharedPreferences pref = await SharedPreferences.getInstance();
      String? token = pref.getString('token');

      if (token == null || token.isEmpty) {
        throw Exception("Token is missing or empty.");
      }

      final response = await http.get(
        Uri.parse(getAllUsersUrl),
        headers: {
          "Authorization": "Bearer $token",
          "Content-Type": "application/json",
        },
      );

      if (response.statusCode == 200) {
        return response;
      } else {
        throw Exception("Failed to fetch users. Status code: ${response.statusCode}");
      }
    } catch (e) {
      print("Error in getAllUsers: $e");
      rethrow;
    }
  }

  // Future<http.Response> getllCustomers() async {
  //   try {
  //     SharedPreferences pref = await SharedPreferences.getInstance();
  //     String? token = pref.getString('token');

  //     if (token == null || token.isEmpty) {
  //       throw Exception("Token is missing or empty.");
  //     }

  //     final response = await http.get(
  //       Uri.parse(getAllUsersUrl),
  //       headers: {
  //         "Authorization": "Bearer $token",
  //         "Content-Type": "application/json",
  //       },
  //     );

  //     if (response.statusCode == 200) {
  //       return response;
  //     } else {
  //       throw Exception("Failed to fetch users. Status code: ${response.statusCode}");
  //     }
  //   } catch (e) {
  //     print("Error in getAllUsers: $e");
  //     rethrow;
  //   }
  // }

  Future<http.Response> addCategory(Map<String, dynamic> categoryData) async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    String? token = pref.getString('token');

    final response = await http.post(
      Uri.parse(addCategoryUrl),
      headers: {
        "Authorization": "Bearer $token",
        "Content-Type": "application/json",
      },
      body: jsonEncode(categoryData),
    );
    print(categoryData);
    return response;
  }

  Future<http.Response> getAllCategories() async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    String? token = pref.getString('token');

    final response = await http.get(
      Uri.parse(getAllCategoriesUrl),
      headers: {
        "Authorization": "Bearer $token",
        "Content-Type": "application/json",
      },
    );
    return response;
  }

  Future<http.Response> deleteCategory(String categoryId) async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    String? token = pref.getString('token');

    final response = await http.delete(
      Uri.parse("$deleteCategoryUrl/$categoryId"),
      headers: {
        "Authorization": "Bearer $token",
        "Content-Type": "application/json",
      },
    );
    return response;
  }

  // Future<http.Response> deleteUser(String categoryId) async {
  //   SharedPreferences pref = await SharedPreferences.getInstance();
  //   String? token = pref.getString('token');
  //   final response = await http.delete(
  //     Uri.parse("$deleteuser/$categoryId"),
  //     headers: {
  //       "Authorization": "Bearer $token",
  //       "Content-Type": "application/json",
  //     },
  //   );
  //   return response;
  // }

  Future<http.Response> saveProduct(Map<String, dynamic> productData) async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    String? token = pref.getString('token');
    print(productData);
    final response = await http.post(
      Uri.parse(saveProductUrl),
      headers: {
        "Authorization": "Bearer $token",
        "Content-Type": "application/json",
      },
      body: jsonEncode(productData),
    );
    return response;
  }

  Future<http.Response> deleteProduct(String productId) async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    String? token = pref.getString('token');

    final response = await http.delete(
      Uri.parse("$deleteProductUrl/$productId"),
      headers: {
        "Authorization": "Bearer $token",
        "Content-Type": "application/json",
      },
    );
    return response;
  }

  Future<http.Response> getAllProducts() async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    String? token = pref.getString('token');
    final response = await http.get(
      Uri.parse(getAllProductsUrl),
      headers: {
        "Authorization": "Bearer $token",
        "Content-Type": "application/json",
      },
    );
    return response;
  }

  Future<http.Response> getProductDetail(String productId) async {
    final response = await http.get(Uri.parse("$getProductDetailUrl/$productId"));
    return response;
  }
}
