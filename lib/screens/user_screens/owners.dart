// // lib/screens/owners.dart
// import 'package:flutter/cupertino.dart';
// import 'package:flutter/material.dart';
// import 'package:r_w_r/components/app_appbar.dart';
// import 'package:r_w_r/components/custom_activity.dart';
// import 'package:r_w_r/constants/color_constants.dart';
//
// import '../../api/api_model/location_model/location_model.dart';
// import '../../api/api_model/owner/owners_model.dart';
// import '../../api/api_service/owners/owner_service.dart';
// import '../../constants/api_constants.dart';
// import '../../constants/assets_constant.dart';
// import '../../l10n/app_localizations.dart';
// import 'owner_details.dart';
//
// class Owners extends StatefulWidget {
//   final GooglePlaceDetails? selectedLocation;
//
//   const Owners({
//     super.key,
//     this.selectedLocation,
//   });
//
//   @override
//   State<Owners> createState() => _OwnersState();
// }
//
// class _OwnersState extends State<Owners> {
//   final String _searchQuery = '';
//   final TextEditingController _searchController = TextEditingController();
//   bool _showLocationSearch = false;
//   List<GooglePlacesSuggestion> _locationSuggestions = [];
//   bool _isSearchingLocation = false;
//
//   final DriverService _driverService = DriverService();
//   List<DriverModel> _apiDrivers = [];
//   bool _isLoading = true;
//   String _errorMessage = '';
//
//   @override
//   void initState() {
//     super.initState();
//     _searchController.text = widget.selectedLocation?.formattedAddress ?? '';
//     _fetchDrivers();
//   }
//
//   Future<void> _fetchDrivers() async {
//     setState(() {
//       _isLoading = true;
//       _errorMessage = '';
//     });
//
//     try {
//       final response = await _driverService.searchDrivers(
//         pincode: widget.selectedLocation?.pinCode.toString() ?? '201001',
//         lat: widget.selectedLocation?.latitude ?? 333.2,
//         lng: widget.selectedLocation?.longitude ?? 33.2,
//       );
//
//       for (int i = 0; i < response.data.length; i++) {
//         final driver = response.data[i];
//       }
//
//       setState(() {
//         _apiDrivers = response.data;
//         _isLoading = false;
//       });
//
//       print('✅ State updated successfully with ${_apiDrivers.length} drivers');
//     } catch (e, stackTrace) {
//       print('❌ Error fetching drivers: $e');
//       print('❌ Stack trace: $stackTrace');
//       setState(() {
//         final localizations = AppLocalizations.of(context)!;
//
//         _errorMessage = '${localizations.failed_to_load_data} $e';
//         _isLoading = false;
//       });
//     }
//   }
//
//   // Filtered drivers based on search
//   List<DriverModel> get _filteredDrivers {
//     try {
//       if (_searchQuery.isEmpty) {
//         return _apiDrivers;
//       }
//
//       return _apiDrivers.where((driver) {
//         // Since your model has non-nullable fields, we can access them directly
//         final name = driver.name;
//         final city = driver.address.city;
//         final servicesLocations = driver.servicesLocations;
//
//         return name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
//             city.toLowerCase().contains(_searchQuery.toLowerCase()) ||
//             servicesLocations.any((location) =>
//                 location.toLowerCase().contains(_searchQuery.toLowerCase()));
//       }).toList();
//     } catch (e) {
//       print('Error in _filteredDrivers: $e');
//       return [];
//     }
//   }
//
//   Future<void> _searchLocations(String query) async {
//     if (query.isEmpty) {
//       setState(() {
//         _locationSuggestions = [];
//       });
//       return;
//     }
//
//     setState(() {
//       _isSearchingLocation = true;
//     });
//
//     try {
//       // Here you would call your location search API
//       // For now, we'll simulate with a delay
//       await Future.delayed(Duration(milliseconds: 500));
//
//       // This is just a mock - replace with your actual API call
//       setState(() {
//         _locationSuggestions = [
//           GooglePlacesSuggestion(
//             placeId: '1',
//             mainText: query,
//             secondaryText: 'Mock location for $query',
//             fullText: '$query, Mock Location',
//             isCurrentLocation: true,
//           ),
//           GooglePlacesSuggestion(
//             placeId: '2',
//             mainText: 'Nearby $query',
//             secondaryText: 'Another mock location',
//             fullText: 'Nearby $query, Mock Location',
//             isCurrentLocation: true,
//           ),
//         ];
//         _isSearchingLocation = false;
//       });
//     } catch (e) {
//       setState(() {
//         _isSearchingLocation = false;
//         _locationSuggestions = [];
//       });
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('Error searching locations: $e')),
//       );
//     }
//   }
//
//   Future<void> _selectLocation(GooglePlacesSuggestion suggestion) async {
//     // In a real app, you would fetch the full location details here
//     // For now, we'll create a mock GooglePlaceDetails
//     final newLocation = GooglePlaceDetails(
//       placeId: suggestion.placeId,
//       formattedAddress: suggestion.fullText,
//       latitude: 0.0,
//       longitude: 0.0,
//       pinCode: '123456',
//     );
//
//     setState(() {
//       _searchController.text = suggestion.fullText;
//       _showLocationSearch = false;
//       _locationSuggestions = [];
//     });
//
//     Navigator.pushReplacement(
//       context,
//       MaterialPageRoute(
//         builder: (context) => Owners(
//           selectedLocation: newLocation,
//         ),
//       ),
//     );
//   }
//
//   Widget _buildLocationSearchBar() {
//     final localizations = AppLocalizations.of(context)!;
//
//     return Container(
//       padding: const EdgeInsets.all(16),
//       color: ColorConstants.backgroundColor,
//       child: Column(
//         children: [
//           TextField(
//             controller: _searchController,
//             decoration: InputDecoration(
//               hintText: localizations.search_for_location,
//               prefixIcon: Icon(Icons.search, color: Colors.grey[500]),
//               suffixIcon: IconButton(
//                 icon: Icon(Icons.close),
//                 onPressed: () {
//                   setState(() {
//                     _showLocationSearch = false;
//                     _locationSuggestions = [];
//                   });
//                 },
//               ),
//               filled: true,
//               fillColor: Colors.grey[100],
//               border: OutlineInputBorder(
//                 borderRadius: BorderRadius.circular(12),
//                 borderSide: BorderSide.none,
//               ),
//               contentPadding: const EdgeInsets.symmetric(
//                 horizontal: 16,
//                 vertical: 12,
//               ),
//             ),
//             onChanged: (value) {
//               _searchLocations(value);
//             },
//           ),
//           const SizedBox(height: 8),
//           if (_isSearchingLocation)
//             const LinearProgressIndicator(
//               minHeight: 2,
//               color: Colors.purple,
//             ),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildLocationSuggestions() {
//     return Expanded(
//       child: ListView.builder(
//         itemCount: _locationSuggestions.length,
//         itemBuilder: (context, index) {
//           final suggestion = _locationSuggestions[index];
//           return ListTile(
//             leading: Icon(Icons.location_on, color: Colors.purple),
//             title: Text(suggestion.mainText),
//             subtitle: Text(suggestion.secondaryText),
//             onTap: () {
//               _selectLocation(suggestion);
//             },
//           );
//         },
//       ),
//     );
//   }
//
//   @override
//   void dispose() {
//     _searchController.dispose();
//     super.dispose();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     final localizations = AppLocalizations.of(context)!;
//
//     return Scaffold(
//       backgroundColor: ColorConstants.backgroundColor,
//       appBar: CustomAppBar(
//         title: localizations.choose_perfect_driver,
//         titleTextStyle: TextStyle(
//             fontSize: 16,
//             color: ColorConstants.white,
//             fontWeight: FontWeight.w600),
//         centerTitle: true,
//       ),
//       body: SafeArea(
//         child: Column(
//           children: [
//             if (_showLocationSearch) ...[
//               _buildLocationSearchBar(),
//               _buildLocationSuggestions(),
//             ] else ...[
//               Container(
//                 color: Colors.white,
//                 padding: const EdgeInsets.all(16),
//                 child: Row(
//                   children: [
//                     Expanded(
//                       child: GestureDetector(
//                         onTap: () {
//                           setState(() {
//                             _showLocationSearch = true;
//                           });
//                         },
//                         child: Container(
//                           padding: const EdgeInsets.symmetric(
//                               horizontal: 16, vertical: 12),
//                           decoration: BoxDecoration(
//                             color:
//                             ColorConstants.primaryColorLight.withAlpha(50),
//                             borderRadius: BorderRadius.circular(12),
//                           ),
//                           child: Row(
//                             children: [
//                               Icon(Icons.location_on, color: Colors.purple),
//                               const SizedBox(width: 8),
//                               Expanded(
//                                 child: Text(
//                                   _searchController.text.isNotEmpty
//                                       ? _searchController.text
//                                       : localizations.tapToChangeLocation,
//                                   style: TextStyle(
//                                     color: _searchController.text.isNotEmpty
//                                         ? Colors.black
//                                         : Colors.grey,
//                                   ),
//                                   overflow: TextOverflow.ellipsis,
//                                 ),
//                               ),
//                             ],
//                           ),
//                         ),
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//               Expanded(
//                 child: _isLoading
//                     ? const Center(
//                   child: CircularProgressIndicator(
//                     color: ColorConstants.primaryColor,
//                   ),
//                 )
//                     : _errorMessage.isNotEmpty
//                     ? Center(
//                   child: Column(
//                     mainAxisAlignment: MainAxisAlignment.center,
//                     children: [
//                       Text(
//                         _errorMessage,
//                         textAlign: TextAlign.center,
//                         style: const TextStyle(color: Colors.red),
//                       ),
//                       const SizedBox(height: 16),
//                       ElevatedButton(
//                         onPressed: _fetchDrivers,
//                         style: ElevatedButton.styleFrom(
//                           backgroundColor:
//                           ColorConstants.primaryColor,
//                         ),
//                         child: Text(localizations.retry),
//                       ),
//                     ],
//                   ),
//                 )
//                     : _filteredDrivers.isEmpty
//                     ? _buildEmptyWidget()
//                     : RefreshIndicator(
//                   onRefresh: _fetchDrivers,
//                   color: ColorConstants.primaryColor,
//                   child: ListView.builder(
//                     padding:
//                     const EdgeInsets.symmetric(vertical: 6.0),
//                     itemCount: _filteredDrivers.length,
//                     itemBuilder: (context, index) {
//                       final driver = _filteredDrivers[index];
//                       return DriverCard(driver: driver);
//                     },
//                   ),
//                 ),
//               ),
//             ],
//           ],
//         ),
//       ),
//     );
//   }
//
//   Widget _buildEmptyWidget() {
//     final localizations = AppLocalizations.of(context)!;
//
//     return Center(
//       child: Padding(
//         padding: const EdgeInsets.all(16),
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             Icon(
//               Icons.search_off,
//               size: 64,
//               color: Colors.grey.shade400,
//             ),
//             const SizedBox(height: 16),
//             Text(
//               localizations.no_driver_found,
//               style: TextStyle(
//                 fontSize: 18,
//                 fontWeight: FontWeight.bold,
//                 color: Colors.grey[800],
//               ),
//             ),
//             const SizedBox(height: 8),
//             Text(
//               localizations.try_different_criteria,
//               style: TextStyle(
//                 fontSize: 14,
//                 color: Colors.grey[600],
//               ),
//             ),
//             const SizedBox(height: 16),
//             ElevatedButton(
//               onPressed: _fetchDrivers,
//               style: ElevatedButton.styleFrom(
//                 backgroundColor: ColorConstants.primaryColor,
//                 foregroundColor: Colors.white,
//                 shape: RoundedRectangleBorder(
//                   borderRadius: BorderRadius.circular(8),
//                 ),
//                 padding:
//                 const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
//               ),
//               child: Text(localizations.refresh),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
//
// class DriverCard extends StatelessWidget {
//   final DriverModel driver;
//
//   const DriverCard({
//     required this.driver,
//     super.key,
//   });
//
//   @override
//   Widget build(BuildContext context) {
//     final localizations = AppLocalizations.of(context)!;
//
//     return Container(
//       margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 10),
//       padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 2),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(12),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black.withAlpha(12),
//             blurRadius: 10,
//             offset: const Offset(0, 2),
//           ),
//         ],
//         border: Border.all(
//           color: Colors.transparent,
//           width: 2,
//         ),
//       ),
//       child: Column(
//         children: [
//           // Driver info row
//           Padding(
//             padding: const EdgeInsets.all(8.0),
//             child: Row(
//               children: [
//                 // Driver image
//                 Container(
//                   width: 65,
//                   height: 65,
//                   decoration: BoxDecoration(
//                     borderRadius: BorderRadius.circular(8.0),
//                     border: Border.all(color: Colors.grey.shade200, width: 1),
//                     boxShadow: const [
//                       BoxShadow(
//                         color: Colors.black12,
//                         blurRadius: 2,
//                         offset: Offset(0, 1),
//                       ),
//                     ],
//                   ),
//                   child: ClipRRect(
//                     borderRadius: BorderRadius.circular(7.0),
//                     child: Image.network(
//                       driver.image,
//                       width: 65,
//                       height: 65,
//                       fit: BoxFit.cover,
//                       errorBuilder: (context, error, stackTrace) {
//                         return Container(
//                           width: 65,
//                           height: 65,
//                           color: Colors.grey.shade200,
//                           child: const Icon(Icons.person, color: Colors.grey),
//                         );
//                       },
//                     ),
//                   ),
//                 ),
//                 const SizedBox(width: 12.0),
//                 Expanded(
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Row(
//                         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                         children: [
//                           Row(
//                             children: [
//                               Text(
//                                 driver.name,
//                                 // Remove null safety since model is non-nullable
//                                 style: const TextStyle(
//                                   color: Color(0xFF6a0dad),
//                                   fontWeight: FontWeight.bold,
//                                   fontSize: 16.0,
//                                 ),
//                               ),
//                               if (driver.isVerified)
//                                 Padding(
//                                   padding: const EdgeInsets.symmetric(
//                                       horizontal: 8.0),
//                                   child: Icon(
//                                     size: 16,
//                                     Icons.verified_rounded,
//                                     color: Colors.blue,
//                                   ),
//                                 ),
//                             ],
//                           ),
//                           Container(
//                             padding: const EdgeInsets.symmetric(
//                                 horizontal: 6, vertical: 2),
//                             decoration: BoxDecoration(
//                               color: Colors.amber.shade50,
//                               borderRadius: BorderRadius.circular(12),
//                               border: Border.all(
//                                   color: Colors.amber.shade200, width: 0.5),
//                             ),
//                             child: Row(
//                               children: [
//                                 const Icon(Icons.star,
//                                     size: 14.0, color: Colors.amber),
//                                 const SizedBox(width: 2.0),
//                                 Text(
//                                   driver.rating.toString(),
//                                   style: TextStyle(
//                                     fontWeight: FontWeight.bold,
//                                     fontSize: 12.0,
//                                     color: Colors.amber.shade800,
//                                   ),
//                                 ),
//                               ],
//                             ),
//                           ),
//                         ],
//                       ),
//                       const SizedBox(height: 4.0),
//                       // Location
//                       Row(
//                         children: [
//                           Icon(Icons.location_on,
//                               size: 14.0, color: Colors.grey.shade600),
//                           const SizedBox(width: 2.0),
//                           Text(
//                             driver.address.city,
//                             // Remove null safety since model is non-nullable
//                             style: TextStyle(
//                               color: Colors.grey.shade600,
//                               fontSize: 12.0,
//                             ),
//                           ),
//                         ],
//                       ),
//                       const SizedBox(height: 4.0),
//                       // Price
//                       Row(
//                         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                         children: [
//                           RichText(
//                             text: TextSpan(
//                               style: DefaultTextStyle.of(context).style,
//                               children: [
//                                 TextSpan(
//                                   text: localizations.minimum_charges,
//                                   style: TextStyle(
//                                     color: Colors.grey.shade600,
//                                     fontSize: 12.0,
//                                   ),
//                                 ),
//                                 TextSpan(
//                                   text: ' ₹${driver.minimumCharges.toInt()}',
//                                   // Remove null safety since model is non-nullable
//                                   style: const TextStyle(
//                                     color: Color(0xFF4CAF50),
//                                     fontWeight: FontWeight.bold,
//                                     fontSize: 13.0,
//                                   ),
//                                 ),
//                               ],
//                             ),
//                           ),
//                           // Experience indicator
//                           Container(
//                             padding: const EdgeInsets.symmetric(
//                                 horizontal: 6, vertical: 2),
//                             decoration: BoxDecoration(
//                               color: Colors.blue.shade50,
//                               borderRadius: BorderRadius.circular(12),
//                               border: Border.all(
//                                   color: Colors.blue.shade200, width: 0.5),
//                             ),
//                             child: Row(
//                               children: [
//                                 const Icon(Icons.work,
//                                     size: 14.0, color: Colors.blue),
//                                 const SizedBox(width: 2.0),
//                                 Text(
//                                   localizations
//                                       .years_experience(driver.experience),
//                                   style: TextStyle(
//                                     fontWeight: FontWeight.bold,
//                                     fontSize: 12.0,
//                                     color: Colors.blue.shade800,
//                                   ),
//                                 ),
//                               ],
//                             ),
//                           ),
//                         ],
//                       ),
//                     ],
//                   ),
//                 ),
//               ],
//             ),
//           ),
//           Container(
//             padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
//             decoration: BoxDecoration(
//               color: Colors.grey.shade50,
//               borderRadius: const BorderRadius.only(
//                 bottomRight: Radius.circular(10),
//                 bottomLeft: Radius.circular(10),
//               ),
//             ),
//             child: Row(
//               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               children: [
//                 Row(
//                   children: [
//                     CustomActivity(
//                       baseUrl: ApiConstants.baseUrl,
//                       userId: driver.id,
//                       // Remove null safety since model is non-nullable
//                       icon: AssetsConstant.whatsApp,
//                       type: 'WHATSAPP',
//                       phone: driver.number,
//                       // Remove null safety since model is non-nullable
//                       activityType: ActivityType.WHATSAPP,
//                       userType: UserType.DRIVER,
//                     ),
//                     SizedBox(width: 5),
//                     CustomActivity(
//                       baseUrl: ApiConstants.baseUrl,
//                       userId: driver.userId,
//                       // Remove null safety since model is non-nullable
//                       icon: AssetsConstant.callPhone,
//                       type: 'PHONE',
//                       phone: driver.number,
//                       // Remove null safety since model is non-nullable
//                       activityType: ActivityType.PHONE,
//                       userType: UserType.DRIVER,
//                     ),
//                     SizedBox(width: 5),
//                     CustomActivity(
//                       baseUrl: ApiConstants.baseUrl,
//                       userId: driver.userId,
//                       // Remove null safety since model is non-nullable
//                       icon: AssetsConstant.chat,
//                       type: 'CHAT',
//                       phone: driver.number,
//                       // Remove null safety since model is non-nullable
//                       activityType: ActivityType.CHAT,
//                       userType: UserType.DRIVER,
//                     ),
//                   ],
//                 ),
//                 SizedBox(
//                   height: 32,
//                   child: ElevatedButton(
//                     onPressed: () async {
//                       try {
//                         print(
//                             '🔄 View More button pressed for driver: ${driver.name}');
//                         print('   Driver ID: ${driver.id}');
//                         print('   User ID: ${driver.userId}');
//
//                         bool success = await logUserActivity(
//                           id: driver.userId,
//                           activity: ActivityType.CLICK,
//                           type: UserType.DRIVER,
//                           baseUrl: ApiConstants.baseUrl,
//                         );
//
//                         if (success) {
//                           print("✅ Activity logged successfully");
//                         } else {
//                           print("❌ Failed to log activity");
//                           ScaffoldMessenger.of(context).showSnackBar(
//                             SnackBar(content: Text("Failed to log activity")),
//                           );
//                         }
//
//                         print('🚀 Navigating to OwnerDetailsScreen');
//                         Navigator.push(
//                           context,
//                           CupertinoPageRoute(
//                             builder: (context) => OwnerDetailsScreen(
//                               driverId: driver.id,
//                               userId: driver.userId,
//                             ),
//                           ),
//                         );
//                       } catch (e, stackTrace) {
//                         print('❌ Error in View More button: $e');
//                         print('❌ Stack trace: $stackTrace');
//                         ScaffoldMessenger.of(context).showSnackBar(
//                           SnackBar(content: Text("Error: $e")),
//                         );
//                       }
//                     },
//                     style: ElevatedButton.styleFrom(
//                       backgroundColor: ColorConstants.primaryColor,
//                       foregroundColor: ColorConstants.white,
//                       elevation: 1,
//                       padding: const EdgeInsets.symmetric(horizontal: 12.0),
//                       shape: RoundedRectangleBorder(
//                         borderRadius: BorderRadius.circular(8.0),
//                       ),
//                     ),
//                     child: Text(
//                       localizations.view_more,
//                       style: TextStyle(fontSize: 12),
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }