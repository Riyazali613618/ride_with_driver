import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:r_w_r/components/app_loader.dart';
import 'package:r_w_r/features/newDashboard/dashboard_model.dart';
import 'package:speedometer_chart/speedometer_chart.dart';

class PerformanceSection extends StatelessWidget {
  final DashboardMetrics data;
  const PerformanceSection( {required this.data,super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Performance",
          style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            ...["1 Day", "1 Week", "1 Month", "1 Year", "Custom"]
                .map(
                  (e) => Padding(
                padding: EdgeInsets.only(right: 8),
                child: Container(
                    padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      border: BoxBorder.all(color: Colors.black,width: 0.5),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Text(
                      e,
                      style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w400,
                          color: Colors.black),
                    )),
              ),
            )
                .toList(),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Container(
              margin: EdgeInsets.symmetric(horizontal: 10),
              height: 150,
              width: (MediaQuery.of(context).size.width*0.4)-10,
              child: PieChart(
                PieChartData(
                  sectionsSpace: 0,
                  centerSpaceRadius: 0,
                  sections: [
                    PieChartSectionData(
                        radius: 70,
                        titleStyle: TextStyle(fontSize: 11,fontWeight: FontWeight.bold,color: Colors.white),
                        value: 32, color: Colors.indigo),
                    PieChartSectionData(
                        radius: 70,
                        titleStyle: TextStyle(fontSize: 11,fontWeight: FontWeight.bold,color: Colors.white),
                        value: 12, color: Colors.blue),
                    PieChartSectionData(
                        radius: 70,
                        titleStyle: TextStyle(fontSize: 11,fontWeight: FontWeight.bold,color: Colors.white),
                        value: 10, color: Colors.lightBlueAccent),
                    PieChartSectionData(
                        titleStyle: TextStyle(fontSize: 11,fontWeight: FontWeight.bold,color: Colors.white),
                        radius: 70,
                        value: 10, color: Colors.grey.shade300),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Card(
                color: Colors.white,
                shadowColor: Colors.grey,
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 10,vertical: 15),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Expanded(child: _legend("Views", 32)),
                          Expanded(child: _legend("Call", 12)),
                        ],
                      ),
                      Row(
                        children: [
                          Expanded(child: _legend("WhatsApp", 10)),
                          Expanded(child: _legend("Chat", 10)),
                        ],
                      )
                    ],
                  ),
                ),
              ),
            )
          ],
        ),
      ],
    );
  }

  Widget _legend(String label, int value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Text("• $label",style: TextStyle(color: AppColors.blue,fontSize: 12,fontWeight: FontWeight.w600),),
          Text("$value",style: TextStyle(color: Colors.black,fontSize: 12,fontWeight: FontWeight.bold),),
        ],
      ),
    );
  }
}
