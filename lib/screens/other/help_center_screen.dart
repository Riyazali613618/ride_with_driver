// import 'package:flutter/material.dart';
//
//
// class HelpCenterScreen extends StatefulWidget {
//   const HelpCenterScreen({super.key});
//
//   @override
//   State<HelpCenterScreen> createState() => _HelpCenterScreenState();
// }
//
// class _HelpCenterScreenState extends State<HelpCenterScreen>
//     with SingleTickerProviderStateMixin {
//   late TabController _tabController;
//
//   late List<HelpCenterModel> _helpCenterData;
//
//   bool _isLoading = true;
//
//   String _errorMessage = '';
//
//   @override
//   void initState() {
//     super.initState();
//     _tabController =
//         TabController(length: 3, vsync: this); // Updated length to 3
//     _fetchHelpCenterData();
//   }
//
//   Future<void> _fetchHelpCenterData() async {
//     try {
//       HelpCenterService service = HelpCenterService();
//       final data = await service.fetchHelpCenterData();
//       setState(() {
//         _helpCenterData = data;
//         _isLoading = false;
//       });
//     } catch (e) {
//       setState(() {
//         _errorMessage = e.toString();
//         _isLoading = false;
//       });
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: const Color(0xFF002B5C),
//       body: SafeArea(
//         child: Column(
//           children: [
//             _buildAppBar(context),
//             Expanded(
//               child: SingleChildScrollView(
//                 child: Column(
//                   children: [
//                     _buildHeader(),
//                     Padding(
//                       padding: const EdgeInsets.symmetric(horizontal: 16.0),
//                       child: _buildSearchBar(),
//                     ),
//                     const SizedBox(height: 20),
//                     Padding(
//                       padding: const EdgeInsets.symmetric(
//                         horizontal: 16.0,
//                       ),
//                       child: _buildTabSection(context),
//                     ), // Passing context here
//                   ],
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
//
//   Widget _buildAppBar(BuildContext context) {
//     return Container(
//       height: kToolbarHeight,
//       padding: const EdgeInsets.symmetric(horizontal: 4),
//       child: Row(
//         children: [
//           IconButton(
//             icon: const Icon(Icons.arrow_back, color: Colors.white),
//             onPressed: () => Navigator.pop(context),
//           ),
//           const Text(
//             'Help Center',
//             style: TextStyle(
//               color: Colors.white,
//               fontSize: 20,
//               fontWeight: FontWeight.w500,
//             ),
//           ),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildHeader() {
//     return Padding(
//       padding: const EdgeInsets.all(20),
//       child: Row(
//         children: [
//           Container(
//             width: 100,
//             height: 100,
//             decoration: BoxDecoration(
//               color: Colors.grey[200],
//               borderRadius: BorderRadius.circular(8),
//             ),
//             child: const Icon(Icons.help_outline, size: 50),
//           ),
//           const SizedBox(width: 20),
//           const Expanded(
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(
//                   'Have Questions?',
//                   style: TextStyle(
//                     color: Colors.white,
//                     fontSize: 24,
//                     fontWeight: FontWeight.bold,
//                   ),
//                 ),
//                 Text(
//                   'Get Instant Answers Here!',
//                   style: TextStyle(
//                     color: Colors.white,
//                     fontSize: 24,
//                     fontWeight: FontWeight.bold,
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildSearchBar() {
//     return CustomTextField(
//       hintText: 'Search',
//       prefixIcon: Icons.search,
//     );
//   }
//
//   Widget _buildTabSection(BuildContext context) {
//     // Added context parameter
//     return Container(
//       decoration: const BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.only(
//           topLeft: Radius.circular(20),
//           topRight: Radius.circular(20),
//         ),
//       ),
//       child: DefaultTabController(
//         length: 3,
//         child: Column(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             TabBar(
//               controller: _tabController,
//               tabs: [
//                 Tab(text: 'All'),
//                 Tab(text: 'App'),
//                 Tab(text: 'Billing'),
//               ],
//               labelColor: Colors.blue,
//               unselectedLabelColor: Colors.grey,
//               indicatorSize: TabBarIndicatorSize.label,
//               dividerColor: appGreyColor.withOpacity(0.2),
//             ),
//             SizedBox(
//               height: MediaQuery.of(context).size.height * 0.8,
//               child: TabBarView(
//                 controller: _tabController,
//                 children: [
//                   _buildAllHelpList(),
//                   _buildHelpList('App'),
//                   _buildHelpList('Billing'),
//                 ],
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
//
//   Widget _buildHelpList(String category) {
//     final filteredData = _helpCenterData
//         .firstWhere((element) => element.category == category)
//         .helps;
//
//     return ListView.builder(
//       padding: EdgeInsets.zero,
//       itemCount: filteredData.length,
//       itemBuilder: (context, index) {
//         final helpItem = filteredData[index];
//
//         return Padding(
//           padding: const EdgeInsets.all(8.0),
//           child: Card(
//             elevation: 0,
//             color: const Color(0xFFF5F7FF),
//             margin: const EdgeInsets.only(bottom: 12),
//             shape: RoundedRectangleBorder(
//               borderRadius: BorderRadius.circular(12),
//             ),
//             child: ListTile(
//               onTap: () {
//                 _sendEmail(helpItem.title, helpItem.message);
//               },
//               title: Text(
//                 helpItem.title,
//                 style: const TextStyle(
//                   fontWeight: FontWeight.w600,
//                   fontSize: 16,
//                 ),
//               ),
//               subtitle: Text(
//                 helpItem.message,
//                 style: TextStyle(
//                   color: Colors.grey[600],
//                   fontSize: 14,
//                 ),
//               ),
//               trailing: GestureDetector(
//                 onTap: () {
//                   _sendEmail(helpItem.title, helpItem.message);
//                 },
//                 child: const Icon(
//                   Icons.arrow_forward_ios,
//                   color: Colors.blue,
//                   size: 16,
//                 ),
//               ),
//             ),
//           ),
//         );
//       },
//     );
//   }
//
//    void _sendEmail(String subject, String body) async {
//     final Uri emailUri = Uri(
//       scheme: 'mailto',
//       path: 'support@exaministry.com',
//       queryParameters: {
//         'subject': subject,
//         'body': body,
//       },
//     );
//
//     try {
//       if (await canLaunchUrl(emailUri)) {
//         await launchUrl(emailUri);
//       } else {
//         ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(
//             content: Text('Could not launch email client'),
//             backgroundColor: Colors.red,
//           ),
//         );
//       }
//     } catch (e) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(
//           content: Text('Error launching email: ${e.toString()}'),
//           backgroundColor: Colors.red,
//         ),
//       );
//     }
//   }
//
//   // Fixed all help list with email functionality
//   Widget _buildAllHelpList() {
//     if (_isLoading) {
//       return const Center(child: CircularProgressIndicator());
//     }
//
//     if (_errorMessage.isNotEmpty) {
//       return Center(child: Text('Error: $_errorMessage', style: const TextStyle(color: Colors.red)));
//     }
//
//     final allData = _helpCenterData.expand((element) => element.helps).toList();
//
//     return ListView.builder(
//       padding: EdgeInsets.zero,
//       itemCount: allData.length,
//       itemBuilder: (context, index) {
//         final helpItem = allData[index];
//         return Padding(
//           padding: const EdgeInsets.all(8.0),
//           child: Card(
//             elevation: 0,
//             color: const Color(0xFFF5F7FF),
//             margin: const EdgeInsets.only(bottom: 12),
//             shape: RoundedRectangleBorder(
//               borderRadius: BorderRadius.circular(12),
//             ),
//             child: ListTile(
//               onTap: () {
//                 _sendEmail(helpItem.title, helpItem.message);
//               },
//               title: Text(
//                 helpItem.title,
//                 style: const TextStyle(
//                   fontWeight: FontWeight.w600,
//                   fontSize: 16,
//                 ),
//               ),
//               subtitle: Text(
//                 helpItem.message,
//                 style: TextStyle(
//                   color: Colors.grey[600],
//                   fontSize: 14,
//                 ),
//               ),
//               trailing: GestureDetector(
//                 onTap: () {
//                   _sendEmail(helpItem.title, helpItem.message);
//                 },
//                 child: const Icon(
//                   Icons.arrow_forward_ios,
//                   color: Colors.blue,
//                   size: 16,
//                 ),
//               ),
//             ),
//           ),
//         );
//       },
//     );
//   }
// }
