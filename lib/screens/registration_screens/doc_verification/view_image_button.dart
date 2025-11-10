import 'package:flutter/material.dart';
import 'package:r_w_r/constants/color_constants.dart';

class ImagePreviewWidget extends StatelessWidget {
  final List<String> imageUrls; // Support both single and multiple images
  final double iconSize;

  const ImagePreviewWidget({
    required this.imageUrls,
    this.iconSize = 24,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Validate that we have at least one image
    if (imageUrls.isEmpty) {
      return Container(); // Return empty container if no images
    }

    return GestureDetector(
      onTap: () => _showImageDialog(context, imageUrls),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 0),
        decoration: BoxDecoration(
          color: ColorConstants.primaryColor.withAlpha(40),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: ColorConstants.primaryColor.withAlpha(100),
          ),
        ),
        child: Row(
          children: [
            Text("View"),
            SizedBox(
              width: 10,
            ),
            Icon(
              Icons.remove_red_eye_outlined,
              size: iconSize,
              color: ColorConstants.primaryColor,
            ),
            // Show count badge if multiple images
            // if (imageUrls.length > 1)
            //   Positioned(
            //     right: 0,
            //     top: -2,
            //     child: Text(
            //       '${imageUrls.length}',
            //       style: const TextStyle(
            //         color: ColorConstants.white,
            //         fontSize: 15,
            //         fontWeight: FontWeight.bold,
            //       ),
            //       textAlign: TextAlign.center,
            //     ),
            //   ),
          ],
        ),
      ),
    );
  }

  void _showImageDialog(BuildContext context, List<String> imageUrls) {
    final screenSize = MediaQuery.of(context).size;
    final isTablet = screenSize.width > 600;
    final isMobile = screenSize.width <= 600;

    showDialog(
      context: context,
      barrierDismissible: true,
      barrierColor: Colors.black87,
      builder: (BuildContext context) {
        return _ImageGalleryDialog(
          imageUrls: imageUrls,
          isTablet: isTablet,
          isMobile: isMobile,
          screenSize: screenSize,
        );
      },
    );
  }
}

class _ImageGalleryDialog extends StatefulWidget {
  final List<String> imageUrls;
  final bool isTablet;
  final bool isMobile;
  final Size screenSize;

  const _ImageGalleryDialog({
    required this.imageUrls,
    required this.isTablet,
    required this.isMobile,
    required this.screenSize,
  });

  @override
  State<_ImageGalleryDialog> createState() => _ImageGalleryDialogState();
}

