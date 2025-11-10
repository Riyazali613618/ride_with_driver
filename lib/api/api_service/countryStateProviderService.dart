import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:r_w_r/api/api_model/stateModel.dart' as sm;
import 'package:r_w_r/constants/api_constants.dart';
import 'package:r_w_r/api/api_model/cityModel.dart' as cM;

import '../api_model/countryModel.dart' as cm;

class LocationProvider with ChangeNotifier {
  // API data
  List<cm.Data> _countries = [];
  List<sm.Data> _states = [];
  List<cM.Data> _cities = [];
  // Selected values
  String? _selectedCountry;
  String? _selectedState;
  // Getters
  List<cm.Data> get countries => _countries;
  List<sm.Data> get states => _states;
  List<cM.Data> get cities => _cities;
  String? get selectedCountry => _selectedCountry;
  String? get selectedState => _selectedState;

  // Fetch countries
  Future<void> fetchCountries() async {
    final url = Uri.parse("${ApiConstants.baseUrl}/public/countries");
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final json = jsonDecode(response.body);
      final countryModel = cm.CountryModel.fromJson(json);
      _countries = countryModel.data ?? [];
      notifyListeners();
    } else {
      throw Exception("Failed to load countries");
    }
  }

  // Fetch states based on selected country
  Future<void> fetchStates(String country) async {
    print("country id:${country}");
    print("country id:${ApiConstants.baseUrl}/public/countries/$country/states");
    final url = Uri.parse("${ApiConstants.baseUrl}/public/countries/$country/states");
    final response = await http.get(url);
    if (response.statusCode == 200) {
      final json = jsonDecode(response.body);
      final stateModel = sm.StateModel.fromJson(json);
      _states = stateModel.data ?? [];
      notifyListeners();
    } else {
      throw Exception("Failed to load states");
    }
  }

  Future<void> fetchCity(String state) async {
    print("fetchCity:$state");
    final url = Uri.parse("${ApiConstants.baseUrl}/public/states/$state/cities");
    final response = await http.get(url);
    if (response.statusCode == 200) {
      final json = jsonDecode(response.body);
      final cityModel = cM.CityModel.fromJson(json);
      _cities = cityModel.data ?? [];
      notifyListeners();
    } else {
      throw Exception("Failed to load states");
    }
  }

  // Set selected country
  void setCountry(String country) {
    _selectedCountry = country;
    _selectedState = null; // reset state when country changes
    fetchStates(country);
    notifyListeners();
  }

  void setSelectedCountry(String selectedCountryId){
    _selectedCountry=selectedCountryId;
    print("_selectedCountry:${_selectedCountry}");
    print("${selectedCountry}");
    notifyListeners();
  }

  // Set selected state
  void setStateValue(String state) {
    _selectedState = state;
    notifyListeners();
  }
}
