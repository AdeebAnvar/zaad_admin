import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:zaad_admin/constatnts/colors.dart';
import 'package:zaad_admin/services.dart';

class ProductsScreen extends StatefulWidget {
  const ProductsScreen({super.key});

  @override
  State<ProductsScreen> createState() => _ProductsScreenState();
}

class _ProductsScreenState extends State<ProductsScreen> {
  List productsList = [];
  List categoriesList = [];

  Future<void> fetchCategories() async {
    try {
      Response response = await Services().getAllCategories();
      var result = jsonDecode(response.body);
      if (result['status']) {
        setState(() {
          categoriesList = result['data'];
        });
      }
    } catch (e) {
      print("Error fetching categories: $e");
    }
  }

  Future<void> fetchProducts() async {
    try {
      Response response = await Services().getAllProducts();
      var result = jsonDecode(response.body);
      if (result['status']) {
        setState(() {
          productsList = result['data'];
        });
      }
    } catch (e) {
      print("Error fetching products: $e");
    }
  }

  @override
  void initState() {
    super.initState();
    fetchProducts();
    fetchCategories();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: LayoutBuilder(
        builder: (context, constraints) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  ElevatedButton.icon(
                    onPressed: _showAddEditProductDialog,
                    icon: Icon(Icons.add),
                    label: Text('Add product'),
                  ),
                ],
              ),
              SizedBox(height: 16),
              Expanded(
                child: productsList.isEmpty
                    ? Center(child: CircularProgressIndicator.adaptive())
                    : constraints.maxWidth < 600
                        ? _buildProductListView()
                        : _buildProductDataTable(),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildProductListView() {
    return ListView.builder(
      itemCount: productsList.length,
      itemBuilder: (context, index) {
        return Card(
          margin: EdgeInsets.symmetric(vertical: 8),
          child: ListTile(
            title: Text(productsList[index]['name'] ?? 'N/A'),
            subtitle: Text('${productsList[index]['category_name_eng'] ?? 'N/A'}'),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: Icon(Icons.edit, color: AppColors.stextColor),
                  onPressed: () => _showAddEditProductDialog(index: index),
                ),
                IconButton(
                  icon: Icon(Icons.delete, color: Colors.red),
                  onPressed: () => _confirmDeleteProduct(index),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildProductDataTable() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
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
            color: MaterialStateProperty.all(index.isOdd ? Colors.grey.shade200 : Colors.white),
            cells: [
              DataCell(Text('${index + 1}')),
              DataCell(Text(productsList[index]['name'] ?? 'N/A')),
              DataCell(Text(productsList[index]['category_name_eng'] ?? 'N/A')),
              DataCell(Text(productsList[index]['category_name_arabic'] ?? 'N/A')),
              DataCell(Text(productsList[index]['unit_price'].toString() ?? 'N/A')),
              DataCell(Text(productsList[index]['discount_price'].toString() ?? 'N/A')),
              DataCell(Row(
                children: [
                  IconButton(
                    icon: Icon(Icons.edit, color: AppColors.stextColor),
                    onPressed: () => _showAddEditProductDialog(index: index),
                  ),
                  IconButton(
                    icon: Icon(Icons.delete, color: Colors.red),
                    onPressed: () => _confirmDeleteProduct(index),
                  ),
                ],
              )),
            ],
          ),
        ),
      ),
    );
  }

  void _confirmDeleteProduct(int index) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Confirm Delete'),
          content: Text('Are you sure you want to delete ${productsList[index]['name']}?'),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: Text('Cancel')),
            TextButton(
              onPressed: () async {
                Navigator.pop(context);
                try {
                  await Services().deleteProduct(productsList[index]['id'].toString());
                  setState(() {
                    productsList.removeAt(index);
                  });
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Product deleted successfully')));
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to delete Product: $e')));
                }
              },
              child: Text('Delete', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }

  void _showAddEditProductDialog({int? index}) {
    final nameController = TextEditingController();
    final unitPriceController = TextEditingController();
    final discPriceController = TextEditingController();
    int? catId;

    if (index != null) {
      final product = productsList[index];
      nameController.text = product['name'] ?? '';
      unitPriceController.text = product['unit_price']?.toString() ?? '';
      discPriceController.text = product['discount_price']?.toString() ?? '';
      catId = product['category_id'];
    }

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(index == null ? 'Add Product' : 'Edit Product'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(controller: nameController, decoration: InputDecoration(labelText: 'Product Name')),
                SizedBox(height: 16),
                DropdownButtonFormField<int>(
                  value: catId,
                  decoration: InputDecoration(labelText: 'Category'),
                  items: categoriesList.map((category) {
                    return DropdownMenuItem<int>(
                      value: category['id'],
                      child: Text(category['category_name_eng'] ?? ''),
                    );
                  }).toList(),
                  onChanged: (value) => catId = value,
                ),
                SizedBox(height: 16),
                TextField(controller: unitPriceController, decoration: InputDecoration(labelText: 'Unit Price'), keyboardType: TextInputType.number),
                SizedBox(height: 16),
                TextField(controller: discPriceController, decoration: InputDecoration(labelText: 'Discount Price'), keyboardType: TextInputType.number),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: Text('Cancel')),
            ElevatedButton(onPressed: () {}, child: Text(index == null ? 'Add' : 'Update')),
          ],
        );
      },
    );
  }
}
