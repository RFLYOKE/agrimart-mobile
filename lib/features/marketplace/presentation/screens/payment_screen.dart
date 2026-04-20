import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class PaymentScreen extends StatefulWidget {
  final String snapToken;
  
  const PaymentScreen({super.key, required this.snapToken});

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  late final WebViewController _controller;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    // Assuming backend created snapUrl like https://app.sandbox.midtrans.com/snap/v2/vtweb/SNAP_TOKEN
    final snapUrl = 'https://app.sandbox.midtrans.com/snap/v2/vtweb/${widget.snapToken}';

    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageFinished: (String url) {
            setState(() {
              _isLoading = false;
            });
          },
          onNavigationRequest: (NavigationRequest request) {
            // Callback simulation handling based on midtrans redirect logic
            if (request.url.contains('transaction_status=capture') || request.url.contains('transaction_status=settlement')) {
              _handlePaymentSuccess();
              return NavigationDecision.prevent;
            } else if (request.url.contains('transaction_status=deny') || request.url.contains('transaction_status=cancel')) {
              _handlePaymentFailed();
              return NavigationDecision.prevent;
            } else if (request.url.contains('transaction_status=pending')) {
               _handlePaymentPending();
               return NavigationDecision.prevent;
            }
            return NavigationDecision.navigate;
          },
        ),
      )
      ..loadRequest(Uri.parse(snapUrl));
  }

  void _handlePaymentSuccess() {
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Pembayaran Berhasil!')));
    Navigator.of(context).pop(); // Back to checkout, which then pops to cart or home
  }

  void _handlePaymentFailed() {
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Pembayaran Gagal atau Dibatalkan!')));
    Navigator.of(context).pop(); 
  }

  void _handlePaymentPending() {
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Menunggu Pembayaran (Pending)...')));
    Navigator.of(context).pop(); 
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Selesaikan Pembayaran'),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () {
            // User manually closes webview
             Navigator.of(context).pop(); 
          },
        ),
      ),
      body: Stack(
        children: [
          WebViewWidget(controller: _controller),
          if (_isLoading)
            const Center(child: CircularProgressIndicator()),
        ],
      ),
    );
  }
}
