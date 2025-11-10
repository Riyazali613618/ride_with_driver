// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Hindi (`hi`).
class AppLocalizationsHi extends AppLocalizations {
  AppLocalizationsHi([String locale = 'hi']) : super(locale);

  @override
  String get failed_to_load_chat_history => 'चैट इतिहास लोड करने में विफल';

  @override
  String network_error(Object error) {
    return 'नेटवर्क त्रुटि';
  }

  @override
  String get loaded_from_cache => 'कैश से लोड किया गया';

  @override
  String get failed_to_send_otp =>
      'OTP भेजने में विफल। कृपया पुनः प्रयास करें।';

  @override
  String get something_went_wrong_check_connection =>
      'कुछ गलत हुआ। कृपया अपना कनेक्शन जांचें।';

  @override
  String upload_failed(Object error) {
    return 'अपलोड विफल: $error';
  }

  @override
  String get uploading_media => 'मीडिया अपलोड हो रहा है...';

  @override
  String get invoice => 'चालान';

  @override
  String error_generating_pdf(Object error) {
    return 'PDF जेनरेट करने में त्रुटि: $error';
  }

  @override
  String error_printing(Object error) {
    return 'प्रिंट करने में त्रुटि: $error';
  }

  @override
  String get invoice_simplified_note =>
      'नोट: यह आपके चालान का सरलीकृत संस्करण है। मूल स्वरूपण को PDF प्रारूप में संरक्षित नहीं किया जा सका।';

  @override
  String get error_rendering_content => 'सामग्री प्रस्तुत करने में त्रुटि';

  @override
  String get loading => 'लोड हो रहा है...';

  @override
  String get check_internet_and_retry =>
      'कृपया अपना इंटरनेट कनेक्शन जांचें और पुनः प्रयास करें।';

  @override
  String get retry => 'पुनः प्रयास करें';

  @override
  String step_number(Object stepNumber) {
    return '$stepNumber';
  }

  @override
  String get search_for_location => 'स्थान खोजें...';

  @override
  String get image_captured => 'छवि कैप्चर की गई!';

  @override
  String get photo_captured_successfully =>
      'आपकी फोटो सफलतापूर्वक कैप्चर की गई है!';

  @override
  String get capture_again => 'फिर से कैप्चर करें';

  @override
  String get use_this_photo => 'इस फोटो का उपयोग करें';

  @override
  String get capture_image => 'छवि कैप्चर करें';

  @override
  String get instructions => 'निर्देश:';

  @override
  String get face_capture_instructions =>
      '1. अपना चेहरा सर्कल में रखें\n2. हरी बॉर्डर का इंतजार करें\n3. कैप्चर करने के लिए आँखें झपकाएँ';

  @override
  String get replace_media => 'मीडिया बदलें';

  @override
  String get confirm_replace => 'क्या आप वाकई बदलना चाहते हैं';

  @override
  String get cancel => 'रद्द करें';

  @override
  String get replace => 'बदलें';

  @override
  String get camera_error => 'कैमरा त्रुटि';

  @override
  String get camera_access_issue =>
      'कैमरा तक पहुंच नहीं मिल सकी। कृपया जांचें:';

  @override
  String get camera_permission_check => '• कैमरा अनुमतियाँ दी गई हैं';

  @override
  String get working_camera_check => '• आपके डिवाइस में कार्यशील कैमरा है';

  @override
  String get camera_in_use_check =>
      '• कोई अन्य ऐप कैमरा का उपयोग नहीं कर रहा है';

  @override
  String get ok => 'ठीक है';

  @override
  String get select_media_source => 'मीडिया स्रोत चुनें';

  @override
  String get choose_media_method => 'अपना मीडिया जोड़ने का तरीका चुनें';

  @override
  String get gallery => 'गैलरी';

  @override
  String get choose_from_existing => 'मौजूदा फोटो से चुनें';

  @override
  String get authentication_required => 'प्रमाणीकरण आवश्यक';

  @override
  String get login_to_upload_media =>
      'मीडिया अपलोड करने के लिए आपको लॉग इन करना होगा। कृपया लॉग इन करें और पुनः प्रयास करें।';

  @override
  String get media_preview => 'मीडिया पूर्वावलोकन';

  @override
  String get open => 'खोलें';

  @override
  String get failed_to_load_image => 'छवि लोड करने में विफल';

  @override
  String get asterisk => '*';

  @override
  String get update_image => 'छवि अपडेट करें';

  @override
  String get uploading => 'अपलोड हो रहा है...';

  @override
  String get max_file_size => '(अधिकतम फाइल आकार: 25 MB)';

  @override
  String get add_more => 'और जोड़ें';

  @override
  String get unable_to_load_pdf => 'PDF लोड करने में असमर्थ';

  @override
  String get error_loading_media => 'मीडिया लोड करने में त्रुटि';

  @override
  String get app_initialization_failed => 'ऐप आरंभीकरण विफल';

  @override
  String get ride_with_driver => 'ड्राइवर के साथ सवारी';

  @override
  String step_x_of_y(Object currentStep, Object totalSteps) {
    return 'चरण $currentStep / $totalSteps';
  }

  @override
  String get previous => 'पिछला';

  @override
  String get company_name => 'कंपनी का नाम';

  @override
  String get enter_company_name => 'अपने कंपनी का नाम दर्ज करें';

  @override
  String get registered_address => 'पंजीकृत पता';

  @override
  String get enter_registered_address => 'अपना पंजीकृत पता दर्ज करें';

  @override
  String get address_type => 'पता प्रकार';

  @override
  String error_picking_document(Object error) {
    return 'दस्तावेज़ चुनने में त्रुटि: $error';
  }

  @override
  String get gstin => 'जीएसटीआईएन';

  @override
  String get enter_gstin => 'अपना जीएसटीआईएन दर्ज करें';

  @override
  String get business_registration_certificate => 'व्यवसाय पंजीकरण प्रमाणपत्र';

  @override
  String get upload_certificate_of_incorporation =>
      'समामेलन का प्रमाणपत्र अपलोड करें (PDF/छवि)';

  @override
  String get authorized_person_aadhaar => 'अधिकृत व्यक्ति आधार';

  @override
  String get enter_12_digit_aadhaar => '12-अंकीय आधार संख्या दर्ज करें';

  @override
  String displayed_as_aadhaar(Object formattedAadhar) {
    return 'इस रूप में दिखाया गया: $formattedAadhar';
  }

  @override
  String get transportation_permit => 'परिवहन परमिट';

  @override
  String get upload_transportation_permit =>
      'वैध परिवहन परमिट दस्तावेज़ अपलोड करें';

  @override
  String error_picking_images(Object error) {
    return 'छवियाँ चुनने में त्रुटि: $error';
  }

  @override
  String get total_fleet_size => 'कुल फ्लीट आकार';

  @override
  String get small_fleet => 'छोटा (2-5 वाहन)';

  @override
  String get medium_fleet => 'मध्यम (6-15 वाहन)';

  @override
  String get large_fleet => 'बड़ा (15+ वाहन)';

  @override
  String get vehicle_details => 'वाहन विवरण';

  @override
  String enter_number_of_vehicles(Object vehicleType) {
    return '$vehicleType की संख्या दर्ज करें';
  }

  @override
  String get allow_negotiation => 'मोलभाव की अनुमति दें';

  @override
  String get vehicle_photos => 'वाहन फोटो';

  @override
  String get add_vehicle_photos_description =>
      'अपने फ्लीट को प्रदर्शित करने के लिए अपने वाहनों की फोटो जोड़ें';

