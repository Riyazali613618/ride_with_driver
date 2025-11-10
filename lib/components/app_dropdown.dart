import 'package:flutter/material.dart';

class PremiumDropdown extends StatefulWidget {
  final List<String> items;
  final String selectedItem;
  final ValueChanged<String> onChanged;

  const PremiumDropdown({
    Key? key,
    required this.items,
    required this.selectedItem,
    required this.onChanged,
  }) : super(key: key);

  @override
  State<PremiumDropdown> createState() => _PremiumDropdownState();
}

class _PremiumDropdownState extends State<PremiumDropdown> {
  late String _currentSelectedItem;

  @override
  void initState() {
    super.initState();
    _currentSelectedItem = widget.selectedItem;
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        height: 30,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(5),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              spreadRadius: 2,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: DropdownButtonHideUnderline(
          child: DropdownButton<String>(
            padding: EdgeInsets.zero,
            value: _currentSelectedItem,
            isExpanded: true,
            icon: const Icon(Icons.keyboard_arrow_down_rounded,
                color: Colors.black),
            dropdownColor: Colors.white,
            borderRadius: BorderRadius.circular(14),
            style: const TextStyle(
              fontSize: 16,
              color: Colors.black,
              fontWeight: FontWeight.w500,
            ),
            items: widget.items.map((item) {
              return DropdownMenuItem<String>(
                value: item,
                child: Text(
                  item,
                  style: const TextStyle(
                    fontSize: 16,
                    color: Colors.black87,
                  ),
                ),
              );
            }).toList(),
            onChanged: (value) {
              setState(() {
                _currentSelectedItem = value!;
              });
              widget.onChanged(value!); // 👈 Call callback
            },
          ),
        ),
      ),
    );
  }
}
