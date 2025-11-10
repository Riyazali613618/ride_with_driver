// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Malayalam (`ml`).
class AppLocalizationsMl extends AppLocalizations {
  AppLocalizationsMl([String locale = 'ml']) : super(locale);

  @override
  String get failed_to_load_chat_history => 'Failed to load chat history';

  @override
  String network_error(Object error) {
    return 'Network Error';
  }

  @override
  String get loaded_from_cache => 'Loaded from cache';

  @override
  String get failed_to_send_otp => 'Failed to send OTP. Please try again.';

  @override
  String get something_went_wrong_check_connection =>
      'Something went wrong. Please check your connection.';

  @override
  String upload_failed(Object error) {
    return 'Upload failed: $error';
  }

  @override
  String get uploading_media => 'Uploading media...';

  @override
  String get invoice => 'Invoice';

  @override
  String error_generating_pdf(Object error) {
    return 'Error generating PDF: $error';
  }

  @override
  String error_printing(Object error) {
    return 'Error printing: $error';
  }

  @override
  String get invoice_simplified_note =>
      'Note: This is a simplified version of your invoice. The original formatting could not be preserved in PDF format.';

  @override
  String get error_rendering_content => 'Error rendering content';

  @override
  String get loading => 'Loading...';

  @override
  String get check_internet_and_retry =>
      'Please check your internet connection and try again.';

  @override
  String get retry => 'Retry';

  @override
  String step_number(Object stepNumber) {
    return '$stepNumber';
  }

  @override
  String get search_for_location => 'Search for a location...';

  @override
  String get image_captured => 'Image Captured!';

  @override
  String get photo_captured_successfully =>
      'Your photo has been captured successfully!';

  @override
  String get capture_again => 'Capture Again';

  @override
  String get use_this_photo => 'Use This Photo';

  @override
  String get capture_image => 'Capture Image';

  @override
  String get instructions => 'Instructions:';

  @override
  String get face_capture_instructions =>
      '1. Position your face in the circle\n2. Wait for the green border\n3. Blink your eyes to capture';

  @override
  String get replace_media => 'Replace Media';

  @override
  String get confirm_replace => 'Are you sure you want to replace';

  @override
  String get cancel => 'Cancel';

  @override
  String get replace => 'Replace';

  @override
  String get camera_error => 'Camera Error';

  @override
  String get camera_access_issue => 'Could not access camera. Please check:';

  @override
  String get camera_permission_check => '• Camera permissions are granted';

  @override
  String get working_camera_check => '• Your device has a working camera';

  @override
  String get camera_in_use_check => '• No other app is using the camera';

  @override
  String get ok => 'OK';

  @override
  String get select_media_source => 'Select Media Source';

  @override
  String get choose_media_method => 'Choose how you want to add your media';

  @override
  String get gallery => 'Gallery';

  @override
  String get choose_from_existing => 'Choose from existing photos';

  @override
  String get authentication_required => 'Authentication Required';

  @override
  String get login_to_upload_media =>
      'You need to be logged in to upload media. Please log in and try again.';

  @override
  String get media_preview => 'Media Preview';

  @override
  String get open => 'Open';

  @override
  String get failed_to_load_image => 'Failed to load image';

  @override
  String get asterisk => '*';

  @override
  String get update_image => 'Update Image';

  @override
  String get uploading => 'Uploading...';

  @override
  String get max_file_size => '(Max. File size: 25 MB)';

  @override
  String get add_more => 'Add More';

  @override
  String get unable_to_load_pdf => 'Unable to load PDF';

  @override
  String get error_loading_media => 'Error Loading Media';

  @override
  String get app_initialization_failed => 'App Initialization Failed';

  @override
  String get ride_with_driver => 'Ride with Driver';

  @override
  String step_x_of_y(Object currentStep, Object totalSteps) {
    return 'Step $currentStep of $totalSteps';
  }

  @override
  String get previous => 'Previous';

  @override
  String get company_name => 'Company Name';

  @override
  String get enter_company_name => 'Enter your company name';

  @override
  String get registered_address => 'Registered Address';

  @override
  String get enter_registered_address => 'Enter your registered address';

  @override
  String get address_type => 'Address Type';

  @override
  String error_picking_document(Object error) {
    return 'Error picking document: $error';
  }

  @override
  String get gstin => 'GSTIN';

  @override
  String get enter_gstin => 'Enter your GSTIN';

  @override
  String get business_registration_certificate =>
      'Business Registration Certificate';

  @override
  String get upload_certificate_of_incorporation =>
      'Upload Certificate of Incorporation (PDF/Image)';

  @override
  String get authorized_person_aadhaar => 'Authorized Person Aadhaar';

  @override
  String get enter_12_digit_aadhaar => 'Enter 12-digit Aadhaar number';

  @override
  String displayed_as_aadhaar(Object formattedAadhar) {
    return 'Displayed as: $formattedAadhar';
  }

  @override
  String get transportation_permit => 'Transportation Permit';

  @override
  String get upload_transportation_permit =>
      'Upload valid transportation permit documents';

  @override
  String error_picking_images(Object error) {
    return 'Error picking images: $error';
  }

  @override
  String get total_fleet_size => 'Total Fleet Size';

  @override
  String get small_fleet => 'Small (2-5 vehicles)';

  @override
  String get medium_fleet => 'Medium (6-15 vehicles)';

  @override
  String get large_fleet => 'Large (15+ vehicles)';

  @override
  String get vehicle_details => 'Vehicle Details';

  @override
  String enter_number_of_vehicles(Object vehicleType) {
    return 'Enter number of $vehicleType';
  }

  @override
  String get allow_negotiation => 'Allow Negotiation';

  @override
  String get vehicle_photos => 'Vehicle Photos';

