import 'package:flutter/material.dart';

import '../../../utils/color.dart';

class FilterDemo extends StatelessWidget {
  const FilterDemo({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Filter Bottom Sheet Demo'),
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            showModalBottomSheet(
              context: context,
              isScrollControlled: true,
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
              ),
              builder: (context) => const FilterBottomSheet(),
            );
          },
          child: const Text('Open Filters'),
        ),
      ),
    );
  }
}

class FilterBottomSheet extends StatefulWidget {
  const FilterBottomSheet({Key? key}) : super(key: key);

  @override
  State<FilterBottomSheet> createState() => _FilterBottomSheetState();
}

class _FilterBottomSheetState extends State<FilterBottomSheet> {
  Map<String, FilterData> filters = {
    'price': FilterData(
      label: 'Price',
      value: 'High',
      options: ['High', 'Low'],
      isActive: true,
    ),
    'vehicleType': FilterData(
      label: 'Vehicle Type',
      value: 'SUV',
      options: ['SUV', 'Mini Van', 'Car', 'Bus', 'Rickshaw', 'E-Rickshaw'],
      isActive: true,
    ),
    'airCondition': FilterData(
      label: 'Air Condition',
      value: 'AC',
      options: ['AC', 'Non-AC'],
      isActive: true,
    ),
    'seatingCapacity': FilterData(
      label: 'Seating Capacity',
      value: '5',
      options: ['1', '2', '3', '4', '5', '6', '7', '8', '9', '10+'],
      isActive: true,
    ),
  };

  void removeFilter(String key) {
    setState(() {
      filters[key]?.isActive = false;
    });
  }

  void addFilter(String key) {
    setState(() {
      filters[key]?.isActive = true;
    });
  }

  void updateFilterValue(String key, String value) {
    setState(() {
      filters[key]?.value = value;
    });
  }

  void clearAll() {
    setState(() {
      filters.forEach((key, value) {
        value.isActive = false;
      });
    });
  }
  Map<String, dynamic> getActiveFilters() {
    Map<String, dynamic> activeFilters = {};
    filters.forEach((key, value) {
      if (value.isActive) {
        activeFilters[key] = value.value;
      }
    });
    return activeFilters;
  }

  void applyFilters() {
    Navigator.pop(context, getActiveFilters());
  }

  @override
  Widget build(BuildContext context) {
    final inactiveFilters =
    filters.entries.where((e) => !e.value.isActive).toList();
    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Filters',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              IconButton(
                onPressed:applyFilters,
                icon: const Icon(Icons.close),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Active Filter Chips
          ...filters.entries.map((entry) {
            if (!entry.value.isActive) return const SizedBox.shrink();
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: FilterChip(
                filterKey: entry.key,
                filterData: entry.value,
                onRemove: () => removeFilter(entry.key),
                onValueChanged: (value) => updateFilterValue(entry.key, value),
              ),
            );
          }).toList(),

          // Add Filter Buttons
          if (inactiveFilters.isNotEmpty) ...[
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: inactiveFilters.map((entry) {
                return AddFilterButton(
                  label: entry.value.label,
                  onTap: () => addFilter(entry.key),
                );
              }).toList(),
            ),
          ],

          const SizedBox(height: 20),

          // Clear All Button
          OutlinedButton(
            onPressed: clearAll,
            style: OutlinedButton.styleFrom(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(25),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 12),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: const [
                Text('Clear All'),
                SizedBox(width: 8),
                Icon(Icons.close, size: 18),
              ],
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}

class FilterChip extends StatelessWidget {
  final String filterKey;
  final FilterData filterData;
  final VoidCallback onRemove;
  final ValueChanged<String> onValueChanged;

  const FilterChip({
    Key? key,
    required this.filterKey,
    required this.filterData,
    required this.onRemove,
    required this.onValueChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.topRight,
          colors: [
            gradientFirst,
            gradientSecond,
          ],
          stops: [0.0, 0.25],
        ),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Padding(
        padding: const EdgeInsets.only(left: 4, top: 4, bottom: 4, right: 12),
        child: Row(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              child: Text(
                filterData.label,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: 15,
                ),
              ),
            ),
            Expanded(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(15),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: filterData.value,
                    isExpanded: true,
                    icon: const Icon(Icons.keyboard_arrow_down),
                    items: filterData.options.map((option) {
                      return DropdownMenuItem(
                        value: option,
                        child: Text(option),
                      );
                    }).toList(),
                    onChanged: (value) {
                      if (value != null) onValueChanged(value);
                    },
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            InkWell(
              onTap: onRemove,
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.close,
                  color: Colors.white,
                  size: 18,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class AddFilterButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const AddFilterButton({
    Key? key,
    required this.label,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.grey[200],
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.grey[400]!),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.add, size: 18, color: Colors.grey[700]),
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(
                color: Colors.grey[700],
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class FilterData {
  String label;
  String value;
  List<String> options;
  bool isActive;

  FilterData({
    required this.label,
    required this.value,
    required this.options,
    required this.isActive,
  });
}