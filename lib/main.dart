import 'package:flutter/material.dart';
import 'router.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: "Flutter Navigaton 2.0",
      routerDelegate: ShopListRouterDelegate(),
      routeInformationParser: ShopListRouterInformationParser(),
    );
  }
}
