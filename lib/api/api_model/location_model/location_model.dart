class GooglePlacesSuggestion {
  final String placeId;
  final String mainText;
  final String secondaryText;
  final String fullText;
  final bool isRecentLocation;
  final bool isCurrentLocation;
  final String? displayName;

  GooglePlacesSuggestion({
    required this.placeId,
    required this.mainText,
    required this.secondaryText,
    required this.fullText,
    this.isRecentLocation = false,
    this.displayName,
   required this.isCurrentLocation,
  });
}

class GooglePlaceDetails {
  final String? name;
  final String placeId;
  final String formattedAddress;
  final double latitude;
  final double longitude;
  final String pinCode;

  GooglePlaceDetails({
    this.name,
    required this.placeId,
    required this.formattedAddress,
    required this.latitude,
    required this.longitude,
    required this.pinCode,
  });
}

class LocationData {
  final String displayName;
  final String addressDetails;
  final String? pincode;

  LocationData({
    required this.displayName,
    required this.addressDetails,
    this.pincode,
  });
}
