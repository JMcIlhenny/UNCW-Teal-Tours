import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _controller = TextEditingController();
  final sitesRef = FirebaseFirestore.instance.collection("Sites");
  List<QueryDocumentSnapshot> searchResults = [];

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Site Search")),
      body: Padding(
        padding: const EdgeInsets.all(8),
        child: Column(
          children: [
            TextField(
              controller: _controller,
              decoration: const InputDecoration(hintText: "Enter a site name"),
              onChanged: (value) {
                if (value.isEmpty) {
                  setState(() {
                    searchResults = [];
                  });
                } else {
                  sitesRef.where('name', isEqualTo: value).get().then(
                    (result) {
                      searchResults = result.docs;
                      setState(() {});
                    },
                  );
                }
              },
            ),
            Expanded(child: _getBodyContent()),
          ],
        ),
      ),
    );
  }

  Widget _getBodyContent() {
    if (_controller.text.isEmpty) {
      return const Text("Enter a search term to see results");
    }

    if (searchResults.isEmpty) {
      return const Text("Your search didn't match anything");
    }

    return ListView.builder(
      itemCount: searchResults.length,
      itemBuilder: (context, index) => ListTile(
        leading: const Icon(Icons.location_city),
        title: Text(searchResults[index].get('name')),
        subtitle: Text(searchResults[index].get('description')),
      ),
    );
  }
}
