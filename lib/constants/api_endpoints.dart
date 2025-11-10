class ApiEndpoints {
  // Authentication
  static const String sendOtp = "/auth/send-otp";
  static const String verifyOtp = "/auth/verify-otp";
  static const String logout = "/user/logout";

  // User
  static const String userHome = "/user/home";
  static const String userProfile = "/user/profile";
  static const String updateProfile = "/user/profile/update";
  static const String userPlan = "/user/plan";
  static const String paymentStatus = "/user/payment-status";

  // Driver
  static const String driverProfile = "/driver/profile";
  static const String driverRegistration = "/driver/registration";
  static const String driverDetails = "/driver/details";
  static const String driverTransporterProfile = "/driver/transporter-profile";

  // Vehicle
  static const String addVehicle = "/vehicle/add";
  static const String searchVehicles = "/vehicle/search";
  static const String vehicleTypes = "/vehicle/types";
  static const String updateVehicle = "/vehicle/update";
  static const String deleteVehicle = "/vehicle/delete";

  // Registration Services
  static const String autoRikshawRegistration = "/registration/auto-rikshaw";
  static const String eRikshawRegistration = "/registration/e-rikshaw";
  static const String becomeDriverRegistration = "/registration/become-driver";
  static const String transporterRegistration = "/registration/transporter";
  static const String indiCarRegistration = "/registration/indi-car";

  // Chat
  static const String startChat = "/chat/start";
  static const String chatHistory = "/chat/history";
  static const String chatConversation = "/chat/conversation";
  static const String deleteChat = "/chat/delete";

  // Payment
  static const String createPayment = "/payment/create";
  static const String verifyPayment = "/payment/verify";
  static const String paymentHistory = "/payment/history";
  static const String subscriptionPlan = "/payment/subscription-plan";
  static const String activePlan = "/payment/active-plan";

  // Location
  static const String searchLocation = "/location/search";
  static const String nearbyDrivers = "/location/nearby-drivers";
  static const String updateLocation = "/location/update";

  // Notification
  static const String notifications = "/notifications";
  static const String markNotificationRead = "/notifications/mark-read";
  static const String updateFcmToken = "/notifications/update-fcm-token";

  // Documents & Verification
  static const String uploadDocument = "/documents/upload";
  static const String verifyDocument = "/documents/verify";
  static const String documentStatus = "/documents/status";

  // Media
  static const String uploadMedia = "/media/upload";

  // Filter
  static const String filterOptions = "/filter/options";
  static const String applyFilter = "/filter/apply";

  // Terms & Conditions
  static const String termsConditions = "/terms-conditions";

  // Ratings & Reviews
  static const String submitRating = "/rating/submit";
  static const String getUserRatings = "/rating/user";
  static const String getDriverRatings = "/rating/driver";

  // Activity
  static const String userActivity = "/activity/user";
  static const String driverActivity = "/activity/driver";

  // Owner Services
  static const String ownerDetails = "/owner/details";
  static const String transporterDetails = "/transporter/details";
}
