import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_widget_from_html_core/flutter_widget_from_html_core.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:share_plus/share_plus.dart';

import '../l10n/app_localizations.dart';

class DynamicInvoiceBottomSheet extends StatefulWidget {
  final String htmlContent;
  final bool useWebViewFallback;

  const DynamicInvoiceBottomSheet({
    Key? key,
    required this.htmlContent,
    this.useWebViewFallback = false,
  }) : super(key: key);

  @override
  State<DynamicInvoiceBottomSheet> createState() =>
      _DynamicInvoiceBottomSheetState();
}

class _DynamicInvoiceBottomSheetState extends State<DynamicInvoiceBottomSheet> {
  final GlobalKey _repaintBoundaryKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.9,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: Column(
        children: [
          // Handle bar with close button
          Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const SizedBox(width: 40), // For balance
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
          ),

          // Header with improved actions
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Invoice',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.blueGrey,
                  ),
                ),
                Row(
                  children: [
                    _buildActionButton(
                      icon: Icons.share,
                      label: 'PDF',
                      onPressed: () => _shareAsPdf(context),
                      color: Colors.red,
                    ),
                    const SizedBox(width: 8),
                    _buildActionButton(
                      icon: Icons.print,
                      label: 'Print',
                      onPressed: () => _printInvoice(context),
                      color: Colors.blue,
                    ),
                  ],
                ),
              ],
            ),
          ),

          Expanded(
            child: RepaintBoundary(
              key: _repaintBoundaryKey,
              child: Container(
                color: Colors.white,
                child: _buildHtmlWidgetWithEnhancedTableSupport(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _shareAsPdf(BuildContext context) async {
    try {
      // Show loading indicator
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(
          child: CircularProgressIndicator(),
        ),
      );

      final pdf = await _generatePdfDocument();

      // Hide loading indicator
      Navigator.of(context).pop();

      // Save to temporary file
      final output = await getTemporaryDirectory();
      final file = File(
          "${output.path}/invoice_${DateTime.now().millisecondsSinceEpoch}.pdf");
      await file.writeAsBytes(await pdf.save());

      // Share the file
      await Share.shareXFiles([XFile(file.path)], text: 'Your Invoice');
    } catch (e) {
      // Hide loading indicator if still showing
      if (Navigator.of(context).canPop()) {
        Navigator.of(context).pop();
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('  $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _printInvoice(BuildContext context) async {
    try {
      // Show loading indicator
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(
          child: CircularProgressIndicator(),
        ),
      );

      await Printing.layoutPdf(
        onLayout: (format) async {
          final pdf = await _generatePdfDocument();
          return pdf.save();
        },
      );

      // Hide loading indicator
      Navigator.of(context).pop();
    } catch (e) {
      // Hide loading indicator if still showing
      if (Navigator.of(context).canPop()) {
        Navigator.of(context).pop();
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('  $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<pw.Document> _generatePdfDocument() async {
    try {
      // Capture the widget as an image
      final RenderRepaintBoundary boundary = _repaintBoundaryKey.currentContext!
          .findRenderObject() as RenderRepaintBoundary;

      // Wait for the widget to be fully rendered
      await Future.delayed(const Duration(milliseconds: 100));

      final ui.Image image = await boundary.toImage(pixelRatio: 2.0);
      final ByteData? byteData =
          await image.toByteData(format: ui.ImageByteFormat.png);
      final Uint8List imageBytes = byteData!.buffer.asUint8List();

      // Create PDF document
      final pdf = pw.Document();

      pdf.addPage(
        pw.Page(
          pageFormat: PdfPageFormat.a4,
          margin: const pw.EdgeInsets.all(20),
          build: (pw.Context context) {
            return pw.Center(
              child: pw.Container(
                constraints: const pw.BoxConstraints(
                  maxWidth: 550,
                  maxHeight: 750,
                ),
                child: pw.Image(
                  pw.MemoryImage(imageBytes),
                  fit: pw.BoxFit.contain,
                ),
              ),
            );
          },
        ),
      );

      return pdf;
    } catch (e) {
      // Fallback: Create a simple text-based PDF if image capture fails
      return _createFallbackPdf();
    }
  }

  Future<pw.Document> _createFallbackPdf() async {
    final localizations = AppLocalizations.of(context)!;

    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(40),
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(
                localizations.invoice,
                style: pw.TextStyle(
                  fontSize: 24,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.SizedBox(height: 20),
              pw.Text(
                localizations.invoice_simplified_note,
                // 'Note: This is a simplified version of your invoice. The original formatting could not be preserved in PDF format.',
                style: pw.TextStyle(
                  fontSize: 12,
                  fontStyle: pw.FontStyle.italic,
                ),
              ),
              pw.SizedBox(height: 20),
              pw.Text(
                _stripHtmlTags(widget.htmlContent),
                style: const pw.TextStyle(fontSize: 10),
              ),
            ],
          );
        },
      ),
    );

    return pdf;
  }

  String _stripHtmlTags(String html) {
    // Simple HTML tag removal for fallback PDF
    return html
        .replaceAll(RegExp(r'<[^>]*>'), '')
        .replaceAll('&nbsp;', ' ')
        .replaceAll('&amp;', '&')
        .replaceAll('&lt;', '<')
        .replaceAll('&gt;', '>')
        .replaceAll('&quot;', '"')
        .trim();
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
    required Color color,
  }) {
    return ElevatedButton.icon(
      icon: Icon(icon, size: 18),
      label: Text(label),
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        foregroundColor: Colors.white,
        backgroundColor: color,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        elevation: 2,
      ),
    );
  }

  Widget _buildHtmlWidgetWithEnhancedTableSupport() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
        ),
        child: HtmlWidget(
          widget.htmlContent,
          textStyle: const TextStyle(
            fontSize: 14,
            color: Colors.black87,
          ),
          customStylesBuilder: (element) {
            if (element.localName == 'table') {
              return {
                'border-collapse': 'collapse',
                'width': '100%',
                'margin': '12px 0',
                'border-spacing': '0',
                'box-shadow': '0 1px 3px rgba(0,0,0,0.1)',
                'background-color': 'white',
              };
            }
            if (element.localName == 'th') {
              return {
                'border': '1px solid #ddd',
                'padding': '12px 8px',
                'text-align': 'left',
                'background-color': '#f8f9fa',
                'font-weight': '600',
                'color': '#333',
                'font-size': '13px',
              };
            }
            if (element.localName == 'td') {
              return {
                'border': '1px solid #ddd',
                'padding': '10px 8px',
                'text-align': 'left',
                'color': '#333',
                'font-size': '13px',
                'background-color': 'white',
              };
            }
            if (element.classes.contains('totals')) {
              return {
                'font-weight': 'bold',
                'color': '#2c3e50',
                'background-color': '#f8f9fa',
                'padding': '12px',
                'border-radius': '4px',
                'margin': '16px 0',
                'border': '1px solid #e9ecef',
              };
            }
            if (element.localName == 'hr') {
              return {
                'border': 'none',
                'height': '1px',
                'background-color': '#e0e0e0',
                'margin': '24px 0',
              };
            }
            if (element.localName == 'h3') {
              return {
                'color': '#3f51b5',
                'margin-bottom': '8px',
                'font-size': '16px',
                'font-weight': '600',
              };
            }
            if (element.localName == 'img') {
              return {
                'max-width': '100%',
                'height': 'auto',
              };
            }
            return null;
          },
          onErrorBuilder: (context, element, error) {
            final localizations = AppLocalizations.of(context)!;

            return Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.red.shade50,
                border: Border.all(color: Colors.red.shade200),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                children: [
                  Icon(Icons.error_outline,
                      color: Colors.red.shade600, size: 32),
                  const SizedBox(height: 8),
                  Text(
                    localizations.error_rendering_content,
                    style: TextStyle(
                      color: Colors.red.shade700,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    error.toString(),
                    style: TextStyle(
                      color: Colors.red.shade600,
                      fontSize: 12,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
