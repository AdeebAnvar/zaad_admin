import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:zaad_admin/constatnts/colors.dart';
import 'package:zaad_admin/services.dart';

class UsersScreen extends StatefulWidget {
  @override
  _UsersScreenState createState() => _UsersScreenState();
}

class _UsersScreenState extends State<UsersScreen> {
  List staffList = [];

  Future<void> fetchStaff() async {
    try {
      Response response = await Services().getAllUsers();
      var result = jsonDecode(response.body);
      print(result);
      if (result['status']) {
        staffList = result['data'];
      } else {
        throw Exception('Failed to fetch users.');
      }
    } catch (e) {
      print("Error fetching customers: $e");
      throw Exception('An error occurred while fetching users.');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: FutureBuilder(
        future: fetchStaff(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator.adaptive());
          } else if (snapshot.hasError) {
            return Center(child: Text('Failed to load users: ${snapshot.error}'));
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
                      label: Text('Add Staff'),
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
                        DataColumn(label: Text('Password')),
                        DataColumn(label: Text('Actions')),
                      ],
                      rows: List.generate(
                        staffList.length,
                        (index) => DataRow(
                          color: WidgetStatePropertyAll(index.floor().isOdd ? Colors.grey.shade200 : Colors.white),
                          cells: [
                            DataCell(Text('${index + 1}')),
                            DataCell(Text(staffList[index]['name'] ?? 'N/A')),
                            DataCell(Text(staffList[index]['password'] ?? 'N/A')),
                            DataCell(Row(
                              children: [
                                IconButton(
                                  icon: Icon(Icons.edit, color: AppColors.stextColor),
                                  onPressed: () => _showAddEditStaffDialog(index: index),
                                ),
                                // IconButton(
                                //   icon: Icon(Icons.delete, color: Colors.red),
                                //   onPressed: () => _confirmDeleteStaff(index),
                                // ),
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

  void _viewStaffDetails(int index) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Staff Details'),
          content: Text('Name: ${staffList[index]['name']}\nPassword: ${staffList[index]['password']}'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Close'),
            ),
          ],
        );
      },
    );
  }

  void _confirmDeleteStaff(int index) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Confirm Delete'),
          content: Text('Are you sure you want to delete ${staffList[index]['name']}?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                Navigator.pop(context);
                try {
                  // await Services().deleteUser(staffList[index]['id']);
                  // setState(() {
                  //   staffList.removeAt(index);
                  // });
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    content: Text('Staff deleted successfully'),
                  ));
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    content: Text('Failed to delete staff: $e'),
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
      id = staffList[index]['id'];
      nameController.text = staffList[index]['name'] ?? '';
      passwordController.text = staffList[index]['password'] ?? '';
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
                      decoration: InputDecoration(labelText: 'Name'),
                    ),
                    SizedBox(height: 16),
                    TextField(
                      controller: passwordController,
                      decoration: InputDecoration(labelText: 'Password'),
                      obscureText: true,
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
                              await Services().addUser({
                                "username": nameController.text,
                                "password": passwordController.text,
                              });
                            } else {
                              // Update existing user
                              await Services().addUser({
                                'id': staffList[index]['id'],
                                "username": nameController.text,
                                "password": passwordController.text,
                              });
                            }
                            fetchStaff();
                            setState(() {});
                            Navigator.pop(context);
                          } catch (e) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Failed to save staff: $e')),
                            );
                          } finally {
                            s(() => isSubmitting = false);
                          }
                        },
                  child: isSubmitting ? CircularProgressIndicator() : Text(index == null ? 'Add Staff' : 'Update Staff'),
                ),
              ],
            );
          },
        );
      },
    );
  }
}