  @override
  String get add_vehicle_photos => 'वाहन फोटो जोड़ें';

  @override
  String get complete_now_message =>
      'अभी पूरा करें → 2 घंटे में सत्यापित हो जाएं!\nयदि अतिरिक्त जानकारी की आवश्यकता होगी, तो हम आपसे संपर्क करेंगे।';

  @override
  String get phone_verified_successfully => 'फोन नंबर सफलतापूर्वक सत्यापित हुआ';

  @override
  String verification_failed(Object error) {
    return 'सत्यापन विफल: $error';
  }

  @override
  String get contact_information => 'संपर्क जानकारी';

  @override
  String get contact_information_description =>
      'ये विवरण ग्राहक संचार के लिए हमारी वेबसाइट और ऐप पर प्रदर्शित किए जाएंगे';

  @override
  String get contact_person_name => 'संपर्क व्यक्ति का नाम';

  @override
  String get name_example => 'जैसे, राहुल शर्मा';

  @override
  String get mobile_number => 'मोबाइल नंबर';

  @override
  String use_login_number(Object phoneNumber) {
    return 'लॉगिन नंबर का उपयोग करें ($phoneNumber)';
  }

  @override
  String get new_mobile_number => 'नया मोबाइल नंबर';

  @override
  String get enter_mobile_number => 'मोबाइल नंबर दर्ज करें';

  @override
  String get show_mobile_number => 'वेबसाइट/ऐप पर मोबाइल नंबर दिखाएं';

  @override
  String get whatsapp_number => 'व्हाट्सएप नंबर';

  @override
  String get new_whatsapp_number => 'नया व्हाट्सएप नंबर';

  @override
  String get enter_whatsapp_number => 'व्हाट्सएप नंबर दर्ज करें';

  @override
  String get show_whatsapp_number => 'वेबसाइट/ऐप पर व्हाट्सएप नंबर दिखाएं';

  @override
  String get enable_in_app_chat => 'इन-ऐप चैट सिस्टम सक्षम करें';

  @override
  String get enable_in_app_chat_description =>
      'ग्राहकों को हमारे ऐप के माध्यम से आपसे संपर्क करने की अनुमति दें';

  @override
  String get review_your_information => 'अपनी जानकारी की समीक्षा करें';

  @override
  String get registration_verification_time =>
      'आपका पंजीकरण 2 घंटे के भीतर सत्यापित कर दिया जाएगा। यदि अतिरिक्त जानकारी की आवश्यकता होगी तो हम आपसे संपर्क कर सकते हैं।';

  @override
  String get all_localized_strings => 'सभी स्थानीयकृत स्ट्रिंग्स:';

  @override
  String get strings_with_placeholders => 'प्लेसहोल्डर के साथ स्ट्रिंग्स:';

  @override
  String get auth_token_not_found =>
      'प्रमाणीकरण टोकन नहीं मिला। कृपया फिर से लॉगिन करें।';

  @override
  String get server_error => 'सर्वर त्रुटि';

  @override
  String get failed_to_update_profile =>
      'प्रोफाइल अपडेट करने में विफल। कृपया अपना इंटरनेट कनेक्शन जांचें।';

  @override
  String get complete_your_profile => 'अपनी प्रोफाइल पूरी करें';

  @override
  String get welcome => 'स्वागत है!';

  @override
  String get complete_profile_to_continue =>
      'जारी रखने के लिए कृपया अपनी प्रोफाइल पूरी करें';

  @override
  String get first_name_required => 'पहला नाम *';

  @override
  String get last_name => 'अंतिम नाम';

  @override
  String get email_optional => 'ईमेल (वैकल्पिक)';

  @override
  String get log_in => 'लॉग इन करें';

  @override
  String get enter_correct_phone => 'कृपया सही फोन नंबर दर्ज करें';

  @override
  String get logout => 'लॉग आउट';

  @override
  String get confirm_logout => 'क्या आप वाकई लॉग आउट करना चाहते हैं?';

  @override
  String get logged_out_successfully => 'सफलतापूर्वक लॉग आउट हो गया';

  @override
  String get failed_to_logout =>
      'लॉग आउट करने में विफल। कृपया पुनः प्रयास करें।';

  @override
  String get enter_all_4_digits => 'कृपया सभी 4 अंक दर्ज करें';

  @override
  String get failed_to_verify_otp =>
      'OTP सत्यापित करने में विफल। कृपया पुनः प्रयास करें।';

  @override
  String get otp_resent => 'OTP कोड आपके व्हाट्सएप नंबर पर पुनः भेजा गया';

  @override
  String get failed_to_resend_otp =>
      'OTP पुनः भेजने में विफल। कृपया पुनः प्रयास करें।';

  @override
  String get verify_phone_number => 'अपना फोन नंबर सत्यापित करें';

  @override
  String get did_not_receive_code => 'कोड प्राप्त नहीं हुआ?';

  @override
  String get resend_code => 'कोड पुनः भेजें';

  @override
  String change_language(Object languageName) {
    return 'भाषा बदलें $languageName';
  }

  @override
  String get your_review => 'आपकी समीक्षा';

  @override
  String get something_went_wrong => 'कुछ गलत हुआ';

  @override
  String get no_reviews_yet => 'अभी तक कोई समीक्षा नहीं';

  @override
  String get no_reviews_received =>
      'आपको अभी तक कोई समीक्षा प्राप्त नहीं हुई है।';

  @override
  String get my_ratings_reviews => 'मेरी रेटिंग्स और समीक्षाएँ';

  @override
  String error_deleting_review(Object error) {
    return 'समीक्षा हटाने में त्रुटि: $error';
  }

  @override
  String get confirm_delete => 'हटाने की पुष्टि करें';

  @override
  String get confirm_delete_review =>
      'क्या आप वाकई इस समीक्षा को हटाना चाहते हैं?';

  @override
  String get delete => 'हटाएं';

  @override
  String review_rating_count(Object totalReviews) {
    return 'समीक्षा और रेटिंग ($totalReviews)';
  }

  @override
  String error_loading_reviews(Object error) {
    return 'समीक्षाएँ लोड करने में त्रुटि: $error';
  }

  @override
  String get no_reviews_available => 'अभी तक कोई समीक्षा नहीं';

  @override
  String get be_first_to_review =>
      'अपना अनुभव साझा करने वाले पहले व्यक्ति बनें!';

  @override
  String get rate_now => 'अभी रेट करें';

  @override
  String rating_display(Object rating) {
    return '$rating.0';
  }

  @override
  String get enter_your_review => 'कृपया अपनी समीक्षा दर्ज करें';

  @override
  String error_updating_review(Object error) {
    return 'समीक्षा अपडेट करने में त्रुटि: $error';
  }

  @override
  String get edit_review => 'समीक्षा संपादित करें';

  @override
  String get your_review_text => 'आपकी समीक्षा';

  @override
  String get update => 'अपडेट करें';

  @override
  String get could_not_open_pdf => 'PDF खोल नहीं सका';

  @override
  String error_message(Object error) {
    return 'त्रुटि: $error';
  }

  @override
  String get active_subscriptions => 'सक्रिय सदस्यताएँ';

  @override
  String get manage_subscriptions => 'अपनी वर्तमान सदस्यताएँ प्रबंधित करें';

  @override
  String get error => 'त्रुटि';

  @override
  String get no_active_subscriptions => 'कोई सक्रिय सदस्यता नहीं';

  @override
  String get no_subscriptions_message => 'आपकी कोई सक्रिय सदस्यता नहीं है।';

  @override
  String get active_plan => 'सक्रिय योजना';

