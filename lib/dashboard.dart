import 'package:flutter/material.dart';
import 'package:zaad_admin/category.dart';
import 'package:zaad_admin/customers.dart';
import 'package:zaad_admin/items_screen.dart';
import 'package:zaad_admin/users.dart';

class DashBoard extends StatefulWidget {
  const DashBoard({super.key});

  @override
  State<DashBoard> createState() => _DashBoardState();
}

class _DashBoardState extends State<DashBoard> {
  int selectedIndex = 0;

  final List<Widget> screens = [
    UsersScreen(),
    CustomersScreen(),
    ItemsScreen(),
    CategoryScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Row(
        children: [
          // Navigation Sidebar
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 2, spreadRadius: 3)],
                color: Colors.white,
              ),
              padding: const EdgeInsets.only(top: 32),
              child: ListView(
                children: navButtons
                    .asMap()
                    .entries
                    .map(
                      (e) => ListTile(
                        title: Text(
                          e.value,
                          style: TextStyle(
                            fontWeight: selectedIndex == e.key ? FontWeight.bold : FontWeight.normal,
                            color: selectedIndex == e.key ? Colors.blue : Colors.black,
                          ),
                        ),
                        onTap: () => onClickButton(e.key),
                      ),
                    )
                    .toList(),
              ),
            ),
          ),
          // Main Content Area
          Expanded(
            flex: 5,
            child: screens[selectedIndex],
          ),
        ],
      ),
    );
  }

  void onClickButton(int index) {
    setState(() {
      selectedIndex = index;
    });
  }
}

List<String> navButtons = ["Staffs", "Customers", "Items", "Categories"];
