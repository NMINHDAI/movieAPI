import 'dart:async';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

Future<Episode> fetchEpisodes(id) async {
  final response = await http
      .get(Uri.parse('https://www.episodate.com/api/show-details?q=${id}'));

  if (response.statusCode == 200) {
    // If the server did return a 200 OK response,
    // then parse the JSON.
    return Episode.fromJson(jsonDecode(response.body)['tvShow']);
  } else {
    // If the server did not return a 200 OK response,
    // then throw an exception.
    throw Exception('Failed to load album');
  }
}

class Episode {
  final int episodeId;
  final String name;
  final String description;
  final String image_path;

  Episode({
    required this.episodeId,
    required this.name,
    required this.description,
    required this.image_path,
  });

  factory Episode.fromJson(Map<String, dynamic> json) {
    return Episode(
      episodeId: json['id'],
      name: json['name'],
      description: json['description'],
      image_path: json['image_thumbnail_path'],
    );
  }
}

class DetailPage extends StatefulWidget {
  final int id;
  final String name;

  const DetailPage({
    Key? key,
    required this.id,
    required this.name,
  }) : super(key: key);

  @override
  _DetailPageState createState() => _DetailPageState();
}

class _DetailPageState extends State<DetailPage> {
  late Future<Episode> episodes;

  @override
  void initState() {
    super.initState();
    episodes = fetchEpisodes(widget.id);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.name)),
      body: Center(
        child: FutureBuilder<Episode>(
          future: fetchEpisodes(widget.id),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              return SingleChildScrollView(
                child: Column(
                  children: [
                    Text(snapshot.data!.name),
                    Text(snapshot.data!.description),
                    Image.network(snapshot.data!.image_path),
                  ],
                ),
              );
            } else if (snapshot.hasError) {
              return Text('${snapshot.error}');
            }
            return CircularProgressIndicator();
          },
        ),
      ),
    );
  }
}