  @override
  String get transaction_history => 'लेन-देन इतिहास';

  @override
  String plan_name(Object planName) {
    return '$planName';
  }

  @override
  String price_in_rupees(Object price) {
    return '₹$price';
  }

  @override
  String get upgrade_plan => 'योजना अपग्रेड करें';

  @override
  String get add_payment_methods => 'भुगतान विधियाँ जोड़ें';

  @override
  String get card_charge_description =>
      'यह कार्ड केवल तभी चार्ज किया जाएगा जब आप\nकोई ऑर्डर देंगे।';

  @override
  String get card_number_example => '4343 4343 4343 4343';

  @override
  String get card_expiry => 'महीना/साल';

  @override
  String get card_cvc => 'CVC';

  @override
  String get add_card => 'कार्ड जोड़ें';

  @override
  String get upi_payment => 'UPI भुगतान';

  @override
  String get scan_card => 'कार्ड स्कैन करें';

  @override
  String get my_dashboard => 'मेरा डैशबोर्ड';

  @override
  String get analytics => 'विश्लेषण';

  @override
  String get vehicles => 'वाहन';

  @override
  String get quick_actions => 'त्वरित कार्य';

  @override
  String get loading_dashboard => 'डैशबोर्ड लोड हो रहा है...';

  @override
  String get oops_something_wrong => 'उफ़! कुछ गलत हो गया';

  @override
  String reach_percentage(Object reachPercentage) {
    return '$reachPercentage';
  }

  @override
  String get profile => 'प्रोफाइल';

  @override
  String get reached => 'पहुँचे';

  @override
  String get my_vehicles => 'मेरे वाहन';

  @override
  String vehicles_added_count(Object currentVehicles, Object maxLimit) {
    return '$currentVehicles/$maxLimit वाहन जोड़े गए';
  }

  @override
  String get vehicle_limit => 'वाहन सीमा';

  @override
  String vehicles_limit_count(Object currentVehicles, Object maxLimit) {
    return '$currentVehicles/$maxLimit';
  }

  @override
  String get limit_reached_message =>
      'सीमा पहुँच गई! अधिक वाहन जोड़ने के लिए अपग्रेड करें।';

  @override
  String get loading_vehicles => 'वाहन लोड हो रहे हैं...';

  @override
  String get no_vehicles_added => 'अभी तक कोई वाहन नहीं जोड़ा गया';

  @override
  String get add_first_vehicle_message =>
      'बुकिंग शुरू करने और अपने फ्लीट को प्रभावी ढंग से प्रबंधित करने के लिए अपना पहला वाहन जोड़ें।';

  @override
  String get add_vehicle => 'वाहन जोड़ें';

  @override
  String get upgrade_your_plan => 'अपनी योजना अपग्रेड करें';

  @override
  String get upgrade_to_transporter_message =>
      'अधिक वाहन जोड़ने और प्रीमियम सुविधाओं को अनलॉक करने के लिए आपको TRANSPORTER योजना में अपग्रेड करने की आवश्यकता है।';

  @override
  String get maybe_later => 'शायद बाद में';

  @override
  String get upgrade_now => 'अभी अपग्रेड करें';

  @override
  String get profile_updated_success => 'प्रोफाइल सफलतापूर्वक अपडेट हो गई!';

  @override
  String get no_profile_data => 'कोई प्रोफाइल डेटा उपलब्ध नहीं';

  @override
  String get profile_photo_updated => 'प्रोफाइल फोटो सफलतापूर्वक अपडेट हो गई!';

  @override
  String error_updating_photo(Object error) {
    return 'फोटो अपडेट करने में त्रुटि: $error';
  }

  @override
  String get verified => 'सत्यापित';

  @override
  String get basic_information => 'मूल जानकारी';

  @override
  String get address_information => 'पता जानकारी';

  @override
  String get fleet_information => 'फ्लीट जानकारी';

  @override
  String get vehicle_types => 'वाहन प्रकार';

  @override
  String get vehicle_counts => 'वाहन गणना';

  @override
  String get professional_information => 'पेशेवर जानकारी';

  @override
  String get saving => 'सहेजा जा रहा है...';

  @override
  String get save_changes => 'परिवर्तन सहेजें';

  @override
  String select_label(Object label) {
    return '$label चुनें';
  }

  @override
  String get vehicle_information => 'वाहन जानकारी';

  @override
  String get pricing_information => 'मूल्य निर्धारण जानकारी';

  @override
  String get price_negotiable => 'मोलभाव योग्य मूल्य';

  @override
  String get service_areas => 'सेवा क्षेत्र';

  @override
  String get vehicle_specifications => 'वाहन विशिष्टताएँ';

  @override
  String get about_driver => 'ड्राइवर के बारे में';

  @override
  String get vehicle_images => 'वाहन छवियाँ';

  @override
  String get processing_payment => 'भुगतान प्रसंस्करण...';

  @override
  String get add_payment => 'भुगतान जोड़ें';

  @override
  String price_in_rupees_with_space(Object price) {
    return '₹ $price';
  }

  @override
  String discount_percentage_off(Object discountPercentage) {
    return '$discountPercentage% छूट';
  }

  @override
  String get total => 'कुल';

  @override
  String price_in_rs(Object price) {
    return 'रु $price';
  }

  @override
  String get make_payment => 'भुगतान करें';

  @override
  String get choose_right_plan => 'सही योजना चुनें';

  @override
  String get choose_plan_description =>
      'एक योजना चुनें और उसके अनुसार सेट करें';

  @override
  String get loading_plans => 'योजनाएँ लोड हो रही हैं...';

  @override
  String get payment_successful => 'भुगतान सफलतापूर्वक प्राप्त हुआ!';

  @override
  String get payment_success_message =>
      'आपका भुगतान सफलतापूर्वक संसाधित हो गया है। अब आप शुरू करने के लिए अपना पंजीकरण पूरा कर सकते हैं।';

  @override
  String get complete_registration => 'पंजीकरण पूरा करें';

  @override
  String get no_plans_available => 'कोई योजना उपलब्ध नहीं';

  @override
  String get no_plans_message =>
      'इस प्रकार के लिए वर्तमान में कोई योजना उपलब्ध नहीं है।';

  @override
  String get refresh => 'ताज़ा करें';

  @override
  String get apply_now => 'अभी आवेदन करें';

  @override
  String get delete_vehicle => 'वाहन हटाएं';

  @override
  String get confirm_delete_vehicle =>
      'क्या आप वाकई इस वाहन को हटाना चाहते हैं?';

  @override
  String vehicle_name_number(Object vehicleName, Object vehicleNumber) {
    return '$vehicleName ($vehicleNumber)';
  }

  @override
  String get action_cannot_be_undone =>
      'इस क्रिया को पूर्ववत नहीं किया जा सकता।';

  @override
  String get vehicle_actions => 'वाहन क्रियाएँ';

  @override
  String get select_vehicle_action => 'इस वाहन के लिए एक क्रिया चुनें:';

  @override
  String get permanently_remove_vehicle => 'इस वाहन को स्थायी रूप से हटाएं';

  @override
  String get disable_vehicle => 'वाहन अक्षम करें';

  @override
  String get hide_vehicle_from_listings => 'इस वाहन को लिस्टिंग से छिपाएं';

  @override
  String get enable_vehicle => 'वाहन सक्षम करें';

  @override
  String get make_vehicle_visible => 'इस वाहन को लिस्टिंग में दिखाएं';

  @override
  String get loading_vehicle_details => 'वाहन विवरण लोड हो रहे हैं...';

