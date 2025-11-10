import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:r_w_r/constants/color_constants.dart';

import '../../components/app_appbar.dart';
import '../../constants/api_constants.dart';
import '../../constants/token_manager.dart';
import '../../l10n/app_localizations.dart';
import '../../utils/color.dart';
import '../block/language/language_repo.dart';

class FAQItem {
  final String id;
  final String question;
  final String answer;
  final int order;

  FAQItem({
    required this.id,
    required this.question,
    required this.answer,
    required this.order,
  });

  factory FAQItem.fromJson(Map<String, dynamic> json) {
    return FAQItem(
      id: json['_id'] ?? '',
      question: json['question'] ?? '',
      answer: json['answer'] ?? '',
      order: json['order'] ?? 0,
    );
  }
}

class FAQResponse {
  final bool status;
  final String message;
  final String title;
  final List<FAQItem> faqs;

  FAQResponse({
    required this.status,
    required this.message,
    required this.title,
    required this.faqs,
  });

  factory FAQResponse.fromJson(Map<String, dynamic> json) {
    var faqList = <FAQItem>[];
    if (json['data'] != null && json['data']['content'] != null) {
      var content = json['data']['content'] as List;
      faqList = content.map((item) => FAQItem.fromJson(item)).toList();
      // Sort by order
      faqList.sort((a, b) => a.order.compareTo(b.order));
    }

    return FAQResponse(
      status: json['status'] ?? false,
      message: json['message'] ?? '',
      title: json['data']?['title'] ?? 'FAQ',
      faqs: faqList,
    );
  }
}

class FAQService {
  static const String baseUrl = ApiConstants.baseUrl;
  static final LanguageRepository _languageRepository = LanguageRepository();

  static Future<FAQResponse> fetchFAQ() async {
    try {
      final token = await TokenManager.getToken();
      final currentLanguage = await _languageRepository.getCurrentLanguage();
      final language = currentLanguage?.code ?? 'en';

      final response = await http.get(
        Uri.parse('$baseUrl/faq'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      ).timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonData = json.decode(response.body);
        return FAQResponse.fromJson(jsonData);
      } else {
        throw Exception('Failed to load FAQ: ${response.statusCode}');
      }
    } on SocketException catch (_) {
      throw Exception('No Internet connection');
    } on TimeoutException catch (_) {
      throw Exception('Request timed out');
    } catch (e) {
      // This catches other unexpected errors
      throw Exception('Unexpected error: $e');
    }
  }

}

// FAQ Screen
class FAQScreen extends StatefulWidget {
  const FAQScreen({Key? key}) : super(key: key);

  @override
  State<FAQScreen> createState() => _FAQScreenState();
}

class _FAQScreenState extends State<FAQScreen> {
  late Future<FAQResponse> _faqFuture;
  int? _expandedIndex;

  @override
  void initState() {
    super.initState();
    _faqFuture = FAQService.fetchFAQ();
  }