  @override
  String get add_vehicle_photos_description =>
      'Add photos of your vehicles to showcase your fleet';

  @override
  String get add_vehicle_photos => 'Add Vehicle Photos';

  @override
  String get complete_now_message =>
      'Complete now → Get verified in 2 hours!\nIf additional information is required, we will contact you.';

  @override
  String get phone_verified_successfully =>
      'Phone number verified successfully';

  @override
  String verification_failed(Object error) {
    return 'Verification failed: $error';
  }

  @override
  String get contact_information => 'Contact Information';

  @override
  String get contact_information_description =>
      'These details will be displayed on our website and app for client communication';

  @override
  String get contact_person_name => 'Contact Person Name';

  @override
  String get name_example => 'e.g., John Doe';

  @override
  String get mobile_number => 'Mobile Number';

  @override
  String use_login_number(Object phoneNumber) {
    return 'Use login number ($phoneNumber)';
  }

  @override
  String get new_mobile_number => 'New Mobile Number';

  @override
  String get enter_mobile_number => 'Enter mobile number';

  @override
  String get show_mobile_number => 'Show mobile number on website/app';

  @override
  String get whatsapp_number => 'WhatsApp Number';

  @override
  String get new_whatsapp_number => 'New WhatsApp Number';

  @override
  String get enter_whatsapp_number => 'Enter WhatsApp number';

  @override
  String get show_whatsapp_number => 'Show WhatsApp number on website/app';

  @override
  String get enable_in_app_chat => 'Enable In-App Chat System';

  @override
  String get enable_in_app_chat_description =>
      'Allow customers to contact you through our app';

  @override
  String get review_your_information => 'Review Your Information';

  @override
  String get registration_verification_time =>
      'Your registration will be verified within 2 hours. We may contact you if additional information is needed.';

  @override
  String get all_localized_strings => 'All Localized Strings:';

  @override
  String get strings_with_placeholders => 'Strings with placeholders:';

  @override
  String get auth_token_not_found =>
      'Authentication token not found. Please login again.';

  @override
  String get server_error => 'Server Error';

  @override
  String get failed_to_update_profile =>
      'Failed to update profile. Please check your internet connection.';

  @override
  String get complete_your_profile => 'Complete Your Profile';

  @override
  String get welcome => 'Welcome!';

  @override
  String get complete_profile_to_continue =>
      'Please complete your profile to continue';

  @override
  String get first_name_required => 'First Name *';

  @override
  String get last_name => 'Last Name';

  @override
  String get email_optional => 'Email (Optional)';

  @override
  String get log_in => 'Login here';

  @override
  String get enter_correct_phone => 'Please Enter Correct Phone';

  @override
  String get logout => 'Logout';

  @override
  String get confirm_logout => 'Are you sure you want to logout?';

  @override
  String get logged_out_successfully => 'Logged out successfully';

  @override
  String get failed_to_logout => 'Failed to logout. Please try again.';

  @override
  String get enter_all_4_digits => 'Please enter all 4 digits';

  @override
  String get failed_to_verify_otp => 'Failed to verify OTP. Please try again.';

  @override
  String get otp_resent => 'OTP code resent to your WhatsApp number';

  @override
  String get failed_to_resend_otp => 'Failed to resend OTP. Please try again.';

  @override
  String get verify_phone_number => 'Verify your phone number';

  @override
  String get did_not_receive_code => 'Did not receive the code?';

  @override
  String get resend_code => 'Resend Code';

  @override
  String change_language(Object languageName) {
    return 'Change language $languageName';
  }

  @override
  String get your_review => 'Your Review';

  @override
  String get something_went_wrong => 'Something went wrong';

  @override
  String get no_reviews_yet => 'No Reviews Yet';

  @override
  String get no_reviews_received => 'You haven\'t received any reviews yet.';

  @override
  String get my_ratings_reviews => 'My Ratings & Reviews';

  @override
  String error_deleting_review(Object error) {
    return 'Error deleting review: $error';
  }

  @override
  String get confirm_delete => 'Confirm Delete';

  @override
  String get confirm_delete_review =>
      'Are you sure you want to delete this review?';

  @override
  String get delete => 'Delete';

  @override
  String review_rating_count(Object totalReviews) {
    return 'Review & Rating ($totalReviews)';
  }

  @override
  String error_loading_reviews(Object error) {
    return 'Error loading reviews: $error';
  }

  @override
  String get no_reviews_available => 'No reviews yet';

  @override
  String get be_first_to_review => 'Be the first to share your experience!';

  @override
  String get rate_now => 'Rate Now';

  @override
  String rating_display(Object rating) {
    return '$rating.0';
  }

  @override
  String get enter_your_review => 'Please enter your review';

  @override
  String error_updating_review(Object error) {
    return 'Error updating review: $error';
  }

  @override
  String get edit_review => 'Edit Review';

  @override
  String get your_review_text => 'Your review';

  @override
  String get update => 'Update';

  @override
  String get could_not_open_pdf => 'Could not open PDF';

  @override
  String error_message(Object error) {
    return 'Error: $error';
  }

  @override
  String get active_subscriptions => 'Active Subscriptions';

  @override
  String get manage_subscriptions => 'Manage your current subscriptions';

  @override
  String get error => 'Error';

  @override
  String get no_active_subscriptions => 'No Active Subscriptions';

  @override
  String get no_subscriptions_message =>
      'You don\'t have any active subscriptions.';

  @override
  String get active_plan => 'Active Plan';

  @override
  String get transaction_history => 'Transaction History';

  @override
  String plan_name(Object planName) {
    return '$planName';
  }

  @override
  String price_in_rupees(Object price) {
    return '₹$price';
  }

  @override
  String get upgrade_plan => 'Upgrade Plan';

  @override
  String get add_payment_methods => 'Add payment methods';

