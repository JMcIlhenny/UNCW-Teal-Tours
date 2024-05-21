import 'package:flutter/material.dart';
import 'dart:math';
import 'site_destination.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'map_screen.dart';
import 'site_card.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:geolocator/geolocator.dart';
import 'search_screen.dart';

class PrimaryScreen extends StatefulWidget {
  const PrimaryScreen({Key? key}) : super(key: key);

  @override
  PrimaryScreenState createState() => PrimaryScreenState();
}

class PrimaryScreenState extends State<PrimaryScreen> {
  Position? currentUserLocation; // Updated currentUserLocation

  double calculateDistance(double userLat, double userLong, double locationLat,
      double locationLong) {
    double latDifferenceSquared = pow(locationLat - userLat, 2) as double;
    double longDifferenceSquared = pow(locationLong - userLong, 2) as double;
    double distance = sqrt(latDifferenceSquared + longDifferenceSquared);
    return distance;
  }

  final PageController _pageController = PageController();
  int _selectedIndex = 0;

  bool _sortByName = false;
  bool _sortByDistance = false;

  @override
  void initState() {
    super.initState();
    _getCurrentUserLocation();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("UNCW Sites", style: TextStyle(color: Colors.white)),
        backgroundColor: const Color.fromARGB(255, 6, 73, 66),
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const SearchScreen()),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          if (_selectedIndex ==
              0) // Only show sort buttons when on the list screen
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      _sortByName = true;
                      _sortByDistance = false;
                    });
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _sortByName
                        ? Colors.green
                        : null, // Change color when selected
                  ),
                  child: const Text("Sort by Name"),
                ),
                const SizedBox(width: 20),
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      _sortByName = false;
                      _sortByDistance = true;
                    });
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _sortByDistance
                        ? Colors.green
                        : null, // Change color when selected
                  ),
                  child: const Text("Sort by Distance"),
                ),
              ],
            ),
          Expanded(
            child: PageView(
              controller: _pageController,
              onPageChanged: (index) {
                setState(() {
                  _selectedIndex = index;
                });
              },
              children: [
                StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection('Sites')
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (snapshot.hasError) {
                      return Center(child: Text('Error: ${snapshot.error}'));
                    }
                    List<QueryDocumentSnapshot> documents = snapshot.data!.docs;
                    List<Sites> sites = documents.map((doc) {
                      return Sites(
                          name: doc['name'],
                          image: doc['image'],
                          description: doc['description'],
                          favorited: doc['favorited'],
                          location: doc['location']);
                    }).toList();

                    // Sort the sites based on the selected sorting option
                    if (_sortByName) {
                      sites.sort((a, b) =>
                          a.name.toLowerCase().compareTo(b.name.toLowerCase()));
                    } else if (_sortByDistance && currentUserLocation != null) {
                      sites.sort((a, b) {
                        double distanceA = calculateDistance(
                          currentUserLocation!.latitude,
                          currentUserLocation!.longitude,
                          a.location.latitude,
                          a.location.longitude,
                        );
                        double distanceB = calculateDistance(
                          currentUserLocation!.latitude,
                          currentUserLocation!.longitude,
                          b.location.latitude,
                          b.location.longitude,
                        );
                        return distanceA.compareTo(distanceB);
                      });
                    }

                    return ListView.builder(
                      padding: const EdgeInsets.all(20),
                      itemCount: sites.length,
                      itemBuilder: (context, index) => SiteCard(
                        site: sites[index],
                        currentUserID: FirebaseAuth.instance.currentUser!.uid,
                      ),
                    );
                  },
                ),
                const MapScreen(),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.teal,
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.grey,
        selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold),
        currentIndex: _selectedIndex,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.list),
            label: 'List',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.map),
            label: 'Map',
          ),
        ],
        onTap: (index) {
          _pageController.animateToPage(
            index,
            duration: const Duration(milliseconds: 500),
            curve: Curves.fastOutSlowIn,
          );
        },
      ),
    );
  }

  // Function to retrieve current user location
  void _getCurrentUserLocation() async {
    try {
      Position position = await Geolocator.getCurrentPosition();
      setState(() {
        currentUserLocation = position;
      });
    } catch (e) {
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Error retrieving user information!'),
        duration: Duration(seconds: 2),
      ));
    }
  }
}