class _ImageGalleryDialogState extends State<_ImageGalleryDialog> {
  late PageController _pageController;
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _currentIndex = 0; // Always start from first image
    _pageController = PageController(initialPage: 0);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _previousImage() {
    if (_currentIndex > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _nextImage() {
    if (_currentIndex < widget.imageUrls.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: EdgeInsets.symmetric(
        horizontal: widget.isMobile ? 16 : 32,
        vertical: widget.isMobile ? 40 : 60,
      ),
      child: Container(
        constraints: BoxConstraints(
          maxWidth: widget.isTablet ? 600 : double.infinity,
          maxHeight: widget.screenSize.height * 0.8,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header with close button and image counter
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Image Preview',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.w600,
                              color: Colors.grey[800],
                            ),
                      ),
                      if (widget.imageUrls.length > 1)
                        Text(
                          '${_currentIndex + 1} of ${widget.imageUrls.length}',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 12,
                          ),
                        ),
                    ],
                  ),
                  Material(
                    color: Colors.transparent,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(20),
                      onTap: () => Navigator.of(context).pop(),
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.grey[100],
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Icon(
                          Icons.close,
                          size: 20,
                          color: Colors.grey[600],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Image container with navigation
            Flexible(
              child: Container(
                width: double.infinity,
                constraints: BoxConstraints(
                  minHeight: widget.screenSize.height * 0.3,
                  maxHeight: widget.screenSize.height * 0.6,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(16),
                    bottomRight: Radius.circular(16),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(16),
                    bottomRight: Radius.circular(16),
                  ),
                  child: Stack(
                    children: [
                      // PageView for images
                      PageView.builder(
                        controller: _pageController,
                        itemCount: widget.imageUrls.length,
                        onPageChanged: (index) {
                          setState(() {
                            _currentIndex = index;
                          });
                        },
                        itemBuilder: (context, index) {
                          return InteractiveViewer(
                            panEnabled: true,
                            scaleEnabled: true,
                            minScale: 0.5,
                            maxScale: 4.0,
                            child: Container(
                              width: double.infinity,
                              height: double.infinity,
                              child: Image.network(
                                widget.imageUrls[index],
                                fit: BoxFit.contain,
                                loadingBuilder:
                                    (context, child, loadingProgress) {
                                  if (loadingProgress == null) return child;
                                  return Center(
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        CircularProgressIndicator(
                                          value: loadingProgress
                                                      .expectedTotalBytes !=
                                                  null
                                              ? loadingProgress
                                                      .cumulativeBytesLoaded /
                                                  loadingProgress
                                                      .expectedTotalBytes!
                                              : null,
                                          strokeWidth: 3,
                                          valueColor:
                                              AlwaysStoppedAnimation<Color>(
                                            ColorConstants.primaryColor,
                                          ),
                                        ),
                                        const SizedBox(height: 16),
                                        Text(
                                          'Loading image...',
                                          style: TextStyle(
                                            color: Colors.grey[600],
                                            fontSize: 14,
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                },
                                errorBuilder: (context, error, stackTrace) {
                                  return Container(
                                    width: double.infinity,
                                    height: 200,
                                    color: Colors.grey[100],
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Icon(
                                          Icons.error_outline,
                                          size: 48,
                                          color: Colors.grey[400],
                                        ),
                                        const SizedBox(height: 16),
                                        Text(
                                          'Failed to load image',
                                          style: TextStyle(
                                            color: Colors.grey[600],
                                            fontSize: 16,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                        const SizedBox(height: 8),
                                        Text(
                                          'Please check your internet connection',
                                          style: TextStyle(
                                            color: Colors.grey[500],
                                            fontSize: 12,
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              ),
                            ),
                          );
                        },
                      ),

                      // Navigation arrows (only show if multiple images)
                      if (widget.imageUrls.length > 1) ...[
                        // Left arrow
                        if (_currentIndex > 0)
                          Positioned(
                            left: 16,
                            top: 0,
                            bottom: 0,
                            child: Center(
                              child: Material(
                                color: Colors.black.withOpacity(0.5),
                                borderRadius: BorderRadius.circular(24),
                                child: InkWell(
                                  borderRadius: BorderRadius.circular(24),
                                  onTap: _previousImage,
                                  child: Container(
                                    width: 48,
                                    height: 48,
                                    child: Icon(
                                      Icons.chevron_left,
                                      color: Colors.white,
                                      size: 32,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),

                        // Right arrow
                        if (_currentIndex < widget.imageUrls.length - 1)
                          Positioned(
                            right: 16,
                            top: 0,
                            bottom: 0,
                            child: Center(
                              child: Material(
                                color: Colors.black.withOpacity(0.5),
                                borderRadius: BorderRadius.circular(24),
                                child: InkWell(
                                  borderRadius: BorderRadius.circular(24),
                                  onTap: _nextImage,
                                  child: Container(
                                    width: 48,
                                    height: 48,
                                    child: Icon(
                                      Icons.chevron_right,
                                      color: Colors.white,
                                      size: 32,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                      ],
                    ],
                  ),
                ),
              ),
            ),

            // Bottom indicators and instructions
            Container(
              margin: const EdgeInsets.only(top: 16),
              child: Column(
                children: [
                  // Page indicators (dots) for multiple images
                  if (widget.imageUrls.length > 1)
                    Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(
                          widget.imageUrls.length,
                          (index) => GestureDetector(
                            onTap: () {
                              _pageController.animateToPage(
                                index,
                                duration: const Duration(milliseconds: 300),
                                curve: Curves.easeInOut,
                              );
                            },
                            child: Container(
                              margin: const EdgeInsets.symmetric(horizontal: 4),
                              width: 8,
                              height: 8,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: _currentIndex == index
                                    ? ColorConstants.primaryColor
                                    : Colors.white.withOpacity(0.5),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),

                  // Instructions
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.9),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.zoom_in,
                          size: 16,
                          color: Colors.grey[600],
                        ),
                        const SizedBox(width: 8),
                        Text(
                          widget.imageUrls.length > 1
                              ? 'Pinch to zoom • Swipe for next'
                              : 'Pinch to zoom',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 12,
                          ),
                        ),
                      ],
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
