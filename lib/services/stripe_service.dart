import 'dart:convert';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:http/http.dart' as http;

class StripeService {
  final Stripe _stripe = Stripe.instance;
  static StripeService instence() => StripeService();
  Map? paymentIntent;
  Future<void> initPaymentSheet({
    required String amount,
    required String currency,
    required String countryCode,
  }) async {
    await createPaymentIntent(
      amount: amount,
      currency: currency,
    ).then((value) async {
      paymentIntent = value;
      try {
        await _stripe.initPaymentSheet(
          paymentSheetParameters: SetupPaymentSheetParameters(
            paymentIntentClientSecret: paymentIntent!['client_secret'],
            customFlow: true,
            customerEphemeralKeySecret: paymentIntent!['ephemeralKey'],
            customerId: paymentIntent!['customer'],
            applePay: PaymentSheetApplePay(merchantCountryCode: countryCode),
            googlePay: PaymentSheetGooglePay(merchantCountryCode: countryCode),
          ),
        );
      } catch (error) {
        throw Exception(error);
      }
    });
    await displayPaymentSheet();
  }

  Future<PaymentMethod> createPaymentMethod(
    BillingDetails? billingDetails,
  ) async {
    final paymentMethod = await _stripe.createPaymentMethod(
      params: PaymentMethodParams.card(
        paymentMethodData: PaymentMethodData(
          billingDetails: billingDetails,
        ),
      ),
    );
    print("create payment method data: $paymentIntent");
    return paymentMethod;
  }

  Future<void> confirmPayment({
    BillingDetails? billingDetails,
  }) async {
    try {
      final result = await Stripe.instance.confirmPayment(
        paymentIntentClientSecret: paymentIntent!['client_secret'],
        data: PaymentMethodParams.card(
          paymentMethodData: PaymentMethodData(
            billingDetails: billingDetails,
          ),
        ),
        options: const PaymentMethodOptions(
          setupFutureUsage: PaymentIntentsFutureUsage.OffSession,
        ),
      );
      print("confirm payment data: ${result.amount}");
    } catch (error) {
      throw Exception(error);
    }
  }

  Future<Map<String, dynamic>> createPaymentIntent({
    required String amount,
    required String currency,
  }) async {
    try {
      Map<String, dynamic> body = {
        'amount': int.parse(amount),
        'currency': currency,
      };
      var response = await http.post(
        Uri.parse('https://api.stripe.com/v1/payment_intents'),
        headers: {
          'Authorization':
              'Bearer sk_test_51NPmvwHheaTFvSMhzt23P2liypkkIoeM07u2tb0iJ2z9dTxJK17qUlJQ9UhYputpJjLCBSabPDykg7qLeehAGuR2007kf5aQtr',
          'Content-Type': 'application/x-www-form-urlencoded'
        },
        body: body,
      );
      return json.decode(response.body);
    } catch (err) {
      throw Exception(err.toString());
    }
  }

  Future<void> displayPaymentSheet() async {
    try {
      await _stripe.presentPaymentSheet().then((value) {
        paymentIntent = null;
      }).onError((error, stackTrace) {
        throw Exception(error);
      });
    } on StripeException catch (excption) {
      throw StripeException(error: excption.error);
    } catch (error) {
      throw Exception(error);
    }
  }
}

StripeService stripeService = StripeService.instence();
