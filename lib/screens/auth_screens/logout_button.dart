import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:r_w_r/screens/auth_screens/splash_screen.dart';

import '../../constants/color_constants.dart';
import '../../constants/token_manager.dart';
import '../../l10n/app_localizations.dart';
import 'package:path_provider/path_provider.dart';

class LogoutButton extends StatelessWidget {
  const LogoutButton({Key? key}) : super(key: key);

  Future<void> _showLogoutConfirmationDialog(BuildContext context) async {
    final localizations = AppLocalizations.of(context)!;

    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          title: Text(
            localizations.logout,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          content: Text(
            localizations.confirm_logout,
            style: const TextStyle(fontSize: 16),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: Text(
                localizations.cancel,
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 16,
                ),
              ),
            ),
            TextButton(
              onPressed: () async {
                Navigator.of(dialogContext).pop();

                try {
                  showDialog(
                    context: context,
                    barrierDismissible: false,
                    builder: (_) => const Center(
                      child: CircularProgressIndicator(),
                    ),
                  );

                  // Clear data
                  final success = await TokenManager.clearAllData();

                  // Dismiss loading dialog
                  if (context.mounted) Navigator.of(context).pop();

                  if (success && context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(localizations.logged_out_successfully),
                        backgroundColor: Colors.green,
                        behavior: SnackBarBehavior.floating,
                        duration: const Duration(seconds: 2),
                      ),
                    );
                    // final tempDir = await getTemporaryDirectory();
                    // if (tempDir.existsSync()) {
                    //   tempDir.deleteSync(recursive: true);
                    // }
                    Navigator.of(context).pushAndRemoveUntil(
                      MaterialPageRoute(builder: (_) => const SplashScreen()),
                      (route) => false,
                    );
                  } else if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(localizations.failed_to_logout),
                        backgroundColor: Colors.red,
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  }
                } catch (e) {
                  if (context.mounted) {
                    Navigator.of(context).pop(); // Ensure dialog closed
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(localizations.failed_to_logout),
                        backgroundColor: Colors.red,
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  }
                }
              },
              child: Text(
                localizations.logout,
                style: TextStyle(
                  color: ColorConstants.errorColor,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;

    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: ColorConstants.errorColor.withOpacity(0.1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(
          Icons.logout_rounded,
          color: ColorConstants.errorColor,
          size: 24,
        ),
      ),
      title: Text(
        localizations.logout,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w700,
        ),
      ),
      trailing: Icon(
        CupertinoIcons.chevron_forward,
        color: Colors.grey[400],
        size: 20,
      ),
      onTap: () => _showLogoutConfirmationDialog(context),
    );
  }
}
