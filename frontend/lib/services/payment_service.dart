import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'api_service.dart';
import '../config/app_config.dart';

class PaymentService {
  static Razorpay? _razorpay;
  static Function(String message)? _onSuccess;
  static Function(String error)? _onFailure;

  /// Initialize Razorpay and open payment checkout for the given invoice.
  ///
  /// [invoiceId] - UUID of the invoice to pay
  /// [onSuccess] - Callback with success message
  /// [onFailure] - Callback with error message
  static Future<void> openRazorpayCheckout({
    required String invoiceId,
    required Function(String message) onSuccess,
    required Function(String error) onFailure,
  }) async {
    _onSuccess = onSuccess;
    _onFailure = onFailure;

    try {
      // Step 1: Create Razorpay order via backend
      final orderData = await ApiService.post(
        '/bookings/invoice/$invoiceId/razorpay/create-order/',
      );

      // Step 2: Initialize Razorpay
      _razorpay?.clear();
      _razorpay = Razorpay();
      _razorpay!.on(Razorpay.EVENT_PAYMENT_SUCCESS, (
        PaymentSuccessResponse response,
      ) {
        _handlePaymentSuccess(response, invoiceId);
      });
      _razorpay!.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
      _razorpay!.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);

      // Step 3: Build checkout options
      final options = {
        'key': orderData['razorpay_key_id'] ?? AppConfig.razorpayKeyId,
        'amount': orderData['amount'],
        'currency': orderData['currency'] ?? 'INR',
        'order_id': orderData['razorpay_order_id'],
        'name': AppConfig.appName,
        'description':
            'Invoice ${orderData['invoice_number']} • Booking ${orderData['booking_number']}',
        'prefill': {
          'name': orderData['user_name'] ?? '',
          'email': orderData['user_email'] ?? '',
          'contact': orderData['user_phone'] ?? '',
        },
        'theme': {'color': '#6C63FF'},
        'retry': {'enabled': true, 'max_count': 3},
        'modal': {'confirm_close': true},
      };

      // Step 4: Open Razorpay checkout
      _razorpay!.open(options);
    } catch (e) {
      onFailure(e.toString());
    }
  }

  /// Handle successful payment — verify on backend
  static Future<void> _handlePaymentSuccess(
    PaymentSuccessResponse response,
    String invoiceId,
  ) async {
    try {
      // Verify payment on backend
      await ApiService.post(
        '/bookings/invoice/$invoiceId/razorpay/verify/',
        body: {
          'razorpay_payment_id': response.paymentId,
          'razorpay_order_id': response.orderId,
          'razorpay_signature': response.signature,
        },
      );

      _onSuccess?.call('Payment successful! ID: ${response.paymentId}');
    } catch (e) {
      _onFailure?.call('Payment done but verification failed: $e');
    } finally {
      _dispose();
    }
  }

  /// Handle payment error
  static void _handlePaymentError(PaymentFailureResponse response) {
    final message = response.message ?? 'Payment failed';
    _onFailure?.call(message);
    _dispose();
  }

  /// Handle external wallet selection
  static void _handleExternalWallet(ExternalWalletResponse response) {
    _onFailure?.call(
      'External wallet ${response.walletName} is not supported yet',
    );
    _dispose();
  }

  /// Clean up
  static void _dispose() {
    _razorpay?.clear();
    _razorpay = null;
    _onSuccess = null;
    _onFailure = null;
  }
}
