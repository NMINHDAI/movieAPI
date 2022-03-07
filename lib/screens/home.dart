import 'package:flutter/material.dart';
import 'package:movie_api/screens/detail.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late Future<List<Show>> shows;
  final myController = TextEditingController();

  @override
  void initState() {
    super.initState();
    shows = fetchShows();
  }

  @override
  void dispose() {
    // Clean up the controller when the widget is disposed.
    myController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Movie api')),
      body: Column(
        children: [
          IconButton(
              onPressed: () {
                setState(() {
                  if (myController.text != '')
                    shows = searchShows(myController.text);
                  else
                    shows = fetchShows();
                });
              },
              icon: Icon(Icons.search)),
          TextField(
            controller: myController,
          ),
          Expanded(
            child: FutureBuilder(
              builder: (context, AsyncSnapshot<List<Show>> snapshot) {
                if (snapshot.hasData) {
                  return Center(
                    child: ListView.separated(
                      padding: const EdgeInsets.all(8),
                      itemCount: snapshot.data!.length,
                      itemBuilder: (BuildContext context, int index) {
                        return ListTile(
                          leading: CircleAvatar(
                            backgroundImage: NetworkImage(
                                '${snapshot.data![index].imageUrl}'),
                          ),
                          title: Text('${snapshot.data![index].name}'),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => DetailPage(
                                    id: snapshot.data![index].id,
                                    name: snapshot.data![index].name),
                              ),
                            );
                          },
                        );
                      },
                      separatorBuilder: (BuildContext context, int index) =>
                          const Divider(),
                    ),
                  );
                } else if (snapshot.hasError) {
                  return Center(child: Text('Something went wrong :('));
                }

                return CircularProgressIndicator();
              },
              future: shows,
            ),
          ),
        ],
      ),
    );
  }
}

class Show {
  final int id;
  final String name;
  final String imageUrl;

  Show({
    required this.id,
    required this.name,
    required this.imageUrl,
  });

  factory Show.fromJson(Map<String, dynamic> json) {
    return Show(
      id: json['id'],
      name: json['name'],
      imageUrl: json['image_thumbnail_path'],
    );
  }
}

Future<List<Show>> fetchShows() async {
  final response = await http
      .get(Uri.parse('https://www.episodate.com/api/most-popular?page=1'));

  if (response.statusCode == 200) {
    var topShowsJson = jsonDecode(response.body)['tv_shows'] as List;
    return topShowsJson.map((show) => Show.fromJson(show)).toList();
  } else {
    throw Exception('Failed to load shows');
  }
}

Future<List<Show>> searchShows(name) async {
  final response = await http
      .get(Uri.parse('https://www.episodate.com/api/search?q=${name}'));

  if (response.statusCode == 200) {
    var topShowsJson = jsonDecode(response.body)['tv_shows'] as List;
    return topShowsJson.map((show) => Show.fromJson(show)).toList();
  } else {
    throw Exception('Failed to load shows');
  }
}