  @override
  String get card_charge_description =>
      'This card will only be charged when you\nplace an order.';

  @override
  String get card_number_example => '4343 4343 4343 4343';

  @override
  String get card_expiry => 'MM/YY';

  @override
  String get card_cvc => 'CVC';

  @override
  String get add_card => 'Add Card';

  @override
  String get upi_payment => 'Upi Payment';

  @override
  String get scan_card => 'Scan Card';

  @override
  String get my_dashboard => 'My Dashboard';

  @override
  String get analytics => 'Analytics';

  @override
  String get vehicles => 'Vehicles';

  @override
  String get quick_actions => 'Quick Actions';

  @override
  String get loading_dashboard => 'Loading dashboard...';

  @override
  String get oops_something_wrong => 'Oops! Something went wrong';

  @override
  String reach_percentage(Object reachPercentage) {
    return '$reachPercentage';
  }

  @override
  String get profile => 'Profile';

  @override
  String get reached => 'Reached';

  @override
  String get my_vehicles => 'My Vehicles';

  @override
  String vehicles_added_count(Object currentVehicles, Object maxLimit) {
    return '$currentVehicles/$maxLimit vehicles added';
  }

  @override
  String get vehicle_limit => 'Vehicle Limit';

  @override
  String vehicles_limit_count(Object currentVehicles, Object maxLimit) {
    return '$currentVehicles/$maxLimit';
  }

  @override
  String get limit_reached_message =>
      'Limit reached! Upgrade to add more vehicles.';

  @override
  String get loading_vehicles => 'Loading vehicles...';

  @override
  String get no_vehicles_added => 'No Vehicles Added Yet';

  @override
  String get add_first_vehicle_message =>
      'Add your first vehicle to get started with bookings and manage your fleet effectively.';

  @override
  String get add_vehicle => 'Add Vehicle';

  @override
  String get upgrade_your_plan => 'Upgrade Your Plan';

  @override
  String get upgrade_to_transporter_message =>
      'You need to upgrade to the TRANSPORTER plan to add more vehicles and unlock premium features.';

  @override
  String get maybe_later => 'Maybe Later';

  @override
  String get upgrade_now => 'Upgrade Now';

  @override
  String get profile_updated_success => 'Profile updated successfully!';

  @override
  String get no_profile_data => 'No profile data available';

  @override
  String get profile_photo_updated => 'Profile photo updated successfully!';

  @override
  String error_updating_photo(Object error) {
    return 'Error updating photo: $error';
  }

  @override
  String get verified => 'Verified';

  @override
  String get basic_information => 'Basic Information';

  @override
  String get address_information => 'Address Information';

  @override
  String get fleet_information => 'Fleet Information';

  @override
  String get vehicle_types => 'Vehicle Types';

  @override
  String get vehicle_counts => 'Vehicle Counts';

  @override
  String get professional_information => 'Professional Information';

  @override
  String get saving => 'Saving...';

  @override
  String get save_changes => 'Save Changes';

  @override
  String select_label(Object label) {
    return 'Select $label';
  }

  @override
  String get vehicle_information => 'Vehicle Information';

  @override
  String get pricing_information => 'Pricing Information';

  @override
  String get price_negotiable => 'Price Negotiable';

  @override
  String get service_areas => 'Service Areas';

  @override
  String get vehicle_specifications => 'Vehicle Specifications';

  @override
  String get about_driver => 'About Driver';

  @override
  String get vehicle_images => 'Vehicle Images';

  @override
  String get processing_payment => 'Processing payment...';

  @override
  String get add_payment => 'Add Payment';

  @override
  String price_in_rupees_with_space(Object price) {
    return '₹ $price';
  }

  @override
  String discount_percentage_off(Object discountPercentage) {
    return '$discountPercentage% off';
  }

  @override
  String get total => 'Total';

  @override
  String price_in_rs(Object price) {
    return 'Rs $price';
  }

  @override
  String get make_payment => 'Make Payment';

  @override
  String get choose_right_plan => 'Choose the right Plan';

  @override
  String get choose_plan_description =>
      'choose a plan and set your accordingly';

  @override
  String get loading_plans => 'Loading plans...';

  @override
  String get payment_successful => 'Payment Successfully Received!';

  @override
  String get payment_success_message =>
      'Your payment has been processed successfully. Now you can complete your registration to get started.';

  @override
  String get complete_registration => 'Complete Registration';

  @override
  String get no_plans_available => 'No Plans Available';

  @override
  String get no_plans_message =>
      'There are currently no plans available for this type.';

  @override
  String get refresh => 'Refresh';

  @override
  String get apply_now => 'Apply Now';

  @override
  String get delete_vehicle => 'Delete Vehicle';

  @override
  String get confirm_delete_vehicle =>
      'Are you sure you want to delete this vehicle?';

  @override
  String vehicle_name_number(Object vehicleName, Object vehicleNumber) {
    return '$vehicleName ($vehicleNumber)';
  }

  @override
  String get action_cannot_be_undone => 'This action cannot be undone.';

  @override
  String get vehicle_actions => 'Vehicle Actions';

  @override
  String get select_vehicle_action => 'Select an action for this vehicle:';

  @override
  String get permanently_remove_vehicle => 'Permanently remove this vehicle';

  @override
  String get disable_vehicle => 'Disable Vehicle';

  @override
  String get hide_vehicle_from_listings => 'Hide this vehicle from listings';

  @override
  String get enable_vehicle => 'Enable Vehicle';

  @override
  String get make_vehicle_visible => 'Make this vehicle visible in listings';

  @override
  String get loading_vehicle_details => 'Loading vehicle details...';

  @override
  String get error_loading_vehicle_details => 'Error loading vehicle details';

  @override
  String get pricing_location => 'Pricing & Location';