  void _refreshFAQ() {
    setState(() {
      _faqFuture = FAQService.fetchFAQ();
      _expandedIndex = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
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
        ),
        child: SafeArea( // ✅ so it doesn’t overlap with status bar
          child: Column(
            children: [
              // /// AppBar inside body
              // CustomAppBar(
              //   elevation: 0,
              //   title: localizations.help_support,
              //   centerTitle: true,
              // ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(
                        Icons.arrow_back_ios,
                        color: ColorConstants.white,
                      ),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            localizations.help_support,
                            style: TextStyle(
                              color: ColorConstants.white,
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              /// Body content
              Expanded(
                child: FutureBuilder<FAQResponse>(
                  future: _faqFuture,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return _buildLoadingWidget();
                    } else if (snapshot.hasError) {
                      return _buildErrorWidget(snapshot.error.toString());
                    } else if (snapshot.hasData) {
                      final faqResponse = snapshot.data!;
                      if (!faqResponse.status || faqResponse.faqs.isEmpty) {
                        return _buildEmptyWidget();
                      }
                      return _buildFAQList(faqResponse);
                    } else {
                      return _buildEmptyWidget();
                    }
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );

  }

  Widget _buildLoadingWidget() {
    final localizations = AppLocalizations.of(context)!;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            valueColor:
                AlwaysStoppedAnimation<Color>(ColorConstants.primaryColor),
            strokeWidth: 3,
          ),
          SizedBox(height: 16),
          Text(
            localizations.loading_faq,
            style: TextStyle(
              color: Colors.grey,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorWidget(String error) {
    final localizations = AppLocalizations.of(context)!;
    print("error we got:${error}");
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: Colors.red[300],
            ),
            const SizedBox(height: 16),
            Text(
              localizations.oops_something_wrong,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.grey[800],
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              error.contains('Network')
                  ? localizations.check_internet_and_retry
                  : localizations.no_faq_available,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _refreshFAQ,
              icon: const Icon(Icons.refresh, size: 20),
              label: Text(localizations.retry),
              style: ElevatedButton.styleFrom(
                backgroundColor: ColorConstants.primaryColor,
                foregroundColor: Colors.white,
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyWidget() {
    final localizations = AppLocalizations.of(context)!;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.help_outline,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              localizations.no_faq_available,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.grey[800],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              localizations.faq_content_coming,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            TextButton.icon(
              onPressed: _refreshFAQ,
              icon: const Icon(Icons.refresh, size: 20),
              label: Text(localizations.refresh),
              style: TextButton.styleFrom(
                foregroundColor: ColorConstants.primaryColor,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFAQList(FAQResponse faqResponse) {
    final localizations = AppLocalizations.of(context)!;

    return Column(
      children: [
        // Header Section
        Padding(
          padding: const EdgeInsets.only(left: 16,top: 8,right: 16,bottom: 8),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: const Border(
                bottom: BorderSide(color: Color(0xFFE0E0E0), width: 1),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  faqResponse.title,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  localizations.find_answers,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 16),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: ColorConstants.primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    ' ${localizations.questions_count(faqResponse.faqs.length)}',
                    style: const TextStyle(
                      color: ColorConstants.primaryColor,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        // FAQ List
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.only(top: 8),
            itemCount: faqResponse.faqs.length,
            itemBuilder: (context, index) {
              return _buildFAQItem(faqResponse.faqs[index], index);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildFAQItem(FAQItem faq, int index) {
    final isExpanded = _expandedIndex == index;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Theme(
        data: Theme.of(context).copyWith(
          dividerColor: Colors.transparent,
          expansionTileTheme: const ExpansionTileThemeData(
            tilePadding: EdgeInsets.zero,
            childrenPadding: EdgeInsets.zero,
          ),
        ),
        child: ExpansionTile(
          key: Key(faq.id),
          initiallyExpanded: false,
          onExpansionChanged: (expanded) {
            setState(() {
              _expandedIndex = expanded ? index : null;
            });
          },
          tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          leading: Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: isExpanded
                  ? ColorConstants.primaryColor
                  : ColorConstants.primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Center(
              child: Text(
                '${index + 1}',
                style: TextStyle(
                  color:
                      isExpanded ? Colors.white : ColorConstants.primaryColor,
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
            ),
          ),
          title: Text(
            faq.question,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: isExpanded ? ColorConstants.primaryColor : Colors.black87,
              height: 1.3,
            ),
          ),
          trailing: AnimatedRotation(
            turns: isExpanded ? 0.5 : 0,
            duration: const Duration(milliseconds: 200),
            child: Icon(
              Icons.keyboard_arrow_down,
              color:
                  isExpanded ? ColorConstants.primaryColor : Colors.grey[600],
              size: 24,
            ),
          ),
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 4,
                    height: 20,
                    decoration: BoxDecoration(
                      color: ColorConstants.primaryColor,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      faq.answer,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[700],
                        height: 1.5,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
