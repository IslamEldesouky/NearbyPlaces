import 'dart:developer';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_maps_webservice/places.dart';

class PlaceDetailsScreen extends StatefulWidget {
  final PlacesSearchResult result;

  const PlaceDetailsScreen(this.result);

  @override
  State<PlaceDetailsScreen> createState() => _PlaceDetailsScreenState(result);
}

class _PlaceDetailsScreenState extends State<PlaceDetailsScreen> {
  final PlacesSearchResult result;

  _PlaceDetailsScreenState(this.result);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(result.name),
        centerTitle: true,
        actions: [
          IconButton(
              onPressed: () {
                Navigator.pop(context);
              },
              icon: Icon(
                Icons.arrow_back,
                color: Colors.white,
              ))
        ],
      ),
      body: Container(
        height: MediaQuery.of(context).size.height,
        child: Padding(
          padding: EdgeInsets.all(10),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Information : ",
                  style: TextStyle(
                      decoration: TextDecoration.underline,
                      color: Colors.black,
                      fontSize: 15)),
              Padding(padding: EdgeInsets.only(top: 10)),
              Row(
                children: [
                  Text(
                    "Rating : ",
                    style: TextStyle(color: Colors.black, fontSize: 12),
                  ),
                  Spacer(),
                  Text(
                    result.rating.toString() == null
                        ? "Not available"
                        : result.rating.toString(),
                    style: TextStyle(color: Colors.black, fontSize: 12),
                  )
                ],
              ),
              Padding(padding: EdgeInsets.only(top: 10)),
              Container(
                height: 250,
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: result.photos.length,
                  itemBuilder: (BuildContext ctx, int index) {
                    return Padding(
                      padding: EdgeInsets.all(20),
                      child: Card(
                        shape: Border.all(
                          width: 5,
                        ),
                        elevation: 20,
                        child: Image.network(
                            "https://maps.googleapis.com/maps/api/place/photo?maxwidth=400&photo_reference=" +
                                result.photos[index].photoReference +
                                "&key="+dotenv.env['API_KEY']!),
                      ),
                    );
                  },
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