  @override
  String currency(Object currency) {
    return '$currency';
  }

  @override
  String vehicle_images_count(Object count) {
    return 'Vehicle Images ($count)';
  }

  @override
  String get failed_to_load => 'Failed to load';

  @override
  String vehicle_videos_count(Object count) {
    return 'Vehicle Videos ($count)';
  }

  @override
  String media_type_index(Object index, Object mediaType) {
    return '$mediaType $index';
  }

  @override
  String get vehicle_documents => 'Vehicle Documents';

  @override
  String get no_documents_uploaded => 'No documents uploaded';

  @override
  String get edit_vehicle => 'Edit Vehicle';

  @override
  String get press_back_again_to_exit => 'Press back again to exit';

  @override
  String get notifications => 'Notifications';

  @override
  String get notification_marked_read => 'Notification marked as read';

  @override
  String get sharing_notification => 'Sharing notification...';

  @override
  String get no_notifications => 'No Notifications';

  @override
  String get no_notifications_message =>
      'You don\'t have any notifications yet.';

  @override
  String get failed_to_load_notifications =>
      'Failed to load notifications. Please check your connection and try again.';

  @override
  String get details => 'Details';

  @override
  String get colon => ':';

  @override
  String search_error(Object error) {
    return 'Search error: $error';
  }

  @override
  String error_getting_location(Object error) {
    return 'Error getting location details: $error';
  }

  @override
  String get select_location_first => 'Please select a location first';

  @override
  String no_locations_found(Object query) {
    return 'No locations found matching $query';
  }

  @override
  String get help_support => 'Help & Support';

  @override
  String get loading_faq => 'Loading FAQ...';

  @override
  String get no_faq_available => 'No FAQ Available';

  @override
  String get faq_content_coming =>
      'FAQ content will appear here once available';

  @override
  String get find_answers => 'Find answers to common questions';

  @override
  String questions_count(Object count) {
    return '$count Questions';
  }

  @override
  String get settings => 'Settings';

  @override
  String get language_settings => 'change language';

  @override
  String get delete_account => 'Delete Account';

  @override
  String get delete_account_warning =>
      'This action cannot be undone. All your data will be permanently deleted.';

  @override
  String get my_profile => 'My Profile';

  @override
  String get load_profile => 'Load Profile';

  @override
  String profile_name(Object name) {
    return 'Name: $name';
  }

  @override
  String profile_phone(Object phone) {
    return 'Phone: $phone';
  }

  @override
  String profile_user_type(Object userType) {
    return 'User Type: $userType';
  }

  @override
  String email_copied(Object email) {
    return 'Email copied to clipboard: $email';
  }

  @override
  String unable_to_open_email(Object email) {
    return 'Unable to open email client. Email: $email';
  }

  @override
  String phone_copied(Object phone) {
    return 'Phone number copied: $phone';
  }

  @override
  String unable_to_process_phone(Object phone) {
    return 'Unable to process phone number: $phone';
  }

  @override
  String get address_copied => 'Address copied to clipboard';

  @override
  String get unable_to_open_maps => 'Unable to open maps or copy address';

  @override
  String get support_center => 'Support Center';

  @override
  String get loading_support_info => 'Loading support information...';

  @override
  String get how_can_we_help => 'How can we help you?';

  @override
  String get choose_support_method =>
      'Choose the best way to reach our support team';

  @override
  String get contact_by_email => 'Contact by Email';

  @override
  String get other_ways_to_contact => 'Other Ways to Reach Us';

  @override
  String get accept_to_continue => 'Please accept to continue';

  @override
  String get loading_data => 'Loading data...';

  @override
  String get failed_to_load_data => 'Failed to load data';

  @override
  String get no_data_available => 'No data available';

  @override
  String get read_and_agree => 'I have read and agree';

  @override
  String get accept => 'Accept';

  @override
  String get terms_conditions => 'Terms and Conditions';

  @override
  String get effective_date => 'Effective Date: 15 Apr 2025';

  @override
  String get terms_welcome_message =>
      'Welcome to RideNow Taxi App. By using our services, you agree to the terms and conditions outlined below. Please read them carefully before booking a ride.';

  @override
  String get need_help_contact => 'Need Help?\nContact Support';

  @override
  String get customer_care_24x7 => '24x7 Customer Care';

  @override
  String get phone_icon => '📞';

  @override
  String get support_phone => '+91-9999999999';

  @override
  String get email_icon => '📧';

  @override
  String get support_email => 'support@ridenow.com';

  @override
  String get profile_photo_required => 'Profile photo is required';

  @override
  String get wait_for_doc_verification =>
      'Please wait for all documents to be verified before proceeding';

  @override
  String get all_docs_required => 'All required documents are needed';

  @override
  String get fuel_type => 'fuelType';

  @override
  String get vehicle_ownership => 'vehicleOwnership';

  @override
  String get rc_front_required => 'RC Book front photo is required';

  @override
  String get rc_back_required => 'RC Book back photo is required';

  @override
  String get at_least_one_vehicle_photo =>
      'At least one vehicle photo is required';

  @override
  String get service_city => 'serviceCity';

  @override
  String get language => 'language';

  @override
  String get no_document_uploaded => 'No document uploaded yet';

  @override
  String get verify_docs_before_submission =>
      'Please verify all documents before submission';

  @override
  String get become_auto_rickshaw_driver => 'Become an Auto Rickshaw Driver';

  @override
  String get india_code => '+91';

  @override
  String get doc_verification => 'Document Verification';

  @override
  String get allow_fare_negotiation => 'Allow Fare Negotiation';

  @override
  String get service_cities => 'Service Cities';

  @override
  String get personal_information => 'Personal Information';

  @override
  String get doc_verification_status => 'Documents Verification Status';

