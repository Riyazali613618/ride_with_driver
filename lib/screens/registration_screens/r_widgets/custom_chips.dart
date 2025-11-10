import 'package:flutter/material.dart';

import '../../../constants/color_constants.dart';

class ChipSelection extends StatelessWidget {
  final String label;
  final List<String> options;
  final List<String> selectedOptions;
  final Function(List<String>) onSelectionChanged;
  final bool required;
  final String? errorText;
  final String hintText;

  const ChipSelection({
    Key? key,
    required this.label,
    required this.options,
    required this.selectedOptions,
    required this.onSelectionChanged,
    this.required = false,
    this.errorText,
    this.hintText = 'Select options',
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Filter out selected options from available options
    final availableOptions =
        options.where((option) => !selectedOptions.contains(option)).toList();

    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildLabel(),
          const SizedBox(height: 8),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(12),
              border: errorText != null
                  ? Border.all(color: Colors.red, width: 1)
                  : selectedOptions.isNotEmpty
                      ? Border.all(
                          color: Theme.of(context).primaryColor, width: 1)
                      : null,
            ),
            child: selectedOptions.isEmpty
                ? Text(
                    hintText,
                    style: TextStyle(
                      fontSize: 16,
                      color: ColorConstants.black.withOpacity(0.3),
                    ),
                  )
                : Wrap(
                    spacing: 2,
                    runSpacing: 0,
                    children: selectedOptions
                        .map((option) => _buildChip(context, option))
                        .toList(),
                  ),
          ),
          if (errorText != null) _buildErrorText(),
          if (availableOptions.isNotEmpty) ...[
            Wrap(
              spacing: 5,
              runSpacing: 0,
              children: availableOptions
                  .map((option) => _buildOptionChip(context, option))
                  .toList(),
            ),
          ],
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

  Widget _buildErrorText() {
    return Padding(
      padding: const EdgeInsets.only(top: 4, left: 8),
      child: Text(
        errorText!,
        style: TextStyle(
          color: Colors.red[700],
          fontSize: 12,
        ),
      ),
    );
  }

  Widget _buildChip(BuildContext context, String option) {
    return Chip(
      label: Text(
        option,
        style: const TextStyle(
          color: ColorConstants.white,
          fontSize: 12,
        ),
      ),
      backgroundColor: Theme.of(context).primaryColor,
      deleteIconColor: ColorConstants.white,
      onDeleted: () {
        final List<String> newSelection = List.from(selectedOptions);
        newSelection.remove(option);
        onSelectionChanged(newSelection);
      },
    );
  }

  Widget _buildOptionChip(BuildContext context, String option) {
    return ActionChip(
      label: Text(
        option,
        style: TextStyle(
          color: ColorConstants.black,
          fontSize: 12,
        ),
      ),
      backgroundColor: Colors.grey[200],
      onPressed: () {
        final List<String> newSelection = List.from(selectedOptions);
        newSelection.add(option);
        onSelectionChanged(newSelection);
      },
    );
  }
}
