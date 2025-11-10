import 'package:flutter/cupertino.dart';
import 'package:url_launcher/url_launcher.dart';

Future<void> openWhatsApp(String phoneNumber) async {
  final Uri whatsappUri = Uri.parse("https://wa.me/$phoneNumber");

  if (await canLaunchUrl(whatsappUri)) {
    await launchUrl(whatsappUri, mode: LaunchMode.externalApplication);
  } else {
    debugPrint("❌ Could not launch WhatsApp");
  }
}

Future<void> dialPhoneNumber(String phoneNumber) async {
  final Uri telUri = Uri(scheme: 'tel', path: phoneNumber);

  if (await canLaunchUrl(telUri)) {
    await launchUrl(telUri);
  } else {
    debugPrint("❌ Could not launch dialer");
  }
}