  @override
  String get uploaded_files => 'Uploaded Files :';

  @override
  String get fare_details => 'Fare Details';

  @override
  String get languages_spoken => 'Languages Spoken';

  @override
  String get address => 'Address';

  @override
  String get submission_confirmation =>
      'By submitting this application, you confirm that all the information provided is accurate and true.';

  @override
  String label_colon(Object label) {
    return '$label:';
  }

  @override
  String get gender => 'gender';

  @override
  String get vehicle_type => 'vehicleType';

  @override
  String get services_cities => 'servicesCities';

  @override
  String get language_spoken => 'languageSpoken';

  @override
  String get become_driver => 'Become a Driver';

  @override
  String get experience_charges => 'Experience & Charges';

  @override
  String get vehicle_cities => 'Vehicle & Cities';

  @override
  String get successfully_verified => 'Successfully Verified';

  @override
  String get verify_images => 'Verify Images';

  @override
  String get enter_aadhaar_number => 'Enter Your Aadhaar Number';

  @override
  String get name_as_on_aadhaar => 'Name as on Aadhaar';

  @override
  String get verify => 'Verify';

  @override
  String get enter_dl_number => 'Enter Your Driving License Number';

  @override
  String get name_as_on_license => 'Name as on License';

  @override
  String get date_of_birth => 'Date of Birth';

  @override
  String get view => 'View';

  @override
  String get image_preview => 'Image Preview';

  @override
  String image_count(Object currentIndex, Object totalImages) {
    return '$currentIndex of $totalImages';
  }

  @override
  String get please_check_internet => 'Please check your internet connection';

  @override
  String get application_submitted => 'Application submitted successfully!';

  @override
  String error_occurred(Object error) {
    return 'An error occurred: $error';
  }

  @override
  String get e_rickshaw_registration => 'E-RICKSHAW Registration';

  @override
  String get submission_confirmation_complete =>
      'By submitting this application, you confirm that all the information provided is accurate and complete.';

  @override
  String get become_transporter => 'Become a Transporter';

  @override
  String get fleet_size => 'Fleet Size';

  @override
  String get enable_price_negotiation =>
      'Enable price negotiation via chat/calls';

  @override
  String get business_info => 'Business Information';

  @override
  String get contact_preferences => 'Contact Preferences';

  @override
  String get documents => 'Documents';

  @override
  String get submission_confirmation_valid =>
      'By submitting this application, you confirm that all the information provided is accurate and documents are valid.';

  @override
  String get air_conditioning => 'airConditioning';

  @override
  String get served_location => 'servedLocation';

  @override
  String get priceIs_negotiable => 'Price is negotiable';

  @override
  String get vehicle_videos_optional => 'Vehicle Videos (Optional)';

  @override
  String get vehicle_registration_docs => 'Vehicle Registration Documents';

  @override
  String get rc_front_photo => 'RC Book Front Photo';

  @override
  String get rc_back_photo => 'RC Book Back Photo';

  @override
  String get review_vehicle_info => 'Review Your Vehicle Information';

  @override
  String videos_uploaded_count(Object count) {
    return '$count video(s) uploaded';
  }

  @override
  String get reg_documents => 'Registration Documents';

  @override
  String get rc_front => 'RC Book Front';

  @override
  String get rc_back => 'RC Book Back';

  @override
  String get review_before_submitting =>
      'Please review all the information carefully before submitting.';

  @override
  String failed_to_delete_chat(Object error) {
    return 'Failed to delete chat: $error';
  }

  @override
  String get delete_chat => 'Delete Chat';

  @override
  String confirm_delete_chat(Object name) {
    return 'Are you sure you want to delete this chat with $name?';
  }

  @override
  String get message => 'Message';

  @override
  String get loading_chats => 'Loading chats...';

  @override
  String get no_chats_yet => 'No chats yet';

  @override
  String get start_conversation_message =>
      'Start a conversation to see it here';

  @override
  String get deleting => 'Deleting...';

  @override
  String get typing => 'Typing...';

  @override
  String get type_message => 'Type a message...';

  @override
  String get upload_media => 'Upload Media';

  @override
  String get document => 'Document';

  @override
  String get download => 'Download';

  @override
  String get unsupported_media => 'Unsupported media type';

  @override
  String get loading_video => 'Loading video...';

  @override
  String get cannot_open_document => 'Cannot open document';

  @override
  String get failed_to_download_doc => 'Failed to download document';

  @override
  String get filter_options => 'Filter Options';

  @override
  String get reset => 'Reset';

  @override
  String get apply => 'Apply';

  @override
  String get unsaved_changes => 'Unsaved Changes';

  @override
  String get confirm_leave_without_saving =>
      'You have unsaved changes. Are you sure you want to leave?';

  @override
  String get leave => 'Leave';

  @override
  String get edit_profile => 'Edit Profile';

  @override
  String get loading_profile => 'Loading your profile...';

  @override
  String get view_edit_profile => 'View and edit profile';

  @override
  String get plans => 'Plans';

  @override
  String get my_ratings => 'My Ratings';

  @override
  String get faq => 'Faq';

  @override
  String get support => 'Support';

  @override
  String get rate_our_app => 'Rate our app';

  @override
  String get about_us => 'About Us';

  @override
  String get privacy_policy => 'Privacy Policy';

  @override
  String get choose_perfect_driver => 'Choose Your Perfect Driver';

  @override
  String get no_driver_found => 'No Driver found';

  @override
  String get try_different_criteria => 'Try searching with different criteria';

  @override
  String years_experience(Object experience) {
    return '$experience years';
  }

  @override
  String get failed_to_log_activity => 'Failed to log activity';

  @override
  String get view_more => 'View More';

  @override
  String get driver_profile => 'Driver Profile';

  @override
  String get no_driver_details => 'No driver details found';

