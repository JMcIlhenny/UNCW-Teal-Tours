import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({Key? key}) : super(key: key);

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  GoogleMapController? controller;

  static const CameraPosition _uncwBellTower = CameraPosition(
    target: LatLng(34.2271592, -77.8729786),
    zoom: 15,
  );

  final Set<Marker> _markers = {};

  @override
  void initState() {
    super.initState();
    _fetchSiteLocations();
  }

  void _fetchSiteLocations() {
    FirebaseFirestore.instance.collection('Sites').get().then((querySnapshot) {
      if (querySnapshot.docs.isNotEmpty) {
        for (var doc in querySnapshot.docs) {
          var site = doc.data();
          // Check if 'location' field exists and is not null
          if (site.containsKey('location') && site['location'] != null) {
            var location = site['location'] as GeoPoint;
            _markers.add(
              Marker(
                markerId: MarkerId(doc.id),
                position: LatLng(location.latitude, location.longitude),
                infoWindow: InfoWindow(
                    title: site['name'], snippet: site['description']),
              ),
            );
          } else {
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
              content: Text('Location data missing'),
              duration: Duration(seconds: 2),
            ));
          }
        }
        setState(() {}); // Update the UI after adding markers
      }
    }).catchError((error) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Error fetching site location'),
        duration: Duration(seconds: 2),
      ));
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GoogleMap(
        mapType: MapType.hybrid,
        initialCameraPosition: _uncwBellTower,
        onMapCreated: (GoogleMapController controller) {
          this.controller = controller;
        },
        markers: _markers,
      ),
    );
  }
}
