// import 'package:flutter/cupertino.dart';
// import 'package:flutter/material.dart';
// import 'package:r_w_r/screens/driver_screens/profile.dart';
// import 'package:r_w_r/screens/other/chat_history_list.dart';
//
// import '../../constants/color_constants.dart';
// import '../other/category_view.dart';
// import 'dashbord.dart';
// import 'driver_home.dart';
//
// class DriverLayout extends StatefulWidget {
//   final int initialIndex; // Add this parameter
//
//   const DriverLayout(
//       {super.key, this.initialIndex = 0}); // Default to first tab
//
//   @override
//   State<DriverLayout> createState() => _DriverLayoutState();
// }
//
// class _DriverLayoutState extends State<DriverLayout> {
//   late int _index; // Change to late
//   final List<Widget> _pages = [
//     DriverHome(),
//     DashboardScreen(),
//     GridViewExample(),
//     ChatHistoryPage(),
//     MyProfileScreen(),
//   ];
//
//   @override
//   void initState() {
//     super.initState();
//     _index = widget.initialIndex; // Initialize with provided index
//   }
//
//   void _onItemTapped(int index) {
//     setState(() {
//       _index = index;
//     });
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: _pages[_index],
//       bottomNavigationBar: Container(
//         decoration: BoxDecoration(
//           color: ColorConstants.white,
//           borderRadius: BorderRadius.only(
//             topLeft: Radius.circular(8),
//             topRight: Radius.circular(8),
//           ),
//           boxShadow: [
//             BoxShadow(
//               color: ColorConstants.black.withOpacity(0.3),
//               spreadRadius: 6,
//               blurRadius: 8,
//               offset: Offset(0, 5),
//             ),
//           ],
//         ),
//         child: ClipRRect(
//           borderRadius: BorderRadius.only(
//             topLeft: Radius.circular(12),
//             topRight: Radius.circular(12),
//           ),
//           child: BottomNavigationBar(
//             items: [
//               BottomNavigationBarItem(
//                 icon: Icon(CupertinoIcons.home, color: Colors.black),
//                 label: "Explore",
//                 activeIcon: Icon(CupertinoIcons.house_fill,
//                     color: ColorConstants.primaryColor),
//               ),
//               BottomNavigationBarItem(
//                 icon: Icon(Icons.dashboard_outlined, color: Colors.black),
//                 label: "Dashboard",
//                 activeIcon:
//                     Icon(Icons.dashboard, color: ColorConstants.primaryColor),
//               ),
//               BottomNavigationBarItem(
//                 icon: Icon(Icons.category_outlined, color: Colors.black),
//                 label: "Category",
//                 activeIcon:
//                     Icon(Icons.category, color: ColorConstants.primaryColor),
//               ),
//               BottomNavigationBarItem(
//                 icon:
//                     Icon(CupertinoIcons.chat_bubble_text, color: Colors.black),
//                 label: "message",
//                 activeIcon: Icon(CupertinoIcons.chat_bubble_text_fill,
//                     color: ColorConstants.primaryColor),
//               ),
//               BottomNavigationBarItem(
//                 icon: Icon(CupertinoIcons.ellipsis_circle, color: Colors.black),
//                 label: "Profile",
//                 activeIcon: Icon(CupertinoIcons.ellipsis_circle_fill,
//                     color: ColorConstants.primaryColor),
//               ),
//             ],
//             currentIndex: _index,
//             type: BottomNavigationBarType.fixed,
//             selectedItemColor: ColorConstants.primaryColor,
//             unselectedItemColor: Colors.black,
//             onTap: _onItemTapped,
//             elevation: 0,
//             showUnselectedLabels: true,
//             selectedFontSize: 14,
//             selectedIconTheme: IconThemeData(size: 28),
//             backgroundColor: Colors.white,
//           ),
//         ),
//       ),
//     );
//   }
// }
