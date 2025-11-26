import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter_svg/svg.dart';
import 'package:r_w_r/components/app_loader.dart';

class VehicleDetailsCard extends StatelessWidget {
  final void Function(int)? onTap;
  final int pos;
  final String name;

  const VehicleDetailsCard(
      {required this.pos, required this.name, this.onTap, super.key});

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.topCenter,
      children: [
        Container(
          margin: EdgeInsets.only(bottom: 4),
          child: Card(
            elevation: 0,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            color: const Color(0xfff4eefc),
            child: Padding(
              padding: const EdgeInsets.all(4),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  /// LEFT: Image Slider
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: SizedBox(
                      height: 70,
                      width: 120,
                      child: Stack(
                        children: [
                          CarouselSlider(
                            items: [
                              Image.asset(
                                "assets/img/image_one.png",
                                fit: BoxFit.cover,
                                width: 120,
                              ),
                              Image.asset(
                                "assets/img/image_one.png",
                                fit: BoxFit.cover,
                                width: 120,
                              ),
                            ],
                            options: CarouselOptions(
                              viewportFraction: 1,
                              height: 70,
                            ),
                          ),
                          Positioned(
                            top: 8,
                            right: 8,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                vertical: 2,
                                horizontal: 6,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.black54,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Text(
                                "1/2",
                                style: TextStyle(
                                    color: Colors.white, fontSize: 12),
                              ),
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 6),

                  /// RIGHT SECTION
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        /// Title + Seats + AC
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              name,
                              style: TextStyle(
                                  fontSize: 10, fontWeight: FontWeight.bold),
                            ),
                            Row(
                              children: const [
                                Icon(Icons.event_seat, size: 18),
                                SizedBox(width: 4),
                                Text(
                                  "7 Seats",
                                  style: TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.w400),
                                ),
                              ],
                            ),
                            Container(
                              margin: EdgeInsets.only(top: 3),
                              padding: const EdgeInsets.symmetric(
                                  vertical: 2, horizontal: 5),
                              decoration: BoxDecoration(
                                color: Color(0x1F641BB4),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: AppColors.blue),
                              ),
                              child: const Text("AC/ Non AC",
                                  style: TextStyle(
                                      fontSize: 9,
                                      fontWeight: FontWeight.w500)),
                            )
                          ],
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          "RE Compact",
                          style: TextStyle(
                              color: Colors.black,
                              fontSize: 9,
                              fontWeight: FontWeight.w400),
                        ),
                        const SizedBox(height: 6),
                        Row(
                          children: const [
                            Text(
                              "Vehicle Number - ",
                              style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 9,
                                  fontWeight: FontWeight.w400),
                            ),
                            Text(
                              "CH01HG5687",
                              style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 9,
                                  fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),

                        const SizedBox(height: 4),

                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              "Specification -",
                              style: TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 10),
                            ),
                            const SizedBox(width: 6),

                            /// Feature chips
                            Expanded(
                              child: Wrap(
                                spacing: 6,
                                runSpacing: 2,
                                children: const [
                                  _specItem("Navigation system"),
                                  _specItem("AirBags"),
                                  _specItem("ABS"),
                                  _specItem("Petrol"),
                                  _specItem("Leather Seat"),
                                  _specItem("Rear Camera"),
                                  _specItem("Bluetooth"),
                                  _specItem("Sunroof"),
                                  _specItem("Cruise Control"),
                                ],
                              ),
                            )
                          ],
                        )
                      ],
                    ),
                  )
                ],
              ),
            ),
          ),
        ),
        if(onTap!=null)
          Positioned(
            right: 0,
            top: 0,
            child: Align(
              child: GestureDetector(
                  onTap: () {
                    onTap!(pos);
                  },
                  child: SvgPicture.asset(
                    "assets/svg/cross.svg",
                    width: 16,
                    height: 16,
                  )),
            ))
      ],
    );
  }
}

class _specItem extends StatelessWidget {
  final String title;

  const _specItem(this.title, {super.key});

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: const TextStyle(
          fontSize: 8, fontWeight: FontWeight.w400, color: Colors.black),
    );
  }
}

