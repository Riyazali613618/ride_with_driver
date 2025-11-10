import 'package:flutter/material.dart';
import 'package:r_w_r/constants/color_constants.dart';

import '../../api/api_model/filter_model.dart';
import '../../api/api_service/filter_service.dart';
import '../../l10n/app_localizations.dart';

class FilterBottomSheet extends StatefulWidget {
  final ScrollController? scrollController;
  final VoidCallback? onClose;
  final Function(Map<String, dynamic>)? onApplyFilters;
  final FilterService filterService;
  final String? filterType;

  const FilterBottomSheet({
    Key? key,
    this.scrollController,
    this.onClose,
    this.onApplyFilters,
    this.filterType,
    required this.filterService,
  }) : super(key: key);

  static Future<Map<String, dynamic>?> show(
      BuildContext context,
      FilterService filterService, {
        String? filterType,
      }) async {
    return await showModalBottomSheet<Map<String, dynamic>>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.5,
          minChildSize: 0.1,
          maxChildSize: 0.9,
          builder: (context, scrollController) {
            return FilterBottomSheet(
              scrollController: scrollController,
              onClose: () => Navigator.pop(context),
              onApplyFilters: (filters) {
                Navigator.pop(context, filters);
              },
              filterService: filterService,
              filterType: filterType,
            );
          },
        );
      },
    );
  }

  @override
  State<FilterBottomSheet> createState() => _FilterBottomSheetState();
}

class _FilterBottomSheetState extends State<FilterBottomSheet> {
  int? _expandedIndex;
  List<FilterModel> _filters = [];
  bool _isLoading = true;
  String? _error;

  // Store selected values for each filter
  final Map<String, dynamic> _selectedFilters = {};

  @override
  void initState() {
    super.initState();
    _loadFilters();
  }

  Future<void> _loadFilters() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      print("Starting to load filters");
      final response = await widget.filterService.fetchFilters(widget.filterType.toString());
      print("Filter response received: $response");

      if (response['status'] == true) {
        final dataList = response['data'] as List;
        print("Filter data count: ${dataList.length}");

        setState(() {
          _filters =
              dataList.map((item) => FilterModel.fromJson(item)).toList();
          _isLoading = false;
        });
        print("Filters loaded successfully: ${_filters.length} filters");
      } else {
        setState(() {
          _error = response['message'] ?? 'Failed to load filters';
          _isLoading = false;
        });
        print("Error loading filters: $_error");
      }
    } catch (e) {
      print("Exception during filter loading: $e");
      setState(() {
        _error = 'Failed to load filters: $e';
        _isLoading = false;
      });
    }
  }

  void _onOptionSelected(String filterName, dynamic value) {
    setState(() {
      if (_selectedFilters[filterName] == value) {
        // If the same value is selected, deselect it
        _selectedFilters.remove(filterName);
      } else {
        _selectedFilters[filterName] = value;
      }
    });
  }

  void _onMultipleOptionSelected(String filterName, String value) {
    setState(() {
      if (!_selectedFilters.containsKey(filterName)) {
        _selectedFilters[filterName] = [];
      }

      final currentValues =
          List<String>.from(_selectedFilters[filterName] ?? []);
      if (currentValues.contains(value)) {
        currentValues.remove(value);
      } else {
        currentValues.add(value);
      }

      _selectedFilters[filterName] = currentValues;
    });
  }

  void _resetFilters() {
    setState(() {
      _selectedFilters.clear();
      _expandedIndex = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;

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
            child: _isLoading
                ? _buildLoading()
                : _error != null
                    ? _buildError()
                    : ListView(
                        controller: widget.scrollController,
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        children: [
                          const SizedBox(height: 8),
                          _buildFilterTitle(),
                          const SizedBox(height: 16),
                          ..._buildFilterCategories(),
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

  Widget _buildLoading() {
    return const Center(
      child: CircularProgressIndicator(),
    );
  }

  Widget _buildError() {
    final localizations = AppLocalizations.of(context)!;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            _error!,
            style: const TextStyle(color: Colors.red),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _loadFilters,
            child: Text(localizations.retry),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildFilterCategories() {
    return List.generate(_filters.length, (index) {
      final filter = _filters[index];
      final isExpanded = _expandedIndex == index;

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
                      _formatFilterName(filter.name),
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
              filter.multiple
                  ? _buildMultipleSelectionOptions(filter)
                  : _buildSingleSelectionOptions(filter),
          ],
        ),
      );
    });
  }

  String _formatFilterName(String name) {
    // Convert names like "ac/nonAc" to "AC/Non AC"
    return name
        .replaceAll('/', ' / ')
        .split(' ')
        .map((word) => word.isNotEmpty
            ? word[0].toUpperCase() + (word.length > 1 ? word.substring(1) : '')
            : '')
        .join(' ');
  }

  Widget _buildSingleSelectionOptions(FilterModel filter) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: filter.values.length,
      itemBuilder: (context, i) {
        final value = filter.values[i];
        final isSelected = _selectedFilters[filter.name] == value;

        return RadioListTile<String>(
          title: Text(value),
          value: value,
          groupValue: isSelected ? value : null,
          onChanged: (_) => _onOptionSelected(filter.name, value),
          activeColor: ColorConstants.primaryColor,
          dense: true,
        );
      },
    );
  }

  Widget _buildMultipleSelectionOptions(FilterModel filter) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: filter.values.length,
      itemBuilder: (context, i) {
        final value = filter.values[i];
        final selectedValues =
            List<String>.from(_selectedFilters[filter.name] ?? []);
        final isSelected = selectedValues.contains(value);

        return CheckboxListTile(
          title: Text(value),
          value: isSelected,
          onChanged: (_) => _onMultipleOptionSelected(filter.name, value),
          activeColor: ColorConstants.primaryColor,
          dense: true,
        );
      },
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
    final localizations = AppLocalizations.of(context)!;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          localizations.filter_options,
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

  Widget _buildButtons() {
    final localizations = AppLocalizations.of(context)!;

    return Row(
      children: [
        Expanded(
          child: ElevatedButton(
            onPressed: _resetFilters,
            style: ElevatedButton.styleFrom(
              foregroundColor: ColorConstants.primaryColor,
              backgroundColor: Colors.white,
              side: const BorderSide(color: ColorConstants.primaryColor),
              padding: const EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: Text(localizations.reset),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: ElevatedButton(
            onPressed: () {
              if (widget.onApplyFilters != null) {
                widget.onApplyFilters!(_selectedFilters);
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
            child: Text(localizations.apply),
          ),
        ),
      ],
    );
  }
}
