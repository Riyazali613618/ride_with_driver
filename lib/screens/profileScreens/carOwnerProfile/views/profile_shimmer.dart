import 'package:flutter/material.dart';
import 'package:shimmer_animation/shimmer_animation.dart';

import '../../../../constants/color_constants.dart';
import '../../../../utils/common_utils.dart';

class ProfileShimmer extends StatelessWidget {
  const ProfileShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    double boxWidth=40;
    double boxHeight=50;
    return Shimmer(

      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildTextField(),
            SizedBox(height: 20),
            _buildTextField(),
            SizedBox(height: 20),
            _buildTextField(),
            SizedBox(height: 20),
            _buildTextField(),
            SizedBox(height: 20),
            _buildTextField(),
            SizedBox(height: 20),
            _buildTextField(),
            SizedBox(height: 20),
            Text(
              'Vehicle Counts',
              style: CommonUtils.commonTextLabelsStyle(),
            ),
            SizedBox(height: 12),
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              Row(
                children: [
                  Text(
                    "",
                  ),
                  SizedBox(width: 4),
                  _buildTextField(),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Text(
                    "",
                  ),
                  SizedBox(width: 4),
                  _buildTextField(),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Text(
                    "",
                  ),
                  SizedBox(width: 4),
                  _buildTextField(),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Text(
                    "",
                  ),
                  SizedBox(width: 4),
                  _buildTextField(),
                ],
              ),
            ]),
            SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            '',
                            style: CommonUtils.commonTextLabelsStyle(),
                          ),
                          SizedBox(width: 8),
                          GestureDetector(
                            onTap: () {
                              showDialog(
                                context: context,
                                builder: (context) => AlertDialog(
                                  title: Text(''),
                                  content: Text(
                                    '',
                                  ),
                                  actions: [
                                    TextButton(
                                      onPressed: () => Navigator.pop(context),
                                      child: Text('OK'),
                                    ),
                                  ],
                                ),
                              );
                            },
                            child: Container(
                              width: 20,
                              height: 20,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.grey[400],
                              ),
                              child: Icon(
                                Icons.info_outline,
                                size: 12,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 8),
                      Container(
                        padding:
                            EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        decoration: BoxDecoration(
                          border: Border.all(
                              color: ColorConstants.inputFieldBorderColor),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child:             _buildTextField(),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildTextField(),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  _buildTextField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "",
          style: CommonUtils.commonTextLabelsStyle(),
        ),
        SizedBox(height: 8),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: CommonUtils.commonInputBoxDecoration(),
          child: Text(""),
        ),
      ],
    );
  }
}
