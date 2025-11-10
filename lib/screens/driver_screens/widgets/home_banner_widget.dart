import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../l10n/app_localizations.dart';
import '../../block/home/home_provider.dart';

class BannerListScreenWithProvider extends StatefulWidget {
  final bool showFirstItem;
  final VoidCallback? onFirstItemTap;

  const BannerListScreenWithProvider({
    super.key,
    this.showFirstItem = false,
    this.onFirstItemTap,
  });

  @override
  _BannerListScreenWithProviderState createState() =>
      _BannerListScreenWithProviderState();
}

class _BannerListScreenWithProviderState
    extends State<BannerListScreenWithProvider> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<HomeDataProvider>(context, listen: false).fetchHomeData();
    });
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;

    return Consumer<HomeDataProvider>(
      builder: (context, homeDataProvider, child) {
        if (homeDataProvider.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (homeDataProvider.error != null &&
            homeDataProvider.banners.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(' ${homeDataProvider.error}'),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => homeDataProvider.fetchHomeData(),
                  child: Text(localizations.retry),
                ),
              ],
            ),
          );
        }

        if (homeDataProvider.banners.isEmpty) {
          return const SizedBox.shrink();
        }

        return ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: homeDataProvider.banners.length,
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          itemBuilder: (context, index) {
            final bannerUrl = homeDataProvider.banners[index];

            // Only make the first item conditionally visible and tappable
            if (index == 0) {
              return Visibility(
                visible: widget.showFirstItem,
                child: GestureDetector(
                  onTap: widget.onFirstItemTap,
                  child: _buildBannerItem(bannerUrl),
                ),
              );
            }

            // Other items remain normal
            return _buildBannerItem(bannerUrl);
          },
        );
      },
    );
  }

  Widget _buildBannerItem(String bannerUrl) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Card(
        elevation: 3,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Image.network(
            bannerUrl,
            fit: BoxFit.cover,
            width: double.infinity,
            loadingBuilder: (context, child, loadingProgress) {
              if (loadingProgress == null) return child;
              return Container(
                height: 150,
                alignment: Alignment.center,
                child: CircularProgressIndicator(
                  value: loadingProgress.expectedTotalBytes != null
                      ? loadingProgress.cumulativeBytesLoaded /
                          (loadingProgress.expectedTotalBytes ?? 1)
                      : null,
                ),
              );
            },
            errorBuilder: (context, error, stackTrace) {
              print('Failed to load image: $bannerUrl, error: $error');
              return const SizedBox.shrink();
            },
          ),
        ),
      ),
    );
  }
}
