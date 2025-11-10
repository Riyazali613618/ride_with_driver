import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:r_w_r/constants/api_constants.dart';
import 'package:r_w_r/constants/color_constants.dart';
import 'package:r_w_r/constants/token_manager.dart';

import '../../api/api_model/vehicle/add_vehicle_model.dart';
import '../../components/app_appbar.dart';
import '../../components/custom_text_field.dart';
import '../../components/video_image_player_widget.dart';

class VehicleDetailsScreen extends StatefulWidget {
  final String? vehicleId;
  final Vehicle? vehicle;

  const VehicleDetailsScreen({
    Key? key,
    this.vehicleId,
    this.vehicle,
  }) : super(key: key);

  @override
  State<VehicleDetailsScreen> createState() => _VehicleDetailsScreenState();
}

class _VehicleDetailsScreenState extends State<VehicleDetailsScreen> {
  bool _isLoading = true;
  bool _isEditing = false;
  bool _isSaving = false;
  bool _isDeleting = false;
  String _errorMessage = '';
  Vehicle? _vehicle;
  String _selectedAction = 'ENABLE';
  bool _isProcessingAction = false;

  // Form controllers
  final _formKey = GlobalKey<FormState>();
  final _vehicleNameController = TextEditingController();
  final _vehicleModelNameController = TextEditingController();
  final _manufacturingController = TextEditingController();
  final _maxPowerController = TextEditingController();
  final _maxSpeedController = TextEditingController();
  final _fuelTypeController = TextEditingController();
  final _milageController = TextEditingController();
  final _registrationDateController = TextEditingController();
  final _vehicleNumberController = TextEditingController();
  final _vehicleSpecificationsController = TextEditingController();
  final _servedLocationController = TextEditingController();
  final _minimumChargeController = TextEditingController();
  final _vehicleOwnershipController = TextEditingController();
  final _first2KmController = TextEditingController();
  final _airConditioningController = TextEditingController();
  final _vehicleTypeController = TextEditingController();
  final _seatingCapacityController = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.vehicle != null) {
      _vehicle = widget.vehicle;
      _initializeControllers();
      _isLoading = false;
    } else if (widget.vehicleId != null) {
      _fetchVehicleDetails(widget.vehicleId!);
    }
  }

  void _initializeControllers() {
    if (_vehicle != null) {
      _vehicleNameController.text = _vehicle!.vehicleName;
      _vehicleModelNameController.text = _vehicle!.vehicleModelName;
      _manufacturingController.text = _vehicle!.manufacturing;
      _maxPowerController.text = _vehicle!.maxPower ?? '';
      _maxSpeedController.text = _vehicle!.maxSpeed ?? '';
      _fuelTypeController.text = _vehicle!.fuelType;
      _milageController.text = _vehicle!.milage ?? '';
      _registrationDateController.text = _vehicle!.registrationDate ?? '';
      _vehicleNumberController.text = _vehicle!.vehicleNumber;
      _vehicleSpecificationsController.text =
          _vehicle!.vehicleSpecifications.join(', ');
      _servedLocationController.text = _vehicle!.servedLocation.join(', ');
      _minimumChargeController.text = _vehicle!.minimumChargePerHour.toString();
      _vehicleOwnershipController.text = _vehicle!.vehicleOwnership;
      _first2KmController.text = _vehicle!.first2Km.toString();
      _airConditioningController.text = _vehicle!.airConditioning;
      _vehicleTypeController.text = _vehicle!.vehicleType;
      _seatingCapacityController.text = _vehicle!.seatingCapacity.toString();
    }
  }

  Future<void> _fetchVehicleDetails(String vehicleId) async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      String? token = await TokenManager.getToken();

      if (token == null) {
        throw Exception('Authentication token not found');
      }

      final response = await http.get(
        Uri.parse('${ApiConstants.baseUrl}/user/vehicle/vehicle/$vehicleId'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        if (data['success'] == true) {
          setState(() {
            _vehicle = Vehicle.fromJson(data['data']);
            _initializeControllers();
            _isLoading = false;
          });
        } else {
          throw Exception(data['message'] ?? 'Failed to load vehicle details');
        }
      } else {
        throw Exception('Failed to load vehicle details');
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = e.toString();
      });
    }
  }

  Future<void> _updateVehicleDetails() async {
    if (_formKey.currentState?.validate() != true) {
      return;
    }

    setState(() {
      _isSaving = true;
      _errorMessage = '';
    });

    try {
      String? token = await TokenManager.getToken();

      if (token == null) {
        throw Exception('Authentication token not found');
      }

      // Parse comma-separated strings to List<String>
      List<String> vehicleSpecifications = _vehicleSpecificationsController.text
          .split(',')
          .map((e) => e.trim())
          .where((e) => e.isNotEmpty)
          .toList();

      List<String> servedLocation = _servedLocationController.text
          .split(',')
          .map((e) => e.trim())
          .where((e) => e.isNotEmpty)
          .toList();

      final Map<String, dynamic> updateData = {
        'vehicleName': _vehicleNameController.text,
        'vehicleModelName': _vehicleModelNameController.text,
        'manufacturing': _manufacturingController.text,
        'maxPower': _maxPowerController.text,
        'maxSpeed': _maxSpeedController.text,
        'fuelType': _fuelTypeController.text,
        'milage': _milageController.text,
        'registrationDate': _registrationDateController.text,
        'vehicleNumber': _vehicleNumberController.text,
        'vehicleSpecifications': vehicleSpecifications,
        'servedLocation': servedLocation,
        'minimumChargePerHour':
            int.tryParse(_minimumChargeController.text) ?? 0,
        'vehicleOwnership': _vehicleOwnershipController.text,
        'first2Km': int.tryParse(_first2KmController.text) ?? 0,
        'airConditioning': _airConditioningController.text,
        'vehicleType': _vehicleTypeController.text,
        'seatingCapacity': int.tryParse(_seatingCapacityController.text) ?? 0,
      };

      final response = await http.put(
        Uri.parse(
            '${ApiConstants.baseUrl}/user/vehicle/edit-vehicle/${_vehicle!.id}'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode(updateData),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        if (data['success'] == true) {
          setState(() {
            // _vehicle = Vehicle.fromJson(data['data']);
            _initializeControllers();
            _isSaving = false;
            _isEditing = false;
          });
          _showSuccessSnackBar('Vehicle details updated successfully');
        } else {
          throw Exception(
              data['message'] ?? 'Failed to update vehicle details');
        }
      } else {
        throw Exception('Failed to update vehicle details');
      }
    } catch (e) {
      setState(() {
        _isSaving = false;
      });
      _showErrorSnackBar('Error: ${e.toString()}');
    }
  }

  Future<void> _deleteVehicle() async {
    setState(() {
      _isDeleting = true;
    });

    try {
      String? token = await TokenManager.getToken();

      if (token == null) {
        throw Exception('Authentication token not found');
      }

      final response = await http.delete(
        Uri.parse(
            '${ApiConstants.baseUrl}/user/vehicle/delete-vehicle/${_vehicle!.id}'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        if (data['success'] == true) {
          _showSuccessSnackBar('Vehicle deleted successfully');
          Navigator.pop(context, true);
        } else {
          throw Exception(data['message'] ?? 'Failed to delete vehicle');
        }
      } else {
        throw Exception('Failed to delete vehicle');
      }
    } catch (e) {
      setState(() {
        _isDeleting = false;
      });
      _showErrorSnackBar('Error: ${e.toString()}');
    }
  }

  void _showDeleteConfirmationDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Row(
            children: [
              Icon(
                Icons.warning_amber_rounded,
                color: Colors.red,
                size: 28,
              ),
              SizedBox(width: 12),
              Text(
                'Delete Vehicle',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.red,
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Are you sure you want to delete this vehicle?',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[700],
                ),
              ),
              SizedBox(height: 12),
              Container(
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey[300]!),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.directions_car,
                      color: ColorConstants.primaryColor,
                      size: 20,
                    ),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        '${_vehicle!.vehicleName} (${_vehicle!.vehicleNumber})',
                        style: TextStyle(
                          fontWeight: FontWeight.w500,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 12),
              Text(
                'This action cannot be undone.',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.red[600],
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                'Cancel',
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: _isDeleting
                  ? null
                  : () {
                      Navigator.pop(context);
                      _deleteVehicle();
                    },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
              child: _isDeleting
                  ? SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    )
                  : Text(
                      'Delete',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
            ),
          ],
        );
      },
    );
  }

  void _showVehicleActionsDialog() {
    // Smart default selection based on current vehicle status
    if (_vehicle!.isDisabled) {
      _selectedAction = 'ENABLE'; // If disabled, suggest enabling
    } else {
      _selectedAction = 'DISABLE'; // If enabled, suggest disabling
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return Dialog(
              insetPadding:
                  const EdgeInsets.symmetric(horizontal: 16.0, vertical: 24.0),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: SingleChildScrollView(
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    maxWidth: MediaQuery.of(context).size.width * 0.9,
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Title Row
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Icon(
                              Icons.settings,
                              color: ColorConstants.primaryColor,
                              size: 28,
                            ),
                            const SizedBox(width: 12),
                            Flexible(
                              child: Text(
                                'Vehicle Actions',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.grey[800],
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),

                        // Description text
                        Text(
                          'Select an action for this vehicle:',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey[700],
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Vehicle info card
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.grey[100],
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.grey[300]!),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Icon(
                                    Icons.directions_car,
                                    color: ColorConstants.primaryColor,
                                    size: 20,
                                  ),
                                  const SizedBox(width: 8),
                                  Flexible(
                                    child: Text(
                                      '${_vehicle!.vehicleName} (${_vehicle!.vehicleNumber})',
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w500,
                                        fontSize: 14,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                      maxLines: 2,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Wrap(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 8, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: _vehicle!.isDisabled
                                          ? Colors.red.withOpacity(0.1)
                                          : Colors.green.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(
                                        color: _vehicle!.isDisabled
                                            ? Colors.red.withOpacity(0.3)
                                            : Colors.green.withOpacity(0.3),
                                      ),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(
                                          _vehicle!.isDisabled
                                              ? Icons.visibility_off
                                              : Icons.visibility,
                                          size: 12,
                                          color: _vehicle!.isDisabled
                                              ? Colors.red
                                              : Colors.green,
                                        ),
                                        const SizedBox(width: 4),
                                        Text(
                                          _vehicle!.isDisabled
                                              ? 'Disabled'
                                              : 'Enabled',
                                          style: TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.w500,
                                            color: _vehicle!.isDisabled
                                                ? Colors.red
                                                : Colors.green,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Action options
                        Column(
                          children: [
                            _buildActionRadioTile(
                              value: 'DELETE',
                              icon: Icons.delete,
                              color: Colors.red,
                              title: 'Delete Vehicle',
                              subtitle: 'Permanently remove this vehicle',
                              setDialogState: setDialogState,
                            ),
                            if (!_vehicle!.isDisabled)
                              _buildActionRadioTile(
                                value: 'DISABLE',
                                icon: Icons.visibility_off,
                                color: Colors.orange,
                                title: 'Disable Vehicle',
                                subtitle: 'Hide this vehicle from listings',
                                setDialogState: setDialogState,
                              ),
                            if (_vehicle!.isDisabled)
                              _buildActionRadioTile(
                                value: 'ENABLE',
                                icon: Icons.visibility,
                                color: Colors.green,
                                title: 'Enable Vehicle',
                                subtitle:
                                    'Make this vehicle visible in listings',
                                setDialogState: setDialogState,
                              ),
                          ],
                        ),

                        // Warning message
                        const SizedBox(height: 16),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: _getActionColor(_selectedAction)
                                .withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: _getActionColor(_selectedAction)
                                  .withOpacity(0.3),
                            ),
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(top: 2.0),
                                child: Icon(
                                  _selectedAction == 'DELETE'
                                      ? Icons.warning_amber_rounded
                                      : Icons.info_outline,
                                  color: _getActionColor(_selectedAction),
                                  size: 16,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  _getActionWarningText(_selectedAction),
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: _getActionColor(_selectedAction),
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        // Buttons
                        const SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            TextButton(
                              onPressed: () => Navigator.pop(context),
                              child: Text(
                                'Cancel',
                                style: TextStyle(
                                  color: Colors.grey[600],
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            ElevatedButton(
                              onPressed: _isProcessingAction
                                  ? null
                                  : () {
                                      Navigator.pop(context);
                                      _performVehicleAction(_selectedAction);
                                    },
                              style: ElevatedButton.styleFrom(
                                backgroundColor:
                                    _getActionColor(_selectedAction),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 16, vertical: 12),
                              ),
                              child: _isProcessingAction
                                  ? const SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(
                                        color: Colors.white,
                                        strokeWidth: 2,
                                      ),
                                    )
                                  : Text(
                                      _getActionButtonText(_selectedAction),
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

// Helper widget for action radio tiles
  Widget _buildActionRadioTile({
    required String value,
    required IconData icon,
    required Color color,
    required String title,
    required String subtitle,
    required Function(Function()) setDialogState,
  }) {
    return RadioListTile<String>(
      contentPadding: EdgeInsets.zero,
      visualDensity: const VisualDensity(
        horizontal: VisualDensity.minimumDensity,
        vertical: VisualDensity.minimumDensity,
      ),
      title: Row(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 8),
          Flexible(
            child: Text(
              title,
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
      subtitle: Padding(
        padding: const EdgeInsets.only(left: 28.0),
        child: Text(
          subtitle,
          style: TextStyle(color: Colors.grey[600], fontSize: 12),
        ),
      ),
      value: value,
      groupValue: _selectedAction,
      activeColor: color,
      onChanged: (value) {
        setDialogState(() {
          _selectedAction = value!;
        });
      },
    );
  }

  Future<void> _performVehicleAction(String action) async {
    setState(() {
      _isProcessingAction = true;
    });

    try {
      String? token = await TokenManager.getToken();

      if (token == null) {
        throw Exception('Authentication token not found');
      }

      String endpoint;
      String successMessage;

      if (action == 'DELETE') {
        endpoint =
            '${ApiConstants.baseUrl}/user/vehicle/delete-vehicle/${_vehicle!.id}';
        successMessage = 'Vehicle deleted successfully';
      } else {
        endpoint =
            '${ApiConstants.baseUrl}/user/vehicle/delete-vehicle/${_vehicle!.id}?action=$action';
        successMessage = action == 'DISABLE'
            ? 'Vehicle disabled successfully'
            : 'Vehicle enabled successfully';
      }

      final response = await http.delete(
        Uri.parse(endpoint),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        if (data['success'] == true) {
          _showSuccessSnackBar(successMessage);

          if (action == 'DELETE') {
            Navigator.pop(context, true); // Return true to indicate deletion
          } else {
            // For enable/disable, you might want to refresh the vehicle data
            // or update the UI to reflect the new status
            if (widget.vehicleId != null) {
              _fetchVehicleDetails(widget.vehicleId!);
            } else if (widget.vehicle != null) {
              setState(() {});
            }
          }
        } else {
          throw Exception(data['message'] ?? 'Failed to perform action');
        }
      } else {
        throw Exception('Failed to perform action');
      }
    } catch (e) {
      _showErrorSnackBar('Error: ${e.toString()}');
    } finally {
      setState(() {
        _isProcessingAction = false;
      });
    }
  }

  Color _getActionColor(String action) {
    switch (action) {
      case 'DELETE':
        return Colors.red;
      case 'DISABLE':
        return Colors.orange;
      case 'ENABLE':
        return Colors.green;
      default:
        return ColorConstants.primaryColor;
    }
  }

// Helper method to get action warning text
  String _getActionWarningText(String action) {
    switch (action) {
      case 'DELETE':
        return 'This action cannot be undone.';
      case 'DISABLE':
        return 'Vehicle will be hidden from listings.';
      case 'ENABLE':
        return 'Vehicle will be visible in listings.';
      default:
        return '';
    }
  }

// Helper method to get action button text
  String _getActionButtonText(String action) {
    switch (action) {
      case 'DELETE':
        return 'Delete';
      case 'DISABLE':
        return 'Disable';
      case 'ENABLE':
        return 'Enable';
      default:
        return 'Confirm';
    }
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(Icons.check_circle, color: Colors.white),
            SizedBox(width: 8),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(Icons.error, color: Colors.white),
            SizedBox(width: 8),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  @override
  void dispose() {
    _vehicleNameController.dispose();
    _vehicleModelNameController.dispose();
    _manufacturingController.dispose();
    _maxPowerController.dispose();
    _maxSpeedController.dispose();
    _fuelTypeController.dispose();
    _milageController.dispose();
    _registrationDateController.dispose();
    _vehicleNumberController.dispose();
    _vehicleSpecificationsController.dispose();
    _servedLocationController.dispose();
    _minimumChargeController.dispose();
    _vehicleOwnershipController.dispose();
    _first2KmController.dispose();
    _airConditioningController.dispose();
    _vehicleTypeController.dispose();
    _seatingCapacityController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: _buildAppBar(),
      body: _isLoading
          ? _buildLoadingIndicator()
          : _errorMessage.isNotEmpty
              ? _buildErrorWidget()
              : _buildContent(),
      bottomNavigationBar:
          _isLoading || _errorMessage.isNotEmpty ? null : _buildBottomButtons(),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return CustomAppBar(
      title: 'Vehicle Details',
      actions: [
        IconButton(
            onPressed: () {
              _showVehicleActionsDialog();
            },
            icon: Icon(
              CupertinoIcons.ellipsis_vertical_circle,
              color: ColorConstants.white,
            ))
      ],
    );
  }

  Widget _buildLoadingIndicator() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            color: ColorConstants.primaryColor,
            strokeWidth: 3,
          ),
          SizedBox(height: 16),
          Text(
            'Loading vehicle details...',
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorWidget() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.red[50],
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.error_outline,
                color: Colors.red,
                size: 48,
              ),
            ),
            SizedBox(height: 24),
            Text(
              'Error loading vehicle details',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.grey[800],
              ),
            ),
            SizedBox(height: 12),
            Text(
              _errorMessage,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 16,
              ),
            ),
            SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: () {
                if (widget.vehicleId != null) {
                  _fetchVehicleDetails(widget.vehicleId!);
                } else {
                  Navigator.pop(context);
                }
              },
              icon: Icon(Icons.refresh),
              label: Text('Retry'),
              style: ElevatedButton.styleFrom(
                backgroundColor: ColorConstants.primaryColor,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent() {
    return Form(
      key: _formKey,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Vehicle basic details section
            _buildVehicleBasicDetailsSection(),
            SizedBox(height: 24),

            // Vehicle specifications section
            _buildVehicleSpecificationsSection(),
            SizedBox(height: 24),

            // Pricing and location section
            _buildPricingLocationSection(),
            SizedBox(height: 24),

            // Images section
            if (_vehicle!.images.isNotEmpty) ...[
              _buildVehicleImagesSection(),
              SizedBox(height: 24),
            ],

            // Videos section
            if (_vehicle!.videos.isNotEmpty) ...[
              _buildVehicleVideosSection(),
              SizedBox(height: 24),
            ],

            // Documents section
            _buildVehicleDocumentsSection(),
            SizedBox(height: 100), // Space for bottom buttons
          ],
        ),
      ),
    );
  }

  Widget _buildSectionCard(
      {required String title, required List<Widget> children}) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 4,
                  height: 24,
                  decoration: BoxDecoration(
                    color: ColorConstants.primaryColor,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                SizedBox(width: 12),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[800],
                  ),
                ),
              ],
            ),
            SizedBox(height: 20),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildVehicleBasicDetailsSection() {
    return _buildSectionCard(
      title: 'Basic Information',
      children: [
        CustomTextField(
          controller: _vehicleNameController,
          label: 'Vehicle Name',
          enabled: _isEditing,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter vehicle name';
            }
            return null;
          },
        ),
        CustomTextField(
          controller: _vehicleModelNameController,
          label: 'Vehicle Model Name',
          enabled: _isEditing,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter model name';
            }
            return null;
          },
        ),
        CustomTextField(
          controller: _vehicleNumberController,
          label: 'Vehicle Number',
          enabled: _isEditing,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter vehicle number';
            }
            return null;
          },
        ),
        CustomTextField(
          controller: _vehicleOwnershipController,
          label: 'Vehicle Ownership',
          enabled: _isEditing,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter ownership type';
            }
            return null;
          },
        ),
        CustomTextField(
          controller: _vehicleTypeController,
          label: 'Vehicle Type',
          enabled: _isEditing,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter vehicle type';
            }
            return null;
          },
        ),
        _buildInfoItem('Verification Status',
            _vehicle!.isVerified ? 'Verified ✓' : 'Not Verified ✗'),

        // Add vehicle status display
        _buildInfoItem(
            'Vehicle Status', _vehicle!.isDisabled ? 'Disabled ✗' : 'Active ✓'),

        _buildInfoItem('Created Date', _formatDate(_vehicle!.createdAt)),
        _buildInfoItem('Last Updated', _formatDate(_vehicle!.updatedAt)),
      ],
    );
  }

  Widget _buildVehicleSpecificationsSection() {
    return _buildSectionCard(
      title: 'Vehicle Specifications',
      children: [
        CustomTextField(
          controller: _manufacturingController,
          label: 'Manufacturing Year',
          enabled: _isEditing,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter manufacturing year';
            }
            return null;
          },
        ),
        CustomTextField(
          controller: _maxPowerController,
          label: 'Max Power',
          enabled: _isEditing,
        ),
        CustomTextField(
          controller: _maxSpeedController,
          label: 'Max Speed',
          enabled: _isEditing,
        ),
        CustomTextField(
          controller: _fuelTypeController,
          label: 'Fuel Type',
          enabled: _isEditing,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter fuel type';
            }
            return null;
          },
        ),
        CustomTextField(
          controller: _milageController,
          label: 'Mileage',
          enabled: _isEditing,
        ),
        CustomTextField(
          controller: _registrationDateController,
          label: 'Registration Date',
          enabled: _isEditing,
        ),
        CustomTextField(
          controller: _seatingCapacityController,
          label: 'Seating Capacity',
          keyboardType: TextInputType.number,
          enabled: _isEditing,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter seating capacity';
            }
            return null;
          },
        ),
        CustomTextField(
          controller: _airConditioningController,
          label: 'Air Conditioning',
          enabled: _isEditing,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter AC availability';
            }
            return null;
          },
        ),
        CustomTextField(
          controller: _vehicleSpecificationsController,
          label: 'Vehicle Specifications',
          enabled: _isEditing,
          maxLines: 3,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter vehicle specifications';
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildPricingLocationSection() {
    return _buildSectionCard(
      title: 'Pricing & Location',
      children: [
        CustomTextField(
          controller: _minimumChargeController,
          label: 'Minimum Charge (Per Hour)',
          keyboardType: TextInputType.number,
          enabled: _isEditing,
          prefix: Text('${_vehicle!.currency} '),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter minimum charge';
            }
            if (int.tryParse(value) == null) {
              return 'Please enter a valid number';
            }
            return null;
          },
        ),
        CustomTextField(
          controller: _first2KmController,
          label: 'First 2 KM Charge',
          keyboardType: TextInputType.number,
          enabled: _isEditing,
          prefix: Text('${_vehicle!.currency} '),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter first 2km charge';
            }
            return null;
          },
        ),
        CustomTextField(
          controller: _servedLocationController,
          label: 'Served Locations',
          enabled: _isEditing,
          maxLines: 2,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter served locations';
            }
            return null;
          },
        ),
        _buildInfoItem(
            'Price Negotiable', _vehicle!.isPriceNegotiable ? 'Yes' : 'No'),
        _buildInfoItem('Currency', _vehicle!.currency),
      ],
    );
  }

  Widget _buildVehicleImagesSection() {
    return _buildSectionCard(
      title: 'Vehicle Images (${_vehicle!.images.length})',
      children: [
        GridView.builder(
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 1.2,
          ),
          itemCount: _vehicle!.images.length,
          itemBuilder: (context, index) {
            return Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey[300]!),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(
                  _vehicle!.images[index],
                  fit: BoxFit.cover,
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    return Center(
                      child: CircularProgressIndicator(
                        color: ColorConstants.primaryColor,
                        strokeWidth: 2,
                        value: loadingProgress.expectedTotalBytes != null
                            ? loadingProgress.cumulativeBytesLoaded /
                                loadingProgress.expectedTotalBytes!
                            : null,
                      ),
                    );
                  },
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.error_outline,
                            color: Colors.grey[400],
                            size: 24,
                          ),
                          SizedBox(height: 4),
                          Text(
                            'Failed to load',
                            style: TextStyle(
                              color: Colors.grey[500],
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildVehicleVideosSection() {
    return _buildSectionCard(
      title: 'Vehicle Videos (${_vehicle!.videos.length})',
      children: [
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: _vehicle!.videos.length,
          separatorBuilder: (context, index) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            final mediaUrl = _vehicle!.videos[index];

            return GestureDetector(
              onTap: () {
                _openMediaPlayer(
                    context,
                    mediaUrl,
                    // "https://www.sample-videos.com/video321/mp4/720/big_buck_bunny_720p_2mb.mp4",

                    index);
              },
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey[50],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey[200]!),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: ColorConstants.primaryColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Icon(
                        _getMediaIcon(mediaUrl),
                        color: ColorConstants.primaryColor,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${_getMediaTypeText(mediaUrl)} ${index + 1}',
                            style: const TextStyle(
                              fontWeight: FontWeight.w500,
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            mediaUrl,
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 12,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed: () =>
                          _openMediaPlayer(context, mediaUrl, index),
                      icon: Icon(
                        Icons.open_in_new,
                        color: Colors.grey[600],
                        size: 18,
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        )
      ],
    );
  }

  MediaType _detectMediaType(String url) {
    final uri = Uri.tryParse(url);
    if (uri == null) return MediaType.image;

    final extension = uri.pathSegments.isNotEmpty
        ? uri.pathSegments.last.split('.').last.toLowerCase()
        : '';

    const videoExtensions = ['mp4', 'avi', 'mov', 'wmv', 'flv', 'webm', 'm4v'];

    if (videoExtensions.contains(extension)) {
      return MediaType.video;
    }

    return MediaType.image;
  }

  void _openMediaPlayer(BuildContext context, String mediaUrl, int index) {
    final mediaType = _detectMediaType(mediaUrl);
    final title = '${_getMediaTypeText(mediaUrl)} ${index + 1}';

    MediaPlayerDialog.show(
      context: context,
      mediaUrl: mediaUrl,
      title: title,
      mediaType: mediaType,
    );
  }

  IconData _getMediaIcon(String url) {
    final mediaType = _detectMediaType(url);
    return mediaType == MediaType.video
        ? Icons.play_circle_outline
        : Icons.image_outlined;
  }

  String _getMediaTypeText(String url) {
    final mediaType = _detectMediaType(url);
    return mediaType == MediaType.video ? 'Video' : 'Image';
  }

  Widget _buildVehicleDocumentsSection() {
    // Create a list of available documents with their labels
    List<MapEntry<String, String?>> availableDocuments = [
      MapEntry('RC Book Front Photo', _vehicle!.documents.rcBookFrontPhoto),
      MapEntry('RC Book Back Photo', _vehicle!.documents.rcBookBackPhoto),
      MapEntry('Aadhar Card Photo', _vehicle!.documents.aadharCardPhoto),
      MapEntry('Aadhar Card Number', _vehicle!.documents.aadharCardNumber),
    ];

    // Filter out null/empty documents
    List<MapEntry<String, String>> validDocuments = availableDocuments
        .where((doc) => doc.value != null && doc.value!.isNotEmpty)
        .map((doc) => MapEntry(doc.key, doc.value!))
        .toList();

    return _buildSectionCard(
      title: 'Vehicle Documents',
      children: [
        if (validDocuments.isEmpty)
          Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey[200]!),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.info_outline,
                  color: Colors.grey[500],
                  size: 20,
                ),
                SizedBox(width: 12),
                Text(
                  'No documents uploaded',
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          )
        else
          ListView.separated(
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            itemCount: validDocuments.length,
            separatorBuilder: (context, index) => SizedBox(height: 12),
            itemBuilder: (context, index) {
              final document = validDocuments[index];
              final isPhoto = document.key.toLowerCase().contains('photo');

              return GestureDetector(
                onTap: () {
                  _openMediaPlayer(
                      context,
                      document.value,
                      // "https://www.sample-videos.com/video321/mp4/720/big_buck_bunny_720p_2mb.mp4",

                      index);
                },
                child: Container(
                  padding: EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.grey[50],
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.grey[200]!),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: ColorConstants.primaryColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Icon(
                          isPhoto
                              ? Icons.image_outlined
                              : Icons.description_outlined,
                          color: ColorConstants.primaryColor,
                          size: 20,
                        ),
                      ),
                      SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              document.key,
                              style: TextStyle(
                                fontWeight: FontWeight.w500,
                                fontSize: 14,
                              ),
                            ),
                            SizedBox(height: 2),
                            Text(
                              isPhoto ? 'Photo Document' : document.value,
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 12,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                      if (isPhoto)
                        IconButton(
                          onPressed: () {
                            // Show image in full screen or launch URL
                            // You can implement image viewing functionality here
                          },
                          icon: Icon(
                            Icons.visibility_outlined,
                            color: Colors.grey[600],
                            size: 18,
                          ),
                        )
                      else
                        IconButton(
                          onPressed: () {
                            // Copy to clipboard or show details
                            // You can implement text copying functionality here
                          },
                          icon: Icon(
                            Icons.copy_outlined,
                            color: Colors.grey[600],
                            size: 18,
                          ),
                        ),
                    ],
                  ),
                ),
              );
            },
          ),
      ],
    );
  }

  Widget _buildInfoItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              value,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[800],
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomButtons() {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            if (_isEditing) ...[
              Expanded(
                child: OutlinedButton(
                  onPressed: _isSaving
                      ? null
                      : () {
                          setState(() {
                            _isEditing = false;
                            _initializeControllers(); // Reset to original values
                          });
                        },
                  style: OutlinedButton.styleFrom(
                    padding: EdgeInsets.symmetric(vertical: 16),
                    side: BorderSide(color: Colors.grey[400]!),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Text(
                    'Cancel',
                    style: TextStyle(
                      color: Colors.grey[700],
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
              SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: _isSaving ? null : _updateVehicleDetails,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: ColorConstants.primaryColor,
                    padding: EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: _isSaving
                      ? SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : Text(
                          'Save Changes',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ),
            ] else ...[
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () {
                    setState(() {
                      _isEditing = true;
                    });
                  },
                  icon: Icon(Icons.edit, size: 20),
                  label: Text(
                    'Edit Vehicle',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: ColorConstants.primaryColor,
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  String _formatDate(String dateString) {
    try {
      final DateTime date = DateTime.parse(dateString);
      return '${date.day}/${date.month}/${date.year}';
    } catch (e) {
      return dateString;
    }
  }
}
