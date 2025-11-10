// import 'package:flutter/foundation.dart';
//
// import '../../../api/api_model/filter_model.dart';
// import '../../../api/api_service/filter_service.dart';
//
// class FilterProvider extends ChangeNotifier {
//   List<FilterModel> _filters = [];
//   bool _isLoading = false;
//   String? _error;
//   Map<String, List<String>> _selectedFilters = {};
//
//   List<FilterModel> get filters => _filters;
//   bool get isLoading => _isLoading;
//   String? get error => _error;
//   Map<String, List<String>> get selectedFilters => _selectedFilters;
//
//   Future<void> fetchFilters() async {
//     try {
//       _isLoading = true;
//       _error = null;
//       notifyListeners();
//
//       final response = await FilterService.fat();
//       _filters = response.data;
//
//       // Initialize selected filters
//       _selectedFilters = {};
//       for (var filter in _filters) {
//         _selectedFilters[filter.name] = [];
//       }
//     } catch (e) {
//       _error = e.toString();
//     } finally {
//       _isLoading = false;
//       notifyListeners();
//     }
//   }
//
//   void updateFilter(String filterName, String value, bool isSelected) {
//     final filter = _filters.firstWhere((f) => f.name == filterName);
//
//     if (filter.multiple) {
//       if (isSelected) {
//         _selectedFilters[filterName]?.add(value);
//       } else {
//         _selectedFilters[filterName]?.remove(value);
//       }
//     } else {
//       _selectedFilters[filterName] = isSelected ? [value] : [];
//     }
//
//     notifyListeners();
//   }
//
//   void resetFilters() {
//     for (var key in _selectedFilters.keys) {
//       _selectedFilters[key] = [];
//     }
//     notifyListeners();
//   }
//
//   Map<String, dynamic> getAppliedFilters() {
//     final Map<String, dynamic> appliedFilters = {};
//     _selectedFilters.forEach((key, value) {
//       if (value.isNotEmpty) {
//         appliedFilters[key] = value;
//       }
//     });
//     return appliedFilters;
//   }
// }
