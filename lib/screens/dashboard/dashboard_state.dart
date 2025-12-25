import '../../features/newDashboard/dashboard_model.dart';

abstract class DashboardState {}

class DashboardLoading extends DashboardState {}

class DashboardLoaded extends DashboardState {
  final String selectedRange;
  final DashboardResponse data;

  DashboardLoaded({
    required this.selectedRange,
    required this.data,
  });

  DashboardLoaded copyWith({
    String? selectedRange,
    DashboardResponse? data,
  }) {
    return DashboardLoaded(
      selectedRange: selectedRange ?? this.selectedRange,
      data: data ?? this.data,
    );
  }
}

class DashboardError extends DashboardState {
  final String message;
  DashboardError(this.message);
}
