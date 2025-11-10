import 'package:flutter/material.dart';
import 'package:r_w_r/components/app_appbar.dart';
import 'package:webview_flutter/webview_flutter.dart';

class LaunchUrl extends StatefulWidget {
  final String url;

  const LaunchUrl({super.key, required this.url});

  @override
  State<LaunchUrl> createState() => _LaunchUrlState();
}

class _LaunchUrlState extends State<LaunchUrl> {
  late final WebViewController controller;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (_) => setState(() => isLoading = true),
          onPageFinished: (_) => setState(() => isLoading = false),
        ),
      )
      ..loadRequest(Uri.parse(widget.url));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        actions: [],
      ),
      body: Stack(
        children: [
          WebViewWidget(controller: controller),
          if (isLoading) const Center(child: CircularProgressIndicator()),
        ],
      ),
    );
  }
}