  @override
  String years_experience_display(Object experience) {
    return '$experience Years Experience';
  }

  @override
  String get more_info => 'More Information';

  @override
  String colon_value(Object value) {
    return ': $value';
  }

  @override
  String get driver_bio => 'Driver Bio';

  @override
  String get minimum_charges => 'Minimum Charges';

  @override
  String rupees_amount(Object amount) {
    return '₹ $amount';
  }

  @override
  String get review_submitted => 'Review submitted successfully!';

  @override
  String get ratings_reviews => 'Ratings & Reviews';

  @override
  String get rating_colon => 'Rating:';

  @override
  String get congratulations => 'Congratulations!';

  @override
  String get successfully_registered => 'You have successfully registered.';

  @override
  String get payment_successful_title => 'Payment Successful!';

  @override
  String get transaction_completed => 'Your transaction has been completed';

  @override
  String get date_colon => 'Date';

  @override
  String get time_colon => 'Time';

  @override
  String get transaction_id => 'Transaction ID';

  @override
  String get amount_colon => 'Amount';

  @override
  String get payment_method_colon => 'Payment Method';

  @override
  String get share_receipt => 'Share Receipt';

  @override
  String get done => 'Done';

  @override
  String get loading_transporter_details => 'Loading transporter details...';

  @override
  String total_fleet_size_display(Object count) {
    return 'Total Fleet Size: $count';
  }

  @override
  String get available_vehicles => 'Available Vehicles';

  @override
  String vehicles_count(Object count, Object plural) {
    return '$count Vehicle$plural';
  }

  @override
  String current_of_total(Object current, Object total) {
    return '$current/$total';
  }

  @override
  String get no_vehicles_available => 'No vehicles available';

  @override
  String price_per_hour(Object currency, Object price) {
    return '$currency$price/hr';
  }

  @override
  String get negotiable => 'Negotiable';

  @override
  String get image_not_available => 'Image not available';

  @override
  String current_image_of_total(Object currentImage, Object totalImages) {
    return '$currentImage/$totalImages';
  }

  @override
  String get video_unavailable => 'Video unavailable';

  @override
  String get find_vehicles_drivers => 'Find the perfect vehicles and drivers';

  @override
  String get use_current_location => 'Use Current Location';

  @override
  String get you => 'You';

  @override
  String get suggestions => 'Suggestions';

  @override
  String get choose_vehicle_type => 'Choose Your Vehicle Type';

  @override
  String get select_vehicle_option =>
      'Select the option that best describes your vehicle';

  @override
  String get become_driver_transporter => 'Become Driver/Transporter';

  @override
  String get price_example => '₹170.71';

  @override
  String get subscribe_now => 'Subscribe Now';

  @override
  String failed_to_load_more_vehicles(Object error) {
    return 'Failed to load more vehicles: $error';
  }

  @override
  String failed_to_refresh(Object error) {
    return 'Failed to refresh: $error';
  }

  @override
  String get could_not_launch_phone => 'Could not launch phone app';

  @override
  String seats_count(Object seats) {
    return '$seats';
  }

  @override
  String get min_charge => 'min charge';

  @override
  String get no_vehicles_found => 'Oops! We couldn\'t find any vehicles.';

  @override
  String get try_changing_location =>
      '🔍 Try changing the location or exploring other categories.';

  @override
  String get no_more_vehicles => 'No more vehicles';

  @override
  String get view_more_vehicles => 'View More Vehicles';

  @override
  String vehicle_details_title(Object vehicleName) {
    return '$vehicleName Details';
  }

  @override
  String short_id(Object shortId) {
    return 'ID: $shortId';
  }

  @override
  String get about_colon => 'About';

  @override
  String get min_charge_colon => 'Min Charge';

  @override
  String get swipe_navigate_instructions => 'Swipe to navigate • Pinch to zoom';

  @override
  String get continue_co => 'Continue';

  @override
  String get phone_number_10_digits => 'Phone number must be 10 digits';

  @override
  String get only_digits_allowed => 'Only digits are allowed';

  @override
  String get enter_code_whatsapp =>
      'Enter the code that was sent to your WhatsApp number';

  @override
  String get enter_valid_email => 'Please enter a valid email address';

  @override
  String get by_continuing_agree_to => 'By continuing you agree to the';

  @override
  String get and => 'and';

  @override
  String get explore => 'Explore';

  @override
  String get dashboard => 'Dashboard';

  @override
  String get category => 'Category';

  @override
  String get home => 'Home';

  @override
  String get car => 'Car';

  @override
  String get auto => 'Auto';

  @override
  String get eRickshaw => 'E-Rickshaw';

  @override
  String get suv => 'SUV';

  @override
  String get minivan => 'Minivan';

  @override
  String get bus => 'Bus';

  @override
  String get driver => 'Driver';

  @override
  String fieldRequired(Object fieldName) {
    return '$fieldName is required';
  }

  @override
  String get profilePhoto => 'Profile photo';

  @override
  String get firstName => 'First name';

  @override
  String get emailAddress => 'Email address';

  @override
  String get phoneNumber => 'Phone number';

  @override
  String get allVehicles => 'All Vehicles';

  @override
  String get youAreCurrentlyHere => 'You are currently here';

  @override
  String get howItWorks => 'How It Works';

  @override
  String get stepSearch => 'Search nearby or global ride';

  @override
  String get stepContact => 'Contact & confirm details';

  @override
  String get stepEnjoy => 'Enjoy a smooth ride!';

  @override
  String get directContact => 'Direct Contact.';

  @override
  String get noCommission => 'No Commission.';

  @override
  String get poweredByBuntyBhai => 'Powered by Bunty Bhai';

  @override
  String get tapToChangeLocation => 'Tap to change location';

  @override
  String get seats => 'Seats';

