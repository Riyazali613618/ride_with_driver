// import 'package:cached_network_image/cached_network_image.dart';
// import 'package:flutter/cupertino.dart';
// import 'package:flutter/material.dart';
//
// class CustomNetworkImage extends StatelessWidget {
//   final String imageUrl;
//   final BoxFit fit;
//   final double? width;
//   final double? height;
//
//   const CustomNetworkImage({
//     super.key,
//     required this.imageUrl,
//     this.fit = BoxFit.cover,
//     this.width,
//     this.height,
//   });
//
//   @override
//   Widget build(BuildContext context) {
//     return ClipRRect(
//       borderRadius: BorderRadius.circular(10),
//       child: CachedNetworkImage(
//         imageUrl: imageUrl,
//         fit: fit,
//         width: width ?? double.infinity,
//         height: height ?? 200, // Fixed height to prevent infinite size
//         placeholder: (context, url) => Center(
//           child: CircularProgressIndicator(
//             color: Theme.of(context).primaryColor,
//           ),
//         ),
//         errorWidget: (context, url, error) => Icon(CupertinoIcons.photo),
//       ),
//     );
//   }
// }
