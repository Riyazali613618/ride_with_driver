import 'dart:convert';

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:r_w_r/constants/token_manager.dart';
import 'package:r_w_r/screens/driver_screens/erikshaw_rikshaw_profile_screen.dart';
import 'package:r_w_r/screens/driver_screens/plans.dart';
import 'package:r_w_r/screens/driver_screens/vehicle_details.dart';
import 'package:r_w_r/screens/profileScreens/eRikshawProfileScreen.dart';

import '../../api/api_model/vehicle/add_vehicle_model.dart';
import '../../components/app_appbar.dart';
import '../../constants/api_constants.dart';
import '../../constants/color_constants.dart';
import '../../l10n/app_localizations.dart';
import '../vehicle/add_vehicle_screen.dart';
import 'driver_profile_info.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  int _selectedIndex = 1;
  String _selectedPeriod = 'Day';
  bool _isLoading = true;
  String _errorMessage = '';

  Map<String, dynamic> _dashboardData = {};
  Map<String, dynamic> _activityData = {};
  List<String> _userTypes = [];
  int _maxLimit = 0;

  // List to store fetched vehicles
  List<Vehicle> _vehicles = [];
  bool _isLoadingVehicles = false;

  Map<String, int> _currentPeriodData = {
    'chat': 0,
    'whatsapp': 0,
    'call': 0,
    'click': 0,
  };

  final List<String> _periods = ['Day', 'Week', 'Month', 'All time'];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_isLoading && _dashboardData.isEmpty) {
      // _fetchDashboardData();
    }
  }

  Future<void> _fetchDashboardData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      final localizations = AppLocalizations.of(context)!;
      final token = await TokenManager.getToken();

      print('Token retrieved: ${token != null}'); // Debug token

      if (token == null) {
        throw Exception(localizations.authenticationError);
      }

      print("Fetching dashboard data...");

      final response = await http.get(
        Uri.parse('${ApiConstants.baseUrl}/user/register/home-'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      ).timeout(Duration(seconds: 30));

      print("Response status: ${response.statusCode}");
      print("Response body: ${response.body}");

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        print("Decoded data: $data");

        if (data['status'] == true) {
          setState(() {
            _dashboardData = data['data'] ?? {};
            _activityData = _dashboardData['activity'] ??
                {
                  'daily': {'chat': 0, 'whatsapp': 0, 'call': 0, 'click': 0},
                  'weekly': {'chat': 0, 'whatsapp': 0, 'call': 0, 'click': 0},
                  'monthly': {'chat': 0, 'whatsapp': 0, 'call': 0, 'click': 0},
                  'all': {'chat': 0, 'whatsapp': 0, 'call': 0, 'click': 0},
                };
            _maxLimit = _dashboardData['maxLimit'] ?? 0;
            _userTypes = List<String>.from(_dashboardData['usertype'] ?? []);
            _updateCurrentPeriodData();
            _isLoading = false;
          });
          _fetchVehicles();
        } else {
          throw Exception(data['message'] ?? 'Unknown API error');
        }
      } else {
        throw Exception('HTTP ${response.statusCode}: ${response.body}');
      }
    } catch (e, stackTrace) {
      print('Error in _fetchDashboardData: $e');
      print('Stack trace: $stackTrace');

      setState(() {
        _isLoading = false;
        _errorMessage = e.toString();
      });
    }
  }

  // Fetch vehicles from API
  Future<void> _fetchVehicles() async {
    setState(() {
      _isLoadingVehicles = true;
    });

    try {
      final localizations = AppLocalizations.of(context)!;

      final token = await TokenManager.getToken();

      if (token == null) {
        throw Exception(localizations.authenticationError);
      }

      final response = await http.get(
        Uri.parse('${ApiConstants.baseUrl}/user/vehicle/vehicle'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        if (data['success'] == true) {
          final vehiclesData = data['data'] as List;
          setState(() {
            _vehicles =
                vehiclesData.map((item) => Vehicle.fromJson(item)).toList();
            _isLoadingVehicles = false;
          });
        } else {
          throw Exception(localizations.error_loading_vehicle_details);
        }
      }
    } catch (e) {
      setState(() {
        _isLoadingVehicles = false;
      });
      print('Error fetching vehicles: $e');
    }
  }

  void _updateCurrentPeriodData() {
    switch (_selectedPeriod) {
      case 'Day':
        _currentPeriodData = {
          'chat': _activityData['daily']['chat'] ?? 0,
          'whatsapp': _activityData['daily']['whatsapp'] ?? 0,
          'call': _activityData['daily']['call'] ?? 0,
          'click': _activityData['daily']['click'] ?? 0,
        };
        break;
      case 'Week':
        _currentPeriodData = {
          'chat': _activityData['weekly']['chat'] ?? 0,
          'whatsapp': _activityData['weekly']['whatsapp'] ?? 0,
          'call': _activityData['weekly']['call'] ?? 0,
          'click': _activityData['weekly']['click'] ?? 0,
        };
        break;
      case 'Month':
        _currentPeriodData = {
          'chat': _activityData['monthly']['chat'] ?? 0,
          'whatsapp': _activityData['monthly']['whatsapp'] ?? 0,
          'call': _activityData['monthly']['call'] ?? 0,
          'click': _activityData['monthly']['click'] ?? 0,
        };
        break;
      case 'All time':
        _currentPeriodData = {
          'chat': _activityData['all']['chat'] ?? 0,
          'whatsapp': _activityData['all']['whatsapp'] ?? 0,
          'call': _activityData['all']['call'] ?? 0,
          'click': _activityData['all']['click'] ?? 0,
        };
        break;
    }
  }

  int _calculateTotalReach() {
    final total = _currentPeriodData['chat']! +
        _currentPeriodData['whatsapp']! +
        _currentPeriodData['call']! +
        _currentPeriodData['click']!;

    if (total == 0) return 0;

    if (_selectedPeriod == 'All time') {
      return ((total)).round().clamp(0, 100);
    }

    int maxExpected;
    switch (_selectedPeriod) {
      case 'Day':
        maxExpected = 30;
        break;
      case 'Week':
        maxExpected = 210;
        break;
      case 'Month':
        maxExpected = 900;
        break;
      default:
        maxExpected = 100;
    }

    return ((total)).round().clamp(0, 100);
  }

  // Calculate individual percentages for pie chart sections
  List<double> _calculateSectionPercentages() {
    final chat = _currentPeriodData['chat'] ?? 0;
    final whatsapp = _currentPeriodData['whatsapp'] ?? 0;
    final call = _currentPeriodData['call'] ?? 0;
    final click = _currentPeriodData['click'] ?? 0;
    final total = chat + whatsapp + call + click;

    if (total == 0) {
      // If total is 0, distribute evenly for visual purposes
      return [33.3, 33.3, 33.4];
    }

    return [
      (chat / total) * 100,
      (whatsapp / total) * 100,
      (call / total) * 100,
    ];
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: ColorConstants.backgroundColor,
      appBar: CustomAppBar(
        leading: Text(''),
        title: localizations.my_dashboard,
        centerTitle: true,
        leadingWidth: 35,
        actions: [
          Container(
            margin: EdgeInsets.only(right: 8),
            child: IconButton(
              onPressed: () {
                // _userTypes.contains('E_RICKSHAW')
                //     ? Navigator.push(
                //         context,
                //         CupertinoPageRoute(
                //           builder: (context) =>
                //               DriverssssProfileScreen(),
                //         ),
                //       )
                //     :
                Navigator.push(
                  context,
                  CupertinoPageRoute(
                    builder: (context) => TransporterDriverProfileScreen(
                      userType: _userTypes.contains('TRANSPORTER')
                          ? 'TRANSPORTER'
                          : _userTypes.contains('DRIVER')
                              ? 'DRIVER'
                              : _userTypes.contains('INDEPENDENT_CAR_OWNER')
                                  ? 'INDEPENDENT_CAR_OWNER'
                                  : _userTypes.contains('RICKSHAW')
                                      ? 'RICKSHAW'
                                      : _userTypes.contains('E_RICKSHAW')
                                          ? 'E_RICKSHAW'
                                          : 'DRIVER',
                    ),
                  ),
                );
              },
              icon: Container(
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withAlpha(50),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Icon(
                  CupertinoIcons.person_alt_circle,
                  color: ColorConstants.white,
                  size: 20,
                ),
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: _isLoading
            ? _buildLoadingIndicator()
            : _errorMessage.isNotEmpty
                ? _buildErrorWidget()
                : Column(
                    children: [
                      _buildTabBar(),
                      Expanded(
                        child: RefreshIndicator(
                          onRefresh: _fetchDashboardData,
                          color: ColorConstants.primaryColor,
                          child: TabBarView(
                            controller: _tabController,
                            children: [
                              _buildStatsTab(),
                              _buildVehiclesTab(),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
      ),
    );
  }

  Widget _buildTabBar() {
    final localizations = AppLocalizations.of(context)!;

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(25),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(10),
            blurRadius: 10,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: TabBar(
        controller: _tabController,
        indicator: BoxDecoration(
          color: ColorConstants.primaryColor,
          borderRadius: BorderRadius.circular(25),
          boxShadow: [
            BoxShadow(
              color: ColorConstants.primaryColor.withAlpha(5),
              blurRadius: 8,
              offset: Offset(0, 2),
            ),
          ],
        ),
        labelColor: Colors.white,
        unselectedLabelColor: Colors.grey[600],
        labelStyle: TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 14,
        ),
        unselectedLabelStyle: TextStyle(
          fontWeight: FontWeight.w500,
          fontSize: 14,
        ),
        indicatorSize: TabBarIndicatorSize.tab,
        dividerColor: Colors.transparent,
        tabs: [
          Tab(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.analytics_outlined, size: 18),
                SizedBox(width: 8),
                Flexible(
                    child: Text(localizations.analytics,
                        overflow: TextOverflow.ellipsis)),
              ],
            ),
          ),
          Tab(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.directions_car_outlined, size: 18),
                SizedBox(width: 8),
                Flexible(
                    child: Text(localizations.vehicles,
                        overflow: TextOverflow.ellipsis)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsTab() {
    return SingleChildScrollView(
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildStatsCard(),
          SizedBox(height: 16),
          _buildQuickActionsCard(),
        ],
      ),
    );
  }

  Widget _buildVehiclesTab() {
    return SingleChildScrollView(
      padding: EdgeInsets.all(16),
      child: _buildVehiclesSection(),
    );
  }

  Widget _buildQuickActionsCard() {
    final localizations = AppLocalizations.of(context)!;

    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(10),
            blurRadius: 15,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            localizations.quick_actions,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey[800],
            ),
          ),
          SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildQuickActionButton(
                  icon: Icons.add_circle_outline,
                  label: localizations.add_vehicle,
                  color: ColorConstants.primaryColor,
                  onTap: () {
                    if (_vehicles.length >= _maxLimit) {
                      _showUpgradePlanDialog();
                    } else if (_userTypes.contains('TRANSPORTER')) {
                      Navigator.push(
                        context,
                        CupertinoPageRoute(
                          builder: (context) => AddVehicleScreen(
                            removeAutoRikshaw:
                                _userTypes.contains('TRANSPORTER'),
                          ),
                        ),
                      ).then((_) => _fetchVehicles());
                    } else {
                      _showUpgradePlanDialog();
                    }
                  },
                ),
              ),
              SizedBox(width: 12),
              Expanded(
                child: _buildQuickActionButton(
                  icon: Icons.upgrade_outlined,
                  label: localizations.upgrade_plan,
                  color: Colors.orange,
                  onTap: () {
                    Navigator.push(
                      context,
                      CupertinoPageRoute(
                        builder: (context) => PlanSelectionScreen(
                          planType: 'REGISTRATION', planFor: 'TRANSPORTER', countryId: '', stateId: '',
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActionButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 16, horizontal: 12),
        decoration: BoxDecoration(
          color: color.withAlpha(25),
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: color.withAlpha(75)),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: color,
              size: 28,
            ),
            SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.w600,
                fontSize: 12,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingIndicator() {
    final localizations = AppLocalizations.of(context)!;

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
            localizations.loading_dashboard,
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
    final localizations = AppLocalizations.of(context)!;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.red.withAlpha(25),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Icon(
                Icons.error_outline,
                color: Colors.red,
                size: 60,
              ),
            ),
            SizedBox(height: 24),
            Text(
              localizations.oops_something_wrong,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.grey[800],
              ),
            ),
            SizedBox(height: 12),
            Text(
              _errorMessage,
              maxLines: 1,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 14,
              ),
            ),
            SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: _fetchDashboardData,
              icon: Icon(Icons.refresh),
              label: Text(localizations.retry),
              style: ElevatedButton.styleFrom(
                backgroundColor: ColorConstants.primaryColor,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(25),
                ),
                elevation: 5,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsCard() {
    final reachPercentage = _calculateTotalReach();
    final sectionPercentages = _calculateSectionPercentages();

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(15),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildPeriodSelector(),
          _buildDonutChart(reachPercentage, sectionPercentages),
          _buildCommunicationStats(),
        ],
      ),
    );
  }

  Widget _buildPeriodSelector() {
    return Container(
      margin: EdgeInsets.all(16),
      padding: EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(25),
      ),
      child: Row(
        children: _periods.map((period) {
          bool isSelected = _selectedPeriod == period;
          return Expanded(
            child: GestureDetector(
              onTap: () {
                setState(() {
                  _selectedPeriod = period;
                  _updateCurrentPeriodData();
                });
              },
              child: AnimatedContainer(
                duration: Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: isSelected
                      ? ColorConstants.primaryColor
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: isSelected
                      ? [
                          BoxShadow(
                            color: ColorConstants.primaryColor.withAlpha(75),
                            blurRadius: 8,
                            offset: Offset(0, 2),
                          ),
                        ]
                      : null,
                ),
                child: Text(
                  period,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: isSelected ? Colors.white : Colors.grey[600],
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                    fontSize: 12,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildDonutChart(
      int reachPercentage, List<double> sectionPercentages) {
    final localizations = AppLocalizations.of(context)!;

    return Container(
      height: 170,
      padding: EdgeInsets.symmetric(vertical: 16),
      child: Stack(
        alignment: Alignment.center,
        children: [
          SizedBox(
            width: 100,
            height: 100,
            child: PieChart(
              PieChartData(
                sectionsSpace: 2,
                centerSpaceRadius: 50,
                sections: [
                  PieChartSectionData(
                    value: sectionPercentages[0], // Chat
                    color: Colors.blue,
                    radius: 25,
                    showTitle: false,
                  ),
                  PieChartSectionData(
                    value: sectionPercentages[1], // WhatsApp
                    color: Colors.green,
                    radius: 25,
                    showTitle: false,
                  ),
                  PieChartSectionData(
                    value: sectionPercentages[2], // Call
                    color: ColorConstants.primaryColor,
                    radius: 25,
                    showTitle: false,
                  ),
                ],
              ),
            ),
          ),
          Container(
            padding: EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withAlpha(25),
                  blurRadius: 10,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '$reachPercentage',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: reachPercentage > 0
                        ? ColorConstants.primaryColor
                        : Colors.grey,
                  ),
                ),
                Text(
                  localizations.profile,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  localizations.reached,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCommunicationStats() {
    final localizations = AppLocalizations.of(context)!;

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        children: [
          _buildStatRow(
            imagePath: "assets/img/chat (2).png",
            iconColor: Colors.blue,
            iconBgColor: Colors.blue.withAlpha(25),
            label: localizations.chat,
            callsAttended:
                '${_currentPeriodData['chat']} ${localizations.messages}',
          ),
          _buildStatRow(
            imagePath: "assets/img/Mask group (2).png",
            iconColor: Colors.green,
            iconBgColor: Colors.green.withAlpha(25),
            label: localizations.whatsapp,
            callsAttended:
                '${_currentPeriodData['whatsapp']} ${localizations.messages}',
          ),
          _buildStatRow(
            imagePath: "assets/img/Mask group (1).png",
            iconColor: ColorConstants.primaryColor,
            iconBgColor: Colors.purple.withAlpha(25),
            label: localizations.call,
            callsAttended:
                '${_currentPeriodData['call']}${localizations.calls}',
          ),
          _buildStatRow(
            imagePath: "assets/img/eye.png",
            iconColor: Colors.orange,
            iconBgColor: Colors.orange.withAlpha(25),
            label: localizations.views,
            callsAttended:
                '${_currentPeriodData['click']} ${localizations.clicks}',
            isLast: true,
          ),
        ],
      ),
    );
  }

  Widget _buildStatRow({
    required String imagePath,
    required Color iconColor,
    required Color iconBgColor,
    required String label,
    required String callsAttended,
    bool isLast = false,
  }) {
    return Container(
      margin: EdgeInsets.only(bottom: isLast ? 16 : 8),
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: iconBgColor,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Image.asset(
              imagePath,
              width: 20,
              height: 20,
              fit: BoxFit.contain,
              errorBuilder: (context, error, stackTrace) {
                return Icon(
                  Icons.image_not_supported,
                  color: iconColor,
                  size: 20,
                );
              },
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  callsAttended,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: iconColor.withAlpha(25),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              callsAttended.split(' ').first,
              style: TextStyle(
                color: iconColor,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVehiclesSection() {
    final localizations = AppLocalizations.of(context)!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                ColorConstants.primaryColor,
                ColorConstants.primaryColor.withAlpha(200),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: ColorConstants.primaryColor.withAlpha(75),
                blurRadius: 15,
                offset: Offset(0, 5),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withAlpha(50),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Icon(
                  Icons.directions_car,
                  color: Colors.white,
                  size: 24,
                ),
              ),
              SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      localizations.my_vehicles,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      '${_vehicles.length}/$_maxLimit ${localizations.vehicleAdded}',
                      style: TextStyle(
                        color: Colors.white.withAlpha(225),
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
              GestureDetector(
                onTap: () {
                  if (_vehicles.length >= _maxLimit) {
                    _showUpgradePlanDialog();
                  } else if (_userTypes.contains('TRANSPORTER')) {
                    Navigator.push(
                      context,
                      CupertinoPageRoute(
                        builder: (context) => AddVehicleScreen(
                          removeAutoRikshaw: _userTypes.contains('TRANSPORTER'),
                        ),
                      ),
                    ).then((_) => _fetchVehicles());
                  } else {
                    _showUpgradePlanDialog();
                  }
                },
                child: Container(
                  padding: EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(15),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withAlpha(25),
                        blurRadius: 5,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Icon(
                    Icons.add,
                    color: ColorConstants.primaryColor,
                    size: 20,
                  ),
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: 20),

        // Vehicle limit progress indicator
        if (_maxLimit > 0) ...[
          Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(15),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withAlpha(10),
                  blurRadius: 10,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      localizations.vehicle_limit,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey[800],
                      ),
                    ),
                    Text(
                      '${_vehicles.length}/$_maxLimit',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: _vehicles.length >= _maxLimit
                            ? Colors.red
                            : ColorConstants.primaryColor,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 12),
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: LinearProgressIndicator(
                    value: _maxLimit > 0 ? _vehicles.length / _maxLimit : 0,
                    backgroundColor: Colors.grey[200],
                    valueColor: AlwaysStoppedAnimation<Color>(
                      _vehicles.length >= _maxLimit
                          ? Colors.red
                          : ColorConstants.primaryColor,
                    ),
                    minHeight: 8,
                  ),
                ),
                if (_vehicles.length >= _maxLimit) ...[
                  SizedBox(height: 8),
                  Text(
                    localizations.limit_reached_message,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.red,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ],
            ),
          ),
          SizedBox(height: 20),
        ],

        // Vehicles list
        _isLoadingVehicles
            ? _buildVehiclesLoadingState()
            : _vehicles.isEmpty
                ? _buildNoVehiclesState()
                : _buildVehiclesList(),
      ],
    );
  }

  Widget _buildVehiclesLoadingState() {
    final localizations = AppLocalizations.of(context)!;

    return Container(
      padding: EdgeInsets.all(40),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(10),
            blurRadius: 15,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          CircularProgressIndicator(
            color: ColorConstants.primaryColor,
            strokeWidth: 3,
          ),
          SizedBox(height: 16),
          Text(
            localizations.loading_vehicles,
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNoVehiclesState() {
    final localizations = AppLocalizations.of(context)!;

    return Container(
      padding: EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(10),
            blurRadius: 15,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.directions_car_outlined,
              color: Colors.grey[400],
              size: 48,
            ),
          ),
          SizedBox(height: 20),
          Text(
            localizations.no_vehicles_available,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey[800],
            ),
          ),
          SizedBox(height: 8),
          Text(
            localizations.add_first_vehicle_message,
            // 'Add your first vehicle to get started with bookings and manage your fleet effectively.',
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 14,
              height: 1.4,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () {
              if (_vehicles.length >= _maxLimit) {
                _showUpgradePlanDialog();
              } else if (_userTypes.contains('TRANSPORTER')) {
                Navigator.push(
                  context,
                  CupertinoPageRoute(
                    builder: (context) => AddVehicleScreen(
                      removeAutoRikshaw: _userTypes.contains('TRANSPORTER'),
                    ),
                  ),
                ).then((_) => _fetchVehicles());
              } else {
                _showUpgradePlanDialog();
              }
            },
            icon: Icon(Icons.add),
            label: Text(localizations.add_vehicle),
            style: ElevatedButton.styleFrom(
              backgroundColor: ColorConstants.primaryColor,
              foregroundColor: Colors.white,
              padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(25),
              ),
              elevation: 5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVehiclesList() {
    return Column(
      children: _vehicles.asMap().entries.map((entry) {
        int index = entry.key;
        Vehicle vehicle = entry.value;
        return Container(
          margin: EdgeInsets.only(bottom: 12),
          child: _buildVehicleItem(vehicle, index),
        );
      }).toList(),
    );
  }

  Widget _buildVehicleItem(Vehicle vehicle, int index) {
    final localizations = AppLocalizations.of(context)!;

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          CupertinoPageRoute(
            builder: (context) => VehicleDetailsScreen(vehicle: vehicle),
          ),
        ).then((_) => _fetchVehicles());
      },
      child: Container(
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(10),
              blurRadius: 15,
              offset: Offset(0, 5),
            ),
          ],
          border: Border.all(
            color: vehicle.isDisabled
                ? Colors.red.withAlpha(75)
                : Colors.green.withAlpha(75),
            width: 1,
          ),
        ),
        child: Column(
          children: [
            Row(
              children: [
                // Vehicle Image
                Container(
                  width: 80,
                  height: 60,
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(15),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withAlpha(25),
                        blurRadius: 5,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(15),
                    child: vehicle.images.isNotEmpty
                        ? Image.network(
                            vehicle.images.first,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                color: Colors.grey[200],
                                child: Icon(
                                  Icons.directions_car,
                                  color: Colors.grey[400],
                                  size: 30,
                                ),
                              );
                            },
                          )
                        : Container(
                            color: Colors.grey[200],
                            child: Icon(
                              Icons.directions_car,
                              color: Colors.grey[400],
                              size: 30,
                            ),
                          ),
                  ),
                ),

                SizedBox(width: 16),

                // Vehicle Details
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: EdgeInsets.symmetric(
                                horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: ColorConstants.primaryColor.withAlpha(25),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              vehicle.vehicleNumber,
                              style: TextStyle(
                                color: ColorConstants.primaryColor,
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            ),
                          ),
                          Spacer(),
                          Container(
                            padding: EdgeInsets.symmetric(
                                horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: vehicle.isDisabled
                                  ? Colors.red.withAlpha(25)
                                  : Colors.green.withAlpha(25),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  vehicle.isDisabled
                                      ? Icons.visibility_off
                                      : Icons.visibility,
                                  color: vehicle.isDisabled
                                      ? Colors.red
                                      : Colors.green,
                                  size: 12,
                                ),
                                SizedBox(width: 4),
                                Text(
                                  vehicle.isDisabled
                                      ? localizations.unlisted
                                      : localizations.listed,
                                  style: TextStyle(
                                    color: vehicle.isDisabled
                                        ? Colors.red
                                        : Colors.green,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 10,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 8),
                      Text(
                        vehicle.vehicleName,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey[800],
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: 4),
                      Text(
                        vehicle.vehicleModelName,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),

                SizedBox(width: 8),

                // Arrow Icon
                Container(
                  padding: EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    Icons.arrow_forward_ios,
                    color: Colors.grey[600],
                    size: 16,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showUpgradePlanDialog() {
    final localizations = AppLocalizations.of(context)!;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Container(
            padding: EdgeInsets.all(24),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              gradient: LinearGradient(
                colors: [
                  Colors.white,
                  ColorConstants.primaryColor.withAlpha(10),
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: ColorConstants.primaryColor.withAlpha(25),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.upgrade,
                    color: ColorConstants.primaryColor,
                    size: 32,
                  ),
                ),
                SizedBox(height: 20),
                Text(
                  localizations.upgrade_plan,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[800],
                  ),
                ),
                SizedBox(height: 12),
                Text(
                  localizations.upgrade_to_transporter_message,
                  // 'You need to upgrade to the TRANSPORTER plan to add more vehicles and unlock premium features.',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                    height: 1.4,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: TextButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        style: TextButton.styleFrom(
                          padding: EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(25),
                            side: BorderSide(color: Colors.grey[300]!),
                          ),
                        ),
                        child: Text(
                          localizations.maybe_later,
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                          Navigator.push(
                            context,
                            CupertinoPageRoute(
                              builder: (context) => PlanSelectionScreen(
                                planType: 'REGISTRATION', planFor: 'TRANSPORTER', countryId: '', stateId: '',
                              ),
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: ColorConstants.primaryColor,
                          padding: EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(25),
                          ),
                          elevation: 5,
                        ),
                        child: Text(
                          localizations.upgrade_now,
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