  @override
  String get searchLocation => 'Search location';

  @override
  String get standAloneDriver => 'Stand Alone Driver';

  @override
  String get autoRickshaw => 'Auto Rickshaw';

  @override
  String get eRickshawt => 'E-Rickshaw';

  @override
  String get transporter => 'Transporter';

  @override
  String get locationNotInIndia => 'This location is not in India';

  @override
  String get addressNotAvailable => 'Address not available';

  @override
  String get selectLocationFirst => 'Please select a location first';

  @override
  String get fixedPrice => 'Fixed Price';

  @override
  String get pleaseTryAgainLater => 'Please try again later';

  @override
  String get categoryNotFoundMessage =>
      'Oops! We couldn\'t find this category at your selected location. We\'re expanding fast—stay tuned!';

  @override
  String get idLabel => 'ID';

  @override
  String get about => 'About';

  @override
  String get vehicle_name => 'Vehicle Name';

  @override
  String get type => 'Type';

  @override
  String get mileage => 'Mileage';

  @override
  String mileage_value(Object value) {
    return '$value km/l';
  }

  @override
  String get not_specified => 'Not specified';

  @override
  String get seating_capacity => 'Seating Capacity';

  @override
  String seating_capacity_value(Object value) {
    return '$value persons';
  }

  @override
  String get pricingAndAvailability => 'Pricing & Availability';

  @override
  String get priceType => 'Price Type';

  @override
  String get rating => 'Rating';

  @override
  String get writeYourReviewHere => 'Write your review here...';

  @override
  String get review => 'Review';

  @override
  String get submitting => 'Submitting...';

  @override
  String get submitReview => 'Submit Review';

  @override
  String get reviewSubmittedSuccessfully => 'Review submitted successfully';

  @override
  String get reviewDeletedSuccessfully => 'Review deleted successfully';

  @override
  String get specifications => 'Specifications';

  @override
  String get features => 'Features';

  @override
  String get vehicleVideos => 'Vehicle Videos';

  @override
  String get experience => 'Experience';

  @override
  String get totalReviews => 'Total Reviews';

  @override
  String get averageRating => 'Average Rating';

  @override
  String get ago => 'ago';

  @override
  String get year => 'year';

  @override
  String get years => 'years';

  @override
  String get month => 'month';

  @override
  String get months => 'months';

  @override
  String get day => 'day';

  @override
  String get days => 'days';

  @override
  String get hour => 'hour';

  @override
  String get hours => 'hours';

  @override
  String get minute => 'minute';

  @override
  String get minutes => 'minutes';

  @override
  String get justNow => 'Just now';

  @override
  String get today => 'Today';

  @override
  String get yesterday => 'Yesterday';

  @override
  String get contactPreferences => 'Contact Preferences';

  @override
  String get whatsappNotifications => 'WhatsApp Notifications';

  @override
  String get whatsappSubtitle => 'Receive notifications via WhatsApp';

  @override
  String get phoneNotifications => 'Phone Notifications';

  @override
  String get phoneSubtitle => 'Receive notifications via phone calls/SMS';

  @override
  String get accountManagement => 'Account Management';

  @override
  String get deleteAccount => 'Delete Account';

  @override
  String get deleteAccountSubtitle => 'Permanently delete your account';

  @override
  String get otherSettings => 'Other Settings';

  @override
  String get changeLanguage => 'Change language';

  @override
  String get comingSoon => 'Coming Soon';

  @override
  String get deleteAccountDialogTitle => 'Delete Account';

  @override
  String get deleteAccountDialogContent =>
      'This action cannot be undone. All your data will be permanently deleted and you will lose access to your account.';

  @override
  String get authenticationError => 'Authentication error. Please login again.';

  @override
  String get preferencesUpdated => 'Preferences updated successfully';

  @override
  String get failedUpdatePreferences => 'Failed to update preferences';

  @override
  String get networkError => 'Network error. Please check your connection.';

  @override
  String get accountDeleted => 'Account deleted successfully';

  @override
  String get failedDeleteAccount => 'Failed to delete account';

  @override
  String get noCamerasAvailable => 'No cameras available on this device';

  @override
  String get cameraTitleBlink => 'Camera with Blink Detection';

  @override
  String get cameraTitle => 'Camera';

  @override
  String get cameraSubtitleBlink => 'Take photo with advanced detection';

  @override
  String get cameraSubtitle => 'Take a new photo';

  @override
  String get uploadPromptButton => 'Click here to upload';

  @override
  String get remove => 'Remove';

  @override
  String get sixDigitPinIsRequired => '6 digit pin is required';

  @override
  String pleaseSelectAtLeastOne(Object fieldName) {
    return 'Please select at least one $fieldName';
  }

  @override
  String get pleaseSelectFuelType => 'Please select fuel type';

  @override
  String get selectVehicleOwnership => 'Select vehicle ownership';

  @override
  String get fareAndCities => 'Fare & Cities';

  @override
  String get fullName => 'Full name';

  @override
  String get pleaseSelectState => 'Please select a state';

  @override
  String get pleaseSelectCity => 'Please select a city';

  @override
  String get pincode => 'Pincode';

  @override
  String get allDocumentsVerifiedSuccessfully =>
      'All documents have been verified successfully!';

  @override
  String get pleaseEnsureAllDocumentsUploadedVerified =>
      'Please ensure all documents are uploaded and verified.';

  @override
  String get aadhaarNumber => 'Aadhaar number';

  @override
  String get drivingLicense => 'Driving License';

  @override
  String get uploaded => 'Uploaded';

  @override
  String get yes => 'Yes';

  @override
  String get no => 'No';

  @override
  String get city => 'City';

  @override
  String get state => 'State';

  @override
  String get allDocumentsVerifiedReadyToSubmit =>
      'All documents verified! Ready to submit.';

