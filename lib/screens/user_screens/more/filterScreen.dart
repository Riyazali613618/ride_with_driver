import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:r_w_r/components/app_loader.dart';
import 'package:r_w_r/constants/color_constants.dart';
import 'package:r_w_r/utils/common_utils.dart';

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
              builder: (context) => FilterBottomSheet(
                listener: (filter) {},
              ),
            );
          },
          child: const Text('Open Filters'),
        ),
      ),
    );
  }
}

class FilterBottomSheet extends StatefulWidget {
  final void Function(Map<String, String>) listener;

  const FilterBottomSheet({required this.listener, super.key});

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
      if(appliedFilter.containsKey(key))
      appliedFilter.remove(key);
    });
  }

  void addFilter(String key) {
    setState(() {
      filters[key]?.isActive = true;
    });
  }

  void updateFilterValue(String key, String value) {
    print(value);
    print(key);

    setState(() {
      filters[key]?.value = value;
    });
    final activeFilters =
    filters.entries.where((e) => e.value.isActive).toList();
    activeFilters.forEach(
          (element) {
        appliedFilter[element.key] = element.value.value;
      },
    );
    widget.listener(appliedFilter);
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
    appliedFilter.forEach((key, value) {
      activeFilters[key] = value;
    });

    return activeFilters;
  }

  void applyFilters() {
    appliedFilter.clear();
    widget.listener(appliedFilter);
    Navigator.pop(context, getActiveFilters());
  }

  Map<String, String> appliedFilter = {};

  @override
  Widget build(BuildContext context) {
    final inactiveFilters =
        filters.entries.where((e) => !e.value.isActive).toList();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20), topRight: Radius.circular(20))),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header
          Align(
            alignment: Alignment.centerRight,
            child: IconButton(
              onPressed: () {
                Navigator.pop(context);
              },
              icon: const Icon(Icons.cancel_outlined),
            ),
          ),
          const SizedBox(height: 10),

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
          Row(
            children: [
              SizedBox(width: 20,),
              Expanded(child: GestureDetector(
                onTap: clearAll,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
                  decoration: BoxDecoration(
                      border: Border.all(color: AppColors.blue),
                      borderRadius: BorderRadius.all(Radius.circular(14))),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text('Clear All',
                          style: CommonUtils.commonTitleStyle(
                              fontSize: 14,
                              color: Colors.black,
                              weight: FontWeight.w400)),
                      SizedBox(width: 8),
                      Icon(Icons.close, size: 18),
                    ],
                  ),
                ),
              )),
              SizedBox(width: 20,),
              Expanded(child: GestureDetector(
                onTap: () {
                  widget.listener(appliedFilter);
                  Navigator.pop(context,getActiveFilters());                },
                child: Container(
                  alignment: Alignment.center,
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
                  decoration: BoxDecoration(
                      color: ColorConstants.primaryColor,
                      border: Border.all(color: AppColors.blue),
                      borderRadius: BorderRadius.all(Radius.circular(14))),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text('Apply',
                          style: CommonUtils.commonTitleStyle(
                              fontSize: 14,
                              color: Colors.white,
                              weight: FontWeight.w400)),
                      SizedBox(width: 8),
                    ],
                  ),
                ),
              )),
              SizedBox(width: 20,),
            ],
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
      margin: EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: Color(0x1F641BB4),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.all(Radius.circular(12)),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.topRight,
                colors: [
                  gradientFirst,
                  gradientSecond,
                ],
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
              child: Text(
                filterData.label,
                style: CommonUtils.commonTitleStyle(
                    fontSize: 18, weight: FontWeight.w400, color: Colors.white),
              ),
            ),
          ),
          const SizedBox(
            width: 0,
          ),
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: filterData.value,
                  isExpanded: true,
                  style: CommonUtils.commonTitleStyle(
                      fontSize: 18,
                      weight: FontWeight.w400,
                      color: Colors.black),
                  icon: SvgPicture.asset("assets/svg/drop_down_gradient.svg"),
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
            child: const Icon(
              Icons.close,
              color: Colors.black,
              size: 18,
            ),
          ),
          const SizedBox(width: 8),
        ],
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