  @override
  String get error_loading_vehicle_details => 'वाहन विवरण लोड करने में त्रुटि';

  @override
  String get pricing_location => 'मूल्य निर्धारण और स्थान';

  @override
  String currency(Object currency) {
    return '$currency';
  }

  @override
  String vehicle_images_count(Object count) {
    return 'वाहन छवियाँ ($count)';
  }

  @override
  String get failed_to_load => 'लोड करने में विफल';

  @override
  String vehicle_videos_count(Object count) {
    return 'वाहन वीडियो ($count)';
  }

  @override
  String media_type_index(Object index, Object mediaType) {
    return '$mediaType $index';
  }

  @override
  String get vehicle_documents => 'वाहन दस्तावेज़';

  @override
  String get no_documents_uploaded => 'कोई दस्तावेज़ अपलोड नहीं किया गया';

  @override
  String get edit_vehicle => 'वाहन संपादित करें';

  @override
  String get press_back_again_to_exit => 'बाहर निकलने के लिए फिर से बैक दबाएं';

  @override
  String get notifications => 'सूचनाएँ';

  @override
  String get notification_marked_read => 'सूचना पढ़ी गई के रूप में चिह्नित';

  @override
  String get sharing_notification => 'सूचना साझा की जा रही है...';

  @override
  String get no_notifications => 'कोई सूचना नहीं';

  @override
  String get no_notifications_message => 'आपके पास अभी तक कोई सूचना नहीं है।';

  @override
  String get failed_to_load_notifications =>
      'सूचनाएँ लोड करने में विफल। कृपया अपना कनेक्शन जांचें और पुनः प्रयास करें।';

  @override
  String get details => 'विवरण';

  @override
  String get colon => ':';

  @override
  String search_error(Object error) {
    return 'खोज त्रुटि: $error';
  }

  @override
  String error_getting_location(Object error) {
    return 'स्थान विवरण प्राप्त करने में त्रुटि: $error';
  }

  @override
  String get select_location_first => 'कृपया पहले एक स्थान चुनें';

  @override
  String no_locations_found(Object query) {
    return '$query से मेल खाता कोई स्थान नहीं मिला';
  }

  @override
  String get help_support => 'सहायता और समर्थन';

  @override
  String get loading_faq => 'FAQ लोड हो रहा है...';

  @override
  String get no_faq_available => 'कोई FAQ उपलब्ध नहीं';

  @override
  String get faq_content_coming => 'FAQ सामग्री उपलब्ध होने पर यहां दिखाई देगी';

  @override
  String get find_answers => 'सामान्य प्रश्नों के उत्तर खोजें';

  @override
  String questions_count(Object count) {
    return '$count प्रश्न';
  }

  @override
  String get settings => 'सेटिंग्स';

  @override
  String get language_settings => 'भाषा बदलें';

  @override
  String get delete_account => 'खाता हटाएं';

  @override
  String get delete_account_warning =>
      'इस क्रिया को पूर्ववत नहीं किया जा सकता। आपका सारा डेटा स्थायी रूप से हटा दिया जाएगा।';

  @override
  String get my_profile => 'मेरी प्रोफाइल';

  @override
  String get load_profile => 'प्रोफाइल लोड करें';

  @override
  String profile_name(Object name) {
    return 'नाम: $name';
  }

  @override
  String profile_phone(Object phone) {
    return 'फोन: $phone';
  }

  @override
  String profile_user_type(Object userType) {
    return 'उपयोगकर्ता प्रकार: $userType';
  }

  @override
  String email_copied(Object email) {
    return 'ईमेल क्लिपबोर्ड पर कॉपी किया गया: $email';
  }

  @override
  String unable_to_open_email(Object email) {
    return 'ईमेल क्लाइंट खोलने में असमर्थ। ईमेल: $email';
  }

  @override
  String phone_copied(Object phone) {
    return 'फोन नंबर कॉपी किया गया: $phone';
  }

  @override
  String unable_to_process_phone(Object phone) {
    return 'फोन नंबर प्रोसेस करने में असमर्थ: $phone';
  }

  @override
  String get address_copied => 'पता क्लिपबोर्ड पर कॉपी किया गया';

  @override
  String get unable_to_open_maps => 'मैप्स खोलने या पता कॉपी करने में असमर्थ';

  @override
  String get support_center => 'सहायता केंद्र';

  @override
  String get loading_support_info => 'सहायता जानकारी लोड हो रही है...';

  @override
  String get how_can_we_help => 'हम आपकी कैसे मदद कर सकते हैं?';

  @override
  String get choose_support_method =>
      'हमारी सहायता टीम तक पहुँचने का सबसे अच्छा तरीका चुनें';

  @override
  String get contact_by_email => 'ईमेल द्वारा संपर्क करें';

  @override
  String get other_ways_to_contact => 'हमसे संपर्क करने के अन्य तरीके';

  @override
  String get accept_to_continue => 'जारी रखने के लिए कृपया स्वीकार करें';

  @override
  String get loading_data => 'डेटा लोड हो रहा है...';

  @override
  String get failed_to_load_data => 'डेटा लोड करने में विफल';

  @override
  String get no_data_available => 'कोई डेटा उपलब्ध नहीं';

  @override
  String get read_and_agree => 'मैंने पढ़ लिया है और सहमत हूँ';

  @override
  String get accept => 'स्वीकार करें';

  @override
  String get terms_conditions => 'नियम और शर्तें';

  @override
  String get effective_date => 'प्रभावी तिथि: 15 अप्रैल 2025';

  @override
  String get terms_welcome_message =>
      'RideNow टैक्सी ऐप में आपका स्वागत है। हमारी सेवाओं का उपयोग करके, आप नीचे दिए गए नियमों और शर्तों से सहमत होते हैं। सवारी बुक करने से पहले कृपया उन्हें ध्यान से पढ़ें।';

  @override
  String get need_help_contact => 'मदद चाहिए?\nसमर्थन से संपर्क करें';

  @override
  String get customer_care_24x7 => '24x7 ग्राहक सेवा';

  @override
  String get phone_icon => '📞';

  @override
  String get support_phone => '+91-9999999999';

  @override
  String get email_icon => '📧';

  @override
  String get support_email => 'support@ridenow.com';

  @override
  String get profile_photo_required => 'प्रोफाइल फोटो आवश्यक है';

  @override
  String get wait_for_doc_verification =>
      'आगे बढ़ने से पहले कृपया सभी दस्तावेज़ों के सत्यापित होने का इंतजार करें';

  @override
  String get all_docs_required => 'सभी आवश्यक दस्तावेज़ आवश्यक हैं';

  @override
  String get fuel_type => 'ईंधन प्रकार';

  @override
  String get vehicle_ownership => 'वाहन स्वामित्व';

  @override
  String get rc_front_required => 'आरसी बुक फ्रंट फोटो आवश्यक है';

  @override
  String get rc_back_required => 'आरसी बुक बैक फोटो आवश्यक है';

  @override
  String get at_least_one_vehicle_photo => 'कम से कम एक वाहन फोटो आवश्यक है';

  @override
  String get service_city => 'सेवा शहर';

  @override
  String get language => 'भाषा';

  @override
  String get no_document_uploaded => 'अभी तक कोई दस्तावेज़ अपलोड नहीं किया गया';

  @override
  String get verify_docs_before_submission =>
      'सबमिशन से पहले कृपया सभी दस्तावेज़ सत्यापित करें';

  @override
  String get become_auto_rickshaw_driver => 'ऑटो रिक्शा ड्राइवर बनें';

  @override
  String get india_code => '+91';

