import 'package:flutter/material.dart';

import '../../../constants/color_constants.dart';

class CustomDropdown<T> extends StatelessWidget {
  final String label;
  final String hint;
  final T? value;
  final List<DropdownMenuItem<T>>? items;
  final ValueChanged<T?>? onChanged;
  final bool required;
  final String? errorText;

  const CustomDropdown({
    Key? key,
    required this.label,
    required this.hint,
    this.value,
    this.items,
    this.onChanged,
    this.required = false,
    this.errorText,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildLabel(),
          const SizedBox(height: 8),
          Container(
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(12),
              border: errorText != null
                  ? Border.all(color: Colors.red, width: 1)
                  : value != null
                      ? Border.all(
                          color: Theme.of(context).primaryColor, width: 1)
                      : null,
            ),
            child: DropdownButtonFormField<T>(
              value: value,
              items: items,
              onChanged: onChanged,
              decoration: InputDecoration(
                hintText: hint,
                errorText: errorText,
                hintStyle: TextStyle(
                  fontSize: 16,
                  color: ColorConstants.black.withOpacity(0.3),
                ),
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                border: InputBorder.none,
              ),
              icon: const Icon(Icons.arrow_drop_down),
              isExpanded: true,
              style: const TextStyle(
                fontSize: 16,
                color: ColorConstants.black,
              ),
              dropdownColor: ColorConstants.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLabel() {
    return Row(
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: ColorConstants.black.withAlpha(100),
          ),
        ),
        if (required)
          Text(
            ' *',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Colors.red[700],
            ),
          ),
      ],
    );
  }
}
