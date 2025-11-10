import 'package:flutter/material.dart';
import 'package:r_w_r/api/api_model/e_rikshawModel.dart';

class ProfileViewModel extends ChangeNotifier {
  ERikshawModel? eRikshawModel;
  bool _isLoading = false;
  String? _error;

  ERikshawModel? get driverProfile => eRikshawModel;
  bool get isLoading => _isLoading;
  String? get error => _error;

  void setDriverProfile(Map<String, dynamic> apiData) {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      eRikshawModel = ERikshawModel.fromJson(apiData);
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  void updateRating(double newRating) {
    if (eRikshawModel != null) {
      notifyListeners();
    }
  }
}
