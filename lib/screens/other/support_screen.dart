import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:r_w_r/constants/color_constants.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../components/app_appbar.dart';
import '../../l10n/app_localizations.dart';
import '../../utils/color.dart';

class SupportPage extends StatefulWidget {
  final String baseUrl;

  const SupportPage({Key? key, required this.baseUrl}) : super(key: key);

  @override
  _SupportPageState createState() => _SupportPageState();
}

class _SupportPageState extends State<SupportPage>
    with SingleTickerProviderStateMixin {
  List<EmailSupport> emails = [];
  ContactInfo? contact;
  bool isLoading = true;
  bool hasError = false;
  String errorMessage = '';
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _fetchSupportData();
  }

  void _initializeAnimations() {
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _fetchSupportData() async {
    try {
      setState(() {
        isLoading = true;
        hasError = false;
        errorMessage = '';
      });

      final uri = Uri.parse('${widget.baseUrl}/session/support');

      final response = await http.get(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ).timeout(
        const Duration(seconds: 30),
        onTimeout: () {
          throw Exception('Request timeout - please check your connection');
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        if (data != null && data is Map<String, dynamic>) {
          if (data['status'] == true && data['data'] != null) {
            final emailsData = data['data']['emails'];
            final contactData = data['data']['contact'];

            setState(() {
              emails = emailsData != null && emailsData is List
                  ? emailsData
                      .map<EmailSupport>(
                          (email) => EmailSupport.fromJson(email))
                      .toList()
                  : [];
              contact = contactData != null
                  ? ContactInfo.fromJson(contactData)
                  : null;
              isLoading = false;
            });

            if (mounted) {
              _animationController.forward();
            }
          } else {
            throw Exception(data['message'] ?? 'Invalid response format');
          }
        } else {
          throw Exception('Invalid JSON response');
        }
      } else {
        throw Exception(
            'Server error (${response.statusCode}): ${response.reasonPhrase}');
      }
    } on SocketException {
      _handleError(
          'No internet connection. Please check your network settings.');
    } on FormatException {
      _handleError('Invalid data format received from server.');
    } on Exception catch (e) {
      _handleError(e.toString().replaceFirst('Exception: ', ''));
    } catch (e) {
      _handleError('An unexpected error occurred. Please try again.');
    }
  }

  void _handleError(String message) {
    if (mounted) {
      setState(() {
        isLoading = false;
        hasError = true;
        errorMessage = message;
      });
    }
  }

  Color _parseColor(String? colorString) {
    if (colorString == null || colorString.isEmpty) return Colors.blue;

    try {
      String cleanColor = colorString.replaceFirst('#', '');
      if (cleanColor.length == 6) {
        return Color(int.parse('0xFF$cleanColor'));
      }
      return Colors.blue;
    } catch (e) {
      return Colors.blue;
    }
  }

  Future<void> _launchEmail(String email, String subject) async {
    try {
      final Uri emailUri = Uri(
        scheme: 'mailto',
        path: email,
        query: 'subject=${Uri.encodeComponent(subject)}',
      );

      if (await canLaunchUrl(emailUri)) {
        await launchUrl(emailUri);
      } else {
        // Fallback to copying to clipboard
        await Clipboard.setData(ClipboardData(text: email));
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  const Icon(Icons.email, color: Colors.white, size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text('Email copied to clipboard: $email'),
                  ),
                ],
              ),
              backgroundColor: Colors.green[600],
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8)),
              duration: const Duration(seconds: 3),
              action: SnackBarAction(
                label: 'OK',
                textColor: Colors.white,
                onPressed: () {},
              ),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Unable to open email client. Email: $email'),
            backgroundColor: Colors.orange[600],
            behavior: SnackBarBehavior.floating,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
        );
      }
    }
  }

  Future<void> _launchPhone(String phone) async {
    try {
      // Clean phone number - remove all non-digit characters except '+'
      String cleanPhone = phone.replaceAll(RegExp(r'[^\d+]'), '');

      final Uri phoneUri = Uri(
        scheme: 'tel',
        path: cleanPhone,
      );

      if (await canLaunchUrl(phoneUri)) {
        await launchUrl(phoneUri);
      } else {
        // Fallback to copying to clipboard
        await Clipboard.setData(ClipboardData(text: cleanPhone));
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  const Icon(Icons.phone, color: Colors.white, size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text('Phone number copied: $cleanPhone'),
                  ),
                ],
              ),
              backgroundColor: Colors.green[600],
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8)),
              duration: const Duration(seconds: 3),
              action: SnackBarAction(
                label: 'OK',
                textColor: Colors.white,
                onPressed: () {},
              ),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Unable to process phone number: $phone'),
            backgroundColor: Colors.orange[600],
            behavior: SnackBarBehavior.floating,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
        );
      }
    }
  }

  Future<void> _copyAddress() async {
    if (contact == null) return;

    try {
      final fullAddress = '${contact!.addressLine1}, ${contact!.addressLine2}';

      // First try to open in Google Maps
      final Uri mapsUri = Uri(
        scheme: 'https',
        host: 'www.google.com',
        path: '/maps/search/',
        queryParameters: {'api': '1', 'query': fullAddress},
      );

      if (await canLaunchUrl(mapsUri)) {
        await launchUrl(
          mapsUri,
          mode: LaunchMode.externalApplication, // Opens in browser/maps app
        );
      } else {
        // Fallback to copying to clipboard
        await Clipboard.setData(ClipboardData(text: fullAddress));
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Row(
                children: [
                  Icon(Icons.location_on, color: Colors.white, size: 20),
                  SizedBox(width: 8),
                  Expanded(child: Text('Address copied to clipboard')),
                ],
              ),
              backgroundColor: Colors.orange[600],
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8)),
              duration: const Duration(seconds: 2),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Unable to open maps or copy address'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: CustomAppBar(
        title: localizations.support_center,
        elevation: 0,
        centerTitle: true,
        systemOverlayStyle: SystemUiOverlayStyle.light,
      ),
      body: RefreshIndicator(
        onRefresh: _fetchSupportData,
        child: _buildBody(),
      ),
    );
  }

  Widget _buildBody() {
    if (isLoading) {
      return _buildLoadingState();
    }

    if (hasError) {
      return _buildErrorState();
    }

    return FadeTransition(
      opacity: _fadeAnimation,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),
            const SizedBox(height: 24),
            if (emails.isNotEmpty) ...[
              _buildEmailSection(),
              const SizedBox(height: 32),
            ],
            if (contact != null) ...[
              _buildContactSection(),
              const SizedBox(height: 24),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingState() {
    final localizations = AppLocalizations.of(context)!;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(
              ColorConstants.primaryColor,
            ),
            strokeWidth: 3,
          ),
          const SizedBox(height: 16),
          Text(
            localizations.loading_support_info,
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState() {
    final localizations = AppLocalizations.of(context)!;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: Colors.red[50],
                borderRadius: BorderRadius.circular(40),
              ),
              child: Icon(
                Icons.error_outline,
                size: 48,
                color: Colors.red[400],
              ),
            ),
            const SizedBox(height: 24),
            Text(
              localizations.something_went_wrong,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.grey[800],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              errorMessage,
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 14,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _fetchSupportData,
                icon: const Icon(Icons.refresh),
                label: Text(localizations.retry),
                style: ElevatedButton.styleFrom(
                  backgroundColor: ColorConstants.primaryColor,
                  foregroundColor: Colors.white,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 2,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    final localizations = AppLocalizations.of(context)!;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            gradientFirst,
            gradientSecond,
            gradientThird,
            Colors.white
          ],
          stops: [0.01, 0.20, 0.31, .34],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: ColorConstants.primaryColor.withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(
            Icons.support_agent,
            size: 48,
            color: Colors.white,
          ),
          SizedBox(height: 16),
          Text(
            localizations.how_can_we_help,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          SizedBox(height: 8),
          Text(
            localizations.choose_support_method,
            style: TextStyle(
              fontSize: 16,
              color: Colors.white70,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildEmailSection() {
    final localizations = AppLocalizations.of(context)!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          localizations.contact_by_email,
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Colors.grey[800],
          ),
        ),
        const SizedBox(height: 16),
        ...emails.asMap().entries.map((entry) {
          int index = entry.key;
          EmailSupport email = entry.value;
          return TweenAnimationBuilder(
            duration: Duration(milliseconds: 600 + (index * 100)),
            tween: Tween<double>(begin: 0.0, end: 1.0),
            builder: (context, double value, child) {
              return Transform.translate(
                offset: Offset(0, 20 * (1 - value)),
                child: Opacity(
                  opacity: value,
                  child: _buildEmailCard(email),
                ),
              );
            },
          );
        }).toList(),
      ],
    );
  }

  Widget _buildEmailCard(EmailSupport email) {
    final cardColor = _parseColor(email.color);
    final localizations = AppLocalizations.of(context)!;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () => _launchEmail(email.email, '${email.type} Inquiry'),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: cardColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(25),
                  ),
                  child: Icon(
                    _getIconForType(email.type),
                    color: cardColor,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        email.type,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey[800],
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        email.email,
                        style: TextStyle(
                          fontSize: 14,
                          color: cardColor,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        email.description,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios,
                  color: Colors.grey[400],
                  size: 16,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildContactSection() {
    if (contact == null) return const SizedBox.shrink();
    final localizations = AppLocalizations.of(context)!;

    return TweenAnimationBuilder(
      duration: const Duration(milliseconds: 800),
      tween: Tween<double>(begin: 0.0, end: 1.0),
      builder: (context, double value, child) {
        return Transform.translate(
          offset: Offset(0, 30 * (1 - value)),
          child: Opacity(
            opacity: value,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  localizations.other_ways_to_contact,
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[800],
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(child: _buildPhoneCard()),
                    const SizedBox(width: 16),
                    Expanded(child: _buildAddressCard()),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildPhoneCard() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () => _launchPhone(contact!.phone),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: Colors.green.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Icon(
                    Icons.phone,
                    color: Colors.green[600],
                    size: 20,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  contact!.phoneTitle,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[800],
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  contact!.phone,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.green[600],
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  contact!.phoneDesc,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAddressCard() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: _copyAddress,
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: Colors.orange.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Icon(
                    Icons.location_on,
                    color: Colors.orange[600],
                    size: 20,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  contact!.addressTitle,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[800],
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  contact!.addressLine1,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[700],
                  ),
                ),
                Text(
                  contact!.addressLine2,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[700],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  IconData _getIconForType(String type) {
    switch (type.toLowerCase()) {
      case 'support':
        return Icons.support_agent;
      case 'sales':
        return Icons.shopping_cart;
      case 'technical':
        return Icons.build;
      default:
        return Icons.email;
    }
  }
}

class EmailSupport {
  final String id;
  final int numId;
  final String type;
  final String email;
  final String description;
  final String color;

  EmailSupport({
    required this.id,
    required this.numId,
    required this.type,
    required this.email,
    required this.description,
    required this.color,
  });

  factory EmailSupport.fromJson(Map<String, dynamic> json) {
    return EmailSupport(
      id: json['_id']?.toString() ?? '',
      numId: json['id'] is int
          ? json['id']
          : int.tryParse(json['id']?.toString() ?? '0') ?? 0,
      type: json['type']?.toString() ?? 'Support',
      email: json['email']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      color: json['color']?.toString() ?? '#3498db',
    );
  }

  @override
  String toString() {
    return 'EmailSupport{id: $id, numId: $numId, type: $type, email: $email, description: $description, color: $color}';
  }
}

class ContactInfo {
  final String phone;
  final String phoneTitle;
  final String phoneDesc;
  final String addressTitle;
  final String addressLine1;
  final String addressLine2;
  final String id;

  ContactInfo({
    required this.phone,
    required this.phoneTitle,
    required this.phoneDesc,
    required this.addressTitle,
    required this.addressLine1,
    required this.addressLine2,
    required this.id,
  });

  factory ContactInfo.fromJson(Map<String, dynamic> json) {
    return ContactInfo(
      phone: json['phone']?.toString() ?? '',
      phoneTitle: json['phoneTitle']?.toString() ?? 'Call Us',
      phoneDesc: json['phoneDesc']?.toString() ?? '',
      addressTitle: json['addressTitle']?.toString() ?? 'Our Office',
      addressLine1: json['addressLine1']?.toString() ?? '',
      addressLine2: json['addressLine2']?.toString() ?? '',
      id: json['_id']?.toString() ?? '',
    );
  }

  @override
  String toString() {
    return 'ContactInfo{phone: $phone, phoneTitle: $phoneTitle, phoneDesc: $phoneDesc, addressTitle: $addressTitle, addressLine1: $addressLine1, addressLine2: $addressLine2, id: $id}';
  }
}
