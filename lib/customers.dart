import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:zaad_admin/constatnts/colors.dart';
import 'package:zaad_admin/services.dart';

class CustomersScreen extends StatefulWidget {
  const CustomersScreen({super.key});

  @override
  State<CustomersScreen> createState() => _CustomersScreenState();
}

class _CustomersScreenState extends State<CustomersScreen> {
  List customerList = [];

  Future<void> fetchCustomers() async {
    try {
      Response response = await Services().getAllCustomers();
      var result = jsonDecode(response.body);
      if (result['status']) {
        setState(() {
          customerList = result['data'];
        });
      } else {
        throw Exception('Failed to fetch customers.');
      }
    } catch (e) {
      print("Error fetching customers: $e");
    }
  }

  @override
  void initState() {
    super.initState();
    fetchCustomers();
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
                    onPressed: _showAddEditStaffDialog,
                    icon: Icon(Icons.add),
                    label: Text('Add Customer'),
                  ),
                ],
              ),
              SizedBox(height: 16),
              Expanded(
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: SingleChildScrollView(
                    child: DataTable(
                      columnSpacing: 20,
                      columns: const [
                        DataColumn(label: Text('SL No.')),
                        DataColumn(label: Text('Name')),
                        DataColumn(label: Text('Phone')),
                        DataColumn(label: Text('Email')),
                        DataColumn(label: Text('Gender')),
                        DataColumn(label: Text('Address')),
                        DataColumn(label: Text('Actions')),
                      ],
                      rows: List.generate(
                        customerList.length,
                        (index) => DataRow(
                          color: WidgetStatePropertyAll(index.isOdd ? Colors.grey.shade200 : Colors.white),
                          cells: [
                            DataCell(Text('${index + 1}')),
                            DataCell(Text(customerList[index]['name'] ?? 'N/A')),
                            DataCell(Text(customerList[index]['phone'] ?? 'N/A')),
                            DataCell(Text(customerList[index]['email'] ?? 'N/A')),
                            DataCell(Text(customerList[index]['gender'] ?? 'N/A')),
                            DataCell(Text(customerList[index]['address'] ?? 'N/A')),
                            DataCell(Row(
                              children: [
                                IconButton(
                                  icon: Icon(Icons.edit, color: AppColors.stextColor),
                                  onPressed: () => _showAddEditStaffDialog(index: index),
                                ),
                              ],
                            )),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  void _showAddEditStaffDialog({int? index}) {
    final nameController = TextEditingController();
    final phoneController = TextEditingController();
    final emailController = TextEditingController();
    final addressController = TextEditingController();
    String? gender;
    bool isSubmitting = false;
    int? id;

    if (index != null) {
      id = customerList[index]['id'];
      nameController.text = customerList[index]['name'] ?? '';
      phoneController.text = customerList[index]['phone'] ?? '';
      emailController.text = customerList[index]['email'] ?? '';
      gender = customerList[index]['gender'];
      addressController.text = customerList[index]['address'] ?? '';
    }

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text(index == null ? 'Add Customer' : 'Edit Customer'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(controller: nameController, decoration: InputDecoration(labelText: 'Customer Name')),
                    SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      value: gender,
                      decoration: InputDecoration(labelText: 'Gender', border: OutlineInputBorder()),
                      items: ['Male', 'Female'].map((String value) => DropdownMenuItem<String>(value: value, child: Text(value))).toList(),
                      onChanged: (value) => setState(() => gender = value),
                    ),
                    SizedBox(height: 16),
                    TextField(controller: phoneController, decoration: InputDecoration(labelText: 'Phone Number'), keyboardType: TextInputType.phone),
                    SizedBox(height: 16),
                    TextField(controller: emailController, decoration: InputDecoration(labelText: 'Email'), keyboardType: TextInputType.emailAddress),
                    SizedBox(height: 16),
                    TextField(controller: addressController, decoration: InputDecoration(labelText: 'Address')),
                  ],
                ),
              ),
              actions: [
                TextButton(onPressed: () => Navigator.pop(context), child: Text('Cancel')),
                ElevatedButton(
                  onPressed: isSubmitting
                      ? null
                      : () async {
                          if ([nameController.text, phoneController.text, emailController.text, gender, addressController.text].contains(null) ||
                              [nameController.text, phoneController.text, emailController.text, addressController.text].contains('')) {
                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Please fill all required fields')));
                            return;
                          }
                          setState(() => isSubmitting = true);
                          try {
                            await Services().saveCustomer({
                              "id": id,
                              "name": nameController.text,
                              "phone": phoneController.text,
                              "email": emailController.text,
                              "gender": gender,
                              "address": addressController.text,
                              "isEdit": index != null
                            });
                            fetchCustomers();
                            Navigator.pop(context);
                          } catch (e) {
                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to save customer: $e')));
                          } finally {
                            setState(() => isSubmitting = false);
                          }
                        },
                  child: isSubmitting ? CircularProgressIndicator.adaptive() : Text(index == null ? 'Add Customer' : 'Update Customer'),
                ),
              ],
            );
          },
        );
      },
    );
  }
}
