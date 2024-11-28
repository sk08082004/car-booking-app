import 'package:flutter/material.dart';
import 'package:user_app/models/predicted_places.dart';
import 'package:user_app/global/global_var.dart';
import 'package:user_app/methods/common_methods.dart';
import 'package:user_app/models/directions.dart';

class SearchPlacesScreen extends StatefulWidget {
  const SearchPlacesScreen({super.key});

  @override
  State<SearchPlacesScreen> createState() => _SearchPlacesScreenState();
}

class _SearchPlacesScreenState extends State<SearchPlacesScreen> {
  List<PredictedPlaces> placesPredictedList = [];

  // Function to handle search input and auto-complete API
  Future<void> findPlaceAutoCompleteSearch(String inputText) async {
    if (inputText.isEmpty || inputText.length <= 1) return;

    String urlAutoCompleteSearch =
        "https://maps.googleapis.com/maps/api/place/autocomplete/json?input=$inputText&key=$googleMapsKey&components=country:IN";
    var responseAutoCompleteSearch =
        await CommonMethods().fetchData(urlAutoCompleteSearch);

    if (responseAutoCompleteSearch == null ||
        responseAutoCompleteSearch["status"] != "OK") return;

    var placePredictions = responseAutoCompleteSearch["predictions"];
    var placePredictionsList = (placePredictions as List)
        .map((jsonData) => PredictedPlaces.fromJson(jsonData))
        .toList();

    setState(() {
      placesPredictedList = placePredictionsList;
    });
  }

  // Function to fetch details of the selected place
  Future<void> getPlaceDirectionDetails(String? placeId) async {
    if (placeId == null) return;

    String placeDetailsUrl =
        "https://maps.googleapis.com/maps/api/place/details/json?place_id=$placeId&key=$googleMapsKey";
    var responseApi = await CommonMethods().fetchData(placeDetailsUrl);

    if (responseApi == null || responseApi["status"] != "OK") return;

    Directions directions = Directions(
      locationName: responseApi["result"]["name"],
      locationId: placeId,
      locationLatitude: responseApi["result"]["geometry"]["location"]["lat"],
      locationLongitude: responseApi["result"]["geometry"]["location"]["lng"],
    );

    Navigator.pop(context, directions);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Search Places"),
        backgroundColor: Colors.yellow.shade700,  // Yellow background
        foregroundColor: Colors.black,  // Black text
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8),
            child: TextField(
              onChanged: findPlaceAutoCompleteSearch,
              decoration: InputDecoration(
                hintText: "Search Location...",
                hintStyle: const TextStyle(color: Colors.black), // Hint text color
                fillColor: Colors.white,
                filled: true,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide.none,
                ),
                prefixIcon: const Icon(Icons.search, color: Colors.black),
              ),
            ),
          ),
          Expanded(
            child: placesPredictedList.isEmpty
                ? const Center(child: Text("No places found", style: TextStyle(color: Colors.black)))
                : ListView.builder(
                    itemCount: placesPredictedList.length,
                    itemBuilder: (context, index) {
                      return ListTile(
                        title: Text(
                          placesPredictedList[index].mainText ?? "",
                          style: const TextStyle(color: Colors.black),  // Black color for main text
                        ),
                        subtitle: Text(
                          placesPredictedList[index].secondaryText ?? "",
                          style: const TextStyle(color: Colors.black),  // Black color for subtitle
                        ),
                        onTap: () => getPlaceDirectionDetails(
                            placesPredictedList[index].placeId),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
