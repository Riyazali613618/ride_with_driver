import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:r_w_r/api/api_model/language/language_model.dart';
import 'package:r_w_r/constants/color_constants.dart';
import 'package:r_w_r/l10n/app_localizations.dart';
import 'package:r_w_r/screens/layout.dart';

import '../block/language/language_provider.dart';

class LanguageSelectionScreen extends StatelessWidget {
  const LanguageSelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const _LanguageSelectionView();
  }
}

class _LanguageSelectionView extends StatefulWidget {
  const _LanguageSelectionView({Key? key}) : super(key: key);

  @override
  State<_LanguageSelectionView> createState() => _LanguageSelectionViewState();
}

class _LanguageSelectionViewState extends State<_LanguageSelectionView> {
  Language? _selectedLanguage;
  bool _initialized = false;

  @override
  void initState() {
    super.initState();
    _initializeSelectedLanguage();
  }

  Future<void> _initializeSelectedLanguage() async {
    final languageProvider =
    Provider.of<LanguageProvider>(context, listen: false);
    _selectedLanguage = languageProvider.currentLanguage;
    setState(() => _initialized = true);
  }

  @override
  Widget build(BuildContext context) {
    if (!_initialized) {
      return const Center(child: CircularProgressIndicator());
    }

    final languageProvider = Provider.of<LanguageProvider>(context);
    final localizations = AppLocalizations.of(context)!;

    return Container(
      decoration: BoxDecoration(
        color: ColorConstants.backgroundColor,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 10),
            // Close button
            Align(
              alignment: Alignment.topRight,
              child: IconButton(
                icon: const Icon(
                  Icons.close,
                  color: ColorConstants.primaryColor,
                  size: 30,
                ),
                onPressed: languageProvider.isLoading
                    ? null
                    : () => Navigator.pop(context),
              ),
            ),

            // Title
            Text(
              localizations.language,
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: ColorConstants.textColor,
              ),
            ),
            const SizedBox(height: 8),

            // Subtitle
            Text(
              localizations.language_spoken,
              style: TextStyle(
                fontSize: 16,
                color: ColorConstants.textColor.withOpacity(0.7),
              ),
            ),
            const SizedBox(height: 30),

            // Loading indicator when changing language
            if (languageProvider.isLoading) _buildLoadingWidget(localizations),

            // Error message
            if (languageProvider.error != null)
              _buildErrorWidget(languageProvider.error!, localizations),

            // Language list
            Expanded(
              child: AbsorbPointer(
                absorbing: languageProvider.isLoading,
                child: Opacity(
                  opacity: languageProvider.isLoading ? 0.6 : 1.0,
                  child: ListView.builder(
                    physics: const BouncingScrollPhysics(),
                    itemCount: languageProvider.languages.length,
                    itemBuilder: (context, index) {
                      final language = languageProvider.languages[index];
                      final isSelected =
                          language.code == _selectedLanguage?.code;

                      return Container(
                        margin: const EdgeInsets.symmetric(vertical: 8),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 10,
                              offset: const Offset(0, 2),
                            ),
                          ],
                          border: Border.all(
                            color: isSelected
                                ? ColorConstants.primaryColor
                                : Colors.transparent,
                            width: 2,
                          ),
                        ),
                        child: RadioListTile<Language>(
                          value: language,
                          groupValue: _selectedLanguage,
                          onChanged: languageProvider.isLoading
                              ? null
                              : (Language? value) {
                            if (value != null) {
                              setState(() => _selectedLanguage = value);
                            }
                          },
                          title: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                language.name,
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: ColorConstants.textColor,
                                ),
                              ),
                              Text(
                                language.nativeName,
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                  color: ColorConstants.primaryColor,
                                ),
                              ),
                            ],
                          ),
                          activeColor: ColorConstants.primaryColor,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 2,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),

            // Change Language Button
            GestureDetector(
              onTap: () => _handleLanguageChange(context),
              child: Container(
                height: 50,
                decoration: BoxDecoration(
                  color: ColorConstants.primaryColor,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Text(
                    localizations.change_language(""),
                    style: TextStyle(color: ColorConstants.white),
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingWidget(AppLocalizations localizations) {
    return Container(
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.blue.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          const SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
          const SizedBox(width: 12),
          Text(localizations.change_language("")),
        ],
      ),
    );
  }

  Widget _buildErrorWidget(String error, AppLocalizations localizations) {
    return Container(
      padding: const EdgeInsets.all(12),
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.red.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.red),
      ),
      child: Row(
        children: [
          const Icon(Icons.error_outline, color: Colors.red),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              localizations.search_error(error),
              style: const TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _handleLanguageChange(BuildContext context) async {
    final languageProvider =
    Provider.of<LanguageProvider>(context, listen: false);
    final localizations = AppLocalizations.of(context)!;

    if (languageProvider.isLoading || _selectedLanguage == null) return;

    if (_selectedLanguage!.code != languageProvider.currentLanguage?.code || _selectedLanguage!.code == 'en') {
      await languageProvider.changeLanguage(_selectedLanguage!);

      if (languageProvider.error == null && context.mounted) {
        Navigator.pop(context);
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const Layout()),
        );

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Language changed to ${_selectedLanguage!.name}',
              style: const TextStyle(fontSize: 16),
            ),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 2),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } else if (context.mounted) {
      Navigator.pop(context);
    }
  }
}