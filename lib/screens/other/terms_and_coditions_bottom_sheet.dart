import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:r_w_r/constants/color_constants.dart';

import '../../api/api_model/term_and_conditions_model/terms_and_conditions_model.dart';
import '../../api/api_service/terms_and_conditions_services/terms_and_conditions_services.dart';
import '../../l10n/app_localizations.dart';

class TermsConditionsBottomSheet extends StatefulWidget {
  final String type;
  final Function(bool)? onAccepted;
  final bool buttonHide;

  const TermsConditionsBottomSheet({
    super.key,
    required this.type,
    this.onAccepted,
    this.buttonHide = false,
  });

  @override
  State<TermsConditionsBottomSheet> createState() =>
      _TermsConditionsBottomSheetState();
}

class _TermsConditionsBottomSheetState
    extends State<TermsConditionsBottomSheet> {
  Future<TermsResponse>? _termsFuture;
  bool _isAccepted = false;

  String _title = '...';

  @override
  void initState() {
    super.initState();
    _termsFuture =
        TermsService.fetchTermsAndConditions(widget.type).then((value) {
      if (value.status) {
        setState(() {
          _title = value.data.title!;
        });
      }
      return value;
    });
  }

  void _retryFetch() {
    setState(() {
      _termsFuture =
          TermsService.fetchTermsAndConditions(widget.type).then((value) {
        if (value.status) {
          setState(() {
            _title = value.data.title;
          });
        }
        return value;
      });
    });
  }

  void _handleAccept() {
    final localizations = AppLocalizations.of(context)!;

    if (_isAccepted) {
      widget.onAccepted?.call(true);
      Navigator.of(context).pop(true);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(localizations.accept_to_continue),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  bool get _showAcceptSection =>
      widget.type.toUpperCase() != 'USER' && !widget.buttonHide;

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    final text = localizations.read_and_agree;
    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.7,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      builder: (context, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              // Handle bar
              Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),

              // Header
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        _title,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.of(context).pop(false),
                      icon: const Icon(Icons.close),
                      iconSize: 20,
                    ),
                  ],
                ),
              ),

              const Divider(height: 1),

              // Main content area
              Expanded(
                child: FutureBuilder<TermsResponse>(
                  future: _termsFuture,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const CircularProgressIndicator(),
                            const SizedBox(height: 5),
                            Text(
                              localizations.loading,
                              style: TextStyle(
                                color: ColorConstants.primaryColor,
                              ),
                            ),
                          ],
                        ),
                      );
                    }

                    if (snapshot.hasError) {
                      return Center(
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.error_outline,
                                size: 48,
                                color: Colors.red[300],
                              ),
                              const SizedBox(height: 16),
                              Text(
                                localizations.failed_to_load_data,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                snapshot.error.toString(),
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey[600],
                                ),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 16),
                              SizedBox(
                                width: double.infinity,
                                child: ElevatedButton.icon(
                                  onPressed: _retryFetch,
                                  icon: const Icon(Icons.refresh),
                                  label: Text(localizations.check_internet_and_retry),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: ColorConstants.primaryColor,
                                    foregroundColor: Colors.white,
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 24, vertical: 16),
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

                    if (snapshot.hasData) {
                      final termsData = snapshot.data!;

                      if (!termsData.status) {
                        return Center(
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(
                                  Icons.description_outlined,
                                  size: 48,
                                  color: Colors.grey,
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  localizations.no_data_available,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    color: Colors.grey,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      }

                      // ✅ FIXED LAYOUT SECTION STARTS HERE
                      return Column(
                        children: [
                          // Scrollable HTML content
                          Expanded(
                            child: SingleChildScrollView(
                              controller: scrollController,
                              padding: const EdgeInsets.all(16),
                              child: Html(
                                data: termsData.data.content,
                                style: {
                                  "body": Style(
                                    margin: Margins.zero,
                                    padding: HtmlPaddings.zero,
                                  ),
                                  "p": Style(
                                    fontSize: FontSize(16),
                                    lineHeight: const LineHeight(1.5),
                                    margin: Margins.only(bottom: 12),
                                  ),
                                  "h1, h2, h3, h4, h5, h6": Style(
                                    fontWeight: FontWeight.bold,
                                    margin: Margins.only(top: 16, bottom: 8),
                                  ),
                                  "ul, ol": Style(
                                    margin: Margins.only(bottom: 12, left: 16),
                                  ),
                                  "li": Style(
                                    margin: Margins.only(bottom: 4),
                                  ),
                                  "a": Style(
                                    color: Theme.of(context).primaryColor,
                                    textDecoration: TextDecoration.underline,
                                  ),
                                },
                                onLinkTap: (url, attributes, element) {
                                  debugPrint('Link tapped: $url');
                                },
                              ),
                            ),
                          ),

                          // Accept section (no extra space anymore)
                          if (_showAcceptSection) ...[
                            const Divider(height: 1, thickness: 1),
                            Padding(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                children: [
                                  Row(
                                    children: [
                                      Checkbox(
                                        activeColor: ColorConstants.primaryColor,
                                        value: _isAccepted,
                                        onChanged: (bool? value) {
                                          setState(() {
                                            _isAccepted = value ?? false;
                                          });
                                        },
                                      ),
                                      Expanded(
                                        child: Text(
                                          text,
                                          style: const TextStyle(fontSize: 14),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 16),
                                  SizedBox(
                                    width: double.infinity,
                                    child: ElevatedButton(
                                      onPressed: _handleAccept,
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: _isAccepted
                                            ? ColorConstants.primaryColor
                                            : Colors.grey[300],
                                        foregroundColor: _isAccepted
                                            ? Colors.white
                                            : Colors.grey[600],
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 16),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                      ),
                                      child: Text(
                                        localizations.accept,
                                        style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ],
                      );
                      // ✅ FIXED LAYOUT SECTION ENDS HERE
                    }

                    return const SizedBox.shrink();
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
