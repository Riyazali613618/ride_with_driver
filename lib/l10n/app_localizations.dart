import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_bn.dart';
import 'app_localizations_en.dart';
import 'app_localizations_gu.dart';
import 'app_localizations_hi.dart';
import 'app_localizations_kn.dart';
import 'app_localizations_ml.dart';
import 'app_localizations_mr.dart';
import 'app_localizations_ta.dart';
import 'app_localizations_te.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
      : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('bn'),
    Locale('en'),
    Locale('gu'),
    Locale('hi'),
    Locale('kn'),
    Locale('ml'),
    Locale('mr'),
    Locale('ta'),
    Locale('te')
  ];

  /// No description provided for @failed_to_load_chat_history.
  ///
  /// In en, this message translates to:
  /// **'Failed to load chat history'**
  String get failed_to_load_chat_history;

  /// No description provided for @network_error.
  ///
  /// In en, this message translates to:
  /// **'Network Error'**
  String network_error(Object error);

  /// No description provided for @loaded_from_cache.
  ///
  /// In en, this message translates to:
  /// **'Loaded from cache'**
  String get loaded_from_cache;

  /// No description provided for @failed_to_send_otp.
  ///
  /// In en, this message translates to:
  /// **'Failed to send OTP. Please try again.'**
  String get failed_to_send_otp;

  /// No description provided for @something_went_wrong_check_connection.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong. Please check your connection.'**
  String get something_went_wrong_check_connection;

  /// No description provided for @upload_failed.
  ///
  /// In en, this message translates to:
  /// **'Upload failed: {error}'**
  String upload_failed(Object error);

  /// No description provided for @uploading_media.
  ///
  /// In en, this message translates to:
  /// **'Uploading media...'**
  String get uploading_media;

  /// No description provided for @invoice.
  ///
  /// In en, this message translates to:
  /// **'Invoice'**
  String get invoice;

  /// No description provided for @error_generating_pdf.
  ///
  /// In en, this message translates to:
  /// **'Error generating PDF: {error}'**
  String error_generating_pdf(Object error);

  /// No description provided for @error_printing.
  ///
  /// In en, this message translates to:
  /// **'Error printing: {error}'**
  String error_printing(Object error);

  /// No description provided for @invoice_simplified_note.
  ///
  /// In en, this message translates to:
  /// **'Note: This is a simplified version of your invoice. The original formatting could not be preserved in PDF format.'**
  String get invoice_simplified_note;

  /// No description provided for @error_rendering_content.
  ///
  /// In en, this message translates to:
  /// **'Error rendering content'**
  String get error_rendering_content;

  /// No description provided for @loading.
  ///
  /// In en, this message translates to:
  /// **'Loading...'**
  String get loading;

  /// No description provided for @check_internet_and_retry.
  ///
  /// In en, this message translates to:
  /// **'Please check your internet connection and try again.'**
  String get check_internet_and_retry;

  /// No description provided for @retry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get retry;

  /// No description provided for @step_number.
  ///
  /// In en, this message translates to:
  /// **'{stepNumber}'**
  String step_number(Object stepNumber);

  /// No description provided for @search_for_location.
  ///
  /// In en, this message translates to:
  /// **'Search for a location...'**
  String get search_for_location;

  /// No description provided for @image_captured.
  ///
  /// In en, this message translates to:
  /// **'Image Captured!'**
  String get image_captured;

  /// No description provided for @photo_captured_successfully.
  ///
  /// In en, this message translates to:
  /// **'Your photo has been captured successfully!'**
  String get photo_captured_successfully;

  /// No description provided for @capture_again.
  ///
  /// In en, this message translates to:
  /// **'Capture Again'**
  String get capture_again;

  /// No description provided for @use_this_photo.
  ///
  /// In en, this message translates to:
  /// **'Use This Photo'**
  String get use_this_photo;

  /// No description provided for @capture_image.
  ///
  /// In en, this message translates to:
  /// **'Capture Image'**
  String get capture_image;

  /// No description provided for @instructions.
  ///
  /// In en, this message translates to:
  /// **'Instructions:'**
  String get instructions;

  /// No description provided for @face_capture_instructions.
  ///
  /// In en, this message translates to:
  /// **'1. Position your face in the circle\n2. Wait for the green border\n3. Blink your eyes to capture'**
  String get face_capture_instructions;

  /// No description provided for @replace_media.
  ///
  /// In en, this message translates to:
  /// **'Replace Media'**
  String get replace_media;

  /// No description provided for @confirm_replace.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to replace'**
  String get confirm_replace;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @replace.
  ///
  /// In en, this message translates to:
  /// **'Replace'**
  String get replace;

  /// No description provided for @camera_error.
  ///
  /// In en, this message translates to:
  /// **'Camera Error'**
  String get camera_error;

  /// No description provided for @camera_access_issue.
  ///
  /// In en, this message translates to:
  /// **'Could not access camera. Please check:'**
  String get camera_access_issue;

  /// No description provided for @camera_permission_check.
  ///
  /// In en, this message translates to:
  /// **'• Camera permissions are granted'**
  String get camera_permission_check;

  /// No description provided for @working_camera_check.
  ///
  /// In en, this message translates to:
  /// **'• Your device has a working camera'**
  String get working_camera_check;

  /// No description provided for @camera_in_use_check.
  ///
  /// In en, this message translates to:
  /// **'• No other app is using the camera'**
  String get camera_in_use_check;

  /// No description provided for @ok.
  ///
  /// In en, this message translates to:
  /// **'OK'**
  String get ok;

  /// No description provided for @select_media_source.
  ///
  /// In en, this message translates to:
  /// **'Select Media Source'**
  String get select_media_source;

  /// No description provided for @choose_media_method.
  ///
  /// In en, this message translates to:
  /// **'Choose how you want to add your media'**
  String get choose_media_method;

  /// No description provided for @gallery.
  ///
  /// In en, this message translates to:
  /// **'Gallery'**
  String get gallery;

  /// No description provided for @choose_from_existing.
  ///
  /// In en, this message translates to:
  /// **'Choose from existing photos'**
  String get choose_from_existing;

  /// No description provided for @authentication_required.
  ///
  /// In en, this message translates to:
  /// **'Authentication Required'**
  String get authentication_required;

  /// No description provided for @login_to_upload_media.
  ///
  /// In en, this message translates to:
  /// **'You need to be logged in to upload media. Please log in and try again.'**
  String get login_to_upload_media;

  /// No description provided for @media_preview.
  ///
  /// In en, this message translates to:
  /// **'Media Preview'**
  String get media_preview;

  /// No description provided for @open.
  ///
  /// In en, this message translates to:
  /// **'Open'**
  String get open;

  /// No description provided for @failed_to_load_image.
  ///
  /// In en, this message translates to:
  /// **'Failed to load image'**
  String get failed_to_load_image;

  /// No description provided for @asterisk.
  ///
  /// In en, this message translates to:
  /// **'*'**
  String get asterisk;

  /// No description provided for @update_image.
  ///
  /// In en, this message translates to:
  /// **'Update Image'**
  String get update_image;

  /// No description provided for @uploading.
  ///
  /// In en, this message translates to:
  /// **'Uploading...'**
  String get uploading;

  /// No description provided for @max_file_size.
  ///
  /// In en, this message translates to:
  /// **'(Max. File size: 25 MB)'**
  String get max_file_size;

  /// No description provided for @add_more.
  ///
  /// In en, this message translates to:
  /// **'Add More'**
  String get add_more;

  /// No description provided for @unable_to_load_pdf.
  ///
  /// In en, this message translates to:
  /// **'Unable to load PDF'**
  String get unable_to_load_pdf;

  /// No description provided for @error_loading_media.
  ///
  /// In en, this message translates to:
  /// **'Error Loading Media'**
  String get error_loading_media;

  /// No description provided for @app_initialization_failed.
  ///
  /// In en, this message translates to:
  /// **'App Initialization Failed'**
  String get app_initialization_failed;

  /// No description provided for @ride_with_driver.
  ///
  /// In en, this message translates to:
  /// **'Ride with Driver'**
  String get ride_with_driver;

  /// No description provided for @step_x_of_y.
  ///
  /// In en, this message translates to:
  /// **'Step {currentStep} of {totalSteps}'**
  String step_x_of_y(Object currentStep, Object totalSteps);

  /// No description provided for @previous.
  ///
  /// In en, this message translates to:
  /// **'Previous'**
  String get previous;

  /// No description provided for @company_name.
  ///
  /// In en, this message translates to:
  /// **'Company Name'**
  String get company_name;

  /// No description provided for @enter_company_name.
  ///
  /// In en, this message translates to:
  /// **'Enter your company name'**
  String get enter_company_name;

  /// No description provided for @registered_address.
  ///
  /// In en, this message translates to:
  /// **'Registered Address'**
  String get registered_address;

  /// No description provided for @enter_registered_address.
  ///
  /// In en, this message translates to:
  /// **'Enter your registered address'**
  String get enter_registered_address;

  /// No description provided for @address_type.
  ///
  /// In en, this message translates to:
  /// **'Address Type'**
  String get address_type;

  /// No description provided for @error_picking_document.
  ///
  /// In en, this message translates to:
  /// **'Error picking document: {error}'**
  String error_picking_document(Object error);

  /// No description provided for @gstin.
  ///
  /// In en, this message translates to:
  /// **'GSTIN'**
  String get gstin;

  /// No description provided for @enter_gstin.
  ///
  /// In en, this message translates to:
  /// **'Enter your GSTIN'**
  String get enter_gstin;

  /// No description provided for @business_registration_certificate.
  ///
  /// In en, this message translates to:
  /// **'Business Registration Certificate'**
  String get business_registration_certificate;

  /// No description provided for @upload_certificate_of_incorporation.
  ///
  /// In en, this message translates to:
  /// **'Upload Certificate of Incorporation (PDF/Image)'**
  String get upload_certificate_of_incorporation;

  /// No description provided for @authorized_person_aadhaar.
  ///
  /// In en, this message translates to:
  /// **'Authorized Person Aadhaar'**
  String get authorized_person_aadhaar;

  /// No description provided for @enter_12_digit_aadhaar.
  ///
  /// In en, this message translates to:
  /// **'Enter 12-digit Aadhaar number'**
  String get enter_12_digit_aadhaar;

  /// No description provided for @displayed_as_aadhaar.
  ///
  /// In en, this message translates to:
  /// **'Displayed as: {formattedAadhar}'**
  String displayed_as_aadhaar(Object formattedAadhar);

  /// No description provided for @transportation_permit.
  ///
  /// In en, this message translates to:
  /// **'Transportation Permit'**
  String get transportation_permit;

  /// No description provided for @upload_transportation_permit.
  ///
  /// In en, this message translates to:
  /// **'Upload valid transportation permit documents'**
  String get upload_transportation_permit;

  /// No description provided for @error_picking_images.
  ///
  /// In en, this message translates to:
  /// **'Error picking images: {error}'**
  String error_picking_images(Object error);

  /// No description provided for @total_fleet_size.
  ///
  /// In en, this message translates to:
  /// **'Total Fleet Size'**
  String get total_fleet_size;

  /// No description provided for @small_fleet.
  ///
  /// In en, this message translates to:
  /// **'Small (2-5 vehicles)'**
  String get small_fleet;

  /// No description provided for @medium_fleet.
  ///
  /// In en, this message translates to:
  /// **'Medium (6-15 vehicles)'**
  String get medium_fleet;

  /// No description provided for @large_fleet.
  ///
  /// In en, this message translates to:
  /// **'Large (15+ vehicles)'**
  String get large_fleet;

  /// No description provided for @vehicle_details.
  ///
  /// In en, this message translates to:
  /// **'Vehicle Details'**
  String get vehicle_details;

  /// No description provided for @enter_number_of_vehicles.
  ///
  /// In en, this message translates to:
  /// **'Enter number of {vehicleType}'**
  String enter_number_of_vehicles(Object vehicleType);

  /// No description provided for @allow_negotiation.
  ///
  /// In en, this message translates to:
  /// **'Allow Negotiation'**
  String get allow_negotiation;

  /// No description provided for @vehicle_photos.
  ///
  /// In en, this message translates to:
  /// **'Vehicle Photos'**
  String get vehicle_photos;

  /// No description provided for @add_vehicle_photos_description.
  ///
  /// In en, this message translates to:
  /// **'Add photos of your vehicles to showcase your fleet'**
  String get add_vehicle_photos_description;

  /// No description provided for @add_vehicle_photos.
  ///
  /// In en, this message translates to:
  /// **'Add Vehicle Photos'**
  String get add_vehicle_photos;

  /// No description provided for @complete_now_message.
  ///
  /// In en, this message translates to:
  /// **'Complete now → Get verified in 2 hours!\nIf additional information is required, we will contact you.'**
  String get complete_now_message;

  /// No description provided for @phone_verified_successfully.
  ///
  /// In en, this message translates to:
  /// **'Phone number verified successfully'**
  String get phone_verified_successfully;

  /// No description provided for @verification_failed.
  ///
  /// In en, this message translates to:
  /// **'Verification failed: {error}'**
  String verification_failed(Object error);

  /// No description provided for @contact_information.
  ///
  /// In en, this message translates to:
  /// **'Contact Information'**
  String get contact_information;

  /// No description provided for @contact_information_description.
  ///
  /// In en, this message translates to:
  /// **'These details will be displayed on our website and app for client communication'**
  String get contact_information_description;

  /// No description provided for @contact_person_name.
  ///
  /// In en, this message translates to:
  /// **'Contact Person Name'**
  String get contact_person_name;

  /// No description provided for @name_example.
  ///
  /// In en, this message translates to:
  /// **'e.g., John Doe'**
  String get name_example;

  /// No description provided for @mobile_number.
  ///
  /// In en, this message translates to:
  /// **'Mobile Number'**
  String get mobile_number;

  /// No description provided for @use_login_number.
  ///
  /// In en, this message translates to:
  /// **'Use login number ({phoneNumber})'**
  String use_login_number(Object phoneNumber);

  /// No description provided for @new_mobile_number.
  ///
  /// In en, this message translates to:
  /// **'New Mobile Number'**
  String get new_mobile_number;

  /// No description provided for @enter_mobile_number.
  ///
  /// In en, this message translates to:
  /// **'Enter mobile number'**
  String get enter_mobile_number;

  /// No description provided for @show_mobile_number.
  ///
  /// In en, this message translates to:
  /// **'Show mobile number on website/app'**
  String get show_mobile_number;

  /// No description provided for @whatsapp_number.
  ///
  /// In en, this message translates to:
  /// **'WhatsApp Number'**
  String get whatsapp_number;

  /// No description provided for @new_whatsapp_number.
  ///
  /// In en, this message translates to:
  /// **'New WhatsApp Number'**
  String get new_whatsapp_number;

  /// No description provided for @enter_whatsapp_number.
  ///
  /// In en, this message translates to:
  /// **'Enter WhatsApp number'**
  String get enter_whatsapp_number;

  /// No description provided for @show_whatsapp_number.
  ///
  /// In en, this message translates to:
  /// **'Show WhatsApp number on website/app'**
  String get show_whatsapp_number;

  /// No description provided for @enable_in_app_chat.
  ///
  /// In en, this message translates to:
  /// **'Enable In-App Chat System'**
  String get enable_in_app_chat;

  /// No description provided for @enable_in_app_chat_description.
  ///
  /// In en, this message translates to:
  /// **'Allow customers to contact you through our app'**
  String get enable_in_app_chat_description;

  /// No description provided for @review_your_information.
  ///
  /// In en, this message translates to:
  /// **'Review Your Information'**
  String get review_your_information;

  /// No description provided for @registration_verification_time.
  ///
  /// In en, this message translates to:
  /// **'Your registration will be verified within 2 hours. We may contact you if additional information is needed.'**
  String get registration_verification_time;

  /// No description provided for @all_localized_strings.
  ///
  /// In en, this message translates to:
  /// **'All Localized Strings:'**
  String get all_localized_strings;

  /// No description provided for @strings_with_placeholders.
  ///
  /// In en, this message translates to:
  /// **'Strings with placeholders:'**
  String get strings_with_placeholders;

  /// No description provided for @auth_token_not_found.
  ///
  /// In en, this message translates to:
  /// **'Authentication token not found. Please login again.'**
  String get auth_token_not_found;

  /// No description provided for @server_error.
  ///
  /// In en, this message translates to:
  /// **'Server Error'**
  String get server_error;

  /// No description provided for @failed_to_update_profile.
  ///
  /// In en, this message translates to:
  /// **'Failed to update profile. Please check your internet connection.'**
  String get failed_to_update_profile;

  /// No description provided for @complete_your_profile.
  ///
  /// In en, this message translates to:
  /// **'Complete Your Profile'**
  String get complete_your_profile;

  /// No description provided for @welcome.
  ///
  /// In en, this message translates to:
  /// **'Welcome!'**
  String get welcome;

  /// No description provided for @complete_profile_to_continue.
  ///
  /// In en, this message translates to:
  /// **'Please complete your profile to continue'**
  String get complete_profile_to_continue;

  /// No description provided for @first_name_required.
  ///
  /// In en, this message translates to:
  /// **'First Name *'**
  String get first_name_required;

  /// No description provided for @last_name.
  ///
  /// In en, this message translates to:
  /// **'Last Name'**
  String get last_name;

  /// No description provided for @email_optional.
  ///
  /// In en, this message translates to:
  /// **'Email (Optional)'**
  String get email_optional;

  /// No description provided for @log_in.
  ///
  /// In en, this message translates to:
  /// **'Login here'**
  String get log_in;

  /// No description provided for @enter_correct_phone.
  ///
  /// In en, this message translates to:
  /// **'Please Enter Correct Phone'**
  String get enter_correct_phone;

  /// No description provided for @logout.
  ///
  /// In en, this message translates to:
  /// **'Logout'**
  String get logout;

  /// No description provided for @confirm_logout.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to logout?'**
  String get confirm_logout;

  /// No description provided for @logged_out_successfully.
  ///
  /// In en, this message translates to:
  /// **'Logged out successfully'**
  String get logged_out_successfully;

  /// No description provided for @failed_to_logout.
  ///
  /// In en, this message translates to:
  /// **'Failed to logout. Please try again.'**
  String get failed_to_logout;

  /// No description provided for @enter_all_4_digits.
  ///
  /// In en, this message translates to:
  /// **'Please enter all 4 digits'**
  String get enter_all_4_digits;

  /// No description provided for @failed_to_verify_otp.
  ///
  /// In en, this message translates to:
  /// **'Failed to verify OTP. Please try again.'**
  String get failed_to_verify_otp;

  /// No description provided for @otp_resent.
  ///
  /// In en, this message translates to:
  /// **'OTP code resent to your WhatsApp number'**
  String get otp_resent;

  /// No description provided for @failed_to_resend_otp.
  ///
  /// In en, this message translates to:
  /// **'Failed to resend OTP. Please try again.'**
  String get failed_to_resend_otp;

  /// No description provided for @verify_phone_number.
  ///
  /// In en, this message translates to:
  /// **'Verify your phone number'**
  String get verify_phone_number;

  /// No description provided for @did_not_receive_code.
  ///
  /// In en, this message translates to:
  /// **'Did not receive the code?'**
  String get did_not_receive_code;

  /// No description provided for @resend_code.
  ///
  /// In en, this message translates to:
  /// **'Resend Code'**
  String get resend_code;

  /// No description provided for @change_language.
  ///
  /// In en, this message translates to:
  /// **'Change language {languageName}'**
  String change_language(Object languageName);

  /// No description provided for @your_review.
  ///
  /// In en, this message translates to:
  /// **'Your Review'**
  String get your_review;

  /// No description provided for @something_went_wrong.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong'**
  String get something_went_wrong;

  /// No description provided for @no_reviews_yet.
  ///
  /// In en, this message translates to:
  /// **'No Reviews Yet'**
  String get no_reviews_yet;

  /// No description provided for @no_reviews_received.
  ///
  /// In en, this message translates to:
  /// **'You haven\'t received any reviews yet.'**
  String get no_reviews_received;

  /// No description provided for @my_ratings_reviews.
  ///
  /// In en, this message translates to:
  /// **'My Ratings & Reviews'**
  String get my_ratings_reviews;

  /// No description provided for @error_deleting_review.
  ///
  /// In en, this message translates to:
  /// **'Error deleting review: {error}'**
  String error_deleting_review(Object error);

  /// No description provided for @confirm_delete.
  ///
  /// In en, this message translates to:
  /// **'Confirm Delete'**
  String get confirm_delete;

  /// No description provided for @confirm_delete_review.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete this review?'**
  String get confirm_delete_review;

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// No description provided for @review_rating_count.
  ///
  /// In en, this message translates to:
  /// **'Review & Rating ({totalReviews})'**
  String review_rating_count(Object totalReviews);

  /// No description provided for @error_loading_reviews.
  ///
  /// In en, this message translates to:
  /// **'Error loading reviews: {error}'**
  String error_loading_reviews(Object error);

  /// No description provided for @no_reviews_available.
  ///
  /// In en, this message translates to:
  /// **'No reviews yet'**
  String get no_reviews_available;

  /// No description provided for @be_first_to_review.
  ///
  /// In en, this message translates to:
  /// **'Be the first to share your experience!'**
  String get be_first_to_review;

  /// No description provided for @rate_now.
  ///
  /// In en, this message translates to:
  /// **'Rate Now'**
  String get rate_now;

  /// No description provided for @rating_display.
  ///
  /// In en, this message translates to:
  /// **'{rating}.0'**
  String rating_display(Object rating);

  /// No description provided for @enter_your_review.
  ///
  /// In en, this message translates to:
  /// **'Please enter your review'**
  String get enter_your_review;

  /// No description provided for @error_updating_review.
  ///
  /// In en, this message translates to:
  /// **'Error updating review: {error}'**
  String error_updating_review(Object error);

  /// No description provided for @edit_review.
  ///
  /// In en, this message translates to:
  /// **'Edit Review'**
  String get edit_review;

  /// No description provided for @your_review_text.
  ///
  /// In en, this message translates to:
  /// **'Your review'**
  String get your_review_text;

  /// No description provided for @update.
  ///
  /// In en, this message translates to:
  /// **'Update'**
  String get update;

  /// No description provided for @could_not_open_pdf.
  ///
  /// In en, this message translates to:
  /// **'Could not open PDF'**
  String get could_not_open_pdf;

  /// No description provided for @error_message.
  ///
  /// In en, this message translates to:
  /// **'Error: {error}'**
  String error_message(Object error);

  /// No description provided for @active_subscriptions.
  ///
  /// In en, this message translates to:
  /// **'Active Subscriptions'**
  String get active_subscriptions;

  /// No description provided for @manage_subscriptions.
  ///
  /// In en, this message translates to:
  /// **'Manage your current subscriptions'**
  String get manage_subscriptions;

  /// No description provided for @error.
  ///
  /// In en, this message translates to:
  /// **'Error'**
  String get error;

  /// No description provided for @no_active_subscriptions.
  ///
  /// In en, this message translates to:
  /// **'No Active Subscriptions'**
  String get no_active_subscriptions;

  /// No description provided for @no_subscriptions_message.
  ///
  /// In en, this message translates to:
  /// **'You don\'t have any active subscriptions.'**
  String get no_subscriptions_message;

  /// No description provided for @active_plan.
  ///
  /// In en, this message translates to:
  /// **'Active Plan'**
  String get active_plan;

  /// No description provided for @transaction_history.
  ///
  /// In en, this message translates to:
  /// **'Transaction History'**
  String get transaction_history;

  /// No description provided for @plan_name.
  ///
  /// In en, this message translates to:
  /// **'{planName}'**
  String plan_name(Object planName);

  /// No description provided for @price_in_rupees.
  ///
  /// In en, this message translates to:
  /// **'₹{price}'**
  String price_in_rupees(Object price);

  /// No description provided for @upgrade_plan.
  ///
  /// In en, this message translates to:
  /// **'Upgrade Plan'**
  String get upgrade_plan;

  /// No description provided for @add_payment_methods.
  ///
  /// In en, this message translates to:
  /// **'Add payment methods'**
  String get add_payment_methods;

  /// No description provided for @card_charge_description.
  ///
  /// In en, this message translates to:
  /// **'This card will only be charged when you\nplace an order.'**
  String get card_charge_description;

  /// No description provided for @card_number_example.
  ///
  /// In en, this message translates to:
  /// **'4343 4343 4343 4343'**
  String get card_number_example;

  /// No description provided for @card_expiry.
  ///
  /// In en, this message translates to:
  /// **'MM/YY'**
  String get card_expiry;

  /// No description provided for @card_cvc.
  ///
  /// In en, this message translates to:
  /// **'CVC'**
  String get card_cvc;

  /// No description provided for @add_card.
  ///
  /// In en, this message translates to:
  /// **'Add Card'**
  String get add_card;

  /// No description provided for @upi_payment.
  ///
  /// In en, this message translates to:
  /// **'Upi Payment'**
  String get upi_payment;

  /// No description provided for @scan_card.
  ///
  /// In en, this message translates to:
  /// **'Scan Card'**
  String get scan_card;

  /// No description provided for @my_dashboard.
  ///
  /// In en, this message translates to:
  /// **'My Dashboard'**
  String get my_dashboard;

  /// No description provided for @analytics.
  ///
  /// In en, this message translates to:
  /// **'Analytics'**
  String get analytics;

  /// No description provided for @vehicles.
  ///
  /// In en, this message translates to:
  /// **'Vehicles'**
  String get vehicles;

  /// No description provided for @quick_actions.
  ///
  /// In en, this message translates to:
  /// **'Quick Actions'**
  String get quick_actions;

  /// No description provided for @loading_dashboard.
  ///
  /// In en, this message translates to:
  /// **'Loading dashboard...'**
  String get loading_dashboard;

  /// No description provided for @oops_something_wrong.
  ///
  /// In en, this message translates to:
  /// **'Oops! Something went wrong'**
  String get oops_something_wrong;

  /// No description provided for @reach_percentage.
  ///
  /// In en, this message translates to:
  /// **'{reachPercentage}'**
  String reach_percentage(Object reachPercentage);

  /// No description provided for @profile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profile;

  /// No description provided for @reached.
  ///
  /// In en, this message translates to:
  /// **'Reached'**
  String get reached;

  /// No description provided for @my_vehicles.
  ///
  /// In en, this message translates to:
  /// **'My Vehicles'**
  String get my_vehicles;

  /// No description provided for @vehicles_added_count.
  ///
  /// In en, this message translates to:
  /// **'{currentVehicles}/{maxLimit} vehicles added'**
  String vehicles_added_count(Object currentVehicles, Object maxLimit);

  /// No description provided for @vehicle_limit.
  ///
  /// In en, this message translates to:
  /// **'Vehicle Limit'**
  String get vehicle_limit;

  /// No description provided for @vehicles_limit_count.
  ///
  /// In en, this message translates to:
  /// **'{currentVehicles}/{maxLimit}'**
  String vehicles_limit_count(Object currentVehicles, Object maxLimit);

  /// No description provided for @limit_reached_message.
  ///
  /// In en, this message translates to:
  /// **'Limit reached! Upgrade to add more vehicles.'**
  String get limit_reached_message;

  /// No description provided for @loading_vehicles.
  ///
  /// In en, this message translates to:
  /// **'Loading vehicles...'**
  String get loading_vehicles;

  /// No description provided for @no_vehicles_added.
  ///
  /// In en, this message translates to:
  /// **'No Vehicles Added Yet'**
  String get no_vehicles_added;

  /// No description provided for @add_first_vehicle_message.
  ///
  /// In en, this message translates to:
  /// **'Add your first vehicle to get started with bookings and manage your fleet effectively.'**
  String get add_first_vehicle_message;

  /// No description provided for @add_vehicle.
  ///
  /// In en, this message translates to:
  /// **'Add Vehicle'**
  String get add_vehicle;

  /// No description provided for @upgrade_your_plan.
  ///
  /// In en, this message translates to:
  /// **'Upgrade Your Plan'**
  String get upgrade_your_plan;

  /// No description provided for @upgrade_to_transporter_message.
  ///
  /// In en, this message translates to:
  /// **'You need to upgrade to the TRANSPORTER plan to add more vehicles and unlock premium features.'**
  String get upgrade_to_transporter_message;

  /// No description provided for @maybe_later.
  ///
  /// In en, this message translates to:
  /// **'Maybe Later'**
  String get maybe_later;

  /// No description provided for @upgrade_now.
  ///
  /// In en, this message translates to:
  /// **'Upgrade Now'**
  String get upgrade_now;

  /// No description provided for @profile_updated_success.
  ///
  /// In en, this message translates to:
  /// **'Profile updated successfully!'**
  String get profile_updated_success;

  /// No description provided for @no_profile_data.
  ///
  /// In en, this message translates to:
  /// **'No profile data available'**
  String get no_profile_data;

  /// No description provided for @profile_photo_updated.
  ///
  /// In en, this message translates to:
  /// **'Profile photo updated successfully!'**
  String get profile_photo_updated;

  /// No description provided for @error_updating_photo.
  ///
  /// In en, this message translates to:
  /// **'Error updating photo: {error}'**
  String error_updating_photo(Object error);

  /// No description provided for @verified.
  ///
  /// In en, this message translates to:
  /// **'Verified'**
  String get verified;

  /// No description provided for @basic_information.
  ///
  /// In en, this message translates to:
  /// **'Basic Information'**
  String get basic_information;

  /// No description provided for @address_information.
  ///
  /// In en, this message translates to:
  /// **'Address Information'**
  String get address_information;

  /// No description provided for @fleet_information.
  ///
  /// In en, this message translates to:
  /// **'Fleet Information'**
  String get fleet_information;

  /// No description provided for @vehicle_types.
  ///
  /// In en, this message translates to:
  /// **'Vehicle Types'**
  String get vehicle_types;

  /// No description provided for @vehicle_counts.
  ///
  /// In en, this message translates to:
  /// **'Vehicle Counts'**
  String get vehicle_counts;

  /// No description provided for @professional_information.
  ///
  /// In en, this message translates to:
  /// **'Professional Information'**
  String get professional_information;

  /// No description provided for @saving.
  ///
  /// In en, this message translates to:
  /// **'Saving...'**
  String get saving;

  /// No description provided for @save_changes.
  ///
  /// In en, this message translates to:
  /// **'Save Changes'**
  String get save_changes;

  /// No description provided for @select_label.
  ///
  /// In en, this message translates to:
  /// **'Select {label}'**
  String select_label(Object label);

  /// No description provided for @vehicle_information.
  ///
  /// In en, this message translates to:
  /// **'Vehicle Information'**
  String get vehicle_information;

  /// No description provided for @pricing_information.
  ///
  /// In en, this message translates to:
  /// **'Pricing Information'**
  String get pricing_information;

  /// No description provided for @price_negotiable.
  ///
  /// In en, this message translates to:
  /// **'Price Negotiable'**
  String get price_negotiable;

  /// No description provided for @service_areas.
  ///
  /// In en, this message translates to:
  /// **'Service Areas'**
  String get service_areas;

  /// No description provided for @vehicle_specifications.
  ///
  /// In en, this message translates to:
  /// **'Vehicle Specifications'**
  String get vehicle_specifications;

  /// No description provided for @about_driver.
  ///
  /// In en, this message translates to:
  /// **'About Driver'**
  String get about_driver;

  /// No description provided for @vehicle_images.
  ///
  /// In en, this message translates to:
  /// **'Vehicle Images'**
  String get vehicle_images;

  /// No description provided for @processing_payment.
  ///
  /// In en, this message translates to:
  /// **'Processing payment...'**
  String get processing_payment;

  /// No description provided for @add_payment.
  ///
  /// In en, this message translates to:
  /// **'Add Payment'**
  String get add_payment;

  /// No description provided for @price_in_rupees_with_space.
  ///
  /// In en, this message translates to:
  /// **'₹ {price}'**
  String price_in_rupees_with_space(Object price);

  /// No description provided for @discount_percentage_off.
  ///
  /// In en, this message translates to:
  /// **'{discountPercentage}% off'**
  String discount_percentage_off(Object discountPercentage);

  /// No description provided for @total.
  ///
  /// In en, this message translates to:
  /// **'Total'**
  String get total;

  /// No description provided for @price_in_rs.
  ///
  /// In en, this message translates to:
  /// **'Rs {price}'**
  String price_in_rs(Object price);

  /// No description provided for @make_payment.
  ///
  /// In en, this message translates to:
  /// **'Make Payment'**
  String get make_payment;

  /// No description provided for @choose_right_plan.
  ///
  /// In en, this message translates to:
  /// **'Choose the right Plan'**
  String get choose_right_plan;

  /// No description provided for @choose_plan_description.
  ///
  /// In en, this message translates to:
  /// **'choose a plan and set your accordingly'**
  String get choose_plan_description;

  /// No description provided for @loading_plans.
  ///
  /// In en, this message translates to:
  /// **'Loading plans...'**
  String get loading_plans;

  /// No description provided for @payment_successful.
  ///
  /// In en, this message translates to:
  /// **'Payment Successfully Received!'**
  String get payment_successful;

  /// No description provided for @payment_success_message.
  ///
  /// In en, this message translates to:
  /// **'Your payment has been processed successfully. Now you can complete your registration to get started.'**
  String get payment_success_message;

  /// No description provided for @complete_registration.
  ///
  /// In en, this message translates to:
  /// **'Complete Registration'**
  String get complete_registration;

  /// No description provided for @no_plans_available.
  ///
  /// In en, this message translates to:
  /// **'No Plans Available'**
  String get no_plans_available;

  /// No description provided for @no_plans_message.
  ///
  /// In en, this message translates to:
  /// **'There are currently no plans available for this type.'**
  String get no_plans_message;

  /// No description provided for @refresh.
  ///
  /// In en, this message translates to:
  /// **'Refresh'**
  String get refresh;

  /// No description provided for @apply_now.
  ///
  /// In en, this message translates to:
  /// **'Apply Now'**
  String get apply_now;

  /// No description provided for @delete_vehicle.
  ///
  /// In en, this message translates to:
  /// **'Delete Vehicle'**
  String get delete_vehicle;

  /// No description provided for @confirm_delete_vehicle.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete this vehicle?'**
  String get confirm_delete_vehicle;

  /// No description provided for @vehicle_name_number.
  ///
  /// In en, this message translates to:
  /// **'{vehicleName} ({vehicleNumber})'**
  String vehicle_name_number(Object vehicleName, Object vehicleNumber);

  /// No description provided for @action_cannot_be_undone.
  ///
  /// In en, this message translates to:
  /// **'This action cannot be undone.'**
  String get action_cannot_be_undone;

  /// No description provided for @vehicle_actions.
  ///
  /// In en, this message translates to:
  /// **'Vehicle Actions'**
  String get vehicle_actions;

  /// No description provided for @select_vehicle_action.
  ///
  /// In en, this message translates to:
  /// **'Select an action for this vehicle:'**
  String get select_vehicle_action;

  /// No description provided for @permanently_remove_vehicle.
  ///
  /// In en, this message translates to:
  /// **'Permanently remove this vehicle'**
  String get permanently_remove_vehicle;

  /// No description provided for @disable_vehicle.
  ///
  /// In en, this message translates to:
  /// **'Disable Vehicle'**
  String get disable_vehicle;

  /// No description provided for @hide_vehicle_from_listings.
  ///
  /// In en, this message translates to:
  /// **'Hide this vehicle from listings'**
  String get hide_vehicle_from_listings;

  /// No description provided for @enable_vehicle.
  ///
  /// In en, this message translates to:
  /// **'Enable Vehicle'**
  String get enable_vehicle;

  /// No description provided for @make_vehicle_visible.
  ///
  /// In en, this message translates to:
  /// **'Make this vehicle visible in listings'**
  String get make_vehicle_visible;

  /// No description provided for @loading_vehicle_details.
  ///
  /// In en, this message translates to:
  /// **'Loading vehicle details...'**
  String get loading_vehicle_details;

  /// No description provided for @error_loading_vehicle_details.
  ///
  /// In en, this message translates to:
  /// **'Error loading vehicle details'**
  String get error_loading_vehicle_details;

  /// No description provided for @pricing_location.
  ///
  /// In en, this message translates to:
  /// **'Pricing & Location'**
  String get pricing_location;

  /// No description provided for @currency.
  ///
  /// In en, this message translates to:
  /// **'{currency}'**
  String currency(Object currency);

  /// No description provided for @vehicle_images_count.
  ///
  /// In en, this message translates to:
  /// **'Vehicle Images ({count})'**
  String vehicle_images_count(Object count);

  /// No description provided for @failed_to_load.
  ///
  /// In en, this message translates to:
  /// **'Failed to load'**
  String get failed_to_load;

  /// No description provided for @vehicle_videos_count.
  ///
  /// In en, this message translates to:
  /// **'Vehicle Videos ({count})'**
  String vehicle_videos_count(Object count);

  /// No description provided for @media_type_index.
  ///
  /// In en, this message translates to:
  /// **'{mediaType} {index}'**
  String media_type_index(Object index, Object mediaType);

  /// No description provided for @vehicle_documents.
  ///
  /// In en, this message translates to:
  /// **'Vehicle Documents'**
  String get vehicle_documents;

  /// No description provided for @no_documents_uploaded.
  ///
  /// In en, this message translates to:
  /// **'No documents uploaded'**
  String get no_documents_uploaded;

  /// No description provided for @edit_vehicle.
  ///
  /// In en, this message translates to:
  /// **'Edit Vehicle'**
  String get edit_vehicle;

  /// No description provided for @press_back_again_to_exit.
  ///
  /// In en, this message translates to:
  /// **'Press back again to exit'**
  String get press_back_again_to_exit;

  /// No description provided for @notifications.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get notifications;

  /// No description provided for @notification_marked_read.
  ///
  /// In en, this message translates to:
  /// **'Notification marked as read'**
  String get notification_marked_read;

  /// No description provided for @sharing_notification.
  ///
  /// In en, this message translates to:
  /// **'Sharing notification...'**
  String get sharing_notification;

  /// No description provided for @no_notifications.
  ///
  /// In en, this message translates to:
  /// **'No Notifications'**
  String get no_notifications;

  /// No description provided for @no_notifications_message.
  ///
  /// In en, this message translates to:
  /// **'You don\'t have any notifications yet.'**
  String get no_notifications_message;

  /// No description provided for @failed_to_load_notifications.
  ///
  /// In en, this message translates to:
  /// **'Failed to load notifications. Please check your connection and try again.'**
  String get failed_to_load_notifications;

  /// No description provided for @details.
  ///
  /// In en, this message translates to:
  /// **'Details'**
  String get details;

  /// No description provided for @colon.
  ///
  /// In en, this message translates to:
  /// **':'**
  String get colon;

  /// No description provided for @search_error.
  ///
  /// In en, this message translates to:
  /// **'Search error: {error}'**
  String search_error(Object error);

  /// No description provided for @error_getting_location.
  ///
  /// In en, this message translates to:
  /// **'Error getting location details: {error}'**
  String error_getting_location(Object error);

  /// No description provided for @select_location_first.
  ///
  /// In en, this message translates to:
  /// **'Please select a location first'**
  String get select_location_first;

  /// No description provided for @no_locations_found.
  ///
  /// In en, this message translates to:
  /// **'No locations found matching {query}'**
  String no_locations_found(Object query);

  /// No description provided for @help_support.
  ///
  /// In en, this message translates to:
  /// **'Help & Support'**
  String get help_support;

  /// No description provided for @loading_faq.
  ///
  /// In en, this message translates to:
  /// **'Loading FAQ...'**
  String get loading_faq;

  /// No description provided for @no_faq_available.
  ///
  /// In en, this message translates to:
  /// **'No FAQ Available'**
  String get no_faq_available;

  /// No description provided for @faq_content_coming.
  ///
  /// In en, this message translates to:
  /// **'FAQ content will appear here once available'**
  String get faq_content_coming;

  /// No description provided for @find_answers.
  ///
  /// In en, this message translates to:
  /// **'Find answers to common questions'**
  String get find_answers;

  /// No description provided for @questions_count.
  ///
  /// In en, this message translates to:
  /// **'{count} Questions'**
  String questions_count(Object count);

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @language_settings.
  ///
  /// In en, this message translates to:
  /// **'change language'**
  String get language_settings;

  /// No description provided for @delete_account.
  ///
  /// In en, this message translates to:
  /// **'Delete Account'**
  String get delete_account;

  /// No description provided for @delete_account_warning.
  ///
  /// In en, this message translates to:
  /// **'This action cannot be undone. All your data will be permanently deleted.'**
  String get delete_account_warning;

  /// No description provided for @my_profile.
  ///
  /// In en, this message translates to:
  /// **'My Profile'**
  String get my_profile;

  /// No description provided for @load_profile.
  ///
  /// In en, this message translates to:
  /// **'Load Profile'**
  String get load_profile;

  /// No description provided for @profile_name.
  ///
  /// In en, this message translates to:
  /// **'Name: {name}'**
  String profile_name(Object name);

  /// No description provided for @profile_phone.
  ///
  /// In en, this message translates to:
  /// **'Phone: {phone}'**
  String profile_phone(Object phone);

  /// No description provided for @profile_user_type.
  ///
  /// In en, this message translates to:
  /// **'User Type: {userType}'**
  String profile_user_type(Object userType);

  /// No description provided for @email_copied.
  ///
  /// In en, this message translates to:
  /// **'Email copied to clipboard: {email}'**
  String email_copied(Object email);

  /// No description provided for @unable_to_open_email.
  ///
  /// In en, this message translates to:
  /// **'Unable to open email client. Email: {email}'**
  String unable_to_open_email(Object email);

  /// No description provided for @phone_copied.
  ///
  /// In en, this message translates to:
  /// **'Phone number copied: {phone}'**
  String phone_copied(Object phone);

  /// No description provided for @unable_to_process_phone.
  ///
  /// In en, this message translates to:
  /// **'Unable to process phone number: {phone}'**
  String unable_to_process_phone(Object phone);

  /// No description provided for @address_copied.
  ///
  /// In en, this message translates to:
  /// **'Address copied to clipboard'**
  String get address_copied;

  /// No description provided for @unable_to_open_maps.
  ///
  /// In en, this message translates to:
  /// **'Unable to open maps or copy address'**
  String get unable_to_open_maps;

  /// No description provided for @support_center.
  ///
  /// In en, this message translates to:
  /// **'Support Center'**
  String get support_center;

  /// No description provided for @loading_support_info.
  ///
  /// In en, this message translates to:
  /// **'Loading support information...'**
  String get loading_support_info;

  /// No description provided for @how_can_we_help.
  ///
  /// In en, this message translates to:
  /// **'How can we help you?'**
  String get how_can_we_help;

  /// No description provided for @choose_support_method.
  ///
  /// In en, this message translates to:
  /// **'Choose the best way to reach our support team'**
  String get choose_support_method;

  /// No description provided for @contact_by_email.
  ///
  /// In en, this message translates to:
  /// **'Contact by Email'**
  String get contact_by_email;

  /// No description provided for @other_ways_to_contact.
  ///
  /// In en, this message translates to:
  /// **'Other Ways to Reach Us'**
  String get other_ways_to_contact;

  /// No description provided for @accept_to_continue.
  ///
  /// In en, this message translates to:
  /// **'Please accept to continue'**
  String get accept_to_continue;

  /// No description provided for @loading_data.
  ///
  /// In en, this message translates to:
  /// **'Loading data...'**
  String get loading_data;

  /// No description provided for @failed_to_load_data.
  ///
  /// In en, this message translates to:
  /// **'Failed to load data'**
  String get failed_to_load_data;

  /// No description provided for @no_data_available.
  ///
  /// In en, this message translates to:
  /// **'No data available'**
  String get no_data_available;

  /// No description provided for @read_and_agree.
  ///
  /// In en, this message translates to:
  /// **'I have read and agree'**
  String get read_and_agree;

  /// No description provided for @accept.
  ///
  /// In en, this message translates to:
  /// **'Accept'**
  String get accept;

  /// No description provided for @terms_conditions.
  ///
  /// In en, this message translates to:
  /// **'Terms and Conditions'**
  String get terms_conditions;

  /// No description provided for @effective_date.
  ///
  /// In en, this message translates to:
  /// **'Effective Date: 15 Apr 2025'**
  String get effective_date;

  /// No description provided for @terms_welcome_message.
  ///
  /// In en, this message translates to:
  /// **'Welcome to RideNow Taxi App. By using our services, you agree to the terms and conditions outlined below. Please read them carefully before booking a ride.'**
  String get terms_welcome_message;

  /// No description provided for @need_help_contact.
  ///
  /// In en, this message translates to:
  /// **'Need Help?\nContact Support'**
  String get need_help_contact;

  /// No description provided for @customer_care_24x7.
  ///
  /// In en, this message translates to:
  /// **'24x7 Customer Care'**
  String get customer_care_24x7;

  /// No description provided for @phone_icon.
  ///
  /// In en, this message translates to:
  /// **'📞'**
  String get phone_icon;

  /// No description provided for @support_phone.
  ///
  /// In en, this message translates to:
  /// **'+91-9999999999'**
  String get support_phone;

  /// No description provided for @email_icon.
  ///
  /// In en, this message translates to:
  /// **'📧'**
  String get email_icon;

  /// No description provided for @support_email.
  ///
  /// In en, this message translates to:
  /// **'support@ridenow.com'**
  String get support_email;

  /// No description provided for @profile_photo_required.
  ///
  /// In en, this message translates to:
  /// **'Profile photo is required'**
  String get profile_photo_required;

  /// No description provided for @wait_for_doc_verification.
  ///
  /// In en, this message translates to:
  /// **'Please wait for all documents to be verified before proceeding'**
  String get wait_for_doc_verification;

  /// No description provided for @all_docs_required.
  ///
  /// In en, this message translates to:
  /// **'All required documents are needed'**
  String get all_docs_required;

  /// No description provided for @fuel_type.
  ///
  /// In en, this message translates to:
  /// **'fuelType'**
  String get fuel_type;

  /// No description provided for @vehicle_ownership.
  ///
  /// In en, this message translates to:
  /// **'vehicleOwnership'**
  String get vehicle_ownership;

  /// No description provided for @rc_front_required.
  ///
  /// In en, this message translates to:
  /// **'RC Book front photo is required'**
  String get rc_front_required;

  /// No description provided for @rc_back_required.
  ///
  /// In en, this message translates to:
  /// **'RC Book back photo is required'**
  String get rc_back_required;

  /// No description provided for @at_least_one_vehicle_photo.
  ///
  /// In en, this message translates to:
  /// **'At least one vehicle photo is required'**
  String get at_least_one_vehicle_photo;

  /// No description provided for @service_city.
  ///
  /// In en, this message translates to:
  /// **'serviceCity'**
  String get service_city;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'language'**
  String get language;

  /// No description provided for @no_document_uploaded.
  ///
  /// In en, this message translates to:
  /// **'No document uploaded yet'**
  String get no_document_uploaded;

  /// No description provided for @verify_docs_before_submission.
  ///
  /// In en, this message translates to:
  /// **'Please verify all documents before submission'**
  String get verify_docs_before_submission;

  /// No description provided for @become_auto_rickshaw_driver.
  ///
  /// In en, this message translates to:
  /// **'Become an Auto Rickshaw Driver'**
  String get become_auto_rickshaw_driver;

  /// No description provided for @india_code.
  ///
  /// In en, this message translates to:
  /// **'+91'**
  String get india_code;

  /// No description provided for @doc_verification.
  ///
  /// In en, this message translates to:
  /// **'Document Verification'**
  String get doc_verification;

  /// No description provided for @allow_fare_negotiation.
  ///
  /// In en, this message translates to:
  /// **'Allow Fare Negotiation'**
  String get allow_fare_negotiation;

  /// No description provided for @service_cities.
  ///
  /// In en, this message translates to:
  /// **'Service Cities'**
  String get service_cities;

  /// No description provided for @personal_information.
  ///
  /// In en, this message translates to:
  /// **'Personal Information'**
  String get personal_information;

  /// No description provided for @doc_verification_status.
  ///
  /// In en, this message translates to:
  /// **'Documents Verification Status'**
  String get doc_verification_status;

  /// No description provided for @uploaded_files.
  ///
  /// In en, this message translates to:
  /// **'Uploaded Files :'**
  String get uploaded_files;

  /// No description provided for @fare_details.
  ///
  /// In en, this message translates to:
  /// **'Fare Details'**
  String get fare_details;

  /// No description provided for @languages_spoken.
  ///
  /// In en, this message translates to:
  /// **'Languages Spoken'**
  String get languages_spoken;

  /// No description provided for @address.
  ///
  /// In en, this message translates to:
  /// **'Address'**
  String get address;

  /// No description provided for @submission_confirmation.
  ///
  /// In en, this message translates to:
  /// **'By submitting this application, you confirm that all the information provided is accurate and true.'**
  String get submission_confirmation;

  /// No description provided for @label_colon.
  ///
  /// In en, this message translates to:
  /// **'{label}:'**
  String label_colon(Object label);

  /// No description provided for @gender.
  ///
  /// In en, this message translates to:
  /// **'gender'**
  String get gender;

  /// No description provided for @vehicle_type.
  ///
  /// In en, this message translates to:
  /// **'Vehicle Type'**
  String get vehicle_type;

  /// No description provided for @services_cities.
  ///
  /// In en, this message translates to:
  /// **'servicesCities'**
  String get services_cities;

  /// No description provided for @language_spoken.
  ///
  /// In en, this message translates to:
  /// **'languageSpoken'**
  String get language_spoken;

  /// No description provided for @become_driver.
  ///
  /// In en, this message translates to:
  /// **'Become a Driver'**
  String get become_driver;

  /// No description provided for @experience_charges.
  ///
  /// In en, this message translates to:
  /// **'Experience & Charges'**
  String get experience_charges;

  /// No description provided for @vehicle_cities.
  ///
  /// In en, this message translates to:
  /// **'Vehicle & Cities'**
  String get vehicle_cities;

  /// No description provided for @successfully_verified.
  ///
  /// In en, this message translates to:
  /// **'Successfully Verified'**
  String get successfully_verified;

  /// No description provided for @verify_images.
  ///
  /// In en, this message translates to:
  /// **'Verify Images'**
  String get verify_images;

  /// No description provided for @enter_aadhaar_number.
  ///
  /// In en, this message translates to:
  /// **'Enter Your Aadhaar Number'**
  String get enter_aadhaar_number;

  /// No description provided for @name_as_on_aadhaar.
  ///
  /// In en, this message translates to:
  /// **'Name as on Aadhaar'**
  String get name_as_on_aadhaar;

  /// No description provided for @verify.
  ///
  /// In en, this message translates to:
  /// **'Verify'**
  String get verify;

  /// No description provided for @enter_dl_number.
  ///
  /// In en, this message translates to:
  /// **'Enter Your Driving License Number'**
  String get enter_dl_number;

  /// No description provided for @name_as_on_license.
  ///
  /// In en, this message translates to:
  /// **'Name as on License'**
  String get name_as_on_license;

  /// No description provided for @date_of_birth.
  ///
  /// In en, this message translates to:
  /// **'Date of Birth'**
  String get date_of_birth;

  /// No description provided for @view.
  ///
  /// In en, this message translates to:
  /// **'View'**
  String get view;

  /// No description provided for @image_preview.
  ///
  /// In en, this message translates to:
  /// **'Image Preview'**
  String get image_preview;

  /// No description provided for @image_count.
  ///
  /// In en, this message translates to:
  /// **'{currentIndex} of {totalImages}'**
  String image_count(Object currentIndex, Object totalImages);

  /// No description provided for @please_check_internet.
  ///
  /// In en, this message translates to:
  /// **'Please check your internet connection'**
  String get please_check_internet;

  /// No description provided for @application_submitted.
  ///
  /// In en, this message translates to:
  /// **'Application submitted successfully!'**
  String get application_submitted;

  /// No description provided for @error_occurred.
  ///
  /// In en, this message translates to:
  /// **'An error occurred: {error}'**
  String error_occurred(Object error);

  /// No description provided for @e_rickshaw_registration.
  ///
  /// In en, this message translates to:
  /// **'E-RICKSHAW Registration'**
  String get e_rickshaw_registration;

  /// No description provided for @submission_confirmation_complete.
  ///
  /// In en, this message translates to:
  /// **'By submitting this application, you confirm that all the information provided is accurate and complete.'**
  String get submission_confirmation_complete;

  /// No description provided for @become_transporter.
  ///
  /// In en, this message translates to:
  /// **'Become a Transporter'**
  String get become_transporter;

  /// No description provided for @fleet_size.
  ///
  /// In en, this message translates to:
  /// **'Fleet Size'**
  String get fleet_size;

  /// No description provided for @enable_price_negotiation.
  ///
  /// In en, this message translates to:
  /// **'Enable price negotiation via chat/calls'**
  String get enable_price_negotiation;

  /// No description provided for @business_info.
  ///
  /// In en, this message translates to:
  /// **'Business Information'**
  String get business_info;

  /// No description provided for @contact_preferences.
  ///
  /// In en, this message translates to:
  /// **'Contact Preferences'**
  String get contact_preferences;

  /// No description provided for @documents.
  ///
  /// In en, this message translates to:
  /// **'Documents'**
  String get documents;

  /// No description provided for @submission_confirmation_valid.
  ///
  /// In en, this message translates to:
  /// **'By submitting this application, you confirm that all the information provided is accurate and documents are valid.'**
  String get submission_confirmation_valid;

  /// No description provided for @air_conditioning.
  ///
  /// In en, this message translates to:
  /// **'airConditioning'**
  String get air_conditioning;

  /// No description provided for @served_location.
  ///
  /// In en, this message translates to:
  /// **'servedLocation'**
  String get served_location;

  /// No description provided for @priceIs_negotiable.
  ///
  /// In en, this message translates to:
  /// **'Price is negotiable'**
  String get priceIs_negotiable;

  /// No description provided for @vehicle_videos_optional.
  ///
  /// In en, this message translates to:
  /// **'Vehicle Videos (Optional)'**
  String get vehicle_videos_optional;

  /// No description provided for @vehicle_registration_docs.
  ///
  /// In en, this message translates to:
  /// **'Vehicle Registration Documents'**
  String get vehicle_registration_docs;

  /// No description provided for @rc_front_photo.
  ///
  /// In en, this message translates to:
  /// **'RC Book Front Photo'**
  String get rc_front_photo;

  /// No description provided for @rc_back_photo.
  ///
  /// In en, this message translates to:
  /// **'RC Book Back Photo'**
  String get rc_back_photo;

  /// No description provided for @review_vehicle_info.
  ///
  /// In en, this message translates to:
  /// **'Review Your Vehicle Information'**
  String get review_vehicle_info;

  /// No description provided for @videos_uploaded_count.
  ///
  /// In en, this message translates to:
  /// **'{count} video(s) uploaded'**
  String videos_uploaded_count(Object count);

  /// No description provided for @reg_documents.
  ///
  /// In en, this message translates to:
  /// **'Registration Documents'**
  String get reg_documents;

  /// No description provided for @rc_front.
  ///
  /// In en, this message translates to:
  /// **'RC Book Front'**
  String get rc_front;

  /// No description provided for @rc_back.
  ///
  /// In en, this message translates to:
  /// **'RC Book Back'**
  String get rc_back;

  /// No description provided for @review_before_submitting.
  ///
  /// In en, this message translates to:
  /// **'Please review all the information carefully before submitting.'**
  String get review_before_submitting;

  /// No description provided for @failed_to_delete_chat.
  ///
  /// In en, this message translates to:
  /// **'Failed to delete chat: {error}'**
  String failed_to_delete_chat(Object error);

  /// No description provided for @delete_chat.
  ///
  /// In en, this message translates to:
  /// **'Delete Chat'**
  String get delete_chat;

  /// No description provided for @confirm_delete_chat.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete this chat with {name}?'**
  String confirm_delete_chat(Object name);

  /// No description provided for @message.
  ///
  /// In en, this message translates to:
  /// **'Message'**
  String get message;

  /// No description provided for @loading_chats.
  ///
  /// In en, this message translates to:
  /// **'Loading chats...'**
  String get loading_chats;

  /// No description provided for @no_chats_yet.
  ///
  /// In en, this message translates to:
  /// **'No chats yet'**
  String get no_chats_yet;

  /// No description provided for @start_conversation_message.
  ///
  /// In en, this message translates to:
  /// **'Start a conversation to see it here'**
  String get start_conversation_message;

  /// No description provided for @deleting.
  ///
  /// In en, this message translates to:
  /// **'Deleting...'**
  String get deleting;

  /// No description provided for @typing.
  ///
  /// In en, this message translates to:
  /// **'Typing...'**
  String get typing;

  /// No description provided for @type_message.
  ///
  /// In en, this message translates to:
  /// **'Type a message...'**
  String get type_message;

  /// No description provided for @upload_media.
  ///
  /// In en, this message translates to:
  /// **'Upload Media'**
  String get upload_media;

  /// No description provided for @document.
  ///
  /// In en, this message translates to:
  /// **'Document'**
  String get document;

  /// No description provided for @download.
  ///
  /// In en, this message translates to:
  /// **'Download'**
  String get download;

  /// No description provided for @unsupported_media.
  ///
  /// In en, this message translates to:
  /// **'Unsupported media type'**
  String get unsupported_media;

  /// No description provided for @loading_video.
  ///
  /// In en, this message translates to:
  /// **'Loading video...'**
  String get loading_video;

  /// No description provided for @cannot_open_document.
  ///
  /// In en, this message translates to:
  /// **'Cannot open document'**
  String get cannot_open_document;

  /// No description provided for @failed_to_download_doc.
  ///
  /// In en, this message translates to:
  /// **'Failed to download document'**
  String get failed_to_download_doc;

  /// No description provided for @filter_options.
  ///
  /// In en, this message translates to:
  /// **'Filter Options'**
  String get filter_options;

  /// No description provided for @reset.
  ///
  /// In en, this message translates to:
  /// **'Reset'**
  String get reset;

  /// No description provided for @apply.
  ///
  /// In en, this message translates to:
  /// **'Apply'**
  String get apply;

  /// No description provided for @unsaved_changes.
  ///
  /// In en, this message translates to:
  /// **'Unsaved Changes'**
  String get unsaved_changes;

  /// No description provided for @confirm_leave_without_saving.
  ///
  /// In en, this message translates to:
  /// **'You have unsaved changes. Are you sure you want to leave?'**
  String get confirm_leave_without_saving;

  /// No description provided for @leave.
  ///
  /// In en, this message translates to:
  /// **'Leave'**
  String get leave;

  /// No description provided for @edit_profile.
  ///
  /// In en, this message translates to:
  /// **'Edit Profile'**
  String get edit_profile;

  /// No description provided for @loading_profile.
  ///
  /// In en, this message translates to:
  /// **'Loading your profile...'**
  String get loading_profile;

  /// No description provided for @view_edit_profile.
  ///
  /// In en, this message translates to:
  /// **'View and edit profile'**
  String get view_edit_profile;

  /// No description provided for @plans.
  ///
  /// In en, this message translates to:
  /// **'Plans'**
  String get plans;

  /// No description provided for @my_ratings.
  ///
  /// In en, this message translates to:
  /// **'My Ratings'**
  String get my_ratings;

  /// No description provided for @faq.
  ///
  /// In en, this message translates to:
  /// **'Faq'**
  String get faq;

  /// No description provided for @support.
  ///
  /// In en, this message translates to:
  /// **'Support'**
  String get support;

  /// No description provided for @rate_our_app.
  ///
  /// In en, this message translates to:
  /// **'Rate our app'**
  String get rate_our_app;

  /// No description provided for @about_us.
  ///
  /// In en, this message translates to:
  /// **'About Us'**
  String get about_us;

  /// No description provided for @privacy_policy.
  ///
  /// In en, this message translates to:
  /// **'Privacy Policy'**
  String get privacy_policy;

  /// No description provided for @choose_perfect_driver.
  ///
  /// In en, this message translates to:
  /// **'Choose Your Perfect Driver'**
  String get choose_perfect_driver;

  /// No description provided for @no_driver_found.
  ///
  /// In en, this message translates to:
  /// **'No Driver found'**
  String get no_driver_found;

  /// No description provided for @try_different_criteria.
  ///
  /// In en, this message translates to:
  /// **'Try searching with different criteria'**
  String get try_different_criteria;

  /// No description provided for @years_experience.
  ///
  /// In en, this message translates to:
  /// **'{experience} years'**
  String years_experience(Object experience);

  /// No description provided for @failed_to_log_activity.
  ///
  /// In en, this message translates to:
  /// **'Failed to log activity'**
  String get failed_to_log_activity;

  /// No description provided for @view_more.
  ///
  /// In en, this message translates to:
  /// **'View More'**
  String get view_more;

  /// No description provided for @driver_profile.
  ///
  /// In en, this message translates to:
  /// **'Driver Profile'**
  String get driver_profile;

  /// No description provided for @no_driver_details.
  ///
  /// In en, this message translates to:
  /// **'No driver details found'**
  String get no_driver_details;

  /// No description provided for @years_experience_display.
  ///
  /// In en, this message translates to:
  /// **'{experience} Years Experience'**
  String years_experience_display(Object experience);

  /// No description provided for @more_info.
  ///
  /// In en, this message translates to:
  /// **'More Information'**
  String get more_info;

  /// No description provided for @colon_value.
  ///
  /// In en, this message translates to:
  /// **': {value}'**
  String colon_value(Object value);

  /// No description provided for @driver_bio.
  ///
  /// In en, this message translates to:
  /// **'Driver Bio'**
  String get driver_bio;

  /// No description provided for @minimum_charges.
  ///
  /// In en, this message translates to:
  /// **'Minimum Charges'**
  String get minimum_charges;

  /// No description provided for @rupees_amount.
  ///
  /// In en, this message translates to:
  /// **'₹ {amount}'**
  String rupees_amount(Object amount);

  /// No description provided for @review_submitted.
  ///
  /// In en, this message translates to:
  /// **'Review submitted successfully!'**
  String get review_submitted;

  /// No description provided for @ratings_reviews.
  ///
  /// In en, this message translates to:
  /// **'Ratings & Reviews'**
  String get ratings_reviews;

  /// No description provided for @rating_colon.
  ///
  /// In en, this message translates to:
  /// **'Rating:'**
  String get rating_colon;

  /// No description provided for @congratulations.
  ///
  /// In en, this message translates to:
  /// **'Congratulations!'**
  String get congratulations;

  /// No description provided for @successfully_registered.
  ///
  /// In en, this message translates to:
  /// **'You have successfully registered.'**
  String get successfully_registered;

  /// No description provided for @payment_successful_title.
  ///
  /// In en, this message translates to:
  /// **'Payment Successful!'**
  String get payment_successful_title;

  /// No description provided for @transaction_completed.
  ///
  /// In en, this message translates to:
  /// **'Your transaction has been completed'**
  String get transaction_completed;

  /// No description provided for @date_colon.
  ///
  /// In en, this message translates to:
  /// **'Date'**
  String get date_colon;

  /// No description provided for @time_colon.
  ///
  /// In en, this message translates to:
  /// **'Time'**
  String get time_colon;

  /// No description provided for @transaction_id.
  ///
  /// In en, this message translates to:
  /// **'Transaction ID'**
  String get transaction_id;

  /// No description provided for @amount_colon.
  ///
  /// In en, this message translates to:
  /// **'Amount'**
  String get amount_colon;

  /// No description provided for @payment_method_colon.
  ///
  /// In en, this message translates to:
  /// **'Payment Method'**
  String get payment_method_colon;

  /// No description provided for @share_receipt.
  ///
  /// In en, this message translates to:
  /// **'Share Receipt'**
  String get share_receipt;

  /// No description provided for @done.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get done;

  /// No description provided for @loading_transporter_details.
  ///
  /// In en, this message translates to:
  /// **'Loading transporter details...'**
  String get loading_transporter_details;

  /// No description provided for @total_fleet_size_display.
  ///
  /// In en, this message translates to:
  /// **'Total Fleet Size: {count}'**
  String total_fleet_size_display(Object count);

  /// No description provided for @available_vehicles.
  ///
  /// In en, this message translates to:
  /// **'Available Vehicles'**
  String get available_vehicles;

  /// No description provided for @vehicles_count.
  ///
  /// In en, this message translates to:
  /// **'{count} Vehicle{plural}'**
  String vehicles_count(Object count, Object plural);

  /// No description provided for @current_of_total.
  ///
  /// In en, this message translates to:
  /// **'{current}/{total}'**
  String current_of_total(Object current, Object total);

  /// No description provided for @no_vehicles_available.
  ///
  /// In en, this message translates to:
  /// **'No vehicles available'**
  String get no_vehicles_available;

  /// No description provided for @price_per_hour.
  ///
  /// In en, this message translates to:
  /// **'{currency}{price}/hr'**
  String price_per_hour(Object currency, Object price);

  /// No description provided for @negotiable.
  ///
  /// In en, this message translates to:
  /// **'Negotiable'**
  String get negotiable;

  /// No description provided for @image_not_available.
  ///
  /// In en, this message translates to:
  /// **'Image not available'**
  String get image_not_available;

  /// No description provided for @current_image_of_total.
  ///
  /// In en, this message translates to:
  /// **'{currentImage}/{totalImages}'**
  String current_image_of_total(Object currentImage, Object totalImages);

  /// No description provided for @video_unavailable.
  ///
  /// In en, this message translates to:
  /// **'Video unavailable'**
  String get video_unavailable;

  /// No description provided for @find_vehicles_drivers.
  ///
  /// In en, this message translates to:
  /// **'Find the perfect vehicles and drivers'**
  String get find_vehicles_drivers;

  /// No description provided for @use_current_location.
  ///
  /// In en, this message translates to:
  /// **'Use Current Location'**
  String get use_current_location;

  /// No description provided for @you.
  ///
  /// In en, this message translates to:
  /// **'You'**
  String get you;

  /// No description provided for @suggestions.
  ///
  /// In en, this message translates to:
  /// **'Suggestions'**
  String get suggestions;

  /// No description provided for @choose_vehicle_type.
  ///
  /// In en, this message translates to:
  /// **'Choose Your Vehicle Type'**
  String get choose_vehicle_type;

  /// No description provided for @select_vehicle_option.
  ///
  /// In en, this message translates to:
  /// **'Select the option that best describes your vehicle'**
  String get select_vehicle_option;

  /// No description provided for @become_driver_transporter.
  ///
  /// In en, this message translates to:
  /// **'Become Driver/Transporter'**
  String get become_driver_transporter;

  /// No description provided for @price_example.
  ///
  /// In en, this message translates to:
  /// **'₹170.71'**
  String get price_example;

  /// No description provided for @subscribe_now.
  ///
  /// In en, this message translates to:
  /// **'Subscribe Now'**
  String get subscribe_now;

  /// No description provided for @failed_to_load_more_vehicles.
  ///
  /// In en, this message translates to:
  /// **'Failed to load more vehicles: {error}'**
  String failed_to_load_more_vehicles(Object error);

  /// No description provided for @failed_to_refresh.
  ///
  /// In en, this message translates to:
  /// **'Failed to refresh: {error}'**
  String failed_to_refresh(Object error);

  /// No description provided for @could_not_launch_phone.
  ///
  /// In en, this message translates to:
  /// **'Could not launch phone app'**
  String get could_not_launch_phone;

  /// No description provided for @seats_count.
  ///
  /// In en, this message translates to:
  /// **'{seats}'**
  String seats_count(Object seats);

  /// No description provided for @min_charge.
  ///
  /// In en, this message translates to:
  /// **'min charge'**
  String get min_charge;

  /// No description provided for @no_vehicles_found.
  ///
  /// In en, this message translates to:
  /// **'Oops! We couldn\'t find any vehicles.'**
  String get no_vehicles_found;

  /// No description provided for @try_changing_location.
  ///
  /// In en, this message translates to:
  /// **'🔍 Try changing the location or exploring other categories.'**
  String get try_changing_location;

  /// No description provided for @no_more_vehicles.
  ///
  /// In en, this message translates to:
  /// **'No more vehicles'**
  String get no_more_vehicles;

  /// No description provided for @view_more_vehicles.
  ///
  /// In en, this message translates to:
  /// **'View More Vehicles'**
  String get view_more_vehicles;

  /// No description provided for @vehicle_details_title.
  ///
  /// In en, this message translates to:
  /// **'{vehicleName} Details'**
  String vehicle_details_title(Object vehicleName);

  /// No description provided for @short_id.
  ///
  /// In en, this message translates to:
  /// **'ID: {shortId}'**
  String short_id(Object shortId);

  /// No description provided for @about_colon.
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get about_colon;

  /// No description provided for @min_charge_colon.
  ///
  /// In en, this message translates to:
  /// **'Min Charge'**
  String get min_charge_colon;

  /// No description provided for @swipe_navigate_instructions.
  ///
  /// In en, this message translates to:
  /// **'Swipe to navigate • Pinch to zoom'**
  String get swipe_navigate_instructions;

  /// No description provided for @continue_co.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get continue_co;

  /// No description provided for @phone_number_10_digits.
  ///
  /// In en, this message translates to:
  /// **'Phone number must be 10 digits'**
  String get phone_number_10_digits;

  /// No description provided for @only_digits_allowed.
  ///
  /// In en, this message translates to:
  /// **'Only digits are allowed'**
  String get only_digits_allowed;

  /// No description provided for @enter_code_whatsapp.
  ///
  /// In en, this message translates to:
  /// **'Enter the code that was sent to your WhatsApp number'**
  String get enter_code_whatsapp;

  /// No description provided for @enter_valid_email.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid email address'**
  String get enter_valid_email;

  /// No description provided for @by_continuing_agree_to.
  ///
  /// In en, this message translates to:
  /// **'By continuing you agree to the'**
  String get by_continuing_agree_to;

  /// No description provided for @and.
  ///
  /// In en, this message translates to:
  /// **'and'**
  String get and;

  /// No description provided for @explore.
  ///
  /// In en, this message translates to:
  /// **'Explore'**
  String get explore;

  /// No description provided for @dashboard.
  ///
  /// In en, this message translates to:
  /// **'Dashboard'**
  String get dashboard;

  /// No description provided for @category.
  ///
  /// In en, this message translates to:
  /// **'Category'**
  String get category;

  /// No description provided for @home.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get home;

  /// No description provided for @car.
  ///
  /// In en, this message translates to:
  /// **'Car'**
  String get car;

  /// No description provided for @auto.
  ///
  /// In en, this message translates to:
  /// **'Auto'**
  String get auto;

  /// Title for electric rickshaw option
  ///
  /// In en, this message translates to:
  /// **'E-Rickshaw'**
  String get eRickshaw;

  /// No description provided for @suv.
  ///
  /// In en, this message translates to:
  /// **'SUV'**
  String get suv;

  /// No description provided for @minivan.
  ///
  /// In en, this message translates to:
  /// **'Minivan'**
  String get minivan;

  /// No description provided for @bus.
  ///
  /// In en, this message translates to:
  /// **'Bus'**
  String get bus;

  /// No description provided for @driver.
  ///
  /// In en, this message translates to:
  /// **'Driver'**
  String get driver;

  /// No description provided for @fieldRequired.
  ///
  /// In en, this message translates to:
  /// **'{fieldName} is required'**
  String fieldRequired(Object fieldName);

  /// No description provided for @profilePhoto.
  ///
  /// In en, this message translates to:
  /// **'Profile photo'**
  String get profilePhoto;

  /// No description provided for @firstName.
  ///
  /// In en, this message translates to:
  /// **'First name'**
  String get firstName;

  /// No description provided for @emailAddress.
  ///
  /// In en, this message translates to:
  /// **'Email address'**
  String get emailAddress;

  /// No description provided for @phoneNumber.
  ///
  /// In en, this message translates to:
  /// **'Phone number'**
  String get phoneNumber;

  /// No description provided for @allVehicles.
  ///
  /// In en, this message translates to:
  /// **'All Vehicles'**
  String get allVehicles;

  /// No description provided for @youAreCurrentlyHere.
  ///
  /// In en, this message translates to:
  /// **'You are currently here'**
  String get youAreCurrentlyHere;

  /// No description provided for @howItWorks.
  ///
  /// In en, this message translates to:
  /// **'How It Works'**
  String get howItWorks;

  /// No description provided for @stepSearch.
  ///
  /// In en, this message translates to:
  /// **'Search nearby or global ride'**
  String get stepSearch;

  /// No description provided for @stepContact.
  ///
  /// In en, this message translates to:
  /// **'Contact & confirm details'**
  String get stepContact;

  /// No description provided for @stepEnjoy.
  ///
  /// In en, this message translates to:
  /// **'Enjoy a smooth ride!'**
  String get stepEnjoy;

  /// No description provided for @directContact.
  ///
  /// In en, this message translates to:
  /// **'Direct Contact.'**
  String get directContact;

  /// No description provided for @noCommission.
  ///
  /// In en, this message translates to:
  /// **'No Commission.'**
  String get noCommission;

  /// No description provided for @poweredByBuntyBhai.
  ///
  /// In en, this message translates to:
  /// **'Powered by Bunty Bhai'**
  String get poweredByBuntyBhai;

  /// No description provided for @tapToChangeLocation.
  ///
  /// In en, this message translates to:
  /// **'Tap to change location'**
  String get tapToChangeLocation;

  /// No description provided for @seats.
  ///
  /// In en, this message translates to:
  /// **'Seats'**
  String get seats;

  /// No description provided for @searchLocation.
  ///
  /// In en, this message translates to:
  /// **'Search location'**
  String get searchLocation;

  /// Title for independent driver option
  ///
  /// In en, this message translates to:
  /// **'Stand Alone Driver'**
  String get standAloneDriver;

  /// Title for auto rickshaw option
  ///
  /// In en, this message translates to:
  /// **'Auto Rickshaw'**
  String get autoRickshaw;

  /// No description provided for @eRickshawt.
  ///
  /// In en, this message translates to:
  /// **'E-Rickshaw'**
  String get eRickshawt;

  /// Title for transporter option
  ///
  /// In en, this message translates to:
  /// **'Transporter'**
  String get transporter;

  /// No description provided for @locationNotInIndia.
  ///
  /// In en, this message translates to:
  /// **'This location is not in India'**
  String get locationNotInIndia;

  /// No description provided for @addressNotAvailable.
  ///
  /// In en, this message translates to:
  /// **'Address not available'**
  String get addressNotAvailable;

  /// No description provided for @selectLocationFirst.
  ///
  /// In en, this message translates to:
  /// **'Please select a location first'**
  String get selectLocationFirst;

  /// No description provided for @fixedPrice.
  ///
  /// In en, this message translates to:
  /// **'Fixed Price'**
  String get fixedPrice;

  /// No description provided for @pleaseTryAgainLater.
  ///
  /// In en, this message translates to:
  /// **'Please try again later'**
  String get pleaseTryAgainLater;

  /// No description provided for @categoryNotFoundMessage.
  ///
  /// In en, this message translates to:
  /// **'Oops! We couldn\'t find this category at your selected location. We\'re expanding fast—stay tuned!'**
  String get categoryNotFoundMessage;

  /// No description provided for @idLabel.
  ///
  /// In en, this message translates to:
  /// **'ID'**
  String get idLabel;

  /// No description provided for @about.
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get about;

  /// No description provided for @vehicle_name.
  ///
  /// In en, this message translates to:
  /// **'Vehicle Name'**
  String get vehicle_name;

  /// No description provided for @type.
  ///
  /// In en, this message translates to:
  /// **'Type'**
  String get type;

  /// No description provided for @mileage.
  ///
  /// In en, this message translates to:
  /// **'Mileage'**
  String get mileage;

  /// No description provided for @mileage_value.
  ///
  /// In en, this message translates to:
  /// **'{value} km/l'**
  String mileage_value(Object value);

  /// No description provided for @not_specified.
  ///
  /// In en, this message translates to:
  /// **'Not specified'**
  String get not_specified;

  /// No description provided for @seating_capacity.
  ///
  /// In en, this message translates to:
  /// **'Seating Capacity'**
  String get seating_capacity;

  /// No description provided for @seating_capacity_value.
  ///
  /// In en, this message translates to:
  /// **'{value} persons'**
  String seating_capacity_value(Object value);

  /// No description provided for @pricingAndAvailability.
  ///
  /// In en, this message translates to:
  /// **'Pricing & Availability'**
  String get pricingAndAvailability;

  /// No description provided for @priceType.
  ///
  /// In en, this message translates to:
  /// **'Price Type'**
  String get priceType;

  /// No description provided for @rating.
  ///
  /// In en, this message translates to:
  /// **'Rating'**
  String get rating;

  /// No description provided for @writeYourReviewHere.
  ///
  /// In en, this message translates to:
  /// **'Write your review here...'**
  String get writeYourReviewHere;

  /// No description provided for @review.
  ///
  /// In en, this message translates to:
  /// **'Review'**
  String get review;

  /// No description provided for @submitting.
  ///
  /// In en, this message translates to:
  /// **'Submitting...'**
  String get submitting;

  /// No description provided for @submitReview.
  ///
  /// In en, this message translates to:
  /// **'Submit Review'**
  String get submitReview;

  /// No description provided for @reviewSubmittedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Review submitted successfully'**
  String get reviewSubmittedSuccessfully;

  /// No description provided for @reviewDeletedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Review deleted successfully'**
  String get reviewDeletedSuccessfully;

  /// No description provided for @specifications.
  ///
  /// In en, this message translates to:
  /// **'Specifications'**
  String get specifications;

  /// No description provided for @features.
  ///
  /// In en, this message translates to:
  /// **'Features'**
  String get features;

  /// No description provided for @vehicleVideos.
  ///
  /// In en, this message translates to:
  /// **'Vehicle Videos'**
  String get vehicleVideos;

  /// No description provided for @experience.
  ///
  /// In en, this message translates to:
  /// **'Experience'**
  String get experience;

  /// No description provided for @totalReviews.
  ///
  /// In en, this message translates to:
  /// **'Total Reviews'**
  String get totalReviews;

  /// No description provided for @averageRating.
  ///
  /// In en, this message translates to:
  /// **'Average Rating'**
  String get averageRating;

  /// No description provided for @ago.
  ///
  /// In en, this message translates to:
  /// **'ago'**
  String get ago;

  /// No description provided for @year.
  ///
  /// In en, this message translates to:
  /// **'year'**
  String get year;

  /// No description provided for @years.
  ///
  /// In en, this message translates to:
  /// **'years'**
  String get years;

  /// No description provided for @month.
  ///
  /// In en, this message translates to:
  /// **'month'**
  String get month;

  /// No description provided for @months.
  ///
  /// In en, this message translates to:
  /// **'months'**
  String get months;

  /// No description provided for @day.
  ///
  /// In en, this message translates to:
  /// **'day'**
  String get day;

  /// No description provided for @days.
  ///
  /// In en, this message translates to:
  /// **'days'**
  String get days;

  /// No description provided for @hour.
  ///
  /// In en, this message translates to:
  /// **'hour'**
  String get hour;

  /// No description provided for @hours.
  ///
  /// In en, this message translates to:
  /// **'hours'**
  String get hours;

  /// No description provided for @minute.
  ///
  /// In en, this message translates to:
  /// **'minute'**
  String get minute;

  /// No description provided for @minutes.
  ///
  /// In en, this message translates to:
  /// **'minutes'**
  String get minutes;

  /// No description provided for @justNow.
  ///
  /// In en, this message translates to:
  /// **'Just now'**
  String get justNow;

  /// No description provided for @today.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get today;

  /// No description provided for @yesterday.
  ///
  /// In en, this message translates to:
  /// **'Yesterday'**
  String get yesterday;

  /// No description provided for @contactPreferences.
  ///
  /// In en, this message translates to:
  /// **'Contact Preferences'**
  String get contactPreferences;

  /// No description provided for @whatsappNotifications.
  ///
  /// In en, this message translates to:
  /// **'WhatsApp Notifications'**
  String get whatsappNotifications;

  /// No description provided for @whatsappSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Receive notifications via WhatsApp'**
  String get whatsappSubtitle;

  /// No description provided for @phoneNotifications.
  ///
  /// In en, this message translates to:
  /// **'Phone Notifications'**
  String get phoneNotifications;

  /// No description provided for @phoneSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Receive notifications via phone calls/SMS'**
  String get phoneSubtitle;

  /// No description provided for @accountManagement.
  ///
  /// In en, this message translates to:
  /// **'Account Management'**
  String get accountManagement;

  /// No description provided for @deleteAccount.
  ///
  /// In en, this message translates to:
  /// **'Delete Account'**
  String get deleteAccount;

  /// No description provided for @deleteAccountSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Permanently delete your account'**
  String get deleteAccountSubtitle;

  /// No description provided for @otherSettings.
  ///
  /// In en, this message translates to:
  /// **'Other Settings'**
  String get otherSettings;

  /// No description provided for @changeLanguage.
  ///
  /// In en, this message translates to:
  /// **'Change language'**
  String get changeLanguage;

  /// No description provided for @comingSoon.
  ///
  /// In en, this message translates to:
  /// **'Coming Soon'**
  String get comingSoon;

  /// No description provided for @deleteAccountDialogTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete Account'**
  String get deleteAccountDialogTitle;

  /// No description provided for @deleteAccountDialogContent.
  ///
  /// In en, this message translates to:
  /// **'This action cannot be undone. All your data will be permanently deleted and you will lose access to your account.'**
  String get deleteAccountDialogContent;

  /// No description provided for @authenticationError.
  ///
  /// In en, this message translates to:
  /// **'Authentication error. Please login again.'**
  String get authenticationError;

  /// No description provided for @preferencesUpdated.
  ///
  /// In en, this message translates to:
  /// **'Preferences updated successfully'**
  String get preferencesUpdated;

  /// No description provided for @failedUpdatePreferences.
  ///
  /// In en, this message translates to:
  /// **'Failed to update preferences'**
  String get failedUpdatePreferences;

  /// No description provided for @networkError.
  ///
  /// In en, this message translates to:
  /// **'Network error. Please check your connection.'**
  String get networkError;

  /// No description provided for @accountDeleted.
  ///
  /// In en, this message translates to:
  /// **'Account deleted successfully'**
  String get accountDeleted;

  /// No description provided for @failedDeleteAccount.
  ///
  /// In en, this message translates to:
  /// **'Failed to delete account'**
  String get failedDeleteAccount;

  /// No description provided for @noCamerasAvailable.
  ///
  /// In en, this message translates to:
  /// **'No cameras available on this device'**
  String get noCamerasAvailable;

  /// No description provided for @cameraTitleBlink.
  ///
  /// In en, this message translates to:
  /// **'Camera with Blink Detection'**
  String get cameraTitleBlink;

  /// No description provided for @cameraTitle.
  ///
  /// In en, this message translates to:
  /// **'Camera'**
  String get cameraTitle;

  /// No description provided for @cameraSubtitleBlink.
  ///
  /// In en, this message translates to:
  /// **'Take photo with advanced detection'**
  String get cameraSubtitleBlink;

  /// No description provided for @cameraSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Take a new photo'**
  String get cameraSubtitle;

  /// No description provided for @uploadPromptButton.
  ///
  /// In en, this message translates to:
  /// **'Click here to upload'**
  String get uploadPromptButton;

  /// No description provided for @remove.
  ///
  /// In en, this message translates to:
  /// **'Remove'**
  String get remove;

  /// No description provided for @sixDigitPinIsRequired.
  ///
  /// In en, this message translates to:
  /// **'6 digit pin is required'**
  String get sixDigitPinIsRequired;

  /// No description provided for @pleaseSelectAtLeastOne.
  ///
  /// In en, this message translates to:
  /// **'Please select at least one {fieldName}'**
  String pleaseSelectAtLeastOne(Object fieldName);

  /// No description provided for @pleaseSelectFuelType.
  ///
  /// In en, this message translates to:
  /// **'Please select fuel type'**
  String get pleaseSelectFuelType;

  /// No description provided for @selectVehicleOwnership.
  ///
  /// In en, this message translates to:
  /// **'Select vehicle ownership'**
  String get selectVehicleOwnership;

  /// No description provided for @fareAndCities.
  ///
  /// In en, this message translates to:
  /// **'Fare & Cities'**
  String get fareAndCities;

  /// No description provided for @fullName.
  ///
  /// In en, this message translates to:
  /// **'Full name'**
  String get fullName;

  /// No description provided for @pleaseSelectState.
  ///
  /// In en, this message translates to:
  /// **'Please select a state'**
  String get pleaseSelectState;

  /// No description provided for @pleaseSelectCity.
  ///
  /// In en, this message translates to:
  /// **'Please select a city'**
  String get pleaseSelectCity;

  /// No description provided for @pincode.
  ///
  /// In en, this message translates to:
  /// **'Pincode'**
  String get pincode;

  /// No description provided for @allDocumentsVerifiedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'All documents have been verified successfully!'**
  String get allDocumentsVerifiedSuccessfully;

  /// No description provided for @pleaseEnsureAllDocumentsUploadedVerified.
  ///
  /// In en, this message translates to:
  /// **'Please ensure all documents are uploaded and verified.'**
  String get pleaseEnsureAllDocumentsUploadedVerified;

  /// No description provided for @aadhaarNumber.
  ///
  /// In en, this message translates to:
  /// **'Aadhaar number'**
  String get aadhaarNumber;

  /// No description provided for @drivingLicense.
  ///
  /// In en, this message translates to:
  /// **'Driving License'**
  String get drivingLicense;

  /// No description provided for @uploaded.
  ///
  /// In en, this message translates to:
  /// **'Uploaded'**
  String get uploaded;

  /// No description provided for @yes.
  ///
  /// In en, this message translates to:
  /// **'Yes'**
  String get yes;

  /// No description provided for @no.
  ///
  /// In en, this message translates to:
  /// **'No'**
  String get no;

  /// No description provided for @city.
  ///
  /// In en, this message translates to:
  /// **'City'**
  String get city;

  /// No description provided for @state.
  ///
  /// In en, this message translates to:
  /// **'State'**
  String get state;

  /// No description provided for @allDocumentsVerifiedReadyToSubmit.
  ///
  /// In en, this message translates to:
  /// **'All documents verified! Ready to submit.'**
  String get allDocumentsVerifiedReadyToSubmit;

  /// No description provided for @documentVerificationIncomplete.
  ///
  /// In en, this message translates to:
  /// **'Document verification incomplete. Please verify all documents before submission.'**
  String get documentVerificationIncomplete;

  /// No description provided for @submit.
  ///
  /// In en, this message translates to:
  /// **'Submit'**
  String get submit;

  /// No description provided for @next.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get next;

  /// No description provided for @vehicleNumber.
  ///
  /// In en, this message translates to:
  /// **'Vehicle number'**
  String get vehicleNumber;

  /// No description provided for @no_internet_connection.
  ///
  /// In en, this message translates to:
  /// **'No Internet Connection'**
  String get no_internet_connection;

  /// No description provided for @check_internet_connection.
  ///
  /// In en, this message translates to:
  /// **'Please check your internet connection and try again.'**
  String get check_internet_connection;

  /// No description provided for @server_unavailable_message.
  ///
  /// In en, this message translates to:
  /// **'The server is currently unavailable (502). Please try again later.'**
  String get server_unavailable_message;

  /// No description provided for @unable_to_connect_server.
  ///
  /// In en, this message translates to:
  /// **'Unable to connect to the server. Please check your connection.'**
  String get unable_to_connect_server;

  /// No description provided for @request_timeout.
  ///
  /// In en, this message translates to:
  /// **'Request Timeout'**
  String get request_timeout;

  /// No description provided for @request_timeout_message.
  ///
  /// In en, this message translates to:
  /// **'The request took too long to complete. Please try again.'**
  String get request_timeout_message;

  /// No description provided for @api_error.
  ///
  /// In en, this message translates to:
  /// **'API Error'**
  String get api_error;

  /// No description provided for @api_error_message.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong while fetching data. Please try again.'**
  String get api_error_message;

  /// No description provided for @unexpected_error_message.
  ///
  /// In en, this message translates to:
  /// **'An unexpected error occurred. Please try again.'**
  String get unexpected_error_message;

  /// No description provided for @try_again.
  ///
  /// In en, this message translates to:
  /// **'Try Again'**
  String get try_again;

  /// No description provided for @open_settings.
  ///
  /// In en, this message translates to:
  /// **'Open Settings'**
  String get open_settings;

  /// No description provided for @check_device_settings.
  ///
  /// In en, this message translates to:
  /// **'Please check your device settings'**
  String get check_device_settings;

  /// No description provided for @startDetectionMessage.
  ///
  /// In en, this message translates to:
  /// **'Press \'Start Detection\' to begin'**
  String get startDetectionMessage;

  /// No description provided for @stopCapturing.
  ///
  /// In en, this message translates to:
  /// **'Stop Capturing'**
  String get stopCapturing;

  /// No description provided for @startCapturing.
  ///
  /// In en, this message translates to:
  /// **'Start Capturing'**
  String get startCapturing;

  /// No description provided for @cameraReady.
  ///
  /// In en, this message translates to:
  /// **'Camera ready - Start detection'**
  String get cameraReady;

  /// No description provided for @cameraInitError.
  ///
  /// In en, this message translates to:
  /// **'Error: Camera initialization failed'**
  String get cameraInitError;

  /// No description provided for @positionFace.
  ///
  /// In en, this message translates to:
  /// **'Position your face in the circle'**
  String get positionFace;

  /// No description provided for @noFaceDetected.
  ///
  /// In en, this message translates to:
  /// **'No face detected - Position your face in the circle'**
  String get noFaceDetected;

  /// No description provided for @moveCloser.
  ///
  /// In en, this message translates to:
  /// **'Move closer to the camera'**
  String get moveCloser;

  /// No description provided for @blinkToCapture.
  ///
  /// In en, this message translates to:
  /// **'Perfect! Now blink your eyes to capture'**
  String get blinkToCapture;

  /// No description provided for @blinkDetected.
  ///
  /// In en, this message translates to:
  /// **'Blink detected! Opening eyes...'**
  String get blinkDetected;

  /// No description provided for @expiresOn.
  ///
  /// In en, this message translates to:
  /// **'Expires on {date} ({days} days left)'**
  String expiresOn(Object date, Object days);

  /// No description provided for @expiryNotAvailable.
  ///
  /// In en, this message translates to:
  /// **'Expiry date not available'**
  String get expiryNotAvailable;

  /// No description provided for @planIncludes.
  ///
  /// In en, this message translates to:
  /// **'Your plan includes:'**
  String get planIncludes;

  /// No description provided for @paymentOn.
  ///
  /// In en, this message translates to:
  /// **'Payment on'**
  String get paymentOn;

  /// No description provided for @chat.
  ///
  /// In en, this message translates to:
  /// **'Chat'**
  String get chat;

  /// No description provided for @whatsapp.
  ///
  /// In en, this message translates to:
  /// **'WhatsApp'**
  String get whatsapp;

  /// No description provided for @call.
  ///
  /// In en, this message translates to:
  /// **'Call'**
  String get call;

  /// No description provided for @views.
  ///
  /// In en, this message translates to:
  /// **'Views'**
  String get views;

  /// No description provided for @messages.
  ///
  /// In en, this message translates to:
  /// **'Messages'**
  String get messages;

  /// No description provided for @calls.
  ///
  /// In en, this message translates to:
  /// **'Calls'**
  String get calls;

  /// No description provided for @clicks.
  ///
  /// In en, this message translates to:
  /// **'Clicks'**
  String get clicks;

  /// No description provided for @vehicleAdded.
  ///
  /// In en, this message translates to:
  /// **'Vehicle added'**
  String get vehicleAdded;

  /// No description provided for @listed.
  ///
  /// In en, this message translates to:
  /// **'Listed'**
  String get listed;

  /// No description provided for @unlisted.
  ///
  /// In en, this message translates to:
  /// **'Unlisted'**
  String get unlisted;

  /// No description provided for @hire_vehicle.
  ///
  /// In en, this message translates to:
  /// **'Hire Vehicle'**
  String get hire_vehicle;

  /// No description provided for @all_Services.
  ///
  /// In en, this message translates to:
  /// **'All Services'**
  String get all_Services;

  /// No description provided for @hire_driver.
  ///
  /// In en, this message translates to:
  /// **'Hire Driver'**
  String get hire_driver;

  /// No description provided for @search_by_vehicle_type_city_or_car_code.
  ///
  /// In en, this message translates to:
  /// **'Search by vehicle type, city or car code'**
  String get search_by_vehicle_type_city_or_car_code;

  /// No description provided for @available_vehicles_with_driver.
  ///
  /// In en, this message translates to:
  /// **'Available vehicles with a driver'**
  String get available_vehicles_with_driver;

  /// No description provided for @become_partner.
  ///
  /// In en, this message translates to:
  /// **'Become Partner'**
  String get become_partner;

  /// No description provided for @around_you.
  ///
  /// In en, this message translates to:
  /// **'Around You'**
  String get around_you;

  /// No description provided for @active_drivers_nearby.
  ///
  /// In en, this message translates to:
  /// **'Active Drivers Nearby'**
  String get active_drivers_nearby;

  /// No description provided for @see_all.
  ///
  /// In en, this message translates to:
  /// **'See all'**
  String get see_all;

  /// No description provided for @joinAsPartner.
  ///
  /// In en, this message translates to:
  /// **'Join as Partner'**
  String get joinAsPartner;

  /// No description provided for @newOpportunities.
  ///
  /// In en, this message translates to:
  /// **'New Opportunities'**
  String get newOpportunities;

  /// No description provided for @startYourJourney.
  ///
  /// In en, this message translates to:
  /// **'Start your journey with us and unlock unlimited earning potential. Join thousands of successful partners.'**
  String get startYourJourney;

  /// No description provided for @highEarnings.
  ///
  /// In en, this message translates to:
  /// **'High Earnings'**
  String get highEarnings;

  /// No description provided for @fastGrowth.
  ///
  /// In en, this message translates to:
  /// **'Fast Growth'**
  String get fastGrowth;

  /// No description provided for @fullSupport.
  ///
  /// In en, this message translates to:
  /// **'Full Support'**
  String get fullSupport;

  /// No description provided for @activePartners.
  ///
  /// In en, this message translates to:
  /// **'Active Partners'**
  String get activePartners;

  /// No description provided for @monthlyEarnings.
  ///
  /// In en, this message translates to:
  /// **'Monthly Earnings'**
  String get monthlyEarnings;

  /// No description provided for @partnerRating.
  ///
  /// In en, this message translates to:
  /// **'Partner Rating'**
  String get partnerRating;

  /// No description provided for @startPartnershipJourney.
  ///
  /// In en, this message translates to:
  /// **'Start Partnership Journey'**
  String get startPartnershipJourney;

  /// No description provided for @quickApproval.
  ///
  /// In en, this message translates to:
  /// **'Quick approval in 24 hours'**
  String get quickApproval;

  /// No description provided for @partner.
  ///
  /// In en, this message translates to:
  /// **'Partner'**
  String get partner;

  /// No description provided for @joinOurPartnerNetwork.
  ///
  /// In en, this message translates to:
  /// **'Join Our Partner Network'**
  String get joinOurPartnerNetwork;

  /// No description provided for @partnershipIntro.
  ///
  /// In en, this message translates to:
  /// **'Choose your preferred partnership model and start earning today'**
  String get partnershipIntro;

  /// No description provided for @selectPartnershipType.
  ///
  /// In en, this message translates to:
  /// **'Select Your Partnership Type'**
  String get selectPartnershipType;

  /// No description provided for @partnerBenefits.
  ///
  /// In en, this message translates to:
  /// **'Partner Benefits'**
  String get partnerBenefits;

  /// No description provided for @transporterOwner.
  ///
  /// In en, this message translates to:
  /// **'Transporter Owner'**
  String get transporterOwner;

  /// No description provided for @independentCarOwner.
  ///
  /// In en, this message translates to:
  /// **'Independent Car Owner'**
  String get independentCarOwner;

  /// No description provided for @autoRickshawOwner.
  ///
  /// In en, this message translates to:
  /// **'AutoRickshaw Owner'**
  String get autoRickshawOwner;

  /// No description provided for @eRickshawOwner.
  ///
  /// In en, this message translates to:
  /// **'eRickshaw Owner'**
  String get eRickshawOwner;

  /// No description provided for @earnMore.
  ///
  /// In en, this message translates to:
  /// **'Earn More'**
  String get earnMore;

  /// No description provided for @earnMoreDesc.
  ///
  /// In en, this message translates to:
  /// **'Maximize your income potential'**
  String get earnMoreDesc;

  /// No description provided for @easyManagement.
  ///
  /// In en, this message translates to:
  /// **'Easy Management'**
  String get easyManagement;

  /// No description provided for @easyManagementDesc.
  ///
  /// In en, this message translates to:
  /// **'Simple app-based operations'**
  String get easyManagementDesc;

  /// No description provided for @trustedPlatform.
  ///
  /// In en, this message translates to:
  /// **'Trusted Platform'**
  String get trustedPlatform;

  /// No description provided for @trustedPlatformDesc.
  ///
  /// In en, this message translates to:
  /// **'Join thousands of partners'**
  String get trustedPlatformDesc;

  /// No description provided for @flexibleWork.
  ///
  /// In en, this message translates to:
  /// **'Flexible Work'**
  String get flexibleWork;

  /// No description provided for @flexibleWorkDesc.
  ///
  /// In en, this message translates to:
  /// **'Work on your own schedule'**
  String get flexibleWorkDesc;

  /// No description provided for @registrationFees.
  ///
  /// In en, this message translates to:
  /// **'Registration Fees'**
  String get registrationFees;

  /// No description provided for @registrationFeesDesc.
  ///
  /// In en, this message translates to:
  /// **'One-time payment for account setup'**
  String get registrationFeesDesc;

  /// No description provided for @accountSetupFee.
  ///
  /// In en, this message translates to:
  /// **'Account Setup Fee'**
  String get accountSetupFee;

  /// No description provided for @accountSetupIncludes.
  ///
  /// In en, this message translates to:
  /// **'Includes verification & documentation'**
  String get accountSetupIncludes;

  /// No description provided for @chooseYourPlan.
  ///
  /// In en, this message translates to:
  /// **'Choose Your Plan'**
  String get chooseYourPlan;

  /// No description provided for @chooseYourPlanDesc.
  ///
  /// In en, this message translates to:
  /// **'Select the best plan for your business'**
  String get chooseYourPlanDesc;

  /// No description provided for @perMonth.
  ///
  /// In en, this message translates to:
  /// **'/month'**
  String get perMonth;

  /// No description provided for @reviewsAndRatings.
  ///
  /// In en, this message translates to:
  /// **'Reviews & Ratings'**
  String get reviewsAndRatings;

  /// No description provided for @pricing.
  ///
  /// In en, this message translates to:
  /// **'Pricing'**
  String get pricing;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>[
        'bn',
        'en',
        'gu',
        'hi',
        'kn',
        'ml',
        'mr',
        'ta',
        'te'
      ].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'bn':
      return AppLocalizationsBn();
    case 'en':
      return AppLocalizationsEn();
    case 'gu':
      return AppLocalizationsGu();
    case 'hi':
      return AppLocalizationsHi();
    case 'kn':
      return AppLocalizationsKn();
    case 'ml':
      return AppLocalizationsMl();
    case 'mr':
      return AppLocalizationsMr();
    case 'ta':
      return AppLocalizationsTa();
    case 'te':
      return AppLocalizationsTe();
  }

  throw FlutterError(
      'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}
