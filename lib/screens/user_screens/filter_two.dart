import 'package:flutter/material.dart';
import 'package:r_w_r/constants/color_constants.dart';

// Customized filter bottom sheet with new categories: Price, Language, Experience, Age
class CustomFilterBottomSheet extends StatefulWidget {
  final ScrollController? scrollController;
  final VoidCallback? onClose;
  final Function(Map<String, String?>)? onApplyFilters;

  const CustomFilterBottomSheet({
    Key? key,
    this.scrollController,
    this.onClose,
    this.onApplyFilters,
  }) : super(key: key);

  // Static method to show the bottom sheet and get results
  static Future<Map<String, String?>?> show(BuildContext context) async {
    return await showModalBottomSheet<Map<String, String?>>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.5,
          minChildSize: 0.1,
          maxChildSize: 0.9,
          builder: (context, scrollController) {
            return CustomFilterBottomSheet(
              scrollController: scrollController,
              onClose: () => Navigator.pop(context),
              onApplyFilters: (filters) {
                Navigator.pop(context, filters);
              },
            );
          },
        );
      },
    );
  }

  @override
  State<CustomFilterBottomSheet> createState() =>
      _CustomFilterBottomSheetState();
}

class _CustomFilterBottomSheetState extends State<CustomFilterBottomSheet> {
  int? _expandedIndex;

  // Store selected values for each category
  String? _selectedPrice;
  String? _selectedLanguage;
  String? _selectedExperience;
  String? _selectedAge;

  // Method to get all filter values as a map
  Map<String, String?> get filterValues => {
        'price': _selectedPrice,
        'language': _selectedLanguage,
        'experience': _selectedExperience,
        'age': _selectedAge,
      };

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 10,
            offset: Offset(0, -5),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildDragHandle(),
          Expanded(
            child: ListView(
              controller: widget.scrollController,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              children: [
                const SizedBox(height: 8),
                _buildFilterTitle(),
                const SizedBox(height: 16),
                _buildFilterCategory(
                  index: 0,
                  title: 'Price',
                  options: const [
                    'High to Low',
                    'Low to High',
                    'Under \$50',
                    '\$50 - \$100',
                    '\$100 - \$200',
                    'Above \$200'
                  ],
                  selectedValue: _selectedPrice,
                  onOptionSelected: (value) =>
                      setState(() => _selectedPrice = value),
                ),
                _buildFilterCategory(
                  index: 1,
                  title: 'Language',
                  options: const [
                    'English',
                    'Spanish',
                    'French',
                    'German',
                    'Chinese',
                    'Japanese',
                    'Arabic'
                  ],
                  selectedValue: _selectedLanguage,
                  onOptionSelected: (value) =>
                      setState(() => _selectedLanguage = value),
                ),
                _buildFilterCategory(
                  index: 2,
                  title: 'Experience',
                  options: const [
                    'Beginner (0-2 years)',
                    'Intermediate (3-5 years)',
                    'Advanced (6-10 years)',
                    'Expert (10+ years)'
                  ],
                  selectedValue: _selectedExperience,
                  onOptionSelected: (value) =>
                      setState(() => _selectedExperience = value),
                ),
                _buildFilterCategory(
                  index: 3,
                  title: 'Age',
                  options: const [
                    'Under 18',
                    '18-24 years',
                    '25-34 years',
                    '35-44 years',
                    '45-54 years',
                    '55+ years'
                  ],
                  selectedValue: _selectedAge,
                  onOptionSelected: (value) =>
                      setState(() => _selectedAge = value),
                ),
                const SizedBox(height: 24),
                _buildButtons(),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDragHandle() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Center(
        child: Container(
          width: 40,
          height: 5,
          decoration: BoxDecoration(
            color: Colors.grey[300],
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      ),
    );
  }

  Widget _buildFilterTitle() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text(
          'Filter Options',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        IconButton(
          onPressed: widget.onClose ?? () {},
          icon: const Icon(Icons.close),
          splashRadius: 20,
        ),
      ],
    );
  }

  Widget _buildFilterCategory({
    required int index,
    required String title,
    required List<String> options,
    required String? selectedValue,
    required Function(String) onOptionSelected,
  }) {
    bool isExpanded = _expandedIndex == index;

    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          InkWell(
            onTap: () {
              setState(() {
                if (isExpanded) {
                  _expandedIndex = null;
                } else {
                  _expandedIndex = index;
                }
              });
            },
            borderRadius: BorderRadius.circular(12),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Icon(
                    isExpanded
                        ? Icons.keyboard_arrow_up
                        : Icons.keyboard_arrow_down,
                    color: Colors.grey[600],
                  ),
                ],
              ),
            ),
          ),
          if (isExpanded)
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: options.length,
              itemBuilder: (context, i) {
                return RadioListTile<String>(
                  title: Text(options[i]),
                  value: options[i],
                  groupValue: selectedValue,
                  onChanged: (value) {
                    if (value != null) {
                      onOptionSelected(value);
                    }
                  },
                  activeColor: ColorConstants.primaryColor,
                  dense: true,
                );
              },
            ),
        ],
      ),
    );
  }

  Widget _buildButtons() {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton(
            onPressed: () {
              setState(() {
                _selectedPrice = null;
                _selectedLanguage = null;
                _selectedExperience = null;
                _selectedAge = null;
                _expandedIndex = null;
              });
            },
            style: ElevatedButton.styleFrom(
              foregroundColor: ColorConstants.primaryColor,
              backgroundColor: Colors.white,
              side: const BorderSide(color: ColorConstants.primaryColor),
              padding: const EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: const Text('Reset'),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: ElevatedButton(
            onPressed: () {
              // Apply filters and close the bottom sheet
              if (widget.onApplyFilters != null) {
                widget.onApplyFilters!(filterValues);
              } else if (widget.onClose != null) {
                widget.onClose!();
              } else {
                Navigator.pop(context);
              }
            },
            style: ElevatedButton.styleFrom(
              foregroundColor: Colors.white,
              backgroundColor: ColorConstants.primaryColor,
              padding: const EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: const Text('Apply'),
          ),
        ),
      ],
    );
  }
}

// Example of usage with async/await to get filter results
class ExampleUsage extends StatelessWidget {
  const ExampleUsage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: () async {
        // Show filter bottom sheet and await results
        final filters = await CustomFilterBottomSheet.show(context);

        if (filters != null) {
          // Process the returned filters
          print('Selected filters: $filters');

          // Apply filters to your UI or data
          // ...
        }
      },
      icon: const Icon(Icons.filter_list),
    );
  }
}
