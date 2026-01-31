import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:rwd/api/api_model/stateModel.dart' as sm;

import '../../utils/common_utils.dart';

class StateDropdownWidget extends StatelessWidget {
  final List<sm.Data> stateList;
  final String? selectedState;
  final Function(String?) onChanged;

  const StateDropdownWidget({
    super.key,
    required this.stateList,
    required this.selectedState,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return DropdownSearch<sm.Data>(
      items: (filter, loadProps) {
        return stateList;
      },
      compareFn: (item1, item2) {
        return item1.name == item2.name;
      },
      selectedItem: stateList
          .where((s) => s.sId == selectedState)
          .isNotEmpty
          ? stateList.firstWhere((s) => s.sId == selectedState)
          : null,

      itemAsString: (sm.Data state) => state.name ?? '',

      decoratorProps: DropDownDecoratorProps(
        decoration: InputDecoration(
          hintText: 'Select Type',
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
            hintText: 'Search state',
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

      onChanged: (sm.Data? value) {
        onChanged(value?.sId);
      },

      validator: (value) {
        if (value == null) {
          return 'Please select a state';
        }
        return null;
      },
    );
  }
}