  @override
  String get documentVerificationIncomplete =>
      'Document verification incomplete. Please verify all documents before submission.';

  @override
  String get submit => 'Submit';

  @override
  String get next => 'Next';

  @override
  String get vehicleNumber => 'Vehicle number';

  @override
  String get no_internet_connection => 'No Internet Connection';

  @override
  String get check_internet_connection =>
      'Please check your internet connection and try again.';

  @override
  String get server_unavailable_message =>
      'The server is currently unavailable (502). Please try again later.';

  @override
  String get unable_to_connect_server =>
      'Unable to connect to the server. Please check your connection.';

  @override
  String get request_timeout => 'Request Timeout';

  @override
  String get request_timeout_message =>
      'The request took too long to complete. Please try again.';

  @override
  String get api_error => 'API Error';

  @override
  String get api_error_message =>
      'Something went wrong while fetching data. Please try again.';

  @override
  String get unexpected_error_message =>
      'An unexpected error occurred. Please try again.';

  @override
  String get try_again => 'Try Again';

  @override
  String get open_settings => 'Open Settings';

  @override
  String get check_device_settings => 'Please check your device settings';

  @override
  String get startDetectionMessage => 'Press \'Start Detection\' to begin';

  @override
  String get stopCapturing => 'Stop Capturing';

  @override
  String get startCapturing => 'Start Capturing';

  @override
  String get cameraReady => 'Camera ready - Start detection';

  @override
  String get cameraInitError => 'Error: Camera initialization failed';

  @override
  String get positionFace => 'Position your face in the circle';

  @override
  String get noFaceDetected =>
      'No face detected - Position your face in the circle';

  @override
  String get moveCloser => 'Move closer to the camera';

  @override
  String get blinkToCapture => 'Perfect! Now blink your eyes to capture';

  @override
  String get blinkDetected => 'Blink detected! Opening eyes...';

  @override
  String expiresOn(Object date, Object days) {
    return 'Expires on $date ($days days left)';
  }

  @override
  String get expiryNotAvailable => 'Expiry date not available';

  @override
  String get planIncludes => 'Your plan includes:';

  @override
  String get paymentOn => 'Payment on';

  @override
  String get chat => 'Chat';

  @override
  String get whatsapp => 'WhatsApp';

  @override
  String get call => 'Call';

  @override
  String get views => 'Views';

  @override
  String get messages => 'Messages';

  @override
  String get calls => 'Calls';

  @override
  String get clicks => 'Clicks';

  @override
  String get vehicleAdded => 'Vehicle added';

  @override
  String get listed => 'Listed';

  @override
  String get unlisted => 'Unlisted';

  @override
  String get hire_vehicle => 'Hire Vehicle';

  @override
  String get all_Services => 'All Services';

  @override
  String get hire_driver => 'Hire Driver';

  @override
  String get search_by_vehicle_type_city_or_car_code =>
      'Search by vehicle type, city or car code';

  @override
  String get available_vehicles_with_driver =>
      'Available vehicles with a driver';

  @override
  String get become_partner => 'Become Partner';

  @override
  String get around_you => 'Around You';

  @override
  String get active_drivers_nearby => 'Active Drivers Nearby';

  @override
  String get see_all => 'See all';

  @override
  String get joinAsPartner => 'Join as Partner';

  @override
  String get newOpportunities => 'New Opportunities';

  @override
  String get startYourJourney =>
      'Start your journey with us and unlock unlimited earning potential. Join thousands of successful partners.';

  @override
  String get highEarnings => 'High Earnings';

  @override
  String get fastGrowth => 'Fast Growth';

  @override
  String get fullSupport => 'Full Support';

  @override
  String get activePartners => 'Active Partners';

  @override
  String get monthlyEarnings => 'Monthly Earnings';

  @override
  String get partnerRating => 'Partner Rating';

  @override
  String get startPartnershipJourney => 'Start Partnership Journey';

  @override
  String get quickApproval => 'Quick approval in 24 hours';

  @override
  String get partner => 'Partner';

  @override
  String get joinOurPartnerNetwork => 'Join Our Partner Network';

  @override
  String get partnershipIntro =>
      'Choose your preferred partnership model and start earning today';

  @override
  String get selectPartnershipType => 'Select Your Partnership Type';

  @override
  String get partnerBenefits => 'Partner Benefits';

  @override
  String get transporterOwner => 'Transporter Owner';

  @override
  String get independentCarOwner => 'Independent Car Owner';

  @override
  String get autoRickshawOwner => 'AutoRickshaw Owner';

  @override
  String get eRickshawOwner => 'eRickshaw Owner';

  @override
  String get earnMore => 'Earn More';

  @override
  String get earnMoreDesc => 'Maximize your income potential';

  @override
  String get easyManagement => 'Easy Management';

  @override
  String get easyManagementDesc => 'Simple app-based operations';

  @override
  String get trustedPlatform => 'Trusted Platform';

  @override
  String get trustedPlatformDesc => 'Join thousands of partners';

  @override
  String get flexibleWork => 'Flexible Work';

  @override
  String get flexibleWorkDesc => 'Work on your own schedule';

  @override
  String get registrationFees => 'Registration Fees';

  @override
  String get registrationFeesDesc => 'One-time payment for account setup';

  @override
  String get accountSetupFee => 'Account Setup Fee';

  @override
  String get accountSetupIncludes => 'Includes verification & documentation';

  @override
  String get chooseYourPlan => 'Choose Your Plan';

  @override
  String get chooseYourPlanDesc => 'Select the best plan for your business';

  @override
  String get perMonth => '/month';

  @override
  String get reviewsAndRatings => 'Reviews & Ratings';

  @override
  String get pricing => 'Pricing';
}
