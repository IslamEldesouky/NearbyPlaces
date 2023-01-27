import 'package:clippy_flutter/triangle.dart';
import 'package:custom_info_window/custom_info_window.dart';
import 'package:flutter/material.dart';
import 'package:flutter_google_places_hoc081098/flutter_google_places_hoc081098.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_api_headers/google_api_headers.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_maps_webservice/places.dart';

void main() => runApp(MyApp());

final places =
    GoogleMapsPlaces(apiKey: "AIzaSyCM6SRj9Ku22_2nZ6JAY7OW_Q8zKRCm270");
Icon customIcon = const Icon(Icons.search);
Widget customSearchBar = const Text('My Personal Journal');
TextEditingController nearByCategory = new TextEditingController();

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "Foodie Map",
      home: Scaffold(
          // We'll change the AppBar title later
          appBar: AppBar(title: const Text("Search nearby categories")),
          body: FoodieMap()),
    );
  }
}

class FoodieMap extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _FoodieMapState();
  }
}

class _FoodieMapState extends State<FoodieMap> {
  Future<Position>? _currentLocation;
  Set<Marker> _markers = {};
  String googleApikey = "AIzaSyCM6SRj9Ku22_2nZ6JAY7OW_Q8zKRCm270";
  GoogleMapController? mapController; //contrller for Google map
  CameraPosition? cameraPosition;
  LatLng startLocation = LatLng(27.6602292, 85.308027);
  String location = "Search Location";
  String placesSearch = "restaurants";
  TextEditingController placeController = new TextEditingController();
  CustomInfoWindowController _customInfoWindowController =
      CustomInfoWindowController();

  @override
  void initState() {
    super.initState();
    _currentLocation = Geolocator.getCurrentPosition();
  }

  Future<void> _retrieveNearbyRestaurants(LatLng _userLocation) async {
    PlacesSearchResponse _response = await places.searchNearbyWithRadius(
        Location(lat: _userLocation.latitude, lng: _userLocation.longitude),
        10000,
        type: placeController.text);

    print("LOG" + _response.status);
    print("LOG" + _response.toString());
    print("LOG" + placeController.text);
    Set<Marker> _restaurantMarkers = _response.results
        .map((result) => Marker(
            markerId: MarkerId(result.name),
            // Use an icon with different colors to differentiate between current location
            // and the restaurants
            icon: BitmapDescriptor.defaultMarkerWithHue(
                BitmapDescriptor.hueAzure),
            onTap: () {
              _customInfoWindowController.addInfoWindow!(
                Column(
                  children: [
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.blue,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Column(
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.place_rounded,
                                    color: Colors.white,
                                    size: 30,
                                  ),
                                  SizedBox(
                                    width: 8.0,
                                  ),
                                  Flexible(
                                    child: Text(
                                      result.name,
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: Colors.white,
                                      ),
                                      softWrap: true,
                                      textAlign: TextAlign.start,
                                    ),
                                  )
                                ],
                              ),
                            ),
                            Container(
                                child: TextButton(
                                    onPressed: () {},
                                    child: Text(
                                      "More Details ->",
                                      style: TextStyle(
                                        fontSize: 10,
                                        decoration: TextDecoration.underline,
                                        color: Colors.white,
                                      ),
                                    ))),
                          ],
                        ),
                        width: double.maxFinite,
                        height: double.maxFinite,
                      ),
                    ),
                    Triangle.isosceles(
                      edge: Edge.BOTTOM,
                      child: Container(
                        color: Colors.blue,
                        width: 20.0,
                        height: 10.0,
                      ),
                    ),
                  ],
                ),
                LatLng(result.geometry!.location.lat,
                    result.geometry!.location.lng),
              );
            },
            // infoWindow: InfoWindow(
            //     title: result.name,
            //     snippet:
            //         "Ratings: " + (result.rating?.toString() ?? "Not Rated")),
            position: LatLng(
                result.geometry!.location.lat, result.geometry!.location.lng)))
        .toSet();
    setState(() {
      _markers.addAll(_restaurantMarkers);
    });
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: _currentLocation,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            if (snapshot.hasData) {
              // The user location returned from the snapshot
              Position? snapshotData = snapshot.data;
              LatLng _userLocation =
                  LatLng(snapshotData!.latitude, snapshotData.longitude);

              if (_markers.isEmpty) {
                _retrieveNearbyRestaurants(_userLocation);
              }

              return Stack(children: [
                GoogleMap(
                  initialCameraPosition: CameraPosition(
                    target: _userLocation,
                    zoom: 12,
                  ),
                  onTap: (position) {
                    _customInfoWindowController.hideInfoWindow!();
                  },
                  onCameraMove: (position) {
                    _customInfoWindowController.onCameraMove!();
                  },
                  onMapCreated: (GoogleMapController controller) async {
                    _customInfoWindowController.googleMapController =
                        controller;
                  },
                  markers: _markers
                    ..add(Marker(
                        markerId: MarkerId("User Location"),
                        infoWindow: InfoWindow(title: "User Location"),
                        position: _userLocation)),
                ),
                Positioned(
                    top: 10,
                    child: Container(
                      color: Colors.white,
                      width: MediaQuery.of(context).size.width - 40,
                      child: ListTile(
                        trailing: IconButton(
                          icon:
                              Icon(Icons.search, color: Colors.black, size: 28),
                          onPressed: () {
                            setState(() {
                              _markers.clear();
                              _retrieveNearbyRestaurants(_userLocation);
                            });
                          },
                        ),
                        title: TextField(
                          controller: placeController,
                          onSubmitted: (s) {
                            setState(() {
                              nearByCategory.text = s;
                            });
                          },
                          decoration: InputDecoration(
                            hintText:
                                'Discover restaurant,pharmacy,,etc near you',
                            hintStyle: TextStyle(
                              color: Colors.grey,
                              fontSize: 18,
                              fontStyle: FontStyle.italic,
                            ),
                            border: InputBorder.none,
                          ),
                          style: TextStyle(
                            color: Colors.black,
                          ),
                        ),
                      ),
                    )),
                CustomInfoWindow(
                  controller: _customInfoWindowController,
                  height: 150,
                  width: 150,
                  offset: 50,
                ),
              ]);
            } else {
              print(snapshot.error.toString());
              return Center(child: Text("Failed to get user location."));
            }
          }
          // While the connection is not in the done state yet
          return Center(child: CircularProgressIndicator());
        });
  }
}
