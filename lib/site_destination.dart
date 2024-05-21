// a data class that holds a site name, site description, and
// image of the site
import 'package:cloud_firestore/cloud_firestore.dart';

class Sites {
  final String name;
  final String description;
  final GeoPoint location;
  final String image;
  bool favorited; // Changed from List<String> to bool

  Sites(
      {required this.name,
      required this.description,
      required this.image,
      required this.favorited,
      required this.location});

  Map<String, Object?> toMap() {
    return {
      'name': name,
      'description': description,
      'image': image,
      'favorited': favorited, // Updated field name
      'location': location
    };
  }
}
