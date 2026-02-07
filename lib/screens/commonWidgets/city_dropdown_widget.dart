import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';
import 'package:rwd/api/api_model/cityModel.dart' as cm;

import '../../utils/common_utils.dart';

class CityDropdownWidget extends StatelessWidget {
  final List<cm.Data> cityList;
  final bool isReadonly;
  final String? selectedCity;
  final Function(String?) onChanged;

  const CityDropdownWidget({
    super.key,
     this.isReadonly=false,
    required this.cityList,
    required this.selectedCity,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return DropdownSearch<cm.Data>(
      items: (filter, loadProps) {
        return cityList;
      },
      enabled: !isReadonly,
      compareFn: (item1, item2) {
        return item1.name == item2.name;
      },
      selectedItem: cityList.where((s) => s.sId == selectedCity).isNotEmpty
          ? cityList.firstWhere((s) => s.sId == selectedCity)
          : null,
      itemAsString: (cm.Data state) => state.name ?? '',
      decoratorProps: DropDownDecoratorProps(
        decoration: InputDecoration(
          hintText: 'Search City',
          labelStyle: CommonUtils.commonTextLabelsStyle(fontSize: 12),
          hintStyle: CommonUtils.commonTextLabelsStyle(fontSize: 12),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        ),
      ),
      popupProps: PopupProps.menu(
        showSearchBox: true,
        searchFieldProps: TextFieldProps(
          decoration: InputDecoration(
            hintText: 'Search city',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
        itemBuilder: (context, item, isDisabled, isSelected) {
          return Padding(
            padding: const EdgeInsets.all(12),
            child: Text(
              item.name ?? '',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[800],
              ),
            ),
          );
        },
      ),
      onChanged: (cm.Data? value) {
        onChanged(value?.sId);
      },
      validator: (value) {
        if (value == null) {
          return 'Please select a city';
        }
        return null;
      },
    );
  }
}
