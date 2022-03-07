import 'package:flutter/material.dart';
import 'package:movie_api/screens/home.dart';
import 'package:movie_api/screens/detail.dart';

void main() async {
  runApp(AnimeApp());
}

class AnimeApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Movie app',
      debugShowCheckedModeBanner: false,
      initialRoute: '/',
      routes: {
        '/': (context) => HomePage(),
        '/detail': (context) => DetailPage(id: 0, name: ''),
      },
    );
  }
}
