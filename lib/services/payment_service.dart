import 'dart:convert';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter/material.dart';

class PaymentService {
  static final PaymentService _instance = PaymentService._internal();
  factory PaymentService() => _instance;
  PaymentService._internal();

  // 🔑 Stripe Keys (Sandbox/Test keys)
  static String publishableKey = '';
  static String secretKey = '';

  // 📝 Initialize Stripe
  static Future<void> initialize() async {
    await dotenv.load();
    publishableKey = dotenv.env['STRIPE_PUBLISHABLE_KEY'] ?? 'pk_test_YOUR_KEY';
    secretKey = dotenv.env['STRIPE_SECRET_KEY'] ?? 'sk_test_YOUR_KEY';
    
    Stripe.publishableKey = publishableKey;
    await Stripe.instance.applySettings();
    print('✅ Stripe initialized');
  }

  // 💰 Make Payment (ANDROID OPTIMIZED - NO APPLE PAY)
  static Future<Map<String, dynamic>> makePayment({
    required int amount,      // Amount in paise (50000 = Rs. 500)
    required String currency, // 'inr', 'usd', 'pkr', etc.
    required String email,
    required String name,
  }) async {
    try {
      print('🟡 Creating payment intent for $amount $currency...');
      
      // Step 1: Create Payment Intent
      final paymentIntent = await _createPaymentIntent(amount, currency);
      
      if (paymentIntent == null) {
        return {
          'success': false,
          'message': 'Failed to create payment intent'
        };
      }

      // Step 2: Initialize Payment Sheet (FIXED - NO APPLE PAY)
      await Stripe.instance.initPaymentSheet(
        paymentSheetParameters: SetupPaymentSheetParameters(
          paymentIntentClientSecret: paymentIntent['client_secret'],
          merchantDisplayName: 'City Care',
          // customerEmail is optional - can be added if needed
          style: ThemeMode.light,
          // ✅ ONLY GOOGLE PAY - APPLE PAY REMOVED
          googlePay: PaymentSheetGooglePay(
            merchantCountryCode: currency == 'INR' ? 'IN' : 'PK',
            currencyCode: currency.toUpperCase(),
            testEnv: true,  // Test mode ke liye true, live mode mein false
          ),
          // ❌ APPLE PAY COMPLETELY HATAYA - Android ke liye zaroorat nahi
        ),
      );

      // Step 3: Present Payment Sheet
      print('🟡 Presenting payment sheet...');
      await Stripe.instance.presentPaymentSheet();

      // Step 4: Payment Successful
      print('✅ Payment successful!');
      return {
        'success': true,
        'paymentIntent': paymentIntent,
        'message': 'Payment successful!'
      };

    } on StripeException catch (e) {
      print('❌ Stripe error: $e');
      return {
        'success': false,
        'message': e.error.localizedMessage ?? 'Payment failed'
      };
    } catch (e) {
      print('❌ Error: $e');
      return {
        'success': false,
        'message': e.toString()
      };
    }
  }

  // 🏦 Create Payment Intent via Stripe API
  static Future<Map<String, dynamic>?> _createPaymentIntent(
    int amount, 
    String currency
  ) async {
    try {
      final response = await http.post(
        Uri.parse('https://api.stripe.com/v1/payment_intents'),
        headers: {
          'Authorization': 'Bearer $secretKey',
          'Content-Type': 'application/x-www-form-urlencoded',
        },
        body: {
          'amount': amount.toString(),
          'currency': currency.toLowerCase(), // lowercase mein behtar hai
          'payment_method_types[]': 'card',
        },
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        print('❌ Payment intent creation failed: ${response.body}');
        return null;
      }
    } catch (e) {
      print('❌ Error creating payment intent: $e');
      return null;
    }
  }

  // 🔄 Verify Payment Status
  static Future<bool> verifyPayment(String paymentIntentId) async {
    try {
      final response = await http.get(
        Uri.parse('https://api.stripe.com/v1/payment_intents/$paymentIntentId'),
        headers: {
          'Authorization': 'Bearer $secretKey',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['status'] == 'succeeded';
      }
      return false;
    } catch (e) {
      print('❌ Error verifying payment: $e');
      return false;
    }
  }
}