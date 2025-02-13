import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:zaad_admin/constatnts/colors.dart';
import 'package:zaad_admin/services.dart';

class ItemsScreen extends StatefulWidget {
  const ItemsScreen({super.key});

  @override
  State<ItemsScreen> createState() => _ItemsScreenState();
}

class _ItemsScreenState extends State<ItemsScreen> {
  List productsList = [];
  List categoriesList = [];

  Future<void> fetchCategories() async {
    try {
      Response response = await Services().getAllCategories();
      var result = jsonDecode(response.body);
      print(result);
      if (result['status']) {
        categoriesList = result['data'];
      } else {
        throw Exception('Failed to fetch categories.');
      }
    } catch (e) {
      print("Error fetching categories: $e");
      throw Exception('An error occurred while fetching categories.');
    }
  }

  Future<void> fetchProducts() async {
    try {
      Response response = await Services().getAllProducts();
      var result = jsonDecode(response.body);
      print(result);
      if (result['status']) {
        productsList = result['data'];
      } else {
        throw Exception('Failed to fetch products.');
      }
    } catch (e) {
      print("Error fetching products: $e");
      throw Exception('An error occurred while fetching products.');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: FutureBuilder(
        future: fetchProducts().then((v) {
          fetchCategories();
        }),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator.adaptive());
          } else if (snapshot.hasError) {
            return Center(child: Text('Failed to load products: ${snapshot.error}'));
          } else {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    ElevatedButton.icon(
                      onPressed: _showAddEditStaffDialog,
                      icon: Icon(Icons.add),
                      label: Text('Add product'),
                    ),
                  ],
                ),
                SizedBox(height: 16),
                Expanded(
                  child: SingleChildScrollView(
                    child: DataTable(
                      columnSpacing: 20,
                      columns: const [
                        DataColumn(label: Text('SL No.')),
                        DataColumn(label: Text('Name')),
                        DataColumn(label: Text('Category (ENG)')),
                        DataColumn(label: Text('Category (Arabic)')),
                        DataColumn(label: Text('Unit price')),
                        DataColumn(label: Text('Discount price')),
                        DataColumn(label: Text('Actions')),
                      ],
                      rows: List.generate(
                        productsList.length,
                        (index) => DataRow(
                          color: WidgetStatePropertyAll(index.floor().isOdd ? Colors.grey.shade200 : Colors.white),
                          cells: [
                            DataCell(Text('${index + 1}')),
                            DataCell(Text(productsList[index]['name'] ?? 'N/A')),
                            DataCell(Text(productsList[index]['category_name_eng'] ?? 'N/A')),
                            DataCell(Text(productsList[index]['category_name_arabic'] ?? 'N/A')),
                            DataCell(Text(productsList[index]['unit_price'] ?? 'N/A')),
                            DataCell(Text(productsList[index]['discount_price'] ?? 'N/A')),
                            DataCell(Row(
                              children: [
                                IconButton(
                                  icon: Icon(Icons.edit, color: AppColors.stextColor),
                                  onPressed: () => _showAddEditStaffDialog(index: index),
                                ),
                                IconButton(
                                  icon: Icon(Icons.delete, color: Colors.red),
                                  onPressed: () => _confirmDeleteStaff(index),
                                ),
                              ],
                            )),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            );
          }
        },
      ),
    );
  }

  void _confirmDeleteStaff(int index) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Confirm Delete'),
          content: Text('Are you sure you want to delete ${productsList[index]['name']}?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                Navigator.pop(context);
                try {
                  await Services().deleteProduct(productsList[index]['id'].toString());
                  setState(() {
                    productsList.removeAt(index);
                  });
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    content: Text('Product deleted successfully'),
                  ));
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    content: Text('Failed to delete Product: $e'),
                  ));
                }
              },
              child: Text('Delete', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }

  void _showAddEditStaffDialog({int? index}) {
    final nameController = TextEditingController();
    final cateNameEngController = TextEditingController();
    final catNameArController = TextEditingController();
    final unitPriceController = TextEditingController();
    final discPriceController = TextEditingController();
    bool isSubmitting = false;
    int? id;
    int? catId;

    if (index != null) {
      id = productsList[index]['id'];
      catId = productsList[index]['category_id'];
      nameController.text = productsList[index]['name'] ?? '';
      cateNameEngController.text = productsList[index]['category_name_eng'] ?? '';
      catNameArController.text = productsList[index]['category_name_arabic'] ?? '';
      unitPriceController.text = productsList[index]['unit_price'] ?? '';
      discPriceController.text = productsList[index]['discount_price'] ?? '';
    }

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, s) {
            return AlertDialog(
              title: Text(index == null ? 'Add Product' : 'Edit Product'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: nameController,
                      decoration: InputDecoration(labelText: 'Product Name'),
                    ),
                    SizedBox(height: 16),
                    DropdownButtonFormField<int>(
                      value: catId,
                      decoration: InputDecoration(
                        labelText: 'Category',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      items: categoriesList.map((category) {
                        return DropdownMenuItem<int>(
                          onTap: () {
                            catNameArController.text = category['category_name_arabic'];
                            cateNameEngController.text = category['category_name_eng'];
                          },
                          value: category['id'],
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                category['category_name_eng'] ?? '',
                                style: TextStyle(fontSize: 16),
                              ),
                              Text(
                                category['category_name_arabic'] ?? '',
                                style: TextStyle(fontSize: 16),
                                textDirection: TextDirection.rtl,
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                      onChanged: (value) {
                        s(() => catId = value);
                      },
                    ),
                    SizedBox(height: 16),
                    TextField(
                      controller: unitPriceController,
                      decoration: InputDecoration(labelText: 'Unit Price'),
                      keyboardType: TextInputType.number,
                    ),
                    SizedBox(height: 16),
                    TextField(
                      controller: discPriceController,
                      decoration: InputDecoration(labelText: 'Discount Price'),
                      keyboardType: TextInputType.number,
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: isSubmitting
                      ? null
                      : () async {
                          if (nameController.text.isEmpty || unitPriceController.text.isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Please fill all required fields')),
                            );
                            return;
                          }

                          s(() => isSubmitting = true);
                          try {
                            if (index == null) {
                              // Add new product
                              await Services().saveProduct({
                                "product_name": nameController.text,
                                "product_category_id": catId,
                                "product_category_name_eng": cateNameEngController.text,
                                "product_category_name_arabic": catNameArController.text,
                                "unit_price": unitPriceController.text,
                                "discount_price": discPriceController.text,
                              });
                            } else {
                              // Update existing product
                              await Services().saveProduct({
                                "product_id": id,
                                "product_name": nameController.text,
                                "product_category_id": catId,
                                "product_category_name_eng": cateNameEngController.text,
                                "product_category_name_arabic": catNameArController.text,
                                "unit_price": unitPriceController.text,
                                "discount_price": discPriceController.text,
                              });
                            }
                            fetchProducts();
                            setState(() {});

                            Navigator.pop(context);
                          } catch (e) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Failed to save product: $e')),
                            );
                          } finally {
                            s(() => isSubmitting = false);
                          }
                        },
                  child: isSubmitting ? CircularProgressIndicator.adaptive() : Text(index == null ? 'Add Product' : 'Update Product'),
                ),
              ],
            );
          },
        );
      },
    );
  }
}
