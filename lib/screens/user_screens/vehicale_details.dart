// import 'package:flutter/material.dart';
// import 'package:r_w_r/constants/color_constants.dart';
//
// import 'chat/message.dart';
//
// class CarDetailScreen extends StatelessWidget {
//   const CarDetailScreen({super.key});
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: SafeArea(
//         child: Column(
//           children: [
//             Expanded(
//               child: SingleChildScrollView(
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     _buildHeader(context),
//                     _buildCarCarousel(),
//                     _buildThumbnails(),
//                     _buildSpecifications(),
//                     _buildCarFeatures(),
//                     _buildOwnerSection(context),
//                   ],
//                 ),
//               ),
//             ),
//             _buildPriceFooter(),
//           ],
//         ),
//       ),
//     );
//   }
//
//   Widget _buildHeader(BuildContext context) {
//     return Padding(
//       padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
//       child: Row(
//         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//         children: [
//           Row(
//             children: [
//               const BackButton(),
//               Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   RichText(
//                     text: const TextSpan(
//                       children: [
//                         TextSpan(
//                           text: 'Owner Name ',
//                           style: TextStyle(
//                             fontSize: 16,
//                             fontWeight: FontWeight.w600,
//                             color: Colors.purple,
//                           ),
//                         ),
//                         TextSpan(
//                           text: '(unique no.)',
//                           style: TextStyle(
//                             fontSize: 12,
//                             color: Colors.black54,
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                   Container(
//                     padding:
//                         const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
//                     decoration: BoxDecoration(
//                       color: const Color(0xFFFFB74D),
//                       borderRadius: BorderRadius.circular(12),
//                     ),
//                     child: Row(
//                       children: const [
//                         Icon(Icons.star, color: Colors.white, size: 14),
//                         SizedBox(width: 4),
//                         Text(
//                           '4.9',
//                           style: TextStyle(
//                             color: Colors.white,
//                             fontWeight: FontWeight.bold,
//                             fontSize: 12,
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                 ],
//               ),
//             ],
//           ),
//           Row(
//             spacing: 10,
//             children: [
//               Image.asset(
//                 "assets/img/Mask group (2).png",
//                 height: 40,
//                 width: 40,
//               ),
//               Image.asset(
//                 "assets/img/Mask group (1).png",
//                 height: 40,
//                 width: 40,
//               ),
//               GestureDetector(
//                 onTap: () {
//                   // Navigator.push(
//                   //     context,
//                   //     MaterialPageRoute(
//                   //         builder: (context) => MessagingScreen(
//                   //             userId: userId, cause: "DRIVER"
//                   //         )));
//                 },
//                 child: Image.asset(
//                   "assets/img/chat (2).png",
//                   height: 40,
//                   width: 40,
//                 ),
//               )
//             ],
//           ),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildContactButton(Color backgroundColor, IconData icon,
//       {required Color color}) {
//     return Container(
//       width: 36,
//       height: 36,
//       decoration: BoxDecoration(
//         color: backgroundColor,
//         borderRadius: BorderRadius.circular(8),
//       ),
//       child: Icon(
//         icon,
//         color: color,
//         size: 20,
//       ),
//     );
//   }
//
//   Widget _buildCarCarousel() {
//     return SizedBox(
//       height: 180,
//       child: Stack(
//         alignment: Alignment.center,
//         children: [
//           Image.network(
//             "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcSXowz1FO0-jzxik-RtD5SLyIb_w713QdyCGw&s",
//             fit: BoxFit.contain,
//             width: double.infinity,
//           ),
//           Positioned(
//             left: 16,
//             child: Container(
//               width: 30,
//               height: 30,
//               decoration: BoxDecoration(
//                 color: Colors.white.withOpacity(0.8),
//                 shape: BoxShape.circle,
//               ),
//               child: const Icon(Icons.chevron_left, size: 24),
//             ),
//           ),
//           Positioned(
//             right: 16,
//             child: Container(
//               width: 30,
//               height: 30,
//               decoration: BoxDecoration(
//                 color: Colors.white.withOpacity(0.8),
//                 shape: BoxShape.circle,
//               ),
//               child: const Icon(Icons.chevron_right, size: 24),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildThumbnails() {
//     return Padding(
//       padding: const EdgeInsets.symmetric(vertical: 16.0),
//       child: SingleChildScrollView(
//         scrollDirection: Axis.horizontal,
//         child: Row(
//           children: List.generate(
//             5,
//             (index) => Container(
//               margin: const EdgeInsets.only(left: 8.0),
//               width: 60,
//               height: 50,
//               decoration: BoxDecoration(
//                 borderRadius: BorderRadius.circular(8),
//                 border: Border.all(color: Colors.grey.shade200),
//                 image: DecorationImage(
//                   image: NetworkImage(
//                       'https://images.pexels.com/photos/170811/pexels-photo-170811.jpeg?auto=compress&cs=tinysrgb&w=1260&h=750&dpr=1'),
//                   fit: BoxFit.cover,
//                 ),
//               ),
//             ),
//           ).toList(),
//         ),
//       ),
//     );
//   }
//
//   Widget _buildSpecifications() {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         const Padding(
//           padding: EdgeInsets.symmetric(horizontal: 16.0),
//           child: Text(
//             'Specifications',
//             style: TextStyle(
//               fontSize: 18,
//               fontWeight: FontWeight.bold,
//               color: Colors.black87,
//             ),
//           ),
//         ),
//         const SizedBox(height: 16),
//         Row(
//           mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//           children: [
//             _buildSpecCard(Icons.bolt, 'Max Power', '320 hp'),
//             _buildSpecCard(Icons.local_gas_station, 'Fuel', 'Petrol'),
//             _buildSpecCard(Icons.speed, '0-60 mph', '2.6 sec'),
//             _buildSpecCard(Icons.shutter_speed, 'Max Speed', '177 mph'),
//           ],
//         ),
//       ],
//     );
//   }
//
//   Widget _buildSpecCard(IconData icon, String title, String value) {
//     return Container(
//       width: 80,
//       padding: const EdgeInsets.all(8),
//       decoration: BoxDecoration(
//         border: Border.all(color: Colors.grey.shade300),
//         borderRadius: BorderRadius.circular(8),
//       ),
//       child: Column(
//         children: [
//           Icon(icon, color: Colors.blue.shade700, size: 20),
//           const SizedBox(height: 4),
//           Text(
//             title,
//             style: TextStyle(fontSize: 12, color: Colors.grey.shade700),
//             textAlign: TextAlign.center,
//           ),
//           const SizedBox(height: 2),
//           Text(
//             value,
//             style: const TextStyle(
//               fontSize: 12,
//               fontWeight: FontWeight.bold,
//             ),
//             textAlign: TextAlign.center,
//           ),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildCarFeatures() {
//     return Padding(
//       padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           const Text(
//             'Car Features',
//             style: TextStyle(
//               fontSize: 18,
//               fontWeight: FontWeight.bold,
//               color: Colors.black87,
//             ),
//           ),
//           const SizedBox(height: 16),
//           _buildFeatureItem(Icons.person, 'Owner Name - Shivangi'),
//           _buildFeatureItem(Icons.directions_car, 'Model Name - XUV'),
//           _buildFeatureItem(
//               Icons.calendar_today, 'Manufacture Date - 20 Jan 2024'),
//           _buildFeatureItem(
//               Icons.settings, 'Specifications (in Detail) - Snow Wheel'),
//           _buildFeatureItem(Icons.air, 'Vehicle Specification - AC'),
//           _buildFeatureItem(
//               Icons.bluetooth, 'Vehicle Specification - Bluetooth'),
//           _buildFeatureItem(Icons.gps_fixed, 'Vehicle Specification - GPS'),
//           _buildFeatureItem(Icons.confirmation_number, 'Vehicle No. - 76543'),
//           _buildFeatureItem(Icons.map, 'Tour - Gurugram, Noida'),
//           _buildFeatureItem(Icons.location_city, 'Gurgaon'),
//           _buildFeatureItem(Icons.directions_car_filled, 'Vehicle Count - 10'),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildFeatureItem(IconData icon, String text) {
//     return Padding(
//       padding: const EdgeInsets.symmetric(vertical: 8.0),
//       child: Row(
//         children: [
//           Icon(icon, color: Colors.green, size: 20),
//           const SizedBox(width: 16),
//           Text(
//             text,
//             style: const TextStyle(
//               fontSize: 14,
//               color: Colors.black87,
//             ),
//           ),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildOwnerSection(BuildContext context) {
//     return Container(
//       margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
//       padding: const EdgeInsets.all(12.0),
//       decoration: BoxDecoration(
//         border: Border.all(color: Colors.grey.shade300),
//         borderRadius: BorderRadius.circular(8),
//       ),
//       child: Row(
//         children: [
//           ClipRRect(
//             borderRadius: BorderRadius.circular(8),
//             child: Image.network(
//               'https://thispersondoesnotexist.com/',
//               width: 100,
//               height: 100,
//               fit: BoxFit.cover,
//             ),
//           ),
//           const SizedBox(width: 16),
//           Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               const Text(
//                 'Owner Name',
//                 style: TextStyle(
//                   fontSize: 14,
//                   fontWeight: FontWeight.w500,
//                 ),
//               ),
//               const SizedBox(height: 8),
//               ElevatedButton(
//                 onPressed: () {
//                   // Navigator.push(
//                   //     context,
//                   //     MaterialPageRoute(
//                   //         builder: (context) => OwnerDetailsScreen(
//                   //               driverId: '682adb1e167d649ee281fcb6',
//                   //             )));
//                 },
//                 style: ElevatedButton.styleFrom(
//                   backgroundColor: ColorConstants.primaryColor,
//                   shape: RoundedRectangleBorder(
//                     borderRadius: BorderRadius.circular(16),
//                   ),
//                   padding:
//                       const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
//                   minimumSize: const Size(0, 30),
//                 ),
//                 child: Text(
//                   'View Profile',
//                   style: TextStyle(fontSize: 12, color: ColorConstants.white),
//                 ),
//               ),
//             ],
//           ),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildPriceFooter() {
//     return Container(
//       padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
//       decoration: const BoxDecoration(
//         color: Colors.black,
//       ),
//       child: Column(
//         children: [
//           Row(
//             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//             children: const [
//               Text(
//                 'Price',
//                 style: TextStyle(
//                   fontSize: 18,
//                   color: Colors.green,
//                   fontWeight: FontWeight.bold,
//                 ),
//               ),
//               Text(
//                 '\$250/Day',
//                 style: TextStyle(
//                   fontSize: 18,
//                   color: Colors.white,
//                   fontWeight: FontWeight.bold,
//                 ),
//               ),
//             ],
//           ),
//           const SizedBox(height: 16),
//           Container(
//             width: 100,
//             height: 5,
//             decoration: BoxDecoration(
//               color: Colors.white,
//               borderRadius: BorderRadius.circular(4),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
