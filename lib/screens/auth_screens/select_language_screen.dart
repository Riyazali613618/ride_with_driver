import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';
import 'package:rwd/api/api_model/language/language_model.dart';
import 'package:rwd/constants/api_constants.dart';
import 'package:rwd/constants/color_constants.dart';
import 'package:rwd/screens/auth_screens/login_screen.dart';
import 'package:rwd/screens/layout.dart';
import 'package:rwd/l10n/app_localizations.dart';
import 'package:rwd/api/api_model/languageModel.dart' as lm;
import 'package:rwd/utils/common_utils.dart';
import '../../utils/color.dart';
import '../block/language/language_provider.dart';

class LanguageSelectionScreen extends StatefulWidget {
  final bool isRegistration;

  const LanguageSelectionScreen({this.isRegistration = false, super.key});

  @override
  State<LanguageSelectionScreen> createState() =>
      _LanguageSelectionScreenState();
}

class _LanguageSelectionScreenState extends State<LanguageSelectionScreen> {
  Language? selectedLanguage;
  bool _initialized = false;
  List<lm.Data> langData = [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeSelectedLanguage();
    });
  }

  Future<void> _initializeSelectedLanguage() async {
    final languageProvider =
        Provider.of<LanguageProvider>(context, listen: false);
    selectedLanguage = languageProvider.currentLanguage;
    languageProvider.fetchLanguagesFromApi();
    if (mounted) {
      setState(() => _initialized = true);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_initialized) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final provider = Provider.of<LanguageProvider>(context);
    final localizations = AppLocalizations.of(context);

    return Scaffold(
      body: Container(
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
            stops: [0.0, 0.15, 0.30, .90],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: provider.isLoading
                          ? null
                          : () => Navigator.of(context).pop(),
                      child: const Icon(
                        Icons.arrow_back,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 16),
                    const Icon(
                      Icons.language,
                      color: Colors.white,
                      size: 28,
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'Language',
                      style:  TextStyle(
                        fontFamily: AppConstants.ptSansFont,
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Loading indicator
              if (provider.isLoading)
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 16),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.9),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        localizations?.change_language("") ??
                            'Changing language...',
                        style: const TextStyle(fontSize: 16),
                      ),
                    ],
                  ),
                ),

              // Error message
              if (provider.error != null)
                Container(
                  margin:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  padding: const EdgeInsets.all(12),
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
                          provider.error!,
                          style: const TextStyle(color: Colors.red),
                        ),
                      ),
                    ],
                  ),
                ),

              const SizedBox(height: 20),

              // Language List
              Expanded(
                child: AbsorbPointer(
                  absorbing: provider.isLoading,
                  child: Opacity(
                    opacity: provider.isLoading ? 0.6 : 1.0,
                    child: Container(
                      margin: const EdgeInsets.symmetric(horizontal: 16),
                      child: ListView.builder(
                        itemCount: provider.languages.length,
                        itemBuilder: (context, index) {
                          final language = provider.languages[index];
                          final isSelected =
                              selectedLanguage?.code == language.code;

                          return Container(
                            margin: const EdgeInsets.only(bottom: 12),
                            decoration: BoxDecoration(
                              color:
                                  isSelected ? Color(0x1F641BB4) : Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              border: isSelected
                                  ? Border.all(color: Colors.purple, width: 2)
                                  : null,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.1),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            foregroundDecoration: isSelected
                                ? BoxDecoration(
                                    color: Colors.purple.withOpacity(0.15),
                                    borderRadius: BorderRadius.circular(16),
                                  )
                                : null,
                            child: ListTile(
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 20,
                                vertical: 8,
                              ),
                              leading: Container(
                                width: 48,
                                height: 48,
                                decoration: BoxDecoration(
                                  color: Colors.grey.shade100,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: const Icon(
                                  Icons.translate,
                                  color: Colors.black87,
                                  size: 24,
                                ),
                              ),
                              title: Text(
                                language.name,
                                style:CommonUtils.commonTitleStyle(fontSize: 16)
                              ),
                              subtitle: Text(
                                language.nativeName,
                                style: TextStyle(
                                  fontSize: 12,
                                  fontFamily: AppConstants.ptSansFont,
                                  color: Colors.grey.shade600,
                                  fontWeight: FontWeight.w400,
                                ),
                              ),
                              trailing: Container(
                                width: 32,
                                height: 32,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: isSelected
                                      ? const Color(0xFF8B5CF6)
                                      : Colors.grey.shade300,
                                ),
                                child: isSelected
                                    ? const Icon(
                                        Icons.check,
                                        color: Colors.white,
                                        size: 20,
                                      )
                                    : null,
                              ),
                              onTap: provider.isLoading
                                  ? null
                                  : () async {
                                      setState(() {
                                        selectedLanguage = language;
                                      });
                                    },
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ),
              ),
              GestureDetector(
                onTap: () async {
                  if (selectedLanguage != null) {
                    await _handleLanguageChange(context, selectedLanguage!);
                  }
                },
                child: Container(
                  alignment: Alignment.center,
                  width: MediaQuery.of(context).size.width,
                  decoration: BoxDecoration(
                      color: ColorConstants.primaryColor,
                      borderRadius: BorderRadius.all(Radius.circular(10))),
                  margin: EdgeInsets.only(left: 20, right: 20, bottom: 20),
                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                  child: Text(
                    "Continue",
                    style: TextStyle(
                        fontFamily: AppConstants.ptSansFont,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: Colors.white),
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _handleLanguageChange(
      BuildContext context, Language language) async {
    final languageProvider =
        Provider.of<LanguageProvider>(context, listen: false);

    if (languageProvider.isLoading) return;

    if (language.code != languageProvider.currentLanguage?.code ||
        language.code == 'en') {
      await languageProvider.changeLanguage(language);

      if (languageProvider.error == null && context.mounted) {
        langData = languageProvider.language!;

        if (langData.isNotEmpty) {
          for (var lang in langData) {
            if (languageProvider.currentLanguage?.code == lang.code) {
              print(
                  "langData:${lang.id} ${languageProvider.currentLanguage?.code}");
              languageProvider.setLangCode(lang.id!);
              Navigator.of(context).pop();
              return;
            }
          }
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Language changed to ${language.name}',
              style: const TextStyle(fontSize: 16),
            ),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 2),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }
}
