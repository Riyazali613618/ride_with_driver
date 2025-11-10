import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:r_w_r/api/api_model/language/language_model.dart';
import 'package:r_w_r/l10n/app_localizations.dart'; // Import generated localizations
import 'package:r_w_r/screens/block/language/language_provider.dart';
import 'package:r_w_r/screens/common_screens/language_screen.dart';

class LocalizationTestScreen extends StatelessWidget {
  const LocalizationTestScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final languageProvider = Provider.of<LanguageProvider>(context);
    final localizations = AppLocalizations.of(context)!; // Get localizations

    return Scaffold(
      appBar: AppBar(
        title: Text(localizations.help_support), // Use generated localization
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Language information section
            if (languageProvider.isLoading)
              const Center(child: CircularProgressIndicator())
            else if (languageProvider.error != null)
              Column(
                children: [
                  Text(
                    localizations.error,
                    style: const TextStyle(color: Colors.red, fontSize: 16),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 20),
                  if (languageProvider.currentLanguage != null)
                    _buildLanguageInfo(context,
                        languageProvider.currentLanguage!, localizations),
                ],
              )
            else if (languageProvider.currentLanguage == null)
              Text(
                localizations.video_unavailable,
                style: const TextStyle(fontSize: 16),
              )
            else
              Column(
                children: [
                  _buildLanguageInfo(context, languageProvider.currentLanguage!,
                      localizations),
                  const SizedBox(height: 30),
                  _buildTranslationTest(context, localizations),
                  const SizedBox(height: 30),
                  _buildAllStringsTest(context,
                      languageProvider.currentLanguage!, localizations),
                ],
              ),

            const SizedBox(height: 40),

            // Change language button
            ElevatedButton(
              onPressed: () {
                showModalBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  builder: (context) => const LanguageSelectionScreen(),
                );
              },
              child: Text(localizations.language_settings),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLanguageInfo(
      BuildContext context, Language language, AppLocalizations localizations) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text(
              localizations.change_language(language.name),
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Text(
              localizations.change_language(language.nativeName),
              style: const TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 5),
            Text(
              localizations.language_settings,
              style: const TextStyle(fontSize: 16, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTranslationTest(
      BuildContext context, AppLocalizations localizations) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text(
              localizations.welcome,
              style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 15),
            Text(
              localizations.choose_vehicle_type,
              style: const TextStyle(fontSize: 20),
            ),
            const SizedBox(height: 15),
            Text(
              localizations.last_name,
              style: const TextStyle(fontSize: 18),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAllStringsTest(BuildContext context, Language currentLanguage,
      AppLocalizations localizations) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'All Localized Strings:',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const Divider(),
            const SizedBox(height: 10),

            const SizedBox(height: 20),
            const Text(
              'Strings with placeholders:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const Divider(),
            const SizedBox(height: 10),

            // Strings with placeholders
            _buildTestRow(
                'current_language', localizations.choose_vehicle_type),
            _buildTestRow('native_name',
                localizations.change_language(currentLanguage.nativeName)),
            _buildTestRow('language_code',
                localizations.change_language(currentLanguage.code)),
            _buildTestRow('error_loading_language',
                localizations.error_deleting_review('Sample error message')),
          ],
        ),
      ),
    );
  }

  Widget _buildTestRow(String key, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: Text(
              key,
              style: const TextStyle(
                fontSize: 16,
                color: Colors.blue,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            flex: 3,
            child: Text(
              value,
              style: const TextStyle(fontSize: 16),
            ),
          ),
        ],
      ),
    );
  }
}