  @override
  String get doc_verification => 'दस्तावेज़ सत्यापन';

  @override
  String get allow_fare_negotiation => 'किराया मोलभाव की अनुमति दें';

  @override
  String get service_cities => 'सेवा शहर';

  @override
  String get personal_information => 'व्यक्तिगत जानकारी';

  @override
  String get doc_verification_status => 'दस्तावेज़ सत्यापन स्थिति';

  @override
  String get uploaded_files => 'अपलोड की गई फाइलें:';

  @override
  String get fare_details => 'किराया विवरण';

  @override
  String get languages_spoken => 'बोली जाने वाली भाषाएँ';

  @override
  String get address => 'पता';

  @override
  String get submission_confirmation =>
      'इस आवेदन को जमा करके, आप पुष्टि करते हैं कि प्रदान की गई सभी जानकारी सटीक और सत्य है।';

  @override
  String label_colon(Object label) {
    return '$label:';
  }

  @override
  String get gender => 'लिंग';

  @override
  String get vehicle_type => 'वाहन प्रकार';

  @override
  String get services_cities => 'सेवा शहर';

  @override
  String get language_spoken => 'बोली जाने वाली भाषा';

  @override
  String get become_driver => 'ड्राइवर बनें';

  @override
  String get experience_charges => 'अनुभव और शुल्क';

  @override
  String get vehicle_cities => 'वाहन और शहर';

  @override
  String get successfully_verified => 'सफलतापूर्वक सत्यापित';

  @override
  String get verify_images => 'छवियाँ सत्यापित करें';

  @override
  String get enter_aadhaar_number => 'अपना आधार नंबर दर्ज करें';

  @override
  String get name_as_on_aadhaar => 'आधार पर नाम';

  @override
  String get verify => 'सत्यापित करें';

  @override
  String get enter_dl_number => 'अपना ड्राइविंग लाइसेंस नंबर दर्ज करें';

  @override
  String get name_as_on_license => 'लाइसेंस पर नाम';

  @override
  String get date_of_birth => 'जन्म तिथि';

  @override
  String get view => 'देखें';

  @override
  String get image_preview => 'छवि पूर्वावलोकन';

  @override
  String image_count(Object currentIndex, Object totalImages) {
    return '$currentIndex / $totalImages';
  }

  @override
  String get please_check_internet => 'कृपया अपना इंटरनेट कनेक्शन जांचें';

  @override
  String get application_submitted => 'आवेदन सफलतापूर्वक जमा हो गया!';

  @override
  String error_occurred(Object error) {
    return 'एक त्रुटि हुई: $error';
  }

  @override
  String get e_rickshaw_registration => 'ई-रिक्शा पंजीकरण';

  @override
  String get submission_confirmation_complete =>
      'इस आवेदन को जमा करके, आप पुष्टि करते हैं कि प्रदान की गई सभी जानकारी सटीक और पूर्ण है।';

  @override
  String get become_transporter => 'ट्रांसपोर्टर बनें';

  @override
  String get fleet_size => 'फ्लीट आकार';

  @override
  String get enable_price_negotiation =>
      'चैट/कॉल के माध्यम से मूल्य मोलभाव सक्षम करें';

  @override
  String get business_info => 'व्यवसाय जानकारी';

  @override
  String get contact_preferences => 'संपर्क वरीयताएँ';

  @override
  String get documents => 'दस्तावेज़';

  @override
  String get submission_confirmation_valid =>
      'इस आवेदन को जमा करके, आप पुष्टि करते हैं कि प्रदान की गई सभी जानकारी सटीक है और दस्तावेज़ वैध हैं।';

  @override
  String get air_conditioning => 'एयर कंडीशनिंग';

  @override
  String get served_location => 'सेवा स्थान';

  @override
  String get priceIs_negotiable => 'मूल्य मोलभाव योग्य है';

  @override
  String get vehicle_videos_optional => 'वाहन वीडियो (वैकल्पिक)';

  @override
  String get vehicle_registration_docs => 'वाहन पंजीकरण दस्तावेज़';

  @override
  String get rc_front_photo => 'आरसी बुक फ्रंट फोटो';

  @override
  String get rc_back_photo => 'आरसी बुक बैक फोटो';

  @override
  String get review_vehicle_info => 'अपनी वाहन जानकारी की समीक्षा करें';

  @override
  String videos_uploaded_count(Object count) {
    return '$count वीडियो अपलोड किया गया';
  }

  @override
  String get reg_documents => 'पंजीकरण दस्तावेज़';

  @override
  String get rc_front => 'आरसी बुक फ्रंट';

  @override
  String get rc_back => 'आरसी बुक बैक';

  @override
  String get review_before_submitting =>
      'सबमिट करने से पहले कृपया सभी जानकारी सावधानीपूर्वक समीक्षा करें।';

  @override
  String failed_to_delete_chat(Object error) {
    return 'चैट हटाने में विफल: $error';
  }

  @override
  String get delete_chat => 'चैट हटाएं';

  @override
  String confirm_delete_chat(Object name) {
    return 'क्या आप वाकई $name के साथ इस चैट को हटाना चाहते हैं?';
  }

  @override
  String get message => 'संदेश';

  @override
  String get loading_chats => 'चैट लोड हो रही हैं...';

  @override
  String get no_chats_yet => 'अभी तक कोई चैट नहीं';

  @override
  String get start_conversation_message =>
      'एक वार्तालाप शुरू करें ताकि इसे यहां देख सकें';

  @override
  String get deleting => 'हटाया जा रहा है...';

  @override
  String get typing => 'टाइप कर रहे हैं...';

  @override
  String get type_message => 'एक संदेश टाइप करें...';

  @override
  String get upload_media => 'मीडिया अपलोड करें';

  @override
  String get document => 'दस्तावेज़';

  @override
  String get download => 'डाउनलोड';

  @override
  String get unsupported_media => 'असमर्थित मीडिया प्रकार';

  @override
  String get loading_video => 'वीडियो लोड हो रहा है...';

  @override
  String get cannot_open_document => 'दस्तावेज़ नहीं खोल सकता';

  @override
  String get failed_to_download_doc => 'दस्तावेज़ डाउनलोड करने में विफल';

  @override
  String get filter_options => 'फ़िल्टर विकल्प';

  @override
  String get reset => 'रीसेट';

  @override
  String get apply => 'लागू करें';

  @override
  String get unsaved_changes => 'असहेजित परिवर्तन';

  @override
  String get confirm_leave_without_saving =>
      'आपके पास असहेजित परिवर्तन हैं। क्या आप वाकई बिना सहेजे जाना चाहते हैं?';

  @override
  String get leave => 'छोड़ें';

  @override
  String get edit_profile => 'प्रोफाइल संपादित करें';

  @override
  String get loading_profile => 'आपकी प्रोफाइल लोड हो रही है...';

  @override
  String get view_edit_profile => 'प्रोफाइल देखें और संपादित करें';

  @override
  String get plans => 'योजनाएँ';

  @override
  String get my_ratings => 'मेरी रेटिंग्स';

  @override
  String get faq => 'एफ़ एक्यू';

  @override
  String get support => 'समर्थन';

  @override
  String get rate_our_app => 'हमारे ऐप को रेट करें';

  @override
  String get about_us => 'हमारे बारे में';

  @override
  String get privacy_policy => 'गोपनीयता नीति';

  @override
  String get choose_perfect_driver => 'अपना सही ड्राइवर चुनें';

  @override
  String get no_driver_found => 'कोई ड्राइवर नहीं मिला';

