import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../../../constants/color_constants.dart';
import '../../../constants/token_manager.dart';

class StateCityData {
  final String state;
  final List<String> cities;

  StateCityData({required this.state, required this.cities});

  factory StateCityData.fromJson(Map<String, dynamic> json) {
    return StateCityData(
      state: json['state'],
      cities: List<String>.from(json['city']),
    );
  }
}

class StateCityDropdownWidget extends StatefulWidget {
  final TextEditingController stateController;
  final TextEditingController cityController;
  final String baseUrl;
  final String? Function(String?)? stateValidator;
  final String? Function(String?)? cityValidator;

  const StateCityDropdownWidget({
    Key? key,
    required this.stateController,
    required this.cityController,
    required this.baseUrl,
    this.stateValidator,
    this.cityValidator,
  }) : super(key: key);

  @override
  State<StateCityDropdownWidget> createState() =>
      _StateCityDropdownWidgetState();
}

class _StateCityDropdownWidgetState extends State<StateCityDropdownWidget> {
  List<StateCityData> _statesCities = [];
  bool _isLoading = true;
  String? _selectedState;
  String? _selectedCity;

  @override
  void initState() {
    super.initState();
    _selectedState = widget.stateController.text.isEmpty
        ? null
        : widget.stateController.text;
    _selectedCity =
        widget.cityController.text.isEmpty ? null : widget.cityController.text;
    _fetchStatesCities();
  }

  Future<void> _fetchStatesCities() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final token = await TokenManager.getToken();

      if (token == null) {
        throw Exception('No authentication token available');
      }

      final response = await http.get(
        Uri.parse('${widget.baseUrl}/user/state-city'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);

        if (jsonData['status'] == true && jsonData['data'] != null) {
          setState(() {
            _statesCities = List<StateCityData>.from(
                jsonData['data'].map((data) => StateCityData.fromJson(data)));
            _isLoading = false;
          });
        } else {
          throw Exception('API returned false status: ${jsonData['message']}');
        }
      } else if (response.statusCode == 401) {
        throw Exception('Authentication failed - please login again');
      } else {
        throw Exception('Failed to load data: ${response.statusCode}');
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });

      debugPrint('Error fetching state/city data: $e');

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.toString()}')),
      );
    }
  }

  List<String> _getCitiesForState(String? state) {
    if (state == null) return [];
    final stateData = _statesCities.firstWhere(
      (element) => element.state == state,
      orElse: () => StateCityData(state: '', cities: []),
    );
    return stateData.cities;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          constraints: const BoxConstraints(minHeight: 52),
          decoration: BoxDecoration(
            color: ColorConstants.white,
            boxShadow: [
              BoxShadow(
                color: ColorConstants.primaryColor.withAlpha(80),
                blurRadius: 2,
                offset: const Offset(0, 2),
              ),
            ],
            borderRadius: BorderRadius.circular(4),
          ),
          child: DropdownButtonFormField<String>(
            padding: EdgeInsets.zero,
            isDense: true,
            decoration: InputDecoration(
              labelText: 'State',
              border: const OutlineInputBorder(),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 12, 
                vertical: 8
              ),
            ),
            value: _selectedState,
            hint: _isLoading
                ? const Text('Loading...')
                : const Text('Select State'),
            items: _statesCities.map((stateCity) {
              return DropdownMenuItem<String>(
                value: stateCity.state,
                child: Text(stateCity.state),
              );
            }).toList(),
            onChanged: (value) {
              setState(() {
                _selectedState = value;
                _selectedCity = null;
                widget.stateController.text = value ?? '';
                widget.cityController.text = '';
              });
            },
            validator: widget.stateValidator,
          ),
        ),
        const SizedBox(height: 16),

        Container(
          constraints: const BoxConstraints(minHeight: 52),
          decoration: BoxDecoration(
            color: ColorConstants.white,
            boxShadow: [
              BoxShadow(
                color: ColorConstants.primaryColor.withAlpha(80),
                blurRadius: 2,
                offset: const Offset(0, 2),
              ),
            ],
            borderRadius: BorderRadius.circular(4),
          ),
          child: DropdownButtonFormField<String>(
            decoration: InputDecoration(
              labelText: 'City',
              border: const OutlineInputBorder(),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 12, 
                vertical: 8
              ),
            ),
            value: _selectedCity,
            hint: _selectedState == null
                ? const Text('Select State first')
                : _getCitiesForState(_selectedState).isEmpty
                    ? const Text('No cities available')
                    : const Text('Select City'),
            items: _getCitiesForState(_selectedState).map((city) {
              return DropdownMenuItem<String>(
                value: city,
                child: Text(city),
              );
            }).toList(),
            onChanged: _selectedState == null ||
                _getCitiesForState(_selectedState).isEmpty
                ? null
                : (value) {
              setState(() {
                _selectedCity = value;
                widget.cityController.text = value ?? '';
              });
            },
            validator: widget.cityValidator,
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }
}