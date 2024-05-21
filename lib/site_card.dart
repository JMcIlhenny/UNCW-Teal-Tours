import 'package:flutter/material.dart';
import 'site_destination.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class SiteCard extends StatelessWidget {
  const SiteCard({required this.site, required this.currentUserID, Key? key})
      : super(key: key);
  final Sites site;
  final String currentUserID;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(MaterialPageRoute(
            builder: (context) => DetailScreen(
                  site,
                )));
      },
      child: Card(
        elevation: 4,
        margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
        child: Container(
          decoration: BoxDecoration(
            border: Border.all(width: 3),
            borderRadius: BorderRadius.circular(8),
          ),
          padding: const EdgeInsets.all(8),
          child: Row(
            children: [
              Expanded(
                flex: 3,
                child: SizedBox(
                  height: 200,
                  child: Image.asset(
                    site.image,
                    fit: BoxFit.cover,
                    width: double.infinity,
                  ),
                ),
              ),
              const SizedBox(width: 15),
              Expanded(
                flex: 7,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      site.name,
                      textAlign: TextAlign.start,
                      style: const TextStyle(
                        color: Color.fromARGB(255, 0, 0, 0),
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      site.description,
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.black,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: site.favorited
                    ? const Icon(Icons.star)
                    : const Icon(Icons.star_border),
                color: site.favorited ? Colors.yellow : null,
                onPressed: () {
                  toggleFavoriteStatus(site);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  void toggleFavoriteStatus(Sites site) async {
    final DocumentReference docRef =
        FirebaseFirestore.instance.collection('Sites').doc(site.name);

    await docRef.update({
      'favorited': !site.favorited,
    });
  }
}

class DetailScreen extends StatelessWidget {
  const DetailScreen(this.site, {Key? key}) : super(key: key);
  final Sites? site;

  @override
  Widget build(BuildContext context) {
    if (site == null) {
      return Scaffold(
        appBar: AppBar(
            title: const Text("Site Details",
                style: TextStyle(color: Colors.white))),
        body: const Center(child: Text("Nothing to see here! Go Seahawks!")),
      );
    }
    return Scaffold(
      backgroundColor: Colors.teal,
      appBar: AppBar(
        title:
            const Text("Site Details", style: TextStyle(color: Colors.white)),
        backgroundColor: const Color.fromARGB(255, 6, 73, 66),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 3,
            child: Image.asset(
              site!.image,
              fit: BoxFit.cover,
            ),
          ),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  site!.name,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  site!.description,
                  style: const TextStyle(
                    fontSize: 18,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}
