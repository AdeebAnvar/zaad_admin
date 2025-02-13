import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:zaad_admin/constatnts/colors.dart';
import 'package:zaad_admin/services.dart';

class CategoryScreen extends StatefulWidget {
  const CategoryScreen({super.key});

  @override
  State<CategoryScreen> createState() => _CategoryScreenState();
}

class _CategoryScreenState extends State<CategoryScreen> {
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

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: FutureBuilder(
        future: fetchCategories(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator.adaptive());
          } else if (snapshot.hasError) {
            return Center(child: Text('Failed to load categories: ${snapshot.error}'));
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
                      label: Text('Add category'),
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
                        DataColumn(label: Text('Category (ENG)')),
                        DataColumn(label: Text('Category (Arabic)')),
                        DataColumn(label: Text('Actions')),
                      ],
                      rows: List.generate(
                        categoriesList.length,
                        (index) => DataRow(
                          color: WidgetStatePropertyAll(index.floor().isOdd ? Colors.grey.shade200 : Colors.white),
                          cells: [
                            DataCell(Text('${index + 1}')),
                            DataCell(Text(categoriesList[index]['category_name_eng'] ?? 'N/A')),
                            DataCell(Text(categoriesList[index]['category_name_arabic'] ?? 'N/A')),
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
          content: Text('Are you sure you want to delete ${categoriesList[index]['name']}?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                Navigator.pop(context);
                try {
                  await Services().deleteCategory(categoriesList[index]['id'].toString());
                  setState(() {
                    categoriesList.removeAt(index);
                  });
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    content: Text('Category deleted successfully'),
                  ));
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    content: Text('Failed to delete Category: $e'),
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
    final passwordController = TextEditingController();
    bool isSubmitting = false;
    int? id;
    if (index != null) {
      id = categoriesList[index]['id'];
      nameController.text = categoriesList[index]['category_name_eng'] ?? '';
      passwordController.text = categoriesList[index]['category_name_arabic'] ?? '';
    }

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, s) {
            return AlertDialog(
              title: Text(index == null ? 'Add Staff' : 'Edit Staff'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: nameController,
                      decoration: InputDecoration(labelText: 'Category (ENG)'),
                    ),
                    SizedBox(height: 16),
                    TextField(
                      controller: passwordController,
                      decoration: InputDecoration(labelText: 'Category (Arabic)'),
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
                          if (nameController.text.isEmpty || passwordController.text.isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Please fill all fields')),
                            );
                            return;
                          }

                          s(() => isSubmitting = true);
                          try {
                            if (index == null) {
                              // Add new user
                              await Services().addCategory({
                                "category_name_eng": nameController.text,
                                "category_name_arabic": passwordController.text,
                              });
                            } else {
                              // Update existing user
                              await Services().addCategory({
                                'id': categoriesList[index]['id'],
                                "category_name_eng": nameController.text,
                                "category_name_arabic": passwordController.text,
                              });
                            }
                            fetchCategories();
                            setState(() {});
                            Navigator.pop(context);
                          } catch (e) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Failed to save category: $e')),
                            );
                          } finally {
                            s(() => isSubmitting = false);
                          }
                        },
                  child: isSubmitting ? CircularProgressIndicator() : Text(index == null ? 'Add category' : 'Update category'),
                ),
              ],
            );
          },
        );
      },
    );
  }
}
