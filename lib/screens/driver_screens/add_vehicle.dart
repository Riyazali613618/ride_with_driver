// import 'package:flutter/cupertino.dart';
// import 'package:flutter/material.dart';
// import 'package:r_w_r/components/app_appbar.dart';
//
// import '../../components/dotted_border.dart';
// import '../../constants/color_constants.dart';
//
// class AddVehicleScreen extends StatefulWidget {
//   const AddVehicleScreen({Key? key}) : super(key: key);
//
//   @override
//   State<AddVehicleScreen> createState() => _AddVehicleScreenState();
// }
//
// class _AddVehicleScreenState extends State<AddVehicleScreen> {
//   final TextEditingController _vehicleNameController =
//       TextEditingController(text: '12345ASD12');
//   final TextEditingController _vehicleModelController =
//       TextEditingController(text: '12345ASD12');
//   final TextEditingController _manufacturingController =
//       TextEditingController(text: '12345ASD12');
//   final TextEditingController _minimumChargeController =
//       TextEditingController(text: '1000');
//
//   String selectedMaxPower = 'SUV';
//   String selectedFuelType = 'Petrol';
//   String selectedMileage = 'Petrol';
//   String selectedRegistrationDate = 'Petrol';
//   String selectedVehicleNo = 'Petrol';
//   String selectedVehicleSpec1 = 'GPS';
//   String selectedVehicleSpec2 = 'AC';
//   String selectedLocation = 'Gurugram, Delhi';
//   String selectedCurrency = 'INR';
//
//   List<FileUploadItem> uploadedFiles = [
//     FileUploadItem('Car Image_JPEG', '200 KB', 0.4),
//   ];
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.white,
//       appBar: CustomAppBar(
//         leading: CupertinoNavigationBarBackButton(
//           color: ColorConstants.white,
//         ),
//         title: 'Add Vehicle',
//         centerTitle: false,
//         titleTextStyle: TextStyle(
//             color: ColorConstants.white,
//             fontSize: 16,
//             fontWeight: FontWeight.w600),
//       ),
//       body: SingleChildScrollView(
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             _buildFileUploadSection(),
//             Padding(
//               padding: const EdgeInsets.symmetric(horizontal: 16),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   _buildFormFields(),
//                 ],
//               ),
//             ),
//             SizedBox(
//               width: double.infinity,
//               child: Padding(
//                 padding: const EdgeInsets.all(8.0),
//                 child: ElevatedButton(
//                   onPressed: () {
//                     Navigator.pop(context);
//                   },
//                   style: ElevatedButton.styleFrom(
//                     backgroundColor: ColorConstants.primaryColor,
//                     padding: const EdgeInsets.symmetric(
//                       vertical: 16,
//                     ),
//                     shape: RoundedRectangleBorder(
//                       borderRadius: BorderRadius.circular(30),
//                     ),
//                   ),
//                   child: const Text(
//                     'Save',
//                     style: TextStyle(
//                       fontSize: 16,
//                       color: ColorConstants.white,
//                       fontWeight: FontWeight.w600,
//                     ),
//                   ),
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
//
//   Widget _buildFileUploadSection() {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         _buildUploadContainer(),
//         const SizedBox(height: 8),
//         ...uploadedFiles.map((file) => _buildUploadedFile(file)).toList(),
//       ],
//     );
//   }
//
//   Widget _buildUploadContainer() {
//     return Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: CustomPaint(
//           isComplex: true,
//           painter: DottedBorderPainter(),
//           child: Container(
//               height: 120.0,
//               width: double.maxFinite,
//               decoration: BoxDecoration(
//                 borderRadius: BorderRadius.circular(8.0),
//               ),
//               child: InkWell(
//                 child: Column(
//                   mainAxisAlignment: MainAxisAlignment.center,
//                   children: [
//                     Container(
//                       padding: const EdgeInsets.all(8.0),
//                       decoration: BoxDecoration(
//                         color: ColorConstants.greyLight.withAlpha(100),
//                         shape: BoxShape.circle,
//                       ),
//                       child: Icon(
//                         CupertinoIcons.cloud_upload,
//                         color: ColorConstants.primaryColor,
//                         size: 24.0,
//                       ),
//                     ),
//                     const SizedBox(height: 8.0),
//                     RichText(
//                       text: TextSpan(
//                         style: TextStyle(letterSpacing: 1, wordSpacing: 1),
//                         children: [
//                           TextSpan(
//                             text: 'Click to Upload',
//                             style: TextStyle(
//                               color: ColorConstants.primaryColor,
//                               fontWeight: FontWeight.w600,
//                             ),
//                           ),
//                           const TextSpan(
//                             text: ' or drag and drop',
//                             style: TextStyle(
//                               color: Colors.black54,
//                               fontWeight: FontWeight.w600,
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),
//                     const SizedBox(height: 5.0),
//                     const Text(
//                       '(Max. File size: 25 MB)',
//                       style: TextStyle(
//                         fontWeight: FontWeight.w600,
//                         color: Colors.black54,
//                         fontSize: 12.0,
//                       ),
//                     ),
//                   ],
//                 ),
//               )),
//         ));
//   }
//
//   Widget _buildUploadedFile(FileUploadItem file) {
//     return Container(
//       margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
//       padding: const EdgeInsets.all(12),
//       decoration: BoxDecoration(
//         border: Border.all(color: Colors.grey[300]!),
//         borderRadius: BorderRadius.circular(8),
//       ),
//       child: Row(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           const Icon(CupertinoIcons.doc_text),
//           const SizedBox(width: 12),
//           Expanded(
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(
//                   file.name,
//                   style: const TextStyle(
//                     fontSize: 14,
//                     fontWeight: FontWeight.w500,
//                   ),
//                 ),
//                 Text(
//                   file.size,
//                   style: TextStyle(
//                     color: Colors.grey[600],
//                     fontSize: 12,
//                   ),
//                 ),
//                 const SizedBox(height: 8),
//                 Row(
//                   children: [
//                     Expanded(
//                       child: LinearProgressIndicator(
//                         value: file.progress,
//                         minHeight: 5,
//                         backgroundColor:
//                             ColorConstants.primaryColor.withOpacity(0.2),
//                         valueColor: AlwaysStoppedAnimation<Color>(
//                           ColorConstants.primaryColor,
//                         ),
//                       ),
//                     ),
//                     const SizedBox(width: 8),
//                     Text(
//                       '${(file.progress * 100).toInt()}%',
//                       style: TextStyle(
//                         color: Colors.grey[600],
//                         fontSize: 12,
//                       ),
//                     ),
//                   ],
//                 ),
//               ],
//             ),
//           ),
//           IconButton(
//             icon: const Icon(
//               CupertinoIcons.delete,
//               color: Colors.grey,
//               size: 20,
//             ),
//             onPressed: () {},
//           ),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildFormFields() {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         const SizedBox(height: 16),
//         const Text(
//           'Vehicle Name',
//           style: TextStyle(
//             fontSize: 14,
//             fontWeight: FontWeight.w500,
//             color: Colors.black87,
//           ),
//         ),
//         const SizedBox(height: 8),
//         CustomTextField(
//           controller: _vehicleNameController,
//         ),
//         const SizedBox(height: 16),
//         const Text(
//           'Vehicle Model Name',
//           style: TextStyle(
//             fontSize: 14,
//             fontWeight: FontWeight.w500,
//             color: Colors.black87,
//           ),
//         ),
//         const SizedBox(height: 8),
//         CustomTextField(
//           controller: _vehicleModelController,
//         ),
//         const SizedBox(height: 16),
//         const Text(
//           'Manufacturing',
//           style: TextStyle(
//             fontSize: 14,
//             fontWeight: FontWeight.w500,
//             color: Colors.black87,
//           ),
//         ),
//         const SizedBox(height: 8),
//         CustomTextField(
//           controller: _manufacturingController,
//         ),
//         const SizedBox(height: 16),
//         const Text(
//           'Max Power',
//           style: TextStyle(
//             fontSize: 14,
//             fontWeight: FontWeight.w500,
//             color: Colors.black87,
//           ),
//         ),
//         const SizedBox(height: 8),
//         _buildDropdownField(selectedMaxPower, ['SUV', 'Sedan', 'Hatchback']),
//         const SizedBox(height: 16),
//         const Text(
//           'Fuel Type',
//           style: TextStyle(
//             fontSize: 14,
//             fontWeight: FontWeight.w500,
//             color: Colors.black87,
//           ),
//         ),
//         const SizedBox(height: 8),
//         _buildDropdownField(
//             selectedFuelType, ['Petrol', 'Diesel', 'Electric', 'CNG']),
//         const SizedBox(height: 16),
//         const Text(
//           'Mileage',
//           style: TextStyle(
//             fontSize: 14,
//             fontWeight: FontWeight.w500,
//             color: Colors.black87,
//           ),
//         ),
//         const SizedBox(height: 8),
//         _buildDropdownField(selectedMileage, ['Petrol', '15 km/l', '20 km/l']),
//         const SizedBox(height: 16),
//         const Text(
//           'Registration Date',
//           style: TextStyle(
//             fontSize: 14,
//             fontWeight: FontWeight.w500,
//             color: Colors.black87,
//           ),
//         ),
//         const SizedBox(height: 8),
//         _buildDropdownField(
//             selectedRegistrationDate, ['Petrol', '2021', '2022', '2023']),
//         const SizedBox(height: 16),
//         const Text(
//           'Vehicle No.',
//           style: TextStyle(
//             fontSize: 14,
//             fontWeight: FontWeight.w500,
//             color: Colors.black87,
//           ),
//         ),
//         const SizedBox(height: 8),
//         _buildDropdownField(
//             selectedVehicleNo, ['Petrol', 'DL01AB1234', 'HR01CD5678']),
//         const SizedBox(height: 16),
//         const Text(
//           'Vehicle Specification',
//           style: TextStyle(
//             fontSize: 14,
//             fontWeight: FontWeight.w500,
//             color: Colors.black87,
//           ),
//         ),
//         const SizedBox(height: 8),
//         _buildDropdownField(selectedVehicleSpec1, ['GPS', 'Bluetooth', 'WiFi']),
//         const SizedBox(height: 16),
//         const Text(
//           'Vehicle Specification',
//           style: TextStyle(
//             fontSize: 14,
//             fontWeight: FontWeight.w500,
//             color: Colors.black87,
//           ),
//         ),
//         const SizedBox(height: 8),
//         _buildDropdownField(
//             selectedVehicleSpec2, ['AC', 'Music System', 'Leather Seats']),
//         const SizedBox(height: 16),
//         const Text(
//           'Served location(city/town)',
//           style: TextStyle(
//             fontSize: 14,
//             fontWeight: FontWeight.w500,
//             color: Colors.black87,
//           ),
//         ),
//         const SizedBox(height: 8),
//         _buildDropdownField(
//             selectedLocation, ['Gurugram, Delhi', 'Mumbai', 'Bangalore']),
//         const SizedBox(height: 16),
//         const Text(
//           'Minimum charge /hrs',
//           style: TextStyle(
//             fontSize: 14,
//             fontWeight: FontWeight.w500,
//             color: Colors.black87,
//           ),
//         ),
//         const SizedBox(height: 8),
//         _buildMinimumChargeField(),
//         const SizedBox(height: 20),
//       ],
//     );
//   }
//
//   Widget _buildDropdownField(String value, List<String> items) {
//     return Container(
//       height: 50,
//       decoration: BoxDecoration(
//         border: Border.all(color: Colors.grey[300]!),
//         borderRadius: BorderRadius.circular(8),
//       ),
//       child: DropdownButtonHideUnderline(
//         child: DropdownButton<String>(
//           value: value,
//           isExpanded: true,
//           padding: const EdgeInsets.symmetric(horizontal: 16),
//           onChanged: (String? newValue) {
//             if (newValue != null) {
//               setState(() {
//                 // Handle dropdown value changes
//               });
//             }
//           },
//           items: items.map<DropdownMenuItem<String>>((String item) {
//             return DropdownMenuItem<String>(
//               value: item,
//               child: Text(item),
//             );
//           }).toList(),
//         ),
//       ),
//     );
//   }
//
//   Widget _buildMinimumChargeField() {
//     return Row(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Container(
//           width: 80,
//           height: 50,
//           decoration: BoxDecoration(
//             border: Border.all(color: Colors.grey[300]!),
//             borderRadius: BorderRadius.circular(8),
//           ),
//           child: DropdownButtonHideUnderline(
//             child: DropdownButton<String>(
//               value: selectedCurrency,
//               padding: const EdgeInsets.symmetric(horizontal: 8),
//               icon: Icon(Icons.keyboard_arrow_down),
//               onChanged: (String? newValue) {
//                 if (newValue != null) {
//                   setState(() {
//                     selectedCurrency = newValue;
//                   });
//                 }
//               },
//               items: ['INR', 'USD', 'EUR']
//                   .map<DropdownMenuItem<String>>((String item) {
//                 return DropdownMenuItem<String>(
//                   value: item,
//                   child: Text(item),
//                 );
//               }).toList(),
//             ),
//           ),
//         ),
//         const SizedBox(width: 8),
//         Expanded(
//           child: CustomTextField(
//             controller: _minimumChargeController,
//             keyboardType: TextInputType.number,
//           ),
//         ),
//       ],
//     );
//   }
//
//   Widget _buildNavItem(IconData icon, String label, bool isSelected) {
//     return Column(
//       mainAxisAlignment: MainAxisAlignment.center,
//       children: [
//         Icon(
//           icon,
//           color: isSelected ? ColorConstants.primaryColor : Colors.grey,
//           size: 24,
//         ),
//         const SizedBox(height: 4),
//         Text(
//           label,
//           style: TextStyle(
//             color: isSelected ? ColorConstants.primaryColor : Colors.grey,
//             fontSize: 12,
//           ),
//         ),
//       ],
//     );
//   }
// }
//
// class CustomTextField extends StatelessWidget {
//   final TextEditingController controller;
//   final TextInputType keyboardType;
//
//   const CustomTextField({
//     Key? key,
//     required this.controller,
//     this.keyboardType = TextInputType.text,
//   }) : super(key: key);
//
//   @override
//   Widget build(BuildContext context) {
//     return SizedBox(
//       height: 50,
//       child: TextField(
//         controller: controller,
//         keyboardType: keyboardType,
//         decoration: InputDecoration(
//           contentPadding:
//               const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
//           border: OutlineInputBorder(
//             borderRadius: BorderRadius.circular(8),
//             borderSide: BorderSide(color: Colors.grey[300]!),
//           ),
//           enabledBorder: OutlineInputBorder(
//             borderRadius: BorderRadius.circular(8),
//             borderSide: BorderSide(color: Colors.grey[300]!),
//           ),
//           focusedBorder: OutlineInputBorder(
//             borderRadius: BorderRadius.circular(8),
//             borderSide: const BorderSide(
//               color: ColorConstants.primaryColor,
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }
//
// class FileUploadItem {
//   final String name;
//   final String size;
//   final double progress;
//
//   FileUploadItem(this.name, this.size, this.progress);
// }
