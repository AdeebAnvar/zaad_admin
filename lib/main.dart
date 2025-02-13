import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:zaad_admin/constatnts/colors.dart';
import 'package:zaad_admin/constatnts/styles.dart';
import 'package:zaad_admin/dashboard.dart';
import 'package:zaad_admin/login.dart';

String? token;
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();
  token = prefs.getString("token");
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'Flutter Demo',
        theme: ThemeData(
          scaffoldBackgroundColor: Colors.white,
          // This is the theme of your application.
          //
          // TRY THIS: Try running your application with "flutter run". You'll see
          // the application has a purple toolbar. Then, without quitting the app,
          // try changing the seedColor in the colorScheme below to Colors.green
          // and then invoke "hot reload" (save your changes or press the "hot
          // reload" button in a Flutter-supported IDE, or press "r" if you used
          // the command line to start the app).
          //
          // Notice that the counter didn't reset back to zero; the application
          // state is not lost during the reload. To reset the state, use hot
          // restart instead.
          //
          // This works for code too, not just values: Most code changes can be
          // tested with just a hot reload.
          // colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
          primaryColor: AppColors.primaryColor,
          dialogBackgroundColor: Colors.white,
          elevatedButtonTheme: ElevatedButtonThemeData(style: AppStyles.filledButton),
          dialogTheme: DialogTheme(
            backgroundColor: Colors.white,
            surfaceTintColor: Colors.white,
          ),
          buttonTheme: ButtonThemeData(
            buttonColor: AppColors.primaryColor,
          ),
          useMaterial3: true,
        ),
        debugShowCheckedModeBanner: false,
        home: token == null || token!.isEmpty ? LoginScreen() : DashBoard());
  }
}
