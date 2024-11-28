class PredictedPlaces {
  final String placeId;
  final String mainText;
  final String? secondaryText;

  PredictedPlaces({
    required this.placeId,
    required this.mainText,
    this.secondaryText,
  });

  /// Factory constructor to parse JSON into a PredictedPlaces object
  factory PredictedPlaces.fromJson(Map<String, dynamic> json) {
    return PredictedPlaces(
      placeId: json["place_id"] as String,
      mainText: json["structured_formatting"]["main_text"] as String,
      secondaryText: json["structured_formatting"]["secondary_text"] as String?,
    );
  }
}
