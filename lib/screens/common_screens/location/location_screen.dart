// import 'dart:convert';
//
// import 'package:flutter/material.dart';
// import 'package:http/http.dart' as http;
//
// class LocationSearchScreen extends StatefulWidget {
//   @override
//   _LocationSearchScreenState createState() => _LocationSearchScreenState();
// }
//
// class _LocationSearchScreenState extends State<LocationSearchScreen> {
//   final TextEditingController _controller = TextEditingController();
//   List<dynamic> _suggestions = [];
//   bool _isLoading = false;
//   String _selectedLocationInfo = '';
//
//   final String _apiKey = 'AIzaSyDUkuN7zD7ApTqkkEyzOXnS_LDxEzP-t40';
//
//   Future<void> _searchPlace(String input) async {
//     if (input.isEmpty) {
//       setState(() {
//         _suggestions = [];
//       });
//       return;
//     }
//
//     setState(() => _isLoading = true);
//
//     final url =
//         Uri.parse('https://places.googleapis.com/v1/places:autocomplete');
//
//     final headers = {
//       'Content-Type': 'application/json',
//       'X-Goog-Api-Key': _apiKey,
//       'X-Goog-FieldMask': '*',
//     };
//
//     final body = jsonEncode({
//       "input": input,
//     });
//
//     try {
//       final response = await http.post(url, headers: headers, body: body);
//
//       if (response.statusCode == 200) {
//         final data = jsonDecode(response.body);
//         setState(() {
//           _suggestions = data['suggestions'];
//         });
//       } else {
//         print('Error ${response.statusCode}: ${response.body}');
//         setState(() {
//           _suggestions = [];
//         });
//       }
//     } catch (e) {
//       print('Exception: $e');
//       setState(() {
//         _suggestions = [];
//       });
//     } finally {
//       setState(() => _isLoading = false);
//     }
//   }
//
//   Future<void> _getPlaceDetails(String placeId) async {
//     setState(() => _isLoading = true);
//
//     final url = Uri.parse('https://places.googleapis.com/v1/places/$placeId');
//
//     final headers = {
//       'Content-Type': 'application/json',
//       'X-Goog-Api-Key': _apiKey,
//       'X-Goog-FieldMask': 'location,addressComponents,formattedAddress',
//     };
//
//     try {
//       final response = await http.get(url, headers: headers);
//
//       if (response.statusCode == 200) {
//         final data = jsonDecode(response.body);
//
//         // Extract latitude and longitude
//         final location = data['location'];
//         final double latitude = location['latitude'];
//         final double longitude = location['longitude'];
//
//         // Extract pin code from address components
//         String pinCode = 'Not found';
//         final addressComponents = data['addressComponents'] as List<dynamic>?;
//
//         if (addressComponents != null) {
//           for (var component in addressComponents) {
//             final types = component['types'] as List<dynamic>;
//             if (types.contains('postal_code')) {
//               pinCode = component['longText'];
//               break;
//             }
//           }
//         }
//
//         final formattedAddress =
//             data['formattedAddress'] ?? 'Address not available';
//
//         // Print to console
//         print('=== Selected Location Details ===');
//         print('Place ID: $placeId');
//         print('Formatted Address: $formattedAddress');
//         print('Latitude: $latitude');
//         print('Longitude: $longitude');
//         print('Pin Code: $pinCode');
//         print('================================');
//
//         // Update UI
//         setState(() {
//           _selectedLocationInfo = '''
// Selected Location Details:
//
// Address: $formattedAddress
//
// Latitude: $latitude
// Longitude: $longitude
// Pin Code: $pinCode
//           ''';
//         });
//       } else {
//         print(
//             'Error fetching place details ${response.statusCode}: ${response.body}');
//         setState(() {
//           _selectedLocationInfo = 'Error fetching location details';
//         });
//       }
//     } catch (e) {
//       print('Exception fetching place details: $e');
//       setState(() {
//         _selectedLocationInfo = 'Error: $e';
//       });
//     } finally {
//       setState(() => _isLoading = false);
//     }
//   }
//
//   Widget _buildSuggestionItem(dynamic item) {
//     final mainText =
//         item['placePrediction']['structuredFormat']['mainText']['text'];
//     final secondaryText =
//         item['placePrediction']['structuredFormat']['secondaryText']['text'];
//
//     return ListTile(
//       title: Text(mainText),
//       subtitle: Text(secondaryText),
//       onTap: () {
//         final placeId = item['placePrediction']['placeId'];
//         print('Selected Place ID: $placeId');
//
//         // Clear suggestions and get place details
//         setState(() {
//           _suggestions = [];
//           _controller.text = '$mainText, $secondaryText';
//         });
//
//         // Fetch detailed information
//         _getPlaceDetails(placeId);
//       },
//     );
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: Text('Search Location')),
//       body: Padding(
//         padding: const EdgeInsets.all(12.0),
//         child: Column(
//           children: [
//             TextField(
//               controller: _controller,
//               decoration: InputDecoration(
//                 hintText: 'Search for a location...',
//                 suffixIcon: _isLoading
//                     ? Padding(
//                         padding: const EdgeInsets.all(10.0),
//                         child: SizedBox(
//                           width: 20,
//                           height: 20,
//                           child: CircularProgressIndicator(strokeWidth: 2),
//                         ),
//                       )
//                     : IconButton(
//                         icon: Icon(Icons.search),
//                         onPressed: () => _searchPlace(_controller.text),
//                       ),
//               ),
//               onChanged: (value) => _searchPlace(value),
//             ),
//             SizedBox(height: 12),
//             if (_selectedLocationInfo.isNotEmpty) ...[
//               Container(
//                 width: double.infinity,
//                 padding: EdgeInsets.all(16),
//                 margin: EdgeInsets.only(bottom: 12),
//                 decoration: BoxDecoration(
//                   color: Colors.blue.shade50,
//                   border: Border.all(color: Colors.blue.shade200),
//                   borderRadius: BorderRadius.circular(8),
//                 ),
//                 child: Text(
//                   _selectedLocationInfo,
//                   style: TextStyle(
//                     fontSize: 14,
//                     fontFamily: 'monospace',
//                   ),
//                 ),
//               ),
//             ],
//             Expanded(
//               child: _suggestions.isEmpty
//                   ? Center(
//                       child: Text(
//                       _selectedLocationInfo.isEmpty
//                           ? 'Search for a location to see suggestions'
//                           : 'Search for another location',
//                     ))
//                   : ListView.builder(
//                       itemCount: _suggestions.length,
//                       itemBuilder: (context, index) {
//                         return _buildSuggestionItem(_suggestions[index]);
//                       },
//                     ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
// import 'package:flutter/material.dart';
//
// import '../../../components/custtom_location_widget.dart';
//
// class LocationChip extends StatelessWidget {
//   /// The main text displayed on the chip, typically the location name.
//   final String label;
//
//   /// Additional info (e.g., address details) shown as a subtitle, optional.
//   final String? secondaryLabel;
//
//   /// Callback when the delete/remove icon is tapped. Optional.
//   final VoidCallback? onDeleted;
//
//   /// Optional: Whether the chip is currently selected (for styling).
//   final bool selected;
//
//   /// Optional: Icon to show on the left (e.g., a location pin).
//   final IconData? icon;
//
//   /// Optional: Custom chip color.
//   final Color? color;
//
//   /// Optional: Custom text color.
//   final Color? textColor;
//
//   const LocationChip({
//     Key? key,
//     required this.label,
//     this.secondaryLabel,
//     this.onDeleted,
//     this.selected = false,
//     this.icon,
//     this.color,
//     this.textColor,
//   }) : super(key: key);
//
//   @override
//   Widget build(BuildContext context) {
//     final chipColor =
//         color ?? (selected ? Colors.blue.shade50 : Colors.grey.shade200);
//     final labelStyle = TextStyle(
//       color:
//           textColor ?? (selected ? Colors.blue.shade900 : Colors.grey.shade800),
//       fontWeight: FontWeight.w600,
//     );
//     return Container(
//       margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
//       child: Material(
//         color: chipColor,
//         elevation: selected ? 2 : 0,
//         borderRadius: BorderRadius.circular(18),
//         child: InkWell(
//           borderRadius: BorderRadius.circular(18),
//           onTap: onDeleted == null ? null : () {}, // Optionally handle chip tap
//           child: Padding(
//             padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
//             child: Row(
//               mainAxisSize: MainAxisSize.min,
//               children: [
//                 if (icon != null)
//                   Padding(
//                     padding: const EdgeInsets.only(right: 6),
//                     child: Icon(icon, size: 18, color: labelStyle.color),
//                   ),
//                 Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Text(label, style: labelStyle),
//                     if (secondaryLabel != null && secondaryLabel!.isNotEmpty)
//                       Text(
//                         secondaryLabel!,
//                         style: TextStyle(
//                           color: labelStyle.color?.withOpacity(0.7),
//                           fontWeight: FontWeight.w400,
//                           fontSize: 12,
//                         ),
//                         maxLines: 1,
//                         overflow: TextOverflow.ellipsis,
//                       ),
//                   ],
//                 ),
//                 if (onDeleted != null)
//                   Padding(
//                     padding: const EdgeInsets.only(left: 6),
//                     child: InkWell(
//                       borderRadius: BorderRadius.circular(12),
//                       onTap: onDeleted,
//                       child:
//                           Icon(Icons.close, size: 18, color: labelStyle.color),
//                     ),
//                   ),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }
//
// class LocationChipSearchDemoScreen extends StatefulWidget {
//   const LocationChipSearchDemoScreen({Key? key}) : super(key: key);
//
//   @override
//   State<LocationChipSearchDemoScreen> createState() =>
//       _LocationChipSearchDemoScreenState();
// }
//
// class _LocationChipSearchDemoScreenState
//     extends State<LocationChipSearchDemoScreen> {
//   final TextEditingController _controller = TextEditingController();
//   final FocusNode _focusNode = FocusNode();
//   List<LocationData> selectedLocations = [];
//   // Mock suggestions for demonstration
//   final List<Map<String, String>> allSuggestions = [];
//
//   String? selectedLabel;
//   String? selectedDetails;
//   List<Map<String, String>> filteredSuggestions = [];
//   bool showSuggestions = false;
//
//   @override
//   void initState() {
//     super.initState();
//     _controller.addListener(_onSearchChanged);
//     _focusNode.addListener(() {
//       if (_focusNode.hasFocus && _controller.text.isNotEmpty) {
//         setState(() => showSuggestions = true);
//       }
//     });
//   }
//
//   void _onSearchChanged() {
//     final text = _controller.text.trim();
//     if (text.isEmpty) {
//       setState(() {
//         filteredSuggestions = [];
//         showSuggestions = false;
//       });
//       return;
//     }
//     setState(() {
//       filteredSuggestions = allSuggestions
//           .where((s) => s["label"]!.toLowerCase().contains(text.toLowerCase()))
//           .toList();
//       showSuggestions = filteredSuggestions.isNotEmpty;
//     });
//   }
//
//   void _selectSuggestion(Map<String, String> suggestion) {
//     setState(() {
//       selectedLabel = suggestion["label"];
//       selectedDetails = suggestion["details"];
//       _controller.clear();
//       showSuggestions = false;
//     });
//     _focusNode.unfocus();
//   }
//
//   void _removeSelectedLocation() {
//     setState(() {
//       selectedLabel = null;
//       selectedDetails = null;
//     });
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: const Color(0xfff7f9fb),
//       appBar: AppBar(
//         title: const Text("Beautiful Location Chip Search"),
//         backgroundColor: Colors.deepPurple,
//       ),
//       body: GestureDetector(
//         onTap: () => FocusScope.of(context).unfocus(),
//         child: Center(
//           child: SingleChildScrollView(
//             child: Container(
//               padding: const EdgeInsets.all(24),
//               constraints: const BoxConstraints(maxWidth: 420),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   const Text(
//                     "Where do you want to go?",
//                     style: TextStyle(
//                       fontWeight: FontWeight.bold,
//                       fontSize: 26,
//                       color: Color(0xff2c175a),
//                     ),
//                   ),
//                   const SizedBox(height: 18),
//                   // Search Box with Chip
//                   Material(
//                     elevation: 3,
//                     borderRadius: BorderRadius.circular(14),
//                     child: Container(
//                       padding: const EdgeInsets.symmetric(
//                           horizontal: 12, vertical: 4),
//                       decoration: BoxDecoration(
//                         color: Colors.white,
//                         borderRadius: BorderRadius.circular(14),
//                       ),
//                       child: selectedLabel == null
//                           ? TextField(
//                               controller: _controller,
//                               focusNode: _focusNode,
//                               style: const TextStyle(fontSize: 16),
//                               decoration: InputDecoration(
//                                 border: InputBorder.none,
//                                 hintText: "Search location...",
//                                 prefixIcon: Icon(Icons.search,
//                                     color: Colors.deepPurple.shade400),
//                               ),
//                               onChanged: (_) => _onSearchChanged(),
//                               onTap: () {
//                                 if (_controller.text.isNotEmpty) {
//                                   setState(() => showSuggestions = true);
//                                 }
//                               },
//                             )
//                           : Row(
//                               children: [
//                                 Flexible(
//                                   child: LocationChip(
//                                     label: selectedLabel!,
//                                     secondaryLabel: selectedDetails,
//                                     icon: Icons.location_on,
//                                     selected: true,
//                                     onDeleted: _removeSelectedLocation,
//                                     color: Colors.deepPurple.shade50,
//                                     textColor: Colors.deepPurple.shade800,
//                                   ),
//                                 ),
//                               ],
//                             ),
//                     ),
//                   ),
//                   // Suggestions Dropdown
//                   if (showSuggestions && filteredSuggestions.isNotEmpty)
//                     Container(
//                       margin: const EdgeInsets.only(top: 2),
//                       decoration: BoxDecoration(
//                         color: Colors.white,
//                         borderRadius: BorderRadius.circular(12),
//                         boxShadow: [
//                           BoxShadow(
//                             color: Colors.black.withOpacity(0.06),
//                             blurRadius: 5,
//                             offset: const Offset(0, 3),
//                           ),
//                         ],
//                       ),
//                       child: ListView.separated(
//                         shrinkWrap: true,
//                         itemCount: filteredSuggestions.length,
//                         separatorBuilder: (_, __) =>
//                             Divider(height: 1, color: Colors.grey.shade200),
//                         itemBuilder: (context, index) {
//                           final suggestion = filteredSuggestions[index];
//                           return ListTile(
//                             leading: const Icon(Icons.location_on,
//                                 color: Colors.deepPurple),
//                             title: Text(suggestion["label"]!,
//                                 style: const TextStyle(
//                                     fontWeight: FontWeight.w600)),
//                             subtitle: Text(suggestion["details"]!),
//                             onTap: () => _selectSuggestion(suggestion),
//                           );
//                         },
//                       ),
//                     ),
//                   const SizedBox(height: 40),
//                   if (selectedLabel != null)
//                     Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         Text("Selected Location:",
//                             style: TextStyle(
//                                 color: Colors.deepPurple.shade600,
//                                 fontWeight: FontWeight.bold,
//                                 fontSize: 15)),
//                         const SizedBox(height: 10),
//                         LocationChip(
//                           label: selectedLabel!,
//                           secondaryLabel: selectedDetails,
//                           icon: Icons.location_on,
//                           selected: true,
//                           onDeleted: _removeSelectedLocation,
//                           color: Colors.deepPurple.shade100,
//                           textColor: Colors.deepPurple.shade900,
//                         ),
//                       ],
//                     ),
//                   if (selectedLabel == null)
//                     Padding(
//                       padding: const EdgeInsets.only(top: 24),
//                       child: Text(
//                         "Tip: Start typing a location above, then select one from the suggestions.",
//                         style: TextStyle(color: Colors.grey.shade600),
//                       ),
//                     ),
//
//                   ElevatedButton(
//                       onPressed: () {
//                         Navigator.push(
//                             context,
//                             MaterialPageRoute(
//                                 builder: (context) => LocationFormExample()));
//                       },
//                       child: Text("hjsdf"))
//                 ],
//               ),
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }
