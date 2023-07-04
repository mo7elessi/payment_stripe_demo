import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:payment_stripe/services/stripe_service.dart';

class PayPage extends StatefulWidget {
  PayPage({super.key});

  @override
  State<PayPage> createState() => _PayPageState();
}

class _PayPageState extends State<PayPage> {
  final Stripe _stripe = Stripe.instance;
  CardFieldInputDetails? _details;
  @override
  Widget build(BuildContext context) {
    const billingDetails = BillingDetails(
      email: 'email@stripe.com',
      phone: '+48888000888',
      address: Address(
        city: 'Houston',
        country: 'US',
        line1: '1459  Circle Drive',
        line2: '',
        state: 'Texas',
        postalCode: '77063',
      ),
    );
    return Scaffold(
      appBar: AppBar(
        title: const Text("Pay"),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          CardField(
            onCardChanged: (details) {
              _details = details;
            },
          ),
          ElevatedButton(
            onPressed: () {
              stripeService.createPaymentMethod(billingDetails);
            },
            child: const Text("Create payment method"),
          ),
          ElevatedButton(
            onPressed: () {
              stripeService.confirmPayment(billingDetails: billingDetails);
            },
            child: const Text("Confirm payment"),
          ),
          ElevatedButton(
            onPressed: () async {
              await stripeService.initPaymentSheet(
                amount: "384",
                currency: "USD",
                countryCode: "US",
              );
            },
            child: const Text("Create payment intent"),
          )
        ],
      ),
    );
  }
}
