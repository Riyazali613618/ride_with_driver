import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../../components/app_loader.dart';

class QuotationTermsPage extends StatelessWidget {
  const QuotationTermsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Quotation Amount:",
              style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.black),
            ),
            const SizedBox(height: 12),
            _buildQuotationRow("1", "TATA SUV", "20000.00"),
            const SizedBox(height: 10),
            _buildQuotationRow("2", "Fortuner", "25000.00"),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: _boxedField(
                    label: "Total Amount",
                    controller: TextEditingController(text: "45000.00"),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _boxedField(
                    label: "Daily driver working hours",
                    controller: TextEditingController(text: "10 hrs"),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 25),
            const Text(
              "Cancellation:",
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _boxedField(
                    label: "Cancellation Deadline",
                    controller: TextEditingController(text: "30/10/2025"),
                    suffixIcon: const Icon(Icons.calendar_today, size: 18),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _boxedField(
                    label: "Time",
                    controller: TextEditingController(text: "10:30 AM"),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Text(
              "Payment terms:",
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: _boxedField(
                    label: "Advance– INR",
                    controller: TextEditingController(text: "10000.00"),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _boxedField(
                    label: "Pay on Arrival– INR",
                    controller: TextEditingController(text: "20000.00"),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _boxedField(
                    label: "Pay on completion– INR",
                    controller: TextEditingController(text: "15000.00"),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 25),
            const Text(
              "Note:",
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Container(
              height: 80,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade400),
                borderRadius: BorderRadius.circular(8),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: const TextField(
                maxLines: null,
                style: TextStyle(fontSize: 10, fontWeight: FontWeight.w400),
                decoration: InputDecoration(
                  hintText: "Enter note...",
                  border: InputBorder.none,
                ),
              ),
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  /// ------------------------------
  /// Quotation Rows
  /// ------------------------------
  Widget _buildQuotationRow(String id, String car, String amount) {
    return Row(
      children: [
        Text(id),
        const SizedBox(width: 12),
        Expanded(
            child: Container(
              height: 30,
              decoration: BoxDecoration(
                color: Color(0xFFB1B1B1),
                borderRadius: const BorderRadius.only(
                  topRight: Radius.circular(6),
                  bottomRight: Radius.circular(6),
                ),
              ),
              child: Row(
                children: [
                  const SizedBox(width: 12),
                  Expanded(child: Text(car)),
                  const SizedBox(width: 12),
                  Container(
                    width: 100,
                    height: 30,
                    decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: const BorderRadius.only(
                          topRight: Radius.circular(6),
                          bottomRight: Radius.circular(6),
                        ),
                        border: Border.all(
                          color: AppColors.blue,
                        )),
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    alignment: Alignment.centerLeft,
                    child: Text(
                      "INR- $amount",
                      style: TextStyle(fontSize: 10, fontWeight: FontWeight.w400),
                    ),
                  ),
                ],
              ),
            ))
      ],
    );
  }

  /// ------------------------------
  /// Universal 40-height Input
  /// ------------------------------
  Widget _boxedField({
    required String label,
    required TextEditingController controller,
    Widget? suffixIcon,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
              fontSize: 10, fontWeight: FontWeight.w400, color: Colors.black),
        ),
        const SizedBox(height: 4),
        SizedBox(
          height: 30,
          child: TextField(
            controller: controller,
            style: TextStyle(
                fontSize: 10, fontWeight: FontWeight.w400, color: Colors.black),
            decoration: InputDecoration(
              contentPadding: const EdgeInsets.symmetric(horizontal: 12),
              suffixIcon: suffixIcon,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(6),
              ),
            ),
          ),
        ),
      ],
    );
  }


}