  @override
  String get try_different_criteria =>
      'विभिन्न मानदंडों के साथ खोज करने का प्रयास करें';

  @override
  String years_experience(Object experience) {
    return '$experience वर्ष';
  }

  @override
  String get failed_to_log_activity => 'गतिविधि लॉग करने में विफल';

  @override
  String get view_more => 'और देखें';

  @override
  String get driver_profile => 'ड्राइवर प्रोफाइल';

  @override
  String get no_driver_details => 'कोई ड्राइवर विवरण नहीं मिला';

  @override
  String years_experience_display(Object experience) {
    return '$experience वर्षों का अनुभव';
  }

  @override
  String get more_info => 'अधिक जानकारी';

  @override
  String colon_value(Object value) {
    return ': $value';
  }

  @override
  String get driver_bio => 'ड्राइवर के बारे में';

  @override
  String get minimum_charges => 'न्यूनतम शुल्क';

  @override
  String rupees_amount(Object amount) {
    return '₹ $amount';
  }

  @override
  String get review_submitted => 'समीक्षा सफलतापूर्वक जमा हो गई!';

  @override
  String get ratings_reviews => 'रेटिंग्स और समीक्षाएँ';

  @override
  String get rating_colon => 'रेटिंग:';

  @override
  String get congratulations => 'बधाई हो!';

  @override
  String get successfully_registered => 'आपने सफलतापूर्वक पंजीकरण कर लिया है।';

  @override
  String get payment_successful_title => 'भुगतान सफल!';

  @override
  String get transaction_completed => 'आपका लेन-देन पूरा हो गया है';

  @override
  String get date_colon => 'तिथि';

  @override
  String get time_colon => 'समय';

  @override
  String get transaction_id => 'लेन-देन आईडी';

  @override
  String get amount_colon => 'राशि';

  @override
  String get payment_method_colon => 'भुगतान विधि';

  @override
  String get share_receipt => 'रसीद साझा करें';

  @override
  String get done => 'हो गया';

  @override
  String get loading_transporter_details =>
      'ट्रांसपोर्टर विवरण लोड हो रहे हैं...';

  @override
  String total_fleet_size_display(Object count) {
    return 'कुल फ्लीट आकार: $count';
  }

  @override
  String get available_vehicles => 'उपलब्ध वाहन';

  @override
  String vehicles_count(Object count, Object plural) {
    return '$count वाहन';
  }

  @override
  String current_of_total(Object current, Object total) {
    return '$current/$total';
  }

  @override
  String get no_vehicles_available => 'कोई वाहन उपलब्ध नहीं';

  @override
  String price_per_hour(Object currency, Object price) {
    return '$currency$price/घंटा';
  }

  @override
  String get negotiable => 'मोलभाव योग्य';

  @override
  String get image_not_available => 'छवि उपलब्ध नहीं';

  @override
  String current_image_of_total(Object currentImage, Object totalImages) {
    return '$currentImage/$totalImages';
  }

  @override
  String get video_unavailable => 'वीडियो उपलब्ध नहीं';

  @override
  String get find_vehicles_drivers => 'सही वाहन और ड्राइवर खोजें';

  @override
  String get use_current_location => 'वर्तमान स्थान का उपयोग करें';

  @override
  String get you => 'आप';

  @override
  String get suggestions => 'सुझाव';

  @override
  String get choose_vehicle_type => 'अपना वाहन प्रकार चुनें';

  @override
  String get select_vehicle_option =>
      'वह विकल्प चुनें जो आपके वाहन का सबसे अच्छा वर्णन करता है';

  @override
  String get become_driver_transporter => 'ड्राइवर/ट्रांसपोर्टर बनें';

  @override
  String get price_example => '₹170.71';

  @override
  String get subscribe_now => 'अभी सदस्यता लें';

  @override
  String failed_to_load_more_vehicles(Object error) {
    return 'अधिक वाहन लोड करने में विफल: $error';
  }

  @override
  String failed_to_refresh(Object error) {
    return 'ताज़ा करने में विफल: $error';
  }

  @override
  String get could_not_launch_phone => 'फोन ऐप लॉन्च नहीं कर सका';

  @override
  String seats_count(Object seats) {
    return '$seats';
  }

  @override
  String get min_charge => 'न्यूनतम शुल्क';

  @override
  String get no_vehicles_found => 'उफ़! हमें कोई वाहन नहीं मिला।';

  @override
  String get try_changing_location =>
      '🔍 स्थान बदलने या अन्य श्रेणियों को एक्सप्लोर करने का प्रयास करें।';

  @override
  String get no_more_vehicles => 'और कोई वाहन नहीं';

  @override
  String get view_more_vehicles => 'अधिक वाहन देखें';

  @override
  String vehicle_details_title(Object vehicleName) {
    return '$vehicleName विवरण';
  }

  @override
  String short_id(Object shortId) {
    return 'आईडी: $shortId';
  }

  @override
  String get about_colon => 'के बारे में';

  @override
  String get min_charge_colon => 'न्यूनतम शुल्क';

  @override
  String get swipe_navigate_instructions =>
      'नेविगेट करने के लिए स्वाइप करें • ज़ूम करने के लिए पिंच करें';

  @override
  String get continue_co => 'जारी रखें';

  @override
  String get phone_number_10_digits => 'Phone number must be 10 digits';

  @override
  String get only_digits_allowed => 'Only digits are allowed';

  @override
  String get enter_code_whatsapp =>
      'वह कोड दर्ज करें जो आपके WhatsApp नंबर पर भेजा गया था';

  @override
  String get enter_valid_email => 'कृपया एक मान्य ईमेल पता दर्ज करें';

  @override
  String get by_continuing_agree_to => 'जारी रखते हुए, आप सहमत होते हैं';

  @override
  String get and => 'और';

  @override
  String get explore => 'एक्सप्लोर';

  @override
  String get dashboard => 'डैशबोर्ड';

  @override
  String get category => 'श्रेणी';

  @override
  String get home => 'होम';

  @override
  String get car => 'कार';

  @override
  String get auto => 'ऑटो';

  @override
  String get eRickshaw => 'ई-रिक्शा';

  @override
  String get suv => 'एसयूवी';

  @override
  String get minivan => 'मिनिवैन';

  @override
  String get bus => 'बस';

  @override
  String get driver => 'ड्राइवर';

  @override
  String fieldRequired(Object fieldName) {
    return '$fieldName आवश्यक है';
  }

  @override
  String get profilePhoto => 'प्रोफ़ाइल फ़ोटो';

  @override
  String get firstName => 'प्रथम नाम';

  @override
  String get emailAddress => 'ईमेल';

  @override
  String get phoneNumber => 'फ़ोन नंबर';

  @override
  String get allVehicles => 'सभी वाहन';

  @override
  String get youAreCurrentlyHere => 'आप वर्तमान में यहाँ हैं';

  @override
  String get howItWorks => 'कैसे काम करता है';

  @override
  String get stepSearch => 'आसपास या वैश्विक सवारी खोजें';

  @override
  String get stepContact => 'संपर्क करें और विवरण की पुष्टि करें';

  @override
  String get stepEnjoy => 'एक आरामदायक सवारी का आनंद लें!';

  @override
  String get directContact => 'सीधा संपर्क।';

  @override
  String get noCommission => 'कोई कमीशन नहीं।';

  @override
  String get poweredByBuntyBhai => 'बंटी भाई द्वारा संचालित';

  @override
  String get tapToChangeLocation => 'स्थान बदलने के लिए टैप करें';

  @override
  String get seats => 'सीटें';

  @override
  String get searchLocation => 'स्थान खोजें';

