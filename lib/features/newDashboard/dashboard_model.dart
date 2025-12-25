class DashboardResponse {
  final bool success;
  final String message;
  final DashboardMetrics data;

  DashboardResponse({
    required this.success,
    required this.message,
    required this.data,
  });

  factory DashboardResponse.fromJson(Map<String, dynamic> json) {
    return DashboardResponse(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      data: DashboardMetrics.fromJson(json['data'] ?? {}),
    );
  }
}
class DashboardMetrics {
  final double totalOutstandingAmount;
  final double totalRevenue;
  final int pendingQuotationCount;
  final int quoteRequestCount;
  final int bookingCompletedCount;

  const DashboardMetrics({
    required this.totalOutstandingAmount,
    required this.totalRevenue,
    required this.pendingQuotationCount,
    required this.quoteRequestCount,
    required this.bookingCompletedCount,
  });

  factory DashboardMetrics.fromJson(Map<String, dynamic> json) {
    return DashboardMetrics(
      totalOutstandingAmount:
      (json['totalOutstandingAmount'] ?? 0).toDouble(),
      totalRevenue: (json['totalRevenue'] ?? 0).toDouble(),
      pendingQuotationCount: json['pendingQuotationCount'] ?? 0,
      quoteRequestCount: json['quoteRequestCount'] ?? 0,
      bookingCompletedCount: json['bookingCompletedCount'] ?? 0,
    );
  }

  static DashboardMetrics empty() {
    return const DashboardMetrics(
      totalOutstandingAmount: 0,
      totalRevenue: 0,
      pendingQuotationCount: 0,
      quoteRequestCount: 0,
      bookingCompletedCount: 0,
    );
  }
}
