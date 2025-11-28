import 'package:flutter/material.dart';

class ShowOtpPopup extends StatefulWidget {
  final void Function(String type) listener;

  const ShowOtpPopup({required this.listener, super.key});

  @override
  State<ShowOtpPopup> createState() => _ShowOtpPopupState();
}

class _ShowOtpPopupState extends State<ShowOtpPopup> {
  final TextEditingController _otp = TextEditingController(text: "123456");

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

            const Text("Start Journey",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),

            // Amount
            _label("Enter Code"),
            _inputBox(controller: _otp),

            const SizedBox(height: 16),

            const SizedBox(height: 28),

            // Add Button
            SizedBox(
              width: 120,
              height: 38,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  widget.listener("add");
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8)),
                ),
                child: const Text("Start",
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
  Widget _label(String text) => Padding(
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
}




class ShowCancelAlertPopup extends StatefulWidget {
  final void Function(String type) listener;

  const ShowCancelAlertPopup({required this.listener, super.key});

  @override
  State<ShowCancelAlertPopup> createState() => _ShowCancelAlertPopupState();
}

class _ShowCancelAlertPopupState extends State<ShowCancelAlertPopup> {

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

            const Text("Are you sure you want to cancel?",
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
            const SizedBox(height: 50),

            // Add Button
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                SizedBox(
                  width: 120,
                  height: 38,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                      widget.listener("cancel");
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8)),
                    ),
                    child: const Text("Cancel",
                        style: TextStyle(color: Colors.white, fontSize: 15)),
                  ),
                ),
                SizedBox(
                  width: 80,
                  height: 38,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                      widget.listener("No");
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8)),
                    ),
                    child: const Text("No",
                        style: TextStyle(color: Colors.white, fontSize: 15)),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  // ---------------- Widgets ----------------
  Widget _label(String text) => Padding(
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
}