  @override
  String get standAloneDriver => 'स्टैंड अलोन ड्राइवर';

  @override
  String get autoRickshaw => 'ऑटो रिक्शा';

  @override
  String get eRickshawt => 'ई-रिक्शा';

  @override
  String get transporter => 'ट्रांसपोर्टर';

  @override
  String get locationNotInIndia => 'यह स्थान भारत में नहीं है';

  @override
  String get addressNotAvailable => 'पता उपलब्ध नहीं है';

  @override
  String get selectLocationFirst => 'कृपया पहले एक स्थान चुनें';

  @override
  String get fixedPrice => 'निर्धारित मूल्य';

  @override
  String get pleaseTryAgainLater => 'कृपया बाद में पुनः प्रयास करें';

  @override
  String get categoryNotFoundMessage =>
      'उफ़! हम आपके चुने हुए स्थान पर यह श्रेणी नहीं ढूंढ सके। हम तेज़ी से विस्तार कर रहे हैं—बने रहें!';

  @override
  String get idLabel => 'पहचान संख्या';

  @override
  String get about => 'परिचय';

  @override
  String get vehicle_name => 'वाहन का नाम';

  @override
  String get type => 'प्रकार';

  @override
  String get mileage => 'माइलेज';

  @override
  String mileage_value(Object value) {
    return '$value कि.मी./ली.';
  }

  @override
  String get not_specified => 'निर्दिष्ट नहीं';

  @override
  String get seating_capacity => 'बैठने की क्षमता';

  @override
  String seating_capacity_value(Object value) {
    return '$value व्यक्ति';
  }

  @override
  String get pricingAndAvailability => 'मूल्य और उपलब्धता';

  @override
  String get priceType => 'मूल्य प्रकार';

  @override
  String get rating => 'रेटिंग';

  @override
  String get writeYourReviewHere => 'अपनी समीक्षा यहाँ लिखें...';

  @override
  String get review => 'समीक्षा';

  @override
  String get submitting => 'जमा किया जा रहा है...';

  @override
  String get submitReview => 'समीक्षा सबमिट करें';

  @override
  String get reviewSubmittedSuccessfully => 'समीक्षा सफलतापूर्वक सबमिट हो गई';

  @override
  String get reviewDeletedSuccessfully => 'समीक्षा सफलतापूर्वक हटाई गई';

  @override
  String get specifications => 'विशेष विवरण';

  @override
  String get features => 'विशेषताएँ';

  @override
  String get vehicleVideos => 'वाहन वीडियो';

  @override
  String get experience => 'अनुभव';

  @override
  String get totalReviews => 'कुल समीक्षाएं';

  @override
  String get averageRating => 'औसत रेटिंग';

  @override
  String get ago => 'पहले';

  @override
  String get year => 'साल';

  @override
  String get years => 'साल';

  @override
  String get month => 'महीना';

  @override
  String get months => 'महीने';

  @override
  String get day => 'दिन';

  @override
  String get days => 'दिन';

  @override
  String get hour => 'घंटा';

  @override
  String get hours => 'घंटे';

  @override
  String get minute => 'मिनट';

  @override
  String get minutes => 'मिनट';

  @override
  String get justNow => 'अभी अभी';

  @override
  String get today => 'आज';

  @override
  String get yesterday => 'कल';

  @override
  String get contactPreferences => 'संपर्क वरीयताएँ';

  @override
  String get whatsappNotifications => 'व्हाट्सएप सूचनाएँ';

  @override
  String get whatsappSubtitle => 'व्हाट्सएप के माध्यम से सूचनाएं प्राप्त करें';

  @override
  String get phoneNotifications => 'फोन सूचनाएँ';

  @override
  String get phoneSubtitle =>
      'फोन कॉल/एसएमएस के माध्यम से सूचनाएं प्राप्त करें';

  @override
  String get accountManagement => 'खाता प्रबंधन';

  @override
  String get deleteAccount => 'खाता हटाएं';

  @override
  String get deleteAccountSubtitle => 'स्थायी रूप से अपना खाता हटाएं';

  @override
  String get otherSettings => 'अन्य सेटिंग्स';

  @override
  String get changeLanguage => 'भाषा बदलें';

  @override
  String get comingSoon => 'जल्द आ रहा है';

  @override
  String get deleteAccountDialogTitle => 'खाता हटाएं';

  @override
  String get deleteAccountDialogContent =>
      'यह क्रिया पूर्ववत नहीं की जा सकती। आपका सारा डेटा स्थायी रूप से हट जाएगा और आप अपने खाते तक पहुँच खो देंगे।';

  @override
  String get authenticationError =>
      'प्रमाणीकरण त्रुटि। कृपया फिर से लॉगिन करें।';

  @override
  String get preferencesUpdated => 'वरीयताएँ सफलतापूर्वक अपडेट की गईं';

  @override
  String get failedUpdatePreferences => 'वरीयताएँ अपडेट करने में विफल';

  @override
  String get networkError => 'नेटवर्क त्रुटि। कृपया अपना कनेक्शन जांचें।';

  @override
  String get accountDeleted => 'खाता सफलतापूर्वक हटाया गया';

  @override
  String get failedDeleteAccount => 'खाता हटाने में विफल';

  @override
  String get noCamerasAvailable => 'इस डिवाइस पर कोई कैमरा उपलब्ध नहीं है';

  @override
  String get cameraTitleBlink => 'पलक पहचान वाली कैमरा';

  @override
  String get cameraTitle => 'कैमरा';

  @override
  String get cameraSubtitleBlink => 'एडवांस पहचान के साथ फोटो लें';

  @override
  String get cameraSubtitle => 'नई फोटो लें';

  @override
  String get uploadPromptButton => 'अपलोड करने के लिए यहां क्लिक करें ';

  @override
  String get remove => 'हटाएं';

  @override
  String get sixDigitPinIsRequired => '6 अंकों का पिन आवश्यक है';

  @override
  String pleaseSelectAtLeastOne(Object fieldName) {
    return 'कृपया कम से कम एक $fieldName चुनें';
  }

  @override
  String get pleaseSelectFuelType => 'कृपया ईंधन प्रकार चुनें';

  @override
  String get selectVehicleOwnership => 'वाहन स्वामित्व चुनें';

  @override
  String get fareAndCities => 'किराया और शहर';

  @override
  String get fullName => 'पूरा नाम';

  @override
  String get pleaseSelectState => 'कृपया राज्य चुनें';

  @override
  String get pleaseSelectCity => 'कृपया शहर चुनें';

  @override
  String get pincode => 'पिनकोड';

  @override
  String get allDocumentsVerifiedSuccessfully =>
      'सभी दस्तावेज़ सफलतापूर्वक सत्यापित हो गए हैं!';

  @override
  String get pleaseEnsureAllDocumentsUploadedVerified =>
      'कृपया सुनिश्चित करें कि सभी दस्तावेज़ अपलोड और सत्यापित किए गए हैं।';

  @override
  String get aadhaarNumber => 'आधार नंबर';

  @override
  String get drivingLicense => 'ड्राइविंग लाइसेंस';

  @override
  String get uploaded => 'अपलोडेड';

  @override
  String get yes => 'हाँ';

  @override
  String get no => 'नहीं';

  @override
  String get city => 'शहर';

  @override
  String get state => 'राज्य';

  @override
  String get allDocumentsVerifiedReadyToSubmit =>
      'सभी दस्तावेज़ सत्यापित हो गए हैं! सबमिट करने के लिए तैयार हैं।';

