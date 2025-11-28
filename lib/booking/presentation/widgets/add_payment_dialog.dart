import 'package:flutter/material.dart';

class AddPaymentRecordPopup extends StatefulWidget {
  final void Function(String type) listener;

  const AddPaymentRecordPopup({required this.listener, super.key});

  @override
  State<AddPaymentRecordPopup> createState() => _AddPaymentRecordPopupState();
}

class _AddPaymentRecordPopupState extends State<AddPaymentRecordPopup> {
  final TextEditingController _amount = TextEditingController(text: "10000.00");
  final TextEditingController _date = TextEditingController(text: "30/10/2025");
  final TextEditingController _time = TextEditingController(text: "10:30 AM");

  String selectedMode = "UPI";
  final modes = ["UPI", "Cash", "Card", "Bank Transfer"];

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 18),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Close Icon
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

            const Text("Add payment Record",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),

            // Amount
            _label("Amount- INR"),
            _inputBox(controller: _amount),

            const SizedBox(height: 16),

            // Date & Time Row
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _label("Date"),
                      _inputBox(
                        controller: _date,
                        readOnly: true,
                        suffix: const Icon(Icons.calendar_today, size: 16),
                        onTap: _pickDate,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _label("Time"),
                      _inputBox(
                        controller: _time,
                        readOnly: true,
                        suffix: const Icon(Icons.access_time, size: 16),
                        onTap: _pickTime,
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Mode Dropdown
            _label("Mode"),
            Container(
              height: 35,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade400),
                borderRadius: BorderRadius.circular(6),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: selectedMode,
                  items: modes
                      .map((e) =>
                      DropdownMenuItem(
                        value: e,
                        child: Text(e),
                      ))
                      .toList(),
                  onChanged: (val) {
                    setState(() => selectedMode = val!);
                  },
                  icon: const Icon(Icons.arrow_drop_down),
                ),
              ),
            ),

            const SizedBox(height: 28),

            // Add Button
            SizedBox(
              width: 120,
              height: 38,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  widget.listener("");
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8)),
                ),
                child: const Text("Add",
                    style: TextStyle(color: Colors.white, fontSize: 15)),
              ),
            ),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }

  // ---------------- Widgets ----------------
  Widget _label(String text) =>
      Padding(
        padding: const EdgeInsets.only(bottom: 4),
        child: Text(text,
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
      );

  Widget _inputBox({
    required TextEditingController controller,
    Widget? suffix,
    bool readOnly = false,
    VoidCallback? onTap,
  }) {
    return SizedBox(
      height: 35,
      child: TextField(
        controller: controller,
        readOnly: readOnly,
        onTap: onTap,
        decoration: InputDecoration(
          contentPadding: const EdgeInsets.symmetric(horizontal: 12),
          suffixIcon: suffix != null
              ? Padding(
            padding: const EdgeInsets.only(right: 6),
            child: suffix,
          )
              : null,
          suffixIconConstraints:
          const BoxConstraints(minWidth: 32, minHeight: 32),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(6),
            borderSide: BorderSide(color: Colors.grey.shade400),
          ),
        ),
        style: const TextStyle(fontSize: 13),
      ),
    );
  }

  // ---------------- Date Picker ----------------
  Future<void> _pickDate() async {
    final result = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2023),
      lastDate: DateTime(2035),
    );
    if (result != null) {
      _date.text =
      "${result.day.toString().padLeft(2, '0')}/${result.month
          .toString()
          .padLeft(2, '0')}/${result.year}";
    }
  }

  // ---------------- Time Picker ----------------
  Future<void> _pickTime() async {
    final result = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (result != null) {
      final hour = result.hourOfPeriod.toString().padLeft(2, '0');
      final minute = result.minute.toString().padLeft(2, '0');
      final period = result.period == DayPeriod.am ? "AM" : "PM";
      _time.text = "$hour:$minute $period";
    }
  }
}
