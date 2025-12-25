abstract class DashboardEvent {}

class LoadDashboard extends DashboardEvent {
  final String range;
  LoadDashboard({this.range = "1 Year"});
}

class ChangeRange extends DashboardEvent {
  final String range;
  ChangeRange(this.range);
}