  @override
  String get documentVerificationIncomplete =>
      'दस्तावेज़ सत्यापन अधूरा है। कृपया सबमिट करने से पहले सभी दस्तावेज़ सत्यापित करें।';

  @override
  String get submit => 'सबमिट';

  @override
  String get next => 'आगे';

  @override
  String get vehicleNumber => 'वाहन नंबर';

  @override
  String get no_internet_connection => 'इंटरनेट कनेक्शन नहीं';

  @override
  String get check_internet_connection =>
      'कृपया अपना इंटरनेट कनेक्शन जांचें और फिर से कोशिश करें।';

  @override
  String get server_unavailable_message =>
      'सर्वर वर्तमान में अनुपलब्ध है (502)। कृपया बाद में पुनः प्रयास करें।';

  @override
  String get unable_to_connect_server =>
      'सर्वर से कनेक्ट नहीं हो सका। कृपया अपना कनेक्शन जांचें।';

  @override
  String get request_timeout => 'अनुरोध समय समाप्त';

  @override
  String get request_timeout_message =>
      'अनुरोध को पूरा करने में बहुत समय लगा। कृपया फिर से कोशिश करें।';

  @override
  String get api_error => 'API त्रुटि';

  @override
  String get api_error_message =>
      'डेटा प्राप्त करने में कुछ गलत हुआ। कृपया फिर से कोशिश करें।';

  @override
  String get unexpected_error_message =>
      'एक अप्रत्याशित त्रुटि हुई। कृपया फिर से कोशिश करें।';

  @override
  String get try_again => 'फिर कोशिश करें';

  @override
  String get open_settings => 'सेटिंग्स खोलें';

  @override
  String get check_device_settings => 'कृपया अपनी डिवाइस सेटिंग्स जांचें';

  @override
  String get startDetectionMessage =>
      '\'शुरू करें\' दबाएं पहचान शुरू करने के लिए';

  @override
  String get stopCapturing => 'कैप्चर करना बंद करें';

  @override
  String get startCapturing => 'कैप्चर करना शुरू करें';

  @override
  String get cameraReady => 'कैमरा तैयार है - पहचान शुरू करें';

  @override
  String get cameraInitError => 'त्रुटि: कैमरा प्रारंभ नहीं हो सका';

  @override
  String get positionFace => 'अपने चेहरे को घेरे के अंदर रखें';

  @override
  String get noFaceDetected =>
      'चेहरा नहीं मिला - अपने चेहरे को घेरे के अंदर रखें';

  @override
  String get moveCloser => 'कैमरे के पास आएं';

  @override
  String get blinkToCapture => 'बढ़िया! अब कैप्चर के लिए अपनी आंखें झपकाएं';

  @override
  String get blinkDetected => 'पलक झपकाना पहचाना गया! आंखें खोलना...';

  @override
  String expiresOn(Object date, Object days) {
    return '$date को समाप्त हो रहा है ($days दिन शेष)';
  }

  @override
  String get expiryNotAvailable => 'समाप्ति तिथि उपलब्ध नहीं है';

  @override
  String get planIncludes => 'आपकी योजना में शामिल हैं:';

  @override
  String get paymentOn => 'भुगतान की तिथि';

  @override
  String get chat => 'चैट';

  @override
  String get whatsapp => 'व्हाट्सएप';

  @override
  String get call => 'कॉल';

  @override
  String get views => 'देखे गए';

  @override
  String get messages => 'संदेश';

  @override
  String get calls => 'कॉल';

  @override
  String get clicks => 'क्लिक';

  @override
  String get vehicleAdded => 'वाहन जोड़ा गया';

  @override
  String get listed => 'सूचीबद्ध';

  @override
  String get unlisted => 'असूचीबद्ध';

  @override
  String get hire_vehicle => 'वाहन किराए पर लें';

  @override
  String get all_Services => 'All Services';

  @override
  String get hire_driver => 'ड्राइवर किराए पर लें';

  @override
  String get search_by_vehicle_type_city_or_car_code =>
      'वाहन प्रकार, शहर या कार कोड से खोजें';

  @override
  String get available_vehicles_with_driver => 'ड्राइवर के साथ उपलब्ध वाहन';

  @override
  String get become_partner => 'साझेदार बनें';

  @override
  String get around_you => 'आपके आसपास';

  @override
  String get active_drivers_nearby => 'पास के सक्रिय ड्राइवर';

  @override
  String get see_all => 'सभी देखें';

  @override
  String get joinAsPartner => 'साझेदार के रूप में जुड़ें';

  @override
  String get newOpportunities => 'नए अवसर';

  @override
  String get startYourJourney =>
      'हमारे साथ अपनी यात्रा शुरू करें और असीमित कमाई की संभावना को अनलॉक करें। हजारों सफल साझेदारों में शामिल हों।';

  @override
  String get highEarnings => 'उच्च कमाई';

  @override
  String get fastGrowth => 'तेज़ विकास';

  @override
  String get fullSupport => 'पूरा सहयोग';

  @override
  String get activePartners => 'सक्रिय साझेदार';

  @override
  String get monthlyEarnings => 'मासिक कमाई';

  @override
  String get partnerRating => 'साझेदार रेटिंग';

  @override
  String get startPartnershipJourney => 'साझेदारी यात्रा शुरू करें';

  @override
  String get quickApproval => '24 घंटे में त्वरित स्वीकृति';

  @override
  String get partner => 'साझेदार';

  @override
  String get joinOurPartnerNetwork => 'हमारे साझेदार नेटवर्क से जुड़ें';

  @override
  String get partnershipIntro =>
      'अपना पसंदीदा साझेदारी मॉडल चुनें और आज ही कमाई शुरू करें';

  @override
  String get selectPartnershipType => 'अपनी साझेदारी का प्रकार चुनें';

  @override
  String get partnerBenefits => 'साझेदार लाभ';

  @override
  String get transporterOwner => 'परिवहन मालिक';

  @override
  String get independentCarOwner => 'स्वतंत्र कार मालिक';

  @override
  String get autoRickshawOwner => 'ऑटो रिक्शा मालिक';

  @override
  String get eRickshawOwner => 'ई-रिक्शा मालिक';

  @override
  String get earnMore => 'अधिक कमाई';

  @override
  String get earnMoreDesc => 'अपनी कमाई की संभावना को अधिकतम करें';

  @override
  String get easyManagement => 'आसान प्रबंधन';

  @override
  String get easyManagementDesc => 'सरल ऐप-आधारित संचालन';

  @override
  String get trustedPlatform => 'विश्वसनीय प्लेटफ़ॉर्म';

  @override
  String get trustedPlatformDesc => 'हजारों साझेदारों में शामिल हों';

  @override
  String get flexibleWork => 'लचीला कार्य';

  @override
  String get flexibleWorkDesc => 'अपने समय के अनुसार काम करें';

  @override
  String get registrationFees => 'पंजीकरण शुल्क';

  @override
  String get registrationFeesDesc => 'खाता सेटअप के लिए एकमुश्त भुगतान';

  @override
  String get accountSetupFee => 'खाता सेटअप शुल्क';

  @override
  String get accountSetupIncludes => 'सत्यापन और दस्तावेज़ीकरण शामिल';

  @override
  String get chooseYourPlan => 'अपनी योजना चुनें';

  @override
  String get chooseYourPlanDesc => 'अपने व्यवसाय के लिए सबसे अच्छी योजना चुनें';

  @override
  String get perMonth => '/माह';

  @override
  String get reviewsAndRatings => 'समीक्षा और रेटिंग';

  @override
  String get pricing => 'मूल्य निर्धारण';
}
