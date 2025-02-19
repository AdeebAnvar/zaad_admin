import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:zaad_admin/category.dart';
import 'package:zaad_admin/constatnts/colors.dart';
import 'package:zaad_admin/customers.dart';
import 'package:zaad_admin/login.dart';
import 'package:zaad_admin/products_screen.dart';
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
    ProductsScreen(),
    CategoryScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Zaad Admin'),
        backgroundColor: Colors.white,
        // actions: [
        //   IconButton(
        //     icon: const Icon(Icons.exit_to_app, color: Colors.white),
        //     onPressed: onLogout,
        //   ),
        // ],
      ),
      drawer: MediaQuery.of(context).size.width < 600
          ? Drawer(
              child: Column(
                children: [
                  // Navigation Buttons
                  Expanded(
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
                ],
              ),
            )
          : null,
      body: Row(
        children: [
          // Sidebar for larger screens
          if (MediaQuery.of(context).size.width >= 600)
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 2, spreadRadius: 3)],
                  color: Colors.white,
                ),
                padding: const EdgeInsets.only(top: 32),
                child: Column(
                  children: [
                    // Navigation Buttons
                    Expanded(
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
                    const Divider(), // Separates the navigation from the logout button

                    // Logout Button
                    ListTile(
                      title: const Text(
                        "Logout",
                        style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
                      ),
                      leading: const Icon(Icons.exit_to_app, color: Colors.red),
                      onTap: onLogout,
                    ),
                  ],
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
      bottomNavigationBar: MediaQuery.of(context).size.width < 600
          ? BottomNavigationBar(
              backgroundColor: Colors.white,
              currentIndex: selectedIndex,
              selectedItemColor: AppColors.primaryColor,
              unselectedItemColor: Colors.black26,
              onTap: onClickButton,
              items: [
                BottomNavigationBarItem(
                  icon: Icon(Icons.people),
                  label: 'Staffs',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.person),
                  label: 'Customers',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.shopping_bag),
                  label: 'Items',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.category),
                  label: 'Categories',
                ),
              ],
            )
          : null,
    );
  }

  void onClickButton(int index) {
    setState(() {
      selectedIndex = index;
    });
  }

  void onLogout() async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    pref.clear();
    Navigator.pushReplacement(context, MaterialPageRoute(builder: (c) => LoginScreen())); // Change route to your login page
  }
}

List<String> navButtons = ["Staffs", "Customers", "Items", "Categories"];
