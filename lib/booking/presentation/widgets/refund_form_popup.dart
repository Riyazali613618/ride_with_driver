import 'package:flutter/material.dart';
import 'package:r_w_r/components/app_loader.dart';

class RefundFormPopup extends StatefulWidget {
  const RefundFormPopup({super.key});

  @override
  State<RefundFormPopup> createState() => _RefundFormPopupState();
}

class _RefundFormPopupState extends State<RefundFormPopup> {
  final TextEditingController _bookingId =
      TextEditingController(text: "B-98723348");
  final TextEditingController _totalPaid =
      TextEditingController(text: "10000.00");
  final TextEditingController _refundAmount =
      TextEditingController(text: "10000.00");
  final TextEditingController _cancelReason = TextEditingController();

  String refundMode = "UPI";
  final modes = ["UPI", "Cash", "Card", "Bank Transfer"];

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Close button
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: const Icon(Icons.close, size: 22),
                )
              ],
            ),

            const SizedBox(height: 4),

            // Title
            const Text(
              "Refund form",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: AppColors.blue, // Purple shade
              ),
            ),
            const SizedBox(height: 22),

            // Booking ID + Total Paid
            Row(
              children: [
                Expanded(
                  child: _labelField("Booking ID", _bookingId, readOnly: true),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: _labelField("Total Paid Amount", _totalPaid,
                      readOnly: true),
                ),
              ],
            ),
            const SizedBox(height: 18),

            // Refund amount + mode
            Row(
              children: [
                Expanded(
                  child:
                      _labelField("Refund amount to be proceed", _refundAmount),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: _labelDropdown("Refund Mode"),
                ),
              ],
            ),

            const SizedBox(height: 18),

            // Cancellation Reason
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "Cancellation Reason",
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
              ),
            ),
            const SizedBox(height: 6),
            SizedBox(
              height: 80,
              child: TextField(
                controller: _cancelReason,
                maxLines: null,
                decoration: InputDecoration(
                  hintText: "Type",
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(6),
                    borderSide: BorderSide(color: Colors.grey.shade400),
                  ),
                ),
                style: const TextStyle(fontSize: 13),
              ),
            ),

            const SizedBox(height: 22),

            // Proceed Button
            SizedBox(
              height: 38,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.blue, // Purple
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8)),
                ),
                child: const Text(
                  "Proceed Refund",
                  style: TextStyle(fontSize: 14, color: Colors.white),
                ),
              ),
            ),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }

  // ------------- COMMON INPUT FIELD (height = 35) -------------
  Widget _labelField(String title, TextEditingController controller,
      {bool readOnly = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title,
            style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w400)),
        const SizedBox(height: 6),
        SizedBox(
          height: 35,
          child: TextField(
            controller: controller,
            readOnly: readOnly,
            decoration: InputDecoration(
              contentPadding: const EdgeInsets.symmetric(horizontal: 12),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(6),
                borderSide: BorderSide(color: Colors.grey.shade400),
              ),
            ),
            style: const TextStyle(fontSize: 10),
          ),
        ),
      ],
    );
  }

  // ------------- DROPDOWN FIELD (height = 35) -------------
  Widget _labelDropdown(String title) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title,
            style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w500)),
        const SizedBox(height: 6),
        Container(
          height: 35,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade400),
            borderRadius: BorderRadius.circular(6),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: refundMode,
              items: modes
                  .map((e) => DropdownMenuItem(
                      value: e,
                      child: Text(
                        e,
                        style: TextStyle(fontSize: 10),
                      )))
                  .toList(),
              onChanged: (val) {
                setState(() => refundMode = val!);
              },
              icon: const Icon(Icons.arrow_drop_down),
            ),
          ),
        ),
      ],
    );
  }
}
